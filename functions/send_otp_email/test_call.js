// Simple test script to call the local send_otp_email service.
// Usage:
//   ACCESS_TOKEN=<supabase-access-token> NEW_PHONE=+15551234567 node test_call.js

const axios = require('axios');

const accessToken = process.env.ACCESS_TOKEN;
const newPhone = process.env.NEW_PHONE || '+1234567890';
const server = process.env.SERVER_URL || 'http://localhost:3000';

if (!accessToken) {
  console.error('Please set ACCESS_TOKEN in the environment.');
  process.exit(1);
}

(async () => {
  try {
    const resp = await axios.post(
      `${server}/send_otp_email`,
      { newPhone },
      { headers: { Authorization: `Bearer ${accessToken}` } }
    );

    console.log('Response status:', resp.status);
    console.log('Response data:', resp.data);
  } catch (err) {
    console.error('Error calling send_otp_email:', err.response ? err.response.data : err.message);
    process.exit(1);
  }
})();
