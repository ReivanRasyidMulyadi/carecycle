import os

output_dir = r"d:\KULIAH BUD\Ssemester 3\Pemrograman Mobile\carecycle\figma"
os.makedirs(output_dir, exist_ok=True)

# Shared Colors & Styles
PRIMARY = "#047857"
PRIMARY_LIGHT = "#10B981"
PRIMARY_DARK = "#065F46"
PRIMARY_BG = "#ECFDF5"
WARNING = "#F59E0B"
WARNING_BG = "#FFFBEB"
ERROR = "#EF4444"
ERROR_BG = "#FEF2F2"
BG_LIGHT = "#F8FAFC"
SURFACE = "#FFFFFF"
TEXT_PRIMARY = "#0F172A"
TEXT_SECONDARY = "#64748B"
BORDER = "#E2E8F0"

def get_status_bar():
    return '''
      <!-- Status Bar -->
      <g id="StatusBar">
        <text x="32" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="600" fill="#0F172A">09:41</text>
        <circle cx="340" cy="28" r="4" fill="#0F172A" />
        <circle cx="352" cy="28" r="4" fill="#0F172A" />
        <rect x="362" y="24" width="18" height="9" rx="3" fill="none" stroke="#0F172A" stroke-width="1.5" />
        <rect x="364" y="26" width="12" height="5" rx="1.5" fill="#0F172A" />
      </g>
    '''

def get_app_bar(title, show_back=False, right_icon=None):
    back_btn = '''
      <g id="BackButton">
        <circle cx="36" cy="74" r="18" fill="#F1F5F9" />
        <path d="M40 68 L32 74 L40 80" stroke="#0F172A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
      </g>
    ''' if show_back else ''
    
    right_btn = ''
    if right_icon == "bell":
        right_btn = '''
          <g id="ActionBell">
            <circle cx="354" cy="74" r="18" fill="#F1F5F9" />
            <path d="M354 66 C350 66 348 69 348 73 L346 76 L362 76 L360 73 C360 69 358 66 354 66 Z" fill="#0F172A" />
            <circle cx="362" cy="66" r="4" fill="#EF4444" />
          </g>
        '''
    elif right_icon == "refresh":
        right_btn = '''
          <g id="ActionRefresh">
            <circle cx="354" cy="74" r="18" fill="#F1F5F9" />
            <path d="M358 70 A5 5 0 1 1 350 74" fill="none" stroke="#0F172A" stroke-width="2" stroke-linecap="round" />
            <polygon points="358,67 361,72 355,72" fill="#0F172A" />
          </g>
        '''
    
    title_x = "70" if show_back else "24"
    return f'''
      <!-- AppBar -->
      <g id="AppBar">
        {back_btn}
        <text x="{title_x}" y="80" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="20" font-weight="700" fill="#0F172A">{title}</text>
        {right_btn}
      </g>
    '''

# 1. Splash Screen
def screen_splash():
    return f'''
      <rect width="390" height="844" fill="{PRIMARY}" />
      <g id="CenterContent" transform="translate(0, 300)">
        <circle cx="195" cy="50" r="50" fill="{PRIMARY_DARK}" />
        <path d="M180 50 C180 38 190 30 202 34 L196 40 C190 38 186 42 186 50 C186 58 194 62 200 58 L206 64 C196 70 180 66 180 50 Z" fill="#FFFFFF" />
        <path d="M205 38 L212 36 L210 44 Z" fill="{PRIMARY_LIGHT}" />
        <text x="195" y="140" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="32" font-weight="800" fill="#FFFFFF" text-anchor="middle">CareCycle</text>
        <text x="195" y="170" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" fill="#A7F3D0" text-anchor="middle">Platform Berbagi &amp; Donasi Komunitas</text>
        
        <circle cx="195" cy="240" r="12" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-dasharray="25 10" />
      </g>
    '''

