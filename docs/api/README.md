# EcoPlay API Reference

Base URL: `http://localhost:3001/api/v1`

All protected endpoints require:
```
Authorization: Bearer <jwt_token>
```

---

## Auth

### POST /auth/register
Register a new collector.

**Body**
```json
{
  "email": "alice@example.com",
  "password": "password123",
  "fullName": "Alice Mwangi"
}
```

**Response 201**
```json
{ "access_token": "<jwt>" }
```

**Errors**
- `409` — email already registered

---

### POST /auth/login
Collector login.

**Body**
```json
{ "email": "alice@example.com", "password": "password123" }
```

**Response 200**
```json
{ "access_token": "<jwt>" }
```

**Errors**
- `401` — invalid credentials

---

### POST /auth/agent/login
Agent login.

**Body**
```json
{ "email": "agent1@example.com", "password": "password123" }
```

**Response 200**
```json
{ "access_token": "<jwt>" }
```

---

## Users

### GET /users/me
Get the authenticated collector's profile.

**Auth:** JWT (collector)

**Response 200**
```json
{
  "id": "uuid",
  "email": "alice@example.com",
  "fullName": "Alice Mwangi",
  "role": "collector",
  "stellarPublicKey": "GDQP2...",
  "totalEarned": 12.5,
  "totalWeightKg": 45.0,
  "isActive": true,
  "createdAt": "2026-01-01T00:00:00Z",
  "updatedAt": "2026-01-01T00:00:00Z"
}
```

---

### PATCH /users/me/wallet
Link a Stellar wallet to the collector's account.

**Auth:** JWT (collector)

**Body**
```json
{ "stellarPublicKey": "GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37" }
```

**Response 200**
```json
{ "stellarPublicKey": "GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37" }
```

**Errors**
- `400` — invalid Stellar public key format

---

## Submissions

### POST /submissions
Log a new material submission and trigger Stellar payouts.

**Auth:** JWT (agent only)

**Body**
```json
{
  "collectorId": "uuid",
  "materialType": "metal",
  "weightKg": 10.0,
  "proofImageUrl": "https://..." 
}
```

`materialType` values: `plastic` | `metal` | `glass` | `paper` | `electronics`

**Response 201**
```json
{
  "id": "uuid",
  "collectorId": "uuid",
  "agentId": "uuid",
  "materialType": "metal",
  "weightKg": 10.0,
  "pricePerKg": 0.45,
  "totalValue": 4.5,
  "status": "paid",
  "paymentTxHash": "abc123...",
  "createdAt": "2026-01-01T00:00:00Z"
}
```

**Errors**
- `404` — collector not found
- `400` — collector or agent has no Stellar wallet linked
- `403` — caller is not an agent

---

### GET /submissions
Agent's own submission history.

**Auth:** JWT (agent)

**Response 200** — array of Submission objects, ordered by `createdAt DESC`

---

### GET /submissions/my
Collector's own submission history.

**Auth:** JWT (collector)

**Response 200** — array of Submission objects, ordered by `createdAt DESC`

---

## Leaderboard

### GET /leaderboard
Top collectors ranked by total earnings.

**Auth:** None

**Query params**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| limit | int  | 10      | Max entries to return (max 100) |

**Response 200**
```json
[
  {
    "rank": 1,
    "id": "uuid",
    "fullName": "Alice Mwangi",
    "totalEarned": 12.5,
    "totalWeightKg": 45.0
  }
]
```

---

## Payments

### GET /payments/history
Transaction history for the authenticated user.

**Auth:** JWT (collector or agent)

**Response 200**
```json
[
  {
    "id": "uuid",
    "submissionId": "uuid",
    "txType": "collector_reward",
    "recipientPublicKey": "GDQP2...",
    "amount": 2.7,
    "asset": "XLM",
    "stellarTxHash": "abc123...",
    "success": true,
    "createdAt": "2026-01-01T00:00:00Z"
  }
]
```

---

## Error Format

All errors return:
```json
{ "error": "Human-readable message" }
```

| Status | Meaning |
|--------|---------|
| 400 | Bad request / validation error |
| 401 | Missing or invalid JWT |
| 403 | Insufficient role |
| 404 | Resource not found |
| 500 | Internal server error |
