const express = require('express');
const merchantRoutes = require('./routes/merchants');
const payments = require('./data/payments');

const app = express();
app.use(express.json());

app.get('/health', (_, res) => res.json({ status: 'ok', service: 'merchant-registry' }));
app.use('/merchants', merchantRoutes);

// Notificação de pagamento recebido (chamado pelo core-connector após commit P2M)
app.post('/payments/notify', (req, res) => {
  const { merchantId, transferId, amount, currency, fee, payerFsp, createdAt } = req.body;
  if (!merchantId || !transferId) return res.status(400).json({ error: 'merchantId e transferId obrigatórios' });
  payments.record({ merchantId, transferId, amount, currency, fee, payerFsp, createdAt });
  console.log(`[PAGAMENTO] ${merchantId} recebeu ${amount} ${currency} | TX: ${transferId}`);
  return res.status(200).json({ ok: true });
});

// Pagamentos recebidos por um comerciante
app.get('/payments/:merchantId', (req, res) => {
  return res.json(payments.getByMerchant(req.params.merchantId));
});

// Todos os pagamentos (para dashboard)
app.get('/payments', (_, res) => res.json(payments.getAll()));

const PORT = process.env.PORT || 4002;
app.listen(PORT, () => console.log(`Merchant Registry listening on port ${PORT}`));