# 2. Login Screen
def screen_login():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      <g id="Header" transform="translate(24, 90)">
        <circle cx="36" cy="36" r="36" fill="{PRIMARY_BG}" />
        <path d="M26 36 C26 28 32 24 38 24 C44 24 50 28 50 36 C50 44 42 48 38 48 C32 48 26 44 26 36 Z" fill="{PRIMARY}" />
        <text x="0" y="105" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="24" font-weight="700" fill="#0F172A">Selamat Datang 👋</text>
        <text x="0" y="130" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="{TEXT_SECONDARY}">Masuk untuk mulai berbagi &amp; mendonasikan barang</text>
      </g>

      <!-- Form Inputs -->
      <g id="Form" transform="translate(24, 260)">
        <text x="0" y="0" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Email</text>
        <rect x="0" y="10" width="342" height="48" rx="10" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1.5" />
        <text x="16" y="40" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="{TEXT_SECONDARY}">donatur@carecycle.id</text>

        <text x="0" y="85" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Kata Sandi</text>
        <rect x="0" y="95" width="342" height="48" rx="10" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1.5" />
        <text x="16" y="125" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" fill="{TEXT_SECONDARY}">••••••••••••</text>
        <text x="290" y="125" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{PRIMARY}" font-weight="600">Lihat</text>

        <!-- Submit Button -->
        <rect x="0" y="175" width="342" height="50" rx="10" fill="{PRIMARY}" />
        <text x="171" y="206" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="700" fill="#FFFFFF" text-anchor="middle">Masuk ke Akun</text>

        <!-- Register Link -->
        <text x="171" y="260" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="{TEXT_SECONDARY}" text-anchor="middle">Belum punya akun? <tspan fill="{PRIMARY}" font-weight="700">Daftar Sekarang</tspan></text>
      </g>
    '''

# 3. Register Screen
def screen_register():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      {get_app_bar("Daftar Akun Baru", show_back=True)}

      <g id="RoleSelector" transform="translate(24, 115)">
        <text x="0" y="0" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Pilih Peran Pengguna *</text>
        
        <!-- Card Donatur (Active) -->
        <rect x="0" y="12" width="164" height="85" rx="12" fill="{PRIMARY_BG}" stroke="{PRIMARY}" stroke-width="2" />
        <circle cx="28" cy="40" r="14" fill="{PRIMARY}" />
        <text x="28" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#FFFFFF" text-anchor="middle">🎁</text>
        <text x="20" y="72" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="{PRIMARY}">Donatur</text>
        <circle cx="145" cy="30" r="8" fill="{PRIMARY}" />
        <polyline points="142,30 144,33 149,27" stroke="#FFF" stroke-width="1.5" fill="none" />

        <!-- Card Komunitas -->
        <rect x="178" y="12" width="164" height="85" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <circle cx="206" cy="40" r="14" fill="#F1F5F9" />
        <text x="206" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" text-anchor="middle">🏢</text>
        <text x="198" y="72" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="{TEXT_SECONDARY}">Komunitas</text>
      </g>

      <!-- Form Inputs -->
      <g id="RegisterForm" transform="translate(24, 240)">
        <text x="0" y="0" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Nama Lengkap</text>
        <rect x="0" y="10" width="342" height="46" rx="10" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="16" y="38" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="#0F172A">Reivan Rasyid</text>

        <text x="0" y="80" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Alamat Email</text>
        <rect x="0" y="90" width="342" height="46" rx="10" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="16" y="118" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="#0F172A">reivan@carecycle.id</text>

        <text x="0" y="160" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Kata Sandi (min. 6 karakter)</text>
        <rect x="0" y="170" width="342" height="46" rx="10" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="16" y="198" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" fill="{TEXT_SECONDARY}">••••••••</text>

        <!-- Submit Button -->
        <rect x="0" y="245" width="342" height="50" rx="10" fill="{PRIMARY}" />
        <text x="171" y="276" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="700" fill="#FFFFFF" text-anchor="middle">Daftar Akun Donatur</text>
      </g>
    '''

