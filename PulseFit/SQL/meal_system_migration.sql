-- Meal system compatibility + integrity migration
-- Safe to run multiple times.

begin;

-- Standardize meals.fat column (legacy column name: fats)
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'meals' and column_name = 'fats'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'meals' and column_name = 'fat'
  ) then
    alter table public.meals rename column fats to fat;
  end if;
end $$;

-- Standardize meal_logs.consumed_at column (legacy column name: eaten_at)
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'meal_logs' and column_name = 'eaten_at'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'meal_logs' and column_name = 'consumed_at'
  ) then
    alter table public.meal_logs rename column eaten_at to consumed_at;
  end if;
end $$;

alter table public.meals
  alter column name set not null,
  alter column calories set not null,
  alter column protein set not null,
  alter column carbs set not null,
  alter column fat set not null;

alter table public.meal_logs
  alter column consumed_at set default now(),
  alter column consumed_at set not null;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'meals_name_not_blank') then
    alter table public.meals
      add constraint meals_name_not_blank check (length(trim(name)) > 0);
  end if;

  if not exists (select 1 from pg_constraint where conname = 'meals_calories_non_negative') then
    alter table public.meals
      add constraint meals_calories_non_negative check (calories >= 0);
  end if;

  if not exists (select 1 from pg_constraint where conname = 'meals_protein_non_negative') then
    alter table public.meals
      add constraint meals_protein_non_negative check (protein >= 0);
  end if;

  if not exists (select 1 from pg_constraint where conname = 'meals_carbs_non_negative') then
    alter table public.meals
      add constraint meals_carbs_non_negative check (carbs >= 0);
  end if;

  if not exists (select 1 from pg_constraint where conname = 'meals_fat_non_negative') then
    alter table public.meals
      add constraint meals_fat_non_negative check (fat >= 0);
  end if;
end $$;

create index if not exists idx_meal_logs_user_consumed_at
  on public.meal_logs(user_id, consumed_at desc);

commit;
