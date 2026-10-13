import 'package:flutter_test/flutter_test.dart';
import 'package:carecycle/features/auth/data/models/user_model.dart';
import 'package:carecycle/features/auth/data/models/community_model.dart';

void main() {
  group('UserModel', () {
    test('berhasil parsing dari Map JSON ke UserModel', () {
      final json = {
        'id': 'user-uuid-123',
        'email': 'donatur@carecycle.id',
        'full_name': 'Budi Santoso',
        'role': 'donatur',
        'care_points': 50,
        'avatar_url': 'https://example.com/avatar.jpg',
        'phone_number': '08123456789',
        'address': 'Jl. Kebaikan No. 10',
        'created_at': '2026-10-13T10:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-uuid-123');
      expect(user.email, 'donatur@carecycle.id');
      expect(user.fullName, 'Budi Santoso');
      expect(user.role, 'donatur');
      expect(user.isDonatur, isTrue);
      expect(user.isKomunitas, isFalse);
      expect(user.isAdmin, isFalse);
      expect(user.roleDisplay, 'Donatur');
      expect(user.carePoints, 50);
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('toJson menghasilkan Map yang sesuai', () {
      const user = UserModel(
        id: 'user-456',
        email: 'komunitas@carecycle.id',
        fullName: 'Yayasan Peduli',
        role: 'komunitas',
        carePoints: 10,
      );

      final json = user.toJson();

      expect(json['id'], 'user-456');
      expect(json['email'], 'komunitas@carecycle.id');
      expect(json['full_name'], 'Yayasan Peduli');
      expect(json['role'], 'komunitas');
      expect(json['care_points'], 10);
      expect(user.isKomunitas, isTrue);
      expect(user.roleDisplay, 'Komunitas');
    });

    test('copyWith memperbarui field yang ditentukan dengan tepat', () {
      const user = UserModel(
        id: 'u-1',
        email: 'test@mail.com',
        fullName: 'Nama Awal',
        role: 'donatur',
        carePoints: 0,
      );

      final updated = user.copyWith(
        fullName: 'Nama Baru',
        carePoints: 25,
      );

      expect(updated.id, 'u-1');
      expect(updated.fullName, 'Nama Baru');
      expect(updated.carePoints, 25);
      expect(updated.email, 'test@mail.com');
    });
  });

  group('CommunityModel', () {
    test('berhasil parsing dari Map JSON ke CommunityModel', () {
      final json = {
        'id': 'comm-uuid-1',
        'profile_id': 'user-uuid-123',
        'community_name': 'Panti Asuhan Kasih',
        'description': 'Lembaga asuhan anak yatim dan dhuafa',
        'verification_status': 'verified',
        'legal_document_url': 'https://supabase.co/legal-docs/doc.pdf',
        'created_at': '2026-10-13T10:00:00.000Z',
      };

      final community = CommunityModel.fromJson(json);

      expect(community.id, 'comm-uuid-1');
      expect(community.profileId, 'user-uuid-123');
      expect(community.communityName, 'Panti Asuhan Kasih');
      expect(community.isVerified, isTrue);
      expect(community.isPending, isFalse);
      expect(community.verificationStatusDisplay, 'Terverifikasi');
    });

    test('status verifikasi pending ditampilkan dengan benar', () {
      const community = CommunityModel(
        id: 'c-2',
        profileId: 'p-2',
        communityName: 'Komunitas Baru',
        verificationStatus: 'pending',
      );

      expect(community.isPending, isTrue);
      expect(community.isVerified, isFalse);
      expect(community.verificationStatusDisplay, 'Menunggu Verifikasi');
    });

    test('status verifikasi rejected ditampilkan dengan benar', () {
      const community = CommunityModel(
        id: 'c-3',
        profileId: 'p-3',
        communityName: 'Komunitas Ditolak',
        verificationStatus: 'rejected',
        rejectionReason: 'Dokumen legalitas tidak valid',
      );

      expect(community.isRejected, isTrue);
      expect(community.verificationStatusDisplay, 'Ditolak');
      expect(community.rejectionReason, 'Dokumen legalitas tidak valid');
    });
  });
}