# 4. Home Screen Donatur
def screen_home_donatur():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      {get_app_bar("CareCycle", right_icon="bell")}

      <!-- User Card -->
      <g id="UserCard" transform="translate(24, 110)">
        <rect width="342" height="74" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" filter="drop-shadow(0 2px 4px rgba(0,0,0,0.04))" />
        <circle cx="38" cy="37" r="22" fill="{PRIMARY_BG}" />
        <text x="38" y="44" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="18" font-weight="700" fill="{PRIMARY}" text-anchor="middle">R</text>
        <text x="70" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="700" fill="#0F172A">Halo, Reivan Rasyid 👋</text>
        
        <rect x="70" y="40" width="60" height="20" rx="4" fill="{PRIMARY}" />
        <text x="100" y="54" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" font-weight="700" fill="#FFFFFF" text-anchor="middle">Donatur</text>
      </g>

      <!-- CarePoints Gamification Card -->
      <g id="PointsCard" transform="translate(24, 200)">
        <rect width="342" height="85" rx="14" fill="{PRIMARY_DARK}" />
        <text x="20" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#A7F3D0">Total CarePoints Donasi</text>
        <text x="20" y="65" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="26" font-weight="800" fill="#FFFFFF">120 Poin</text>
        <circle cx="295" cy="42" r="24" fill="rgba(255,255,255,0.15)" />
        <text x="295" y="48" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="20" text-anchor="middle">🌱</text>
      </g>

      <!-- Section Title -->
      <text x="24" y="315" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="700" fill="#0F172A">Aktivitas Donatur</text>

      <!-- 2x2 Grid Activity Cards -->
      <g id="GridActivities" transform="translate(24, 330)">
        <!-- Card 1: Unggah Donasi -->
        <rect x="0" y="0" width="164" height="95" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <circle cx="30" cy="30" r="16" fill="{PRIMARY_BG}" />
        <text x="30" y="35" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" text-anchor="middle">📸</text>
        <text x="16" y="64" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Unggah Donasi</text>
        <text x="16" y="80" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{TEXT_SECONDARY}">Donasikan barang layak</text>

        <!-- Card 2: Barang Saya -->
        <rect x="178" y="0" width="164" height="95" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <circle cx="208" cy="30" r="16" fill="#FFFBEB" />
        <text x="208" y="35" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" text-anchor="middle">📦</text>
        <text x="194" y="64" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Barang Saya</text>
        <text x="194" y="80" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{WARNING}" font-weight="600">1 draft offline ⚡</text>

        <!-- Card 3: Katalog Publik -->
        <rect x="0" y="110" width="164" height="95" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <circle cx="30" cy="140" r="16" fill="{PRIMARY_BG}" />
        <text x="30" y="145" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" text-anchor="middle">🔍</text>
        <text x="16" y="174" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Katalog Publik</text>
        <text x="16" y="190" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{TEXT_SECONDARY}">Eksplorasi donasi</text>

        <!-- Card 4: Permintaan Masuk -->
        <rect x="178" y="110" width="164" height="95" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <circle cx="208" cy="140" r="16" fill="{PRIMARY_BG}" />
        <text x="208" y="145" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" text-anchor="middle">📥</text>
        <text x="194" y="174" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Permintaan Masuk</text>
        <text x="194" y="190" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{PRIMARY}" font-weight="600">2 permohonan baru</text>
      </g>
    '''

# 5. Item Upload Screen with AI ML Kit
def screen_item_upload():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      {get_app_bar("Unggah Donasi Barang", show_back=True)}

      <!-- Photo Picker Box with Image -->
      <g id="PhotoPicker" transform="translate(24, 105)">
        <rect width="342" height="150" rx="12" fill="#E2E8F0" />
        <!-- Mock photo -->
        <rect x="0" y="0" width="342" height="150" rx="12" fill="#334155" />
        <text x="171" y="80" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="32" text-anchor="middle">👕</text>
        <rect x="295" y="10" width="36" height="36" rx="18" fill="rgba(0,0,0,0.5)" />
        <text x="313" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="16" fill="#FFFFFF" text-anchor="middle">✕</text>
      </g>

      <!-- AI ML Kit Recommendation Banner -->
      <g id="AiSuggestion" transform="translate(24, 270)">
        <rect width="342" height="54" rx="10" fill="{PRIMARY_BG}" stroke="{PRIMARY_LIGHT}" stroke-width="1" />
        <text x="16" y="24" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="{PRIMARY}">✨ Rekomendasi Kategori AI: Pakaian</text>
        <text x="16" y="42" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{TEXT_SECONDARY}">Terdeteksi label "shirt" (akurasi 94%). Anda bebas mengubahnya.</text>
      </g>

      <!-- Form Inputs -->
      <g id="UploadForm" transform="translate(24, 340)">
        <text x="0" y="0" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Judul Barang *</text>
        <rect x="0" y="8" width="342" height="44" rx="8" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="14" y="34" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#0F172A">Kemeja Formal Pria Lengan Panjang</text>

        <!-- Category Chips -->
        <text x="0" y="75" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Kategori *</text>
        <rect x="0" y="85" width="75" height="28" rx="14" fill="{PRIMARY}" />
        <text x="37" y="103" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#FFFFFF" text-anchor="middle">Pakaian ✨</text>
        
        <rect x="83" y="85" width="55" height="28" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="110" y="103" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Buku</text>

        <rect x="146" y="85" width="85" height="28" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="188" y="103" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Elektronik</text>

        <rect x="239" y="85" width="95" height="28" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="286" y="103" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Alat Sekolah</text>

        <!-- Condition Chips -->
        <text x="0" y="138" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Kondisi Barang *</text>
        <rect x="0" y="148" width="90" height="28" rx="14" fill="{PRIMARY}" />
        <text x="45" y="166" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="#FFFFFF" text-anchor="middle">Sangat Baik</text>

        <rect x="98" y="148" width="85" height="28" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="140" y="166" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Layak Pakai</text>

        <!-- Location -->
        <text x="0" y="200" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="600" fill="#0F172A">Lokasi / Kota</text>
        <rect x="0" y="208" width="342" height="44" rx="8" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="14" y="234" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="#0F172A">Bandung, Jawa Barat</text>

        <!-- Button -->
        <rect x="0" y="275" width="342" height="50" rx="10" fill="{PRIMARY}" />
        <text x="171" y="306" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="700" fill="#FFFFFF" text-anchor="middle">Donasikan Barang Sekarang</text>
      </g>
    '''

