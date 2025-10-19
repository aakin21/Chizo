-- Fix photo_order values for existing photos
-- This script assigns proper photo_order values to photos that have null photo_order

-- First, let's see what we have
SELECT id, user_id, photo_order, is_active, created_at 
FROM user_photos 
WHERE photo_order IS NULL 
ORDER BY user_id, created_at;

-- Update photos with null photo_order
-- Assign sequential numbers starting from 1 for each user
WITH ranked_photos AS (
  SELECT 
    id,
    user_id,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) as new_order
  FROM user_photos 
  WHERE photo_order IS NULL AND is_active = true
)
UPDATE user_photos 
SET photo_order = ranked_photos.new_order
FROM ranked_photos 
WHERE user_photos.id = ranked_photos.id;

-- Verify the results
SELECT user_id, photo_order, is_active, COUNT(*) as count
FROM user_photos 
GROUP BY user_id, photo_order, is_active
ORDER BY user_id, photo_order;


