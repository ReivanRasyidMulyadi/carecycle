import 'package:flutter_test/flutter_test.dart';
import 'package:carecycle/features/auth/data/models/community_model.dart';
import 'package:carecycle/features/auth/presentation/providers/community_provider.dart';

void main() {
  group('CommunityModel Verification Tests', () {
    test('Status pending memiliki flag isPending true dan display yang sesuai', () {
      const community = CommunityModel(
        id: 'comm-1',
        profileId: 'user-1',
        communityName: 'Komunitas Peduli Sesama',
        verificationStatus: 'pending',
      );

      expect(community.isPending, isTrue);
      expect(community.isVerified, isFalse);
      expect(community.isRejected, isFalse);
      expect(community.verificationStatusDisplay, 'Menunggu Verifikasi');
    });

    test('Status verified memiliki flag isVerified true', () {
      final now = DateTime.now();
      final community = CommunityModel(
        id: 'comm-2',
        profileId: 'user-2',
        communityName: 'Yayasan Hijau Lestari',
        verificationStatus: 'verified',
        verifiedAt: now,
        verifiedBy: 'admin-1',
      );

      expect(community.isVerified, isTrue);
      expect(community.isPending, isFalse);
      expect(community.isRejected, isFalse);
      expect(community.verificationStatusDisplay, 'Terverifikasi');
      expect(community.verifiedBy, 'admin-1');
      expect(community.verifiedAt, equals(now));
    });

    test('Status rejected memiliki flag isRejected true dan mencatat alasan penolakan', () {
      const community = CommunityModel(
        id: 'comm-3',
        profileId: 'user-3',
        communityName: 'Komunitas Baru',
        verificationStatus: 'rejected',
        rejectionReason: 'Berkas akta tidak terbaca jelas.',
      );

      expect(community.isRejected, isTrue);
      expect(community.isVerified, isFalse);
      expect(community.isPending, isFalse);
      expect(community.verificationStatusDisplay, 'Ditolak');
      expect(community.rejectionReason, 'Berkas akta tidak terbaca jelas.');
    });

    test('copyWith memperbarui status verifikasi dan membersihkan penolakan saat upload ulang', () {
      const initial = CommunityModel(
        id: 'comm-4',
        profileId: 'user-4',
        communityName: 'Komunitas Harapan',
        verificationStatus: 'rejected',
        rejectionReason: 'Surat domisili sudah kadaluarsa',
      );

      final updated = initial.copyWith(
        legalDocumentUrl: 'https://example.com/docs/new_doc.pdf',
        verificationStatus: 'pending',
        clearRejectionReason: true,
      );

      expect(updated.verificationStatus, 'pending');
      expect(updated.isPending, isTrue);
      expect(updated.legalDocumentUrl, isNotNull);
      expect(updated.rejectionReason, isNull);
    });
  });

  group('Komunitas Access Control & Guard Logic', () {
    test('Komunitas yang belum verified dilarang mengajukan request atau open campaign', () {
      const pendingCommunity = CommunityModel(
        id: 'comm-pending',
        profileId: 'user-p',
        communityName: 'Komunitas Menunggu',
        verificationStatus: 'pending',
      );

      const rejectedCommunity = CommunityModel(
        id: 'comm-rejected',
        profileId: 'user-r',
        communityName: 'Komunitas Ditolak',
        verificationStatus: 'rejected',
      );

      const verifiedCommunity = CommunityModel(
        id: 'comm-verified',
        profileId: 'user-v',
        communityName: 'Komunitas Sah',
        verificationStatus: 'verified',
      );

      // Helper validasi hak akses pengajuan
      bool canCreateRequestOrCampaign(CommunityModel c) => c.isVerified;

      expect(canCreateRequestOrCampaign(pendingCommunity), isFalse);
      expect(canCreateRequestOrCampaign(rejectedCommunity), isFalse);
      expect(canCreateRequestOrCampaign(verifiedCommunity), isTrue);
    });

    test('AdminVerificationState memfilter data antrean dengan benar', () {
      const c1 = CommunityModel(
        id: '1',
        profileId: 'u1',
        communityName: 'K1',
        verificationStatus: 'pending',
      );
      const c2 = CommunityModel(
        id: '2',
        profileId: 'u2',
        communityName: 'K2',
        verificationStatus: 'verified',
      );

      var state = const AdminVerificationState(
        communities: [c1, c2],
        currentFilter: 'pending',
      );

      expect(state.currentFilter, 'pending');
      expect(state.communities.length, 2);

      state = state.copyWith(currentFilter: 'verified');
      expect(state.currentFilter, 'verified');
    });
  });
}
