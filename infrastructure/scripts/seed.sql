-- seed.sql
-- Test data for local development
-- Passwords are all bcrypt hash of "password123"

INSERT INTO users (email, password_hash, full_name, stellar_public_key, total_earned, total_weight_kg) VALUES
  ('alice@example.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Alice Mwangi',  'GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37', 12.50, 45.0),
  ('bob@example.com',   '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Bob Osei',     'GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGZM4YJLKF3QLKLE7XTJQM', 8.10,  30.0),
  ('carol@example.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Carol Diallo',  NULL, 0.0, 0.0)
ON CONFLICT (email) DO NOTHING;

INSERT INTO agents (email, password_hash, full_name, location_name, stellar_public_key) VALUES
  ('agent1@example.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'James Kamau', 'Nairobi Central Hub',  'GBVZQ3OQKZM4YJLKF3QLKLE7XTJQMGCEZWKCA5VLDNRLN3RPRJMRZOX'),
  ('agent2@example.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Fatima Sy',   'Dakar West Collection', 'GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W38')
ON CONFLICT (email) DO NOTHING;
