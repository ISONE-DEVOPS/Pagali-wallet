const express = require('express');
const QRCode = require('qrcode');
const { generate } = require('../qr/generator');
const { parse } = require('../qr/parser');

const router = express.Router();

// Generate EMVCo QR — returns TLV string and base64 PNG image
router.post('/generate', async (req, res) => {
  const { merchantId, dfspSwift, merchantName, merchantCity, mcc, currency, amount } = req.body;

  if (!merchantId || !dfspSwift || !merchantName || !merchantCity) {
    return res.status(400).json({ error: 'merchantId, dfspSwift, merchantName and merchantCity are required' });
  }

  try {
    const qrString = generate({ merchantId, dfspSwift, merchantName, merchantCity, mcc, currency, amount });
    const qrImage = await QRCode.toDataURL(qrString, { errorCorrectionLevel: 'M', width: 300 });
    return res.status(200).json({ qrString, qrImage, type: amount ? 'DYNAMIC' : 'STATIC' });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

// Parse and validate EMVCo QR string
router.post('/parse', (req, res) => {
  const { qrString } = req.body;
  if (!qrString) return res.status(400).json({ error: 'qrString is required' });

  try {
    const result = parse(qrString);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(422).json({ valid: false, error: err.message });
  }
});

module.exports = router;
