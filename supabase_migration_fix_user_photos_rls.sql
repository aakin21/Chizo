-- Migration: Fix user_photos RLS policies
-- Date: $(date)
-- Description: Add Row Level Security policies for user_photos table

-- Enable RLS on user_photos table
ALTER TABLE user_photos ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own photos" ON user_photos;
DROP POLICY IF EXISTS "Users can insert their own photos" ON user_photos;
DROP POLICY IF EXISTS "Users can update their own photos" ON user_photos;
DROP POLICY IF EXISTS "Users can delete their own photos" ON user_photos;
DROP POLICY IF EXISTS "Users can view other users' active photos" ON user_photos;

-- Create new policies

-- Policy 1: Users can view their own photos
CREATE POLICY "Users can view their own photos" ON user_photos
    FOR SELECT USING (auth.uid()::text = user_id);

-- Policy 2: Users can insert their own photos
CREATE POLICY "Users can insert their own photos" ON user_photos
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

-- Policy 3: Users can update their own photos
CREATE POLICY "Users can update their own photos" ON user_photos
    FOR UPDATE USING (auth.uid()::text = user_id);

-- Policy 4: Users can delete their own photos
CREATE POLICY "Users can delete their own photos" ON user_photos
    FOR DELETE USING (auth.uid()::text = user_id);

-- Policy 5: Users can view other users' active photos (for profile viewing)
CREATE POLICY "Users can view other users' active photos" ON user_photos
    FOR SELECT USING (is_active = true);

-- Verify the policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'user_photos';
