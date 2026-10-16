export const localImageAssets = [
  { label: 'Pernikahan di taman', value: '/images/wedding-garden.jpg' },
  { label: 'Acara corporate', value: '/images/corporate-event.jpg' },
  { label: 'Wisuda', value: '/images/graduation.jpg' },
  { label: 'Event organizer', value: '/images/event-organizer.jpg' },
  { label: 'Yearbook', value: '/images/yearbook.jpg' },
  { label: 'Produksi foto dan video', value: '/images/production.jpg' },
  { label: 'Pernikahan saat senja', value: '/images/wedding-sunset.jpg' },
  { label: 'Cerita Abadi nan Jaya', value: '/images/about-team.jpg' },
]

export const localImages = {
  wedding: '/images/wedding-garden.jpg',
  corporate: '/images/corporate-event.jpg',
  graduation: '/images/graduation.jpg',
  organizing: '/images/event-organizer.jpg',
  yearbook: '/images/yearbook.jpg',
  production: '/images/production.jpg',
  weddingSunset: '/images/wedding-sunset.jpg',
  about: '/images/about-team.jpg',
}

export const demoCategories = [
  { id: 'wedding', name: 'Wedding', slug: 'wedding', description: 'Hari istimewa, dirancang sepenuh hati.', icon: 'Heart', sort_order: 1 },
  { id: 'event', name: 'Event & Corporate', slug: 'event', description: 'Acara bermakna untuk setiap brand.', icon: 'BriefcaseBusiness', sort_order: 2 },
  { id: 'graduation', name: 'Graduation', slug: 'graduation', description: 'Perayaan pencapaian yang membanggakan.', icon: 'GraduationCap', sort_order: 3 },
  { id: 'organizing', name: 'Event Organizer', slug: 'organizing', description: 'Dari ide menjadi pengalaman tak terlupakan.', icon: 'Sparkles', sort_order: 4 },
  { id: 'yearbook', name: 'Yearbook', slug: 'yearbook', description: 'Cerita satu angkatan, dalam satu kenangan.', icon: 'BookOpen', sort_order: 5 },
]

export const demoServices = [
  { id: 'wedding-planning', category_id: 'wedding', title: 'Wedding Planning', slug: 'wedding-planning', summary: 'Hari bahagia yang terasa begitu personal.', description: 'Tim kami merangkai setiap detail hari pernikahan dengan penuh perhatian, dari konsep hingga momen terakhir.', image_url: localImages.wedding, is_published: true, featured: true },
  { id: 'corporate-event', category_id: 'event', title: 'Corporate & Brand Event', slug: 'corporate-event', summary: 'Acara profesional yang meninggalkan kesan.', description: 'Peluncuran produk, gathering, konferensi, dan perayaan perusahaan yang dirancang strategis.', image_url: localImages.corporate, is_published: true, featured: true },
  { id: 'graduation-celebration', category_id: 'graduation', title: 'Graduation Celebration', slug: 'graduation-celebration', summary: 'Rayakan perjalanan dan pencapaian bersama.', description: 'Konsep wisuda sekolah yang meriah dan tertata, dengan dekorasi, dokumentasi, dan produksi acara.', image_url: localImages.graduation, is_published: true, featured: true },
  { id: 'event-organizer', category_id: 'organizing', title: 'Full-Service Event Organizer', slug: 'event-organizer', summary: 'Ide terbaik, eksekusi yang tenang.', description: 'Perencanaan end-to-end untuk berbagai acara, ditangani tim berpengalaman dan vendor pilihan.', image_url: localImages.organizing, is_published: true, featured: false },
  { id: 'yearbook-story', category_id: 'yearbook', title: 'Yearbook & Graduation Book', slug: 'yearbook-story', summary: 'Satu buku untuk ribuan cerita.', description: 'Yearbook premium dari konsep kreatif, sesi foto, desain, hingga cetak berkualitas.', image_url: localImages.yearbook, is_published: true, featured: true },
  { id: 'visual-production', category_id: 'event', title: 'Photo & Video Production', slug: 'visual-production', summary: 'Momen berharga, tersimpan selamanya.', description: 'Dokumentasi foto dan video profesional untuk acara personal maupun perusahaan.', image_url: localImages.production, is_published: true, featured: false },
]