# 6. My Items Screen (Barang Saya)
def screen_my_items():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      {get_app_bar("Barang Saya", show_back=True, right_icon="refresh")}

      <!-- Offline Sync Banner -->
      <g id="SyncBanner" transform="translate(24, 110)">
        <rect width="342" height="62" rx="12" fill="{WARNING_BG}" stroke="{WARNING}" stroke-width="1" />
        <text x="16" y="28" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#92400E">1 Draft Menunggu Koneksi ⚡</text>
        <text x="16" y="46" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="#B45309">Otomatis diunggah saat online</text>
        
        <rect x="240" y="16" width="90" height="30" rx="6" fill="{PRIMARY}" />
        <text x="285" y="35" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle">Sinkronkan</text>
      </g>

      <!-- Items List -->
      <g id="ItemList" transform="translate(24, 190)">
        <!-- Card 1: Draft Offline -->
        <rect x="0" y="0" width="342" height="105" rx="12" fill="#FFFFFF" stroke="{WARNING}" stroke-width="1.5" />
        <rect x="10" y="10" width="85" height="85" rx="8" fill="#F1F5F9" />
        <text x="52" y="58" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="28" text-anchor="middle">📚</text>
        <text x="105" y="30" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Buku Pemrograman Dart</text>
        <rect x="105" y="38" width="50" height="18" rx="4" fill="{PRIMARY_BG}" />
        <text x="130" y="51" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{PRIMARY}" font-weight="600" text-anchor="middle">Buku</text>
        
        <rect x="105" y="65" width="125" height="20" rx="4" fill="{WARNING_BG}" />
        <text x="167" y="79" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="#B45309" font-weight="700" text-anchor="middle">⚡ Menunggu koneksi</text>

        <!-- Card 2: Synced Item (Available) -->
        <rect x="0" y="120" width="342" height="105" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <rect x="10" y="130" width="85" height="85" rx="8" fill="#F1F5F9" />
        <text x="52" y="178" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="28" text-anchor="middle">👕</text>
        <text x="105" y="150" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Kemeja Formal Pria</text>
        <rect x="105" y="158" width="60" height="18" rx="4" fill="{PRIMARY_BG}" />
        <text x="135" y="171" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{PRIMARY}" font-weight="600" text-anchor="middle">Pakaian</text>

        <rect x="105" y="185" width="70" height="20" rx="4" fill="{PRIMARY_BG}" />
        <text x="140" y="199" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{PRIMARY}" font-weight="700" text-anchor="middle">✓ Tersedia</text>
      </g>
    '''

# 7. Public Catalog Screen
def screen_catalog():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      {get_app_bar("Katalog Publik Donasi", show_back=True)}

      <!-- Search Bar -->
      <g id="SearchBar" transform="translate(24, 110)">
        <rect width="342" height="44" rx="10" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="16" y="27" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" fill="{TEXT_SECONDARY}">🔍  Cari barang atau kota...</text>
      </g>

      <!-- Category Filter Chips -->
      <g id="Filters" transform="translate(24, 165)">
        <rect x="0" y="0" width="65" height="28" rx="14" fill="{PRIMARY}" />
        <text x="32" y="18" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle">Semua</text>

        <rect x="73" y="0" width="75" height="28" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="110" y="18" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Pakaian</text>

        <rect x="156" y="0" width="60" height="28" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="186" y="18" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Buku</text>

        <rect x="224" y="0" width="85" height="28" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="266" y="18" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Elektronik</text>
      </g>

      <!-- 2-Column Grid Catalog -->
      <g id="CatalogGrid" transform="translate(24, 210)">
        <!-- Item 1 -->
        <rect x="0" y="0" width="164" height="210" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <rect x="0" y="0" width="164" height="110" rx="12" fill="#E2E8F0" />
        <text x="82" y="65" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="32" text-anchor="middle">🎒</text>
        <text x="10" y="132" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Tas Sekolah Anak</text>
        <text x="10" y="150" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{PRIMARY}" font-weight="600">Alat Sekolah</text>
        <text x="10" y="172" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{TEXT_SECONDARY}">📍 Bandung</text>
        <rect x="10" y="182" width="55" height="18" rx="4" fill="{PRIMARY_BG}" />
        <text x="37" y="195" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="700" fill="{PRIMARY}" text-anchor="middle">Tersedia</text>

        <!-- Item 2 -->
        <rect x="178" y="0" width="164" height="210" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <rect x="178" y="0" width="164" height="110" rx="12" fill="#E2E8F0" />
        <text x="260" y="65" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="32" text-anchor="middle">📖</text>
        <text x="188" y="132" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#0F172A">Ensiklopedia Sains</text>
        <text x="188" y="150" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{PRIMARY}" font-weight="600">Buku</text>
        <text x="188" y="172" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{TEXT_SECONDARY}">📍 Jakarta</text>
        <rect x="188" y="182" width="55" height="18" rx="4" fill="{PRIMARY_BG}" />
        <text x="215" y="195" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="700" fill="{PRIMARY}" text-anchor="middle">Tersedia</text>
      </g>
    '''

