-- PulseFit MVP schema for Supabase (Postgres)
create table if not exists profiles (
  id uuid primary key references auth.users(id),
  created_at timestamptz default now(),
  display_name text,
  units text default 'imperial',
  weekly_gym_goal int default 3,
  calorie_goal int,
  protein_goal int,
  carb_goal int,
  fat_goal int,
  progression_method text default 'doubleProgression'
);

create table if not exists sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  gym_id uuid null,
  started_at timestamptz default now(),
  ended_at timestamptz null,
  mood int null,
  energy int null,
  notes text null
);

create table if not exists exercises (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  name text not null,
  category text not null,
  tracking_type text not null,
  created_at timestamptz default now()
);

create table if not exists session_exercises (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references sessions(id) on delete cascade,
  exercise_id uuid not null references exercises(id),
  order_index int not null,
  notes text null
);

create table if not exists sets (
  id uuid primary key default gen_random_uuid(),
  session_exercise_id uuid not null references session_exercises(id) on delete cascade,
  set_index int not null,
  weight numeric null,
  reps int null,
  time_seconds int null,
  distance_meters numeric null,
  rpe int null,
  is_completed boolean default false,
  created_at timestamptz default now()
);

create table if not exists food_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  logged_at timestamptz default now(),
  name text not null,
  calories int not null,
  protein int not null,
  carbs int not null,
  fat int not null
);

alter table profiles enable row level security;
alter table sessions enable row level security;
alter table exercises enable row level security;
alter table session_exercises enable row level security;
alter table sets enable row level security;
alter table food_entries enable row level security;

create policy "profiles_select_own" on profiles for select using (id = auth.uid());
create policy "profiles_update_own" on profiles for update using (id = auth.uid());

create policy "sessions_own_all" on sessions for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "exercises_own_all" on exercises for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "food_entries_own_all" on food_entries for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "session_exercises_via_session" on session_exercises
for all using (
  exists (select 1 from sessions s where s.id = session_exercises.session_id and s.user_id = auth.uid())
) with check (
  exists (select 1 from sessions s where s.id = session_exercises.session_id and s.user_id = auth.uid())
);

create policy "sets_via_session_chain" on sets
for all using (
  exists (
    select 1 from session_exercises se
    join sessions s on s.id = se.session_id
    where se.id = sets.session_exercise_id and s.user_id = auth.uid()
  )
) with check (
  exists (
    select 1 from session_exercises se
    join sessions s on s.id = se.session_id
    where se.id = sets.session_exercise_id and s.user_id = auth.uid()
  )
);

create index if not exists idx_sessions_user_started_at on sessions(user_id, started_at desc);
create index if not exists idx_food_entries_user_logged_at on food_entries(user_id, logged_at desc);
create index if not exists idx_sets_session_exercise_index on sets(session_exercise_id, set_index);
