-- FLEKKS Database Schema for Supabase
-- Simplified Team = Program model (like Ladder)
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    avatar_url TEXT,
    streak_count INTEGER DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    total_minutes INTEGER DEFAULT 0,
    current_team_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- ============================================
-- COACHES TABLE
-- ============================================
CREATE TABLE coaches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    credential TEXT,
    bio TEXT,
    avatar_url TEXT,
    hero_image_url TEXT,
    accent_color TEXT DEFAULT '#00d4aa',
    is_verified BOOLEAN DEFAULT FALSE,
    stripe_account_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE coaches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view verified coaches" ON coaches
    FOR SELECT USING (is_verified = TRUE);

CREATE POLICY "Coaches can update own profile" ON coaches
    FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- TEAMS TABLE (Team = Coach + Community + Program)
-- Each team IS a program - 1:1 relationship
-- ============================================
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID REFERENCES coaches(id) ON DELETE CASCADE,

    -- Team identity
    name TEXT NOT NULL,                    -- "Low Back Liberation", "Pike Perfection"
    tagline TEXT,                          -- Short hook: "Fix your low back for good"
    description TEXT,                      -- Full description
    focus TEXT,                            -- "Low Back Pain", "Pike Flexibility"

    -- Visual
    hero_gradient TEXT DEFAULT 'green',    -- 'green', 'purple', 'blue', 'teal'
    thumbnail_url TEXT,                    -- Team card thumbnail

    -- Program structure
    week_count INTEGER DEFAULT 6,          -- Program duration
    sessions_per_week INTEGER DEFAULT 5,   -- Sessions per week

    -- Stats
    member_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,     -- Show on explore page

    -- Pricing (for future)
    price_monthly INTEGER,                 -- In cents
    price_yearly INTEGER,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active teams" ON teams
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Coaches can manage own teams" ON teams
    FOR ALL USING (
        coach_id IN (SELECT id FROM coaches WHERE user_id = auth.uid())
    );

-- ============================================
-- TEAM MEMBERS (Junction Table)
-- ============================================
CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    current_week INTEGER DEFAULT 1,        -- User's progress in program
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(team_id, user_id)
);

ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own memberships" ON team_members
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own memberships" ON team_members
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- SESSIONS TABLE (Workouts within a Team)
-- ============================================
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,

    -- Position in program
    week_number INTEGER NOT NULL,
    day_number INTEGER NOT NULL,

    -- Content
    title TEXT NOT NULL,
    description TEXT,
    focus_area TEXT,                       -- "Hips", "Core", "Spine", etc.
    duration_minutes INTEGER,

    -- Mux Video (instead of Supabase storage)
    mux_playback_id TEXT,                  -- Mux public playback ID
    mux_asset_id TEXT,                     -- Mux asset ID (for management)
    thumbnail_url TEXT,                    -- Mux thumbnail or custom

    -- Metadata
    equipment TEXT[],                      -- ["mat", "foam roller", "band"]
    difficulty TEXT DEFAULT 'moderate',   -- 'easy', 'moderate', 'challenging'

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(team_id, week_number, day_number)
);

ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Team members can view sessions" ON sessions
    FOR SELECT USING (
        team_id IN (SELECT team_id FROM team_members WHERE user_id = auth.uid())
        OR team_id IN (SELECT id FROM teams WHERE coach_id IN (SELECT id FROM coaches WHERE user_id = auth.uid()))
    );

CREATE POLICY "Coaches can manage sessions" ON sessions
    FOR ALL USING (
        team_id IN (SELECT id FROM teams WHERE coach_id IN (SELECT id FROM coaches WHERE user_id = auth.uid()))
    );

