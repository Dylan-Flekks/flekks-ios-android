-- FLEKKS Seed Data
-- Run this after schema.sql to populate test data

-- ============================================
-- COACH: Dr. Dylan Peters (Physical Therapist)
-- ============================================

-- First, create auth user for Dylan (in production, this happens via auth signup)
-- For testing, we'll use a fixed UUID
DO $$
DECLARE
    dylan_user_id UUID := 'a1b2c3d4-1111-4444-aaaa-111111111111';
    dylan_coach_id UUID;
    dylan_team_id UUID;
    lowback_program_id UUID;
BEGIN
    -- Insert Dylan as a user (skip if exists)
    INSERT INTO users (id, email, name, avatar_url, streak_count, total_sessions, total_minutes)
    VALUES (
        dylan_user_id,
        'dylan@flekks.com',
        'Dr. Dylan Peters',
        NULL,
        0, 0, 0
    ) ON CONFLICT (id) DO NOTHING;

    -- Insert Dylan as a coach
    INSERT INTO coaches (id, user_id, name, credential, bio, avatar_url, hero_image_url, accent_color, is_verified)
    VALUES (
        'c1111111-1111-4444-aaaa-111111111111',
        dylan_user_id,
        'Dr. Dylan Peters',
        'DPT, CSCS',
        'Doctor of Physical Therapy specializing in spinal health, injury prevention, and movement optimization. 10+ years helping desk workers and athletes move pain-free.',
        NULL,
        NULL,
        '#00d4aa',
        TRUE
    ) ON CONFLICT (id) DO NOTHING;

    dylan_coach_id := 'c1111111-1111-4444-aaaa-111111111111';

    -- Create Dylan's Team: Low Back Liberation
    INSERT INTO teams (id, coach_id, name, description, focus, hero_gradient, member_count, is_active)
    VALUES (
        't1111111-1111-4444-aaaa-111111111111',
        dylan_coach_id,
        'Low Back Liberation',
        'Fix your low back for good. Science-backed protocols for desk workers, lifters, and anyone tired of living with back pain. No fluff, just results.',
        'Low Back Pain Relief',
        'green',
        847,
        TRUE
    ) ON CONFLICT (id) DO NOTHING;

    dylan_team_id := 't1111111-1111-4444-aaaa-111111111111';

    -- Create Program: 6-Week Low Back Reset
    INSERT INTO programs (id, team_id, name, description, week_count, is_active)
    VALUES (
        'p1111111-1111-4444-aaaa-111111111111',
        dylan_team_id,
        '6-Week Low Back Reset',
        'A comprehensive program to eliminate low back pain and build lasting resilience. Combines mobility, stability, and strength work.',
        6,
        TRUE
    ) ON CONFLICT (id) DO NOTHING;

    lowback_program_id := 'p1111111-1111-4444-aaaa-111111111111';

    -- Create Sessions for Week 1
    INSERT INTO sessions (id, program_id, week_number, day_number, title, description, focus_area, duration_minutes, video_url, thumbnail_url)
    VALUES
        ('s1111111-1111-4444-aaaa-000000000001', lowback_program_id, 1, 1, 'Assessment & Foundation', 'Identify your movement patterns and establish your baseline. Learn the core principles that will guide your recovery.', 'Assessment', 15, NULL, NULL),
        ('s1111111-1111-4444-aaaa-000000000002', lowback_program_id, 1, 2, 'Hip Hinge Mastery', 'The hip hinge is the #1 skill for protecting your low back. Master this pattern and watch your pain decrease.', 'Hips & Glutes', 18, NULL, NULL),
        ('s1111111-1111-4444-aaaa-000000000003', lowback_program_id, 1, 3, 'Spine Decompression', 'Gentle traction and decompression techniques to relieve pressure on your discs and nerves.', 'Spine', 12, NULL, NULL),
        ('s1111111-1111-4444-aaaa-000000000004', lowback_program_id, 1, 4, 'Core Activation', 'Not crunches! Learn to properly brace and stabilize your core to support your spine.', 'Core', 20, NULL, NULL),
        ('s1111111-1111-4444-aaaa-000000000005', lowback_program_id, 1, 5, 'Hip Flexor Release', 'Tight hip flexors are a major contributor to low back pain. Release them and feel the relief.', 'Hip Flexors', 15, NULL, NULL)
    ON CONFLICT (id) DO NOTHING;

    -- Create Sessions for Week 2
    INSERT INTO sessions (id, program_id, week_number, day_number, title, description, focus_area, duration_minutes, video_url, thumbnail_url)
    VALUES
        ('s1111111-1111-4444-aaaa-000000000006', lowback_program_id, 2, 1, 'Glute Activation', 'Wake up your glutes to take pressure off your low back. Strong glutes = happy spine.', 'Glutes', 18, NULL, NULL),
        ('s1111111-1111-4444-aaaa-000000000007', lowback_program_id, 2, 2, 'Thoracic Mobility', 'Improve upper back mobility to reduce compensations in your low back.', 'Upper Back', 16, NULL, NULL),
        ('s1111111-1111-4444-aaaa-000000000008', lowback_program_id, 2, 3, 'Hamstring Flow', 'Balanced hamstring flexibility without overstretching. Quality over quantity.', 'Hamstrings', 14, NULL, NULL),
        ('s1111111-1111-4444-aaaa-000000000009', lowback_program_id, 2, 4, 'McGill Big 3', 'The gold standard core exercises for low back pain, developed by Dr. Stuart McGill.', 'Core', 22, NULL, NULL),
        ('s1111111-1111-4444-aaaa-000000000010', lowback_program_id, 2, 5, 'Active Recovery', 'Gentle movement to promote healing and maintain progress. Rest is part of the program.', 'Full Body', 12, NULL, NULL)
    ON CONFLICT (id) DO NOTHING;

