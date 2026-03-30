-- ============================================================
-- Leaves Calculator — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- 1. EMPLOYEES
CREATE TABLE IF NOT EXISTS public.employees (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    job_id text NOT NULL,
    name text NOT NULL,
    dept text DEFAULT '',
    company text DEFAULT '',
    hire_date date,
    created_at timestamptz DEFAULT now(),
    UNIQUE(user_id, job_id)
);

ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sel_employees" ON public.employees FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "ins_employees" ON public.employees FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "upd_employees" ON public.employees FOR UPDATE TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "del_employees" ON public.employees FOR DELETE TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- 2. EXTRA HOURS (Compensatory)
CREATE TABLE IF NOT EXISTS public.extra_hours (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    job_id text NOT NULL,
    name text DEFAULT '',
    date date NOT NULL,
    hours numeric NOT NULL,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE public.extra_hours ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sel_extra_hours" ON public.extra_hours FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "ins_extra_hours" ON public.extra_hours FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "upd_extra_hours" ON public.extra_hours FOR UPDATE TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "del_extra_hours" ON public.extra_hours FOR DELETE TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- 3. CALCULATED BALANCES (Archived snapshots)
CREATE TABLE IF NOT EXISTS public.calculated_balances (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    job_id text NOT NULL,
    name text NOT NULL,
    calc_date text NOT NULL,
    annual_hours numeric NOT NULL DEFAULT 0,
    comp_hours numeric NOT NULL DEFAULT 0,
    total_days numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    UNIQUE(user_id, job_id)
);

ALTER TABLE public.calculated_balances ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sel_calc_bal" ON public.calculated_balances FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "ins_calc_bal" ON public.calculated_balances FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "upd_calc_bal" ON public.calculated_balances FOR UPDATE TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "del_calc_bal" ON public.calculated_balances FOR DELETE TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- 4. TAKEN LEAVES
CREATE TABLE IF NOT EXISTS public.taken_leaves (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    job_id text NOT NULL,
    name text DEFAULT '',
    dept text DEFAULT '',
    company text DEFAULT '',
    req_date date,
    req_time time,
    start_date date,
    start_time time,
    return_date date,
    reason text DEFAULT '',
    total numeric NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE public.taken_leaves ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sel_taken_leaves" ON public.taken_leaves FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "ins_taken_leaves" ON public.taken_leaves FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "upd_taken_leaves" ON public.taken_leaves FOR UPDATE TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "del_taken_leaves" ON public.taken_leaves FOR DELETE TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- 5. USAGE OVERRIDES (manual consumption per year)
CREATE TABLE IF NOT EXISTS public.usage_overrides (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    job_id text NOT NULL,
    year integer NOT NULL,
    hours numeric NOT NULL DEFAULT 0,
    UNIQUE(user_id, job_id, year)
);

ALTER TABLE public.usage_overrides ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sel_usage_ovr" ON public.usage_overrides FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "ins_usage_ovr" ON public.usage_overrides FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);
CREATE POLICY "upd_usage_ovr" ON public.usage_overrides FOR UPDATE TO authenticated
    USING ((SELECT auth.uid()) = user_id);
CREATE POLICY "del_usage_ovr" ON public.usage_overrides FOR DELETE TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- 6. PERFORMANCE INDEXES
CREATE INDEX IF NOT EXISTS idx_employees_user_job    ON public.employees(user_id, job_id);
CREATE INDEX IF NOT EXISTS idx_extra_hours_user_job  ON public.extra_hours(user_id, job_id);
CREATE INDEX IF NOT EXISTS idx_calc_bal_user_job     ON public.calculated_balances(user_id, job_id);
CREATE INDEX IF NOT EXISTS idx_taken_leaves_user_job ON public.taken_leaves(user_id, job_id);
CREATE INDEX IF NOT EXISTS idx_usage_ovr_user_job    ON public.usage_overrides(user_id, job_id);
