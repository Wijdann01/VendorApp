create extension if not exists pgcrypto;

create type public.profile_role as enum ('super_admin', 'editor');
create type public.inquiry_status as enum ('baru', 'diproses', 'selesai');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role public.profile_role not null default 'editor',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role in ('super_admin', 'editor')
  );
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'super_admin'
  );
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    'editor'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text not null default '',
  icon text not null default '',
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.services (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories(id) on delete restrict,
  title text not null,
  slug text not null unique,
  summary text not null default '',
  description text not null default '',
  image_url text not null default '',
  featured boolean not null default false,
  sort_order integer not null default 0,
  is_published boolean not null default false,
  seo_title text not null default '',
  seo_description text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.packages (
  id uuid primary key default gen_random_uuid(),
  service_id uuid not null references public.services(id) on delete cascade,
  name text not null,
  slug text not null unique,
  description text not null default '',
  price numeric(14,2) not null default 0 check (price >= 0),
  price_label text not null default 'Mulai dari',
  inclusions text[] not null default '{}',
  featured boolean not null default false,
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.package_items (
  id uuid primary key default gen_random_uuid(),
  package_id uuid not null references public.packages(id) on delete cascade,
  name text not null,
  description text not null default '',
  quantity integer not null default 1 check (quantity > 0),
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.addons (
  id uuid primary key default gen_random_uuid(),
  package_id uuid not null references public.packages(id) on delete cascade,
  name text not null,
  description text not null default '',
  price numeric(14,2) not null default 0 check (price >= 0),
  sort_order integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.portfolios (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  category text not null default '',
  category_id uuid references public.categories(id) on delete set null,
  description text not null default '',
  cover_image_url text not null default '',
  media jsonb not null default '[]'::jsonb,
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.portfolio_media (
  id uuid primary key default gen_random_uuid(),
  portfolio_id uuid not null references public.portfolios(id) on delete cascade,
  storage_path text not null,
  media_url text not null,
  media_type text not null default 'image' check (media_type in ('image', 'video')),
  alt_text text not null default '',
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.contacts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  title text not null default '',
  division text not null default '',
  phone text not null default '',
  email text not null default '',
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.testimonials (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text not null default '',
  quote text not null,
  rating smallint not null default 5 check (rating between 1 and 5),
  avatar_url text not null default '',
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text not null default '',
  website_url text not null default '',
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.faqs (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  answer text not null,
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.inquiries (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 120),
  email text not null check (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
  phone text not null check (char_length(regexp_replace(phone, '\D', '', 'g')) between 9 and 16),
  event_type text not null,
  event_date date,
  guest_count integer check (guest_count is null or guest_count > 0),
  message text not null check (char_length(trim(message)) between 15 and 5000),
  status public.inquiry_status not null default 'baru',
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.price_list (
  id uuid primary key default gen_random_uuid(),
  package_id uuid references public.packages(id) on delete set null,
  category_id uuid references public.categories(id) on delete set null,
  name text not null,
  description text not null default '',
  price numeric(14,2) not null default 0 check (price >= 0),
  price_label text not null default 'Mulai dari',
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.site_settings (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  value jsonb not null default '{}'::jsonb,
  is_public boolean not null default true,
  sort_order integer not null default 0,
  updated_at timestamptz not null default now()
);

create table public.landing_sections (
  id uuid primary key default gen_random_uuid(),
  section_key text not null unique,
  title text not null default '',
  subtitle text not null default '',
  body text not null default '',
  image_url text not null default '',
  cta_label text not null default '',
  cta_url text not null default '',
  is_enabled boolean not null default true,
  sort_order integer not null default 0,
  updated_at timestamptz not null default now()
);

create index services_category_published_idx on public.services (category_id, is_published, sort_order);
create index packages_service_published_idx on public.packages (service_id, is_published, sort_order);
create index portfolio_category_published_idx on public.portfolios (category_id, is_published, sort_order);
create index inquiries_status_created_idx on public.inquiries (status, created_at desc);
create index package_items_package_idx on public.package_items (package_id, sort_order);
create index addons_package_idx on public.addons (package_id, sort_order);
create index portfolio_media_portfolio_idx on public.portfolio_media (portfolio_id, sort_order);
create unique index package_items_package_name_idx on public.package_items (package_id, name);
create unique index contacts_email_idx on public.contacts (email) where email <> '';
create unique index testimonials_name_quote_idx on public.testimonials (name, quote);
create unique index clients_name_idx on public.clients (name);
create unique index faqs_question_idx on public.faqs (question);
create unique index price_list_package_idx on public.price_list (package_id) where package_id is not null;

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.services enable row level security;
alter table public.packages enable row level security;
alter table public.package_items enable row level security;
alter table public.addons enable row level security;
alter table public.portfolios enable row level security;
alter table public.portfolio_media enable row level security;
alter table public.contacts enable row level security;
alter table public.testimonials enable row level security;
alter table public.clients enable row level security;
alter table public.faqs enable row level security;
alter table public.inquiries enable row level security;
alter table public.price_list enable row level security;
alter table public.site_settings enable row level security;
alter table public.landing_sections enable row level security;

create policy "Admins read profiles" on public.profiles for select to authenticated using (public.is_admin());
create policy "Super admins manage profiles" on public.profiles for all to authenticated using (public.is_super_admin()) with check (public.is_super_admin());

create policy "Public read published categories" on public.categories for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage categories" on public.categories for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read published services" on public.services for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage services" on public.services for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read published packages" on public.packages for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage packages" on public.packages for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "Public read items in published packages" on public.package_items for select to anon, authenticated
using (exists (select 1 from public.packages p where p.id = package_id and p.is_published) or public.is_admin());
create policy "Admins manage package items" on public.package_items for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read addons in published packages" on public.addons for select to anon, authenticated
using ((is_published and exists (select 1 from public.packages p where p.id = package_id and p.is_published)) or public.is_admin());
create policy "Admins manage addons" on public.addons for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "Public read published portfolios" on public.portfolios for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage portfolios" on public.portfolios for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read media for published portfolios" on public.portfolio_media for select to anon, authenticated
using (exists (select 1 from public.portfolios p where p.id = portfolio_id and p.is_published) or public.is_admin());
create policy "Admins manage portfolio media" on public.portfolio_media for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "Public read published contacts" on public.contacts for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage contacts" on public.contacts for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read published testimonials" on public.testimonials for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage testimonials" on public.testimonials for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read published clients" on public.clients for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage clients" on public.clients for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read published faqs" on public.faqs for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage faqs" on public.faqs for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "Public submit inquiries" on public.inquiries for insert to anon, authenticated with check (
  status = 'baru' and notes = '' and name = trim(name) and message = trim(message)
);
create policy "Admins read inquiries" on public.inquiries for select to authenticated using (public.is_admin());
create policy "Admins update inquiries" on public.inquiries for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admins delete inquiries" on public.inquiries for delete to authenticated using (public.is_admin());

create policy "Public read published price list" on public.price_list for select to anon, authenticated using (is_published or public.is_admin());
create policy "Admins manage price list" on public.price_list for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read public site settings" on public.site_settings for select to anon, authenticated using (is_public or public.is_admin());
create policy "Admins manage site settings" on public.site_settings for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Public read enabled landing sections" on public.landing_sections for select to anon, authenticated using (is_enabled or public.is_admin());
create policy "Admins manage landing sections" on public.landing_sections for all to authenticated using (public.is_admin()) with check (public.is_admin());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'portfolio-media',
  'portfolio-media',
  true,
  52428800,
  array['image/jpeg','image/png','image/webp','image/avif','image/gif','video/mp4','video/webm']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "Public read portfolio media storage" on storage.objects for select to anon, authenticated using (bucket_id = 'portfolio-media');
create policy "Admins upload portfolio media storage" on storage.objects for insert to authenticated with check (bucket_id = 'portfolio-media' and public.is_admin());
create policy "Admins update portfolio media storage" on storage.objects for update to authenticated using (bucket_id = 'portfolio-media' and public.is_admin()) with check (bucket_id = 'portfolio-media' and public.is_admin());
create policy "Admins delete portfolio media storage" on storage.objects for delete to authenticated using (bucket_id = 'portfolio-media' and public.is_admin());
