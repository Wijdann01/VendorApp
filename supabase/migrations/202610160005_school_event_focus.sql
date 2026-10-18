update public.categories
set name = case slug
      when 'graduation' then 'Perpisahan & Wisuda'
      when 'yearbook' then 'Yearbook'
      when 'event' then 'Event & Corporate'
      when 'organizing' then 'Event Organizer'
      when 'wedding' then 'Wedding'
    end,
    description = case
      when slug = 'graduation' and description = 'Perayaan pencapaian yang membanggakan.' then 'Rayakan perjalanan satu angkatan dan awal langkah berikutnya.'
      when slug = 'yearbook' and description = 'Cerita satu angkatan, dalam satu kenangan.' then 'Kenangan satu angkatan, dirangkai jadi cerita yang bisa dibuka lagi.'
      when slug = 'event' and description = 'Acara bermakna untuk setiap brand.' then 'Acara sekolah, komunitas, dan perusahaan yang tertata.'
      when slug = 'organizing' and description = 'Dari ide menjadi pengalaman tak terlupakan.' then 'Dari rundown hingga hari-H, semua terkoordinasi.'
      when slug = 'wedding' and description = 'Hari istimewa, dirancang sepenuh hati.' then 'Perayaan personal yang dirancang dengan penuh perhatian.'
      else description
    end,
    sort_order = case slug
      when 'graduation' then 1
      when 'yearbook' then 2
      when 'event' then 3
      when 'organizing' then 4
      when 'wedding' then 5
    end
where slug in ('graduation', 'yearbook', 'event', 'organizing', 'wedding')
  and (
    (slug = 'graduation' and name = 'Graduation')
    or (slug = 'yearbook' and name = 'Yearbook')
    or (slug = 'event' and name = 'Event & Corporate')
    or (slug = 'organizing' and name = 'Event Organizer')
    or (slug = 'wedding' and name = 'Wedding')
  );

update public.services
set title = case
      when slug = 'graduation-celebration' and title = 'Graduation Celebration' then 'Perpisahan & Wisuda Sekolah'
      when slug = 'yearbook-story' and title = 'Yearbook & Graduation Book' then 'Yearbook & Buku Kenangan'
      when slug = 'corporate-event' and title = 'Corporate & Brand Event' then 'Acara Sekolah & Corporate'
      when slug = 'event-organizer' and title = 'Full-Service Event Organizer' then 'Event Organizer'
      when slug = 'visual-production' and title = 'Photo & Video Production' then 'Produksi Foto & Video'
      else title
    end,
    summary = case
      when slug = 'graduation-celebration' and summary = 'Rayakan perjalanan dan pencapaian bersama.' then 'Rayakan perjalanan satu angkatan dengan acara yang seru dan tertata.'
      when slug = 'yearbook-story' and summary = 'Satu buku untuk ribuan cerita.' then 'Satu angkatan, banyak cerita, satu kenangan yang bisa dibawa pulang.'
      when slug = 'corporate-event' and summary = 'Acara profesional yang meninggalkan kesan.' then 'Acara besar dengan alur yang jelas dan pengalaman yang berkesan.'
      when slug = 'event-organizer' and summary = 'Ide terbaik, eksekusi yang tenang.' then 'Dari ide, rundown, sampai koordinasi hari-H.'
      when slug = 'visual-production' and summary = 'Momen berharga, tersimpan selamanya.' then 'Dokumentasi acara yang siap dikenang dan dibagikan.'
      when slug = 'wedding-planning' and summary = 'Hari bahagia yang terasa begitu personal.' then 'Perayaan personal yang terasa dekat dan tertata.'
      else summary
    end,
    description = case
      when slug = 'graduation-celebration' and description = 'Konsep wisuda sekolah yang meriah dan tertata, dengan dekorasi, dokumentasi, dan produksi acara.' then 'Konsep perpisahan dan wisuda sekolah dari panggung, rundown, hiburan, hingga dokumentasi—disesuaikan dengan karakter sekolah dan jumlah siswa.'
      when slug = 'yearbook-story' and description = 'Yearbook premium dari konsep kreatif, sesi foto, desain, hingga cetak berkualitas.' then 'Produksi buku kenangan sekolah dari konsep, sesi foto, desain, pengumpulan data siswa, hingga cetak.'
      when slug = 'corporate-event' and description = 'Peluncuran produk, gathering, konferensi, dan perayaan perusahaan yang dirancang strategis.' then 'Perayaan sekolah, gathering, konferensi, peluncuran, dan acara komunitas yang dirancang sesuai tujuan dan audiens.'
      when slug = 'event-organizer' and description = 'Perencanaan end-to-end untuk berbagai acara, ditangani tim berpengalaman dan vendor pilihan.' then 'Tim pelaksana untuk membantu sekolah, komunitas, dan perusahaan mengelola acara dari awal hingga selesai.'
      when slug = 'visual-production' and description = 'Dokumentasi foto dan video profesional untuk acara personal maupun perusahaan.' then 'Dokumentasi foto, video highlight, photobooth, dan live streaming untuk acara sekolah maupun umum.'
      when slug = 'wedding-planning' and description = 'Tim kami merangkai setiap detail hari pernikahan dengan penuh perhatian, dari konsep hingga momen terakhir.' then 'Tim kami membantu merencanakan detail pernikahan dari konsep hingga hari acara.'
      else description
    end,
    featured = slug in ('graduation-celebration', 'yearbook-story', 'corporate-event', 'event-organizer'),
    sort_order = case slug
      when 'graduation-celebration' then 1
      when 'yearbook-story' then 2
      when 'corporate-event' then 3
      when 'event-organizer' then 4
      when 'visual-production' then 5
      when 'wedding-planning' then 6
    end,
    image_url = case
      when slug = 'graduation-celebration' and (image_url = '/images/wedding-garden.jpg' or image_url = '') then '/images/graduation.jpg'
      else image_url
    end
