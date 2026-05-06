const express = require('express');
const store = require('../data/merchants');

const router = express.Router();

router.get('/', (_, res) => res.json(store.findAll()));

router.get('/:id', (req, res) => {
  const merchant = store.findById(req.params.id);
  if (!merchant) return res.status(404).json({ error: 'Merchant not found' });
  return res.json(merchant);
});

router.post('/', (req, res) => {
  const { name, fspId, mcc, city, phone } = req.body;
  if (!name || !fspId) return res.status(400).json({ error: 'name and fspId are required' });
  const merchant = store.create({ name, fspId, mcc, city, phone });
  return res.status(201).json(merchant);
});

router.put('/:id', (req, res) => {
  const merchant = store.update(req.params.id, req.body);
  if (!merchant) return res.status(404).json({ error: 'Merchant not found' });
  return res.json(merchant);
});

router.delete('/:id', (req, res) => {
  const ok = store.remove(req.params.id);
  if (!ok) return res.status(404).json({ error: 'Merchant not found' });
  return res.status(204).send();
});

module.exports = router;
