alter table public.landing_sections
  add column if not exists layout text not null default 'image-left';

alter table public.landing_sections
  drop constraint if exists landing_sections_layout_check;

alter table public.landing_sections
  add constraint landing_sections_layout_check
  check (layout in ('image-left', 'image-right', 'image-top', 'centered', 'highlight'));
