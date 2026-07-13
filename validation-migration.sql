-- ============================================================
-- VALIDATION SIGN-OFF MIGRATION
-- Run this in Supabase SQL Editor
-- ============================================================

-- 1. VALIDATION SIGNOFFS TABLE
-- Tracks who signed off each employee on each validation item, and when.

CREATE TABLE IF NOT EXISTS validation_signoffs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  item_id       UUID NOT NULL REFERENCES module_items(id) ON DELETE CASCADE,
  signed_off_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  location_id   UUID REFERENCES locations(id) ON DELETE SET NULL,
  signed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  notes         TEXT,
  UNIQUE (employee_id, item_id)   -- one sign-off record per employee per item
);

-- 2. ROW LEVEL SECURITY

ALTER TABLE validation_signoffs ENABLE ROW LEVEL SECURITY;

-- Employees can read their own sign-offs
-- Managers can read sign-offs at their location
-- Admins can read all
CREATE POLICY "signoffs_select" ON validation_signoffs
  FOR SELECT TO authenticated
  USING (
    employee_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
        AND (
          role = 'admin'
          OR (role = 'manager' AND location_id = validation_signoffs.location_id)
        )
    )
  );

-- Only managers and admins can create sign-offs
CREATE POLICY "signoffs_insert" ON validation_signoffs
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'manager')
    )
  );

-- Managers/admins can update (re-sign-off if needed)
CREATE POLICY "signoffs_update" ON validation_signoffs
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'manager')
    )
  );


-- 3. sign_off_validation RPC
-- Called from the employee's training module when a manager taps their PIN.
-- Finds which manager owns that PIN, records the sign-off, and marks the
-- item complete in employee_progress.
-- Returns { success: bool, manager_name: text, error: text }

CREATE OR REPLACE FUNCTION sign_off_validation(
  p_location_id  UUID,
  p_pin          TEXT,
  p_employee_id  UUID,
  p_item_id      UUID,
  p_notes        TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_manager_id   UUID;
  v_manager_name TEXT;
BEGIN
  -- Verify PIN and find manager
  SELECT id, full_name
  INTO v_manager_id, v_manager_name
  FROM profiles
  WHERE location_id = p_location_id
    AND manager_pin  = p_pin
    AND role IN ('manager', 'admin')
  LIMIT 1;

  IF v_manager_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid PIN');
  END IF;

  -- Upsert the sign-off (update if they were re-signed)
  INSERT INTO validation_signoffs
    (employee_id, item_id, signed_off_by, location_id, notes, signed_at)
  VALUES
    (p_employee_id, p_item_id, v_manager_id, p_location_id, p_notes, now())
  ON CONFLICT (employee_id, item_id) DO UPDATE
    SET signed_off_by = v_manager_id,
        signed_at     = now(),
        notes         = COALESCE(p_notes, validation_signoffs.notes);

  -- Mark item complete in employee_progress (same as passing a quiz)
  INSERT INTO employee_progress (user_id, module_item_id)
  VALUES (p_employee_id, p_item_id)
  ON CONFLICT DO NOTHING;

  RETURN jsonb_build_object('success', true, 'manager_name', v_manager_name);
END;
$$;

GRANT EXECUTE ON FUNCTION sign_off_validation(UUID, TEXT, UUID, UUID, TEXT) TO authenticated;


-- 4. batch_sign_off_validation RPC
-- Called from the AdminPanel ValidationTab when a manager signs off
-- multiple employees on one item at once.
-- Returns { success: bool, signed_count: int, error: text }

CREATE OR REPLACE FUNCTION batch_sign_off_validation(
  p_location_id  UUID,
  p_pin          TEXT,
  p_employee_ids UUID[],
  p_item_id      UUID,
  p_notes        TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_manager_id   UUID;
  v_manager_name TEXT;
  v_emp_id       UUID;
  v_count        INT := 0;
BEGIN
  -- Verify PIN
  SELECT id, full_name
  INTO v_manager_id, v_manager_name
  FROM profiles
  WHERE location_id = p_location_id
    AND manager_pin  = p_pin
    AND role IN ('manager', 'admin')
  LIMIT 1;

  IF v_manager_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid PIN');
  END IF;

  -- Sign off each employee
  FOREACH v_emp_id IN ARRAY p_employee_ids LOOP
    INSERT INTO validation_signoffs
      (employee_id, item_id, signed_off_by, location_id, notes, signed_at)
    VALUES
      (v_emp_id, p_item_id, v_manager_id, p_location_id, p_notes, now())
    ON CONFLICT (employee_id, item_id) DO UPDATE
      SET signed_off_by = v_manager_id,
          signed_at     = now(),
          notes         = COALESCE(p_notes, validation_signoffs.notes);

    INSERT INTO employee_progress (user_id, module_item_id)
    VALUES (v_emp_id, p_item_id)
    ON CONFLICT DO NOTHING;

    v_count := v_count + 1;
  END LOOP;

  RETURN jsonb_build_object('success', true, 'signed_count', v_count, 'manager_name', v_manager_name);
END;
$$;

GRANT EXECUTE ON FUNCTION batch_sign_off_validation(UUID, TEXT, UUID[], UUID, TEXT) TO authenticated;


-- 5. pre_complete_track RPC
-- Marks all current items in a track as complete for an employee.
-- Used when assigning an already-trained employee to a track so they
-- don't have to redo training they've already completed in person.

CREATE OR REPLACE FUNCTION pre_complete_track(
  p_employee_id UUID,
  p_track_id    UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO employee_progress (user_id, module_item_id)
  SELECT p_employee_id, mi.id
  FROM module_items mi
  JOIN modules m ON m.id = mi.module_id
  WHERE m.track_id = p_track_id
    AND mi.type IN ('checklist', 'quiz', 'validation')
  ON CONFLICT DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION pre_complete_track(UUID, UUID) TO authenticated;