-- ============================================
-- USER PROGRESS TABLE
-- ============================================
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    duration_seconds INTEGER,
    UNIQUE(user_id, session_id)
);

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own progress" ON user_progress
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- CHAT MESSAGES TABLE
-- ============================================
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Team members can view messages" ON chat_messages
    FOR SELECT USING (
        team_id IN (SELECT team_id FROM team_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Team members can send messages" ON chat_messages
    FOR INSERT WITH CHECK (
        team_id IN (SELECT team_id FROM team_members WHERE user_id = auth.uid())
        AND auth.uid() = user_id
    );

-- ============================================
-- BADGES TABLE
-- ============================================
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT NOT NULL,
    requirement_type TEXT,
    requirement_value INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own badges" ON user_badges
    FOR SELECT USING (auth.uid() = user_id);

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

CREATE OR REPLACE FUNCTION increment_team_members(team_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE teams SET member_count = member_count + 1 WHERE id = team_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION decrement_team_members(team_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE teams SET member_count = GREATEST(0, member_count - 1) WHERE id = team_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Auto-increment on team join
CREATE OR REPLACE FUNCTION on_team_member_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM increment_team_members(NEW.team_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER team_member_insert_trigger
    AFTER INSERT ON team_members
    FOR EACH ROW
    EXECUTE FUNCTION on_team_member_insert();

-- Auto-decrement on team leave
CREATE OR REPLACE FUNCTION on_team_member_delete()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM decrement_team_members(OLD.team_id);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER team_member_delete_trigger
    AFTER DELETE ON team_members
    FOR EACH ROW
    EXECUTE FUNCTION on_team_member_delete();

-- Streak update function
CREATE OR REPLACE FUNCTION update_user_streak()
RETURNS TRIGGER AS $$
DECLARE
    last_completion DATE;
BEGIN
    SELECT DATE(completed_at) INTO last_completion
    FROM user_progress
    WHERE user_id = NEW.user_id AND id != NEW.id
    ORDER BY completed_at DESC
    LIMIT 1;

    IF last_completion = CURRENT_DATE - INTERVAL '1 day' THEN
        UPDATE users SET
            streak_count = streak_count + 1,
            total_sessions = total_sessions + 1,
            total_minutes = total_minutes + COALESCE(NEW.duration_seconds / 60, 0)
        WHERE id = NEW.user_id;
    ELSIF last_completion = CURRENT_DATE THEN
        UPDATE users SET
            total_sessions = total_sessions + 1,
            total_minutes = total_minutes + COALESCE(NEW.duration_seconds / 60, 0)
        WHERE id = NEW.user_id;
    ELSE
        UPDATE users SET
            streak_count = 1,
            total_sessions = total_sessions + 1,
            total_minutes = total_minutes + COALESCE(NEW.duration_seconds / 60, 0)
        WHERE id = NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_session_complete
    AFTER INSERT ON user_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_user_streak();

-- ============================================
-- STORAGE BUCKETS (Avatars & Thumbnails only)
-- Videos are hosted on Mux
-- ============================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars', 'avatars', TRUE, 2097152,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'thumbnails', 'thumbnails', TRUE, 1048576,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Avatar policies
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Thumbnail policies
CREATE POLICY "Thumbnails are publicly accessible"
ON storage.objects FOR SELECT USING (bucket_id = 'thumbnails');

CREATE POLICY "Coaches can upload thumbnails"
ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'thumbnails'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

CREATE POLICY "Coaches can manage thumbnails"
ON storage.objects FOR UPDATE USING (
    bucket_id = 'thumbnails'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

CREATE POLICY "Coaches can delete thumbnails"
ON storage.objects FOR DELETE USING (
    bucket_id = 'thumbnails'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_team_members_user ON team_members(user_id);
CREATE INDEX idx_team_members_team ON team_members(team_id);
CREATE INDEX idx_chat_messages_team ON chat_messages(team_id);
CREATE INDEX idx_chat_messages_created ON chat_messages(created_at DESC);
CREATE INDEX idx_user_progress_user ON user_progress(user_id);
CREATE INDEX idx_sessions_team ON sessions(team_id);
CREATE INDEX idx_sessions_week ON sessions(team_id, week_number);

-- ============================================
-- ENABLE REALTIME
-- ============================================
-- Run separately: ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
