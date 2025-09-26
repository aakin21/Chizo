# Chizo Database Setup Guide

## 🎯 Database Setup - Step by Step

### 1. Access Supabase Dashboard
- Login to your Supabase project dashboard
- Navigate to the **SQL Editor** tab

### 2. Run the Complete Setup Script
Copy and paste the entire contents of `complete_database_setup.sql` into the SQL Editor and run it.

### 3. Verify Database Tables
After running the script, check that these tables exist:
- ✅ `users`
- ✅ `matches` 
- ✅ `votes`
- ✅ `tournaments`
- ✅ `tournament_participants`
- ✅ `tournament_votes`
- ✅ `user_photos`
- ✅ `photo_stats`
- ✅ `coin_transactions`
- ✅ `payments`
- ✅ `winrate_predictions`

### 4. Storage Buckets
The script also creates these storage buckets:
- ✅ `profile-images` 
- ✅ `tournament-photos`

### 5. Test Your App
Once the database is set up:
1. Run `flutter pub get`
2. Start your app with `flutter run`
3. Test user registration and match creation

## 🔍 What the Database Setup Includes

### Tables Created:
- **Users**: User profiles with coins, preferences, photos
- **Matches**: Voting matches between users
- **Votes**: User voting records
- **Tournaments**: Tournament events
- **Tournament Participants**: Who's in each tournament
- **Tournament Votes**: Voting in tournaments
- **User Photos**: Multi-photo uploads (slots 1-5)
- **Photo Stats**: Win/loss stats per photo
- **Coin Transactions**: All coin movements
- **Payments**: Purchase records
- **Win Rate Predictions**: User prediction system

### Security Features:
- Row Level Security (RLS) policies
- Proper foreign key relationships
- Access controls for data protection

### Helper Functions:
- Tournament participant counters
- Score incrementing
- Auto-updated timestamps

### Storage Integration:
- Photo upload buckets
- Public access for viewing images
- Private upload rights

## ✅ Your Database is Ready!
Your Chizo tournament app now has a complete, secure database ready to handle:
- User management
- Tournament hosting
- Photo uploads 
- Voting system
- Coin economy
- Prediction scoring

Start testing your app now!
