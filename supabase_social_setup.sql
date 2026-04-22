-- ============================================
-- FITBUDDY SOCIAL SYSTEM SQL SETUP
-- ============================================
-- Execute this file in your Supabase SQL Editor.
-- Ensure you have completed the previous `supabase_contest_setup.sql` 
-- so the `profiles` table exists.

-- ============================================
-- STEP 1: Followers Table
-- ============================================
CREATE TABLE IF NOT EXISTS followers (
  follower_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  following_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (follower_id, following_id)
);

ALTER TABLE followers ENABLE ROW LEVEL SECURITY;

-- Anyone can see who follows who
CREATE POLICY "Public followers view"
ON followers FOR SELECT TO public USING (true);

-- A user can only follow others as themselves
CREATE POLICY "Users can follow"
ON followers FOR INSERT TO authenticated
WITH CHECK (auth.uid() = follower_id);

-- A user can unfollow
CREATE POLICY "Users can unfollow"
ON followers FOR DELETE TO authenticated
USING (auth.uid() = follower_id);

-- ============================================
-- STEP 2: Chat Rooms Table
-- ============================================
CREATE TABLE IF NOT EXISTS chat_rooms (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamptz DEFAULT now()
);

-- ============================================
-- STEP 3: Chat Participants Table
-- ============================================
CREATE TABLE IF NOT EXISTS chat_participants (
  room_id uuid REFERENCES chat_rooms(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (room_id, user_id)
);

-- ============================================
-- STEP 4: Chat Messages Table
-- ============================================
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id uuid REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- ============================================
-- STEP 5: Apply Policies
-- ============================================

-- Helper function to avoid infinite recursion when querying chat_participants
CREATE OR REPLACE FUNCTION is_room_participant(check_room_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM chat_participants
    WHERE room_id = check_room_id AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can create rooms"
ON chat_rooms FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Participants can view their rooms"
ON chat_rooms FOR SELECT TO authenticated
USING (
  is_room_participant(id)
);

ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can add participants to a room"
ON chat_participants FOR INSERT TO authenticated 
WITH CHECK (true); 

CREATE POLICY "Participants can view room members"
ON chat_participants FOR SELECT TO authenticated
USING (
  is_room_participant(room_id)
);

ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Participants can view messages"
ON chat_messages FOR SELECT TO authenticated
USING (
  is_room_participant(room_id)
);

CREATE POLICY "Participants can send messages"
ON chat_messages FOR INSERT TO authenticated
WITH CHECK (
  auth.uid() = sender_id AND
  is_room_participant(room_id)
);

-- ============================================
-- STEP 5: Follower Status View
-- ============================================
-- Quick helper to count followers / following for a user
CREATE OR REPLACE VIEW user_follow_stats AS
SELECT 
    p.id as user_id,
    (SELECT count(*) FROM followers WHERE following_id = p.id) as follower_count,
    (SELECT count(*) FROM followers WHERE follower_id = p.id) as following_count
FROM profiles p;

GRANT SELECT ON user_follow_stats TO public;

-- ============================================
-- STEP 6: PUBLICATION FOR REALTIME
-- ============================================
-- ⚠️ IMPORTANT: You MUST enable replication for realtime subscriptions!
-- To do this natively via SQL, run:
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime;
COMMIT;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
