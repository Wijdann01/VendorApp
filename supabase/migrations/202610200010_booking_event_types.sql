create table public.event_types (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 120),
  booking_type text not null check (booking_type in ('organization', 'personal')),
  sort_order integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (booking_type, name)
);

alter table public.event_types enable row level security;

create policy "Public read published event types"
  on public.event_types for select to anon, authenticated
  using (is_published or public.is_admin());
create policy "Admins insert event types"
  on public.event_types for insert to authenticated
  with check (public.is_admin());
create policy "Admins update event types"
  on public.event_types for update to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete event types"
  on public.event_types for delete to authenticated
  using (public.is_super_admin());

insert into public.event_types (name, booking_type, sort_order, is_published) values
  ('Acara perusahaan', 'organization', 1, true),
  ('Gathering perusahaan', 'organization', 2, true),
  ('Acara komunitas', 'organization', 3, true),
  ('Lainnya', 'organization', 4, true),
  ('Ulang tahun', 'personal', 1, true),
  ('Perayaan keluarga', 'personal', 2, true),
  ('Gathering pribadi', 'personal', 3, true),
  ('Lainnya', 'personal', 4, true)
on conflict (booking_type, name) do nothing;

drop policy if exists "Public submit inquiries" on public.inquiries;
create policy "Public submit inquiries"
  on public.inquiries for insert to anon, authenticated
  with check (
    status = 'baru'
    and notes = ''
    and name = trim(name)
    and message = trim(message)
    and booking_type in ('personal', 'organization')
    and (booking_type <> 'organization' or length(trim(organization_name)) >= 2)
    and jsonb_typeof(selected_addons) = 'array'
    and (event_date is null or event_date >= current_date)
    and (budget_min is null or budget_max is null or budget_max >= budget_min)
    and (
      not (service_id is not null or package_id is not null or organization_name <> '' or event_city <> '' or event_location <> '' or selected_addons <> '[]'::jsonb)
      or exists (
        select 1
        from public.event_types et
        where et.name = inquiries.event_type
          and et.booking_type = inquiries.booking_type
          and et.is_published
      )
      or exists (
        select 1
        from public.categories c
        where c.name = inquiries.event_type
          and c.is_published
          and (
            (inquiries.booking_type = 'organization' and c.slug not like 'wedding%')
            or (inquiries.booking_type = 'personal' and c.slug in ('wedding', 'personal'))
          )
      )
    )
    and (
      not (package_id is not null or organization_name <> '' or event_city <> '' or event_location <> '' or selected_addons <> '[]'::jsonb)
      or service_id is not null
    )
    and (
      service_id is null
      or exists (
        select 1
        from public.services s
        join public.categories c on c.id = s.category_id
        where s.id = inquiries.service_id
          and s.is_published
          and c.is_published
          and (
            (inquiries.booking_type = 'organization' and c.slug not like 'wedding%' and s.slug not like '%wedding%')
            or (
              inquiries.booking_type = 'personal'
              and (c.slug in ('wedding', 'personal') or s.slug = 'visual-production')
            )
          )
      )
    )
    and (
      package_id is null
      or exists (
        select 1
        from public.packages p
        join public.services s on s.id = p.service_id
        join public.categories c on c.id = s.category_id
        where p.id = inquiries.package_id
          and p.is_published
          and s.is_published
          and c.is_published
          and inquiries.service_id = s.id
          and (
            (inquiries.booking_type = 'organization' and c.slug not like 'wedding%' and s.slug not like '%wedding%')
            or (
              inquiries.booking_type = 'personal'
              and (c.slug in ('wedding', 'personal') or s.slug = 'visual-production')
            )
          )
      )
    )
    and not exists (
      select 1
      from jsonb_array_elements(selected_addons) as selected(item)
      where case
        when selected.item ->> 'id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
        then not exists (
          select 1
          from public.addons a
          where a.id = (selected.item ->> 'id')::uuid
            and a.package_id = inquiries.package_id
            and a.is_published
            and a.name = (selected.item ->> 'name')
            and a.price = coalesce((selected.item ->> 'price')::numeric, -1)
            and coalesce((selected.item ->> 'quantity')::integer, 0) between 1 and 100
        )
        else true
      end
    )
  );
