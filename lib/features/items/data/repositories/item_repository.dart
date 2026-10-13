import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/item_model.dart';

/// Repository untuk mengelola katalog barang donasi, upload berkas,
/// penyimpanan draft lokal di Hive, dan sinkronisasi offline-ke-online.
class ItemRepository {
  final SupabaseClient _client;
  static const _uuid = Uuid();

  ItemRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService.client;

  /// Buat barang baru:
  /// - Jika online: langsung upload foto ke Supabase Storage & insert data ke database.
  /// - Jika offline: simpan sebagai draft di Hive dengan status 'pending_sync'.
  Future<ItemModel> createItem({
    required String donorId,
    required String name,
    required String description,
    required String category,
    required String condition,
    required String location,
    File? photoFile,
  }) async {
    final isOnline = await ConnectivityService.isConnected();

    if (!isOnline) {
      // Simpan sebagai draft lokal di Hive saat offline
      final draftId = _uuid.v4();
      final draft = ItemModel(
        id: draftId,
        donorId: donorId,
        name: name.trim(),
        description: description.trim(),
        category: category,
        condition: condition,
        location: location.trim(),
        photoUrls: const [],
        status: 'pending_sync',
        createdAt: DateTime.now(),
        isDraft: true,
        localPhotoPath: photoFile?.path,
      );

      await HiveService.saveDraft(draftId, draft.toDraftMap());
      return draft;
    }

    // Alur Online: Upload foto ke bucket 'item-photos' jika ada
    List<String> photoUrls = [];
    if (photoFile != null && await photoFile.exists()) {
      final ext = photoFile.path.split('.').last.toLowerCase();
      final storagePath = '$donorId/${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.$ext';

      await _client.storage.from('item-photos').upload(
            storagePath,
            photoFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage.from('item-photos').getPublicUrl(storagePath);
      photoUrls.add(publicUrl);
    }

    // Insert ke tabel public.items
    final data = await _client.from('items').insert({
      'donor_id': donorId,
      'name': name.trim(),
      'description': description.trim(),
      'category': category,
      'condition': condition,
      'photo_urls': photoUrls,
      'location': location.trim(),
      'status': 'available',
    }).select().single();

    return ItemModel.fromJson(data);
  }

  /// Ambil daftar barang yang diunggah oleh donatur (gabungan data online & draft lokal)
  Future<List<ItemModel>> getMyItems(String donorId) async {
    // 1. Ambil semua draft lokal dari Hive milik donatur ini
    final localDrafts = HiveService.getAllDrafts()
        .where((d) => d['donor_id'] == donorId)
        .map((d) => ItemModel.fromDraftMap(d))
        .toList();

    List<ItemModel> onlineItems = [];

    // 2. Ambil dari Supabase jika ada koneksi
    try {
      final isOnline = await ConnectivityService.isConnected();
      if (isOnline) {
        final data = await _client
            .from('items')
            .select()
            .eq('donor_id', donorId)
            .order('created_at', ascending: false);

        onlineItems = (data as List).map((e) => ItemModel.fromJson(e)).toList();

        // Simpan cache lokal
        await HiveService.setCache(
          'cached_my_items_$donorId',
          onlineItems.map((e) => e.toJson()).toList(),
        );
      } else {
        // Ambil dari cache jika offline
        final cached = HiveService.getCache('cached_my_items_$donorId');
        if (cached is List) {
          onlineItems = cached
              .map((e) => ItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }
    } catch (_) {
      // Jika terjadi kesalahan koneksi, ambil dari cache
      final cached = HiveService.getCache('cached_my_items_$donorId');
      if (cached is List) {
        onlineItems = cached
            .map((e) => ItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }

    // Gabungkan: Draft offline di atas, diikuti barang yang sudah online
    return [...localDrafts, ...onlineItems];
  }

  /// Sinkronisasi semua draft yang tertunda di Hive ke Supabase
  Future<int> syncPendingDrafts(String donorId) async {
    final isOnline = await ConnectivityService.isConnected();
    if (!isOnline) return 0;

    final drafts = HiveService.getAllDrafts()
        .where((d) => d['donor_id'] == donorId)
        .map((d) => ItemModel.fromDraftMap(d))
        .toList();

    if (drafts.isEmpty) return 0;

    int syncedCount = 0;

    for (final draft in drafts) {
      try {
        List<String> photoUrls = List.from(draft.photoUrls);

        // Upload foto lokal jika ada
        if (draft.localPhotoPath != null) {
          final file = File(draft.localPhotoPath!);
          if (await file.exists()) {
            final ext = file.path.split('.').last.toLowerCase();
            final storagePath =
                '$donorId/${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.$ext';

            await _client.storage.from('item-photos').upload(
                  storagePath,
                  file,
                  fileOptions: const FileOptions(upsert: true),
                );

            final publicUrl =
                _client.storage.from('item-photos').getPublicUrl(storagePath);
            photoUrls.add(publicUrl);
          }
        }

        // Simpan ke Supabase
        await _client.from('items').insert({
          'donor_id': draft.donorId,
          'name': draft.name,
          'description': draft.description,
          'category': draft.category,
          'condition': draft.condition,
          'photo_urls': photoUrls,
          'location': draft.location,
          'status': 'available',
        });

        // Hapus dari Hive jika berhasil
        await HiveService.deleteDraft(draft.id);
        syncedCount++;
      } catch (e) {
        // Catat error pada draft agar tidak terhapus
        final updatedDraft = draft.copyWith(syncError: e.toString());
        await HiveService.saveDraft(draft.id, updatedDraft.toDraftMap());
      }
    }

    return syncedCount;
  }

  /// Hapus barang (baik draft lokal maupun item Supabase)
  Future<void> deleteItem(String itemId, {bool isDraft = false}) async {
    if (isDraft) {
      await HiveService.deleteDraft(itemId);
    } else {
      await _client.from('items').delete().eq('id', itemId);
    }
  }
}
