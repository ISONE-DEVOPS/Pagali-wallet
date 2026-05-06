const axios = require('axios');

const sdkClient = axios.create({
  baseURL: process.env.SDK_BASE_URL || 'http://localhost:4001',
  headers: { 'Content-Type': 'application/json' },
  timeout: 30000,
});

async function initiateSendMoney(payload) {
  const { data } = await sdkClient.post('/sendmoney', payload);
  return data;
}

async function acceptParty(transferId) {
  const { data } = await sdkClient.put(`/sendmoney/${transferId}/acceptParty`, {
    acceptParty: true,
  });
  return data;
}

async function acceptQuote(transferId, acceptQuotePayload = {}) {
  const { data } = await sdkClient.put(`/sendmoney/${transferId}/acceptQuote`, {
    acceptQuote: true,
    ...acceptQuotePayload,
  });
  return data;
}

module.exports = { initiateSendMoney, acceptParty, acceptQuote };
