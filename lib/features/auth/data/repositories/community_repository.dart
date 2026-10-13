import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/community_model.dart';

/// Repository untuk mengelola profil komunitas, upload berkas legalitas,
/// serta proses verifikasi oleh Admin.
class CommunityRepository {
  final SupabaseClient _client;

  CommunityRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService.client;

  /// Ambil detail komunitas berdasarkan profileId
  Future<CommunityModel?> getCommunityByProfileId(String profileId) async {
    final data = await _client
        .from('communities')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();

    if (data == null) return null;
    return CommunityModel.fromJson(data);
  }

  /// Ambil detail komunitas berdasarkan ID komunitas
  Future<CommunityModel?> getCommunityById(String communityId) async {
    final data = await _client
        .from('communities')
        .select()
        .eq('id', communityId)
        .maybeSingle();

    if (data == null) return null;
    return CommunityModel.fromJson(data);
  }

  /// Perbarui informasi profil komunitas (nama & deskripsi/visi-misi)
  Future<CommunityModel> updateCommunityProfile({
    required String profileId,
    String? communityName,
    String? description,
  }) async {
    final updates = <String, dynamic>{
      if (communityName != null) 'community_name': communityName.trim(),
      if (description != null) 'description': description.trim(),
    };

    final data = await _client
        .from('communities')
        .update(updates)
        .eq('profile_id', profileId)
        .select()
        .single();

    return CommunityModel.fromJson(data);
  }

  /// Unggah berkas dokumen legalitas (PDF atau Gambar) ke Supabase Storage `legal-docs`
  /// Menggunakan file path/file lokal
  Future<CommunityModel> uploadLegalDocumentFile({
    required String userId,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = file.path.split('.').last.toLowerCase();
    final fileName = 'legal_doc_${DateTime.now().millisecondsSinceEpoch}.$extension';
    return uploadLegalDocumentBytes(
      userId: userId,
      bytes: bytes,
      fileName: fileName,
    );
  }

  /// Unggah berkas dokumen legalitas dalam bentuk bytes
  Future<CommunityModel> uploadLegalDocumentBytes({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    // Jalur penyimpanan: {userId}/{fileName}
    final storagePath = '$userId/$fileName';

    // 1. Upload ke private bucket legal-docs
    await _client.storage.from('legal-docs').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    // 2. Buat signed URL (berlaku 1 tahun) agar dapat diakses oleh admin & komunitas
    final signedUrl = await _client.storage
        .from('legal-docs')
        .createSignedUrl(storagePath, 60 * 60 * 24 * 365);

    // 3. Simpan URL ke tabel communities dan ubah status verifikasi menjadi 'pending'
    final data = await _client
        .from('communities')
        .update({
          'legal_document_url': signedUrl,
          'verification_status': 'pending',
          'rejection_reason': null,
        })
        .eq('profile_id', userId)
        .select()
        .single();

    return CommunityModel.fromJson(data);
  }

  /// Ambil daftar seluruh komunitas (khusus admin, mendukung filter status)
  Future<List<CommunityModel>> getCommunitiesList({String? statusFilter}) async {
    var query = _client.from('communities').select();

    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
      query = query.eq('verification_status', statusFilter);
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => CommunityModel.fromJson(e)).toList();
  }

  /// Setujui komunitas oleh admin
  Future<CommunityModel> approveCommunity({
    required String communityId,
    required String adminId,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final data = await _client
        .from('communities')
        .update({
          'verification_status': 'verified',
          'verified_at': now,
          'verified_by': adminId,
          'rejection_reason': null,
        })
        .eq('id', communityId)
        .select()
        .single();

    return CommunityModel.fromJson(data);
  }

  /// Tolak verifikasi komunitas oleh admin beserta alasannya
  Future<CommunityModel> rejectCommunity({
    required String communityId,
    required String rejectionReason,
  }) async {
    final data = await _client
        .from('communities')
        .update({
          'verification_status': 'rejected',
          'rejection_reason': rejectionReason.trim(),
        })
        .eq('id', communityId)
        .select()
        .single();

    return CommunityModel.fromJson(data);
  }
}
