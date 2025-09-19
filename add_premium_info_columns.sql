-- Premium bilgi görünürlük alanlarını ekle
ALTER TABLE users ADD COLUMN IF NOT EXISTS show_instagram BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS show_profession BOOLEAN DEFAULT false;
