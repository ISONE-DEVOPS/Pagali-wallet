const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { getRate, getAllRates, FX_FEE_RATE } = require('../data/fx_rates');
const transfers = require('../data/transfers');
const accounts  = require('../data/accounts');

const router = express.Router();

// GET /fx/rates — taxas de câmbio actuais
router.get('/rates', (_, res) => res.json(getAllRates()));

// POST /fx/quote — calcular quote antes de transferir
router.post('/quote', (req, res) => {
  const { sourceCurrency, sourceAmount, payeeMsisdn } = req.body;
  if (!sourceCurrency || !sourceAmount) {
    return res.status(400).json({ error: 'sourceCurrency e sourceAmount são obrigatórios' });
  }
  try {
    const rate        = getRate(sourceCurrency);
    const srcAmt      = parseFloat(sourceAmount);
    const cveGross    = parseFloat((srcAmt * rate).toFixed(2));
    const fee         = parseFloat((cveGross * FX_FEE_RATE).toFixed(2));
    const cveNet      = parseFloat((cveGross - fee).toFixed(2));
    const quoteId     = uuidv4();
    const expiry      = new Date(Date.now() + 60000).toISOString();

    return res.json({
      quoteId, sourceCurrency, sourceAmount: srcAmt,
      targetCurrency: 'CVE', targetAmount: cveNet,
      exchangeRate: rate, fee, feeRate: `${(FX_FEE_RATE * 100).toFixed(1)}%`,
      payeeMsisdn, expiry,
    });
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
});

// POST /fx/transfers — executar transferência FX
router.post('/transfers', (req, res) => {
  const { sourceCurrency, sourceAmount, targetAmount, exchangeRate, fee, payeeMsisdn, payerMsisdn, note } = req.body;
  if (!sourceCurrency || !sourceAmount || !payeeMsisdn) {
    return res.status(400).json({ error: 'Campos obrigatórios em falta' });
  }

  const payee = accounts.findByMsisdn(payeeMsisdn);
  if (!payee) return res.status(404).json({ error: 'Beneficiário não encontrado' });

  const transferId = uuidv4();
  const record = transfers.create({
    transferId,
    payer: { idType: 'MSISDN', idValue: payerMsisdn || 'EXTERNAL', fspId: 'EXTERNAL' },
    payee: { idType: 'MSISDN', idValue: payeeMsisdn, fspId: payee.fspId },
    amount: parseFloat(targetAmount),
    currency: 'CVE',
    fee: fee?.toString() ?? '0',
    kind: 'FX',
  });
  transfers.commit(transferId);

  return res.status(201).json({
    transferId: record.transferId,
    sourceCurrency, sourceAmount,
    targetCurrency: 'CVE', targetAmount,
    exchangeRate, fee, state: 'COMMITTED',
    payee: { name: payee.name, msisdn: payeeMsisdn, fspId: payee.fspId },
    completedAt: record.completedAt,
  });
});

// GET /fx/transfers — histórico FX
router.get('/transfers', (_, res) => {
  const { list } = require('../data/transfers');
  return res.json(list().filter(t => t.kind === 'FX'));
});

module.exports = router;
