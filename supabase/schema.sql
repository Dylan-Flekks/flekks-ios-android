-- FLEKKS Database Schema for Supabase
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

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- ============================================
-- COACHES TABLE
-- ============================================
CREATE TABLE coaches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    credential TEXT, -- e.g., "DPT, CSCS"
    bio TEXT,
    avatar_url TEXT,
    hero_image_url TEXT,
    accent_color TEXT DEFAULT '#00d4aa',
    is_verified BOOLEAN DEFAULT FALSE,
    stripe_account_id TEXT, -- For payments
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE coaches ENABLE ROW LEVEL SECURITY;

-- Anyone can view verified coaches
CREATE POLICY "Anyone can view verified coaches" ON coaches
    FOR SELECT USING (is_verified = TRUE);

-- Coaches can update their own profile
CREATE POLICY "Coaches can update own profile" ON coaches
    FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- TEAMS TABLE
-- ============================================
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID REFERENCES coaches(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    focus TEXT, -- e.g., "Injury Prevention", "Advanced Flexibility"
    hero_gradient TEXT DEFAULT 'green', -- 'green', 'purple', 'blue'
    member_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

-- Anyone can view active teams
CREATE POLICY "Anyone can view active teams" ON teams
    FOR SELECT USING (is_active = TRUE);

-- Coaches can manage their teams
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
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(team_id, user_id)
);

ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- Users can see their own memberships
CREATE POLICY "Users can view own memberships" ON team_members
    FOR SELECT USING (auth.uid() = user_id);

-- Users can join/leave teams
CREATE POLICY "Users can manage own memberships" ON team_members
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- PROGRAMS TABLE
-- ============================================
CREATE TABLE programs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    week_count INTEGER DEFAULT 6,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE programs ENABLE ROW LEVEL SECURITY;

-- Team members can view programs
CREATE POLICY "Team members can view programs" ON programs
    FOR SELECT USING (
        team_id IN (SELECT team_id FROM team_members WHERE user_id = auth.uid())
        OR
        team_id IN (SELECT id FROM teams WHERE coach_id IN (SELECT id FROM coaches WHERE user_id = auth.uid()))
    );

-- ============================================
-- SESSIONS TABLE
-- ============================================
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_id UUID REFERENCES programs(id) ON DELETE CASCADE,
    week_number INTEGER NOT NULL,
    day_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    focus_area TEXT,
    duration_minutes INTEGER,
    video_url TEXT,
    thumbnail_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- Team members can view sessions
