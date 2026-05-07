const express = require('express');
const pisp      = require('../data/pisp');
const transfers = require('../data/transfers');
const { v4: uuidv4 } = require('uuid');

const router = express.Router();
const FEE_RATE = 0.005;

// Apps terceiras disponíveis
router.get('/apps', (_, res) => res.json(pisp.getApps()));

// ── Consentimentos ────────────────────────────────────────────────────────────
router.get('/consents/:msisdn', (req, res) => res.json(pisp.getConsents(req.params.msisdn)));

router.post('/consents', (req, res) => {
  const { msisdn, appId, maxAmount, expiresInDays } = req.body;
  if (!msisdn || !appId) return res.status(400).json({ error: 'msisdn e appId obrigatórios' });
  return res.status(201).json(pisp.grantConsent({ msisdn, appId, maxAmount, expiresInDays }));
});

router.delete('/consents/:consentId', (req, res) => {
  const result = pisp.revokeConsent(req.params.consentId);
  if (!result) return res.status(404).json({ error: 'Consentimento não encontrado' });
  return res.json(result);
});

// ── Iniciações ────────────────────────────────────────────────────────────────

// App terceira inicia pagamento (requer consentimento activo)
router.post('/initiate', (req, res) => {
  const { appId, payerMsisdn, payeeMsisdn, payeeFsp, amount, currency, description, reference } = req.body;
  if (!appId || !payerMsisdn || !amount) return res.status(400).json({ error: 'appId, payerMsisdn e amount obrigatórios' });
  const result = pisp.initiate({ appId, payerMsisdn, payeeMsisdn, payeeFsp, amount, currency, description, reference });
  if (result.error) return res.status(403).json(result);
  return res.status(201).json(result);
});

// Pedidos pendentes para um utilizador
router.get('/pending/:msisdn', (req, res) => res.json(pisp.getPending(req.params.msisdn)));

// Todos os pedidos (dashboard)
router.get('/initiations', (_, res) => res.json(pisp.getAll()));

// Utilizador aprova
router.post('/initiations/:id/approve', (req, res) => {
  const req_ = pisp.getPending('')[0]; // find by id
  const all = pisp.getAll();
  const found = all.find(r => r.initiationId === req.params.id);
  if (!found || found.state !== 'PENDING') return res.status(404).json({ error: 'Pedido não encontrado ou já processado' });

  const transferId = uuidv4();
  const fee = parseFloat((found.amount * FEE_RATE).toFixed(2));
  transfers.create({
    transferId,
    payer: { idType: 'MSISDN', idValue: found.payerMsisdn, fspId: 'BCVCVCV' },
    payee: { idType: 'MSISDN', idValue: found.payeeMsisdn || 'MERCHANT', fspId: found.payeeFsp || 'BCVCVCV' },
    amount: found.amount, currency: found.currency, fee, kind: 'PISP',
  });
  transfers.commit(transferId);

  const approved = pisp.approve(found.initiationId, transferId);
  return res.json({ ...approved, transferId, fee });
});

// Utilizador rejeita
router.post('/initiations/:id/reject', (req, res) => {
  const result = pisp.reject(req.params.id);
  if (!result) return res.status(404).json({ error: 'Pedido não encontrado ou já processado' });
  return res.json(result);
});

module.exports = router;
