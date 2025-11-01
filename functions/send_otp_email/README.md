send_otp_email - Node.js OTP mailer for Amayalert

This small service accepts a POST to `/send_otp_email` with a JSON body `{ "newPhone": "..." }` and an `Authorization: Bearer <access_token>` header. It will:

1. Resolve the user from the access token via Supabase `auth/v1/user`.
2. Generate a 6-digit OTP and insert a row into `phone_verifications` using your Supabase service role key (bypasses RLS).
3. Send the OTP via email to the user's account email using SMTP (nodemailer).

Environment variables (set these in a `.env` file or in your hosting environment):

- SUPABASE_URL (eg. https://your-project.supabase.co)
- SUPABASE_SERVICE_ROLE (your service_role key from Supabase)
- SMTP_HOST (smtp.gmail.com)
- SMTP_PORT (587)
- SMTP_USER (your gmail address or SMTP username)
- SMTP_PASS (app password or SMTP password)
- SMTP_FROM (optional - default uses SMTP_USER)
- PORT (optional - default 3000)

Example .env (DO NOT COMMIT):

```
SUPABASE_URL=https://scnowyoufkzayjxrxmft.supabase.co
SUPABASE_SERVICE_ROLE=<your-service-role-key>
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=amayalert.site@gmail.com
SMTP_PASS=<your-gmail-app-password>
SMTP_FROM="Amayalert Support <no-reply@yourdomain.com>"
PORT=3000
```

Run locally:

```bash
cd functions/send_otp_email
npm install
npm start
```

Test (use a valid access token for an authenticated user):

```bash
curl -X POST http://localhost:3000/send_otp_email \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"newPhone":"1234567890"}'
```

Notes:

- For Gmail, use an App Password (not your main Google password) and ensure the account has app passwords enabled (2FA required).
- Keep `SUPABASE_SERVICE_ROLE` and SMTP credentials secret (store in your hosting provider's secret store or CI/CD secrets).
- The service inserts `phone_verifications` using the service role key; if you prefer to use RLS policies you can alter the approach to rely on the user's token and grant insert privileges via RLS rules instead.

Quick local test using the included Node script

1. Install deps and start the server:

```bash
cd functions/send_otp_email
npm install
npm start
```

2. Run the test script (you need a valid Supabase access token for an authenticated user):

```bash
# Unix/macOS
ACCESS_TOKEN=<ACCESS_TOKEN> NEW_PHONE="+15551234567" node test_call.js

# Optional: point to a different server
SERVER_URL=http://localhost:3000 ACCESS_TOKEN=<ACCESS_TOKEN> NEW_PHONE="+15551234567" node test_call.js
```

Gmail App Password guidance

- Go to https://myaccount.google.com/security
- Under "Signing in to Google" enable 2-Step Verification if not already enabled.
- After enabling 2SV, open "App passwords" and create a new app password for "Mail" and your device (e.g., "Other / NodeMailer").
- Use the generated 16-character app password as `SMTP_PASS`.

Security reminder

- Do not commit your `.env` file or any secret keys to source control.
- For production, set the `SUPABASE_SERVICE_ROLE` and SMTP credentials in your host's secret store (Heroku config vars, Vercel environment variables, etc.).
