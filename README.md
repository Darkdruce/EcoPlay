# EcoPlay — Recycling Incentive Network

A blockchain-powered recycling coordination system that uses Stellar micro-payments to incentivize real-world environmental action, connecting collectors, agents, and recycling companies in a transparent and scalable ecosystem.

---

## What Is EcoPlay?

EcoPlay is a 3-sided platform that sits between people who collect recyclable waste, agents who verify and aggregate it, and recycling companies who buy it. Instead of recycling being a thankless act, EcoPlay turns it into an income stream — every verified drop-off triggers an instant Stellar payment split between the collector and the agent, with a small platform fee retained.

This model works because Stellar transactions are:
- Near-instant (3–5 seconds)
- Extremely low cost (fractions of a cent)
- Transparent and auditable on-chain

Traditional banking cannot support this kind of high-frequency, low-value payout model. Stellar can.

---

## The Three Actors

### 👤 Collectors
Individuals who gather recyclable materials (plastic, metal, glass, paper, electronics) and bring them to a registered collection point. They earn a direct cut of the material's market value, paid instantly to their Stellar wallet.

### 🏢 Collection Agents
Verified operators who run physical collection points. They weigh incoming materials, log submissions into the EcoPlay system, and earn a commission on every submission they process. Agents are the trust layer — only verified agents can create submissions.

### 🏭 Recycling Companies
Companies that purchase aggregated recyclable materials from the platform. Their bulk payments fund the reward pool that gets distributed to collectors and agents.

---

## End-to-End Flow

```
1. Collector brings recyclables to a collection point

2. Agent weighs the materials and logs a submission:
      - Collector ID
      - Material type (plastic / metal / glass / paper / electronics)
      - Weight (kg)
      - Optional proof photo

3. Backend calculates reward split based on:
      - Material base price (per kg)
      - Configured split percentages

4. Single Stellar transaction is built with 2 payment operations:
      → 60% to collector's Stellar wallet
      → 30% to agent's Stellar wallet
      → 10% retained by platform wallet

5. Submission is marked Paid, collector and agent stats are updated

6. Collector sees earnings update in real time on their dashboard
```

---

## Payment Logic

| Recipient  | Default Split |
|------------|--------------|
| Collector  | 60%          |
| Agent      | 30%          |
| Platform   | 10%          |

Splits are configurable via environment variables. All percentages must sum to 100.

**Material base prices (USD/kg):**

| Material     | Price/kg |
|--------------|----------|
| Plastic      | $0.15    |
| Metal        | $0.45    |
| Glass        | $0.08    |
| Paper        | $0.06    |
| Electronics  | $1.20    |

Example: Agent logs 10kg of metal for a collector.
- Total value: 10 × $0.45 = $4.50
- Collector receives: $2.70
- Agent receives: $1.35
- Platform retains: $0.45

---

## Gamification Layer

Engagement is sustained through a lightweight gamification system built on top of the economic core:

- **Leaderboards** — top collectors ranked by total earnings and weight recycled
- **Weekly challenges** — bonus rewards for hitting weight targets
- **Badges** — Eco Hero, Top Agent, First Drop-off, and more
- **Progress tracking** — lifetime stats visible on every collector's profile

Gamification is secondary. The economic incentive is the primary driver.

---

## Trust & Verification

Fraud prevention is built into the system architecture:

- Only verified agents can log submissions — collectors cannot self-report
- Every submission, payment, and status change is recorded with a full audit trail
- Optional proof photo upload per submission
- All Stellar transactions are publicly verifiable on-chain
- Future: GPS tagging of collection points, AI-assisted weight verification

---

## Tech Stack

| Layer            | Technology                        |
|------------------|-----------------------------------|
| Backend          | Rust (Axum, SQLx, Tokio)          |
| Database         | PostgreSQL                        |
| Payments         | Stellar (Horizon REST API)        |
| Collector App    | Next.js 14, Tailwind CSS          |
| Agent Dashboard  | Next.js 14, Tailwind CSS          |
| Auth             | JWT (bcrypt + jsonwebtoken)       |
| Infrastructure   | Docker Compose                    |

---

## Project Structure