# 8. Item Detail Screen
def screen_item_detail():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      
      <!-- Top Image Header -->
      <rect x="0" y="0" width="390" height="240" fill="#334155" />
      <text x="195" y="130" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="54" text-anchor="middle">🎒</text>
      <circle cx="36" cy="65" r="18" fill="rgba(0,0,0,0.5)" />
      <path d="M40 59 L32 65 L40 71" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" fill="none"/>

      <!-- Body Content -->
      <g id="DetailContent" transform="translate(24, 260)">
        <rect x="0" y="0" width="65" height="22" rx="4" fill="{PRIMARY_BG}" />
        <text x="32" y="15" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="{PRIMARY}" text-anchor="middle">Alat Sekolah</text>

        <rect x="75" y="0" width="80" height="22" rx="4" fill="#F1F5F9" />
        <text x="115" y="15" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Sangat Baik</text>

        <text x="0" y="50" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="20" font-weight="800" fill="#0F172A">Tas Sekolah Ransel Anak</text>
        <text x="0" y="75" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" fill="{TEXT_SECONDARY}">📍 Sukajadi, Kota Bandung • Diposting 2 hari lalu</text>

        <line x1="0" y1="95" x2="342" y2="95" stroke="{BORDER}" stroke-width="1" />

        <text x="0" y="125" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="700" fill="#0F172A">Deskripsi Barang</text>
        <text x="0" y="148" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" fill="{TEXT_SECONDARY}">Ransel masih dalam kondisi sangat bagus, resleting aman tanpa cacat. Cocok untuk anak usia SD/SMP yang membutuhkan perlengkapan sekolah.</text>

        <!-- Donor Profile Card -->
        <rect x="0" y="210" width="342" height="60" rx="10" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <circle cx="30" cy="240" r="16" fill="{PRIMARY_BG}" />
        <text x="30" y="245" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="{PRIMARY}" text-anchor="middle">R</text>
        <text x="56" y="235" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Reivan Rasyid</text>
        <text x="56" y="250" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}">Donatur Terpercaya • 120 Poin</text>
      </g>

      <!-- Bottom Floating Action Bar -->
      <g id="BottomAction" transform="translate(0, 750)">
        <rect width="390" height="94" fill="#FFFFFF" filter="drop-shadow(0 -4px 10px rgba(0,0,0,0.05))" />
        <rect x="24" y="16" width="342" height="50" rx="10" fill="{PRIMARY}" />
        <text x="195" y="47" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="15" font-weight="700" fill="#FFFFFF" text-anchor="middle">Ajukan Permintaan Donasi</text>
      </g>
    '''

# 9. Donor Requests & Handover Screen
def screen_donor_requests():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      {get_app_bar("Permintaan Masuk", show_back=True)}

      <!-- Request Card -->
      <g id="RequestCard" transform="translate(24, 115)">
        <rect width="342" height="235" rx="14" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        
        <!-- Item Info -->
        <rect x="14" y="14" width="45" height="45" rx="8" fill="#F1F5F9" />
        <text x="36" y="42" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="20" text-anchor="middle">🎒</text>
        <text x="70" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Tas Sekolah Ransel</text>
        <text x="70" y="48" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}">Alat Sekolah</text>

        <line x1="14" y1="70" x2="328" y2="70" stroke="{BORDER}" stroke-width="1" />

        <!-- Community Info -->
        <rect x="14" y="80" width="314" height="45" rx="8" fill="{PRIMARY_BG}" />
        <text x="26" y="100" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="{PRIMARY}">🏢 Yayasan Kasih Bangsa</text>
        <rect x="230" y="88" width="85" height="18" rx="4" fill="{PRIMARY}" />
        <text x="272" y="101" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="700" fill="#FFFFFF" text-anchor="middle">✓ VERIFIED</text>
        <text x="26" y="116" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="10" fill="{TEXT_SECONDARY}">Panti Asuhan Anak Yatim &amp; Dhuafa</text>

        <!-- Reason -->
        <text x="14" y="145" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#0F172A">Alasan Pengajuan:</text>
        <text x="14" y="162" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}">Dibutuhkan untuk adik asuh yang baru masuk SD tahun ajaran baru ini.</text>

        <!-- Actions -->
        <rect x="14" y="185" width="100" height="36" rx="8" fill="#FFFFFF" stroke="{ERROR}" stroke-width="1.5" />
        <text x="64" y="208" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="{ERROR}" text-anchor="middle">Tolak</text>

        <rect x="124" y="185" width="204" height="36" rx="8" fill="{PRIMARY}" />
        <text x="226" y="208" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#FFFFFF" text-anchor="middle">✓ Setujui Permintaan</text>
      </g>
    '''

