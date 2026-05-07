const express = require('express');
const agents = require('../data/agents');

const router = express.Router();
const AGENT_FEE = 50; // CVE taxa fixa por operação

// Listar agentes
router.get('/', (_, res) => res.json(agents.listAgents()));

// Todas as transações de todos os agentes
router.get('/transactions/all', (_, res) => {
  const all = agents.listAgents().flatMap(a =>
    agents.getTransactions(a.agentId).map(t => ({ ...t, agentName: a.name, island: a.island }))
  ).sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  return res.json(all);
});

// Detalhes + transações de um agente
router.get('/:id', (req, res) => {
  const agent = agents.getAgent(req.params.id);
  if (!agent) return res.status(404).json({ error: 'Agente não encontrado' });
  const txs = agents.getTransactions(req.params.id);
  return res.json({ ...agent, transactions: txs });
});

// Cash-in: cliente deposita dinheiro via agente → wallet creditada
router.post('/:id/cash-in', (req, res) => {
  const { customerMsisdn, amount } = req.body;
  if (!customerMsisdn || !amount) return res.status(400).json({ error: 'customerMsisdn e amount obrigatórios' });
  const tx = agents.cashIn({ agentId: req.params.id, customerMsisdn, amount, fee: AGENT_FEE });
  if (!tx) return res.status(404).json({ error: 'Agente não encontrado' });
  console.log(`[AGENT CASH-IN] ${req.params.id} → ${customerMsisdn}: ${amount} CVE`);
  return res.status(201).json(tx);
});

// Cash-out: cliente levanta dinheiro via agente → wallet debitada
router.post('/:id/cash-out', (req, res) => {
  const { customerMsisdn, amount } = req.body;
  if (!customerMsisdn || !amount) return res.status(400).json({ error: 'customerMsisdn e amount obrigatórios' });
  const tx = agents.cashOut({ agentId: req.params.id, customerMsisdn, amount, fee: AGENT_FEE });
  if (!tx) return res.status(404).json({ error: 'Agente não encontrado' });
  console.log(`[AGENT CASH-OUT] ${req.params.id} → ${customerMsisdn}: ${amount} CVE`);
  return res.status(201).json(tx);
});

module.exports = router;
