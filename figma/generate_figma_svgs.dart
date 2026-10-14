// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final outDir = Directory('figma');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final screens = <String, String>{
    '01_splash_screen.svg': screenSplash(),
    '02_login_screen.svg': screenLogin(),
    '03_register_screen.svg': screenRegister(),
    '04_home_donatur.svg': screenHomeDonatur(),
    '05_item_upload_ai.svg': screenItemUploadAi(),
    '06_my_items.svg': screenMyItems(),
    '07_public_catalog.svg': screenPublicCatalog(),
    '08_item_detail.svg': screenItemDetail(),
    '09_donor_requests_handover.svg': screenDonorRequestsHandover(),
    '10_admin_verification.svg': screenAdminVerification(),
  };

  // Write individual screen SVGs with realistic mobile phone frame
  for (final entry in screens.entries) {
    final file = File('figma/${entry.key}');
    file.writeAsStringSync(wrapSingleScreenSvg(entry.value));
    print('Generated figma/${entry.key}');
  }

  // Generate Master Canvas with Project Presentation Header, Style Tokens & Thematic User Flows
  final masterCanvas = generateMasterBoard(screens);
  File('figma/carecycle_all_screens_figma_canvas.svg').writeAsStringSync(masterCanvas);
  print('Generated figma/carecycle_all_screens_figma_canvas.svg');
}

// ==========================================
// SVG WRAPPERS & PHONE FRAME
// ==========================================

