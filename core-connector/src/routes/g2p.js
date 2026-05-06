const express = require('express');
const { v4: uuidv4 } = require('uuid');
const batches = require('../data/batches');
const transfers = require('../data/transfers');
const accounts = require('../data/accounts');

const router = express.Router();
const FEE_RATE = 0.005;

// Processa cada beneficiário com delay para simular fluxo real
async function processBatch(batchId, beneficiaries) {
  for (const b of beneficiaries) {
    await new Promise(r => setTimeout(r, 800)); // simula latência de rede
    try {
      const account = accounts.findByMsisdn(b.msisdn);
      if (!account) throw new Error('Beneficiário não encontrado');

      const transferId = uuidv4();
      const amount = parseFloat(b.amount);
      const fee = (amount * FEE_RATE).toFixed(2);

      transfers.create({
        transferId,
        payer: { idType: 'MSISDN', idValue: 'GOV001', fspId: 'BCVCVCV' },
        payee: { idType: 'MSISDN', idValue: b.msisdn, fspId: account.fspId },
        amount, currency: 'CVE', fee, kind: 'G2P',
      });
      transfers.commit(transferId);

      batches.updateBeneficiary(batchId, b.msisdn, {
        transferId, state: 'SUCCESS', completedAt: new Date().toISOString(),
      });
    } catch (err) {
      batches.updateBeneficiary(batchId, b.msisdn, {
        state: 'FAILED', error: err.message,
      });
    }
  }
}

// POST /g2p/batches — iniciar disbursement
router.post('/batches', (req, res) => {
  const { program, disbursedBy, beneficiaries } = req.body;
  if (!Array.isArray(beneficiaries) || beneficiaries.length === 0) {
    return res.status(400).json({ error: 'beneficiaries é obrigatório e não pode estar vazio' });
  }
  const batch = batches.create({ program, disbursedBy, beneficiaries });
  processBatch(batch.batchId, batch.beneficiaries); // async fire-and-forget
  return res.status(202).json({ batchId: batch.batchId, state: 'PROCESSING', total: batch.total });
});

// GET /g2p/batches — listar todos os lotes
router.get('/batches', (_, res) => res.json(batches.list()));

// GET /g2p/batches/:id — estado de um lote (polling)
router.get('/batches/:batchId', (req, res) => {
  const batch = batches.get(req.params.batchId);
  if (!batch) return res.status(404).json({ error: 'Batch não encontrado' });
  const success = batch.beneficiaries.filter(b => b.state === 'SUCCESS').length;
  const failed  = batch.beneficiaries.filter(b => b.state === 'FAILED').length;
  const pending = batch.beneficiaries.filter(b => b.state === 'PENDING').length;
  return res.json({ ...batch, summary: { success, failed, pending } });
});

module.exports = router;
