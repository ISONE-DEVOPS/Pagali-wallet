// CBDC — Escudo Digital (1 CBDC = 1 CVE, emitido pelo BCV)
const { v4: uuidv4 } = require('uuid');

const wallets = new Map(); // msisdn → balance
const transactions = [];

let totalSupply = 0; // Escudos Digitais em circulação

function getWallet(msisdn) {
  return { msisdn, balance: wallets.get(msisdn) || 0, currency: 'CBDC', name: 'Escudo Digital' };
}

// BCV emite novos Escudos Digitais (mint)
function mint({ msisdn, amount, authorizedBy }) {
  const amt = parseFloat(amount);
  wallets.set(msisdn, (wallets.get(msisdn) || 0) + amt);
  totalSupply += amt;
  const tx = { txId: uuidv4(), type: 'MINT', to: msisdn, amount: amt, authorizedBy: authorizedBy || 'BCV', createdAt: new Date().toISOString() };
  transactions.push(tx);
  console.log(`[CBDC MINT] BCV emitiu ${amt} Escudos Digitais para ${msisdn}`);
  return { ...tx, newBalance: wallets.get(msisdn), totalSupply };
}

// Converter CVE → CBDC (1:1)
function convertToCBDC({ msisdn, amount }) {
  const amt = parseFloat(amount);
  wallets.set(msisdn, (wallets.get(msisdn) || 0) + amt);
  totalSupply += amt;
  const tx = { txId: uuidv4(), type: 'CVE_TO_CBDC', msisdn, amount: amt, rate: 1, createdAt: new Date().toISOString() };
  transactions.push(tx);
  return { ...tx, cbdcBalance: wallets.get(msisdn) };
}

// Converter CBDC → CVE (1:1)
function convertToCVE({ msisdn, amount }) {
  const amt = parseFloat(amount);
  const bal = wallets.get(msisdn) || 0;
  if (bal < amt) return null;
  wallets.set(msisdn, bal - amt);
  totalSupply -= amt;
  const tx = { txId: uuidv4(), type: 'CBDC_TO_CVE', msisdn, amount: amt, rate: 1, createdAt: new Date().toISOString() };
  transactions.push(tx);
  return { ...tx, cbdcBalance: wallets.get(msisdn) };
}

// Transferir CBDC entre carteiras
function transfer({ fromMsisdn, toMsisdn, amount }) {
  const amt = parseFloat(amount);
  const fromBal = wallets.get(fromMsisdn) || 0;
  if (fromBal < amt) return null;
  wallets.set(fromMsisdn, fromBal - amt);
  wallets.set(toMsisdn, (wallets.get(toMsisdn) || 0) + amt);
  const tx = { txId: uuidv4(), type: 'TRANSFER', from: fromMsisdn, to: toMsisdn, amount: amt, createdAt: new Date().toISOString() };
  transactions.push(tx);
  console.log(`[CBDC TRANSFER] ${fromMsisdn} → ${toMsisdn}: ${amt} CBDC`);
  return { ...tx, fromBalance: wallets.get(fromMsisdn), toBalance: wallets.get(toMsisdn) };
}

function getSupply() {
  return { totalSupply, wallets: wallets.size, currency: 'Escudo Digital (CBDC)', issuer: 'Banco de Cabo Verde' };
}

function getTransactions() {
  return [...transactions].sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

module.exports = { getWallet, mint, convertToCBDC, convertToCVE, transfer, getSupply, getTransactions };
