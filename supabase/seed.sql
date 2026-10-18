insert into public.categories (name, slug, description, icon, sort_order, is_published) values
  ('Perpisahan & Wisuda', 'graduation', 'Rayakan perjalanan satu angkatan dan awal langkah berikutnya.', 'GraduationCap', 1, true),
  ('Yearbook', 'yearbook', 'Kenangan satu angkatan, dirangkai jadi cerita yang bisa dibuka lagi.', 'BookOpen', 2, true),
  ('Event & Corporate', 'event', 'Acara sekolah, komunitas, dan perusahaan yang tertata.', 'BriefcaseBusiness', 3, true),
  ('Event Organizer', 'organizing', 'Dari rundown hingga hari-H, semua terkoordinasi.', 'Sparkles', 4, true),
  ('Wedding', 'wedding', 'Perayaan personal yang dirancang dengan penuh perhatian.', 'Heart', 5, true)
on conflict (slug) do update set name = excluded.name, description = excluded.description, icon = excluded.icon, sort_order = excluded.sort_order, is_published = excluded.is_published;

insert into public.services (category_id, title, slug, summary, description, image_url, featured, sort_order, is_published)
select c.id, v.title, v.slug, v.summary, v.description, v.image_url, v.featured, v.sort_order, true
from (values
  ('graduation', 'Perpisahan & Wisuda Sekolah', 'graduation-celebration', 'Rayakan perjalanan satu angkatan dengan acara yang seru dan tertata.', 'Konsep perpisahan dan wisuda sekolah dari panggung, rundown, hiburan, hingga dokumentasi—disesuaikan dengan karakter sekolah dan jumlah siswa.', '/images/graduation.jpg', true, 1),
  ('yearbook', 'Yearbook & Buku Kenangan', 'yearbook-story', 'Satu angkatan, banyak cerita, satu kenangan yang bisa dibawa pulang.', 'Produksi buku kenangan sekolah dari konsep, sesi foto, desain, pengumpulan data siswa, hingga cetak.', '/images/yearbook.jpg', true, 2),
  ('event', 'Acara Sekolah & Corporate', 'corporate-event', 'Acara besar dengan alur yang jelas dan pengalaman yang berkesan.', 'Perayaan sekolah, gathering, konferensi, peluncuran, dan acara komunitas yang dirancang sesuai tujuan dan audiens.', '/images/corporate-event.jpg', true, 3),
  ('organizing', 'Event Organizer', 'event-organizer', 'Dari ide, rundown, sampai koordinasi hari-H.', 'Tim pelaksana untuk membantu sekolah, komunitas, dan perusahaan mengelola acara dari awal hingga selesai.', '/images/event-organizer.jpg', true, 4),
  ('event', 'Produksi Foto & Video', 'visual-production', 'Dokumentasi acara yang siap dikenang dan dibagikan.', 'Dokumentasi foto, video highlight, photobooth, dan live streaming untuk acara sekolah maupun umum.', '/images/production.jpg', false, 5),
  ('wedding', 'Wedding Planning', 'wedding-planning', 'Perayaan personal yang terasa dekat dan tertata.', 'Tim kami membantu merencanakan detail pernikahan dari konsep hingga hari acara.', '/images/wedding-garden.jpg', false, 6)
) as v(category_slug, title, slug, summary, description, image_url, featured, sort_order)
join public.categories c on c.slug = v.category_slug
on conflict (slug) do update set category_id = excluded.category_id, title = excluded.title, summary = excluded.summary, description = excluded.description, image_url = excluded.image_url, featured = excluded.featured, sort_order = excluded.sort_order, is_published = true;

