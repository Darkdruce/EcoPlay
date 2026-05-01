-- init-db.sql
-- Runs once on first Postgres container start via docker-entrypoint-initdb.d
-- Creates enums and tables for EcoPlay

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enums
CREATE TYPE user_role AS ENUM ('collector', 'admin');
CREATE TYPE material_type AS ENUM ('plastic', 'metal', 'glass', 'paper', 'electronics');
CREATE TYPE submission_status AS ENUM ('pending', 'verified', 'paid', 'rejected');
CREATE TYPE transaction_type AS ENUM ('collector_reward', 'agent_commission', 'platform_fee');

-- Users (collectors)
CREATE TABLE IF NOT EXISTS users (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email            TEXT UNIQUE NOT NULL,
    password_hash    TEXT NOT NULL,
    full_name        TEXT NOT NULL,
    role             user_role NOT NULL DEFAULT 'collector',
    stellar_public_key TEXT,
    total_earned     NUMERIC(18,7) NOT NULL DEFAULT 0,
    total_weight_kg  NUMERIC(10,2) NOT NULL DEFAULT 0,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Agents
CREATE TABLE IF NOT EXISTS agents (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email            TEXT UNIQUE NOT NULL,
    password_hash    TEXT NOT NULL,
    full_name        TEXT NOT NULL,
    location_name    TEXT NOT NULL,
    stellar_public_key TEXT,
    is_verified      BOOLEAN NOT NULL DEFAULT TRUE,
    total_commission NUMERIC(18,7) NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Submissions
CREATE TABLE IF NOT EXISTS submissions (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collector_id     UUID NOT NULL REFERENCES users(id),
    agent_id         UUID NOT NULL REFERENCES agents(id),
    material_type    material_type NOT NULL,
    weight_kg        NUMERIC(10,2) NOT NULL,
    price_per_kg     NUMERIC(10,4) NOT NULL,
    total_value      NUMERIC(18,7) NOT NULL,
    status           submission_status NOT NULL DEFAULT 'pending',
    proof_image_url  TEXT,
    payment_tx_hash  TEXT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Transactions
CREATE TABLE IF NOT EXISTS transactions (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id        UUID NOT NULL REFERENCES submissions(id),
    tx_type              transaction_type NOT NULL,
    recipient_public_key TEXT NOT NULL,
    amount               NUMERIC(18,7) NOT NULL,
    asset                TEXT NOT NULL DEFAULT 'XLM',
    stellar_tx_hash      TEXT,
    success              BOOLEAN NOT NULL DEFAULT FALSE,
    error_message        TEXT,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_submissions_collector ON submissions(collector_id);
CREATE INDEX IF NOT EXISTS idx_submissions_agent ON submissions(agent_id);
CREATE INDEX IF NOT EXISTS idx_transactions_submission ON transactions(submission_id);
CREATE INDEX IF NOT EXISTS idx_users_total_earned ON users(total_earned DESC);
