# KindShare

Platform berbagi & donasi barang layak pakai berbasis komunitas.

## Tech Stack
- **Framework**: Flutter + Dart
- **State Management**: Riverpod (`flutter_riverpod`)
- **Navigasi**: `go_router`
- **Backend**: Supabase (Auth, PostgreSQL, Storage, Realtime)
- **Local Storage**: Hive (`hive_flutter`)
- **AI**: `google_mlkit_image_labeling` (On-device untuk saran kategori)
- **Sertifikat**: `pdf`, `printing`, `share_plus`

## Fitur Utama & Alur
1. **Donatur (Individu)**: Upload barang (+ saran kategori AI ML Kit) -> masuk katalog publik -> review & setujui permintaan komunitas -> kumpulkan Care Points & tingkatkan level (Starter, Hero, Savior).
2. **Komunitas (Terverifikasi)**: Ajukan permintaan barang yang dibutuhkan atau buat Open Campaign.
3. **Admin**: Verifikasi legalitas organisasi/komunitas.

## Setup & Menjalankan Aplikasi
1. Salin file environment:
   ```bash
   cp .env.example .env
   ```
2. Isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di file `.env`.
3. Jalankan Supabase database schema yang tersedia di [`supabase/schema.sql`](supabase/schema.sql).
4. Unduh dependensi:
   ```bash
   flutter pub get
   ```
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Cara Instal APK