```
EcoPlay/
│
├── backend/                          # Rust API server
│   ├── Cargo.toml                    # Dependencies: axum, sqlx, tokio, bcrypt, jwt, reqwest
│   └── src/
│       ├── main.rs                   # Entry point — boots Axum server, connects DB
│       ├── config/
│       │   └── mod.rs                # Typed config loaded from environment variables
│       ├── errors/
│       │   └── mod.rs                # AppError enum → HTTP response mapping
│       ├── models/
│       │   ├── mod.rs
│       │   ├── user.rs               # User struct (collector) — maps to users table
│       │   ├── agent.rs              # Agent struct — maps to agents table
│       │   ├── submission.rs         # Submission struct + MaterialType + SubmissionStatus enums
│       │   └── transaction.rs        # Transaction struct + TransactionType enum
│       ├── db/
│       │   ├── mod.rs                # create_pool() → PgPool
│       │   ├── migrations/
│       │   │   ├── 001_create_users.sql
│       │   │   ├── 002_create_agents.sql
│       │   │   ├── 003_create_submissions.sql
│       │   │   └── 004_create_transactions.sql
│       │   └── queries/
│       │       ├── mod.rs
│       │       ├── users.rs          # find_by_id, find_by_email, insert, increment_stats, update_wallet
│       │       ├── agents.rs         # find_by_id, find_by_email, insert, increment_commission
│       │       ├── submissions.rs    # insert, find_by_id, find_by_collector, find_by_agent, update_status
│       │       ├── transactions.rs   # insert, find_by_submission
│       │       └── leaderboard.rs    # top_collectors(limit) ORDER BY total_earned DESC
│       ├── services/
│       │   ├── mod.rs
│       │   ├── auth/
│       │   │   └── mod.rs            # register_collector, login_collector, login_agent → JWT
│       │   ├── rewards/
│       │   │   └── mod.rs            # calculate(material, weight_kg) → RewardSplit
│       │   ├── payments/
│       │   │   └── mod.rs            # send_payouts(recipients) → builds + submits Stellar tx
│       │   ├── submissions/
│       │   │   └── mod.rs            # create() — full orchestration: validate → calculate → pay → record
│       │   └── leaderboard/
│       │       └── mod.rs            # top_collectors(limit) → Vec<LeaderboardEntry>
│       ├── stellar/
│       │   └── mod.rs                # Low-level Horizon HTTP client: load_account, build_tx, submit_tx
│       └── api/
│           ├── mod.rs                # router() — mounts all route groups under /api/v1
│           ├── middleware/
│           │   └── mod.rs            # JWT extractor → injects Claims { sub, email, role }
│           ├── routes/
│           │   └── mod.rs            # All route definitions with method + path + handler mapping
│           └── handlers/
│               ├── mod.rs
│               ├── auth.rs           # POST /auth/register, /auth/login, /auth/agent/login
│               ├── users.rs          # GET /users/me, PATCH /users/me/wallet
│               ├── submissions.rs    # POST /submissions, GET /submissions, GET /submissions/my
│               ├── leaderboard.rs    # GET /leaderboard
│               └── payments.rs       # GET /payments/history
│
├── apps/
│   │
│   ├── web/                          # Collector-facing app (port 3000)
│   │   ├── package.json
│   │   ├── next.config.ts
│   │   ├── tsconfig.json
│   │   ├── tailwind.config.ts
│   │   ├── postcss.config.js
│   │   ├── .env.local
│   │   └── src/
│   │       ├── app/
│   │       │   ├── layout.tsx        # Root layout — fonts, providers, global styles
│   │       │   ├── page.tsx          # Landing / redirect to dashboard or login
│   │       │   ├── globals.css
│   │       │   ├── auth/
│   │       │   │   ├── login/page.tsx
│   │       │   │   └── register/page.tsx
│   │       │   ├── dashboard/
│   │       │   │   ├── layout.tsx    # Dashboard shell with Navbar
│   │       │   │   └── page.tsx      # Earnings summary, recent submissions
│   │       │   ├── leaderboard/
│   │       │   │   └── page.tsx      # Top collectors ranked by earnings
│   │       │   └── profile/
│   │       │       └── page.tsx      # Wallet linking, lifetime stats, badges
│   │       ├── components/
│   │       │   ├── ui/
│   │       │   │   ├── Button.tsx
│   │       │   │   ├── Card.tsx
│   │       │   │   ├── Badge.tsx
│   │       │   │   ├── Input.tsx
│   │       │   │   └── Spinner.tsx
│   │       │   ├── shared/
│   │       │   │   ├── Navbar.tsx
│   │       │   │   ├── Layout.tsx
│   │       │   │   └── ProtectedRoute.tsx
│   │       │   └── forms/
│   │       │       ├── LoginForm.tsx
│   │       │       └── RegisterForm.tsx
│   │       ├── lib/
│   │       │   ├── api/
│   │       │   │   ├── client.ts     # Axios instance with base URL + auth header injection
│   │       │   │   ├── auth.ts       # register(), login()
│   │       │   │   ├── submissions.ts # getMySubmissions()
│   │       │   │   ├── leaderboard.ts # getLeaderboard()
│   │       │   │   └── users.ts      # getMe(), linkWallet()
│   │       │   ├── stellar/
│   │       │   │   └── wallet.ts     # Stellar wallet helpers (keypair generation, validation)
│   │       │   └── utils/
│   │       │       └── format.ts     # Currency, weight, date formatters
│   │       ├── hooks/
│   │       │   ├── useAuth.ts        # Login, register, logout, current user
│   │       │   ├── useSubmissions.ts # Fetch collector's submission history
│   │       │   ├── useLeaderboard.ts # Fetch leaderboard data
│   │       │   └── useProfile.ts     # Fetch + update profile, link wallet
│   │       ├── store/
│   │       │   └── authStore.ts      # Zustand — stores JWT token + user object
│   │       └── types/
│   │           ├── index.ts          # Re-exports all types
│   │           └── api.ts            # User, Submission, Transaction, LeaderboardEntry types
│   │
│   └── agent-dashboard/              # Agent-facing app (port 3001)
│       ├── package.json
│       ├── next.config.ts
│       ├── tsconfig.json
│       ├── tailwind.config.ts
│       ├── postcss.config.js
│       ├── .env.local
│       └── src/
│           ├── app/
│           │   ├── layout.tsx        # Root layout
│           │   ├── page.tsx          # Redirect to dashboard or login
│           │   ├── globals.css
│           │   ├── auth/
│           │   │   └── login/page.tsx
│           │   ├── dashboard/
│           │   │   ├── layout.tsx    # Dashboard shell with Navbar
│           │   │   └── page.tsx      # Stats: total submissions, total commission earned
│           │   ├── submissions/
│           │   │   ├── page.tsx      # List of agent's submissions
│           │   │   └── new/page.tsx  # New submission form (weigh + assign to collector)
│           │   └── history/
│           │       └── page.tsx      # Full submission history with filters
│           ├── components/
│           │   ├── ui/
│           │   │   ├── Button.tsx
│           │   │   ├── Card.tsx
│           │   │   ├── Input.tsx
│           │   │   ├── Badge.tsx
│           │   │   └── Spinner.tsx
│           │   ├── shared/
│           │   │   ├── Navbar.tsx
│           │   │   ├── Layout.tsx
│           │   │   └── ProtectedRoute.tsx
│           │   └── forms/
│           │       ├── SubmissionForm.tsx  # Core form: collector ID, material, weight, photo
│           │       └── LoginForm.tsx
│           ├── lib/
│           │   ├── api/
│           │   │   ├── client.ts     # Axios instance
│           │   │   ├── auth.ts       # agentLogin()
│           │   │   └── submissions.ts # createSubmission(), getAgentSubmissions()
│           │   └── utils/
│           │       └── format.ts     # Formatters
│           ├── hooks/
│           │   ├── useAuth.ts        # Agent login, logout, session
│           │   └── useSubmissions.ts # Create + fetch submissions
│           ├── store/
│           │   └── authStore.ts      # Zustand — agent JWT + agent object
│           └── types/
│               ├── index.ts
│               └── api.ts            # Agent, Submission, Transaction types
│
├── infrastructure/
│   ├── docker/
│   │   ├── docker-compose.yml        # Full local stack: postgres + backend + web + agent-dashboard
│   │   ├── Dockerfile.backend        # Multi-stage Rust build → minimal debian image
│   │   └── Dockerfile.web            # Next.js build → production image
│   ├── nginx/                        # Reverse proxy config for production
│   └── scripts/                      # DB seed scripts, deploy helpers
│
├── docs/
│   ├── api/                          # API endpoint documentation
│   ├── architecture/                 # System design diagrams
│   └── flows/                        # End-to-end flow diagrams
│
├── .env.example                      # All required environment variables documented
├── .gitignore
└── README.md
```

