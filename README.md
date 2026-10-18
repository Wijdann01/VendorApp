# Abadi nan Jaya

Website katalog layanan event dan wedding dengan dashboard admin. Dibangun menggunakan Vue 3, Vite, Vue Router, Pinia, Tailwind CSS 4, Supabase Auth, PostgreSQL, Storage, dan RLS. Bahasa antarmuka: Indonesia.

## Struktur proyek

```text
.
├── public/
│   ├── images/                             # foto default lokal yang digunakan situs
│   └── _redirects                         # fallback SPA untuk Netlify
├── src/
│   ├── assets/
│   ├── components/                        # navigasi, footer, toast
│   ├── composables/                       # notifikasi
│   ├── data/demo.js                       # konten preview tanpa koneksi Supabase
│   ├── lib/supabase.js                    # client dan validasi konfigurasi
│   ├── router/index.js                    # halaman publik dan guard admin
│   ├── stores/site.js                     # state konten publik (Pinia)
│   ├── views/
│   │   ├── HomeView.vue
│   │   ├── CatalogView.vue
│   │   ├── ServiceDetailView.vue
│   │   ├── PortfolioView.vue
│   │   ├── PriceListView.vue
│   │   ├── ContactView.vue
│   │   ├── AboutView.vue
│   │   ├── AdminLoginView.vue
│   │   ├── BookingView.vue
│   │   └── AdminView.vue
│   ├── App.vue
│   ├── main.js
│   ├── event-theme.css
│   └── style.css
├── supabase/
│   ├── migrations/
│   │   ├── 202610160001_initial_schema.sql
│   │   ├── 202610160002_event_booking_fields.sql
│   │   ├── 202610160003_role_permissions.sql
│   │   ├── 202610160004_local_image_assets.sql
│   │   └── 202610160005_school_event_focus.sql
│   └── seed.sql
├── .env.example
└── vite.config.js
```

## Skema database

| Tabel | Fungsi |
| --- | --- |
| `categories` | Kategori Wedding, Event, Graduation, Organizing, Yearbook |
| `services` | Detail layanan, kategori, foto, SEO, publikasi |
| `packages` | Harga, isi, status publikasi, urutan paket |
| `package_items` | Item yang termasuk di dalam paket |
| `addons` | Layanan tambahan yang dapat dipilih |
| `portfolios` | Cerita portofolio dan cover |
| `portfolio_media` | Media foto/video untuk portofolio |
| `contacts` | Kontak person, divisi, WhatsApp, email |
| `testimonials` | Testimoni klien dan rating |
| `clients` | Logo/nama klien atau partner |
| `faqs` | Pertanyaan dan jawaban |
| `inquiries` | Pesan dan detail booking calon klien/instansi, paket, add-on, status, catatan internal |
| `price_list` | Baris daftar harga publik terpisah bila diperlukan |
| `site_settings` | Brand, nomor WhatsApp, tema, sosial, metadata |
| `landing_sections` | Konten, status tampil, urutan section landing |
| `profiles` | Profil Auth dengan role `super_admin` atau `editor` |

Seluruh tabel mengaktifkan RLS. Konten publik hanya membaca record yang dipublikasikan (atau section yang aktif); pengunjung boleh mengirim inquiry tetapi tidak membaca atau mengubah inquiry. Fungsi pemeriksa role memakai `SECURITY DEFINER` agar pemeriksaan role tidak menimbulkan rekursi RLS.

### Hak akses admin

| Kemampuan | Editor | Super admin |
| --- | --- | --- |
| Melihat dashboard, konten, dan inquiry | Ya | Ya |
| Membuat, mengubah, dan memublikasikan konten | Ya | Ya |
| Mengubah status inquiry dan catatan internal | Ya | Ya |
| Mengubah detail booking inquiry | Tidak | Ya |
| Menghapus konten utama atau inquiry | Tidak | Ya |
| Menambah/menghapus item isi paket dan add-on saat mengelola paket | Ya | Ya |
| Mengunggah atau mengganti media portofolio | Ya | Ya |
| Menghapus file/media portofolio | Tidak | Ya |
| Mengubah pengaturan situs | Tidak | Ya |
| Melihat daftar akun dan mengubah role | Tidak | Ya |

