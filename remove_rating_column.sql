-- Rating kolonunu sil (eğer varsa)
ALTER TABLE users DROP COLUMN IF EXISTS rating;

-- Rating ile ilgili index'leri sil (eğer varsa)
DROP INDEX IF EXISTS idx_users_rating;
