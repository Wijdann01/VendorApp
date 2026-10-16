insert into public.categories (name, slug, description, icon, sort_order, is_published) values
  ('Wedding', 'wedding', 'Hari istimewa, dirancang sepenuh hati.', 'Heart', 1, true),
  ('Event & Corporate', 'event', 'Acara bermakna untuk setiap brand.', 'BriefcaseBusiness', 2, true),
  ('Graduation', 'graduation', 'Perayaan pencapaian yang membanggakan.', 'GraduationCap', 3, true),
  ('Event Organizer', 'organizing', 'Dari ide menjadi pengalaman tak terlupakan.', 'Sparkles', 4, true),
  ('Yearbook', 'yearbook', 'Cerita satu angkatan, dalam satu kenangan.', 'BookOpen', 5, true)
on conflict (slug) do update set name = excluded.name, description = excluded.description, icon = excluded.icon, sort_order = excluded.sort_order, is_published = excluded.is_published;

insert into public.services (category_id, title, slug, summary, description, image_url, featured, sort_order, is_published)
select c.id, v.title, v.slug, v.summary, v.description, v.image_url, v.featured, v.sort_order, true
from (values
  ('wedding', 'Wedding Planning', 'wedding-planning', 'Hari bahagia yang terasa begitu personal.', 'Tim kami merangkai setiap detail hari pernikahan dengan penuh perhatian, dari konsep hingga momen terakhir.', '/images/wedding-garden.jpg', true, 1),
  ('event', 'Corporate & Brand Event', 'corporate-event', 'Acara profesional yang meninggalkan kesan.', 'Peluncuran produk, gathering, konferensi, dan perayaan perusahaan yang dirancang strategis.', '/images/corporate-event.jpg', true, 2),
  ('graduation', 'Graduation Celebration', 'graduation-celebration', 'Rayakan perjalanan dan pencapaian bersama.', 'Konsep wisuda sekolah yang meriah dan tertata, dengan dekorasi, dokumentasi, dan produksi acara.', '/images/graduation.jpg', true, 3),
  ('organizing', 'Full-Service Event Organizer', 'event-organizer', 'Ide terbaik, eksekusi yang tenang.', 'Perencanaan end-to-end untuk berbagai acara, ditangani tim berpengalaman dan vendor pilihan.', '/images/event-organizer.jpg', false, 4),
  ('yearbook', 'Yearbook & Graduation Book', 'yearbook-story', 'Satu buku untuk ribuan cerita.', 'Yearbook premium dari konsep kreatif, sesi foto, desain, hingga cetak berkualitas.', '/images/yearbook.jpg', true, 5),
  ('event', 'Photo & Video Production', 'visual-production', 'Momen berharga, tersimpan selamanya.', 'Dokumentasi foto dan video profesional untuk acara personal maupun perusahaan.', '/images/production.jpg', false, 6)
) as v(category_slug, title, slug, summary, description, image_url, featured, sort_order)
join public.categories c on c.slug = v.category_slug
on conflict (slug) do update set category_id = excluded.category_id, title = excluded.title, summary = excluded.summary, description = excluded.description, image_url = excluded.image_url, featured = excluded.featured, sort_order = excluded.sort_order, is_published = true;

insert into public.packages (service_id, name, slug, description, price, price_label, inclusions, featured, sort_order, is_published)
select s.id, v.name, v.slug, v.description, v.price, v.price_label, v.inclusions, v.featured, v.sort_order, true
from (values
  ('wedding-planning', 'Intimate Wedding', 'intimate-wedding', 'Perayaan hangat hingga 150 tamu.', 28500000, 'Mulai dari', array['Wedding planner & coordinator','Dekorasi area akad dan resepsi','Master of ceremony','Dokumentasi foto 6 jam']::text[], true, 1),
  ('corporate-event', 'Signature Corporate', 'signature-corporate', 'Pengalaman brand yang berkesan.', 45000000, 'Mulai dari', array['Konsep dan creative direction','Manajemen venue dan vendor','Produksi panggung dan visual','Koordinator hari-H']::text[], true, 2),
  ('graduation-celebration', 'School Celebration', 'school-celebration', 'Momen kelulusan penuh kebanggaan.', 18500000, 'Mulai dari', array['Desain panggung dan backdrop','MC dan rundown acara','Sound system standar','Dokumentasi foto acara']::text[], false, 3),
  ('yearbook-story', 'Yearbook Classic', 'yearbook-classic', 'Desain personal, cetak premium.', 185000, 'Mulai dari / buku', array['Desain layout eksklusif','Sesi foto kelompok','Hard cover premium','Minimal 100 eksemplar']::text[], true, 4),
  ('event-organizer', 'Full Event Planning', 'full-event-planning', 'Perencanaan lengkap tanpa repot.', 32000000, 'Mulai dari', array['Konsultasi dan perencanaan','Koordinasi vendor','Rundown dan produksi','Tim pelaksana di lokasi']::text[], false, 5)
) as v(service_slug, name, slug, description, price, price_label, inclusions, featured, sort_order)
join public.services s on s.slug = v.service_slug
on conflict (slug) do update set service_id = excluded.service_id, name = excluded.name, description = excluded.description, price = excluded.price, price_label = excluded.price_label, inclusions = excluded.inclusions, featured = excluded.featured, sort_order = excluded.sort_order, is_published = true;

