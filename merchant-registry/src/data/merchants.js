const { v4: uuidv4 } = require('uuid');

// In-memory store — replace with a database for production
const merchants = [
  {
    id: 'MER001',
    name: 'Mercado Sucupira',
    fspId: 'BCVCVCV',
    mcc: '5411',
    city: 'Praia',
    phone: '2381234',
    active: true,
    balance: 0,
    currency: 'CVE',
    createdAt: new Date().toISOString(),
  },
  {
    id: 'MER002',
    name: 'Restaurante Sodade',
    fspId: 'BCVCVCV',
    mcc: '5812',
    city: 'Mindelo',
    phone: '2325678',
    active: true,
    balance: 0,
    currency: 'CVE',
    createdAt: new Date().toISOString(),
  },
];

function findAll() {
  return merchants.filter((m) => m.active);
}

function findById(id) {
  return merchants.find((m) => m.id === id && m.active) || null;
}

function create(data) {
  const merchant = { id: uuidv4().slice(0, 8).toUpperCase(), ...data, active: true, createdAt: new Date().toISOString() };
  merchants.push(merchant);
  return merchant;
}

function creditBalance(id, amount) {
  const m = merchants.find((m) => m.id === id);
  if (m) m.balance = parseFloat(((m.balance || 0) + parseFloat(amount)).toFixed(2));
}

function update(id, data) {
  const idx = merchants.findIndex((m) => m.id === id);
  if (idx === -1) return null;
  merchants[idx] = { ...merchants[idx], ...data };
  return merchants[idx];
}

function remove(id) {
  const idx = merchants.findIndex((m) => m.id === id);
  if (idx === -1) return false;
  merchants[idx].active = false;
  return true;
}

module.exports = { findAll, findById, create, update, remove, creditBalance };