export const demoPackages = [
  { id: 'intimate-wedding', service_id: 'wedding-planning', name: 'Intimate Wedding', slug: 'intimate-wedding', description: 'Perayaan hangat hingga 150 tamu.', price: 28500000, price_label: 'Mulai dari', is_published: true, featured: true, inclusions: ['Wedding planner & coordinator', 'Dekorasi area akad dan resepsi', 'Master of ceremony', 'Dokumentasi foto 6 jam'], addons: [{ id: 'w1', name: 'Live music akustik', description: 'Duo musik untuk mengiringi resepsi.', price: 4500000 }, { id: 'w2', name: 'Videografi cinematic', description: 'Video highlight dan dokumentasi acara.', price: 6500000 }, { id: 'w3', name: 'Welcome signage custom', description: 'Papan sambut dengan desain personal.', price: 1250000 }, { id: 'w4', name: 'Lighting dekorasi', description: 'Ambient lighting untuk area resepsi.', price: 2750000 }, { id: 'w5', name: 'Photobooth cetak instan', description: 'Foto kenangan untuk tamu.', price: 3500000 }] },
  { id: 'signature-event', service_id: 'corporate-event', name: 'Signature Corporate', slug: 'signature-corporate', description: 'Pengalaman brand yang berkesan.', price: 45000000, price_label: 'Mulai dari', is_published: true, featured: true, inclusions: ['Konsep dan creative direction', 'Manajemen venue dan vendor', 'Produksi panggung dan visual', 'Koordinator hari-H'], addons: [{ id: 'e1', name: 'Hybrid event streaming', description: 'Live streaming multi-kamera.', price: 8500000 }, { id: 'e2', name: 'LED screen tambahan', description: 'Layar LED untuk presentasi dan visual.', price: 7500000 }, { id: 'e3', name: 'Sound system premium', description: 'Audio profesional sesuai kapasitas venue.', price: 5500000 }, { id: 'e4', name: 'Photo booth interaktif', description: 'Aktivasi brand dan foto digital.', price: 4500000 }, { id: 'e5', name: 'Registrasi digital', description: 'QR check-in dan rekap kehadiran.', price: 2500000 }] },
  { id: 'school-celebration', service_id: 'graduation-celebration', name: 'School Celebration', slug: 'school-celebration', description: 'Momen kelulusan penuh kebanggaan.', price: 18500000, price_label: 'Mulai dari', is_published: true, featured: false, inclusions: ['Desain panggung dan backdrop', 'MC dan rundown acara', 'Sound system standar', 'Dokumentasi foto acara'], addons: [{ id: 'g1', name: 'Photobooth wisuda', description: 'Sesi foto siswa dan keluarga.', price: 3500000 }, { id: 'g2', name: 'Videografi highlight', description: 'Video rangkuman acara kelulusan.', price: 4500000 }, { id: 'g3', name: 'Buku kenangan kelas', description: 'Yearbook custom per siswa.', price: 165000 }, { id: 'g4', name: 'Live streaming keluarga', description: 'Siaran langsung untuk keluarga jarak jauh.', price: 3000000 }, { id: 'g5', name: 'Paket sound & lighting', description: 'Audio serta pencahayaan panggung.', price: 5500000 }] },
  { id: 'yearbook-classic', service_id: 'yearbook-story', name: 'Yearbook Classic', slug: 'yearbook-classic', description: 'Desain personal, cetak premium.', price: 185000, price_label: 'Mulai dari / buku', is_published: true, featured: true, inclusions: ['Desain layout eksklusif', 'Sesi foto kelompok', 'Hard cover premium', 'Minimal 100 eksemplar'], addons: [{ id: 'yb1', name: 'Halaman tambahan', description: 'Penambahan halaman per 4 halaman.', price: 18000 }, { id: 'yb2', name: 'Video aftermovie', description: 'Video kenangan satu angkatan.', price: 4500000 }, { id: 'yb3', name: 'Packaging custom', description: 'Kemasan personal untuk setiap buku.', price: 12000 }] },
  { id: 'full-planning', service_id: 'event-organizer', name: 'Full Event Planning', slug: 'full-event-planning', description: 'Perencanaan lengkap tanpa repot.', price: 32000000, price_label: 'Mulai dari', is_published: true, featured: false, inclusions: ['Konsultasi dan perencanaan', 'Koordinasi vendor', 'Rundown dan produksi', 'Tim pelaksana di lokasi'], addons: [{ id: 'o1', name: 'LED screen & visual', description: 'Visual pendukung acara.', price: 7500000 }, { id: 'o2', name: 'Live entertainment', description: 'Penampil musik atau hiburan.', price: 5000000 }, { id: 'o3', name: 'Dokumentasi foto-video', description: 'Dokumentasi lengkap acara.', price: 6500000 }, { id: 'o4', name: 'Booth registrasi digital', description: 'Check-in peserta dan name tag.', price: 2500000 }] },
]

export const demoPortfolios = [
  { id: 'p1', title: 'A Garden Wedding', category: 'Wedding', category_id: 'wedding', description: 'Perayaan intim di tengah taman tropis.', image_url: localImages.wedding, is_published: true },
  { id: 'p2', title: 'Together, Forward', category: 'Corporate', category_id: 'event', description: 'Annual gathering dengan sentuhan modern.', image_url: localImages.corporate, is_published: true },
  { id: 'p3', title: 'Class of 2025', category: 'Graduation', category_id: 'graduation', description: 'Malam apresiasi penuh cahaya.', image_url: localImages.graduation, is_published: true },
  { id: 'p4', title: 'The Art of Gathering', category: 'Event', category_id: 'organizing', description: 'Pameran kreatif dengan alur yang intim.', image_url: localImages.organizing, is_published: true },
  { id: 'p5', title: 'Our Little Universe', category: 'Yearbook', category_id: 'yearbook', description: 'Yearbook penuh warna dan kepribadian.', image_url: localImages.yearbook, is_published: true },
  { id: 'p6', title: 'Golden Hour Vows', category: 'Wedding', category_id: 'wedding', description: 'Akad dan resepsi di bawah senja.', image_url: localImages.weddingSunset, is_published: true },
]

