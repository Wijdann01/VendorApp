update public.services
set image_url = case slug
  when 'wedding-planning' then '/images/wedding-garden.jpg'
  when 'corporate-event' then '/images/corporate-event.jpg'
  when 'graduation-celebration' then '/images/graduation.jpg'
  when 'event-organizer' then '/images/event-organizer.jpg'
  when 'yearbook-story' then '/images/yearbook.jpg'
  when 'visual-production' then '/images/production.jpg'
  else image_url
end
where slug in ('wedding-planning', 'corporate-event', 'graduation-celebration', 'event-organizer', 'yearbook-story', 'visual-production');

update public.portfolios
set cover_image_url = case slug
  when 'a-garden-wedding' then '/images/wedding-garden.jpg'
  when 'together-forward' then '/images/corporate-event.jpg'
  when 'class-of-2025' then '/images/graduation.jpg'
  when 'the-art-of-gathering' then '/images/event-organizer.jpg'
  when 'our-little-universe' then '/images/yearbook.jpg'
  when 'golden-hour-vows' then '/images/wedding-sunset.jpg'
  else cover_image_url
end
where slug in ('a-garden-wedding', 'together-forward', 'class-of-2025', 'the-art-of-gathering', 'our-little-universe', 'golden-hour-vows');

update public.landing_sections
set image_url = case section_key
  when 'hero' then '/images/wedding-garden.jpg'
  when 'about' then '/images/about-team.jpg'
  else image_url
end
where section_key in ('hero', 'about');
