-- PulseFit schema for Supabase (PostgreSQL)
-- Run this in Supabase SQL editor.

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
  target_sets integer not null default 3 check (target_sets > 0),
  target_reps integer not null default 10 check (target_reps > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  calories integer not null default 0 check (calories >= 0),
  protein integer not null default 0 check (protein >= 0),
  carbs integer not null default 0 check (carbs >= 0),
  fats integer not null default 0 check (fats >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.check_ins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_id uuid not null references public.workouts(id) on delete restrict,
  started_at timestamptz not null default now(),
  ended_at timestamptz
);

create table if not exists public.exercise_sets (
  id uuid primary key default gen_random_uuid(),
  check_in_id uuid not null references public.check_ins(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete restrict,
  set_index integer not null check (set_index > 0),
  reps integer not null check (reps >= 0),
  weight numeric(8,2) not null check (weight >= 0),
  started_at timestamptz not null,
  ended_at timestamptz not null,
  rest_seconds_before_set integer not null default 0 check (rest_seconds_before_set >= 0),
  created_at timestamptz not null default now(),
  check (ended_at >= started_at)
);

create table if not exists public.meal_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_id uuid not null references public.meals(id) on delete restrict,
  eaten_at timestamptz not null default now()
);

create index if not exists idx_workouts_user_id on public.workouts(user_id);
create index if not exists idx_meals_user_id on public.meals(user_id);
create index if not exists idx_exercises_workout_id on public.exercises(workout_id);
create index if not exists idx_check_ins_user_started on public.check_ins(user_id, started_at desc);
create index if not exists idx_exercise_sets_check_in on public.exercise_sets(check_in_id);
create index if not exists idx_meal_logs_user_eaten on public.meal_logs(user_id, eaten_at desc);

alter table public.workouts enable row level security;
alter table public.exercises enable row level security;
alter table public.meals enable row level security;
alter table public.check_ins enable row level security;
alter table public.exercise_sets enable row level security;
alter table public.meal_logs enable row level security;

-- Workouts policies
create policy if not exists "workouts_select_own"
  on public.workouts for select
  using (auth.uid() = user_id);

create policy if not exists "workouts_insert_own"
  on public.workouts for insert
  with check (auth.uid() = user_id);

create policy if not exists "workouts_update_own"
  on public.workouts for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy if not exists "workouts_delete_own"
  on public.workouts for delete
  using (auth.uid() = user_id);

-- Exercises policies (owned via parent workout)
create policy if not exists "exercises_select_own"
  on public.exercises for select
  using (
    exists (
      select 1 from public.workouts w
      where w.id = workout_id and w.user_id = auth.uid()
    )
  );

create policy if not exists "exercises_insert_own"
  on public.exercises for insert
  with check (
    exists (
      select 1 from public.workouts w
      where w.id = workout_id and w.user_id = auth.uid()
    )
  );

create policy if not exists "exercises_update_own"
  on public.exercises for update
  using (
    exists (
      select 1 from public.workouts w
      where w.id = workout_id and w.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.workouts w
      where w.id = workout_id and w.user_id = auth.uid()
    )
  );

create policy if not exists "exercises_delete_own"
  on public.exercises for delete
  using (
    exists (
      select 1 from public.workouts w
      where w.id = workout_id and w.user_id = auth.uid()
    )
  );

-- Meals policies
create policy if not exists "meals_select_own"
  on public.meals for select
  using (auth.uid() = user_id);

create policy if not exists "meals_insert_own"
  on public.meals for insert
  with check (auth.uid() = user_id);

create policy if not exists "meals_update_own"
  on public.meals for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy if not exists "meals_delete_own"
  on public.meals for delete
  using (auth.uid() = user_id);

-- Check-ins policies
create policy if not exists "check_ins_select_own"
  on public.check_ins for select
  using (auth.uid() = user_id);

create policy if not exists "check_ins_insert_own"
  on public.check_ins for insert
  with check (auth.uid() = user_id);

create policy if not exists "check_ins_update_own"
  on public.check_ins for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy if not exists "check_ins_delete_own"
  on public.check_ins for delete
  using (auth.uid() = user_id);

-- Exercise sets policies (owned via check-in)
create policy if not exists "exercise_sets_select_own"
  on public.exercise_sets for select
  using (
    exists (
      select 1 from public.check_ins ci
      where ci.id = check_in_id and ci.user_id = auth.uid()
    )
  );

create policy if not exists "exercise_sets_insert_own"
  on public.exercise_sets for insert
  with check (
    exists (
      select 1 from public.check_ins ci
      where ci.id = check_in_id and ci.user_id = auth.uid()
    )
  );

create policy if not exists "exercise_sets_update_own"
  on public.exercise_sets for update
  using (
    exists (
      select 1 from public.check_ins ci
      where ci.id = check_in_id and ci.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.check_ins ci
      where ci.id = check_in_id and ci.user_id = auth.uid()
    )
  );

create policy if not exists "exercise_sets_delete_own"
  on public.exercise_sets for delete
  using (
    exists (
      select 1 from public.check_ins ci
      where ci.id = check_in_id and ci.user_id = auth.uid()
    )
  );

-- Meal logs policies
create policy if not exists "meal_logs_select_own"
  on public.meal_logs for select
  using (auth.uid() = user_id);

create policy if not exists "meal_logs_insert_own"
  on public.meal_logs for insert
  with check (auth.uid() = user_id);

create policy if not exists "meal_logs_update_own"
  on public.meal_logs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy if not exists "meal_logs_delete_own"
  on public.meal_logs for delete
  using (auth.uid() = user_id);
