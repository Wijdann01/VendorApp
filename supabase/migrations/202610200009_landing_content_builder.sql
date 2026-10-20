alter table public.landing_sections
  add column if not exists content_blocks jsonb not null default '[]'::jsonb;

alter table public.landing_sections
  drop constraint if exists landing_sections_content_blocks_check;

alter table public.landing_sections
  add constraint landing_sections_content_blocks_check
  check (jsonb_typeof(content_blocks) = 'array');
