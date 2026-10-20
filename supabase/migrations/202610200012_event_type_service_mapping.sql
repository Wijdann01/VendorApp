create table public.event_type_services (
  event_type_id uuid not null references public.event_types(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (event_type_id, service_id)
);

alter table public.event_type_services enable row level security;

create policy "Public read published event type services"
  on public.event_type_services for select to anon, authenticated
  using (
    exists (
      select 1 from public.event_types et
      where et.id = event_type_services.event_type_id and et.is_published
    )
    and exists (
      select 1 from public.services s
      where s.id = event_type_services.service_id and s.is_published
    )
    or public.is_admin()
  );
create policy "Admins insert event type services"
  on public.event_type_services for insert to authenticated
  with check (public.is_admin());
create policy "Admins delete event type services"
  on public.event_type_services for delete to authenticated
  using (public.is_admin());

with service_mapping(event_name, booking_type, service_slug) as (
  values
    ('Perpisahan & Wisuda', 'organization', 'graduation-celebration'),
    ('Perpisahan & Wisuda', 'organization', 'visual-production'),
    ('Yearbook', 'organization', 'yearbook-story'),
    ('Yearbook', 'organization', 'visual-production'),
    ('Event & Corporate', 'organization', 'corporate-event'),
    ('Event & Corporate', 'organization', 'visual-production'),
    ('Event Organizer', 'organization', 'event-organizer'),
    ('Event Organizer', 'organization', 'corporate-event'),
    ('Event Organizer', 'organization', 'visual-production'),
    ('Acara perusahaan', 'organization', 'corporate-event'),
    ('Acara perusahaan', 'organization', 'event-organizer'),
    ('Acara perusahaan', 'organization', 'visual-production'),
    ('Gathering perusahaan', 'organization', 'corporate-event'),
    ('Gathering perusahaan', 'organization', 'event-organizer'),
    ('Gathering perusahaan', 'organization', 'visual-production'),
    ('Acara komunitas', 'organization', 'corporate-event'),
    ('Acara komunitas', 'organization', 'event-organizer'),
    ('Acara komunitas', 'organization', 'visual-production'),
    ('Lainnya', 'organization', 'graduation-celebration'),
    ('Lainnya', 'organization', 'yearbook-story'),
    ('Lainnya', 'organization', 'corporate-event'),
    ('Lainnya', 'organization', 'event-organizer'),
    ('Lainnya', 'organization', 'visual-production'),
    ('Wedding', 'personal', 'wedding-planning'),
    ('Wedding', 'personal', 'visual-production'),
    ('Ulang tahun', 'personal', 'wedding-planning'),
    ('Ulang tahun', 'personal', 'visual-production'),
    ('Perayaan keluarga', 'personal', 'wedding-planning'),
    ('Perayaan keluarga', 'personal', 'visual-production'),
    ('Gathering pribadi', 'personal', 'wedding-planning'),
    ('Gathering pribadi', 'personal', 'visual-production'),
    ('Lainnya', 'personal', 'wedding-planning'),
    ('Lainnya', 'personal', 'visual-production')
)
insert into public.event_type_services (event_type_id, service_id)
select et.id, s.id
from service_mapping m
join public.event_types et on et.name = m.event_name and et.booking_type = m.booking_type
join public.services s on s.slug = m.service_slug
on conflict do nothing;

insert into public.event_type_services (event_type_id, service_id)
select p.event_type_id, p.service_id
from public.packages p
on conflict do nothing;

alter table public.packages
  add constraint packages_event_type_service_fkey
  foreign key (event_type_id, service_id)
  references public.event_type_services (event_type_id, service_id)
  on delete restrict;

create or replace function public.set_event_type_services(p_event_type_id uuid, p_service_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception using errcode = '42501', message = 'Hanya admin yang dapat mengatur layanan jenis acara.';
  end if;

  if p_service_ids is null or cardinality(p_service_ids) = 0 then
    raise exception using errcode = '23514', message = 'Setiap jenis acara harus memiliki minimal satu layanan.';
  end if;

  perform 1
  from public.event_types
  where id = p_event_type_id
  for update;
  if not found then
    raise exception using errcode = '23503', message = 'Jenis acara tidak ditemukan.';
  end if;

  if exists (
    select 1
    from public.packages p
    where p.event_type_id = p_event_type_id
      and not (p.service_id = any(p_service_ids))
  ) then
    raise exception using
      errcode = '23514',
      message = 'Layanan yang dipilih masih digunakan oleh paket. Ubah layanan paket terlebih dahulu.';
  end if;

  delete from public.event_type_services
  where event_type_id = p_event_type_id
    and not (service_id = any(p_service_ids));

  insert into public.event_type_services (event_type_id, service_id)
  select p_event_type_id, service_id
  from (select distinct unnest(p_service_ids) as service_id) selected
  on conflict do nothing;
end;
$$;

grant execute on function public.set_event_type_services(uuid, uuid[]) to authenticated;

create or replace function public.validate_package_event_type()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if not exists (
    select 1
    from public.event_type_services ets
    join public.event_types et on et.id = ets.event_type_id
    join public.services s on s.id = ets.service_id
    where ets.event_type_id = new.event_type_id
      and ets.service_id = new.service_id
  ) then
    raise exception using
      errcode = '23514',
      message = 'Layanan paket belum dihubungkan dengan jenis acara tersebut.';
  end if;

  return new;
end;
$$;

create or replace function public.validate_inquiry_package_event_type()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.service_id is not null and not exists (
    select 1
    from public.event_types et
    join public.event_type_services ets on ets.event_type_id = et.id
    join public.services s on s.id = ets.service_id
    where et.name = new.event_type
      and et.booking_type = new.booking_type
      and et.is_published
      and ets.service_id = new.service_id
      and s.is_published
  ) then
    raise exception using
      errcode = '23514',
      message = 'Layanan tidak tersedia untuk jenis acara dan tipe pemesan yang dipilih.';
  end if;

  if new.package_id is not null and not exists (
    select 1
    from public.packages p
    join public.event_types et on et.id = p.event_type_id
    where p.id = new.package_id
      and p.service_id = new.service_id
      and p.is_published
      and et.name = new.event_type
      and et.booking_type = new.booking_type
      and et.is_published
  ) then
    raise exception using
      errcode = '23514',
      message = 'Paket tidak sesuai dengan jenis acara yang dipilih.';
  end if;

  return new;
end;
$$;

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
      not (
        service_id is not null
        or package_id is not null
        or organization_name <> ''
        or event_city <> ''
        or event_location <> ''
        or selected_addons <> '[]'::jsonb
      )
      or exists (
        select 1
        from public.event_types et
        where et.name = inquiries.event_type
          and et.booking_type = inquiries.booking_type
          and et.is_published
      )
    )
    and (
      not (
        package_id is not null
        or organization_name <> ''
        or event_city <> ''
        or event_location <> ''
        or selected_addons <> '[]'::jsonb
      )
      or service_id is not null
    )
    and (
      service_id is null
      or exists (
        select 1
        from public.event_types et
        join public.event_type_services ets on ets.event_type_id = et.id
        join public.services s on s.id = ets.service_id
        where et.name = inquiries.event_type
          and et.booking_type = inquiries.booking_type
          and et.is_published
          and ets.service_id = inquiries.service_id
          and s.is_published
      )
    )
    and (
      package_id is null
      or exists (
        select 1
        from public.packages p
        join public.event_types et on et.id = p.event_type_id
        where p.id = inquiries.package_id
          and p.is_published
          and inquiries.service_id = p.service_id
          and et.name = inquiries.event_type
          and et.booking_type = inquiries.booking_type
          and et.is_published
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
