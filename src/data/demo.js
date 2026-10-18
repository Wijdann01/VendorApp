export const localImageAssets = [
  { label: 'Perpisahan & wisuda sekolah', value: '/images/graduation.jpg' },
  { label: 'Yearbook', value: '/images/yearbook.jpg' },
  { label: 'Acara corporate', value: '/images/corporate-event.jpg' },
  { label: 'Event organizer', value: '/images/event-organizer.jpg' },
  { label: 'Produksi foto dan video', value: '/images/production.jpg' },
  { label: 'Pernikahan di taman', value: '/images/wedding-garden.jpg' },
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
  { id: 'graduation', name: 'Perpisahan & Wisuda', slug: 'graduation', description: 'Rayakan perjalanan satu angkatan dan awal langkah berikutnya.', icon: 'GraduationCap', sort_order: 1 },
  { id: 'yearbook', name: 'Yearbook', slug: 'yearbook', description: 'Kenangan satu angkatan, dirangkai jadi cerita yang bisa dibuka lagi.', icon: 'BookOpen', sort_order: 2 },
  { id: 'event', name: 'Event & Corporate', slug: 'event', description: 'Acara sekolah, komunitas, dan perusahaan yang tertata.', icon: 'BriefcaseBusiness', sort_order: 3 },
  { id: 'organizing', name: 'Event Organizer', slug: 'organizing', description: 'Dari rundown hingga hari-H, semua terkoordinasi.', icon: 'Sparkles', sort_order: 4 },
  { id: 'wedding', name: 'Wedding', slug: 'wedding', description: 'Perayaan personal yang dirancang dengan penuh perhatian.', icon: 'Heart', sort_order: 5 },
]

export const demoServices = [
  { id: 'graduation-celebration', category_id: 'graduation', title: 'Perpisahan & Wisuda Sekolah', slug: 'graduation-celebration', summary: 'Rayakan perjalanan satu angkatan dengan acara yang seru dan tertata.', description: 'Konsep perpisahan dan wisuda sekolah dari panggung, rundown, hiburan, hingga dokumentasi—disesuaikan dengan karakter sekolah dan jumlah siswa.', image_url: localImages.graduation, is_published: true, featured: true },
  { id: 'yearbook-story', category_id: 'yearbook', title: 'Yearbook & Buku Kenangan', slug: 'yearbook-story', summary: 'Satu angkatan, banyak cerita, satu kenangan yang bisa dibawa pulang.', description: 'Produksi buku kenangan sekolah dari konsep, sesi foto, desain, pengumpulan data siswa, hingga cetak.', image_url: localImages.yearbook, is_published: true, featured: true },
  { id: 'corporate-event', category_id: 'event', title: 'Acara Sekolah & Corporate', slug: 'corporate-event', summary: 'Acara besar dengan alur yang jelas dan pengalaman yang berkesan.', description: 'Perayaan sekolah, gathering, konferensi, peluncuran, dan acara komunitas yang dirancang sesuai tujuan dan audiens.', image_url: localImages.corporate, is_published: true, featured: true },
  { id: 'event-organizer', category_id: 'organizing', title: 'Event Organizer', slug: 'event-organizer', summary: 'Dari ide, rundown, sampai koordinasi hari-H.', description: 'Tim pelaksana untuk membantu sekolah, komunitas, dan perusahaan mengelola acara dari awal hingga selesai.', image_url: localImages.organizing, is_published: true, featured: true },
  { id: 'visual-production', category_id: 'event', title: 'Produksi Foto & Video', slug: 'visual-production', summary: 'Dokumentasi acara yang siap dikenang dan dibagikan.', description: 'Dokumentasi foto, video highlight, photobooth, dan live streaming untuk acara sekolah maupun umum.', image_url: localImages.production, is_published: true, featured: false },
  { id: 'wedding-planning', category_id: 'wedding', title: 'Wedding Planning', slug: 'wedding-planning', summary: 'Perayaan personal yang terasa dekat dan tertata.', description: 'Tim kami membantu merencanakan detail pernikahan dari konsep hingga hari acara.', image_url: localImages.wedding, is_published: true, featured: false },
]

