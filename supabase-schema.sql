-- MyMoney single-account cloud storage
-- Run this in Supabase Dashboard > SQL Editor.

create table if not exists public.mymoney_data (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{"transactions": [], "budgets": {}, "settings": {"currency": "INR", "theme": "light"}}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.mymoney_data enable row level security;

-- Keep browser access limited to signed-in users; row policies below scope each row.
revoke all on public.mymoney_data from anon;
grant select, insert, update, delete on public.mymoney_data to authenticated;

 drop policy if exists "MyMoney owner can read own row" on public.mymoney_data;
 drop policy if exists "MyMoney owner can insert own row" on public.mymoney_data;
 drop policy if exists "MyMoney owner can update own row" on public.mymoney_data;
 drop policy if exists "MyMoney owner can delete own row" on public.mymoney_data;

create policy "MyMoney owner can read own row"
  on public.mymoney_data for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "MyMoney owner can insert own row"
  on public.mymoney_data for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "MyMoney owner can update own row"
  on public.mymoney_data for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "MyMoney owner can delete own row"
  on public.mymoney_data for delete to authenticated
  using ((select auth.uid()) = user_id);

-- Optional: enable database change events for live sync between open devices.
-- If your project already has this table in the publication, skip this block.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (
       select 1 from pg_publication_tables
       where pubname = 'supabase_realtime'
         and schemaname = 'public'
         and tablename = 'mymoney_data'
     ) then
    alter publication supabase_realtime add table public.mymoney_data;
  end if;
end $$;
