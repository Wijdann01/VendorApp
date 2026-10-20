insert into public.site_settings (key, value, is_public, sort_order)
values ('map_location', '{"map_location":"Tasikmalaya, Jawa Barat"}'::jsonb, true, 6)
on conflict (key) do nothing;
