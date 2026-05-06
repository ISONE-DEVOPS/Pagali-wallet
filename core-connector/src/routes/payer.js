const express = require('express');
const { v4: uuidv4 } = require('uuid');
const sdk = require('../services/sdk');

const router = express.Router();

const P2M_ID_TYPES = ['BUSINESS'];

function buildPayload(body) {
  const { to, from, amount, currency, note, merchantId, dfspId, payerIdType, payerIdValue } = body;

  // Support both generic {to, from} shape and legacy P2M shape {merchantId, dfspId}
  const toIdType = to?.idType || (merchantId ? 'BUSINESS' : 'MSISDN');
  const toIdValue = to?.idValue || merchantId;
  const toFspId = to?.fspId || dfspId;
  const isP2M = P2M_ID_TYPES.includes(toIdType);

  return {
    homeTransactionId: uuidv4(),
    from: {
      idType: from?.idType || payerIdType || 'MSISDN',
      idValue: from?.idValue || payerIdValue,
    },
    to: {
      idType: toIdType,
      idValue: toIdValue,
      ...(isP2M && toFspId ? { fspId: toFspId } : {}),
    },
    amountType: 'SEND',
    currency: currency || 'CVE',
    amount: amount || body.amount,
    transactionType: 'TRANSFER',
    subScenario: isP2M ? 'PERSON_TO_BUSINESS' : 'PERSON_TO_PERSON',
    note: note || (isP2M ? 'Pagali P2M payment' : 'Pagali P2P transfer'),
  };
}

// Phase 1 — Discovery: initiate P2P or P2M transfer
// P2P body: { from: {idType, idValue}, to: {idType: 'MSISDN', idValue}, amount, currency }
// P2M body: { from: {idType, idValue}, to: {idType: 'BUSINESS', idValue, fspId}, amount, currency }
router.post('/', async (req, res) => {
  const toIdValue = req.body.to?.idValue || req.body.merchantId;
  const amount = req.body.amount;

  if (!toIdValue || !amount) {
    return res.status(400).json({ error: 'to.idValue (or merchantId) and amount are required' });
  }

  try {
    const result = await sdk.initiateSendMoney(buildPayload(req.body));
    return res.status(200).json(result);
  } catch (err) {
    return res.status(502).json({ error: 'SDK error', detail: err.message });
  }
});

// Phase 2 — Agreement: confirm resolved party and receive quote
router.put('/:transferId/acceptParty', async (req, res) => {
  const { transferId } = req.params;
  try {
    const result = await sdk.acceptParty(transferId);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(502).json({ error: 'SDK error', detail: err.message });
  }
});

// Phase 3 — Transfer: accept quote and trigger final debit + credit
router.put('/:transferId/acceptQuote', async (req, res) => {
  const { transferId } = req.params;
  try {
    const result = await sdk.acceptQuote(transferId, req.body);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(502).json({ error: 'SDK error', detail: err.message });
  }
});

module.exports = router;
