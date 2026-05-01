# EcoPlay — End-to-End Flows

---

## 1. Collector Registration & Wallet Linking

```
Collector opens apps/web → /auth/register

1. Fills in name, email, password
   POST /api/v1/auth/register
   ← { access_token }

2. Token stored in Zustand authStore

3. Collector navigates to /profile
   PATCH /api/v1/users/me/wallet { stellarPublicKey }
   ← { stellarPublicKey }

✓ Collector is now ready to receive payouts
```

---

## 2. Agent Logs a Submission (Core Flow)

```
Agent opens apps/agent-dashboard → /submissions/new

1. Agent fills SubmissionForm:
   - Collector ID (scanned or typed)
   - Material type (dropdown)
   - Weight in kg
   - Optional proof photo

2. POST /api/v1/submissions
   Authorization: Bearer <agent_jwt>

3. Backend — SubmissionsService.create():
   │
   ├─ Validate collector exists + has Stellar wallet
   ├─ Validate agent has Stellar wallet
   ├─ RewardsService.calculate(material, weight)
   │    total = price_per_kg × weight
   │    collector_amount = total × 0.60
   │    agent_amount     = total × 0.30
   │    platform_amount  = total × 0.10
   │
   ├─ INSERT submission (status = verified)
   │
   ├─ Stellar transaction (single tx, 2 operations):
   │    Operation 1: platform → collector  (collector_amount XLM)
   │    Operation 2: platform → agent      (agent_amount XLM)
   │    Platform retains platform_amount
   │
   ├─ INSERT transactions (collector_reward, agent_commission)
   ├─ UPDATE submission status = paid
   ├─ INCREMENT users.total_earned, total_weight_kg
   └─ INCREMENT agents.total_commission

4. ← 201 Submission { status: "paid", paymentTxHash }

✓ Collector and agent wallets funded instantly
```

---

## 3. Collector Views Dashboard

```
Collector opens /dashboard

1. GET /api/v1/users/me
   ← { totalEarned, totalWeightKg, ... }

2. GET /api/v1/submissions/my
   ← [ { materialType, weightKg, totalValue, status, createdAt }, ... ]

3. Dashboard renders:
   - Total earned (XLM)
   - Total weight recycled (kg)
   - Recent submissions list
```

---

## 4. Leaderboard

```
Anyone opens /leaderboard

GET /api/v1/leaderboard?limit=10
← [
    { rank: 1, fullName: "Alice Mwangi", totalEarned: 12.5, totalWeightKg: 45 },
    { rank: 2, fullName: "Bob Osei",     totalEarned: 8.1,  totalWeightKg: 30 },
    ...
  ]

No auth required. Updates in real time as submissions are paid.
```

---

## 5. Payment Failure Handling

```
Stellar submission fails (network error, insufficient platform balance, etc.)

1. PaymentsService catches error
2. INSERT transactions with success = false, error_message = <reason>
3. Submission status remains "verified" (not "paid")
4. Error propagated → handler returns 500
5. Agent sees error in dashboard, can retry

All failed attempts are recorded in transactions table for audit.
```

---

## Submission Status Lifecycle

```
pending → verified → paid
                  ↘ rejected   (future: fraud detection)
```

| Status | Meaning |
|--------|---------|
| pending | Created, not yet processed |
| verified | Agent confirmed, reward calculated |
| paid | Stellar transaction confirmed |
| rejected | Flagged as invalid (future) |