where slug in ('graduation-celebration', 'yearbook-story', 'corporate-event', 'event-organizer', 'visual-production', 'wedding-planning');

update public.packages
set name = case slug
      when 'school-celebration' then case when name = 'School Celebration' then 'Perpisahan Sekolah' else name end
      when 'yearbook-classic' then case when name = 'Yearbook Classic' then 'Yearbook Satu Angkatan' else name end
      when 'signature-corporate' then case when name = 'Signature Corporate' then 'Signature Event' else name end
      else name
    end,
    description = case
      when slug = 'school-celebration' and description = 'Momen kelulusan penuh kebanggaan.' then 'Paket acara kelulusan yang bisa disesuaikan dengan kebutuhan sekolah.'
      when slug = 'yearbook-classic' and description = 'Desain personal, cetak premium.' then 'Dari sesi foto sampai buku kenangan siap dibagikan.'
      when slug = 'signature-corporate' and description = 'Pengalaman brand yang berkesan.' then 'Produksi acara sekolah, komunitas, atau perusahaan.'
      else description
    end,
    featured = slug in ('school-celebration', 'yearbook-classic', 'signature-corporate'),
    sort_order = case slug
      when 'school-celebration' then 1
      when 'yearbook-classic' then 2
      when 'signature-corporate' then 3
      when 'full-event-planning' then 4
      when 'intimate-wedding' then 5
    end
where slug in ('school-celebration', 'yearbook-classic', 'signature-corporate', 'full-event-planning', 'intimate-wedding');

update public.price_list pl
set sort_order = packages.sort_order,
    name = packages.name,
    description = packages.description
from public.packages
where pl.package_id = packages.id
  and packages.slug in ('school-celebration', 'yearbook-classic', 'signature-corporate', 'full-event-planning', 'intimate-wedding');

update public.portfolios
set title = case
      when slug = 'class-of-2025' and title = 'Class of 2025' then 'Malam Perpisahan Angkatan 2025'
      when slug = 'our-little-universe' and title = 'Our Little Universe' then 'Yearbook: Our Little Universe'
      else title
    end,
    category = case
      when slug = 'class-of-2025' and category = 'Graduation' then 'Perpisahan & Wisuda'
      when slug = 'together-forward' and category = 'Corporate' then 'Event & Corporate'
      else category
    end,
    description = case
      when slug = 'class-of-2025' and description = 'Malam apresiasi penuh cahaya.' then 'Satu malam untuk merayakan perjalanan dan teman-teman seperjuangan.'
      when slug = 'our-little-universe' and description = 'Yearbook penuh warna dan kepribadian.' then 'Cerita satu angkatan dalam buku kenangan penuh warna.'
      when slug = 'together-forward' and description = 'Annual gathering dengan sentuhan modern.' then 'Gathering dengan panggung, visual, dan alur acara yang rapi.'
      else description
    end,
    sort_order = case slug
      when 'class-of-2025' then 1
      when 'our-little-universe' then 2
      when 'together-forward' then 3
      when 'the-art-of-gathering' then 4
      when 'a-garden-wedding' then 5
      when 'golden-hour-vows' then 6
    end,
    cover_image_url = case
      when slug = 'class-of-2025' and (cover_image_url = '/images/wedding-garden.jpg' or cover_image_url = '') then '/images/graduation.jpg'
      else cover_image_url
    end
