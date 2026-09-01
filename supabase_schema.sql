-- ============================================================
-- FitBuddy Supabase Schema
-- Run this entire file in the Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. PROFILES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    user_id TEXT UNIQUE NOT NULL,          -- unique handle (e.g. @fitbuddy123)
    username TEXT NOT NULL,                 -- display name
    bio TEXT DEFAULT '',
    avatar_url TEXT DEFAULT '',
    background_url TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Anyone can read profiles
CREATE POLICY "Profiles are viewable by everyone"
    ON public.profiles FOR SELECT
    USING (true);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Grant table-level permissions (required for RLS policies to work)
GRANT SELECT ON public.profiles TO anon, authenticated;
GRANT INSERT ON public.profiles TO authenticated;
GRANT UPDATE ON public.profiles TO authenticated;

-- Auto-update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_profiles_updated
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();


-- ============================================================
-- 2. FOLLOWS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.follows (
    follower_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (follower_id, following_id),
    CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

-- Anyone authenticated can see follows
CREATE POLICY "Follows are viewable by authenticated users"
    ON public.follows FOR SELECT
    TO authenticated
    USING (true);

-- Users can only create follows where they are the follower
CREATE POLICY "Users can follow others"
    ON public.follows FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = follower_id);

-- Users can only delete their own follows
CREATE POLICY "Users can unfollow"
    ON public.follows FOR DELETE
    TO authenticated
    USING (auth.uid() = follower_id);


-- ============================================================
-- 3. CHAT ROOMS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 4. CHAT MEMBERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.chat_members (
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (room_id, user_id)
);

ALTER TABLE public.chat_members ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- Policies for chat_rooms
-- ------------------------------------------------------------
-- Users can see rooms they are a member of
CREATE POLICY "Users can view their chat rooms"
    ON public.chat_rooms FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.chat_members
            WHERE chat_members.room_id = chat_rooms.id
            AND chat_members.user_id = auth.uid()
        )
    );

-- Authenticated users can create chat rooms
CREATE POLICY "Authenticated users can create chat rooms"
    ON public.chat_rooms FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Helper function to break RLS recursion for chat rooms (SECURITY DEFINER bypasses RLS recursion)
CREATE OR REPLACE FUNCTION public.is_chat_member(p_room_id UUID, p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.chat_members
        WHERE room_id = p_room_id AND user_id = p_user_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.is_chat_member(UUID, UUID) TO authenticated;

-- Users can only see members of rooms they belong to (uses SECURITY DEFINER function to avoid recursion)
CREATE POLICY "Users can view members of their rooms"
    ON public.chat_members FOR SELECT
    TO authenticated
    USING (public.is_chat_member(room_id, auth.uid()));

-- Users can only add themselves to NEW chat rooms (rooms with < 2 members)
-- The get_or_create_dm_room RPC uses SECURITY DEFINER to bypass this for both members.
-- This prevents unauthorized users from joining existing private DM rooms.
CREATE POLICY "Users can only add themselves to new rooms"
    ON public.chat_members FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = user_id
        AND (SELECT COUNT(*) FROM public.chat_members WHERE room_id = chat_members.room_id) < 2
    );


-- ============================================================
-- 5. MESSAGES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Users can see messages in rooms they belong to
CREATE POLICY "Users can view messages in their rooms"
    ON public.messages FOR SELECT
    TO authenticated
    USING (public.is_chat_member(room_id, auth.uid()));

-- Users can send messages to rooms they belong to
CREATE POLICY "Users can send messages to their rooms"
    ON public.messages FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = sender_id
        AND public.is_chat_member(room_id, auth.uid())
    );

-- Users can delete their own messages
CREATE POLICY "Users can delete own messages"
    ON public.messages FOR DELETE
    TO authenticated
    USING (auth.uid() = sender_id);


-- ============================================================
-- 6. HELPER FUNCTION: Find or create a DM room between two users
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_or_create_dm_room(other_user_id UUID)
RETURNS UUID AS $$
DECLARE
    existing_room_id UUID;
    new_room_id UUID;
    current_user_id UUID := auth.uid();