### Build APK Release
```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```
File APK hasil build ada di:
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk   (16.3 MB) — HP lama (32-bit ARM)
├── app-arm64-v8a-release.apk     (17.4 MB) — HP modern (POCO F6, Samsung, dll)
└── app-x86_64-release.apk        (17.8 MB) — Emulator/Chromebook
```

### Instal di HP Android
1. **Kirim APK ke HP** — gunakan salah satu cara:
   - Kirim via **Google Drive / Telegram / WhatsApp** (kirim sebagai file/dokumen)
   - Sambungkan HP via kabel USB, lalu copy file APK ke folder `Download`
2. **Izinkan install dari sumber tidak dikenal:**
   - Buka **Pengaturan > Keamanan > Instal aplikasi yang tidak dikenal** (atau **Settings > Apps > Special access > Install unknown apps**)
   - Pilih aplikasi yang digunakan untuk membuka APK (misal: File Manager, Chrome, Telegram) lalu aktifkan izin
3. **Buka file APK** dari File Manager atau notifikasi download, lalu tap **Instal**
4. Setelah terpasang, buka aplikasi **KindShare** dari app drawer

### Pilih APK yang Tepat
- **POCO F6** dan kebanyakan HP modern → gunakan **`app-arm64-v8a-release.apk`**
- Jika tidak yakin arsitektur HP, bisa build tanpa `--split-per-abi` untuk menghasilkan satu APK universal (ukuran lebih besar)

### Catatan Penting
- **ML Kit (AI saran kategori)** hanya berfungsi di perangkat **Android/iOS** — tidak tersedia di web
- Aplikasi membutuhkan **koneksi internet** untuk terhubung ke backend Supabase
- Pastikan izin **Kamera** dan **Penyimpanan/Foto** diizinkan saat diminta agar fitur upload barang berfungsi

---

## 🎨 UI/UX Design System & Koneksi Figma ↔ Kode Flutter

Seluruh rancangan antarmuka aplikasi CareCycle telah dipetakan secara **1-to-1** dengan kode sumber Flutter.

### 📁 Berkas Desain & Prototipe (Folder `figma/`)
- **📱 Prototipe Interaktif Web (19 Layar)**: [`figma/carecycle-prototype.html`](figma/carecycle-prototype.html)
  - Prototipe mandiri berformat HTML/Tailwind dengan simulator frame ponsel modern (iPhone 390x844), Dynamic Island, status bar, tombol demo switch role (Donatur, Komunitas, Admin), dan data interaktif realistis.
  - Cukup buka file ini di browser (Chrome / Edge / Firefox) tanpa perlu setup apa pun.
- **📑 Matriks Koneksi Desain ↔ Kode Flutter**: [`figma/figma-design-blueprint.md`](figma/figma-design-blueprint.md)
  - Menghubungkan setiap token warna, tipografi, ukuran, dan seluruh 17 layar aplikasi langsung ke file sumber Dart di `lib/`.
- **🌐 Portal Presentasi & Figma Clipboard**: [`figma/index.html`](figma/index.html)
  - Halaman showcase SVG per flow yang memungkinkan Anda menyalin kode vektor XML langsung ke clipboard untuk ditempel (**Ctrl + V**) di kanvas [Figma](https://figma.com).
- **📦 Master Canvas Vector**: [`figma/carecycle_all_screens_figma_canvas.svg`](figma/carecycle_all_screens_figma_canvas.svg)

### 🔗 Matriks Singkat Layar Desain vs File Flutter

| No | Nama Layar | Role | File Kode Sumber Flutter | Rute `go_router` |
|---|---|---|---|---|
| 1 | Splash Screen | Semua | [`splash_screen.dart`](lib/features/auth/presentation/screens/splash_screen.dart) | `/` |
| 2 | Login Screen | Tamu | [`login_screen.dart`](lib/features/auth/presentation/screens/login_screen.dart) | `/login` |
| 3 | Register Screen | Tamu | [`register_screen.dart`](lib/features/auth/presentation/screens/register_screen.dart) | `/register` |
| 4 | Beranda (Home) | Donatur/Komunitas/Admin | [`home_screen.dart`](lib/features/auth/presentation/screens/home_screen.dart) | `/home` |
| 5 | Unggah Barang + AI ML Kit | Donatur | [`item_upload_screen.dart`](lib/features/items/presentation/screens/item_upload_screen.dart) | `/upload` |
| 6 | Barang Saya & Draft Offline | Donatur | [`my_items_screen.dart`](lib/features/items/presentation/screens/my_items_screen.dart) | `/my-items` |
| 7 | Katalog Donasi Publik | Semua | [`catalog_screen.dart`](lib/features/items/presentation/screens/catalog_screen.dart) | `/catalog` |
| 8 | Rincian Barang & Pengajuan | Semua | [`item_detail_screen.dart`](lib/features/items/presentation/screens/item_detail_screen.dart) | `/items/:id` |
| 9 | Acc Permintaan Donasi | Admin | [`donor_requests_screen.dart`](lib/features/requests/presentation/screens/donor_requests_screen.dart) | `/requests/donor` |
| 10 | Permintaan Donasi Saya | Komunitas | [`community_requests_screen.dart`](lib/features/requests/presentation/screens/community_requests_screen.dart) | `/community/requests` |
| 11 | Unggah Berkas Legalitas | Komunitas | [`community_verification_screen.dart`](lib/features/auth/presentation/screens/community_verification_screen.dart) | `/community/verification` |
| 12 | Verifikasi Komunitas | Admin | [`admin_verification_screen.dart`](lib/features/admin/presentation/screens/admin_verification_screen.dart) | `/admin/verification` |
| 13 | Kelola Pengguna | Admin | [`admin_users_screen.dart`](lib/features/admin/presentation/screens/admin_users_screen.dart) | `/admin/users` |
| 14 | Statistik & Eco-Impact | Admin | [`admin_analytics_screen.dart`](lib/features/admin/presentation/screens/admin_analytics_screen.dart) | `/admin/analytics` |
| 15 | Moderasi Barang Donasi | Admin | [`admin_items_screen.dart`](lib/features/admin/presentation/screens/admin_items_screen.dart) | `/admin/items` |
| 16 | Open Campaign | Semua | [`campaign_screen.dart`](lib/features/campaigns/presentation/screens/campaign_screen.dart) | `/campaign` |
| 17 | Profil & Mode Gelap | Semua | [`profile_screen.dart`](lib/features/auth/presentation/screens/profile_screen.dart) | `/profile` |
