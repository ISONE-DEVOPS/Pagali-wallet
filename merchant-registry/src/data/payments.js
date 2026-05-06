// Registo de pagamentos recebidos por cada comerciante
const store = new Map(); // merchantId → [payments]

function record({ merchantId, transferId, amount, currency, fee, payerFsp, createdAt }) {
  if (!store.has(merchantId)) store.set(merchantId, []);
  store.get(merchantId).unshift({ transferId, amount, currency, fee, payerFsp, createdAt });
}

function getByMerchant(merchantId) {
  return store.get(merchantId) || [];
}

function getAll() {
  const result = [];
  for (const [merchantId, payments] of store) {
    payments.forEach(p => result.push({ merchantId, ...p }));
  }
  return result.sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

module.exports = { record, getByMerchant, getAll };
