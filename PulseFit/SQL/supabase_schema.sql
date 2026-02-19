-- PulseFit schema for Supabase
create extension if not exists "pgcrypto";

create table if not exists public.workouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.exercises (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references public.workouts(id) on delete cascade,
  name text not null,
  target_sets int not null default 3,
  target_reps int not null default 10,
  notes text,
  sort_order int not null default 0
);

create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  calories int not null check (calories >= 0),
  protein int not null check (protein >= 0),
  carbs int not null check (carbs >= 0),
  fat int not null check (fat >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.gym_check_ins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_id uuid not null references public.workouts(id) on delete restrict,
  started_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.exercise_set_logs (
  id uuid primary key default gen_random_uuid(),
  check_in_id uuid not null references public.gym_check_ins(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete restrict,
  set_number int not null check (set_number > 0),
  reps int not null check (reps >= 0),
  weight_kg numeric(8,2) not null check (weight_kg >= 0),
  started_at timestamptz not null,
  completed_at timestamptz not null,
  rest_seconds int not null default 0 check (rest_seconds >= 0)
);

create table if not exists public.meal_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_id uuid not null references public.meals(id) on delete cascade,
  consumed_at timestamptz not null default now()
);

alter table public.workouts enable row level security;
alter table public.exercises enable row level security;
alter table public.meals enable row level security;
alter table public.gym_check_ins enable row level security;
alter table public.exercise_set_logs enable row level security;
alter table public.meal_logs enable row level security;

create policy "workouts owner access" on public.workouts
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "meals owner access" on public.meals
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "checkin owner access" on public.gym_check_ins
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "meal logs owner access" on public.meal_logs
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "exercises by workout owner" on public.exercises
for all using (
  exists (select 1 from public.workouts w where w.id = workout_id and w.user_id = auth.uid())
) with check (
  exists (select 1 from public.workouts w where w.id = workout_id and w.user_id = auth.uid())
);

create policy "set logs by checkin owner" on public.exercise_set_logs
for all using (
  exists (select 1 from public.gym_check_ins g where g.id = check_in_id and g.user_id = auth.uid())
) with check (
  exists (select 1 from public.gym_check_ins g where g.id = check_in_id and g.user_id = auth.uid())
);

create index if not exists idx_workouts_user_id on public.workouts(user_id);
create index if not exists idx_meals_user_id on public.meals(user_id);
create index if not exists idx_exercises_workout_id on public.exercises(workout_id);
create index if not exists idx_checkins_user_id on public.gym_check_ins(user_id);
create index if not exists idx_set_logs_checkin on public.exercise_set_logs(check_in_id);
create index if not exists idx_meal_logs_user_id on public.meal_logs(user_id);