where slug in ('class-of-2025', 'our-little-universe', 'together-forward', 'the-art-of-gathering', 'a-garden-wedding', 'golden-hour-vows');

update public.testimonials
set role = 'Panitia perpisahan sekolah',
    quote = 'Dari persiapan sampai acara selesai, timnya sigap. Anak-anak menikmati malam perpisahan dan guru bisa fokus mendampingi mereka.',
    sort_order = 1
where name = 'SMA Cakrawala'
  and role = 'School partner';

update public.testimonials
set name = 'Universitas Pertiwi',
    role = 'Panitia wisuda',
    quote = 'Alur acara, panggung, dan dokumentasi tertata baik. Koordinasi dengan panitia kampus juga berjalan lancar.',
    sort_order = 2
where name = 'Nadia & Arief'
  and role = 'Wedding client';

update public.faqs
set question = 'Kapan sebaiknya sekolah mulai merencanakan acara perpisahan?',
    answer = 'Idealnya hubungi kami 3–6 bulan sebelum acara agar waktu untuk menyusun konsep, anggaran, venue, dan koordinasi sekolah cukup. Kami tetap terbuka untuk kebutuhan dengan jadwal lebih singkat.',
    sort_order = 1
where question = 'Seberapa awal sebaiknya saya menghubungi tim?'
  and answer like 'Untuk pernikahan, idealnya%';

update public.contacts
set title = 'Konsultan Acara Sekolah',
    division = 'Sekolah & Event',
    sort_order = 1
where email = 'event@abadinanjaya.id';

update public.contacts
set sort_order = 2
where email = 'wedding@abadinanjaya.id';

update public.landing_sections
set title = 'Perpisahan sekolah, jadi cerita satu angkatan.',
    subtitle = 'Panggung, hiburan, rundown, dan dokumentasi kami siapkan. Sekolah dan siswa tinggal menikmati momennya.',
    image_url = '/images/graduation.jpg'
where section_key = 'hero'
  and title = 'Setiap perayaan punya cerita.';

update public.landing_sections
set title = 'Partner acara untuk sekolah dan banyak cerita lain.'
where section_key = 'services'
  and title = 'Satu partner untuk setiap perayaan.';

update public.landing_sections
set title = 'Paket perpisahan yang bisa disesuaikan.',
    subtitle = 'Mulai dari kebutuhan inti sampai tambahan panggung, photobooth, dokumentasi, dan yearbook.'
where section_key = 'packages'
  and title = 'Awali dari yang paling sesuai.';

update public.landing_sections
set title = 'Momen sekolah yang pernah kami rayakan.'
where section_key = 'portfolio'
  and title = 'Cerita yang pernah kami rangkai.';

update public.landing_sections
set title = 'Acara tertata. Semua bisa ikut merayakan.',
    subtitle = 'Untuk sekolah, komunitas, dan perusahaan.',
    body = 'Abadi nan Jaya membantu panitia mengelola konsep, produksi, dan koordinasi acara. Fokus utama kami adalah perayaan sekolah—mulai dari perpisahan dan wisuda hingga buku kenangan—serta berbagai acara komunitas, corporate, dan personal.',
    image_url = case when image_url = '' then '/images/about-team.jpg' else image_url end
where section_key = 'about'
  and title = 'Bukan sekadar acara.';

update public.landing_sections
set title = 'Cerita dari panitia dan sekolah.'
where section_key = 'testimonials'
  and title = 'Kata mereka setelah hari istimewa.';

update public.landing_sections
set title = 'Sedang menyiapkan perpisahan sekolah?',
    subtitle = 'Ceritakan jumlah siswa, rencana acara, dan kebutuhan sekolah. Kami bantu susun langkah berikutnya.',
    cta_label = 'Diskusikan acara sekolah',
    cta_url = '/booking'
where section_key = 'cta'
  and title = 'Ada cerita yang ingin Anda rayakan?';
