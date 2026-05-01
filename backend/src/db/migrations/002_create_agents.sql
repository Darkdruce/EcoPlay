-- 002_create_agents.sql
CREATE TABLE agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    location_name TEXT NOT NULL,
    stellar_public_key TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT TRUE,
    total_commission NUMERIC(18,7) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
