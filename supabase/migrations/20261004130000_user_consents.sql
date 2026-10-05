-- Consent evidence for email account linking.
-- Apply this migration before deploying the matching frontend.
create table if not exists public.user_consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  consent_version text not null,
  terms_version text not null,
  accepted_at timestamptz not null default now()
);

alter table public.user_consents enable row level security;

create policy "Users can record their own consent"
on public.user_consents
for insert
to authenticated
with check (user_id = (select auth.uid()));

create policy "Users can view their own consent records"
on public.user_consents
for select
to authenticated
using (user_id = (select auth.uid()));

revoke update, delete on public.user_consents from anon, authenticated;
grant select, insert on public.user_consents to authenticated;
