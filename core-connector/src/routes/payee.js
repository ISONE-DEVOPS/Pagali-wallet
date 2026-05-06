const express = require('express');
const axios = require('axios');
const accounts = require('../data/accounts');

const router = express.Router();

const registryUrl = process.env.MERCHANT_REGISTRY_URL || 'http://localhost:4002';

// API 1a — P2P party lookup: ALS resolves MSISDN to account holder
router.get('/parties/MSISDN/:msisdn', (req, res) => {
  const account = accounts.findByMsisdn(req.params.msisdn);
  if (!account) {
    return res.status(404).json({ errorInformation: { errorCode: '3204', errorDescription: 'Party not found' } });
  }
  return res.status(200).json({
    party: {
      partyIdInfo: {
        partyIdType: 'MSISDN',
        partyIdentifier: req.params.msisdn,
        fspId: account.fspId,
      },
      name: account.name,
    },
  });
});

// API 1b — P2M party lookup: ALS resolves BUSINESS ID to merchant
router.get('/parties/BUSINESS/:merchantId', async (req, res) => {
  const { merchantId } = req.params;
  try {
    const { data: merchant } = await axios.get(`${registryUrl}/merchants/${merchantId}`);
    return res.status(200).json({
      party: {
        partyIdInfo: {
          partyIdType: 'BUSINESS',
          partyIdentifier: merchantId,
          fspId: merchant.fspId,
        },
        name: merchant.name,
        merchantClassificationCode: merchant.mcc || '0000',
      },
    });
  } catch {
    return res.status(404).json({ errorInformation: { errorCode: '3204', errorDescription: 'Party not found' } });
  }
});

// API 2 — Quote: return applicable fees for the transaction
router.post('/quoterequests', (req, res) => {
  const { amount } = req.body;
  const fee = (parseFloat(amount?.amount || 0) * 0.005).toFixed(2);
  return res.status(200).json({
    transferAmount: amount,
    payeeFspFee: { amount: fee, currency: amount?.currency || 'CVE' },
    payeeFspCommission: { amount: '0', currency: amount?.currency || 'CVE' },
    expiration: new Date(Date.now() + 60000).toISOString(),
  });
});

// API 3 — Pre-validation: check limits and account status before transfer
router.post('/transfers', (req, res) => {
  return res.status(200).json({ transferState: 'RESERVED' });
});

// API 4 — Credit posting: confirm and credit merchant account
router.put('/transfers/:transferId', (req, res) => {
  const { transferId } = req.params;
  return res.status(200).json({ transferId, transferState: 'COMMITTED' });
});

module.exports = router;
