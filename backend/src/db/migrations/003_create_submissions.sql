-- 003_create_submissions.sql
CREATE TYPE material_type AS ENUM ('plastic','metal','glass','paper','electronics');
CREATE TYPE submission_status AS ENUM ('pending','verified','paid','rejected');

CREATE TABLE submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collector_id UUID NOT NULL REFERENCES users(id),
    agent_id UUID NOT NULL REFERENCES agents(id),
    material_type material_type NOT NULL,
    weight_kg NUMERIC(10,2) NOT NULL,
    price_per_kg NUMERIC(10,4) NOT NULL,
    total_value NUMERIC(18,7) NOT NULL,
    status submission_status NOT NULL DEFAULT 'pending',
    proof_image_url TEXT,
    payment_tx_hash TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
