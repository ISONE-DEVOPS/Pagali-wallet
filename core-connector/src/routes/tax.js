const express = require('express');
const tax = require('../data/tax');
const router = express.Router();

router.get('/types', (_, res) => res.json(tax.getTypes()));

router.post('/calculate', (req, res) => {
  const { code, baseAmount } = req.body;
  const result = tax.calculate({ code, baseAmount });
  if (!result) return res.status(400).json({ error: 'Tipo de imposto inválido' });
  return res.json(result);
});

router.post('/pay', (req, res) => {
  const { nif, code, baseAmount, payerMsisdn, period } = req.body;
  if (!nif || !code || !baseAmount) return res.status(400).json({ error: 'nif, code e baseAmount obrigatórios' });
  const receipt = tax.pay({ nif, code, baseAmount, payerMsisdn, period });
  if (!receipt) return res.status(400).json({ error: 'Tipo de imposto inválido' });
  return res.status(201).json(receipt);
});

router.get('/receipts/:nif', (req, res) => res.json(tax.getReceipts(req.params.nif)));
router.get('/receipts', (_, res) => res.json(tax.getAllReceipts()));

module.exports = router;
