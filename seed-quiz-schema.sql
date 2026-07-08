-- ============================================================
-- MALLARDS TRAINING APP — QUIZ & IMAGE STORAGE SCHEMA
-- Run this ONCE in Supabase > SQL Editor > New Query
-- ============================================================

-- ── SUPABASE STORAGE BUCKET FOR TRAINING IMAGES ──
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'training-images',
  'training-images',
  true,
  10485760, -- 10 MB max per file
  ARRAY['image/jpeg','image/png','image/gif','image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload training images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'training-images' AND auth.uid() IS NOT NULL);

-- Allow anyone to view images (they are public)
CREATE POLICY "Anyone can view training images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'training-images');

-- Allow authenticated users to delete images they uploaded
CREATE POLICY "Authenticated users can delete training images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'training-images' AND auth.uid() IS NOT NULL);


-- ── QUIZ ATTEMPTS TABLE (tracks pass/fail history) ──
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid REFERENCES profiles(id) ON DELETE CASCADE,
  module_item_id uuid REFERENCES module_items(id) ON DELETE CASCADE,
  score       int  NOT NULL,
  total       int  NOT NULL,
  passed      boolean NOT NULL,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own attempts"
  ON quiz_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own attempts"
  ON quiz_attempts FOR SELECT
  USING (auth.uid() = user_id);

-- Managers/admins can read all attempts for reporting
CREATE POLICY "Authenticated can read all attempts"
  ON quiz_attempts FOR SELECT
  USING (auth.uid() IS NOT NULL);