export const demoPackages = [
  { id: 'intimate-wedding', service_id: 'wedding-planning', name: 'Intimate Wedding', slug: 'intimate-wedding', description: 'Perayaan hangat hingga 150 tamu.', price: 28500000, price_label: 'Mulai dari', is_published: true, featured: false, inclusions: ['Wedding planner & coordinator', 'Dekorasi area akad dan resepsi', 'Master of ceremony', 'Dokumentasi foto 6 jam'], addons: [{ id: 'w1', name: 'Live music akustik', description: 'Duo musik untuk mengiringi resepsi.', price: 4500000 }, { id: 'w2', name: 'Videografi cinematic', description: 'Video highlight dan dokumentasi acara.', price: 6500000 }, { id: 'w3', name: 'Welcome signage custom', description: 'Papan sambut dengan desain personal.', price: 1250000 }, { id: 'w4', name: 'Lighting dekorasi', description: 'Ambient lighting untuk area resepsi.', price: 2750000 }, { id: 'w5', name: 'Photobooth cetak instan', description: 'Foto kenangan untuk tamu.', price: 3500000 }] },
  { id: 'signature-event', service_id: 'corporate-event', name: 'Signature Event', slug: 'signature-corporate', description: 'Produksi acara sekolah, komunitas, atau perusahaan.', price: 45000000, price_label: 'Mulai dari', is_published: true, featured: true, inclusions: ['Konsep dan creative direction', 'Manajemen venue dan vendor', 'Produksi panggung dan visual', 'Koordinator hari-H'], addons: [{ id: 'e1', name: 'Hybrid event streaming', description: 'Live streaming multi-kamera.', price: 8500000 }, { id: 'e2', name: 'LED screen tambahan', description: 'Layar LED untuk presentasi dan visual.', price: 7500000 }, { id: 'e3', name: 'Sound system premium', description: 'Audio profesional sesuai kapasitas venue.', price: 5500000 }, { id: 'e4', name: 'Photo booth interaktif', description: 'Aktivasi brand dan foto digital.', price: 4500000 }, { id: 'e5', name: 'Registrasi digital', description: 'QR check-in dan rekap kehadiran.', price: 2500000 }] },
  { id: 'school-celebration', service_id: 'graduation-celebration', name: 'Perpisahan Sekolah', slug: 'school-celebration', description: 'Paket acara kelulusan yang bisa disesuaikan dengan kebutuhan sekolah.', price: 18500000, price_label: 'Mulai dari', is_published: true, featured: true, inclusions: ['Desain panggung dan backdrop', 'MC dan rundown acara', 'Sound system standar', 'Dokumentasi foto acara'], addons: [{ id: 'g1', name: 'Photobooth wisuda', description: 'Sesi foto siswa dan keluarga.', price: 3500000 }, { id: 'g2', name: 'Videografi highlight', description: 'Video rangkuman acara kelulusan.', price: 4500000 }, { id: 'g3', name: 'Buku kenangan kelas', description: 'Yearbook custom per siswa.', price: 165000 }, { id: 'g4', name: 'Live streaming keluarga', description: 'Siaran langsung untuk keluarga jarak jauh.', price: 3000000 }, { id: 'g5', name: 'Paket sound & lighting', description: 'Audio serta pencahayaan panggung.', price: 5500000 }] },
  { id: 'yearbook-classic', service_id: 'yearbook-story', name: 'Yearbook Satu Angkatan', slug: 'yearbook-classic', description: 'Dari sesi foto sampai buku kenangan siap dibagikan.', price: 185000, price_label: 'Mulai dari / buku', is_published: true, featured: true, inclusions: ['Desain layout eksklusif', 'Sesi foto kelompok', 'Hard cover premium', 'Minimal 100 eksemplar'], addons: [{ id: 'yb1', name: 'Halaman tambahan', description: 'Penambahan halaman per 4 halaman.', price: 18000 }, { id: 'yb2', name: 'Video aftermovie', description: 'Video kenangan satu angkatan.', price: 4500000 }, { id: 'yb3', name: 'Packaging custom', description: 'Kemasan personal untuk setiap buku.', price: 12000 }] },
  { id: 'full-planning', service_id: 'event-organizer', name: 'Full Event Planning', slug: 'full-event-planning', description: 'Perencanaan lengkap tanpa repot.', price: 32000000, price_label: 'Mulai dari', is_published: true, featured: false, inclusions: ['Konsultasi dan perencanaan', 'Koordinasi vendor', 'Rundown dan produksi', 'Tim pelaksana di lokasi'], addons: [{ id: 'o1', name: 'LED screen & visual', description: 'Visual pendukung acara.', price: 7500000 }, { id: 'o2', name: 'Live entertainment', description: 'Penampil musik atau hiburan.', price: 5000000 }, { id: 'o3', name: 'Dokumentasi foto-video', description: 'Dokumentasi lengkap acara.', price: 6500000 }, { id: 'o4', name: 'Booth registrasi digital', description: 'Check-in peserta dan name tag.', price: 2500000 }] },
]