# 10. Admin Verification Panel
def screen_admin():
    return f'''
      <rect width="390" height="844" fill="{BG_LIGHT}" />
      {get_status_bar()}
      {get_app_bar("Panel Admin Verifikasi")}

      <!-- Status Tabs -->
      <g id="Tabs" transform="translate(24, 110)">
        <rect x="0" y="0" width="85" height="30" rx="15" fill="{PRIMARY}" />
        <text x="42" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle">Menunggu</text>

        <rect x="95" y="0" width="95" height="30" rx="15" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="142" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Terverifikasi</text>

        <rect x="200" y="0" width="70" height="30" rx="15" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        <text x="235" y="19" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}" text-anchor="middle">Ditolak</text>
      </g>

      <!-- Admin Queue Card -->
      <g id="QueueCard" transform="translate(24, 160)">
        <rect width="342" height="190" rx="12" fill="#FFFFFF" stroke="{BORDER}" stroke-width="1" />
        
        <text x="16" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="14" font-weight="700" fill="#0F172A">Komunitas Peduli Sesama</text>
        <rect x="235" y="18" width="90" height="20" rx="4" fill="{WARNING_BG}" />
        <text x="280" y="32" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="9" font-weight="700" fill="#B45309" text-anchor="middle">⏳ Menunggu</text>

        <text x="16" y="55" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" fill="{TEXT_SECONDARY}">Organisasi sosial penyalur bantuan anak jalanan.</text>

        <!-- Doc Link Button -->
        <rect x="16" y="75" width="170" height="32" rx="6" fill="#FFFFFF" stroke="{PRIMARY}" stroke-width="1" />
        <text x="101" y="96" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="11" font-weight="600" fill="{PRIMARY}" text-anchor="middle">📄 Buka Akta Notaris (PDF)</text>

        <line x1="16" y1="125" x2="326" y2="125" stroke="{BORDER}" stroke-width="1" />

        <!-- Actions -->
        <rect x="16" y="140" width="90" height="34" rx="8" fill="#FFFFFF" stroke="{ERROR}" stroke-width="1" />
        <text x="61" y="162" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="{ERROR}" text-anchor="middle">✕ Tolak</text>

        <rect x="116" y="140" width="210" height="34" rx="8" fill="{PRIMARY}" />
        <text x="221" y="162" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="12" font-weight="700" fill="#FFFFFF" text-anchor="middle">✓ Setujui Komunitas</text>
      </g>
    '''