String wrapSingleScreenSvg(String innerScreen) {
  return '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 880" width="420" height="880">
  <defs>
    <filter id="phoneShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="16" stdDeviation="20" flood-color="#0F172A" flood-opacity="0.12"/>
    </filter>
  </defs>
  <!-- Background Artboard Canvas -->
  <rect width="420" height="880" fill="#F8FAFC" />
  
  <!-- Realistic Smartphone Outer Shell -->
  <g transform="translate(15, 18)" filter="url(#phoneShadow)">
    <!-- Outer Bezel -->
    <rect width="390" height="844" rx="44" fill="#0F172A" stroke="#334155" stroke-width="3" />
    <!-- Screen Viewport with Clip -->
    <rect x="0" y="0" width="390" height="844" rx="42" fill="#FFFFFF" />
    <g>
      $innerScreen
    </g>
    <!-- Screen Glass Rim Border -->
    <rect x="0" y="0" width="390" height="844" rx="42" fill="none" stroke="#0F172A" stroke-width="4" />
    <!-- iPhone-style Dynamic Island / Notch -->
    <rect x="140" y="11" width="110" height="26" rx="13" fill="#000000" />
    <circle cx="230" cy="24" r="5" fill="#1E293B" />
    <circle cx="160" cy="24" r="3.5" fill="#0F172A" />
    <!-- Bottom Home Indicator Bar -->
    <rect x="125" y="830" width="140" height="4.5" rx="2.5" fill="#0F172A" opacity="0.6" />
  </g>
</svg>''';
}

String phoneShellContent(String innerScreen) {
  return '''
  <!-- Phone Frame Container -->
  <g id="DeviceShell">
    <!-- Outer Bezel -->
    <rect width="390" height="844" rx="42" fill="#0F172A" stroke="#334155" stroke-width="2.5" />
    <!-- Screen Area -->
    <rect width="390" height="844" rx="40" fill="#FFFFFF" />
    <!-- Inner Screen Content -->
    <g>
      $innerScreen
    </g>
    <!-- Glass Rim -->
    <rect width="390" height="844" rx="40" fill="none" stroke="#0F172A" stroke-width="3.5" />
    <!-- Dynamic Island Notch -->
    <rect x="140" y="11" width="110" height="26" rx="13" fill="#000000" />
    <circle cx="230" cy="24" r="5" fill="#1E293B" />
    <!-- Bottom Home Indicator -->
    <rect x="125" y="830" width="140" height="4.5" rx="2.5" fill="#0F172A" opacity="0.6" />
  </g>''';
}

// ==========================================
// REUSABLE MOBILE UI COMPONENTS
// ==========================================

String statusBar({bool isDark = false}) {
  final color = isDark ? '#FFFFFF' : '#0F172A';
  return '''
  <!-- iOS Status Bar -->
  <g id="StatusBar" transform="translate(0, 0)">
    <text x="36" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="$color">09:41</text>
    <!-- Signal, Wifi, Battery -->
    <circle cx="330" cy="25" r="3" fill="$color" />
    <circle cx="340" cy="25" r="3" fill="$color" />
    <!-- Battery -->
    <rect x="350" y="20" width="20" height="10" rx="3" fill="none" stroke="$color" stroke-width="1.5" />
    <rect x="352" y="22" width="13" height="6" rx="1.5" fill="$color" />
  </g>''';
}

String bottomNav({int activeIndex = 0}) {
  return '''
  <!-- Bottom Navigation Bar -->
  <g id="BottomNavBar" transform="translate(0, 755)">
    <rect width="390" height="89" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    
    <!-- Tab 1: Beranda -->
    <g transform="translate(48, 14)">
      <circle cx="0" cy="12" r="16" fill="${activeIndex == 0 ? '#ECFDF5' : 'none'}" />
      <path d="M-8 14 L0 7 L8 14 L8 24 L3 24 L3 17 L-3 17 L-3 24 L-8 24 Z" fill="${activeIndex == 0 ? '#047857' : '#94A3B8'}" />
      <text x="0" y="36" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="${activeIndex == 0 ? '700' : '600'}" fill="${activeIndex == 0 ? '#047857' : '#94A3B8'}" text-anchor="middle">Beranda</text>
    </g>

    <!-- Tab 2: Katalog -->
    <g transform="translate(148, 14)">
      <circle cx="0" cy="12" r="16" fill="${activeIndex == 1 ? '#ECFDF5' : 'none'}" />
      <rect x="-8" y="6" width="16" height="16" rx="3" fill="none" stroke="${activeIndex == 1 ? '#047857' : '#94A3B8'}" stroke-width="2" />
      <text x="0" y="36" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="${activeIndex == 1 ? '700' : '600'}" fill="${activeIndex == 1 ? '#047857' : '#94A3B8'}" text-anchor="middle">Katalog</text>
    </g>

    <!-- Tab 3: Aktivitas -->
    <g transform="translate(248, 14)">
      <circle cx="0" cy="12" r="16" fill="${activeIndex == 2 ? '#ECFDF5' : 'none'}" />
      <rect x="-7" y="7" width="14" height="14" rx="2" fill="none" stroke="${activeIndex == 2 ? '#047857' : '#94A3B8'}" stroke-width="2" />
      <line x1="-3" y1="12" x2="3" y2="12" stroke="${activeIndex == 2 ? '#047857' : '#94A3B8'}" stroke-width="1.8" stroke-linecap="round"/>
      <text x="0" y="36" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="${activeIndex == 2 ? '700' : '600'}" fill="${activeIndex == 2 ? '#047857' : '#94A3B8'}" text-anchor="middle">Aktivitas</text>
    </g>

    <!-- Tab 4: Profil -->
    <g transform="translate(342, 14)">
      <circle cx="0" cy="12" r="16" fill="${activeIndex == 3 ? '#ECFDF5' : 'none'}" />
      <circle cx="0" cy="9" r="4.5" fill="none" stroke="${activeIndex == 3 ? '#047857' : '#94A3B8'}" stroke-width="1.8" />
      <path d="M-7 23 C-7 18.5 -3.5 17 0 17 C3.5 17 7 18.5 7 23" fill="none" stroke="${activeIndex == 3 ? '#047857' : '#94A3B8'}" stroke-width="1.8" stroke-linecap="round"/>
      <text x="0" y="36" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="${activeIndex == 3 ? '700' : '600'}" fill="${activeIndex == 3 ? '#047857' : '#94A3B8'}" text-anchor="middle">Profil</text>
    </g>
  </g>''';
}

String mobileAppBar(String title, {bool showBack = true, String? actionIcon}) {
  return '''
  <!-- Mobile App Bar -->
  <g id="AppBar" transform="translate(0, 48)">
    ${showBack ? '''
    <g id="BtnBack">
      <circle cx="38" cy="24" r="18" fill="#F1F5F9" />
      <path d="M41 18 L34 24 L41 30" stroke="#0F172A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    </g>''' : ''}
    <text x="${showBack ? 70 : 24}" y="31" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="19" font-weight="800" fill="#0F172A">$title</text>
    ${actionIcon == 'bell' ? '''
    <g id="ActionBell">
      <circle cx="352" cy="24" r="18" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1" />
      <path d="M352 16 C348 16 346 19 346 23 L344 26 L360 26 L358 23 C358 19 356 16 352 16 Z" fill="#0F172A" />
      <circle cx="360" cy="16" r="4.5" fill="#EF4444" stroke="#FFFFFF" stroke-width="1.5" />
    </g>''' : ''}
  </g>''';
}

// ==========================================
// SCREEN 1: SPLASH SCREEN
// ==========================================
String screenSplash() {
  return '''
  <rect width="390" height="844" fill="#047857" />
  
  <!-- Subtle background pattern / curves -->
  <circle cx="380" cy="120" r="160" fill="#065F46" opacity="0.4" />
  <circle cx="20" cy="740" r="200" fill="#065F46" opacity="0.4" />

  ${statusBar(isDark: true)}

  <!-- Brand Center Logo -->
  <g id="BrandCenter" transform="translate(195, 340)">
    <!-- Outer Glow -->
    <circle cx="0" cy="0" r="54" fill="#065F46" />
    <circle cx="0" cy="0" r="44" fill="#10B981" opacity="0.2" />
    
    <!-- Vector Recycle Leaf Icon -->
    <path d="M-18 8 C-18 -10 0 -22 18 -16 C26 -12 30 0 24 12 C18 24 2 30 -14 22 L-22 30 L-18 8 Z" fill="#FFFFFF" />
    <path d="M-4 -2 C2 -8 12 -8 16 -2 C18 4 14 12 8 14 C0 16 -8 10 -4 -2 Z" fill="#047857" />
    
    <text x="0" y="90" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="34" font-weight="800" fill="#FFFFFF" text-anchor="middle" letter-spacing="-0.5">CareCycle</text>
    <text x="0" y="118" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13.5" font-weight="500" fill="#A7F3D0" text-anchor="middle">Siklus Berbagi &amp; Donasi Komunitas</text>
    
    <!-- University / Project Metadata pill -->
    <rect x="-85" y="145" width="170" height="26" rx="13" fill="#065F46" />
    <text x="0" y="162" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="700" fill="#ECFDF5" text-anchor="middle">PEMROGRAMAN MOBILE • SMT 3</text>
  </g>

  <!-- Bottom Loading & Version -->
  <g transform="translate(195, 760)">
    <circle cx="0" cy="0" r="13" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-dasharray="24 10" opacity="0.8" />
    <text x="0" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="500" fill="#A7F3D0" text-anchor="middle">Memuat sistem offline &amp; cloud...</text>
  </g>''';
}

// ==========================================
// SCREEN 2: LOGIN SCREEN
// ==========================================
String screenLogin() {
  return '''
  <rect width="390" height="844" fill="#F8FAFC" />
  ${statusBar()}

  <!-- Header Section -->
  <g id="LoginHeader" transform="translate(24, 85)">
    <rect width="44" height="44" rx="12" fill="#ECFDF5" />
    <path d="M14 22 C14 16 18 12 24 12 C30 12 34 16 34 22 C34 28 28 32 22 32 Z" fill="#047857" />
    
    <text x="0" y="78" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="24" font-weight="800" fill="#0F172A">Masuk ke Akun</text>
    <text x="0" y="102" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="#64748B">Pilih role dan masuk untuk mulai mendonasikan barang</text>
  </g>

  <!-- Role Selector Switcher -->
  <g id="RoleSwitch" transform="translate(24, 215)">
    <rect width="342" height="46" rx="12" fill="#E2E8F0" />
    <!-- Active Donatur tab -->
    <rect x="4" y="4" width="108" height="38" rx="9" fill="#047857" />
    <text x="58" y="27" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#FFFFFF" text-anchor="middle">Donatur</text>
    
    <text x="171" y="27" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="600" fill="#64748B" text-anchor="middle">Komunitas</text>
    <text x="285" y="27" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="600" fill="#64748B" text-anchor="middle">Admin</text>
  </g>

  <!-- Form Fields -->
  <g id="FormFields" transform="translate(24, 285)">
    <text x="0" y="0" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" font-weight="700" fill="#0F172A">Alamat Email</text>
    <rect x="0" y="10" width="342" height="48" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.2" />
    <text x="16" y="39" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="#0F172A">reivan.rasyid@student.ac.id</text>

    <text x="0" y="85" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" font-weight="700" fill="#0F172A">Kata Sandi</text>
    <rect x="0" y="95" width="342" height="48" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.2" />
    <text x="16" y="125" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" fill="#0F172A">••••••••••••••</text>
    <text x="296" y="124" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#047857">LIHAT</text>

    <!-- Quick Remember & Forgot Password -->
    <g transform="translate(0, 160)">
      <rect x="0" y="0" width="16" height="16" rx="4" fill="#047857" />
      <path d="M4 8 L7 11 L12 5" fill="none" stroke="#FFFFFF" stroke-width="1.8" stroke-linecap="round" />
      <text x="24" y="13" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#64748B">Ingat saya</text>
      <text x="342" y="13" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="600" fill="#047857" text-anchor="end">Lupa sandi?</text>
    </g>

    <!-- Submit Button -->
    <rect x="0" y="195" width="342" height="50" rx="12" fill="#047857" />
    <text x="171" y="226" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14.5" font-weight="700" fill="#FFFFFF" text-anchor="middle">Masuk Sekarang</text>

    <!-- Quick Test Credentials Box -->
    <g transform="translate(0, 270)">
      <rect width="342" height="65" rx="10" fill="#EFF6FF" stroke="#BFDBFE" stroke-width="1" />
      <text x="14" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#1D4ED8">⚡ Demo Praktikum IT:</text>
      <text x="14" y="38" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#1E40AF">Tersedia login cepat Donatur, Komunitas, &amp; Admin</text>
      <text x="14" y="52" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#3B82F6">Supabase Auth • Realtime Session Sync</text>
    </g>

    <text x="171" y="365" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#64748B" text-anchor="middle">Belum punya akun? <tspan fill="#047857" font-weight="700">Daftar Komunitas</tspan></text>
  </g>''';
}

// ==========================================
// SCREEN 3: REGISTER SCREEN (KOMUNITAS + DOKUMEN)
// ==========================================
String screenRegister() {
  return '''
  <rect width="390" height="844" fill="#F8FAFC" />
  ${statusBar()}
  ${mobileAppBar('Registrasi Komunitas')}

  <g id="RegisterBody" transform="translate(24, 105)">
    <!-- Step Badge -->
    <rect width="180" height="24" rx="12" fill="#ECFDF5" />
    <text x="12" y="16" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" font-weight="700" fill="#047857">LANGKAH 2: DOKUMEN LEGALITAS</text>

    <!-- Form Inputs -->
    <text x="0" y="50" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Nama Komunitas / Yayasan</text>
    <rect x="0" y="58" width="342" height="44" rx="8" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.2" />
    <text x="14" y="85" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" fill="#0F172A">Yayasan Kasih Harapan Bangsa</text>

    <text x="0" y="122" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Nomor Izin Kemenkumham / Akta</text>
    <rect x="0" y="130" width="342" height="44" rx="8" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.2" />
    <text x="14" y="157" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" fill="#0F172A">AHU-0019284.AH.01.04.2021</text>

    <text x="0" y="194" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Alamat Sekretariat</text>
    <rect x="0" y="202" width="342" height="44" rx="8" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.2" />
    <text x="14" y="229" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" fill="#0F172A">Jl. Dipati Ukur No. 42, Coblong, Bandung</text>

    <!-- Upload Legalitas Component -->
    <text x="0" y="268" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Unggah Berkas Legalitas (PDF / Foto)</text>
    
    <g transform="translate(0, 278)">
      <rect width="342" height="96" rx="10" fill="#F0FDF4" stroke="#047857" stroke-width="1.5" stroke-dasharray="6 4" />
      <!-- PDF Document Icon -->
      <rect x="20" y="24" width="36" height="46" rx="5" fill="#DCFCE7" />
      <text x="38" y="52" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="800" fill="#047857" text-anchor="middle">PDF</text>
      
      <text x="68" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" font-weight="700" fill="#0F172A">akta_pendirian_notaris.pdf</text>
      <text x="68" y="60" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#64748B">2.1 MB • Terverifikasi siap upload</text>
      
      <rect x="250" y="32" width="76" height="30" rx="6" fill="#047857" />
      <text x="288" y="51" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle">Ganti File</text>
    </g>

    <!-- Verification Info Notice -->
    <g transform="translate(0, 390)">
      <rect width="342" height="54" rx="8" fill="#FFFBEB" stroke="#F59E0B" stroke-width="1" />
      <text x="14" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#B45309">⚠️ Status Awal: Menunggu Verifikasi Admin</text>
      <text x="14" y="38" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#92400E">Komunitas belum terverifikasi belum dapat mengajukan donasi.</text>
    </g>

    <!-- Submit Button -->
    <rect x="0" y="460" width="342" height="48" rx="12" fill="#047857" />
    <text x="171" y="490" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="700" fill="#FFFFFF" text-anchor="middle">Kirim Berkas Pendaftaran</text>
  </g>''';
}

// ==========================================
// SCREEN 4: HOME DONATUR
// ==========================================
String screenHomeDonatur() {
  return '''
  <rect width="390" height="844" fill="#F8FAFC" />
  ${statusBar()}
  ${mobileAppBar('CareCycle', showBack: false, actionIcon: 'bell')}

  <!-- User Greeting Card -->
  <g id="GreetingCard" transform="translate(24, 105)">
    <rect width="342" height="76" rx="16" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="42" cy="38" r="24" fill="#ECFDF5" />
    <text x="42" y="45" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="17" font-weight="800" fill="#047857" text-anchor="middle">RR</text>
    
    <text x="76" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14.5" font-weight="800" fill="#0F172A">Halo, Reivan Rasyid 👋</text>
    <text x="76" y="49" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#64748B">Donatur Aktif • Coblong, Bandung</text>
    
    <rect x="250" y="24" width="76" height="24" rx="12" fill="#ECFDF5" />
    <text x="288" y="40" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="700" fill="#047857" text-anchor="middle">TERVERIFIKASI</text>
  </g>

  <!-- CarePoints Gamification Banner -->
  <g id="GamificationCard" transform="translate(24, 195)">
    <rect width="342" height="96" rx="16" fill="#047857" />
    <circle cx="310" cy="48" r="40" fill="#065F46" opacity="0.6" />
    
    <text x="20" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" font-weight="600" fill="#A7F3D0">Total CarePoints &amp; Kontribusi</text>
    <text x="20" y="66" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="28" font-weight="800" fill="#FFFFFF">340 Pts</text>
    
    <!-- Impact Stats -->
    <text x="20" y="84" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#ECFDF5">🌱 5 Barang Tersalurkan • 18 kg Emisi Tercegah</text>

    <!-- Level badge -->
    <rect x="235" y="20" width="90" height="24" rx="6" fill="#065F46" />
    <text x="280" y="36" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" font-weight="700" fill="#FFFFFF" text-anchor="middle">Level 2: Peduli</text>
  </g>

  <!-- Section Title -->
  <text x="24" y="318" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14.5" font-weight="800" fill="#0F172A">Menu Utama Donatur</text>

  <!-- 2x2 Feature Grid -->
  <g id="FeatureGrid" transform="translate(24, 332)">
    <!-- Card 1: Upload Donasi -->
    <rect x="0" y="0" width="164" height="100" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
    <circle cx="32" cy="32" r="16" fill="#ECFDF5" />
    <!-- Camera icon -->
    <circle cx="32" cy="32" r="6" fill="#047857" />
    <text x="14" y="68" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">Unggah Barang</text>
    <text x="14" y="85" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#64748B">Deteksi AI ML Kit</text>

    <!-- Card 2: Barang Saya -->
    <rect x="178" y="0" width="164" height="100" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
    <circle cx="210" cy="32" r="16" fill="#FFFBEB" />
    <rect x="204" y="26" width="12" height="12" rx="2" fill="#F59E0B" />
    <text x="192" y="68" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">Barang Saya</text>
    <text x="192" y="85" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="700" fill="#B45309">1 Draft Offline ⚡</text>

    <!-- Card 3: Katalog Publik -->
    <rect x="0" y="112" width="164" height="100" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
    <circle cx="32" cy="144" r="16" fill="#ECFDF5" />
    <path d="M28 140 L36 140 L36 148 L28 148 Z" fill="none" stroke="#047857" stroke-width="2" />
    <text x="14" y="180" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">Katalog Publik</text>
    <text x="14" y="197" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#64748B">Kebutuhan Komunitas</text>

    <!-- Card 4: Permintaan Masuk -->
    <rect x="178" y="112" width="164" height="100" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
    <circle cx="210" cy="144" r="16" fill="#EFF6FF" />
    <circle cx="210" cy="144" r="6" fill="#2563EB" />
    <circle cx="220" cy="136" r="4.5" fill="#EF4444" />
    <text x="192" y="180" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">Permintaan</text>
    <text x="192" y="197" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="700" fill="#2563EB">2 Baru Masuk</text>
  </g>

  <!-- Live Activity Ticker -->
  <g transform="translate(24, 565)">
    <rect width="342" height="52" rx="10" fill="#F1F5F9" />
    <circle cx="24" cy="26" r="8" fill="#10B981" />
    <text x="42" y="24" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#0F172A">Yayasan Kasih Bangsa</text>
    <text x="42" y="38" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#64748B">Mengajukan permohonan "Tas Ransel Eiger" • 5m lalu</text>
  </g>

  ${bottomNav(activeIndex: 0)}''';
}

// ==========================================
// SCREEN 5: UPLOAD BARANG & AI ML KIT
// ==========================================
String screenItemUploadAi() {
  return '''
  <rect width="390" height="844" fill="#F8FAFC" />
  ${statusBar()}
  ${mobileAppBar('Donasikan Barang')}

  <g id="UploadForm" transform="translate(24, 105)">
    <!-- Photo Picker & Visual Illustration -->
    <g id="PhotoPicker">
      <rect width="342" height="145" rx="14" fill="#FFFFFF" stroke="#047857" stroke-width="1.5" stroke-dasharray="6 4" />
      
      <!-- Uploaded Picture Preview Frame -->
      <rect x="15" y="15" width="115" height="115" rx="10" fill="#E2E8F0" />
      <!-- Stylized Jacket Drawing -->
      <path d="M45 40 L72 35 L100 40 L110 65 L95 70 L95 110 L50 110 L50 70 L35 65 Z" fill="#047857" />
      <line x1="72" y1="35" x2="72" y2="110" stroke="#FFFFFF" stroke-width="1.5" />
      
      <text x="145" y="45" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Foto Berhasil Dipilih</text>
      <text x="145" y="62" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">camera_capture_821.jpg</text>
      
      <rect x="145" y="78" width="120" height="28" rx="6" fill="#F1F5F9" />
      <text x="205" y="96" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" font-weight="700" fill="#047857" text-anchor="middle">Ambil Ulang Foto</text>
    </g>

    <!-- Google ML Kit Image Labeling Banner (Core Feature) -->
    <g id="MLKitBanner" transform="translate(0, 160)">
      <rect width="342" height="64" rx="10" fill="#ECFDF5" stroke="#10B981" stroke-width="1.2" />
      <circle cx="24" cy="32" r="12" fill="#10B981" />
      <!-- Chip / Brain icon -->
      <path d="M20 32 L23 35 L28 29" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" />
      
      <text x="46" y="26" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" font-weight="800" fill="#047857">Google ML Kit On-Device Labeling</text>
      <text x="46" y="42" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#065F46">Terdeteksi: "Outerwear, Jacket" (Akurasi 94%)</text>
      <text x="46" y="55" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9.5" fill="#047857">Kategori otomatis disetel ke: [ Pakaian ]</text>
    </g>

    <!-- Form Inputs -->
    <g transform="translate(0, 238)">
      <text x="0" y="0" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Kategori Barang</text>
      <rect x="0" y="8" width="342" height="42" rx="8" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.2" />
      <text x="14" y="34" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" fill="#0F172A">Pakaian (Saran AI - Dapat Diubah)</text>

      <text x="0" y="68" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Judul Barang</text>
      <rect x="0" y="76" width="342" height="42" rx="8" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.2" />
      <text x="14" y="102" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" fill="#0F172A">Jaket Parka Outdoor Eiger (Size L)</text>

      <text x="0" y="136" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Deskripsi &amp; Kondisi Barang</text>
      <rect x="0" y="144" width="342" height="60" rx="8" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.2" />
      <text x="14" y="168" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#475569">Kondisi 90% layak pakai, resleting lancar,</text>
      <text x="14" y="184" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#475569">bahan tebal anti angin. Cocok untuk cuaca dingin.</text>

      <!-- Offline Sync Notification Banner -->
      <g transform="translate(0, 218)">
        <rect width="342" height="44" rx="8" fill="#FEF3C7" stroke="#F59E0B" stroke-width="1" />
        <circle cx="20" cy="22" r="6" fill="#F59E0B" />
        <text x="36" y="20" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" font-weight="700" fill="#92400E">Mode Offline (Hive Local Storage)</text>
        <text x="36" y="34" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9.5" fill="#B45309">Akan otomatis di-upload ke Supabase saat sinyal pulih.</text>
      </g>

      <!-- Action Button -->
      <rect x="0" y="275" width="342" height="48" rx="12" fill="#047857" />
      <text x="171" y="304" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="700" fill="#FFFFFF" text-anchor="middle">Terbitkan Donasi</text>
    </g>
  </g>''';
}

// ==========================================
// SCREEN 6: BARANG SAYA
// ==========================================
String screenMyItems() {
  return '''
  <rect width="390" height="844" fill="#F8FAFC" />
  ${statusBar()}
  ${mobileAppBar('Barang Saya')}

  <!-- Status Filter Chips -->
  <g id="StatusFilter" transform="translate(24, 105)">
    <rect x="0" y="0" width="80" height="32" rx="16" fill="#047857" />
    <text x="40" y="20" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle">Semua (4)</text>

    <rect x="90" y="0" width="90" height="32" rx="16" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="135" y="20" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">Tersedia (2)</text>

    <rect x="190" y="0" width="85" height="32" rx="16" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="232" y="20" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">Diproses (1)</text>

    <rect x="285" y="0" width="57" height="32" rx="16" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="313" y="20" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">Draft (1)</text>
  </g>

  <!-- Items Feed List -->
  <g id="ItemsFeed" transform="translate(24, 155)">
    <!-- Item 1: Draft Offline Sync (Hive) -->
    <g transform="translate(0, 0)">
      <rect width="342" height="96" rx="14" fill="#FFFFFF" stroke="#F59E0B" stroke-width="1.5" />
      <rect x="10" y="10" width="76" height="76" rx="10" fill="#FEF3C7" />
      <text x="48" y="52" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="800" fill="#B45309" text-anchor="middle">OFFLINE</text>
      
      <text x="96" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">Sepatu Ventela Sneaker</text>
      <text x="96" y="48" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#64748B">Pakaian • Ukuran 41</text>
      
      <rect x="96" y="60" width="140" height="22" rx="5" fill="#FFFBEB" />
      <text x="166" y="75" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9.5" font-weight="700" fill="#B45309" text-anchor="middle">⚡ Menunggu Koneksi Pulih</text>
      
      <!-- Sync Retry Icon -->
      <circle cx="316" cy="48" r="14" fill="#FEF3C7" />
      <path d="M312 45 L316 42 L320 45" fill="none" stroke="#B45309" stroke-width="1.8" />
    </g>

    <!-- Item 2: Tersedia Online -->
    <g transform="translate(0, 110)">
      <rect width="342" height="96" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
      <rect x="10" y="10" width="76" height="76" rx="10" fill="#ECFDF5" />
      <text x="48" y="52" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="800" fill="#047857" text-anchor="middle">ONLINE</text>
      
      <text x="96" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">Buku Paket Tematik SD (1-6)</text>
      <text x="96" y="48" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#64748B">Buku • 6 Jilid Lengkap</text>
      
      <rect x="96" y="60" width="80" height="22" rx="5" fill="#ECFDF5" />
      <text x="136" y="75" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9.5" font-weight="700" fill="#047857" text-anchor="middle">Tersedia</text>
    </g>

    <!-- Item 3: Sedang Diproses (In-Process) -->
    <g transform="translate(0, 220)">
      <rect width="342" height="96" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
      <rect x="10" y="10" width="76" height="76" rx="10" fill="#EFF6FF" />
      <text x="48" y="52" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="800" fill="#2563EB" text-anchor="middle">PROSES</text>
      
      <text x="96" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">Tas Ransel Laptop Eiger</text>
      <text x="96" y="48" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#64748B">Alat Sekolah • Biru Navy</text>
      
      <rect x="96" y="60" width="130" height="22" rx="5" fill="#EFF6FF" />
      <text x="161" y="75" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9.5" font-weight="700" fill="#2563EB" text-anchor="middle">Sedang Diproses (Kurir)</text>
    </g>
  </g>

  ${bottomNav(activeIndex: 2)}''';
}

// ==========================================
// SCREEN 7: KATALOG PUBLIK
// ==========================================
String screenPublicCatalog() {
  return '''
  <rect width="390" height="844" fill="#F8FAFC" />
  ${statusBar()}
  ${mobileAppBar('Katalog Kebaikan', showBack: false)}

  <!-- Search Input Bar -->
  <g id="SearchBar" transform="translate(24, 105)">
    <rect width="342" height="46" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
    <circle cx="26" cy="23" r="6" fill="none" stroke="#64748B" stroke-width="1.8" />
    <line x1="31" y1="28" x2="36" y2="33" stroke="#64748B" stroke-width="1.8" stroke-linecap="round" />
    <text x="48" y="28" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" fill="#94A3B8">Cari buku, pakaian, perlengkapan...</text>
  </g>

  <!-- Category Pills Horizontal Scroll -->
  <g id="CategoryPills" transform="translate(24, 163)">
    <rect x="0" y="0" width="68" height="30" rx="15" fill="#047857" />
    <text x="34" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle">Semua</text>

    <rect x="76" y="0" width="76" height="30" rx="15" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="114" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">Pakaian</text>

    <rect x="160" y="0" width="64" height="30" rx="15" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="192" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">Buku</text>

    <rect x="232" y="0" width="86" height="30" rx="15" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="275" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">Elektronik</text>
  </g>

  <!-- 2-Column Responsive Card Grid -->
  <g id="CatalogCards" transform="translate(24, 208)">
    <!-- Card 1 -->
    <g transform="translate(0, 0)">
      <rect width="164" height="248" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
      <rect width="164" height="120" rx="14" fill="#ECFDF5" />
      <rect x="10" y="10" width="55" height="20" rx="5" fill="#047857" />
      <text x="37" y="24" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="800" fill="#FFFFFF" text-anchor="middle">PAKAIAN</text>
      
      <text x="12" y="146" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="800" fill="#0F172A">Jaket Parka Eiger</text>
      <text x="12" y="164" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#64748B">Donatur: Reivan R.</text>
      <text x="12" y="180" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="600" fill="#047857">Bandung • Siap Kirim</text>
      
      <rect x="12" y="200" width="140" height="34" rx="8" fill="#ECFDF5" />
      <text x="82" y="222" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#047857" text-anchor="middle">Lihat Detail</text>
    </g>

    <!-- Card 2 -->
    <g transform="translate(178, 0)">
      <rect width="164" height="248" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
      <rect width="164" height="120" rx="14" fill="#EFF6FF" />
      <rect x="10" y="10" width="46" height="20" rx="5" fill="#2563EB" />
      <text x="33" y="24" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="800" fill="#FFFFFF" text-anchor="middle">BUKU</text>
      
      <text x="12" y="146" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="800" fill="#0F172A">Ensiklopedia Sains</text>
      <text x="12" y="164" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#64748B">Donatur: Siti Rahma</text>
      <text x="12" y="180" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="600" fill="#047857">Jakarta • Siap Kirim</text>
      
      <rect x="12" y="200" width="140" height="34" rx="8" fill="#ECFDF5" />
      <text x="82" y="222" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#047857" text-anchor="middle">Lihat Detail</text>
    </g>
  </g>

  <!-- Hive Cache Indicator -->
  <g transform="translate(24, 475)">
    <rect width="342" height="38" rx="8" fill="#F1F5F9" />
    <circle cx="20" cy="19" r="5" fill="#10B981" />
    <text x="32" y="23" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">Tersinkronisasi dengan Hive Box lokal (Bisa dibuka offline)</text>
  </g>

  ${bottomNav(activeIndex: 1)}''';
}

// ==========================================
// SCREEN 8: DETAIL BARANG & MODAL PERMINTAAN
// ==========================================
String screenItemDetail() {
  return '''
  <rect width="390" height="844" fill="#FFFFFF" />
  ${statusBar()}

  <!-- Hero Image Banner -->
  <g id="HeroImage">
    <rect width="390" height="300" fill="#ECFDF5" />
    <!-- Stylized Item Graphic -->
    <path d="M140 100 L195 85 L250 100 L265 140 L240 150 L240 220 L150 220 L150 150 L125 140 Z" fill="#047857" />
    
    <!-- Floating Back & Action -->
    <circle cx="40" cy="55" r="18" fill="rgba(255,255,255,0.9)" />
    <path d="M43 49 L36 55 L43 61" stroke="#0F172A" stroke-width="2" stroke-linecap="round" fill="none"/>

    <circle cx="350" cy="55" r="18" fill="rgba(255,255,255,0.9)" />
    <circle cx="347" cy="55" r="2" fill="#0F172A" />
    <circle cx="353" cy="55" r="2" fill="#0F172A" />
  </g>

  <!-- Item Details Section -->
  <g id="DetailContent" transform="translate(24, 320)">
    <rect width="65" height="22" rx="5" fill="#ECFDF5" />
    <text x="32" y="15" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9.5" font-weight="800" fill="#047857" text-anchor="middle">PAKAIAN</text>

    <text x="0" y="46" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="20" font-weight="800" fill="#0F172A">Jaket Parka Outdoor Eiger</text>
    
    <!-- Donor Profile Row -->
    <g transform="translate(0, 60)">
      <circle cx="18" cy="18" r="18" fill="#F1F5F9" />
      <text x="18" y="23" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="800" fill="#047857" text-anchor="middle">R</text>
      <text x="44" y="16" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" font-weight="700" fill="#0F172A">Reivan Rasyid (Donatur)</text>
      <text x="44" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">Coblong, Bandung • Aktif 10m lalu</text>
    </g>

    <line x1="0" y1="110" x2="342" y2="110" stroke="#F1F5F9" stroke-width="1.5" />

    <text x="0" y="135" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Deskripsi Kondisi</text>
    <text x="0" y="155" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" fill="#475569">Jaket masih sangat layak pakai 92%, resleting lancar, bahan</text>
    <text x="0" y="172" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" fill="#475569">waterproof tebal. Sangat cocok untuk adik-adik di panti asuhan.</text>
  </g>

  <!-- Bottom Sheet: Permintaan Donasi (Modal) -->
  <g id="BottomSheetModal" transform="translate(0, 520)">
    <rect width="390" height="324" rx="24" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.5" />
    <line x1="175" y1="12" x2="215" y2="12" stroke="#CBD5E1" stroke-width="4" stroke-linecap="round" />

    <text x="24" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="16" font-weight="800" fill="#0F172A">Ajukan Permintaan Donasi</text>
    
    <!-- Community Verified Badge -->
    <rect x="24" y="56" width="220" height="24" rx="6" fill="#ECFDF5" />
    <text x="34" y="72" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" font-weight="700" fill="#047857">Yayasan Kasih Bangsa (Terverifikasi)</text>

    <text x="24" y="105" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" font-weight="700" fill="#0F172A">Tulis Alasan Kebutuhan Barang:</text>
    <rect x="24" y="115" width="342" height="65" rx="8" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1" />
    <text x="36" y="138" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#475569">Dibutuhkan untuk anak asuh kami yang sedang</text>
    <text x="36" y="154" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#475569">mengikuti kegiatan sekolah alam di Lembang.</text>

    <!-- Send Request Button -->
    <rect x="24" y="195" width="342" height="48" rx="12" fill="#047857" />
    <text x="195" y="225" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="700" fill="#FFFFFF" text-anchor="middle">Kirim Permintaan ke Donatur</text>
  </g>''';
}

// ==========================================
// SCREEN 9: PERMINTAAN & SERAH TERIMA REALTIME
// ==========================================
String screenDonorRequestsHandover() {
  return '''
  <rect width="390" height="844" fill="#F8FAFC" />
  ${statusBar()}
  ${mobileAppBar('Permintaan Masuk')}

  <!-- Incoming Request Card -->
  <g id="RequestCard" transform="translate(24, 105)">
    <rect width="342" height="235" rx="16" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
    
    <!-- Item Mini Bar -->
    <rect x="14" y="14" width="46" height="46" rx="8" fill="#ECFDF5" />
    <rect x="24" y="24" width="26" height="26" rx="4" fill="#047857" />
    <text x="70" y="34" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">Jaket Parka Outdoor Eiger</text>
    <text x="70" y="50" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#64748B">Kategori: Pakaian</text>

    <line x1="14" y1="72" x2="328" y2="72" stroke="#F1F5F9" stroke-width="1.5" />

    <!-- Community Profile Info -->
    <g transform="translate(14, 84)">
      <rect width="314" height="46" rx="8" fill="#ECFDF5" />
      <text x="14" y="20" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="800" fill="#047857">Yayasan Kasih Bangsa</text>
      <rect x="220" y="10" width="84" height="18" rx="4" fill="#047857" />
      <text x="262" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="8.5" font-weight="700" fill="#FFFFFF" text-anchor="middle">VERIFIED ADMIN</text>
      <text x="14" y="36" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#64748B">Panti Asuhan Anak Yatim &amp; Dhuafa Bandung</text>
    </g>

    <!-- Reason Text -->
    <text x="14" y="150" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" font-weight="700" fill="#0F172A">Alasan Pengajuan:</text>
    <text x="14" y="166" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">Dibutuhkan untuk anak asuh kegiatan sekolah alam Lembang.</text>

    <!-- Quick Actions -->
    <rect x="14" y="185" width="95" height="36" rx="8" fill="#FFFFFF" stroke="#EF4444" stroke-width="1.2" />
    <text x="61" y="208" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" font-weight="700" fill="#EF4444" text-anchor="middle">Tolak</text>

    <rect x="118" y="185" width="210" height="36" rx="8" fill="#047857" />
    <text x="223" y="208" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" font-weight="700" fill="#FFFFFF" text-anchor="middle">Setujui Permintaan</text>
  </g>

  <!-- Handover Modal (Bottom Agreement Sheet) -->
  <g id="HandoverModal" transform="translate(0, 360)">
    <rect width="390" height="484" rx="24" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.5" />
    <line x1="175" y1="12" x2="215" y2="12" stroke="#CBD5E1" stroke-width="4" stroke-linecap="round" />

    <text x="24" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="16.5" font-weight="800" fill="#0F172A">Metode Serah Terima Barang</text>
    <text x="24" y="64" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" fill="#64748B">Status barang akan otomatis berubah jadi "Sedang Diproses"</text>

    <!-- Option 1: Kurir (Selected) -->
    <g transform="translate(24, 82)">
      <rect width="342" height="64" rx="12" fill="#ECFDF5" stroke="#047857" stroke-width="1.5" />
      <circle cx="28" cy="32" r="14" fill="#047857" />
      <circle cx="28" cy="32" r="5" fill="#FFFFFF" />
      <text x="54" y="27" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" font-weight="800" fill="#0F172A">Kirim via Kurir Ekspedisi</text>
      <text x="54" y="45" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" font-weight="600" fill="#047857">Resi: JNE JP9821448102ID</text>
    </g>

    <!-- Option 2: Antar Langsung -->
    <g transform="translate(24, 154)">
      <rect width="342" height="60" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
      <circle cx="28" cy="30" r="14" fill="#F1F5F9" />
      <text x="54" y="26" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" font-weight="700" fill="#0F172A">Antar Langsung ke Yayasan</text>
      <text x="54" y="43" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">Donatur menyerahkan ke alamat sekretariat</text>
    </g>

    <!-- Option 3: Dijemput Komunitas -->
    <g transform="translate(24, 222)">
      <rect width="342" height="60" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
      <circle cx="28" cy="30" r="14" fill="#F1F5F9" />
      <text x="54" y="26" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12.5" font-weight="700" fill="#0F172A">Dijemput oleh Yayasan</text>
      <text x="54" y="43" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">Relawan mengambil ke alamat donatur</text>
    </g>

    <!-- Confirm Button -->
    <rect x="24" y="305" width="342" height="48" rx="12" fill="#047857" />
    <text x="195" y="335" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="700" fill="#FFFFFF" text-anchor="middle">Konfirmasi Serah Terima</text>
  </g>''';
}

// ==========================================
// SCREEN 10: ADMIN PANEL VERIFIKASI
// ==========================================
String screenAdminVerification() {
  return '''
  <rect width="390" height="844" fill="#F8FAFC" />
  ${statusBar()}
  ${mobileAppBar('Panel Verifikasi Admin', showBack: false)}

  <!-- Filter Status Tabs -->
  <g id="AdminTabs" transform="translate(24, 105)">
    <rect x="0" y="0" width="90" height="30" rx="15" fill="#047857" />
    <text x="45" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle">Menunggu (2)</text>

    <rect x="98" y="0" width="100" height="30" rx="15" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="148" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">Terverifikasi (8)</text>

    <rect x="206" y="0" width="75" height="30" rx="15" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="243" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">Ditolak (1)</text>
  </g>

  <!-- Verification Card 1 -->
  <g id="VerifyCard" transform="translate(24, 155)">
    <rect width="342" height="215" rx="16" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1.2" />
    
    <text x="16" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="800" fill="#0F172A">Yayasan Kasih Bangsa</text>
    <rect x="235" y="16" width="90" height="20" rx="4" fill="#FFFBEB" />
    <text x="280" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="700" fill="#B45309" text-anchor="middle">PENDING REVIEW</text>

    <text x="16" y="52" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#64748B">Izin: AHU-0019284.AH.01.04 • Bandung</text>

    <!-- Document Preview Link -->
    <g transform="translate(16, 68)">
      <rect width="310" height="38" rx="8" fill="#F0FDF4" stroke="#047857" stroke-width="1" />
      <rect x="10" y="8" width="22" height="22" rx="4" fill="#047857" />
      <text x="21" y="23" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="800" fill="#FFFFFF" text-anchor="middle">PDF</text>
      <text x="40" y="23" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#047857">Buka Akta Notaris Yayasan.pdf</text>
      <text x="290" y="23" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#047857" text-anchor="end">Lihat ↗</text>
    </g>

    <!-- Checklist Audit -->
    <g transform="translate(16, 120)">
      <circle cx="8" cy="8" r="7" fill="#ECFDF5" />
      <path d="M5 8 L7 10 L11 6" fill="none" stroke="#047857" stroke-width="1.5" />
      <text x="22" y="11" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#475569">Nomor legalitas Kemenkumham terdata</text>
    </g>

    <line x1="16" y1="145" x2="326" y2="145" stroke="#F1F5F9" stroke-width="1.5" />

    <!-- Actions -->
    <rect x="16" y="160" width="90" height="38" rx="8" fill="#FFFFFF" stroke="#EF4444" stroke-width="1.2" />
    <text x="61" y="184" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#EF4444" text-anchor="middle">Tolak</text>

    <rect x="116" y="160" width="210" height="38" rx="8" fill="#047857" />
    <text x="221" y="184" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#FFFFFF" text-anchor="middle">Setujui Komunitas</text>
  </g>''';
}

// ==========================================
// MASTER CANVAS GENERATOR
// ==========================================
String generateMasterBoard(Map<String, String> screens) {
  final buffer = StringBuffer();
  buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buffer.writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2800 3600" width="2800" height="3600">');
  buffer.writeln('  <defs>');
  buffer.writeln('    <filter id="masterCardShadow" x="-10%" y="-10%" width="120%" height="120%">');
  buffer.writeln('      <feDropShadow dx="0" dy="16" stdDeviation="20" flood-color="#0F172A" flood-opacity="0.12"/>');
  buffer.writeln('    </filter>');
  buffer.writeln('  </defs>');

  // Background
  buffer.writeln('  <rect width="2800" height="3600" fill="#F1F5F9" />');

  // ==========================================
  // 1. PROJECT HEADER & PRESENTATION COVER (IT College Style)
  // ==========================================
  buffer.writeln('''
  <!-- Project Cover Banner -->
  <g id="ProjectCover" transform="translate(80, 60)">
    <rect width="2640" height="280" rx="24" fill="#047857" />
    <circle cx="2500" cy="140" r="160" fill="#065F46" opacity="0.6" />
    
    <!-- Badges -->
    <rect x="48" y="40" width="220" height="30" rx="15" fill="#065F46" />
    <text x="158" y="60" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11.5" font-weight="800" fill="#A7F3D0" text-anchor="middle">TUGAS BESAR PEMROGRAMAN MOBILE</text>

    <text x="48" y="125" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="38" font-weight="800" fill="#FFFFFF">CareCycle — Mobile UI/UX Design System</text>
    <text x="48" y="160" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="16" fill="#ECFDF5">Platform Donasi &amp; Redistribusi Barang Komunitas Berbasis On-Device AI (ML Kit) &amp; Offline-First Sync</text>

    <!-- Student Metadata -->
    <g transform="translate(48, 195)">
      <rect width="180" height="50" rx="10" fill="#065F46" />
      <text x="16" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#A7F3D0">NAMA PENGEMBANG</text>
      <text x="16" y="40" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#FFFFFF">Reivan Rasyid Mulyadi</text>
    </g>

    <g transform="translate(245, 195)">
      <rect width="170" height="50" rx="10" fill="#065F46" />
      <text x="16" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#A7F3D0">PROGRAM STUDI</text>
      <text x="16" y="40" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#FFFFFF">Teknik Informatika (S1)</text>
    </g>

    <g transform="translate(430, 195)">
      <rect width="210" height="50" rx="10" fill="#065F46" />
      <text x="16" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#A7F3D0">TECH STACK UTAMA</text>
      <text x="16" y="40" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#FFFFFF">Flutter • Supabase • ML Kit</text>
    </g>

    <!-- Design Tokens Quick Palette -->
    <g transform="translate(1980, 45)">
      <text x="0" y="0" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#A7F3D0">DESIGN TOKENS PALETTE</text>
      
      <g transform="translate(0, 15)">
        <rect x="0" y="0" width="55" height="40" rx="8" fill="#047857" stroke="#FFFFFF" stroke-width="1.5" />
        <rect x="65" y="0" width="55" height="40" rx="8" fill="#10B981" />
        <rect x="130" y="0" width="55" height="40" rx="8" fill="#065F46" />
        <rect x="195" y="0" width="55" height="40" rx="8" fill="#F59E0B" />
        <rect x="260" y="0" width="55" height="40" rx="8" fill="#EF4444" />
        <rect x="325" y="0" width="55" height="40" rx="8" fill="#F8FAFC" />
        <rect x="390" y="0" width="55" height="40" rx="8" fill="#0F172A" />
      </g>
      <text x="0" y="80" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#ECFDF5">Emerald 700 (#047857) • Secondary (#10B981) • Amber Pending • Red Reject • Slate Dark</text>
    </g>
  </g>''');

  // ==========================================
  // SECTION 1: AUTH & COMMUNITY LEGALITY FLOW
  // ==========================================
  buffer.writeln('''
  <!-- Section 1 Header -->
  <g transform="translate(80, 390)">
    <rect width="2640" height="48" rx="8" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="24" cy="24" r="10" fill="#047857" />
    <text x="24" y="28" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">1</text>
    <text x="46" y="29" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="800" fill="#0F172A">USER FLOW 1: ONBOARDING, MULTI-ROLE AUTH &amp; VERIFIKASI DOKUMEN KOMUNITAS</text>
    <text x="2620" y="29" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#64748B" text-anchor="end">Supabase Auth • PDF Storage • Status Guard</text>
  </g>''');

  final row1 = [
    {'key': '01_splash_screen.svg', 'title': '1. Splash Screen', 'desc': 'Logo &amp; Indikator Bootstrap', 'tag': 'BOOTSTRAP'},
    {'key': '02_login_screen.svg', 'title': '2. Login Screen', 'desc': 'Role Switcher: Donatur/Komunitas/Admin', 'tag': 'AUTH'},
    {'key': '03_register_screen.svg', 'title': '3. Register Komunitas', 'desc': 'Upload Akta Notaris (PDF/Foto)', 'tag': 'LEGALITAS'},
    {'key': '10_admin_verification.svg', 'title': '4. Panel Admin Verifikasi', 'desc': 'Review Berkas Legalitas &amp; Approval', 'tag': 'ADMIN PANEL'},
  ];

  for (int i = 0; i < row1.length; i++) {
    final item = row1[i];
    final x = 80 + i * 680;
    final y = 460;
    final svgContent = screens[item['key']!]!;

    buffer.writeln('''
    <g id="Frame_Flow1_$i" transform="translate($x, $y)">
      <!-- Artboard Label Card -->
      <rect width="390" height="50" rx="10" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
      <text x="14" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">${item['title']}</text>
      <text x="14" y="38" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">${item['desc']}</text>
      <rect x="290" y="12" width="85" height="22" rx="4" fill="#ECFDF5" />
      <text x="332" y="27" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="700" fill="#047857" text-anchor="middle">${item['tag']}</text>

      <!-- Smartphone Device Mockup -->
      <g transform="translate(0, 65)">
        ${phoneShellContent(svgContent)}
      </g>
    </g>''');
  }

  // ==========================================
  // SECTION 2: DONATUR AI & OFFLINE-FIRST FLOW
  // ==========================================
  buffer.writeln('''
  <!-- Section 2 Header -->
  <g transform="translate(80, 1440)">
    <rect width="2640" height="48" rx="8" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="24" cy="24" r="10" fill="#047857" />
    <text x="24" y="28" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">2</text>
    <text x="46" y="29" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="800" fill="#0F172A">USER FLOW 2: DONATUR — ON-DEVICE AI IMAGE LABELING &amp; OFFLINE-FIRST SYNC</text>
    <text x="2620" y="29" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#64748B" text-anchor="end">Google ML Kit • Hive Storage • Connectivity Plus</text>
  </g>''');

  final row2 = [
    {'key': '04_home_donatur.svg', 'title': '5. Beranda Donatur', 'desc': 'Dashboard CarePoints, Impact &amp; Notifikasi', 'tag': 'DASHBOARD'},
    {'key': '05_item_upload_ai.svg', 'title': '6. Unggah Donasi + ML Kit', 'desc': 'Labeling AI Otomatis &amp; Draft Simpan Offline', 'tag': 'ON-DEVICE ML'},
    {'key': '06_my_items.svg', 'title': '7. Kelola "Barang Saya"', 'desc': 'Tab Draft Menunggu Koneksi &amp; Auto Sync', 'tag': 'HIVE SYNC'},
  ];

  for (int i = 0; i < row2.length; i++) {
    final item = row2[i];
    final x = 80 + i * 680;
    final y = 1510;
    final svgContent = screens[item['key']!]!;

    buffer.writeln('''
    <g id="Frame_Flow2_$i" transform="translate($x, $y)">
      <rect width="390" height="50" rx="10" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
      <text x="14" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">${item['title']}</text>
      <text x="14" y="38" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">${item['desc']}</text>
      <rect x="290" y="12" width="85" height="22" rx="4" fill="#ECFDF5" />
      <text x="332" y="27" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="700" fill="#047857" text-anchor="middle">${item['tag']}</text>

      <g transform="translate(0, 65)">
        ${phoneShellContent(svgContent)}
      </g>
    </g>''');
  }

  // Feature Explanation Card on Row 2
  buffer.writeln('''
  <g transform="translate(2120, 1510)">
    <rect width="600" height="910" rx="20" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5" />
    
    <rect x="30" y="30" width="160" height="28" rx="14" fill="#ECFDF5" />
    <text x="110" y="49" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="800" fill="#047857" text-anchor="middle">ARSITEKTUR FITUR IT</text>
    
    <text x="30" y="95" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="22" font-weight="800" fill="#0F172A">Fitur Unggulan Praktikum</text>
    
    <!-- ML Kit Explanation -->
    <g transform="translate(30, 125)">
      <rect width="540" height="150" rx="12" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1" />
      <circle cx="28" cy="28" r="14" fill="#ECFDF5" />
      <text x="28" y="33" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="800" fill="#047857" text-anchor="middle">AI</text>
      <text x="54" y="26" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="800" fill="#0F172A">Google ML Kit Image Labeling (On-Device)</text>
      <text x="54" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#64748B">Model machine learning berjalan 100% lokal di smartphone tanpa latency cloud. Otomatis mengenali label pakaian, buku, elektronik, dan memetakan ke kategori sistem.</text>
    </g>

    <!-- Offline Sync Explanation -->
    <g transform="translate(30, 295)">
      <rect width="540" height="150" rx="12" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1" />
      <circle cx="28" cy="28" r="14" fill="#FFFBEB" />
      <text x="28" y="33" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="800" fill="#B45309" text-anchor="middle">⚡</text>
      <text x="54" y="26" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="800" fill="#0F172A">Offline-First dengan Hive NoSQL Box</text>
      <text x="54" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#64748B">Saat internet terputus, form donasi tetap dapat diisi dan disimpan sebagai draft lokal di Hive. ConnectivityPlus memonitor sinyal untuk auto-upload otomatis saat online.</text>
    </g>

    <!-- Realtime Real-Life Flow -->
    <g transform="translate(30, 465)">
      <rect width="540" height="150" rx="12" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1" />
      <circle cx="28" cy="28" r="14" fill="#EFF6FF" />
      <text x="28" y="33" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="800" fill="#2563EB" text-anchor="middle">🔄</text>
      <text x="54" y="26" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="800" fill="#0F172A">Supabase Realtime WebSockets</text>
      <text x="54" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#64748B">Ketika komunitas mengajukan permintaan, donatur menerima notifikasi in-app realtime secara instan tanpa perlu merefresh halaman aplikasi.</text>
    </g>
  </g>''');

  // ==========================================
  // SECTION 3: PUBLIC CATALOG & REALTIME HANDOVER FLOW
  // ==========================================
  buffer.writeln('''
  <!-- Section 3 Header -->
  <g transform="translate(80, 2490)">
    <rect width="2640" height="48" rx="8" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="24" cy="24" r="10" fill="#047857" />
    <text x="24" y="28" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="800" fill="#FFFFFF" text-anchor="middle">3</text>
    <text x="46" y="29" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="800" fill="#0F172A">USER FLOW 3: KOMUNITAS — KATALOG PUBLIK &amp; SIKLUS SERAH TERIMA REALTIME</text>
    <text x="2620" y="29" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#64748B" text-anchor="end">Filter Chips • Modal Ajukan Permintaan • Handover Method</text>
  </g>''');

  final row3 = [
    {'key': '07_public_catalog.svg', 'title': '8. Katalog Donasi Publik', 'desc': 'Pencarian, Filter Kategori &amp; Grid Offline', 'tag': 'PUBLIC GRID'},
    {'key': '08_item_detail.svg', 'title': '9. Detail &amp; Modal Permintaan', 'desc': 'Kirim Alasan Donasi Komunitas Verified', 'tag': 'REQUEST MODAL'},
    {'key': '09_donor_requests_handover.svg', 'title': '10. Review &amp; Serah Terima', 'desc': 'Setujui &amp; Pilih Metode (Kurir/Antar/Jemput)', 'tag': 'HANDOVER FLOW'},
  ];

  for (int i = 0; i < row3.length; i++) {
    final item = row3[i];
    final x = 80 + i * 680;
    final y = 2560;
    final svgContent = screens[item['key']!]!;

    buffer.writeln('''
    <g id="Frame_Flow3_$i" transform="translate($x, $y)">
      <rect width="390" height="50" rx="10" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
      <text x="14" y="22" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="800" fill="#0F172A">${item['title']}</text>
      <text x="14" y="38" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10.5" fill="#64748B">${item['desc']}</text>
      <rect x="290" y="12" width="85" height="22" rx="4" fill="#ECFDF5" />
      <text x="332" y="27" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="700" fill="#047857" text-anchor="middle">${item['tag']}</text>

      <g transform="translate(0, 65)">
        ${phoneShellContent(svgContent)}
      </g>
    </g>''');
  }

  // Summary Note on bottom right
  buffer.writeln('''
  <g transform="translate(2120, 2560)">
    <rect width="600" height="910" rx="20" fill="#047857" />
    <circle cx="2600" cy="3000" r="180" fill="#065F46" opacity="0.5" />
    
    <g transform="translate(40, 50)">
      <text x="0" y="0" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="24" font-weight="800" fill="#FFFFFF">CareCycle Delivery Agreement</text>
      <text x="0" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="#ECFDF5">Tiga Metode Serah Terima yang Didukung Sistem:</text>

      <!-- Courier -->
      <g transform="translate(0, 60)">
        <rect width="520" height="90" rx="12" fill="#065F46" />
        <text x="20" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="800" fill="#FFFFFF">1. Kurir Ekspedisi (JNE, J&amp;T, SiCepat)</text>
        <text x="20" y="55" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#A7F3D0">Donatur mengirim via kurir dan menginput nomor resi pelacakan ke dalam aplikasi agar dapat dipantau bersama.</text>
      </g>

      <!-- Self Deliver -->
      <g transform="translate(0, 170)">
        <rect width="520" height="90" rx="12" fill="#065F46" />
        <text x="20" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="800" fill="#FFFFFF">2. Antar Langsung (Self Deliver)</text>
        <text x="20" y="55" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#A7F3D0">Donatur mengantar langsung ke alamat yayasan/komunitas penerima yang telah terverifikasi keabsahannya oleh admin.</text>
      </g>

      <!-- Pickup -->
      <g transform="translate(0, 280)">
        <rect width="520" height="90" rx="12" fill="#065F46" />
        <text x="20" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="800" fill="#FFFFFF">3. Dijemput Komunitas (Pickup)</text>
        <text x="20" y="55" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#A7F3D0">Relawan yayasan mendatangi titik penjemputan donatur sesuai perjanjian waktu yang disepakati.</text>
      </g>
    </g>
  </g>''');

  buffer.writeln('</svg>');
  return buffer.toString();
}
