const express = require('express');
const requests = require('../data/requests');
const transfers = require('../data/transfers');
const { v4: uuidv4 } = require('uuid');

const router = express.Router();
const FEE_RATE = 0.005;

// Merchant cria pedido de pagamento
router.post('/', (req, res) => {
  const { merchantId, merchantName, merchantFsp, payerMsisdn, amount, currency, description } = req.body;
  if (!merchantId || !payerMsisdn || !amount) {
    return res.status(400).json({ error: 'merchantId, payerMsisdn e amount obrigatórios' });
  }
  const r = requests.create({ merchantId, merchantName, merchantFsp, payerMsisdn, amount, currency, description });
  return res.status(201).json(r);
});

// Listar pedidos pendentes para um pagador
router.get('/payer/:msisdn', (req, res) => {
  return res.json(requests.listByPayer(req.params.msisdn));
});

// Listar todos os pedidos
router.get('/', (_, res) => res.json(requests.list()));

// Ver pedido específico
router.get('/:id', (req, res) => {
  const r = requests.get(req.params.id);
  if (!r) return res.status(404).json({ error: 'Pedido não encontrado' });
  return res.json(r);
});

// Pagador aceita
router.post('/:id/accept', (req, res) => {
  const r = requests.get(req.params.id);
  if (!r) return res.status(404).json({ error: 'Pedido não encontrado' });
  if (r.state !== 'PENDING') return res.status(400).json({ error: `Pedido já ${r.state}` });

  const transferId = uuidv4();
  const fee = parseFloat((r.amount * FEE_RATE).toFixed(2));
  transfers.create({
    transferId,
    payer: { idType: 'MSISDN', idValue: r.payerMsisdn, fspId: 'BCVCVCV' },
    payee: { idType: 'BUSINESS', idValue: r.merchantId, fspId: r.merchantFsp || 'BCVCVCV' },
    amount: r.amount, currency: r.currency, fee, kind: 'R2P',
  });
  transfers.commit(transferId);
  const accepted = requests.accept(r.requestId, transferId);
  return res.json({ ...accepted, transferId, fee });
});

// Pagador rejeita
router.post('/:id/reject', (req, res) => {
  const r = requests.reject(req.params.id);
  if (!r) return res.status(404).json({ error: 'Pedido não encontrado ou já processado' });
  return res.json(r);
});

module.exports = router;
