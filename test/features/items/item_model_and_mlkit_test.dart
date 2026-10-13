import 'package:flutter_test/flutter_test.dart';
import 'package:carecycle/core/services/ml_kit_service.dart';
import 'package:carecycle/features/items/data/models/item_model.dart';
import 'package:carecycle/features/items/presentation/providers/item_provider.dart';

void main() {
  group('MlKitService Category Classification Tests', () {
    test('Memetakan pakaian dan alas kaki ke kategori Pakaian', () {
      expect(MlKitService.mapRawLabelsToCategoryName(['Shirt', 'Collar']), 'Pakaian');
      expect(MlKitService.mapRawLabelsToCategoryName(['Jeans', 'Denim']), 'Pakaian');
      expect(MlKitService.mapRawLabelsToCategoryName(['Sneakers', 'Shoe']), 'Pakaian');
      expect(MlKitService.mapRawLabelsToCategoryName(['Jacket', 'Coat']), 'Pakaian');
      expect(MlKitService.mapRawLabelsToCategoryName(['Hoodie']), 'Pakaian');
    });

    test('Memetakan literatur dan buku ke kategori Buku', () {
      expect(MlKitService.mapRawLabelsToCategoryName(['Book', 'Publication']), 'Buku');
      expect(MlKitService.mapRawLabelsToCategoryName(['Novel']), 'Buku');
      expect(MlKitService.mapRawLabelsToCategoryName(['Textbook']), 'Buku');
      expect(MlKitService.mapRawLabelsToCategoryName(['Magazine']), 'Buku');
    });

    test('Memetakan gawai dan perangkat ke kategori Elektronik', () {
      expect(MlKitService.mapRawLabelsToCategoryName(['Laptop', 'Computer']), 'Elektronik');
      expect(MlKitService.mapRawLabelsToCategoryName(['Smartphone', 'Cell phone']), 'Elektronik');
      expect(MlKitService.mapRawLabelsToCategoryName(['Headphones', 'Audio']), 'Elektronik');
      expect(MlKitService.mapRawLabelsToCategoryName(['Television', 'Display']), 'Elektronik');
    });

    test('Memetakan alat tulis dan tas ke kategori Alat Sekolah', () {
      expect(MlKitService.mapRawLabelsToCategoryName(['Backpack', 'School bag']), 'Alat Sekolah');
      expect(MlKitService.mapRawLabelsToCategoryName(['Pen', 'Stationery']), 'Alat Sekolah');
      expect(MlKitService.mapRawLabelsToCategoryName(['Pencil case', 'Ruler']), 'Alat Sekolah');
      expect(MlKitService.mapRawLabelsToCategoryName(['Calculator']), 'Alat Sekolah');
    });

    test('Objek yang tidak dikenal otomatis fallback ke kategori Lainnya', () {
      expect(MlKitService.mapRawLabelsToCategoryName(['Tree', 'Sky', 'Grass']), 'Lainnya');
      expect(MlKitService.mapRawLabelsToCategoryName([]), 'Lainnya');
    });
  });

  group('ItemModel Tests', () {
    test('Parsing dari Supabase JSON dan serialisasi toJson', () {
      final json = {
        'id': 'item-123',
        'donor_id': 'donor-456',
        'name': 'Kemeja Katun Putih',
        'description': 'Kondisi 95% bagus tanpa cacat',
        'category': 'Pakaian',
        'condition': 'Sangat Baik',
        'photo_urls': ['https://example.com/item.jpg'],
        'location': 'Bandung',
        'status': 'available',
        'created_at': '2026-10-10T10:00:00Z',
      };

      final item = ItemModel.fromJson(json);

      expect(item.id, 'item-123');
      expect(item.name, 'Kemeja Katun Putih');
      expect(item.category, 'Pakaian');
      expect(item.isAvailable, isTrue);
      expect(item.isPendingSync, isFalse);
      expect(item.statusDisplay, 'Tersedia');
      expect(item.photoUrls.length, 1);

      final outMap = item.toJson();
      expect(outMap['name'], 'Kemeja Katun Putih');
      expect(outMap['status'], 'available');
    });

    test('Serialisasi dan Deserialisasi Hive Draft Map', () {
      const draft = ItemModel(
        id: 'draft-999',
        donorId: 'donor-456',
        name: 'Buku Pemrograman Flutter',
        description: 'Buku panduan lengkap',
        category: 'Buku',
        condition: 'Baik',
        location: 'Jakarta',
        status: 'pending_sync',
        isDraft: true,
        localPhotoPath: '/data/user/0/cache/foto1.jpg',
      );

      expect(draft.isPendingSync, isTrue);
      expect(draft.statusDisplay, 'Menunggu koneksi');

      final draftMap = draft.toDraftMap();
      expect(draftMap['is_draft'], isTrue);
      expect(draftMap['status'], 'pending_sync');
      expect(draftMap['local_photo_path'], '/data/user/0/cache/foto1.jpg');

      final reconstructed = ItemModel.fromDraftMap(draftMap);
      expect(reconstructed.id, 'draft-999');
      expect(reconstructed.name, 'Buku Pemrograman Flutter');
      expect(reconstructed.isPendingSync, isTrue);
      expect(reconstructed.statusDisplay, 'Menunggu koneksi');
      expect(reconstructed.localPhotoPath, '/data/user/0/cache/foto1.jpg');
    });

    test('copyWith bekerja dengan tepat pada metadata draft', () {
      const draft = ItemModel(
        id: 'draft-1',
        donorId: 'd1',
        name: 'Item A',
        description: 'Desc A',
        category: 'Lainnya',
        condition: 'Layak Pakai',
        location: 'Surabaya',
        isDraft: true,
      );

      final updated = draft.copyWith(
        name: 'Item A Baru',
        syncError: 'SocketException',
      );

      expect(updated.name, 'Item A Baru');
      expect(updated.syncError, 'SocketException');
      expect(updated.id, 'draft-1');
    });
  });

  group('MyItemsState Tests', () {
    test('Menghitung jumlah pendingDraftsCount dengan benar', () {
      const item1 = ItemModel(
        id: '1',
        donorId: 'd1',
        name: 'Buku',
        description: 'Desc',
        category: 'Buku',
        condition: 'Baik',
        location: 'Jakarta',
        status: 'available',
      );
      const item2 = ItemModel(
        id: '2',
        donorId: 'd1',
        name: 'Baju',
        description: 'Desc',
        category: 'Pakaian',
        condition: 'Baik',
        location: 'Jakarta',
        status: 'pending_sync',
        isDraft: true,
      );

      const state = MyItemsState(items: [item1, item2]);
      expect(state.pendingDraftsCount, 1);
      expect(state.hasPendingDrafts, isTrue);
    });
  });
}
