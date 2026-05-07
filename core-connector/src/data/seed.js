// Dados de demonstração — carregados no arranque do servidor
const transfers  = require('./transfers');
const batches    = require('./batches');
const agents     = require('./agents');
const tax        = require('./tax');
const cbdc       = require('./cbdc');
const pisp       = require('./pisp');
const requests   = require('./requests');
const { v4: uuidv4 } = require('uuid');

function seed() {
  console.log('[SEED] A carregar dados de demonstração...');

  // ── P2P ──────────────────────────────────────────────────────────────────
  const p2p1 = uuidv4();
  transfers.create({ transferId: p2p1, kind: 'P2P', payer: { idType:'MSISDN', idValue:'2389001', fspId:'BCVCVCV' }, payee: { idType:'MSISDN', idValue:'2389002', fspId:'BCNCV' }, amount: 1500, currency:'CVE', fee:'7.50' });
  transfers.commit(p2p1);

  const p2p2 = uuidv4();
  transfers.create({ transferId: p2p2, kind: 'P2P', payer: { idType:'MSISDN', idValue:'2389001', fspId:'BCVCVCV' }, payee: { idType:'MSISDN', idValue:'2389003', fspId:'BCNCV' }, amount: 3000, currency:'CVE', fee:'15.00' });
  transfers.commit(p2p2);

  // ── P2M ──────────────────────────────────────────────────────────────────
  const p2m1 = uuidv4();
  transfers.create({ transferId: p2m1, kind: 'P2M', payer: { idType:'MSISDN', idValue:'2389001', fspId:'BCVCVCV' }, payee: { idType:'BUSINESS', idValue:'MER001', fspId:'BCVCVCV' }, amount: 850, currency:'CVE', fee:'4.25' });
  transfers.commit(p2m1);

  const p2m2 = uuidv4();
  transfers.create({ transferId: p2m2, kind: 'P2M', payer: { idType:'MSISDN', idValue:'2389002', fspId:'BCNCV' }, payee: { idType:'BUSINESS', idValue:'MER002', fspId:'BCVCVCV' }, amount: 1200, currency:'CVE', fee:'6.00' });
  transfers.commit(p2m2);

  // ── FX ───────────────────────────────────────────────────────────────────
  const fx1 = uuidv4();
  transfers.create({ transferId: fx1, kind: 'FX', payer: { idType:'MSISDN', idValue:'EXTERNAL', fspId:'EXTERNAL' }, payee: { idType:'MSISDN', idValue:'2389001', fspId:'BCVCVCV' }, amount: 11027, currency:'CVE', fee:'165.40' });
  transfers.commit(fx1);

  // ── G2P ──────────────────────────────────────────────────────────────────
  const batch = batches.create({
    program: 'Subsídio Social — Maio 2026',
    disbursedBy: 'Governo de Cabo Verde',
    beneficiaries: [
      { name:'Ana Silva',     msisdn:'2389001', amount:'5000' },
      { name:'João Monteiro', msisdn:'2389002', amount:'5000' },
      { name:'Maria Tavares', msisdn:'2389003', amount:'5000' },
      { name:'Carlos Évora',  msisdn:'2389004', amount:'5000' },
    ],
  });
  // Processar imediatamente
  batch.beneficiaries.forEach(b => {
    const tid = uuidv4();
    transfers.create({ transferId: tid, kind: 'G2P', payer: { idType:'MSISDN', idValue:'GOV001', fspId:'BCVCVCV' }, payee: { idType:'MSISDN', idValue:b.msisdn, fspId:'BCVCVCV' }, amount: parseFloat(b.amount), currency:'CVE', fee:'0' });
    transfers.commit(tid);
    batches.updateBeneficiary(batch.batchId, b.msisdn, { state:'SUCCESS', transferId: tid, completedAt: new Date().toISOString() });
  });

  // ── Agent Banking ─────────────────────────────────────────────────────────
  agents.cashIn({ agentId:'AGT001', customerMsisdn:'2389001', amount: 5000, fee: 50 });
  agents.cashOut({ agentId:'AGT002', customerMsisdn:'2389003', amount: 2000, fee: 50 });

  // ── Tax ───────────────────────────────────────────────────────────────────
  tax.pay({ nif:'CV123456A', code:'IGT',  baseAmount: 50000, payerMsisdn:'2389001', period:'Mai 2026' });
  tax.pay({ nif:'CV789012B', code:'INPS', baseAmount: 80000, payerMsisdn:'2389002', period:'Mai 2026' });

  // ── CBDC ──────────────────────────────────────────────────────────────────
  cbdc.mint({ msisdn:'2389001', amount: 10000, authorizedBy:'BCV' });
  cbdc.convertToCBDC({ msisdn:'2389002', amount: 5000 });

  // ── R2P ───────────────────────────────────────────────────────────────────
  const r2p = requests.create({ merchantId:'MER002', merchantName:'Restaurante Sodade', merchantFsp:'BCVCVCV', payerMsisdn:'2389001', amount: 850, description:'Refeição almoço' });
  const r2pId = uuidv4();
  transfers.create({ transferId: r2pId, kind: 'R2P', payer: { idType:'MSISDN', idValue:'2389001', fspId:'BCVCVCV' }, payee: { idType:'BUSINESS', idValue:'MER002', fspId:'BCVCVCV' }, amount: 850, currency:'CVE', fee:'4.25' });
  transfers.commit(r2pId);
  requests.accept(r2p.requestId, r2pId);

  // ── PISP ──────────────────────────────────────────────────────────────────
  pisp.grantConsent({ msisdn:'2389001', appId:'LOJA_ONLINE_CV', maxAmount: 10000 });
  const pispReq = pisp.initiate({ appId:'LOJA_ONLINE_CV', payerMsisdn:'2389001', payeeMsisdn:'MERCHANT', payeeFsp:'BCVCVCV', amount: 2500, description:'Compra Online #42', reference:'ORD-042' });
  if (!pispReq.error) {
    const pispTx = uuidv4();
    transfers.create({ transferId: pispTx, kind:'PISP', payer:{ idType:'MSISDN', idValue:'2389001', fspId:'BCVCVCV' }, payee:{ idType:'MSISDN', idValue:'MERCHANT', fspId:'BCVCVCV' }, amount:2500, currency:'CVE', fee:'12.50' });
    transfers.commit(pispTx);
    pisp.approve(pispReq.initiationId, pispTx);
  }

  // Pedido R2P pendente (para demo ao vivo)
  requests.create({ merchantId:'MER001', merchantName:'Mercado Sucupira', merchantFsp:'BCVCVCV', payerMsisdn:'2389001', amount: 3500, description:'Compras semanais' });

  // Pedido PISP pendente (para demo ao vivo)
  pisp.grantConsent({ msisdn:'2389001', appId:'RENDA_CV', maxAmount: 15000 });
  pisp.initiate({ appId:'RENDA_CV', payerMsisdn:'2389001', payeeMsisdn:'LANDLORD', payeeFsp:'BCNCV', amount: 12000, description:'Renda de Maio 2026', reference:'RENDA-052026' });

  console.log('[SEED] ✓ Dados de demonstração carregados — dashboard pronto para o júri.');
}

module.exports = { seed };
