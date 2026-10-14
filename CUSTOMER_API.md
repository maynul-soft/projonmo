# Tecqora Customer & Public API (`/api/v1`)

> **Full integration guide (auth, envelopes, app flows):** [API_GUIDE.md](./API_GUIDE.md)

Base URL: `http://localhost:8001/api/v1`

Maintenance mode (`PlatformSetting` key `maintenance`) returns **503** on `/public/*`, `/customer/auth/*`, and `/customer/*` when enabled. Admin routes and `POST /auth/login` are unaffected.

## Public (no auth)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/public/home` | Homepage + general + telegram + app download settings |
| GET | `/public/banners` | Active banners |
| GET | `/public/faqs` | Published FAQs |
| GET | `/public/rules` | Published rules |
| GET | `/public/videos` | Active videos |
| GET | `/public/posts` | Published posts |
| GET | `/public/lucky-gifts` | Active lucky gift campaigns |
| GET | `/public/announcement-popup` | Current active popup or `null` |
| GET | `/public/app-download` | App download settings JSON |
| GET | `/public/telegram` | Telegram settings JSON |
| GET | `/public/categories` | Active product categories |
| GET | `/public/products` | Active products list |
| GET | `/public/products/:id` | Product detail |

## Customer auth (no Bearer token)

| Method | Path | Body |
|--------|------|------|
| POST | `/customer/auth/send-otp` | `{ "mobile": "017..." }` |
| POST | `/customer/auth/verify-otp` | `{ "mobile", "code" }` |
| POST | `/customer/auth/register` | `{ "mobile", "password", "otp", "referralCode?" }` |
| POST | `/customer/auth/login` | `{ "mobile", "password" }` |
| POST | `/customer/auth/refresh` | `{ "refreshToken" }` — rotates refresh token, returns new pair |

Response login/register/refresh: `{ user, accessToken, refreshToken, expiresIn, refreshExpiresAt? }`

**Dev OTP:** set `OTP_DEV_CODE=123456` in `.env` to accept that code without SMS. OTP is logged to console in development.

## Customer (header `Authorization: Bearer <accessToken>`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/customer/me` | Profile |
| PATCH | `/customer/me/password` | `{ currentPassword, newPassword }` |
| POST | `/customer/auth/sign-out` | Optional `{ "refreshToken" }` to revoke server-side refresh token |
| GET | `/customer/dashboard` | Balance, VIP, referral link, counts |
| GET | `/customer/products/mine` | Purchased products |
| POST | `/customer/products/:id/purchase` | Buy with balance |
| GET | `/customer/payment-methods` | Admin deposit methods (active) |
| POST | `/customer/deposits` | `{ amount, method, txnId, proofUrl? }` |
| GET | `/customer/deposits` | Deposit history |
| GET | `/customer/transactions` | Deposits + withdrawals combined |
| GET | `/customer/withdrawal-methods` | Saved payout accounts |
| POST | `/customer/withdrawal-methods` | `{ method, accountNo, accountName, isDefault? }` |
| DELETE | `/customer/withdrawal-methods/:id` | Remove saved method |
| POST | `/customer/withdrawals` | `{ methodId, amount }` |
| GET | `/customer/withdrawals` | Withdrawal history |
| GET | `/customer/team` | Team summary (§70 team APIs — staged A/B/C view) |
| GET | `/customer/income` | Income ledger history |
| GET | `/customer/points` | Points balance + conversion rules |
| POST | `/customer/points/redeem` | `{ "points": 500 }` |
| POST | `/customer/uploads` | Multipart `file` (deposit proof, etc.) |

## Admin login (unchanged)

`POST /auth/login` with `{ "adminId", "password" }`

## Migrate & seed

```bash
npm run prisma:migrate -- --name user_refresh_token
npm run prisma:seed
```

Demo customer after seed: **01712345678** / **123456**
