insert into public.event_types (name, booking_type, sort_order, is_published)
select
  trim(c.name),
  case when c.slug ~* '(wedding|pernikahan|personal)' or c.name ~* '(wedding|pernikahan|personal)' then 'personal' else 'organization' end,
  c.sort_order,
  c.is_published
from public.categories c
where char_length(trim(c.name)) between 2 and 120
on conflict (booking_type, name) do nothing;

alter table public.packages
  add column event_type_id uuid references public.event_types(id) on delete restrict;

update public.packages p
set event_type_id = et.id
from public.services s
join public.categories c on c.id = s.category_id
join public.event_types et
  on et.name = case when char_length(trim(c.name)) between 2 and 120 then trim(c.name) else 'Lainnya' end
  and et.booking_type = case when c.slug ~* '(wedding|pernikahan|personal)' or c.name ~* '(wedding|pernikahan|personal)' then 'personal' else 'organization' end
where p.service_id = s.id;

alter table public.packages
  alter column event_type_id set not null;

create index packages_event_type_id_idx on public.packages (event_type_id);

create or replace function public.validate_package_event_type()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if not exists (
    select 1
    from public.services s
    join public.categories c on c.id = s.category_id
    join public.event_types et on et.id = new.event_type_id
    where s.id = new.service_id
      and (
        (et.booking_type = 'organization' and c.slug not ilike '%wedding%' and c.name not ilike '%pernikahan%' and s.slug not ilike '%wedding%')
        or (
          et.booking_type = 'personal'
          and (
            c.slug ilike '%wedding%'
            or c.slug = 'personal'
            or c.name ilike '%wedding%'
            or c.name ilike '%pernikahan%'
            or s.slug = 'visual-production'
          )
        )
      )
  ) then
    raise exception using
      errcode = '23514',
      message = 'Jenis acara paket harus sesuai dengan layanan dan tipe pemesannya.';
  end if;

  return new;
end;
$$;

create trigger validate_package_event_type_before_write
  before insert or update of service_id, event_type_id
  on public.packages
  for each row execute function public.validate_package_event_type();

create or replace function public.validate_inquiry_package_event_type()
returns trigger
language plpgsql
set search_path = public
as $$
begin
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

create trigger validate_inquiry_package_event_type_before_insert
  before insert on public.inquiries
  for each row execute function public.validate_inquiry_package_event_type();