Di menu **Halaman utama**, admin dapat menambahkan bagian konten baru tanpa mengisi kode atau slug. Bagian tambahan otomatis tampil di beranda dan dapat diurutkan, disembunyikan, atau dihapus. Di formulir **Paket & harga**, isi paket dan add-on dikelola lewat baris input dengan tombol tambah/hapus, bukan format array atau teks khusus.

Pembatasan diterapkan di dashboard **dan** RLS/database, jadi menyembunyikan menu bukan satu-satunya kontrol. Editor hanya dapat mengubah status dan catatan inquiry; perubahan kolom booking lain ditolak oleh trigger database. Editor tidak dapat menghapus konten utama. Pengelolaan akun dilakukan di menu **Akun & hak akses** oleh super admin; akun Supabase Auth tetap dibuat/diundang melalui Supabase Dashboard. Sistem mencegah penghapusan atau penurunan role super admin terakhir.

## Menjalankan lokal

Persyaratan: Node.js 20.19+ (atau 22.12+) dan npm.

```bash
npm install
npm run dev
```

Tanpa konfigurasi Supabase situs berjalan memakai data demo. Inquiry preview disimpan pada `localStorage` browser; perubahan konten dashboard preview hanya tersimpan selama sesi aplikasi, bukan sebagai database permanen. Autentikasi dan upload media memerlukan Supabase yang aktif.

## Setup Supabase

1. Buat proyek Supabase, lalu salin `.env.example` menjadi `.env.local`.
2. Isi `VITE_SUPABASE_URL` dengan **Project URL dasar** (contoh `https://project-ref.supabase.co`), dan `VITE_SUPABASE_ANON_KEY` dari **Project Settings → API**. Jangan isi URL dengan `/rest/v1` dan jangan pernah menaruh `service_role` key di frontend. Client menghapus akhiran `/rest/v1` jika URL tersebut tidak sengaja ikut disalin.
3. Jalankan kelima migration dalam urutan nama dan seed melalui Supabase CLI dari direktori proyek:

   ```bash
   npx supabase login
   npx supabase link --project-ref <project-ref>
   npx supabase migration up
   npx supabase db execute --file supabase/seed.sql
   ```

   Migration pertama membuat tabel dan RLS, migration kedua menambahkan detail booking, migration ketiga membatasi hak akses editor/super admin, migration keempat mengganti foto contoh di database dengan aset lokal, dan migration kelima memprioritaskan acara sekolah/perpisahan pada konten contoh. Migration kelima hanya mengganti teks bawaan yang belum dikustomisasi; urutan layanan dan paket contoh disusun ulang untuk menonjolkan wisuda, yearbook, dan acara sekolah. Untuk menjalankan Supabase lokal dari awal (perintah ini membangun ulang database lokal):

   ```bash
   npx supabase start
   npx supabase db reset
   ```

   Jika Supabase CLI belum tersedia, buka SQL Editor dashboard dan jalankan seluruh file di `supabase/migrations/` secara berurutan, kemudian jalankan `supabase/seed.sql`. Pada database existing yang sudah menerapkan migration 001–004, jalankan migration 005 untuk memperbarui urutan dan teks konten bawaan.
4. Buat akun super admin pertama melalui **Authentication → Users → Add user**. Trigger akan membuat profil dengan role `editor`.
5. Untuk menjadikan akun pertama sebagai super admin, jalankan SQL berikut di SQL Editor dengan email akun yang Anda buat:

   ```sql
   update public.profiles
   set role = 'super_admin'
   where id = (
     select id from auth.users where email = 'admin@domain-anda.id'
   );
   ```

   Akun admin berikutnya dapat dibuat, diubah (termasuk email, nama, kata sandi, dan role), atau dihapus dari menu **Akun & hak akses**. Setelah deployment Edge Function pada langkah berikutnya, super admin mengelola akun langsung dari dashboard.
6. Deploy Edge Function pengelola akun. Fungsi memvalidasi sesi dan role super admin di server sebelum memakai Supabase Auth Admin API; service-role key tidak pernah dikirim ke browser.

   ```bash
   npx supabase login
   npx supabase link --project-ref <project-ref>
   npx supabase functions deploy admin-users
   ```

   Pastikan secret `SUPABASE_SERVICE_ROLE_KEY` tersedia di secrets Edge Functions proyek. Jangan pernah menambahkan key ini ke `.env.local` dengan prefix `VITE_` atau ke kode frontend.
