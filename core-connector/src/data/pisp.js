// PISP — Payment Initiation Service Provider
// Terceiros iniciam pagamentos com consentimento do utilizador
const { v4: uuidv4 } = require('uuid');

// Aplicações terceiras registadas
const THIRD_PARTY_APPS = [
  { appId: 'LOJA_ONLINE_CV', name: 'Loja Online CV',    category: 'E-commerce',  icon: '🛒', trusted: true },
  { appId: 'RENDA_CV',       name: 'Renda CV',           category: 'Imobiliário', icon: '🏠', trusted: true },
  { appId: 'TURISMO_CV',     name: 'Turismo Cabo Verde', category: 'Turismo',     icon: '✈️', trusted: true },
];

const consents    = []; // Consentimentos activos por utilizador
const initiations = []; // Pedidos de pagamento pendentes

// ── Consentimentos ────────────────────────────────────────────────────────────
function grantConsent({ msisdn, appId, maxAmount, expiresInDays }) {
  // Revogar consentimento anterior para o mesmo app
  const existing = consents.findIndex(c => c.msisdn === msisdn && c.appId === appId && c.state === 'ACTIVE');
  if (existing >= 0) consents[existing].state = 'REVOKED';

  const consent = {
    consentId: uuidv4(),
    msisdn, appId,
    app: THIRD_PARTY_APPS.find(a => a.appId === appId),
    maxAmount: maxAmount || 10000,
    currency: 'CVE',
    state: 'ACTIVE',
    grantedAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + (expiresInDays || 30) * 86400000).toISOString(),
  };
  consents.push(consent);
  console.log(`[PISP CONSENT] ${msisdn} autorizou ${appId}`);
  return consent;
}

function revokeConsent(consentId) {
  const c = consents.find(c => c.consentId === consentId);
  if (!c) return null;
  c.state = 'REVOKED';
  c.revokedAt = new Date().toISOString();
  return c;
}

function getConsents(msisdn) {
  return consents.filter(c => c.msisdn === msisdn && c.state === 'ACTIVE');
}

function hasActiveConsent(msisdn, appId) {
  return consents.some(c =>
    c.msisdn === msisdn && c.appId === appId && c.state === 'ACTIVE' && new Date(c.expiresAt) > new Date()
  );
}

function getConsentLimit(msisdn, appId) {
  const c = consents.find(c => c.msisdn === msisdn && c.appId === appId && c.state === 'ACTIVE');
  return c?.maxAmount || 0;
}

// ── Iniciações ────────────────────────────────────────────────────────────────
function initiate({ appId, payerMsisdn, payeeMsisdn, payeeFsp, amount, currency, description, reference }) {
  if (!hasActiveConsent(payerMsisdn, appId)) return { error: 'Sem consentimento activo para este app' };
  const limit = getConsentLimit(payerMsisdn, appId);
  if (parseFloat(amount) > limit) return { error: `Montante excede o limite autorizado (${limit} CVE)` };

  const app = THIRD_PARTY_APPS.find(a => a.appId === appId);
  const req = {
    initiationId: uuidv4(),
    appId, app,
    payerMsisdn, payeeMsisdn, payeeFsp,
    amount: parseFloat(amount), currency: currency || 'CVE',
    description: description || 'Pagamento iniciado por terceiro',
    reference,
    state: 'PENDING',
    createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 300000).toISOString(), // 5 min
    transferId: null,
  };
  initiations.push(req);
  console.log(`[PISP INITIATE] ${appId} iniciou pagamento de ${amount} CVE para ${payerMsisdn}`);
  return req;
}

function approve(initiationId, transferId) {
  const req = initiations.find(r => r.initiationId === initiationId);
  if (!req || req.state !== 'PENDING') return null;
  req.state = 'APPROVED';
  req.transferId = transferId;
  req.approvedAt = new Date().toISOString();
  return req;
}

function reject(initiationId) {
  const req = initiations.find(r => r.initiationId === initiationId);
  if (!req || req.state !== 'PENDING') return null;
  req.state = 'REJECTED';
  req.rejectedAt = new Date().toISOString();
  return req;
}

function getPending(msisdn) {
  return initiations.filter(r => r.payerMsisdn === msisdn && r.state === 'PENDING');
}

function getAll() {
  return [...initiations].sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

function getApps() { return THIRD_PARTY_APPS; }

module.exports = { grantConsent, revokeConsent, getConsents, hasActiveConsent, initiate, approve, reject, getPending, getAll, getApps };
