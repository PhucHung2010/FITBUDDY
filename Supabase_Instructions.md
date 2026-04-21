# Supabase SQL — Contest System Setup

Paste the following SQL into your **Supabase Dashboard → SQL Editor → New Query → Run**.

---

## Step 1: Add columns to profiles

```sql
-- Add points and badge columns to the existing profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS points int DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS badge text;
```

## Step 2: Create contests table

```sql
CREATE TABLE contests (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  description text,
  exercise_name text NOT NULL,
  target_reps int NOT NULL DEFAULT 10,
  difficulty text NOT NULL DEFAULT 'easy',
  points_reward int NOT NULL DEFAULT 50,
  icon_system_name text,
  color_hex text,
  start_date timestamptz,
  end_date timestamptz,
  created_at timestamptz DEFAULT timezone('utc'::text, now())
);

-- RLS: Anyone can view contests
ALTER TABLE contests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view contests"
ON contests FOR SELECT
TO public
USING (true);
```

## Step 3: Create contest_participants table

```sql
CREATE TABLE contest_participants (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  contest_id uuid REFERENCES contests(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  accuracy double precision,
  time_seconds double precision,
  completed boolean DEFAULT false,
  joined_at timestamptz DEFAULT timezone('utc'::text, now()),
  completed_at timestamptz,
  UNIQUE(contest_id, user_id)
);

-- RLS policies
ALTER TABLE contest_participants ENABLE ROW LEVEL SECURITY;

-- Anyone can view participants (for leaderboard)
CREATE POLICY "Anyone can view participants"
ON contest_participants FOR SELECT
TO public
USING (true);

-- Authenticated users can join contests
CREATE POLICY "Authenticated users can join contests"
ON contest_participants FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can update their own results
CREATE POLICY "Users can update own results"
ON contest_participants FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);
```

## Step 4: Insert sample contests

These exercise names match the 10 exercises available in the app:

```sql
INSERT INTO contests (title, description, exercise_name, target_reps, difficulty, points_reward, icon_system_name, color_hex, start_date, end_date) VALUES
(
  'Squat Champion',
  'Complete 20 squats with the best form accuracy. Show everyone your leg power!',
  'Squat',
  20,
  'medium',
  150,
  'figure.strengthtraining.traditional',
  '#4CAF50',
  NOW(),
  NOW() + INTERVAL '30 days'
),
(
  'Curl Master',
  'Perfect your bicep curls. 15 reps, highest accuracy wins!',
  'Dumbbell Curl',
  15,
  'easy',
  100,
  'dumbbell.fill',
  '#2196F3',
  NOW(),
  NOW() + INTERVAL '14 days'
),
(
  'Push-Up Beast',
  'Show your chest strength. 25 push-ups with monitored form accuracy.',
  'Push-Up',
  25,
  'hard',
  250,
  'flame.fill',
  '#FF5722',
  NOW(),
  NOW() + INTERVAL '7 days'
),
(
  'Jumping Jack Sprint',
  'Cardio blast! Complete 30 jumping jacks at top accuracy.',
  'Jumping Jack',
  30,
  'easy',
  80,
  'bolt.fill',
  '#FFC107',
  NOW(),
  NOW() + INTERVAL '7 days'
),
(
  'Core Crusher',
  'Sit-up showdown! 20 sit-ups with the best form wins.',
  'Sit-Up',
  20,
  'medium',
  120,
  'figure.core.training',
  '#9C27B0',
  NOW(),
  NOW() + INTERVAL '14 days'
);
```

> **Done!** After running all 4 steps, refresh the app and the contests will load automatically.