CREATE POLICY "Team members can view sessions" ON sessions
    FOR SELECT USING (
        program_id IN (
            SELECT id FROM programs WHERE team_id IN (
                SELECT team_id FROM team_members WHERE user_id = auth.uid()
            )
        )
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

-- Users can manage their own progress
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

-- Team members can view messages
CREATE POLICY "Team members can view messages" ON chat_messages
    FOR SELECT USING (
        team_id IN (SELECT team_id FROM team_members WHERE user_id = auth.uid())
    );

-- Team members can send messages
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
    requirement_type TEXT, -- 'streak', 'sessions', 'minutes', etc.
    requirement_value INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- USER BADGES (Junction Table)
-- ============================================
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

-- Function to increment team member count
CREATE OR REPLACE FUNCTION increment_team_members(team_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE teams SET member_count = member_count + 1 WHERE id = team_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrement team member count
CREATE OR REPLACE FUNCTION decrement_team_members(team_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE teams SET member_count = GREATEST(0, member_count - 1) WHERE id = team_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update streak
CREATE OR REPLACE FUNCTION update_user_streak()
RETURNS TRIGGER AS $$
DECLARE
    last_completion DATE;
    current_streak INTEGER;
BEGIN
    -- Get user's last completion date (before this one)
    SELECT DATE(completed_at) INTO last_completion
    FROM user_progress
    WHERE user_id = NEW.user_id AND id != NEW.id
    ORDER BY completed_at DESC
    LIMIT 1;

    -- Get current streak
    SELECT streak_count INTO current_streak
    FROM users WHERE id = NEW.user_id;

    -- If last completion was yesterday, increment streak
    IF last_completion = CURRENT_DATE - INTERVAL '1 day' THEN
        UPDATE users SET
            streak_count = streak_count + 1,
            total_sessions = total_sessions + 1,
            total_minutes = total_minutes + (NEW.duration_seconds / 60)
        WHERE id = NEW.user_id;
    -- If last completion was today, don't change streak
    ELSIF last_completion = CURRENT_DATE THEN
        UPDATE users SET
            total_sessions = total_sessions + 1,
            total_minutes = total_minutes + (NEW.duration_seconds / 60)
        WHERE id = NEW.user_id;
    -- Otherwise, reset streak to 1
    ELSE
        UPDATE users SET
            streak_count = 1,
            total_sessions = total_sessions + 1,
            total_minutes = total_minutes + (NEW.duration_seconds / 60)
        WHERE id = NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for streak updates
CREATE TRIGGER on_session_complete
    AFTER INSERT ON user_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_user_streak();

-- ============================================
-- STORAGE BUCKETS & POLICIES
-- ============================================
-- Run these in Supabase Dashboard > Storage or via SQL

-- Create buckets (do this in Dashboard first, then apply policies below)

-- 1. AVATARS BUCKET (Public - displayed throughout app)
-- Dashboard: Create bucket "avatars", set to PUBLIC
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    TRUE,  -- Public bucket
    2097152,  -- 2MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Avatars: Anyone can view, authenticated users can upload their own
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 2. THUMBNAILS BUCKET (Public - shown in session lists)
-- Dashboard: Create bucket "thumbnails", set to PUBLIC
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'thumbnails',
    'thumbnails',
    TRUE,  -- Public bucket
    1048576,  -- 1MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Thumbnails: Anyone can view, only coaches can upload
CREATE POLICY "Thumbnails are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'thumbnails');

CREATE POLICY "Coaches can upload thumbnails"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'thumbnails'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

CREATE POLICY "Coaches can manage thumbnails"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'thumbnails'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

CREATE POLICY "Coaches can delete thumbnails"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'thumbnails'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

-- 3. VIDEOS BUCKET (Private - paid content, use signed URLs)
-- Dashboard: Create bucket "videos", set to PRIVATE
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'videos',
    'videos',
    FALSE,  -- PRIVATE bucket - requires signed URLs
    524288000,  -- 500MB limit
    ARRAY['video/mp4', 'video/quicktime', 'video/x-m4v']
) ON CONFLICT (id) DO NOTHING;

-- Videos: Only team members can view (via signed URLs in app)
CREATE POLICY "Team members can view videos"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'videos'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (
        SELECT tm.user_id FROM team_members tm
        JOIN programs p ON p.team_id = tm.team_id
        JOIN sessions s ON s.program_id = p.id
        WHERE s.video_url LIKE '%' || name || '%'
    )
);

-- Only coaches can upload videos
CREATE POLICY "Coaches can upload videos"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'videos'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

CREATE POLICY "Coaches can manage videos"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'videos'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

CREATE POLICY "Coaches can delete videos"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'videos'
    AND auth.role() = 'authenticated'
    AND auth.uid() IN (SELECT user_id FROM coaches)
);

-- ============================================
-- REALTIME (Enable in Dashboard)
-- ============================================
-- Enable realtime for chat_messages table:
-- ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_team_members_user ON team_members(user_id);
CREATE INDEX idx_team_members_team ON team_members(team_id);
CREATE INDEX idx_chat_messages_team ON chat_messages(team_id);
CREATE INDEX idx_chat_messages_created ON chat_messages(created_at DESC);
CREATE INDEX idx_user_progress_user ON user_progress(user_id);
CREATE INDEX idx_sessions_program ON sessions(program_id);

-- ============================================
-- SEED DATA (Optional - for testing)
-- ============================================
-- INSERT INTO badges (name, description, icon, requirement_type, requirement_value) VALUES
-- ('First Session', 'Complete your first session', '🎯', 'sessions', 1),
-- ('Week Warrior', 'Complete 7 sessions', '🔥', 'sessions', 7),
-- ('Early Bird', 'Complete a session before 7am', '🌅', 'time', 7),
-- ('Consistent', 'Maintain a 14-day streak', '⚡️', 'streak', 14),
-- ('Flexible', 'Complete 30 sessions', '🧘', 'sessions', 30),
-- ('Team Player', 'Send 10 chat messages', '👥', 'messages', 10),
-- ('30 Days', 'Maintain a 30-day streak', '🏆', 'streak', 30),
-- ('Master', 'Complete 100 sessions', '👑', 'sessions', 100);