export const demoPortfolios = [
  { id: 'p3', title: 'Malam Perpisahan Angkatan 2025', category: 'Perpisahan & Wisuda', category_id: 'graduation', description: 'Satu malam untuk merayakan perjalanan dan teman-teman seperjuangan.', image_url: localImages.graduation, is_published: true },
  { id: 'p5', title: 'Yearbook: Our Little Universe', category: 'Yearbook', category_id: 'yearbook', description: 'Cerita satu angkatan dalam buku kenangan penuh warna.', image_url: localImages.yearbook, is_published: true },
  { id: 'p2', title: 'Together, Forward', category: 'Event & Corporate', category_id: 'event', description: 'Gathering dengan panggung, visual, dan alur acara yang rapi.', image_url: localImages.corporate, is_published: true },
  { id: 'p4', title: 'The Art of Gathering', category: 'Event', category_id: 'organizing', description: 'Pameran kreatif dengan alur yang intim.', image_url: localImages.organizing, is_published: true },
  { id: 'p1', title: 'A Garden Wedding', category: 'Wedding', category_id: 'wedding', description: 'Perayaan intim di tengah taman tropis.', image_url: localImages.wedding, is_published: true },
  { id: 'p6', title: 'Golden Hour Vows', category: 'Wedding', category_id: 'wedding', description: 'Akad dan resepsi di bawah senja.', image_url: localImages.weddingSunset, is_published: true },
]

export const demoTestimonials = [
  { id: 't3', name: 'SMA Cakrawala', role: 'Panitia perpisahan sekolah', quote: 'Dari persiapan sampai acara selesai, timnya sigap. Anak-anak menikmati malam perpisahan dan guru bisa fokus mendampingi mereka.', rating: 5, is_published: true },
  { id: 't4', name: 'Universitas Pertiwi', role: 'Panitia wisuda', quote: 'Alur acara, panggung, dan dokumentasi tertata baik. Koordinasi dengan panitia kampus juga berjalan lancar.', rating: 5, is_published: true },
  { id: 't2', name: 'Dina Prameswari', role: 'Marketing Manager', quote: 'Acara berjalan rapi, tim responsif, dan pengalaman brand kami benar-benar terasa di setiap sudut.', rating: 5, is_published: true },
]