insert into public.packages (service_id, name, slug, description, price, price_label, inclusions, featured, sort_order, is_published)
select s.id, v.name, v.slug, v.description, v.price, v.price_label, v.inclusions, v.featured, v.sort_order, true
from (values
  ('graduation-celebration', 'Perpisahan Sekolah', 'school-celebration', 'Paket acara kelulusan yang bisa disesuaikan dengan kebutuhan sekolah.', 18500000, 'Mulai dari', array['Desain panggung dan backdrop','MC dan rundown acara','Sound system standar','Dokumentasi foto acara']::text[], true, 1),
  ('yearbook-story', 'Yearbook Satu Angkatan', 'yearbook-classic', 'Dari sesi foto sampai buku kenangan siap dibagikan.', 185000, 'Mulai dari / buku', array['Desain layout eksklusif','Sesi foto kelompok','Hard cover premium','Minimal 100 eksemplar']::text[], true, 2),
  ('corporate-event', 'Signature Event', 'signature-corporate', 'Produksi acara sekolah, komunitas, atau perusahaan.', 45000000, 'Mulai dari', array['Konsep dan creative direction','Manajemen venue dan vendor','Produksi panggung dan visual','Koordinator hari-H']::text[], true, 3),
  ('event-organizer', 'Full Event Planning', 'full-event-planning', 'Perencanaan lengkap tanpa repot.', 32000000, 'Mulai dari', array['Konsultasi dan perencanaan','Koordinasi vendor','Rundown dan produksi','Tim pelaksana di lokasi']::text[], false, 4),
  ('wedding-planning', 'Intimate Wedding', 'intimate-wedding', 'Perayaan hangat hingga 150 tamu.', 28500000, 'Mulai dari', array['Wedding planner & coordinator','Dekorasi area akad dan resepsi','Master of ceremony','Dokumentasi foto 6 jam']::text[], false, 5)
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
  ('Malam Perpisahan Angkatan 2025','class-of-2025','Perpisahan & Wisuda','graduation','Satu malam untuk merayakan perjalanan dan teman-teman seperjuangan.','/images/graduation.jpg',1),
  ('Yearbook: Our Little Universe','our-little-universe','Yearbook','yearbook','Cerita satu angkatan dalam buku kenangan penuh warna.','/images/yearbook.jpg',2),
  ('Together, Forward','together-forward','Event & Corporate','event','Gathering dengan panggung, visual, dan alur acara yang rapi.','/images/corporate-event.jpg',3),
  ('The Art of Gathering','the-art-of-gathering','Event','organizing','Pameran kreatif dengan alur yang intim.','/images/event-organizer.jpg',4),
  ('A Garden Wedding','a-garden-wedding','Wedding','wedding','Perayaan intim di tengah taman tropis.','/images/wedding-garden.jpg',5),
  ('Golden Hour Vows','golden-hour-vows','Wedding','wedding','Akad dan resepsi di bawah senja.','/images/wedding-sunset.jpg',6)
) as v(title, slug, category, category_slug, description, image_url, sort_order)
left join public.categories c on c.slug = v.category_slug
on conflict (slug) do update set title = excluded.title, category = excluded.category, category_id = excluded.category_id, description = excluded.description, cover_image_url = excluded.cover_image_url, is_published = true, sort_order = excluded.sort_order;

insert into public.testimonials (name, role, quote, rating, sort_order, is_published) values
  ('SMA Cakrawala', 'Panitia perpisahan sekolah', 'Dari persiapan sampai acara selesai, timnya sigap. Anak-anak menikmati malam perpisahan dan guru bisa fokus mendampingi mereka.', 5, 1, true),
  ('Universitas Pertiwi', 'Panitia wisuda', 'Alur acara, panggung, dan dokumentasi tertata baik. Koordinasi dengan panitia kampus juga berjalan lancar.', 5, 2, true),
  ('Dina Prameswari', 'Marketing Manager', 'Acara berjalan rapi, tim responsif, dan pengalaman brand kami benar-benar terasa di setiap sudut.', 5, 3, true)
on conflict do nothing;

insert into public.clients (name, sort_order, is_published) values
  ('SMA Cakrawala', 1, true), ('Nusantara Group', 2, true), ('Universitas Pertiwi', 3, true), ('Ruang Cerita', 4, true), ('Karya Kolektif', 5, true)
