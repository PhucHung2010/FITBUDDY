-- ============================================
-- STEP 1: Add columns to profiles
-- ============================================
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS points int DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS badge text;


-- ============================================
-- STEP 2: Create contests table
-- ============================================
CREATE TABLE IF NOT EXISTS contests (
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
  created_at timestamptz DEFAULT now()
);

ALTER TABLE contests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view contests"
ON contests FOR SELECT
TO public
USING (true);


-- ============================================
-- STEP 3: Create contest_participants table
-- ============================================
CREATE TABLE IF NOT EXISTS contest_participants (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  contest_id uuid REFERENCES contests(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  accuracy double precision,
  time_seconds double precision,
  completed boolean DEFAULT false,
  joined_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  UNIQUE(contest_id, user_id)
);

ALTER TABLE contest_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view participants"
ON contest_participants FOR SELECT
TO public
USING (true);

CREATE POLICY "Authenticated users can join contests"
ON contest_participants FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own results"
ON contest_participants FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);


-- ============================================
-- STEP 4: Insert sample contests
-- ============================================
INSERT INTO contests (title, description, exercise_name, target_reps, difficulty, points_reward, icon_system_name, color_hex, start_date, end_date)
VALUES
('Squat Champion', 'Complete 20 squats with the best form accuracy. Show everyone your leg power!', 'Squat', 20, 'medium', 150, 'figure.strengthtraining.traditional', '#4CAF50', now(), now() + interval '30 days'),
('Curl Master', 'Perfect your bicep curls. 15 reps, highest accuracy wins!', 'Dumbbell Curl', 15, 'easy', 100, 'dumbbell.fill', '#2196F3', now(), now() + interval '14 days'),
('Push-Up Beast', 'Show your chest strength. 25 push-ups with monitored form accuracy.', 'Push-Up', 25, 'hard', 250, 'flame.fill', '#FF5722', now(), now() + interval '7 days'),
('Jumping Jack Sprint', 'Cardio blast! Complete 30 jumping jacks at top accuracy.', 'Jumping Jack', 30, 'easy', 80, 'bolt.fill', '#FFC107', now(), now() + interval '7 days'),
('Core Crusher', 'Sit-up showdown! 20 sit-ups with the best form wins.', 'Sit-Up', 20, 'medium', 120, 'figure.core.training', '#9C27B0', now(), now() + interval '14 days');
