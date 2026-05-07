// Agent Banking — agentes humanos para cash-in/cash-out
const { v4: uuidv4 } = require('uuid');

const agents = [
  { agentId: 'AGT001', name: 'Loja Nha Filomena', msisdn: '2385001', island: 'Santo Antão', location: 'Porto Novo', float: 50000, currency: 'CVE', active: true },
  { agentId: 'AGT002', name: 'Mercadinho do Zé', msisdn: '2385002', island: 'São Nicolau', location: 'Ribeira Brava', float: 30000, currency: 'CVE', active: true },
  { agentId: 'AGT003', name: 'Taberna da Bela', msisdn: '2385003', island: 'Fogo', location: 'São Filipe', float: 45000, currency: 'CVE', active: true },
];

const transactions = [];

function listAgents() { return agents.filter(a => a.active); }
function getAgent(id) { return agents.find(a => a.agentId === id) || null; }

function cashIn({ agentId, customerMsisdn, amount, fee = 0 }) {
  const agent = agents.find(a => a.agentId === agentId);
  if (!agent) return null;
  const parsedAmt = parseFloat(amount);
  const parsedFee = parseFloat(fee);
  agent.float -= parsedAmt; // agente entrega cash
  const tx = {
    txId: uuidv4(), type: 'CASH_IN', agentId,
    agentName: agent.name, customerMsisdn,
    amount: parsedAmt, fee: parsedFee,
    netAmount: parsedAmt - parsedFee,
    currency: 'CVE', state: 'COMMITTED',
    createdAt: new Date().toISOString(),
  };
  transactions.push(tx);
  return tx;
}

function cashOut({ agentId, customerMsisdn, amount, fee = 0 }) {
  const agent = agents.find(a => a.agentId === agentId);
  if (!agent) return null;
  const parsedAmt = parseFloat(amount);
  const parsedFee = parseFloat(fee);
  agent.float += parsedAmt; // agente recebe cash
  const tx = {
    txId: uuidv4(), type: 'CASH_OUT', agentId,
    agentName: agent.name, customerMsisdn,
    amount: parsedAmt, fee: parsedFee,
    netAmount: parsedAmt - parsedFee,
    currency: 'CVE', state: 'COMMITTED',
    createdAt: new Date().toISOString(),
  };
  transactions.push(tx);
  return tx;
}

function getTransactions(agentId) {
  return transactions.filter(t => t.agentId === agentId)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

module.exports = { listAgents, getAgent, cashIn, cashOut, getTransactions };
