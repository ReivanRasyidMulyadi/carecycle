import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carecycle/core/services/hive_service.dart';

void main() {
  group('HiveService', () {
    setUpAll(() async {
      // Inisialisasi Hive untuk testing
      Hive.init('./test/hive_test');
      await Hive.openBox(HiveService.sessionBox);
      await Hive.openBox(HiveService.settingsBox);
      await Hive.openBox(HiveService.draftsBox);
      await Hive.openBox(HiveService.cacheBox);
    });

    tearDownAll(() async {
      await Hive.close();
    });

    group('Settings', () {
      test('default dark mode adalah false', () {
        expect(HiveService.isDarkMode(), isFalse);
      });

      test('bisa set dan get dark mode', () async {
        await HiveService.setDarkMode(true);
        expect(HiveService.isDarkMode(), isTrue);

        await HiveService.setDarkMode(false);
        expect(HiveService.isDarkMode(), isFalse);
      });

      test('default onboarding adalah false', () {
        expect(HiveService.hasSeenOnboarding(), isFalse);
      });

      test('bisa set onboarding status', () async {
        await HiveService.setHasSeenOnboarding(true);
        expect(HiveService.hasSeenOnboarding(), isTrue);
      });
    });

    group('Session', () {
      setUp(() async {
        await Hive.box(HiveService.sessionBox).clear();
      });

      test('default isLoggedIn adalah false', () {
        expect(HiveService.isLoggedIn(), isFalse);
      });

      test('bisa simpan dan baca sesi', () async {
        await HiveService.saveSession(
          userId: 'test-user-123',
          role: 'donatur',
          email: 'test@example.com',
          name: 'Test User',
        );

        expect(HiveService.isLoggedIn(), isTrue);
        expect(HiveService.getUserId(), 'test-user-123');
        expect(HiveService.getUserRole(), 'donatur');
        expect(HiveService.getUserName(), 'Test User');
      });

      test('bisa clear sesi (logout)', () async {
        await HiveService.saveSession(
          userId: 'test-user-123',
          role: 'donatur',
          email: 'test@example.com',
          name: 'Test User',
        );

        await HiveService.clearSession();
        expect(HiveService.isLoggedIn(), isFalse);
        expect(HiveService.getUserId(), isNull);
      });
    });

    group('Drafts', () {
      setUp(() async {
        final box = Hive.box(HiveService.draftsBox);
        await box.clear();
      });

      test('bisa simpan dan ambil draft', () async {
        final draftData = {
          'id': 'draft-1',
          'name': 'Tas Sekolah',
          'description': 'Tas sekolah bekas, kondisi baik',
          'category': 'Perlengkapan Sekolah',
        };

        await HiveService.saveDraft('draft-1', draftData);
        final drafts = HiveService.getAllDrafts();

        expect(drafts, isNotEmpty);
        expect(drafts.first['name'], 'Tas Sekolah');
      });

      test('bisa hapus draft', () async {
        await HiveService.saveDraft('draft-2', {'name': 'Buku'});
        await HiveService.deleteDraft('draft-2');

        final drafts = HiveService.getAllDrafts();
        final hasDraft2 = drafts.any((d) => d['name'] == 'Buku');
        expect(hasDraft2, isFalse);
      });
    });

    group('Cache', () {
      setUp(() async {
        await Hive.box(HiveService.cacheBox).clear();
      });

      test('bisa simpan dan ambil cache', () async {
        await HiveService.setCache('test_key', 'test_value');
        expect(HiveService.getCache('test_key'), 'test_value');
      });

      test('bisa clear semua cache', () async {
        await HiveService.setCache('key1', 'val1');
        await HiveService.setCache('key2', 'val2');
        await HiveService.clearCache();

        expect(HiveService.getCache('key1'), isNull);
        expect(HiveService.getCache('key2'), isNull);
      });
    });
  });
}
