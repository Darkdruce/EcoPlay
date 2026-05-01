# EcoPlay — System Architecture

## Overview

EcoPlay is a 3-sided platform connecting collectors, agents, and recycling companies. The backend is a Rust API server. Two Next.js apps serve the collector and agent interfaces. Stellar handles all payments.

---

## Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        EcoPlay System                        │
│                                                             │
│  ┌──────────────┐        ┌──────────────────────────────┐  │
│  │  apps/web    │        │    apps/agent-dashboard      │  │
│  │  (port 3000) │        │         (port 3001)          │  │
│  │  Next.js 14  │        │          Next.js 14          │  │
│  │  Collector   │        │            Agent             │  │
│  └──────┬───────┘        └──────────────┬───────────────┘  │
│         │                               │                   │
│         └──────────────┬────────────────┘                   │
│                        │ HTTP / REST                        │
│                        ▼                                    │
│         ┌──────────────────────────────┐                   │
│         │         Rust Backend         │                   │
│         │    Axum + SQLx + Tokio       │                   │
│         │         (port 3001)          │                   │
│         │                              │                   │
│         │  ┌──────────┐ ┌──────────┐  │                   │
│         │  │  Auth    │ │Submissions│  │                   │
│         │  │ Service  │ │ Service  │  │                   │
│         │  └──────────┘ └──────────┘  │                   │
│         │  ┌──────────┐ ┌──────────┐  │                   │
│         │  │ Rewards  │ │Payments  │  │                   │
│         │  │ Service  │ │ Service  │  │                   │
│         │  └──────────┘ └──────────┘  │                   │
│         └──────┬───────────────┬───────┘                   │
│                │               │                           │
│                ▼               ▼                           │
│         ┌──────────┐   ┌──────────────┐                   │
│         │PostgreSQL│   │Stellar Horizon│                   │
│         │  (5432)  │   │  (testnet /  │                   │
│         │          │   │   mainnet)   │                   │
│         └──────────┘   └──────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Layers

### API Layer (`backend/src/api/`)
- Axum router mounted at `/api/v1`
- JWT middleware extracts `Claims { sub, email, role }` from Bearer token
- Handlers are thin — they parse input, call a service, return JSON

### Service Layer (`backend/src/services/`)
- All business logic lives here
- `AuthService` — bcrypt hashing, JWT signing
- `RewardsService` — stateless reward split calculation
- `SubmissionsService` — orchestrates the full submission flow
- `PaymentsService` — builds and submits Stellar transactions
- `LeaderboardService` — queries top collectors

### Data Layer (`backend/src/db/`)
- Raw SQLx queries, no ORM
- One file per table in `queries/`
- Migrations are plain SQL files in `migrations/`

### Stellar Layer (`backend/src/stellar/`)
- Low-level Horizon HTTP client via `reqwest`
- `load_account` → `build_tx` → `submit_tx`
- Platform keypair signs all outgoing transactions

---

## Database Schema

```
users
  id, email, password_hash, full_name, role,
  stellar_public_key, total_earned, total_weight_kg,
  is_active, created_at, updated_at

agents
  id, email, password_hash, full_name, location_name,
  stellar_public_key, is_verified, total_commission,
  created_at, updated_at

submissions
  id, collector_id → users.id, agent_id → agents.id,
  material_type, weight_kg, price_per_kg, total_value,
  status, proof_image_url, payment_tx_hash, created_at

transactions
  id, submission_id → submissions.id, tx_type,
  recipient_public_key, amount, asset,
  stellar_tx_hash, success, error_message, created_at
```

---

## Auth Flow

```
Client → POST /auth/login { email, password }
       ← 200 { access_token: JWT }

JWT payload: { sub: user_id, email, role, exp }

Protected request:
  Authorization: Bearer <token>
  → Middleware validates signature + expiry
  → Injects Claims into request extensions
  → Handler reads Claims to check role
```

---

## Reward Split

```
material_price_per_kg × weight_kg = total_value

total_value × 0.60 → collector's Stellar wallet
total_value × 0.30 → agent's Stellar wallet
total_value × 0.10 → platform wallet (retained)
```

All three are sent in a **single Stellar transaction** with multiple payment operations.

---

## Packages

| Package | Purpose |
|---------|---------|
| `@ecoplay/shared-types` | TypeScript interfaces and constants shared across both apps |
| `@ecoplay/config` | Frontend env validation (`NEXT_PUBLIC_*` vars) |
| `@ecoplay/stellar-sdk` | Stellar utilities: key validation, amount formatting, network constants |

---

## Infrastructure

```
docker-compose.yml
  postgres:16-alpine   — database, healthcheck, auto-runs init-db.sql
  backend              — Rust binary, waits for postgres healthy
  web                  — collector Next.js app
  agent-dashboard      — agent Next.js app

nginx.conf             — reverse proxy for production
  /        → web:3000
  /agent/  → agent-dashboard:3000
  /api/    → backend:3001
```