BEGIN
    -- Safety: can't DM yourself
    IF current_user_id = other_user_id THEN
        RAISE EXCEPTION 'Cannot create a chat room with yourself';
    END IF;

    -- Enforce mutual follow before allowing room creation
    IF NOT EXISTS (
        SELECT 1 FROM public.follows 
        WHERE follower_id = current_user_id AND following_id = other_user_id
    ) OR NOT EXISTS (
        SELECT 1 FROM public.follows 
        WHERE follower_id = other_user_id AND following_id = current_user_id
    ) THEN
        RAISE EXCEPTION 'Mutual follow required to start a conversation';
    END IF;

    -- Find existing DM room between the two users
    SELECT cm1.room_id INTO existing_room_id
    FROM public.chat_members cm1
    JOIN public.chat_members cm2 ON cm1.room_id = cm2.room_id
    WHERE cm1.user_id = current_user_id
      AND cm2.user_id = other_user_id
      AND (SELECT COUNT(*) FROM public.chat_members WHERE room_id = cm1.room_id) = 2
    LIMIT 1;

    IF existing_room_id IS NOT NULL THEN
        RETURN existing_room_id;
    END IF;

    -- Create new room
    INSERT INTO public.chat_rooms DEFAULT VALUES
    RETURNING id INTO new_room_id;

    -- Add both users (SECURITY DEFINER bypasses the INSERT policy)
    INSERT INTO public.chat_members (room_id, user_id) VALUES (new_room_id, current_user_id);
    INSERT INTO public.chat_members (room_id, user_id) VALUES (new_room_id, other_user_id);

    RETURN new_room_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.get_or_create_dm_room(UUID) TO authenticated;


-- ============================================================
-- 7. HELPER FUNCTION: Check mutual follow
-- ============================================================
CREATE OR REPLACE FUNCTION public.check_mutual_follow(user_a UUID, user_b UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.follows WHERE follower_id = user_a AND following_id = user_b
    ) AND EXISTS (
        SELECT 1 FROM public.follows WHERE follower_id = user_b AND following_id = user_a
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.check_mutual_follow(UUID, UUID) TO authenticated;


-- ============================================================
-- 8. HELPER FUNCTION: Get follow state & counts in ONE query
--    Eliminates 4 roundtrips -> 1 roundtrip
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_profile_follow_state(target_user_id UUID)
RETURNS TABLE (
    is_following BOOLEAN,
    is_followed_by BOOLEAN,
    is_mutual_follow BOOLEAN,
    follower_count INT,
    following_count INT
) AS $$
DECLARE
    me UUID := auth.uid();
    v_is_following BOOLEAN := false;
    v_they_follow BOOLEAN := false;
    v_followers INT := 0;
    v_following INT := 0;
BEGIN
    IF me IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM public.follows WHERE follower_id = me AND following_id = target_user_id
        ) INTO v_is_following;

        SELECT EXISTS(
            SELECT 1 FROM public.follows WHERE follower_id = target_user_id AND following_id = me
        ) INTO v_they_follow;
    END IF;

    SELECT COUNT(*)::INT INTO v_followers
    FROM public.follows
    WHERE following_id = target_user_id;

    SELECT COUNT(*)::INT INTO v_following
    FROM public.follows
    WHERE follower_id = target_user_id;

    RETURN QUERY
    SELECT 
        v_is_following,
        v_they_follow,
        (v_is_following AND v_they_follow),
        v_followers,
        v_following;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.get_profile_follow_state(UUID) TO authenticated, anon;


