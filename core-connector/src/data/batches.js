const { v4: uuidv4 } = require('uuid');

const store = new Map();

function create({ program, disbursedBy, beneficiaries }) {
  const batchId = uuidv4();
  const batch = {
    batchId,
    program,
    disbursedBy: disbursedBy || 'Governo de Cabo Verde',
    createdAt: new Date().toISOString(),
    state: 'PROCESSING',
    total: beneficiaries.reduce((s, b) => s + parseFloat(b.amount), 0),
    currency: 'CVE',
    beneficiaries: beneficiaries.map(b => ({
      ...b,
      transferId: null,
      state: 'PENDING',
      error: null,
    })),
  };
  store.set(batchId, batch);
  return batch;
}

function get(batchId) {
  return store.get(batchId) || null;
}

function list() {
  return Array.from(store.values()).sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

function updateBeneficiary(batchId, msisdn, update) {
  const batch = store.get(batchId);
  if (!batch) return;
  const b = batch.beneficiaries.find(b => b.msisdn === msisdn);
  if (b) Object.assign(b, update);
  const allDone = batch.beneficiaries.every(b => b.state !== 'PENDING');
  if (allDone) {
    const failed = batch.beneficiaries.filter(b => b.state === 'FAILED').length;
    batch.state = failed === 0 ? 'COMPLETED' : 'COMPLETED_WITH_ERRORS';
    batch.completedAt = new Date().toISOString();
  }
}

module.exports = { create, get, list, updateBeneficiary };