7. Jalankan `npm run dev`, lalu buka `/admin/login`. Editor dan super admin mendapat kemampuan berbeda sesuai matriks di atas.

Migration juga menyiapkan bucket `portfolio-media` dan policy Storage dengan batas upload/hapus sesuai role. Untuk inquiry aktifkan CAPTCHA/Turnstile di lapisan deployment bila form akan menerima traffic publik besar; jangan membuka tabel inquiry untuk pembacaan anonim.

Jika pengelolaan akun menampilkan pesan Edge Function tidak ditemukan/tidak dapat terhubung, pastikan CLI sudah di-link ke project ref yang sama dengan `VITE_SUPABASE_URL`, lalu deploy ulang fungsi dengan perintah di atas. Jika endpoint fungsi belum aktif, CRUD Auth dari browser memang tidak dapat dijalankan secara aman tanpa backend.

## Gambar

Foto contoh situs disimpan di `public/images/` dan dirujuk menggunakan path lokal seperti `/images/wedding-garden.jpg`. Pada form admin, pilih file gambar dari perangkat melalui pemilih berkas; saat Supabase dikonfigurasi, gambar diunggah ke bucket `portfolio-media` dan URL hasil unggahan disimpan ke database secara otomatis. Migration 004 memperbarui gambar data contoh pada database yang sudah ada. Tanpa Supabase, pratinjau unggahan tersedia di sesi demo saja dan tidak disimpan permanen.

## Halaman dan fitur

- Beranda dengan hero, layanan, paket, portofolio, testimoni, klien, FAQ, dan CTA WhatsApp.
- Katalog layanan dengan filter kategori dan pencarian; detail paket, isi paket, add-on, konsultasi WhatsApp, dan inquiry.
- Fokus utama konten adalah acara perpisahan/wisuda sekolah dan yearbook, dengan layanan corporate, komunitas, organizer, produksi, serta wedding tetap tersedia di katalog.
- Portofolio per kategori dengan lightbox.
- Daftar harga dapat dicetak/disimpan menjadi PDF dari dialog cetak browser.
- Kontak person, validasi formulir, status inquiry baru/diproses/selesai, catatan internal, dan ekspor CSV.
- Booking acara untuk pemesan personal maupun instansi/sekolah: paket, kuantitas add-on/peralatan, tanggal/jam, kapasitas tamu, venue, anggaran, tema, PIC, dan kebutuhan khusus. Permintaan booking belum mengunci tanggal atau pembayaran sampai dikonfirmasi tim.
- Dashboard ringkasan inquiry dan layanan populer, plus menu ringkasan booking terpisah untuk jumlah booking baru, acara mendatang, organisasi, status, catatan, detail add-on, dan ekspor CSV. CRUD konten kategori, layanan, paket, portofolio, testimoni, klien, FAQ, kontak, section landing, dan pengaturan. Upload foto/video multi-file memakai Supabase Storage.
- Responsive, gambar lazy-load, skeleton awal, toast, meta deskripsi dasar, dan SPA fallback.

Saat Supabase belum dikonfigurasi, tombol **Lihat preview dashboard demo** di `/admin/login` membuka dashboard dengan data contoh yang hanya bersifat preview (inquiry demo lokal memakai `localStorage`). Login Supabase tetap wajib untuk dashboard dan perubahan permanen setelah konfigurasi.

## Build dan deploy

```bash
npm run build
npm run preview
```

### Netlify

- Build command: `npm run build`
- Publish directory: `dist`
- Tambahkan `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` pada environment variables.
- File `public/_redirects` meneruskan rute SPA ke `index.html`.

### Vercel

- Framework preset: Vite; build command `npm run build`; output directory `dist`.
- Tambahkan environment variables Supabase untuk environment Preview dan Production.
- `vercel.json` menyertakan rewrite SPA.

Setelah domain deployment aktif, tambahkan URL situs dan callback `/admin/login` ke **Supabase → Authentication → URL Configuration → Site URL / Redirect URLs**. Pastikan environment variable tersedia saat proses build.