-- ============================================================
-- 9. HELPER FUNCTION: High-performance profile search
-- ============================================================
CREATE OR REPLACE FUNCTION public.search_profiles(
    search_query TEXT, 
    current_user_id UUID DEFAULT NULL, 
    result_limit INT DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    user_id TEXT,
    username TEXT,
    bio TEXT,
    avatar_url TEXT,
    background_url TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id, 
        p.user_id, 
        p.username, 
        p.bio, 
        p.avatar_url, 
        p.background_url
    FROM public.profiles p
    WHERE (
        p.username ILIKE ('%' || search_query || '%') 
        OR p.user_id ILIKE ('%' || search_query || '%')
    )
    AND (current_user_id IS NULL OR p.id != current_user_id)
    ORDER BY 
        -- Prioritize exact prefix matches at top of search results
        CASE 
            WHEN p.username ILIKE (search_query || '%') THEN 1
            WHEN p.user_id ILIKE (search_query || '%') THEN 2
            ELSE 3
        END,
        p.username ASC
    LIMIT result_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.search_profiles(TEXT, UUID, INT) TO authenticated;


-- ============================================================
-- 10. HELPER FUNCTION: Get all chat room previews in ONE query
--    Eliminates N+1 problem: replaces (1 + 3×N) requests with 1
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_my_chat_rooms()
RETURNS TABLE (
    room_id         UUID,
    other_user_id   UUID,
    other_user_uid  TEXT,
    other_username  TEXT,
    other_bio       TEXT,
    other_avatar    TEXT,
    other_bg        TEXT,
    last_msg_id     UUID,
    last_msg_content TEXT,
    last_msg_sender UUID,
    last_msg_at     TIMESTAMPTZ
) AS $$
DECLARE
    me UUID := auth.uid();
BEGIN
    RETURN QUERY
    SELECT
        cm_me.room_id,
        p.id              AS other_user_id,
        p.user_id         AS other_user_uid,
        p.username        AS other_username,
        p.bio             AS other_bio,
        p.avatar_url      AS other_avatar,
        p.background_url  AS other_bg,
        lm.m_id           AS last_msg_id,
        lm.m_content      AS last_msg_content,
        lm.m_sender       AS last_msg_sender,
        lm.m_created      AS last_msg_at
    FROM public.chat_members cm_me
    -- Find the other member in same room (not me)
    JOIN public.chat_members cm_other
        ON cm_other.room_id = cm_me.room_id
       AND cm_other.user_id != me
    -- Get other user's profile
    JOIN public.profiles p
        ON p.id = cm_other.user_id
    -- Get last message (lateral join = efficient, no subquery for each row)
    LEFT JOIN LATERAL (
        SELECT 
            msg.id         AS m_id,
            msg.content    AS m_content,
            msg.sender_id  AS m_sender,
            msg.created_at AS m_created
        FROM public.messages msg
        WHERE msg.room_id = cm_me.room_id
        ORDER BY msg.created_at DESC
        LIMIT 1
    ) lm ON true
    WHERE cm_me.user_id = me
    ORDER BY lm.m_created DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.get_my_chat_rooms() TO authenticated;



-- ============================================================
-- 11. STORAGE BUCKETS & POLICIES
-- ============================================================
-- Ensure avatars and backgrounds buckets exist and are marked public
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('avatars', 'avatars', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
    ('backgrounds', 'backgrounds', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO UPDATE SET 
    public = true,
    file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- Drop existing policies if any to allow clean re-runs
DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users have full access to their own avatar folder" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Users have full access to their own background folder" ON storage.objects;

-- Storage policies for avatars
CREATE POLICY "Anyone can view avatars"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');

CREATE POLICY "Users have full access to their own avatar folder" 
    ON storage.objects FOR ALL 
    TO authenticated 
    USING (bucket_id = 'avatars' AND lower((storage.foldername(name))[1]) = auth.uid()::text)
    WITH CHECK (bucket_id = 'avatars' AND lower((storage.foldername(name))[1]) = auth.uid()::text);

-- Storage policies for backgrounds
CREATE POLICY "Anyone can view backgrounds"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'backgrounds');

CREATE POLICY "Users have full access to their own background folder" 
    ON storage.objects FOR ALL 
    TO authenticated 
    USING (bucket_id = 'backgrounds' AND lower((storage.foldername(name))[1]) = auth.uid()::text)
    WITH CHECK (bucket_id = 'backgrounds' AND lower((storage.foldername(name))[1]) = auth.uid()::text);


-- ============================================================
-- 12. ENABLE REALTIME for messages
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;


-- ============================================================
-- 13. EXTENSIONS & INDEXES for Performance
-- ============================================================
-- Enable Trigram extension for fast sub-millisecond substring searching
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- GIN Trigram indexes on profiles (eliminates full table scans for ILIKE %...%)
CREATE INDEX IF NOT EXISTS idx_profiles_username_trgm ON public.profiles USING gin (username gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id_trgm ON public.profiles USING gin (user_id gin_trgm_ops);

-- Performance indexes (optimized: no duplicate single/composite or ASC/DESC redundancy)
CREATE INDEX IF NOT EXISTS idx_follows_follower ON public.follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON public.follows(following_id);
CREATE INDEX IF NOT EXISTS idx_messages_room_id ON public.messages(room_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_members_composite ON public.chat_members(user_id, room_id);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);


-- ============================================================
-- 14. CONTESTS, SUBMISSIONS, LEADERBOARD & RANKINGS
-- ============================================================

-- Contests Table
CREATE TABLE IF NOT EXISTS public.contests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_name TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    difficulty TEXT DEFAULT 'medium',
    target_reps INT DEFAULT 20,
    target_time INT DEFAULT 60,
    points_reward INT DEFAULT 100,
    is_active BOOLEAN DEFAULT true,
    starts_at TIMESTAMPTZ DEFAULT now(),
    ends_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.contests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Contests are viewable by everyone"
    ON public.contests FOR SELECT
    USING (true);

GRANT SELECT ON public.contests TO anon, authenticated;


-- Contest Submissions Table
CREATE TABLE IF NOT EXISTS public.contest_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contest_id UUID NOT NULL REFERENCES public.contests(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    total_correct INT NOT NULL DEFAULT 0,
    total_incorrect INT NOT NULL DEFAULT 0,
    accuracy INT NOT NULL DEFAULT 0,
    total_time INT NOT NULL DEFAULT 0,
    points_earned INT NOT NULL DEFAULT 0,
    attempts_count INT NOT NULL DEFAULT 1 CHECK (attempts_count >= 1 AND attempts_count <= 3),
    submitted_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_contest_user UNIQUE (contest_id, user_id)
);

ALTER TABLE public.contest_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Contest submissions are viewable by everyone"
    ON public.contest_submissions FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own submissions"
    ON public.contest_submissions FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own submissions"
    ON public.contest_submissions FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

GRANT SELECT ON public.contest_submissions TO anon, authenticated;
GRANT INSERT, UPDATE ON public.contest_submissions TO authenticated;


-- Leaderboard View (Rankings per individual contest)
DROP VIEW IF EXISTS public.contest_leaderboard CASCADE;
CREATE VIEW public.contest_leaderboard 
WITH (security_invoker = true)
AS
SELECT 
    cs.contest_id,
    cs.user_id,
    p.username,
    p.avatar_url,
    cs.total_correct,
    cs.accuracy,
    cs.points_earned,
    cs.total_time,
    cs.attempts_count,
    cs.submitted_at,
    DENSE_RANK() OVER (
        PARTITION BY cs.contest_id 
        ORDER BY cs.points_earned DESC, cs.accuracy DESC, cs.total_time ASC
    ) AS rank
FROM public.contest_submissions cs
JOIN public.profiles p ON cs.user_id = p.id;

GRANT SELECT ON public.contest_leaderboard TO anon, authenticated;


-- Global Contest Ranking View (Aggregated across all contests)
DROP VIEW IF EXISTS public.global_contest_ranking CASCADE;
CREATE VIEW public.global_contest_ranking 
WITH (security_invoker = true)
AS
SELECT 
    cs.user_id,
    p.username,
    p.avatar_url,
    COALESCE(SUM(cs.points_earned), 0)::INT AS total_points,
    COUNT(cs.contest_id)::INT AS contests_completed,
    COALESCE(ROUND(AVG(cs.accuracy)::numeric, 1), 0)::FLOAT8 AS avg_accuracy,
    DENSE_RANK() OVER (
        ORDER BY COALESCE(SUM(cs.points_earned), 0) DESC, COALESCE(ROUND(AVG(cs.accuracy)::numeric, 1), 0) DESC
    ) AS rank
FROM public.contest_submissions cs
JOIN public.profiles p ON cs.user_id = p.id
GROUP BY cs.user_id, p.username, p.avatar_url;

GRANT SELECT ON public.global_contest_ranking TO anon, authenticated;


-- RPC: submit_contest_attempt (Enforces max 3 tries, keeps highest score)
CREATE OR REPLACE FUNCTION public.submit_contest_attempt(
    p_contest_id UUID,
    p_total_correct INT,
    p_total_incorrect INT,
    p_accuracy INT,
    p_total_time INT,
    p_points_earned INT
)
RETURNS JSONB AS $$
DECLARE
    v_user_id UUID;
    v_existing public.contest_submissions%ROWTYPE;
    v_new_attempts INT;
    v_is_best BOOLEAN := false;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Check if submission already exists
    SELECT * INTO v_existing 
    FROM public.contest_submissions 
    WHERE contest_id = p_contest_id AND user_id = v_user_id;

    IF NOT FOUND THEN
        -- Attempt 1
        INSERT INTO public.contest_submissions (
            contest_id, user_id, total_correct, total_incorrect,
            accuracy, total_time, points_earned, attempts_count, submitted_at
        ) VALUES (
            p_contest_id, v_user_id, p_total_correct, p_total_incorrect,
            p_accuracy, p_total_time, p_points_earned, 1, now()
        );
        
        RETURN jsonb_build_object(
            'success', true,
            'attempts_used', 1,
            'attempts_left', 2,
            'is_best_score', true,
            'points_earned', p_points_earned
        );
    ELSE
        -- Validate maximum 3 attempts
        IF v_existing.attempts_count >= 3 THEN
            RAISE EXCEPTION 'Maximum attempts (3) reached for this contest';
        END IF;

        v_new_attempts := v_existing.attempts_count + 1;
        
        -- Check if new score is better than previous best score
        IF p_points_earned > v_existing.points_earned OR 
           (p_points_earned = v_existing.points_earned AND p_accuracy > v_existing.accuracy) THEN
            v_is_best := true;
            UPDATE public.contest_submissions
            SET total_correct = p_total_correct,
                total_incorrect = p_total_incorrect,
                accuracy = p_accuracy,
                total_time = p_total_time,
                points_earned = p_points_earned,
                attempts_count = v_new_attempts,
                submitted_at = now()
            WHERE contest_id = p_contest_id AND user_id = v_user_id;
        ELSE
            -- Increment attempts_count without lowering best score
            UPDATE public.contest_submissions
            SET attempts_count = v_new_attempts
            WHERE contest_id = p_contest_id AND user_id = v_user_id;
        END IF;

        RETURN jsonb_build_object(
            'success', true,
            'attempts_used', v_new_attempts,
            'attempts_left', GREATEST(0, 3 - v_new_attempts),
            'is_best_score', v_is_best,
            'points_earned', GREATEST(v_existing.points_earned, p_points_earned)
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.submit_contest_attempt(UUID, INT, INT, INT, INT, INT) TO authenticated;


-- Helper RPC: get_active_contests with submission & attempts state
DROP FUNCTION IF EXISTS public.get_active_contests(UUID);
CREATE OR REPLACE FUNCTION public.get_active_contests(p_user_id UUID DEFAULT NULL)
RETURNS TABLE (
    id UUID,
    exercise_name TEXT,
    title TEXT,
    description TEXT,
    difficulty TEXT,
    target_reps INT,
    target_time INT,
    points_reward INT,
    starts_at TIMESTAMPTZ,
    ends_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    participant_count INT,
    user_submitted BOOLEAN,
    user_points INT,
    user_accuracy INT,
    user_attempts_count INT,
    attempts_left INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.exercise_name,
        c.title,
        c.description,
        c.difficulty,
        c.target_reps,
        c.target_time,
        c.points_reward,
        c.starts_at,
        c.ends_at,
        c.created_at,
        (SELECT COUNT(*)::INT FROM public.contest_submissions cs_count WHERE cs_count.contest_id = c.id) AS participant_count,
        CASE WHEN p_user_id IS NOT NULL THEN
            EXISTS(SELECT 1 FROM public.contest_submissions cs WHERE cs.contest_id = c.id AND cs.user_id = p_user_id)
        ELSE false END AS user_submitted,
        CASE WHEN p_user_id IS NOT NULL THEN
            (SELECT cs.points_earned FROM public.contest_submissions cs WHERE cs.contest_id = c.id AND cs.user_id = p_user_id LIMIT 1)
        ELSE NULL END AS user_points,
        CASE WHEN p_user_id IS NOT NULL THEN
            (SELECT cs.accuracy FROM public.contest_submissions cs WHERE cs.contest_id = c.id AND cs.user_id = p_user_id LIMIT 1)
        ELSE NULL END AS user_accuracy,
        CASE WHEN p_user_id IS NOT NULL THEN
            COALESCE((SELECT cs.attempts_count FROM public.contest_submissions cs WHERE cs.contest_id = c.id AND cs.user_id = p_user_id LIMIT 1), 0)
        ELSE 0 END AS user_attempts_count,
        CASE WHEN p_user_id IS NOT NULL THEN
            GREATEST(0, 3 - COALESCE((SELECT cs.attempts_count FROM public.contest_submissions cs WHERE cs.contest_id = c.id AND cs.user_id = p_user_id LIMIT 1), 0))
        ELSE 3 END AS attempts_left
    FROM public.contests c
    WHERE c.is_active = true
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.get_active_contests(UUID) TO anon, authenticated;


