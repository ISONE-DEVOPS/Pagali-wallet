const express = require('express');
const { v4: uuidv4 } = require('uuid');
const sdk = require('../services/sdk');

const router = express.Router();

// Phase 1 — Discovery: initiate P2M payment after QR scan
router.post('/', async (req, res) => {
  const { merchantId, dfspId, amount, currency, note } = req.body;

  if (!merchantId || !dfspId || !amount) {
    return res.status(400).json({ error: 'merchantId, dfspId and amount are required' });
  }

  try {
    const payload = {
      homeTransactionId: uuidv4(),
      from: {
        idType: req.body.payerIdType || 'MSISDN',
        idValue: req.body.payerIdValue,
      },
      to: {
        idType: 'BUSINESS',
        idValue: merchantId,
        fspId: dfspId,
      },
      amountType: 'SEND',
      currency: currency || 'CVE',
      amount,
      transactionType: 'TRANSFER',
      subScenario: 'PERSON_TO_BUSINESS',
      note: note || 'Pagali P2M payment',
    };

    const result = await sdk.initiateSendMoney(payload);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(502).json({ error: 'SDK error', detail: err.message });
  }
});

// Phase 2 — Agreement: confirm payee identity and receive quote
router.put('/:transferId/acceptParty', async (req, res) => {
  const { transferId } = req.params;
  try {
    const result = await sdk.acceptParty(transferId);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(502).json({ error: 'SDK error', detail: err.message });
  }
});

// Phase 3 — Transfer: accept quote and trigger final debit + merchant credit
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