export const demoTestimonials = [
  { id: 't1', name: 'Nadia & Arief', role: 'Wedding client', quote: 'Semua terasa personal dan kami bisa menikmati hari tanpa memikirkan hal teknis. Timnya perhatian sekali pada detail.', rating: 5, is_published: true },
  { id: 't2', name: 'Dina Prameswari', role: 'Marketing Manager', quote: 'Acara berjalan rapi, tim responsif, dan pengalaman brand kami benar-benar terasa di setiap sudut.', rating: 5, is_published: true },
  { id: 't3', name: 'SMA Cakrawala', role: 'School partner', quote: 'Yearbook-nya jadi kenangan yang dibanggakan satu angkatan. Prosesnya pun menyenangkan untuk siswa.', rating: 5, is_published: true },
]

export const demoFaqs = [
  { id: 'f1', question: 'Seberapa awal sebaiknya saya menghubungi tim?', answer: 'Untuk pernikahan, idealnya 6–12 bulan sebelum hari acara. Untuk jenis acara lain, hubungi kami sesegera mungkin agar tanggal dan kebutuhan Anda dapat kami siapkan.', sort_order: 1, is_published: true },
  { id: 'f2', question: 'Apakah paket bisa disesuaikan?', answer: 'Tentu. Paket adalah titik awal; kami akan menyusun penawaran berdasarkan jumlah tamu, lokasi, konsep, dan kebutuhan khusus Anda.', sort_order: 2, is_published: true },
  { id: 'f3', question: 'Apakah Abadi nan Jaya melayani di luar kota?', answer: 'Ya, kami melayani berbagai kota di Indonesia. Biaya transportasi dan akomodasi akan tercantum transparan dalam penawaran.', sort_order: 3, is_published: true },
]

export const demoClients = ['SMA Cakrawala', 'Nusantara Group', 'Universitas Pertiwi', 'Ruang Cerita', 'Karya Kolektif']
export const demoContacts = [
  { id: 'c1', name: 'Alya Putri', division: 'Wedding & Personal', title: 'Wedding Consultant', phone: '6281234567890', email: 'wedding@abadinanjaya.id', is_published: true },
  { id: 'c2', name: 'Raka Mahendra', division: 'Corporate & School', title: 'Event Consultant', phone: '6281234567891', email: 'event@abadinanjaya.id', is_published: true },
]
export const demoLandingSections = [
  { id: 's1', section_key: 'hero', title: 'Setiap perayaan punya cerita.', subtitle: 'Kami hadir untuk merancang momen yang terasa dekat, indah, dan selalu diingat.', is_enabled: true, sort_order: 1 },
  { id: 's2', section_key: 'services', title: 'Satu partner untuk setiap perayaan.', is_enabled: true, sort_order: 2 },
  { id: 's3', section_key: 'packages', title: 'Awali dari yang paling sesuai.', is_enabled: true, sort_order: 3 },
  { id: 's4', section_key: 'portfolio', title: 'Cerita yang pernah kami rangkai.', is_enabled: true, sort_order: 4 },
  { id: 's5', section_key: 'about', title: 'Bukan sekadar acara.', subtitle: 'Sebuah cerita untuk dikenang.', body: 'Kami percaya momen terbaik lahir ketika semua terasa dekat dan bermakna. Sejak 2014, kami membantu keluarga, sekolah, dan brand merayakan perjalanan mereka.', is_enabled: true, sort_order: 5 },
  { id: 's6', section_key: 'testimonials', title: 'Kata mereka setelah hari istimewa.', is_enabled: true, sort_order: 6 },
  { id: 's7', section_key: 'clients', title: 'Mereka yang telah bersama kami.', is_enabled: true, sort_order: 7 },
  { id: 's8', section_key: 'faq', title: 'Pertanyaan yang sering muncul.', is_enabled: true, sort_order: 8 },
  { id: 's9', section_key: 'cta', title: 'Ada cerita yang ingin Anda rayakan?', subtitle: 'Ceritakan rencana Anda. Kami akan membantu merangkai sisanya.', cta_label: 'Mulai percakapan', cta_url: '/kontak', is_enabled: true, sort_order: 9 },
]

export const formatPrice = (amount) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(amount || 0)
export const categoryName = (id) => demoCategories.find((item) => item.id === id)?.name || 'Layanan'
