drop policy if exists "Admins read profiles" on public.profiles;
drop policy if exists "Super admins manage profiles" on public.profiles;
create policy "Users read own profile or super admins read profiles"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()) or public.is_super_admin());
create policy "Super admins insert profiles"
  on public.profiles for insert to authenticated
  with check (public.is_super_admin());
create policy "Super admins update profiles"
  on public.profiles for update to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());
create policy "Super admins delete profiles"
  on public.profiles for delete to authenticated
  using (public.is_super_admin());

create or replace function public.prevent_last_super_admin_removal()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.role = 'super_admin' then
    if tg_op = 'DELETE' then
      if (select count(*) from public.profiles where role = 'super_admin') <= 1 then
        raise exception 'At least one super admin account must remain.';
      end if;
    elsif new.role <> 'super_admin' then
      if (select count(*) from public.profiles where role = 'super_admin') <= 1 then
        raise exception 'At least one super admin account must remain.';
      end if;
    end if;
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_last_super_admin on public.profiles;
create trigger protect_last_super_admin
  before update of role or delete on public.profiles
  for each row execute function public.prevent_last_super_admin_removal();

drop policy if exists "Admins manage categories" on public.categories;
create policy "Admins insert categories" on public.categories for insert to authenticated with check (public.is_admin());
create policy "Admins update categories" on public.categories for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete categories" on public.categories for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage services" on public.services;
create policy "Admins insert services" on public.services for insert to authenticated with check (public.is_admin());
create policy "Admins update services" on public.services for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete services" on public.services for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage packages" on public.packages;
create policy "Admins insert packages" on public.packages for insert to authenticated with check (public.is_admin());
create policy "Admins update packages" on public.packages for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete packages" on public.packages for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage package items" on public.package_items;
create policy "Admins insert package items" on public.package_items for insert to authenticated with check (public.is_admin());
create policy "Admins update package items" on public.package_items for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admins delete package items" on public.package_items for delete to authenticated using (public.is_admin());

drop policy if exists "Admins manage addons" on public.addons;
create policy "Admins insert addons" on public.addons for insert to authenticated with check (public.is_admin());
create policy "Admins update addons" on public.addons for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admins delete addons" on public.addons for delete to authenticated using (public.is_admin());

drop policy if exists "Admins manage portfolios" on public.portfolios;
create policy "Admins insert portfolios" on public.portfolios for insert to authenticated with check (public.is_admin());
create policy "Admins update portfolios" on public.portfolios for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete portfolios" on public.portfolios for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage portfolio media" on public.portfolio_media;
create policy "Admins insert portfolio media" on public.portfolio_media for insert to authenticated with check (public.is_admin());
create policy "Admins update portfolio media" on public.portfolio_media for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete portfolio media" on public.portfolio_media for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage contacts" on public.contacts;
create policy "Admins insert contacts" on public.contacts for insert to authenticated with check (public.is_admin());
create policy "Admins update contacts" on public.contacts for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete contacts" on public.contacts for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage testimonials" on public.testimonials;
create policy "Admins insert testimonials" on public.testimonials for insert to authenticated with check (public.is_admin());
create policy "Admins update testimonials" on public.testimonials for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete testimonials" on public.testimonials for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage clients" on public.clients;
create policy "Admins insert clients" on public.clients for insert to authenticated with check (public.is_admin());
create policy "Admins update clients" on public.clients for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete clients" on public.clients for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage faqs" on public.faqs;
create policy "Admins insert faqs" on public.faqs for insert to authenticated with check (public.is_admin());
create policy "Admins update faqs" on public.faqs for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete faqs" on public.faqs for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage price list" on public.price_list;
create policy "Admins insert price list" on public.price_list for insert to authenticated with check (public.is_admin());
create policy "Admins update price list" on public.price_list for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete price list" on public.price_list for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage landing sections" on public.landing_sections;
create policy "Admins insert landing sections" on public.landing_sections for insert to authenticated with check (public.is_admin());
create policy "Admins update landing sections" on public.landing_sections for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Super admins delete landing sections" on public.landing_sections for delete to authenticated using (public.is_super_admin());

drop policy if exists "Admins manage site settings" on public.site_settings;
drop policy if exists "Public read public site settings" on public.site_settings;
create policy "Public read public site settings"
  on public.site_settings for select to anon, authenticated
  using (is_public or public.is_super_admin());
create policy "Super admins manage site settings"
  on public.site_settings for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

drop policy if exists "Admins delete inquiries" on public.inquiries;
create policy "Super admins delete inquiries"
  on public.inquiries for delete to authenticated using (public.is_super_admin());

create or replace function public.protect_editor_inquiry_fields()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if not public.is_super_admin()
    and (to_jsonb(new) - array['status', 'notes']) is distinct from (to_jsonb(old) - array['status', 'notes']) then
    raise exception 'Editors may only update inquiry status and internal notes.';
  end if;
  return new;
end;
$$;

drop trigger if exists protect_editor_inquiry_fields on public.inquiries;
create trigger protect_editor_inquiry_fields
  before update on public.inquiries
  for each row execute function public.protect_editor_inquiry_fields();

drop policy if exists "Admins upload portfolio media storage" on storage.objects;
drop policy if exists "Admins update portfolio media storage" on storage.objects;
drop policy if exists "Admins delete portfolio media storage" on storage.objects;
create policy "Admins upload portfolio media storage"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'portfolio-media' and public.is_admin());
create policy "Admins update portfolio media storage"
  on storage.objects for update to authenticated
  using (bucket_id = 'portfolio-media' and public.is_admin())
  with check (bucket_id = 'portfolio-media' and public.is_admin());
create policy "Super admins delete portfolio media storage"
  on storage.objects for delete to authenticated
  using (bucket_id = 'portfolio-media' and public.is_super_admin());
