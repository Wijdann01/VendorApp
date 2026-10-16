alter table public.inquiries
  add column if not exists booking_type text not null default 'personal'
    check (booking_type in ('personal', 'organization')),
  add column if not exists organization_name text not null default '',
  add column if not exists organization_type text not null default '',
  add column if not exists contact_position text not null default '',
  add column if not exists service_id uuid references public.services(id) on delete set null,
  add column if not exists package_id uuid references public.packages(id) on delete set null,
  add column if not exists event_start_time time,
  add column if not exists event_end_time time,
  add column if not exists event_location text not null default '',
  add column if not exists event_city text not null default '',
  add column if not exists venue_type text not null default '',
  add column if not exists budget_min numeric(14,2) check (budget_min is null or budget_min >= 0),
  add column if not exists budget_max numeric(14,2) check (budget_max is null or budget_max >= 0),
  add column if not exists event_theme text not null default '',
  add column if not exists selected_addons jsonb not null default '[]'::jsonb,
  add column if not exists special_requirements text not null default '';

alter table public.inquiries
  add constraint inquiries_budget_range_check
  check (budget_min is null or budget_max is null or budget_max >= budget_min);

create index if not exists inquiries_package_created_idx
  on public.inquiries (package_id, created_at desc);

create index if not exists inquiries_booking_type_created_idx
  on public.inquiries (booking_type, created_at desc);

create unique index if not exists addons_package_name_idx
  on public.addons (package_id, name);

drop policy if exists "Public submit inquiries" on public.inquiries;
create policy "Public submit inquiries" on public.inquiries for insert to anon, authenticated with check (
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
    inquiries.service_id is null
    or exists (select 1 from public.services s where s.id = inquiries.service_id and s.is_published)
  )
  and (
    package_id is null
    or exists (
      select 1 from public.packages p
      join public.services s on s.id = p.service_id
      where p.id = inquiries.package_id and p.is_published and s.is_published
        and (inquiries.service_id is null or inquiries.service_id = s.id)
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
