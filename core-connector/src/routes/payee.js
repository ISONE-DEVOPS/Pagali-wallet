const express = require('express');
const axios = require('axios');
const accounts = require('../data/accounts');
const transfers = require('../data/transfers');

const router = express.Router();

const registryUrl = process.env.MERCHANT_REGISTRY_URL || 'http://localhost:4002';

const FEE_RATE = 0.005; // 0.5%

// Phase 1a — P2P party lookup: ALS resolves MSISDN to account holder
router.get('/parties/MSISDN/:msisdn', (req, res) => {
  const account = accounts.findByMsisdn(req.params.msisdn);
  if (!account) {
    return res.status(404).json({ errorInformation: { errorCode: '3204', errorDescription: 'Party not found' } });
  }
  return res.status(200).json({
    party: {
      partyIdInfo: { partyIdType: 'MSISDN', partyIdentifier: req.params.msisdn, fspId: account.fspId },
      name: account.name,
    },
  });
});

// Phase 1b — P2M party lookup: ALS resolves BUSINESS ID to merchant
router.get('/parties/BUSINESS/:merchantId', async (req, res) => {
  const { merchantId } = req.params;
  try {
    const { data: merchant } = await axios.get(`${registryUrl}/merchants/${merchantId}`);
    return res.status(200).json({
      party: {
        partyIdInfo: { partyIdType: 'BUSINESS', partyIdentifier: merchantId, fspId: merchant.fspId },
        name: merchant.name,
        merchantClassificationCode: merchant.mcc || '0000',
      },
    });
  } catch {
    return res.status(404).json({ errorInformation: { errorCode: '3204', errorDescription: 'Party not found' } });
  }
});

// GET /transfers — listar todas as transferências (para debug/monitorização)
router.get('/transfers', (req, res) => {
  return res.status(200).json(transfers.list());
});

// GET /transfers/:id — detalhes de uma transferência
router.get('/transfers/:transferId', (req, res) => {
  const record = transfers.get(req.params.transferId);
  if (!record) return res.status(404).json({ error: 'Transfer not found' });
  return res.status(200).json(record);
});

// Phase 2 — Reserve transfer + calculate fee
router.post('/transfers', (req, res) => {
  const { transferId, payer, payee, amount, currency } = req.body;
  if (!transferId || !amount) {
    return res.status(400).json({ error: 'transferId and amount are required' });
  }

  const parsedAmount = parseFloat(amount);
  const fee = (parsedAmount * FEE_RATE).toFixed(2);
  const kind = req.body.kind || (payee?.idType === 'BUSINESS' ? 'P2M' : 'P2P');
  const record = transfers.create({ transferId, payer, payee, amount: parsedAmount, currency: currency || 'CVE', fee, kind });

  return res.status(200).json({
    transferId: record.transferId,
    fee,
    currency: record.currency,
    state: 'RESERVED',
    expiry: record.expiry,
  });
});

// Phase 3 — Execute: commit the reserved transfer
router.post('/transfers/:transferId/accept-quote', async (req, res) => {
  const { transferId } = req.params;
  const record = transfers.commit(transferId);
  if (!record) {
    return res.status(404).json({ error: 'Transfer not found', transferId });
  }

  // Notificar merchant registry se for um pagamento P2M
  if (record.kind === 'P2M' && record.payee?.idValue) {
    axios.post(`${registryUrl}/payments/notify`, {
      merchantId: record.payee.idValue,
      transferId: record.transferId,
      amount: record.amount,
      currency: record.currency,
      fee: record.fee,
      payerFsp: record.payer?.fspId,
      createdAt: record.completedAt,
    }).catch(() => {}); // fire-and-forget
  }

  return res.status(200).json({
    transferId: record.transferId,
    state: 'COMMITTED',
    completedAt: record.completedAt,
  });
});

module.exports = router;
