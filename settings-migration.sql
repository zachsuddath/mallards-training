-- ── SETTINGS TABLE ────────────────────────────────────────────
-- Run this in Supabase SQL Editor once

CREATE TABLE IF NOT EXISTS settings (
  key   TEXT PRIMARY KEY,
  value TEXT
);

-- Default values
INSERT INTO settings (key, value) VALUES
  ('company_name',  'Mallards'),
  ('tagline',       'Training Portal'),
  ('primary_color', '#1B3A6B'),
  ('accent_color',  '#C9A227'),
  ('logo_url',      '')
ON CONFLICT (key) DO NOTHING;

-- Row Level Security
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Everyone can read settings (needed to show branding on login page too)
CREATE POLICY "settings_read_all" ON settings
  FOR SELECT USING (true);

-- Only admins can write
CREATE POLICY "settings_write_admin" ON settings
  FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
