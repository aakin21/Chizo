-- =====================================================
-- NOTIFICATIONS TABLE - RLS POLICIES
-- =====================================================
-- Run these commands in Supabase SQL Editor to enable proper RLS
-- After running these, you can re-enable RLS on notifications table
-- =====================================================

-- 1. DROP existing policies (if any)
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can insert own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can delete own notifications" ON notifications;
DROP POLICY IF EXISTS "System can insert notifications" ON notifications;

-- =====================================================
-- 2. CREATE NEW POLICIES
-- =====================================================

-- SELECT: Users can view their own notifications
CREATE POLICY "Users can view own notifications"
ON notifications
FOR SELECT
TO authenticated
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_id = auth.uid()
  )
);

-- INSERT: System/authenticated users can create notifications for any user
-- (This allows notification_service.dart to create notifications)
CREATE POLICY "System can insert notifications"
ON notifications
FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Users can update (mark as read) their own notifications
CREATE POLICY "Users can update own notifications"
ON notifications
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

-- DELETE: Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
ON notifications
FOR DELETE
TO authenticated
USING (
  user_id IN (
    SELECT id FROM users WHERE auth_id = auth.uid()
  )
);

-- =====================================================
-- 3. RE-ENABLE RLS (after creating policies)
-- =====================================================

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

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
WHERE tablename = 'notifications';

-- =====================================================
-- NOTES:
-- =====================================================
--
-- The INSERT policy is permissive (WITH CHECK (true)) because:
-- - The notification_service.dart creates notifications for various users
-- - It runs with the current authenticated user's credentials
-- - It needs to be able to insert notifications for the target user_id
--
-- If you want to restrict INSERT to only allow creating notifications
-- for the current user, use this instead:
--
-- CREATE POLICY "Users can insert own notifications"
-- ON notifications
-- FOR INSERT
-- TO authenticated
-- WITH CHECK (
--   user_id IN (
--     SELECT id FROM users WHERE auth_id = auth.uid()
--   )
-- );
--
-- However, this would break system-generated notifications!
-- =====================================================
