# Panduan Eksekusi Supabase Database Schema & Storage

File [`schema.sql`](schema.sql) berisi skema database lengkap untuk aplikasi **CareCycle**, meliputi:
1. **Tipe Enum**: `user_role`, `verification_status`, `item_status`, `request_status`, `delivery_method`, `campaign_status`.
2. **Tabel-Tabel**: `profiles`, `communities`, `items`, `requests`, `campaigns`, `campaign_pledges`.
3. **Trigger**:
   - `on_auth_user_created`: Otomatis membuat baris di tabel `profiles` (dan record di tabel `communities` jika role adalah `'komunitas'`) saat pengguna baru mendaftar di Supabase Auth (`auth.users`).
   - `set_*_updated_at`: Pembaruan timestamp `updated_at` otomatis di setiap tabel.
4. **Row Level Security (RLS)**:
   - Katalog item berstatus `'available'` dapat diakses publik (`anon` dan `authenticated`).
   - Donatur hanya dapat mengubah atau menghapus item miliknya sendiri.
   - Hanya komunitas berstatus `'verified'` yang diizinkan melakukan `INSERT` pada tabel `requests` dan `campaigns`.
   - Donatur dan komunitas terkait dapat membaca & memperbarui alur proses serah terima.
5. **Storage Buckets**:
   - `item-photos` (Public): Penyimpanan foto barang donasi.
   - `legal-docs` (Private): Penyimpanan dokumen legalitas verifikasi komunitas yang hanya dapat diakses oleh pemilik dan Admin.

---

## Langkah Menjalankan SQL di Supabase

### Metode 1: Lewat Supabase Dashboard (Paling Mudah)
1. Buka [Supabase Dashboard](https://supabase.com/dashboard) dan login ke akun Anda.
2. Masuk ke proyek CareCycle Anda.
3. Di panel navigasi sisi kiri, pilih menu **SQL Editor** (ikon terminal `>_`).
4. Klik **"+ New query"** (atau buat query kosong baru).
5. Buka file [`supabase/schema.sql`](schema.sql), salin (copy) seluruh kodenya, dan tempel (paste) ke editor SQL di Dashboard.
6. Klik tombol **Run** di pojok kanan bawah editor SQL.
7. Pastikan muncul notifikasi **"Success. No rows returned"** tanpa ada pesan kesalahan.

---

### Metode 2: Lewat Supabase CLI (Jika Menggunakan Local Development)
Jika Anda menggunakan Supabase CLI di mesin lokal:
1. Pastikan Supabase CLI sudah terpasang dan service lokal berjalan:
   ```bash
   supabase start
   ```
2. Jalankan perintah migrasi atau reset skema:
   ```bash
   supabase db reset
   ```
   *atau eksekusi file langsung:*
   ```bash
   supabase db execute -f supabase/schema.sql
   ```

---

## Verifikasi Setelah Eksekusi

Setelah menjalankan script SQL di atas:
1. **Cek Tabel**: Buka menu **Table Editor** di Supabase Dashboard, pastikan 6 tabel berikut muncul:
   - `profiles`
   - `communities`
   - `items`
   - `requests`
   - `campaigns`
   - `campaign_pledges`
2. **Cek RLS**: Pastikan label **RLS Enabled** aktif berwarna hijau di setiap tabel.
3. **Cek Storage**: Buka menu **Storage**, pastikan bucket berikut telah dibuat:
   - `item-photos` (Public Bucket)
   - `legal-docs` (Private Bucket)
4. **Hubungkan ke Aplikasi**:
   - Buka menu **Project Settings** > **API**.
   - Salin **Project URL** dan **anon public key**.
   - Masukkan ke dalam file `.env` di root proyek Flutter:
     ```env
     SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
     SUPABASE_ANON_KEY=eyJh...
     ```