on conflict do nothing;

insert into public.faqs (question, answer, sort_order, is_published) values
  ('Kapan sebaiknya sekolah mulai merencanakan acara perpisahan?', 'Idealnya hubungi kami 3–6 bulan sebelum acara agar waktu untuk menyusun konsep, anggaran, venue, dan koordinasi sekolah cukup. Kami tetap terbuka untuk kebutuhan dengan jadwal lebih singkat.', 1, true),
  ('Apakah paket bisa disesuaikan?', 'Tentu. Paket adalah titik awal; kami akan menyusun penawaran berdasarkan jumlah tamu, lokasi, konsep, dan kebutuhan khusus Anda.', 2, true),
  ('Apakah Abadi nan Jaya melayani di luar kota?', 'Ya, kami melayani berbagai kota di Indonesia. Biaya transportasi dan akomodasi akan tercantum transparan dalam penawaran.', 3, true)
on conflict do nothing;

insert into public.contacts (name, title, division, phone, email, sort_order, is_published) values
  ('Raka Mahendra', 'Konsultan Acara Sekolah', 'Sekolah & Event', '6281234567891', 'event@abadinanjaya.id', 1, true),
  ('Alya Putri', 'Wedding Consultant', 'Wedding & Personal', '6281234567890', 'wedding@abadinanjaya.id', 2, true)
on conflict do nothing;

insert into public.landing_sections (section_key, title, subtitle, body, is_enabled, sort_order) values
  ('hero', 'Perpisahan sekolah, jadi cerita satu angkatan.', 'Panggung, hiburan, rundown, dan dokumentasi kami siapkan. Sekolah dan siswa tinggal menikmati momennya.', '', true, 1),
  ('services', 'Partner acara untuk sekolah dan banyak cerita lain.', '', '', true, 2),
  ('packages', 'Paket perpisahan yang bisa disesuaikan.', 'Mulai dari kebutuhan inti sampai tambahan panggung, photobooth, dokumentasi, dan yearbook.', '', true, 3),
  ('portfolio', 'Momen sekolah yang pernah kami rayakan.', '', '', true, 4),
  ('about', 'Acara tertata. Semua bisa ikut merayakan.', 'Untuk sekolah, komunitas, dan perusahaan.', 'Abadi nan Jaya membantu panitia mengelola konsep, produksi, dan koordinasi acara. Fokus utama kami adalah perayaan sekolah—mulai dari perpisahan dan wisuda hingga buku kenangan—serta berbagai acara komunitas, corporate, dan personal.', true, 5),
  ('testimonials', 'Cerita dari panitia dan sekolah.', '', '', true, 6),
  ('clients', 'Mereka yang telah bersama kami.', '', '', true, 7),
  ('faq', 'Pertanyaan yang sering muncul.', '', '', true, 8),
  ('cta', 'Sedang menyiapkan perpisahan sekolah?', 'Ceritakan jumlah siswa, rencana acara, dan kebutuhan sekolah. Kami bantu susun langkah berikutnya.', '', true, 9)
on conflict (section_key) do update set title = excluded.title, subtitle = excluded.subtitle, body = excluded.body, is_enabled = excluded.is_enabled, sort_order = excluded.sort_order;

insert into public.site_settings (key, value, is_public, sort_order) values
  ('brand_name', '{"brand_name":"Abadi nan Jaya"}', true, 1),
  ('whatsapp', '{"whatsapp":"6281234567890"}', true, 2),
  ('instagram', '{"instagram":"@abadinanjaya"}', true, 3),
  ('tagline', '{"tagline":"Merayakan setiap cerita"}', true, 4),
  ('seo', '{"seo_title":"Abadi nan Jaya — Merayakan setiap cerita","seo_description":"Partner terpercaya untuk momen istimewa, acara korporat, wisuda, dan yearbook."}', true, 5)
on conflict (key) do update set value = excluded.value, is_public = excluded.is_public, sort_order = excluded.sort_order;