screens = [
    ("01_splash_screen.svg", "Splash Screen", screen_splash),
    ("02_login_screen.svg", "Login Screen", screen_login),
    ("03_register_screen.svg", "Register Screen", screen_register),
    ("04_home_donatur.svg", "Home Donatur", screen_home_donatur),
    ("05_item_upload_ai.svg", "Upload Donasi & AI ML Kit", screen_item_upload),
    ("06_my_items.svg", "Barang Saya (Offline Draft)", screen_my_items),
    ("07_public_catalog.svg", "Katalog Publik", screen_catalog),
    ("08_item_detail.svg", "Detail Barang Donasi", screen_item_detail),
    ("09_donor_requests_handover.svg", "Permintaan Masuk & Serah Terima", screen_donor_requests),
    ("10_admin_verification.svg", "Panel Admin Verifikasi", screen_admin),
]

# Generate individual files
for fname, title, func in screens:
    content = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 844" width="390" height="844">
      {func()}
    </svg>'''
    filepath = os.path.join(output_dir, fname)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

# Generate All-in-One Canvas SVG for Figma
# 5 columns x 2 rows (width: 5 * 450 = 2250, height: 2 * 960 = 1920)
col_w = 440
row_h = 920

all_svg = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2300 1950" width="2300" height="1950">']
all_svg.append('<rect width="2300" height="1950" fill="#E2E8F0" />')
all_svg.append('<text x="40" y="50" font-family="\'Plus Jakarta Sans\', Inter, sans-serif" font-size="28" font-weight="800" fill="#0F172A">CareCycle UI/UX Mobile App - Master Canvas Figma</text>')

for idx, (fname, title, func) in enumerate(screens):
    col = idx % 5
    row = idx // 5
    x = 40 + col * col_w
    y = 80 + row * row_h
    
    all_svg.append(f'''
      <g id="{title.replace(' ', '_')}" transform="translate({x}, {y})">
        <text x="0" y="-12" font-family="'Plus Jakarta Sans', Inter, sans-serif" font-size="16" font-weight="700" fill="#0F172A">{idx+1}. {title}</text>
        <g id="Frame" filter="drop-shadow(0 8px 16px rgba(0,0,0,0.1))">
          {func()}
        </g>
      </g>
    ''')

all_svg.append('</svg>')

canvas_path = os.path.join(output_dir, "carecycle_all_screens_figma_canvas.svg")
with open(canvas_path, "w", encoding="utf-8") as f:
    f.write("\n".join(all_svg))

print("Successfully generated all Figma SVG artboards!")
