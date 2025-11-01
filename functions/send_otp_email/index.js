const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const nodemailer = require('nodemailer');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());

const {
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE,
  SMTP_HOST,
  SMTP_PORT,
  SMTP_USER,
  SMTP_PASS,
  SMTP_FROM,
  PORT,
} = process.env;

if (!SUPABASE_URL) console.warn('Warning: SUPABASE_URL is not set');
if (!SUPABASE_SERVICE_ROLE) console.warn('Warning: SUPABASE_SERVICE_ROLE is not set');
if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS)
  console.warn('Warning: SMTP credentials are not fully set');

const smtpPort = parseInt(SMTP_PORT || '587', 10);

const transporter = nodemailer.createTransport({
  host: SMTP_HOST,
  port: smtpPort,
  secure: smtpPort === 465, // true for 465, false for other ports
  auth: {
    user: SMTP_USER,
    pass: SMTP_PASS,
  },
  tls: {
    // Allow self-signed certs (useful for some providers / testing). Remove in production if not needed.
    rejectUnauthorized: false,
  },
});

app.post('/send_otp_email', async (req, res) => {
  try {
    const auth = req.headers['authorization'] || req.headers['Authorization'];
    const token = (auth || '').toString().startsWith('Bearer ')
      ? (auth || '').toString().split(' ')[1]
      : null;
    if (!token) return res.status(401).json({ error: 'Missing Authorization Bearer token' });

    const { newPhone } = req.body || {};
    if (!newPhone) return res.status(400).json({ error: 'newPhone is required' });

    // Resolve user info from token via Supabase auth endpoint
    const userRes = await axios.get(`${SUPABASE_URL}/auth/v1/user`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const user = userRes.data;
    const userId = user?.id;
    const userEmail = user?.email;
    if (!userId || !userEmail)
      return res.status(400).json({ error: 'Unable to determine user from token' });

    // Generate 6-digit code
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();

    // Insert verification record using service role key (bypass RLS)
    const insertRes = await axios.post(
      `${SUPABASE_URL}/rest/v1/phone_verifications`,
      {
        user_id: userId,
        phone: newPhone,
        code,
        expires_at: expiresAt,
        verified: false,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          apikey: SUPABASE_SERVICE_ROLE,
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE}`,
          Prefer: 'return=representation',
        },
      }
    );

    if (![200, 201].includes(insertRes.status)) {
      return res
        .status(500)
        .json({ error: 'Failed to create verification record', details: insertRes.data });
    }

    // Compose email
    const from = SMTP_FROM || `"Amayalert Support" <${SMTP_USER}>`;
    const mailOptions = {
      from,
      to: userEmail,
      subject: 'Your Amayalert verification code',
      text: `Your verification code is ${code}. It will expire in 10 minutes.`,
      html: `<p>Your verification code is <strong>${code}</strong>.</p><p>It will expire in 10 minutes.</p>`,
    };

    // Send email
    const info = await transporter.sendMail(mailOptions);
    console.log('OTP email sent:', info && info.messageId ? info.messageId : info);

    return res.json({ success: true });
  } catch (err) {
    console.error('send_otp_email error', err?.response?.data || err.message || err);
    return res
      .status(500)
      .json({
        error: 'Internal server error',
        details: err?.response?.data || err.message || String(err),
      });
  }
});

const listenPort = parseInt(PORT || '3000', 10);
app.listen(listenPort, () => {
  console.log(`send_otp_email server running on http://localhost:${listenPort}`);
});

module.exports = app;
