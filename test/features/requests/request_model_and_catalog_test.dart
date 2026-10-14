import 'package:flutter_test/flutter_test.dart';
import 'package:carecycle/features/items/data/models/item_model.dart';
import 'package:carecycle/features/items/presentation/providers/catalog_provider.dart';
import 'package:carecycle/features/requests/data/models/request_model.dart';
import 'package:carecycle/features/requests/presentation/providers/request_provider.dart';

void main() {
  group('RequestModel Tests', () {
    test('Parsing dari JSON dengan metadata relasi komunitas dan barang', () {
      final json = {
        'id': 'req-1',
        'item_id': 'item-101',
        'community_id': 'comm-202',
        'reason': 'Dibutuhkan untuk anak-anak asuh di panti',
        'status': 'submitted',
        'delivery_method': 'courier',
        'tracking_number': 'JNE123456789',
        'notes': 'Mohon kirim ke alamat sekretariat',
        'created_at': '2026-10-14T08:00:00Z',
        'communities': {
          'community_name': 'Yayasan Kasih Bangsa',
          'verification_status': 'verified',
          'description': 'Yayasan sosial peduli yatim piatu',
        },
        'items': {
          'name': 'Buku Ensiklopedia Sains',
          'category': 'Buku',
          'donor_id': 'donor-999',
          'photo_urls': ['https://example.com/buku.jpg'],
        },
      };

      final req = RequestModel.fromJson(json);

      expect(req.id, 'req-1');
      expect(req.itemId, 'item-101');
      expect(req.communityName, 'Yayasan Kasih Bangsa');
      expect(req.isCommunityVerified, isTrue);
      expect(req.itemName, 'Buku Ensiklopedia Sains');
      expect(req.itemPhotoUrl, 'https://example.com/buku.jpg');
      expect(req.isSubmitted, isTrue);
      expect(req.isApproved, isFalse);
      expect(req.statusDisplay, 'Menunggu Persetujuan');
      expect(req.deliveryMethodDisplay, 'Kurir / Ekspedisi');
      expect(req.trackingNumber, 'JNE123456789');
    });

    test('Transisi status persetujuan dan metode serah terima', () {
      const initial = RequestModel(
        id: 'req-2',
        itemId: 'item-2',
        communityId: 'comm-2',
        reason: 'Untuk posko tanggap bencana',
        status: 'submitted',
      );

      final approved = initial.copyWith(
        status: 'approved',
        deliveryMethod: 'self_deliver',
        notes: 'Akan diantar besok pukul 10 pagi',
      );

      expect(approved.isApproved, isTrue);
      expect(approved.statusDisplay, 'Disetujui (Sedang Diproses)');
      expect(approved.deliveryMethodDisplay, 'Diantar Langsung oleh Donatur');
      expect(approved.notes, 'Akan diantar besok pukul 10 pagi');
    });

    test('Metode serah terima pickup ditampilkan dengan benar', () {
      const req = RequestModel(
        id: 'req-3',
        itemId: 'item-3',
        communityId: 'comm-3',
        reason: 'Alasan',
        deliveryMethod: 'pickup',
      );

      expect(req.deliveryMethodDisplay, 'Dijemput oleh Komunitas');
    });
  });

  group('ItemModel In-Process Status Tests', () {
    test('Status processing atau in_process terdeteksi sebagai isInProcess', () {
      const itemProcessing = ItemModel(
        id: '1',
        donorId: 'd1',
        name: 'Sepatu Olahraga',
        description: 'Ukuran 42',
        category: 'Pakaian',
        condition: 'Baik',
        location: 'Jakarta',
        status: 'processing',
      );

      const itemInProcess = ItemModel(
        id: '2',
        donorId: 'd1',
        name: 'Tas Ransel',
        description: 'Warna Hitam',
        category: 'Alat Sekolah',
        condition: 'Layak Pakai',
        location: 'Bandung',
        status: 'in_process',
      );

      expect(itemProcessing.isInProcess, isTrue);
      expect(itemProcessing.statusDisplay, 'Sedang Diproses');
      expect(itemInProcess.isInProcess, isTrue);
      expect(itemInProcess.statusDisplay, 'Sedang Diproses');
    });
  });

  group('CatalogState & DonorRequestsState Tests', () {
    test('CatalogState memperbarui kategori dan query pencarian dengan benar', () {
      const state = CatalogState(
        items: [],
        selectedCategory: 'Semua',
        searchQuery: '',
      );

      final filtered = state.copyWith(
        selectedCategory: 'Pakaian',
        searchQuery: 'kemeja',
      );

      expect(filtered.selectedCategory, 'Pakaian');
      expect(filtered.searchQuery, 'kemeja');
    });

    test('DonorRequestsState menghitung jumlah pendingRequestsCount dengan tepat', () {
      const r1 = RequestModel(
        id: '1',
        itemId: 'i1',
        communityId: 'c1',
        reason: 'R1',
        status: 'submitted',
      );
      const r2 = RequestModel(
        id: '2',
        itemId: 'i2',
        communityId: 'c2',
        reason: 'R2',
        status: 'approved',
      );

      const state = DonorRequestsState(requests: [r1, r2]);
      expect(state.pendingRequestsCount, 1);
    });
  });
}
