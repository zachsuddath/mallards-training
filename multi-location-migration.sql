-- ============================================================
-- MULTI-LOCATION MIGRATION
-- Run this in Supabase SQL Editor
-- ============================================================

-- 1. LOCATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS locations (
  id   uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

INSERT INTO locations (name) VALUES
  ('Shakopee'),
  ('Bloomington'),
  ('Inver Grove Heights'),
  ('Forest Lake'),
  ('Glendale (Bayshore Mall)')
ON CONFLICT (name) DO NOTHING;

ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "locations_read_all" ON locations;
CREATE POLICY "locations_read_all" ON locations
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "locations_admin_write" ON locations;
CREATE POLICY "locations_admin_write" ON locations
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));


-- 2. UPDATE PROFILES TABLE
-- ============================================================
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS location_id   uuid REFERENCES locations(id),
  ADD COLUMN IF NOT EXISTS manager_pin   TEXT,
  ADD COLUMN IF NOT EXISTS report_email  TEXT,
  ADD COLUMN IF NOT EXISTS status        TEXT NOT NULL DEFAULT 'active';

-- Add check constraint for status (safe to run multiple times via DO block)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'profiles_status_check'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT profiles_status_check
      CHECK (status IN ('active', 'pending', 'archived'));
  END IF;
END $$;


-- 3. PROFILES RLS — drop old policies, recreate scoped ones
-- ============================================================

-- Drop all known existing profile policies
DROP POLICY IF EXISTS "Users can view their own profile"       ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile"     ON profiles;
DROP POLICY IF EXISTS "Admins can view all profiles"           ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles"         ON profiles;
DROP POLICY IF EXISTS "profiles_read_own"                      ON profiles;
DROP POLICY IF EXISTS "profiles_update_own"                    ON profiles;
DROP POLICY IF EXISTS "profiles_admin_all"                     ON profiles;
DROP POLICY IF EXISTS "profiles_manager_location"              ON profiles;
DROP POLICY IF EXISTS "profiles_insert_own"                    ON profiles;

-- SELECT: own profile, or manager sees their location, or admin sees all
CREATE POLICY "profiles_select" ON profiles
  FOR SELECT TO authenticated
  USING (
    id = auth.uid()
    OR (
      EXISTS (
        SELECT 1 FROM profiles AS me
        WHERE me.id = auth.uid()
          AND me.role = 'manager'
          AND me.location_id = profiles.location_id
      )
    )
    OR EXISTS (SELECT 1 FROM profiles AS me WHERE me.id = auth.uid() AND me.role = 'admin')
  );

-- INSERT: anyone can insert their own profile (for self-signup)
CREATE POLICY "profiles_insert_own" ON profiles
  FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());

-- UPDATE: own profile, or manager updates employees at their location, or admin updates all
CREATE POLICY "profiles_update" ON profiles
  FOR UPDATE TO authenticated
  USING (
    id = auth.uid()
    OR (
      EXISTS (
        SELECT 1 FROM profiles AS me
        WHERE me.id = auth.uid()
          AND me.role = 'manager'
          AND me.location_id = profiles.location_id
      )
    )
    OR EXISTS (SELECT 1 FROM profiles AS me WHERE me.id = auth.uid() AND me.role = 'admin')
  )
  WITH CHECK (
    id = auth.uid()
    OR (
      EXISTS (
        SELECT 1 FROM profiles AS me
        WHERE me.id = auth.uid()
          AND me.role = 'manager'
          AND me.location_id = profiles.location_id
      )
    )
    OR EXISTS (SELECT 1 FROM profiles AS me WHERE me.id = auth.uid() AND me.role = 'admin')
  );


-- 4. RPC: VERIFY MANAGER PIN
-- Called from the app when an employee needs to unlock a test.
-- Returns true/false — never exposes the PIN value itself.
-- ============================================================
CREATE OR REPLACE FUNCTION verify_manager_pin(p_location_id uuid, p_pin text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE location_id = p_location_id
      AND role        = 'manager'
      AND manager_pin = p_pin
      AND status      = 'active'
  );
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION verify_manager_pin(uuid, text) TO authenticated;


-- 5. RPC: APPROVE EMPLOYEE
-- Managers / admins call this to flip status from pending -> active
-- ============================================================
CREATE OR REPLACE FUNCTION approve_employee(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  caller_role TEXT;
  caller_location uuid;
  target_location uuid;
BEGIN
  SELECT role, location_id INTO caller_role, caller_location
    FROM profiles WHERE id = auth.uid();

  SELECT location_id INTO target_location
    FROM profiles WHERE id = p_user_id;

  IF caller_role = 'admin'
     OR (caller_role = 'manager' AND caller_location = target_location)
  THEN
    UPDATE profiles SET status = 'active' WHERE id = p_user_id;
  ELSE
    RAISE EXCEPTION 'Not authorized';
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION approve_employee(uuid) TO authenticated;


-- Done!
-- After running this, the app will support:
--   - 5 locations
--   - manager role scoped to their location
--   - employee self-signup (status = 'pending' until approved)
--   - manager PIN for test gating
--   - archived status for terminated employees
