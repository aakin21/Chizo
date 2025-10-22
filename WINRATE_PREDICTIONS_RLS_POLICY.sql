-- =====================================================
-- WINRATE_PREDICTIONS TABLE - RLS POLICIES
-- =====================================================
-- Run these commands in Supabase SQL Editor
-- =====================================================

-- 1. DROP existing policies (if any)
DROP POLICY IF EXISTS "Users can view own predictions" ON winrate_predictions;
DROP POLICY IF EXISTS "Users can insert own predictions" ON winrate_predictions;
DROP POLICY IF EXISTS "Users can update own predictions" ON winrate_predictions;
DROP POLICY IF EXISTS "Users can delete own predictions" ON winrate_predictions;

-- =====================================================
-- 2. CREATE NEW POLICIES
-- =====================================================

-- SELECT: Users can view their own predictions
CREATE POLICY "Users can view own predictions"
ON winrate_predictions
FOR SELECT
TO authenticated
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_id = auth.uid()
  )
);

-- INSERT: Users can insert their own predictions
CREATE POLICY "Users can insert own predictions"
ON winrate_predictions
FOR INSERT
TO authenticated
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE auth_id = auth.uid()
  )
);

-- UPDATE: Users can update their own predictions (optional - genelde prediction update etmeyiz)
CREATE POLICY "Users can update own predictions"
ON winrate_predictions
FOR UPDATE
TO authenticated
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_id = auth.uid()
  )
)
WITH CHECK (
  user_id IN (
    SELECT id FROM users WHERE auth_id = auth.uid()
  )
);

-- DELETE: Users can delete their own predictions (optional)
CREATE POLICY "Users can delete own predictions"
ON winrate_predictions
FOR DELETE
TO authenticated
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_id = auth.uid()
  )
);

-- =====================================================
-- 3. RE-ENABLE RLS (if disabled)
-- =====================================================

ALTER TABLE winrate_predictions ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. VERIFY POLICIES
-- =====================================================

-- Check that policies are created correctly:
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'winrate_predictions';

-- =====================================================
-- NOTES:
-- =====================================================
--
-- Bu policy'ler kullanıcıların:
-- - Sadece kendi tahminlerini görmesini (SELECT)
-- - Kendi tahminlerini oluşturmasını (INSERT)
-- - Kendi tahminlerini güncellemesini (UPDATE - optional)
-- - Kendi tahminlerini silmesini (DELETE - optional)
-- sağlar.
--
-- INSERT policy, kullanıcının sadece kendi user_id'si ile
-- tahmin oluşturmasına izin verir. Başkası adına tahmin
-- oluşturamazlar.
-- =====================================================
