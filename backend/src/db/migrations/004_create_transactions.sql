-- 004_create_transactions.sql
CREATE TYPE transaction_type AS ENUM ('collector_reward','agent_commission','platform_fee');

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id UUID NOT NULL REFERENCES submissions(id),
    tx_type transaction_type NOT NULL,
    recipient_public_key TEXT NOT NULL,
    amount NUMERIC(18,7) NOT NULL,
    asset TEXT NOT NULL DEFAULT 'XLM',
    stellar_tx_hash TEXT,
    success BOOLEAN NOT NULL DEFAULT FALSE,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