export const demoFaqs = [
  { id: 'f1', question: 'Kapan sebaiknya sekolah mulai merencanakan acara perpisahan?', answer: 'Idealnya hubungi kami 3–6 bulan sebelum acara agar waktu untuk menyusun konsep, anggaran, venue, dan koordinasi sekolah cukup. Kami tetap terbuka untuk kebutuhan dengan jadwal lebih singkat.', sort_order: 1, is_published: true },
  { id: 'f2', question: 'Apakah paket bisa disesuaikan?', answer: 'Tentu. Paket adalah titik awal; kami akan menyusun penawaran berdasarkan jumlah tamu, lokasi, konsep, dan kebutuhan khusus Anda.', sort_order: 2, is_published: true },
  { id: 'f3', question: 'Apakah Abadi nan Jaya melayani di luar kota?', answer: 'Ya, kami melayani berbagai kota di Indonesia. Biaya transportasi dan akomodasi akan tercantum transparan dalam penawaran.', sort_order: 3, is_published: true },
]

export const demoClients = ['SMA Cakrawala', 'Nusantara Group', 'Universitas Pertiwi', 'Ruang Cerita', 'Karya Kolektif']
export const demoContacts = [
  { id: 'c2', name: 'Raka Mahendra', division: 'Sekolah & Event', title: 'Konsultan Acara Sekolah', phone: '6281234567891', email: 'event@abadinanjaya.id', is_published: true },
  { id: 'c1', name: 'Alya Putri', division: 'Wedding & Personal', title: 'Wedding Consultant', phone: '6281234567890', email: 'wedding@abadinanjaya.id', is_published: true },
]
export const demoLandingSections = [
  { id: 's1', section_key: 'hero', title: 'Perpisahan sekolah, jadi cerita satu angkatan.', subtitle: 'Panggung, hiburan, rundown, dan dokumentasi kami siapkan. Sekolah dan siswa tinggal menikmati momennya.', image_url: localImages.graduation, cta_label: 'Rencanakan acara sekolah', cta_url: '/booking', is_enabled: true, sort_order: 1 },
  { id: 's2', section_key: 'services', title: 'Partner acara untuk sekolah dan banyak cerita lain.', is_enabled: true, sort_order: 2 },
  { id: 's3', section_key: 'packages', title: 'Paket perpisahan yang bisa disesuaikan.', subtitle: 'Mulai dari kebutuhan inti sampai tambahan panggung, photobooth, dokumentasi, dan yearbook.', is_enabled: true, sort_order: 3 },
  { id: 's4', section_key: 'portfolio', title: 'Momen sekolah yang pernah kami rayakan.', is_enabled: true, sort_order: 4 },
  { id: 's5', section_key: 'about', title: 'Acara tertata. Semua bisa ikut merayakan.', subtitle: 'Untuk sekolah, komunitas, dan perusahaan.', body: 'Abadi nan Jaya membantu panitia mengelola konsep, produksi, dan koordinasi acara. Fokus utama kami adalah perayaan sekolah—mulai dari perpisahan dan wisuda hingga buku kenangan—serta berbagai acara komunitas, corporate, dan personal.', is_enabled: true, sort_order: 5 },
  { id: 's6', section_key: 'testimonials', title: 'Cerita dari panitia dan sekolah.', is_enabled: true, sort_order: 6 },
  { id: 's7', section_key: 'clients', title: 'Mereka yang telah bersama kami.', is_enabled: true, sort_order: 7 },
  { id: 's8', section_key: 'faq', title: 'Pertanyaan yang sering muncul.', is_enabled: true, sort_order: 8 },
  { id: 's9', section_key: 'cta', title: 'Sedang menyiapkan perpisahan sekolah?', subtitle: 'Ceritakan jumlah siswa, rencana acara, dan kebutuhan sekolah. Kami bantu susun langkah berikutnya.', cta_label: 'Diskusikan acara sekolah', cta_url: '/booking', is_enabled: true, sort_order: 9 },
]

export const formatPrice = (amount) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(amount || 0)
export const categoryName = (id) => demoCategories.find((item) => item.id === id)?.name || 'Layanan'
