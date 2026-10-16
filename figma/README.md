# CareCycle — Mobile UI/UX Design System & Master Figma Canvas

Berkas desain UI/UX aplikasi **CareCycle** (Tugas Besar Pemrograman Mobile Semester 3) yang telah disusun secara rapi, profesional, dan realistis dengan standar presentasi portofolio mahasiswa Teknik Informatika.

Seluruh berkas dibuat dalam format **W3C SVG Vector murni (100% valid XML)** yang dapat langsung di-import atau disalin (**Ctrl + V**) ke dalam kanvas **Figma**.

---

## 👨‍💻 Informasi Proyek & Pengembang

- **Aplikasi**: CareCycle (Siklus Berbagi & Donasi Komunitas)
- **Mata Kuliah**: Pemrograman Mobile (Semester 3)
- **Pengembang**: Reivan Rasyid Mulyadi (Teknik Informatika)
- **Tech Stack**: Flutter 3.24.2 • Supabase • Google ML Kit On-Device • Hive NoSQL • Riverpod

---

## 🚀 Cara Membuka di Figma (Paling Cepat & Anti-Gagal)

### Metode 1: Lewat Web Helper & Clipboard (Super Praktis - Rekomendasi)
1. Buka file **`figma/index.html`** di browser komputer Anda (klik ganda filenya).
2. Anda akan melihat seluruh alur layar berjejer rapi dalam User Flow tematik.
3. Di banner atas, Anda dapat mengakses:
   - **📱 Buka Prototipe Interaktif (19 Layar)**: `figma/carecycle-prototype.html` untuk mencoba aplikasi secara interaktif dengan simulator frame ponsel smartphone, transisi, role switcher (Donatur, Komunitas, Admin), dan data realistis.
   - **📑 Matriks Koneksi Desain ↔ Kode Flutter**: `figma/figma-design-blueprint.md` yang menghubungkan setiap elemen UI/UX dengan file Dart implementasinya.
4. Klik tombol **"📋 Salin Master Canvas"** (atau salin layar satuan yang Anda pilih).
5. Buka [Figma](https://www.figma.com/) dan tekan **`Ctrl + V`** (Paste).
6. Layar ponsel modern lengkap dengan Dynamic Island, bezel, dan seluruh layer vektor akan langsung terpasang di kanvas Figma Anda!

### Metode 2: Drag & Drop Langsung
1. Buka Figma dan buat file kerja baru (*New design file*).
2. Buka File Explorer ke folder: `d:\KULIAH BUD\Ssemester 3\Pemrograman Mobile\carecycle\figma\`
3. Tarik (**Drag & Drop**) file:
   👉 **`carecycle_all_screens_figma_canvas.svg`**
   langsung ke kanvas Figma.

---

## 📱 Struktur User Flow & Daftar Layar

Kanvas utama (`carecycle_all_screens_figma_canvas.svg`) berukuran **2800 x 3600 px** dan dibagi menjadi beberapa bagian tematik yang mencerminkan alur kerja sistem:

### 1. Cover & Design System Tokens (Header Board)
- Header cover Tugas Besar Pemrograman Mobile.
- Metadata pengembang & Tech Stack.
- Mini Style Guide: Color Palette tokens (Emerald `#047857`, Secondary Mint `#10B981`, Amber Pending `#F59E0B`, Danger Red `#EF4444`, Slate Dark `#0F172A`), Typography scale, dan Grid layout.

### 2. User Flow 1: Onboarding, Multi-Role Auth & Legalitas Komunitas
- **`01_splash_screen.svg`**: Splash screen dengan logo eco-cycle, tagline, & bootstrap loader.
- **`02_login_screen.svg`**: Login interaktif dengan Role Switcher (Donatur, Komunitas, Admin) & shortcut kredensial demo praktikum.
- **`03_register_screen.svg`**: Form registrasi profil yayasan/komunitas + upload berkas PDF legalitas (akta notaris) dengan status awal *Pending*.
- **`10_admin_verification.svg`**: Panel verifikasi admin untuk meninjau keabsahan berkas PDF akta notaris dan memberikan status *Verified*.

### 3. User Flow 2: Donatur — On-Device AI Image Labeling & Offline-First Sync
- **`04_home_donatur.svg`**: Dashboard donatur lengkap dengan gamifikasi CarePoints, jejak emisi tekstil, menu aksi cepat, dan lonceng notifikasi realtime.
- **`05_item_upload_ai.svg`**: Form unggah barang donasi dengan ilustrasi pakaian, deteksi kategori otomatis oleh **Google ML Kit** on-device (<150ms), dan banner offline mode.
- **`06_my_items.svg`**: Halaman manajemen "Barang Saya" dengan pemilahan status (Draft offline menunggu koneksi, Tersedia, dan Sedang Diproses).

### 4. User Flow 3: Komunitas — Katalog Publik & Siklus Serah Terima Realtime
- **`07_public_catalog.svg`**: Katalog donasi publik 2 kolom responsif dengan filter chips kategori, pencarian, dan indikator cache Hive.
- **`08_item_detail.svg`**: Halaman detail barang lengkap dengan bottom sheet modal "Ajukan Permintaan Donasi" bagi komunitas terverifikasi.
- **`09_donor_requests_handover.svg`**: Layar review permintaan masuk bagi donatur, verifikasi profil pemohon, dan modal pemilihan kesepakatan serah terima (Kurir / Antar Langsung / Dijemput Komunitas).

---

## 🎨 Token Warna (Design Tokens)
- **Primary Emerald**: `#047857`
- **Secondary Mint**: `#10B981`
- **Dark Forest**: `#065F46`
- **Background Light**: `#F8FAFC` / `#F1F5F9`
- **Text Slate**: `#0F172A`
- **Warning / Pending Amber**: `#F59E0B`
- **Success Green**: `#10B981`
- **Danger Red**: `#EF4444`
