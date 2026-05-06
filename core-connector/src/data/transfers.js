// In-memory transfer store — holds state between POST /transfers and accept-quote
const store = new Map();

function create({ transferId, payer, payee, amount, currency, fee }) {
  const record = {
    transferId, payer, payee, amount, currency, fee,
    state: 'RESERVED',
    createdAt: new Date().toISOString(),
    expiry: new Date(Date.now() + 60000).toISOString(),
  };
  store.set(transferId, record);
  return record;
}

function get(transferId) {
  return store.get(transferId) || null;
}

function commit(transferId) {
  const record = store.get(transferId);
  if (!record) return null;
  record.state = 'COMMITTED';
  record.completedAt = new Date().toISOString();
  return record;
}

function list() {
  return Array.from(store.values()).sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

module.exports = { create, get, commit, list };
