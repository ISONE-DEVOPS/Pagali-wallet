const express = require('express');
const cbdc = require('../data/cbdc');
const router = express.Router();

router.get('/supply', (_, res) => res.json(cbdc.getSupply()));
router.get('/wallet/:msisdn', (req, res) => res.json(cbdc.getWallet(req.params.msisdn)));
router.get('/transactions', (_, res) => res.json(cbdc.getTransactions()));

router.post('/mint', (req, res) => {
  const { msisdn, amount, authorizedBy } = req.body;
  if (!msisdn || !amount) return res.status(400).json({ error: 'msisdn e amount obrigatórios' });
  return res.status(201).json(cbdc.mint({ msisdn, amount, authorizedBy }));
});

router.post('/convert/to-cbdc', (req, res) => {
  const { msisdn, amount } = req.body;
  if (!msisdn || !amount) return res.status(400).json({ error: 'msisdn e amount obrigatórios' });
  return res.json(cbdc.convertToCBDC({ msisdn, amount }));
});

router.post('/convert/to-cve', (req, res) => {
  const { msisdn, amount } = req.body;
  const result = cbdc.convertToCVE({ msisdn, amount });
  if (!result) return res.status(400).json({ error: 'Saldo CBDC insuficiente' });
  return res.json(result);
});

router.post('/transfer', (req, res) => {
  const { fromMsisdn, toMsisdn, amount } = req.body;
  const result = cbdc.transfer({ fromMsisdn, toMsisdn, amount });
  if (!result) return res.status(400).json({ error: 'Saldo CBDC insuficiente' });
  return res.json(result);
});

module.exports = router;