insert into public.package_items (package_id, name, sort_order)
select p.id, item.name, item.ordinality::integer
from public.packages p
cross join lateral unnest(p.inclusions) with ordinality as item(name, ordinality)
on conflict (package_id, name) do update set sort_order = excluded.sort_order;

insert into public.price_list (package_id, category_id, name, description, price, price_label, sort_order, is_published)
select p.id, s.category_id, p.name, p.description, p.price, p.price_label, p.sort_order, true
from public.packages p
join public.services s on s.id = p.service_id
on conflict (package_id) where package_id is not null do update set
  category_id = excluded.category_id, name = excluded.name, description = excluded.description,
  price = excluded.price, price_label = excluded.price_label, sort_order = excluded.sort_order, is_published = true;

insert into public.addons (package_id, name, description, price, sort_order, is_published)
select p.id, v.name, v.description, v.price, v.sort_order, true
from (values
  ('intimate-wedding', 'Live music akustik', 'Duo musik untuk mengiringi resepsi.', 4500000, 1),
  ('intimate-wedding', 'Videografi cinematic', 'Video highlight dan dokumentasi acara.', 6500000, 2),
  ('intimate-wedding', 'Welcome signage custom', 'Papan sambut dengan desain personal.', 1250000, 3),
  ('intimate-wedding', 'Lighting dekorasi', 'Ambient lighting untuk area resepsi.', 2750000, 4),
  ('intimate-wedding', 'Photobooth cetak instan', 'Foto kenangan untuk tamu.', 3500000, 5),
  ('signature-corporate', 'Hybrid event streaming', 'Live streaming multi-kamera.', 8500000, 1),
  ('signature-corporate', 'LED screen tambahan', 'Layar LED untuk presentasi dan visual.', 7500000, 2),
  ('signature-corporate', 'Sound system premium', 'Audio profesional sesuai kapasitas venue.', 5500000, 3),
  ('signature-corporate', 'Photo booth interaktif', 'Aktivasi brand dan foto digital.', 4500000, 4),
  ('signature-corporate', 'Registrasi digital', 'QR check-in dan rekap kehadiran.', 2500000, 5),
  ('school-celebration', 'Photobooth wisuda', 'Sesi foto siswa dan keluarga.', 3500000, 1),
  ('school-celebration', 'Videografi highlight', 'Video rangkuman acara kelulusan.', 4500000, 2),
  ('school-celebration', 'Buku kenangan kelas', 'Yearbook custom per siswa.', 165000, 3),
  ('school-celebration', 'Live streaming keluarga', 'Siaran langsung untuk keluarga jarak jauh.', 3000000, 4),
  ('school-celebration', 'Paket sound & lighting', 'Audio serta pencahayaan panggung.', 5500000, 5),
  ('yearbook-classic', 'Halaman tambahan', 'Penambahan halaman per 4 halaman.', 18000, 1),
  ('yearbook-classic', 'Video aftermovie', 'Video kenangan satu angkatan.', 4500000, 2),
  ('yearbook-classic', 'Packaging custom', 'Kemasan personal untuk setiap buku.', 12000, 3),
  ('full-event-planning', 'LED screen & visual', 'Visual pendukung acara.', 7500000, 1),
  ('full-event-planning', 'Live entertainment', 'Penampil musik atau hiburan.', 5000000, 2),
  ('full-event-planning', 'Dokumentasi foto-video', 'Dokumentasi lengkap acara.', 6500000, 3),
  ('full-event-planning', 'Booth registrasi digital', 'Check-in peserta dan name tag.', 2500000, 4)
) as v(package_slug, name, description, price, sort_order)
join public.packages p on p.slug = v.package_slug
on conflict (package_id, name) do update set
  description = excluded.description, price = excluded.price,
  sort_order = excluded.sort_order, is_published = true;

insert into public.portfolios (title, slug, category, category_id, description, cover_image_url, is_published, sort_order)
select v.title, v.slug, v.category, c.id, v.description, v.image_url, true, v.sort_order
from (values
  ('A Garden Wedding','a-garden-wedding','Wedding','wedding','Perayaan intim di tengah taman tropis.','/images/wedding-garden.jpg',1),
  ('Together, Forward','together-forward','Corporate','event','Annual gathering dengan sentuhan modern.','/images/corporate-event.jpg',2),
  ('Class of 2025','class-of-2025','Graduation','graduation','Malam apresiasi penuh cahaya.','/images/graduation.jpg',3),
  ('The Art of Gathering','the-art-of-gathering','Event','organizing','Pameran kreatif dengan alur yang intim.','/images/event-organizer.jpg',4),
  ('Our Little Universe','our-little-universe','Yearbook','yearbook','Yearbook penuh warna dan kepribadian.','/images/yearbook.jpg',5),
  ('Golden Hour Vows','golden-hour-vows','Wedding','wedding','Akad dan resepsi di bawah senja.','/images/wedding-sunset.jpg',6)
) as v(title, slug, category, category_slug, description, image_url, sort_order)
left join public.categories c on c.slug = v.category_slug
on conflict (slug) do update set title = excluded.title, category = excluded.category, category_id = excluded.category_id, description = excluded.description, cover_image_url = excluded.cover_image_url, is_published = true, sort_order = excluded.sort_order;

