const { v4: uuidv4 } = require('uuid');

const TAX_TYPES = [
  { code: 'IGT',  name: 'Imposto s/ Rendimento Singular', description: 'IRS — pessoas singulares', rate: 0.15, minAmount: 50 },
  { code: 'INPS', name: 'Previdência Social', description: 'Contribuição mensal INPS', rate: 0.085, minAmount: 100 },
  { code: 'IVA',  name: 'Imposto s/ Valor Acrescentado', description: 'IVA — bens e serviços', rate: 0.15, minAmount: 20 },
  { code: 'IUP',  name: 'Imposto s/ Património', description: 'IUP — imóveis e veículos', rate: 0.008, minAmount: 200 },
  { code: 'IUR',  name: 'Imposto s/ Rendimento Empresas', description: 'IRC — pessoas coletivas', rate: 0.25, minAmount: 500 },
];

const receipts = [];

function getTypes() { return TAX_TYPES; }

function calculate({ code, baseAmount }) {
  const type = TAX_TYPES.find(t => t.code === code);
  if (!type) return null;
  const base = parseFloat(baseAmount);
  const taxAmount = parseFloat((base * type.rate).toFixed(2));
  const penalty = 0;
  return { type, baseAmount: base, taxAmount, penalty, total: taxAmount + penalty };
}

function pay({ nif, code, baseAmount, payerMsisdn, period }) {
  const calc = calculate({ code, baseAmount });
  if (!calc) return null;
  const receipt = {
    receiptId: uuidv4(),
    nif, code, period,
    payerMsisdn,
    taxType: calc.type.name,
    baseAmount: calc.baseAmount,
    taxAmount: calc.taxAmount,
    total: calc.total,
    currency: 'CVE',
    state: 'PAID',
    paidAt: new Date().toISOString(),
  };
  receipts.push(receipt);
  console.log(`[IMPOSTO] ${code} pago por NIF ${nif} | ${calc.total} CVE`);
  return receipt;
}

function getReceipts(nif) {
  return receipts.filter(r => r.nif === nif).sort((a, b) => b.paidAt.localeCompare(a.paidAt));
}

function getAllReceipts() {
  return [...receipts].sort((a, b) => b.paidAt.localeCompare(a.paidAt));
}

module.exports = { getTypes, calculate, pay, getReceipts, getAllReceipts };