END $$;

-- ============================================
-- COACH: Tina (Stretch Therapist)
-- ============================================

DO $$
DECLARE
    tina_user_id UUID := 'a1b2c3d4-2222-4444-bbbb-222222222222';
    tina_coach_id UUID;
    tina_team_id UUID;
    pike_program_id UUID;
    pancake_program_id UUID;
BEGIN
    -- Insert Tina as a user
    INSERT INTO users (id, email, name, avatar_url, streak_count, total_sessions, total_minutes)
    VALUES (
        tina_user_id,
        'tina@flekks.com',
        'Tina',
        NULL,
        0, 0, 0
    ) ON CONFLICT (id) DO NOTHING;

    -- Insert Tina as a coach
    INSERT INTO coaches (id, user_id, name, credential, bio, avatar_url, hero_image_url, accent_color, is_verified)
    VALUES (
        'c2222222-2222-4444-bbbb-222222222222',
        tina_user_id,
        'Tina',
        'Certified Stretch Therapist',
        'Former professional dancer turned flexibility specialist. I help people unlock their body''s full range of motion through targeted stretching protocols. Your pike and pancake goals are my specialty!',
        NULL,
        NULL,
        '#9b59b6',
        TRUE
    ) ON CONFLICT (id) DO NOTHING;

    tina_coach_id := 'c2222222-2222-4444-bbbb-222222222222';

    -- Create Tina's Team: Flexibility Lab
    INSERT INTO teams (id, coach_id, name, description, focus, hero_gradient, member_count, is_active)
    VALUES (
        't2222222-2222-4444-bbbb-222222222222',
        tina_coach_id,
        'Flexibility Lab',
        'Deep flexibility work for serious progress. Whether you''re chasing your pike, pancake, or just want to move better - this is where transformation happens.',
        'Advanced Flexibility',
        'purple',
        523,
        TRUE
    ) ON CONFLICT (id) DO NOTHING;

    tina_team_id := 't2222222-2222-4444-bbbb-222222222222';

    -- Create Program 1: Pike Perfection
    INSERT INTO programs (id, team_id, name, description, week_count, is_active)
    VALUES (
        'p2222222-2222-4444-bbbb-111111111111',
        tina_team_id,
        'Pike Perfection',
        'Master the pike stretch with progressive overload and targeted techniques. Go from barely touching your toes to chest-to-knees flexibility.',
        8,
        TRUE
    ) ON CONFLICT (id) DO NOTHING;

    pike_program_id := 'p2222222-2222-4444-bbbb-111111111111';

    -- Create Program 2: Pancake Protocol
    INSERT INTO programs (id, team_id, name, description, week_count, is_active)
    VALUES (
        'p2222222-2222-4444-bbbb-222222222222',
        tina_team_id,
        'Pancake Protocol',
        'The ultimate middle splits and pancake progression. Unlock your hips and achieve that flat pancake position.',
        8,
        TRUE
    ) ON CONFLICT (id) DO NOTHING;

    pancake_program_id := 'p2222222-2222-4444-bbbb-222222222222';

    -- Pike Perfection Sessions - Week 1
    INSERT INTO sessions (id, program_id, week_number, day_number, title, description, focus_area, duration_minutes, video_url, thumbnail_url)
    VALUES
        ('s2222222-2222-4444-bbbb-000000000001', pike_program_id, 1, 1, 'Pike Assessment', 'Test your current pike and identify your limiting factors. Is it hamstrings, hip flexion, or spinal mobility?', 'Assessment', 12, NULL, NULL),
        ('s2222222-2222-4444-bbbb-000000000002', pike_program_id, 1, 2, 'Hamstring Prep', 'Prepare your hamstrings for deep stretching with targeted activation and lengthening.', 'Hamstrings', 20, NULL, NULL),
        ('s2222222-2222-4444-bbbb-000000000003', pike_program_id, 1, 3, 'Hip Flexor Strength', 'Strong hip flexors pull you deeper into your pike. Build that active flexibility.', 'Hip Flexors', 18, NULL, NULL),
        ('s2222222-2222-4444-bbbb-000000000004', pike_program_id, 1, 4, 'Standing Pike Flow', 'Progressive standing pike work with holds and pulses.', 'Full Pike', 22, NULL, NULL),
        ('s2222222-2222-4444-bbbb-000000000005', pike_program_id, 1, 5, 'Seated Pike Deep Work', 'Seated pike variations with weighted stretches and long holds.', 'Full Pike', 25, NULL, NULL)
    ON CONFLICT (id) DO NOTHING;

    -- Pancake Protocol Sessions - Week 1
    INSERT INTO sessions (id, program_id, week_number, day_number, title, description, focus_area, duration_minutes, video_url, thumbnail_url)
    VALUES
        ('s3333333-3333-4444-cccc-000000000001', pancake_program_id, 1, 1, 'Pancake Baseline', 'Assess your current pancake and identify where you need the most work.', 'Assessment', 12, NULL, NULL),
        ('s3333333-3333-4444-cccc-000000000002', pancake_program_id, 1, 2, 'Adductor Release', 'Open up the inner thighs with targeted adductor work.', 'Adductors', 20, NULL, NULL),
        ('s3333333-3333-4444-cccc-000000000003', pancake_program_id, 1, 3, 'Hip External Rotation', 'External rotation is key for a flat pancake. Build it here.', 'Hips', 18, NULL, NULL),
        ('s3333333-3333-4444-cccc-000000000004', pancake_program_id, 1, 4, 'Straddle Progression', 'Progressive straddle work to increase your side-to-side range.', 'Full Straddle', 24, NULL, NULL),
        ('s3333333-3333-4444-cccc-000000000005', pancake_program_id, 1, 5, 'Pancake Flow', 'Putting it all together with a complete pancake training session.', 'Full Pancake', 28, NULL, NULL)
    ON CONFLICT (id) DO NOTHING;