insert into public.testimonials (name, role, quote, rating, sort_order, is_published) values
  ('Nadia & Arief', 'Wedding client', 'Semua terasa personal dan kami bisa menikmati hari tanpa memikirkan hal teknis. Timnya perhatian sekali pada detail.', 5, 1, true),
  ('Dina Prameswari', 'Marketing Manager', 'Acara berjalan rapi, tim responsif, dan pengalaman brand kami benar-benar terasa di setiap sudut.', 5, 2, true),
  ('SMA Cakrawala', 'School partner', 'Yearbook-nya jadi kenangan yang dibanggakan satu angkatan. Prosesnya pun menyenangkan untuk siswa.', 5, 3, true)
on conflict do nothing;

insert into public.clients (name, sort_order, is_published) values
  ('SMA Cakrawala', 1, true), ('Nusantara Group', 2, true), ('Universitas Pertiwi', 3, true), ('Ruang Cerita', 4, true), ('Karya Kolektif', 5, true)
on conflict do nothing;

insert into public.faqs (question, answer, sort_order, is_published) values
  ('Seberapa awal sebaiknya saya menghubungi tim?', 'Untuk pernikahan, idealnya 6–12 bulan sebelum hari acara. Untuk jenis acara lain, hubungi kami sesegera mungkin agar tanggal dan kebutuhan Anda dapat kami siapkan.', 1, true),
  ('Apakah paket bisa disesuaikan?', 'Tentu. Paket adalah titik awal; kami akan menyusun penawaran berdasarkan jumlah tamu, lokasi, konsep, dan kebutuhan khusus Anda.', 2, true),
  ('Apakah Abadi nan Jaya melayani di luar kota?', 'Ya, kami melayani berbagai kota di Indonesia. Biaya transportasi dan akomodasi akan tercantum transparan dalam penawaran.', 3, true)
on conflict do nothing;

insert into public.contacts (name, title, division, phone, email, sort_order, is_published) values
  ('Alya Putri', 'Wedding Consultant', 'Wedding & Personal', '6281234567890', 'wedding@abadinanjaya.id', 1, true),
  ('Raka Mahendra', 'Event Consultant', 'Corporate & School', '6281234567891', 'event@abadinanjaya.id', 2, true)
on conflict do nothing;

insert into public.landing_sections (section_key, title, subtitle, body, is_enabled, sort_order) values
  ('hero', 'Setiap perayaan punya cerita.', 'Kami hadir untuk merancang momen yang terasa dekat, indah, dan selalu diingat.', '', true, 1),
  ('services', 'Satu partner untuk setiap perayaan.', '', '', true, 2),
  ('packages', 'Awali dari yang paling sesuai.', '', '', true, 3),
  ('portfolio', 'Cerita yang pernah kami rangkai.', '', '', true, 4),
  ('about', 'Bukan sekadar acara.', 'Sebuah cerita untuk dikenang.', 'Kami percaya momen terbaik lahir ketika semua terasa dekat dan bermakna. Sejak 2014, kami membantu keluarga, sekolah, dan brand merayakan perjalanan mereka.', true, 5),
  ('testimonials', 'Kata mereka setelah hari istimewa.', '', '', true, 6),
  ('clients', 'Mereka yang telah bersama kami.', '', '', true, 7),
  ('faq', 'Pertanyaan yang sering muncul.', '', '', true, 8),
  ('cta', 'Ada cerita yang ingin Anda rayakan?', 'Ceritakan rencana Anda. Kami akan membantu merangkai sisanya.', '', true, 9)
on conflict (section_key) do update set title = excluded.title, subtitle = excluded.subtitle, body = excluded.body, is_enabled = excluded.is_enabled, sort_order = excluded.sort_order;

insert into public.site_settings (key, value, is_public, sort_order) values
  ('brand_name', '{"brand_name":"Abadi nan Jaya"}', true, 1),
  ('whatsapp', '{"whatsapp":"6281234567890"}', true, 2),
  ('instagram', '{"instagram":"@abadinanjaya"}', true, 3),
  ('tagline', '{"tagline":"Merayakan setiap cerita"}', true, 4),
  ('seo', '{"seo_title":"Abadi nan Jaya — Merayakan setiap cerita","seo_description":"Partner terpercaya untuk momen istimewa, acara korporat, wisuda, dan yearbook."}', true, 5)
on conflict (key) do update set value = excluded.value, is_public = excluded.is_public, sort_order = excluded.sort_order;
