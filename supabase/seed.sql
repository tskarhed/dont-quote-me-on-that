-- ==============================
-- Seeds for Allowlist-only Quotes App
-- ==============================

-- Insert test users into auth.users (these would normally be created through Supabase Auth)
-- Note: In a real scenario, these users would be created through the auth system
-- For seeding purposes, we'll insert them directly

-- Test User 1: Admin user
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'admin@example.com',
  crypt('password123', gen_salt('bf')),
  now(),
  null,
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  now(),
  now(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Test User 2: Allowlisted user
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '22222222-2222-2222-2222-222222222222',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'user@example.com',
  crypt('password123', gen_salt('bf')),
  now(),
  null,
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  now(),
  now(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Test User 3: Non-allowlisted user
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '33333333-3333-3333-3333-333333333333',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'outsider@example.com',
  crypt('password123', gen_salt('bf')),
  now(),
  null,
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  now(),
  now(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Update profiles to set roles (profiles are created automatically on user creation)
UPDATE profiles SET role = 'admin' WHERE id = '11111111-1111-1111-1111-111111111111';
UPDATE profiles SET role = 'user' WHERE id = '22222222-2222-2222-2222-222222222222';
UPDATE profiles SET role = 'user' WHERE id = '33333333-3333-3333-3333-333333333333';

-- Insert allowlist entries
INSERT INTO allowlist (email, created_by) VALUES 
  ('admin@example.com', '11111111-1111-1111-1111-111111111111'),
  ('user@example.com', '11111111-1111-1111-1111-111111111111')
ON CONFLICT (email) DO NOTHING;

-- Insert 50 quotes including XSS test cases
INSERT INTO quotes (text, author, created_by) VALUES 
  -- Regular inspirational quotes
  ('The only way to do great work is to love what you do.', 'Steve Jobs', '11111111-1111-1111-1111-111111111111'),
  ('Innovation distinguishes between a leader and a follower.', 'Steve Jobs', '11111111-1111-1111-1111-111111111111'),
  ('Life is what happens to you while you''re busy making other plans.', 'John Lennon', '22222222-2222-2222-2222-222222222222'),
  ('The future belongs to those who believe in the beauty of their dreams.', 'Eleanor Roosevelt', '11111111-1111-1111-1111-111111111111'),
  ('It is during our darkest moments that we must focus to see the light.', 'Aristotle', '22222222-2222-2222-2222-222222222222'),
  ('Success is not final, failure is not fatal: it is the courage to continue that counts.', 'Winston Churchill', '11111111-1111-1111-1111-111111111111'),
  ('The way to get started is to quit talking and begin doing.', 'Walt Disney', '22222222-2222-2222-2222-222222222222'),
  ('Don''t be pushed around by the fears in your mind. Be led by the dreams in your heart.', 'Roy T. Bennett', '11111111-1111-1111-1111-111111111111'),
  ('Believe you can and you''re halfway there.', 'Theodore Roosevelt', '22222222-2222-2222-2222-222222222222'),
  ('The only impossible journey is the one you never begin.', 'Tony Robbins', '11111111-1111-1111-1111-111111111111'),
  
  -- XSS Test Cases (malicious quotes)
  ('<script>alert("XSS Attack!")</script>', 'Malicious User', '11111111-1111-1111-1111-111111111111'),
  ('<img src="x" onerror="alert(''XSS'')">', 'Hacker', '22222222-2222-2222-2222-222222222222'),
  ('javascript:alert("XSS")', 'Script Kiddie', '11111111-1111-1111-1111-111111111111'),
  ('<svg onload="alert(''XSS'')">', 'Security Tester', '22222222-2222-2222-2222-222222222222'),
  ('<iframe src="javascript:alert(''XSS'')"></iframe>', 'Penetration Tester', '11111111-1111-1111-1111-111111111111'),
  ('<body onload="alert(''XSS'')">', 'Bug Hunter', '22222222-2222-2222-2222-222222222222'),
  ('<input type="image" src="x" onerror="alert(''XSS'')">', 'Security Researcher', '11111111-1111-1111-1111-111111111111'),
  ('<link rel="stylesheet" href="javascript:alert(''XSS'')">', 'White Hat', '22222222-2222-2222-2222-222222222222'),
  ('<meta http-equiv="refresh" content="0;url=javascript:alert(''XSS'')">', 'Ethical Hacker', '11111111-1111-1111-1111-111111111111'),
  ('<object data="javascript:alert(''XSS'')">', 'Security Analyst', '22222222-2222-2222-2222-222222222222'),
  
  -- More regular quotes
  ('The greatest glory in living lies not in never falling, but in rising every time we fall.', 'Nelson Mandela', '11111111-1111-1111-1111-111111111111'),
  ('Your time is limited, don''t waste it living someone else''s life.', 'Steve Jobs', '22222222-2222-2222-2222-222222222222'),
  ('If life were predictable it would cease to be life, and be without flavor.', 'Eleanor Roosevelt', '11111111-1111-1111-1111-111111111111'),
  ('If you look at what you have in life, you''ll always have more.', 'Oprah Winfrey', '22222222-2222-2222-2222-222222222222'),
  ('If you set your goals ridiculously high and it''s a failure, you will fail above everyone else''s success.', 'James Cameron', '11111111-1111-1111-1111-111111111111'),
  ('Life is what happens to you while you''re busy making other plans.', 'John Lennon', '22222222-2222-2222-2222-222222222222'),
  ('Spread love everywhere you go. Let no one ever come to you without leaving happier.', 'Mother Teresa', '11111111-1111-1111-1111-111111111111'),
  ('When you reach the end of your rope, tie a knot in it and hang on.', 'Franklin D. Roosevelt', '22222222-2222-2222-2222-222222222222'),
  ('Always remember that you are absolutely unique. Just like everyone else.', 'Margaret Mead', '11111111-1111-1111-1111-111111111111'),
  ('Don''t judge each day by the harvest you reap but by the seeds that you plant.', 'Robert Louis Stevenson', '22222222-2222-2222-2222-222222222222'),
  
  -- More XSS test cases with different payloads
  ('<embed src="javascript:alert(''XSS'')">', 'Red Team', '11111111-1111-1111-1111-111111111111'),
  ('<form><button formaction="javascript:alert(''XSS'')">Click</button></form>', 'Blue Team', '22222222-2222-2222-2222-222222222222'),
  ('<details open ontoggle="alert(''XSS'')">', 'Purple Team', '11111111-1111-1111-1111-111111111111'),
  ('<marquee onstart="alert(''XSS'')">', 'Security Engineer', '22222222-2222-2222-2222-222222222222'),
  ('<audio src="x" onerror="alert(''XSS'')">', 'DevSecOps', '11111111-1111-1111-1111-111111111111'),
  ('<video src="x" onerror="alert(''XSS'')">', 'AppSec', '22222222-2222-2222-2222-222222222222'),
  ('<source src="x" onerror="alert(''XSS'')">', 'InfoSec', '11111111-1111-1111-1111-111111111111'),
  ('<track src="x" onerror="alert(''XSS'')">', 'CyberSec', '22222222-2222-2222-2222-222222222222'),
  ('<area shape="rect" coords="0,0,100,100" href="javascript:alert(''XSS'')">', 'Security Consultant', '11111111-1111-1111-1111-111111111111'),
  ('<base href="javascript:alert(''XSS'')">', 'Security Architect', '22222222-2222-2222-2222-222222222222'),
  
  -- Final regular quotes
  ('The future belongs to those who believe in the beauty of their dreams.', 'Eleanor Roosevelt', '11111111-1111-1111-1111-111111111111'),
  ('It is during our darkest moments that we must focus to see the light.', 'Aristotle', '22222222-2222-2222-2222-222222222222'),
  ('The way to get started is to quit talking and begin doing.', 'Walt Disney', '11111111-1111-1111-1111-111111111111'),
  ('Don''t be pushed around by the fears in your mind. Be led by the dreams in your heart.', 'Roy T. Bennett', '22222222-2222-2222-2222-222222222222'),
  ('Believe you can and you''re halfway there.', 'Theodore Roosevelt', '11111111-1111-1111-1111-111111111111'),
  ('The only impossible journey is the one you never begin.', 'Tony Robbins', '22222222-2222-2222-2222-222222222222'),
  ('Success is not final, failure is not fatal: it is the courage to continue that counts.', 'Winston Churchill', '11111111-1111-1111-1111-111111111111'),
  ('Innovation distinguishes between a leader and a follower.', 'Steve Jobs', '22222222-2222-2222-2222-222222222222'),
  ('Life is what happens to you while you''re busy making other plans.', 'John Lennon', '11111111-1111-1111-1111-111111111111'),
  ('The only way to do great work is to love what you do.', 'Steve Jobs', '22222222-2222-2222-2222-222222222222');

-- ==============================
-- End of seeds
-- ==============================
