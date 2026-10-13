# CareCycle

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
