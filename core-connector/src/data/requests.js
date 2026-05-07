// Request to Pay — pedidos de pagamento iniciados pelo beneficiário
const { v4: uuidv4 } = require('uuid');

const store = new Map();

function create({ merchantId, merchantName, merchantFsp, payerMsisdn, amount, currency, description }) {
  const id = uuidv4();
  const req = {
    requestId: id,
    merchantId, merchantName, merchantFsp,
    payerMsisdn, amount: parseFloat(amount), currency: currency || 'CVE',
    description: description || 'Pedido de pagamento',
    state: 'PENDING',
    createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 300000).toISOString(), // 5 min
    transferId: null,
  };
  store.set(id, req);
  return req;
}

function get(id) { return store.get(id) || null; }

function accept(id, transferId) {
  const req = store.get(id);
  if (!req || req.state !== 'PENDING') return null;
  req.state = 'ACCEPTED';
  req.transferId = transferId;
  req.acceptedAt = new Date().toISOString();
  return req;
}

function reject(id) {
  const req = store.get(id);
  if (!req || req.state !== 'PENDING') return null;
  req.state = 'REJECTED';
  req.rejectedAt = new Date().toISOString();
  return req;
}

function listByPayer(msisdn) {
  return Array.from(store.values())
    .filter(r => r.payerMsisdn === msisdn)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

function list() {
  return Array.from(store.values()).sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

module.exports = { create, get, accept, reject, listByPayer, list };