---

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/register` | — | Register a new collector |
| POST | `/api/v1/auth/login` | — | Collector login → JWT |
| POST | `/api/v1/auth/agent/login` | — | Agent login → JWT |
| GET | `/api/v1/users/me` | JWT | Get current collector profile |
| PATCH | `/api/v1/users/me/wallet` | JWT | Link Stellar wallet |
| POST | `/api/v1/submissions` | JWT (agent) | Log a new submission + trigger payout |
| GET | `/api/v1/submissions` | JWT (agent) | Agent's own submission history |
| GET | `/api/v1/submissions/my` | JWT (collector) | Collector's own submission history |
| GET | `/api/v1/leaderboard` | — | Top collectors by earnings |
| GET | `/api/v1/payments/history` | JWT | Payment transaction history |

---

## Database Schema

**users** — collectors registered on the platform
**agents** — verified collection point operators
**submissions** — every material drop-off event, linked to a collector and agent
**transactions** — every Stellar payment attempt, success or failure, linked to a submission

---

## Getting Started

```bash
# 1. Copy and fill environment variables
cp .env.example .env

# 2. Start Postgres
docker compose -f infrastructure/docker/docker-compose.yml up postgres -d

# 3. Run the Rust backend
cd backend && cargo run

# 4. Run the collector app
cd apps/web && npm install && npm run dev

# 5. Run the agent dashboard
cd apps/agent-dashboard && npm install && npm run dev
```

---

## MVP Scope

- [x] Project structure
- [ ] Rust backend — auth, submissions, rewards, Stellar payouts
- [ ] Collector app — register, dashboard, leaderboard, profile
- [ ] Agent dashboard — submission form, history
- [ ] Docker Compose full stack

---

## Economic Model

**Revenue sources:**
- 10% platform fee on every submission payout
- Future: recycling company partnership fees, NGO grants, sponsor integrations

**Why this is fundable:**
- Directly addresses waste management in underserved regions
- Creates income for low-income collectors
- Fully transparent payment trail on Stellar blockchain
- Measurable environmental impact (kg recycled, CO₂ offset)