END $$;

-- ============================================
-- SAMPLE CHAT MESSAGES
-- ============================================

-- Note: These require actual user IDs from auth.users
-- For now, we'll add them when users sign up

-- ============================================
-- BADGES (Global)
-- ============================================

INSERT INTO badges (id, name, description, icon, requirement_type, requirement_value)
VALUES
    ('b1111111-1111-4444-aaaa-000000000001', 'First Session', 'Complete your first session', 'target', 'sessions', 1),
    ('b1111111-1111-4444-aaaa-000000000002', 'Week Warrior', 'Complete 7 sessions', 'flame.fill', 'sessions', 7),
    ('b1111111-1111-4444-aaaa-000000000003', 'Consistent', 'Maintain a 14-day streak', 'bolt.fill', 'streak', 14),
    ('b1111111-1111-4444-aaaa-000000000004', 'Dedicated', 'Complete 30 sessions', 'star.fill', 'sessions', 30),
    ('b1111111-1111-4444-aaaa-000000000005', '30 Days', 'Maintain a 30-day streak', 'trophy.fill', 'streak', 30),
    ('b1111111-1111-4444-aaaa-000000000006', 'Master', 'Complete 100 sessions', 'crown.fill', 'sessions', 100),
    ('b1111111-1111-4444-aaaa-000000000007', 'Team Player', 'Send 10 chat messages', 'person.2.fill', 'messages', 10),
    ('b1111111-1111-4444-aaaa-000000000008', 'Early Bird', 'Complete a session before 7am', 'sunrise.fill', 'time', 7)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- VERIFY DATA
-- ============================================

-- Check coaches
SELECT 'Coaches:' as info;
SELECT name, credential, is_verified FROM coaches;

-- Check teams
SELECT 'Teams:' as info;
SELECT t.name as team_name, c.name as coach_name, t.member_count, t.focus
FROM teams t
JOIN coaches c ON t.coach_id = c.id;

-- Check programs
SELECT 'Programs:' as info;
SELECT p.name as program_name, t.name as team_name, p.week_count
FROM programs p
JOIN teams t ON p.team_id = t.id;

-- Check sessions count
SELECT 'Sessions per program:' as info;
SELECT p.name, COUNT(s.id) as session_count
FROM programs p
LEFT JOIN sessions s ON s.program_id = p.id
GROUP BY p.name;
