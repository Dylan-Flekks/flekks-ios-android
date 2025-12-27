-- FLEKKS Seed Data
-- Run this after schema.sql to populate test data
-- Note: Coaches are created without user_id since that requires auth.users entries

-- ============================================
-- COACH: Dr. Dylan Peters (Physical Therapist)
-- ============================================

-- Insert Dylan as a coach (no user_id needed for seed data)
INSERT INTO coaches (id, user_id, name, credential, bio, avatar_url, hero_image_url, accent_color, is_verified)
VALUES (
    'c1111111-1111-4444-aaaa-111111111111',
    NULL,  -- No auth user for seed data
    'Dr. Dylan Peters',
    'DPT, CSCS',
    'Doctor of Physical Therapy specializing in spinal health, injury prevention, and movement optimization. 10+ years helping desk workers and athletes move pain-free.',
    NULL,
    NULL,
    '#00d4aa',
    TRUE
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    credential = EXCLUDED.credential,
    bio = EXCLUDED.bio,
    is_verified = EXCLUDED.is_verified;

-- Create Dylan's Team: Low Back Liberation
INSERT INTO teams (id, coach_id, name, description, focus, hero_gradient, member_count, is_active)
VALUES (
    't1111111-1111-4444-aaaa-111111111111',
    'c1111111-1111-4444-aaaa-111111111111',
    'Low Back Liberation',
    'Fix your low back for good. Science-backed protocols for desk workers, lifters, and anyone tired of living with back pain. No fluff, just results.',
    'Low Back Pain Relief',
    'green',
    847,
    TRUE
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    member_count = EXCLUDED.member_count;

-- Create Program: 6-Week Low Back Reset
INSERT INTO programs (id, team_id, name, description, week_count, is_active)
VALUES (
    'p1111111-1111-4444-aaaa-111111111111',
    't1111111-1111-4444-aaaa-111111111111',
    '6-Week Low Back Reset',
    'A comprehensive program to eliminate low back pain and build lasting resilience. Combines mobility, stability, and strength work.',
    6,
    TRUE
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description;

-- Create Sessions for Week 1
INSERT INTO sessions (id, program_id, week_number, day_number, title, description, focus_area, duration_minutes, video_url, thumbnail_url)
VALUES
    ('s1111111-1111-4444-aaaa-000000000001', 'p1111111-1111-4444-aaaa-111111111111', 1, 1, 'Assessment & Foundation', 'Identify your movement patterns and establish your baseline. Learn the core principles that will guide your recovery.', 'Assessment', 15, NULL, NULL),
    ('s1111111-1111-4444-aaaa-000000000002', 'p1111111-1111-4444-aaaa-111111111111', 1, 2, 'Hip Hinge Mastery', 'The hip hinge is the #1 skill for protecting your low back. Master this pattern and watch your pain decrease.', 'Hips & Glutes', 18, NULL, NULL),
    ('s1111111-1111-4444-aaaa-000000000003', 'p1111111-1111-4444-aaaa-111111111111', 1, 3, 'Spine Decompression', 'Gentle traction and decompression techniques to relieve pressure on your discs and nerves.', 'Spine', 12, NULL, NULL),
    ('s1111111-1111-4444-aaaa-000000000004', 'p1111111-1111-4444-aaaa-111111111111', 1, 4, 'Core Activation', 'Not crunches! Learn to properly brace and stabilize your core to support your spine.', 'Core', 20, NULL, NULL),
    ('s1111111-1111-4444-aaaa-000000000005', 'p1111111-1111-4444-aaaa-111111111111', 1, 5, 'Hip Flexor Release', 'Tight hip flexors are a major contributor to low back pain. Release them and feel the relief.', 'Hip Flexors', 15, NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- Create Sessions for Week 2
INSERT INTO sessions (id, program_id, week_number, day_number, title, description, focus_area, duration_minutes, video_url, thumbnail_url)
VALUES
    ('s1111111-1111-4444-aaaa-000000000006', 'p1111111-1111-4444-aaaa-111111111111', 2, 1, 'Glute Activation', 'Wake up your glutes to take pressure off your low back. Strong glutes = happy spine.', 'Glutes', 18, NULL, NULL),
    ('s1111111-1111-4444-aaaa-000000000007', 'p1111111-1111-4444-aaaa-111111111111', 2, 2, 'Thoracic Mobility', 'Improve upper back mobility to reduce compensations in your low back.', 'Upper Back', 16, NULL, NULL),
    ('s1111111-1111-4444-aaaa-000000000008', 'p1111111-1111-4444-aaaa-111111111111', 2, 3, 'Hamstring Flow', 'Balanced hamstring flexibility without overstretching. Quality over quantity.', 'Hamstrings', 14, NULL, NULL),
    ('s1111111-1111-4444-aaaa-000000000009', 'p1111111-1111-4444-aaaa-111111111111', 2, 4, 'McGill Big 3', 'The gold standard core exercises for low back pain, developed by Dr. Stuart McGill.', 'Core', 22, NULL, NULL),
    ('s1111111-1111-4444-aaaa-000000000010', 'p1111111-1111-4444-aaaa-111111111111', 2, 5, 'Active Recovery', 'Gentle movement to promote healing and maintain progress. Rest is part of the program.', 'Full Body', 12, NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- COACH: Tina (Stretch Therapist)
-- ============================================

-- Insert Tina as a coach
INSERT INTO coaches (id, user_id, name, credential, bio, avatar_url, hero_image_url, accent_color, is_verified)
VALUES (
    'c2222222-2222-4444-bbbb-222222222222',
    NULL,  -- No auth user for seed data
    'Tina',
    'Certified Stretch Therapist',
    'Former professional dancer turned flexibility specialist. I help people unlock their body''s full range of motion through targeted stretching protocols. Your pike and pancake goals are my specialty!',
    NULL,
    NULL,
    '#9b59b6',
    TRUE
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    credential = EXCLUDED.credential,
    bio = EXCLUDED.bio,
    is_verified = EXCLUDED.is_verified;

-- Create Tina's Team: Flexibility Lab
INSERT INTO teams (id, coach_id, name, description, focus, hero_gradient, member_count, is_active)
VALUES (
    't2222222-2222-4444-bbbb-222222222222',
    'c2222222-2222-4444-bbbb-222222222222',
    'Flexibility Lab',
    'Deep flexibility work for serious progress. Whether you''re chasing your pike, pancake, or just want to move better - this is where transformation happens.',
    'Advanced Flexibility',
    'purple',
    523,
    TRUE
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    member_count = EXCLUDED.member_count;

-- Create Program 1: Pike Perfection
INSERT INTO programs (id, team_id, name, description, week_count, is_active)
VALUES (
    'p2222222-2222-4444-bbbb-111111111111',
    't2222222-2222-4444-bbbb-222222222222',
    'Pike Perfection',
    'Master the pike stretch with progressive overload and targeted techniques. Go from barely touching your toes to chest-to-knees flexibility.',
    8,
    TRUE
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description;

-- Create Program 2: Pancake Protocol
INSERT INTO programs (id, team_id, name, description, week_count, is_active)
VALUES (
    'p2222222-2222-4444-bbbb-222222222222',
    't2222222-2222-4444-bbbb-222222222222',
    'Pancake Protocol',
    'The ultimate middle splits and pancake progression. Unlock your hips and achieve that flat pancake position.',
    8,
    TRUE
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description;

-- Pike Perfection Sessions - Week 1
INSERT INTO sessions (id, program_id, week_number, day_number, title, description, focus_area, duration_minutes, video_url, thumbnail_url)
VALUES
    ('s2222222-2222-4444-bbbb-000000000001', 'p2222222-2222-4444-bbbb-111111111111', 1, 1, 'Pike Assessment', 'Test your current pike and identify your limiting factors. Is it hamstrings, hip flexion, or spinal mobility?', 'Assessment', 12, NULL, NULL),
    ('s2222222-2222-4444-bbbb-000000000002', 'p2222222-2222-4444-bbbb-111111111111', 1, 2, 'Hamstring Prep', 'Prepare your hamstrings for deep stretching with targeted activation and lengthening.', 'Hamstrings', 20, NULL, NULL),
    ('s2222222-2222-4444-bbbb-000000000003', 'p2222222-2222-4444-bbbb-111111111111', 1, 3, 'Hip Flexor Strength', 'Strong hip flexors pull you deeper into your pike. Build that active flexibility.', 'Hip Flexors', 18, NULL, NULL),
    ('s2222222-2222-4444-bbbb-000000000004', 'p2222222-2222-4444-bbbb-111111111111', 1, 4, 'Standing Pike Flow', 'Progressive standing pike work with holds and pulses.', 'Full Pike', 22, NULL, NULL),
    ('s2222222-2222-4444-bbbb-000000000005', 'p2222222-2222-4444-bbbb-111111111111', 1, 5, 'Seated Pike Deep Work', 'Seated pike variations with weighted stretches and long holds.', 'Full Pike', 25, NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- Pancake Protocol Sessions - Week 1
INSERT INTO sessions (id, program_id, week_number, day_number, title, description, focus_area, duration_minutes, video_url, thumbnail_url)
VALUES
    ('s3333333-3333-4444-cccc-000000000001', 'p2222222-2222-4444-bbbb-222222222222', 1, 1, 'Pancake Baseline', 'Assess your current pancake and identify where you need the most work.', 'Assessment', 12, NULL, NULL),
    ('s3333333-3333-4444-cccc-000000000002', 'p2222222-2222-4444-bbbb-222222222222', 1, 2, 'Adductor Release', 'Open up the inner thighs with targeted adductor work.', 'Adductors', 20, NULL, NULL),
    ('s3333333-3333-4444-cccc-000000000003', 'p2222222-2222-4444-bbbb-222222222222', 1, 3, 'Hip External Rotation', 'External rotation is key for a flat pancake. Build it here.', 'Hips', 18, NULL, NULL),
    ('s3333333-3333-4444-cccc-000000000004', 'p2222222-2222-4444-bbbb-222222222222', 1, 4, 'Straddle Progression', 'Progressive straddle work to increase your side-to-side range.', 'Full Straddle', 24, NULL, NULL),
    ('s3333333-3333-4444-cccc-000000000005', 'p2222222-2222-4444-bbbb-222222222222', 1, 5, 'Pancake Flow', 'Putting it all together with a complete pancake training session.', 'Full Pancake', 28, NULL, NULL)
ON CONFLICT (id) DO NOTHING;

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
