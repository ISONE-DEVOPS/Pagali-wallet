// In-memory account store for P2P payee lookup
const accounts = [
  { msisdn: '2389001', name: 'Ana Silva', fspId: 'BCVCVCV', active: true },
  { msisdn: '2389002', name: 'João Monteiro', fspId: 'BCVCVCV', active: true },
  { msisdn: '2389003', name: 'Maria Tavares', fspId: 'CAIXACV', active: true },
  { msisdn: '2389004', name: 'Carlos Évora', fspId: 'CAIXACV', active: true },
];

function findByMsisdn(msisdn) {
  return accounts.find((a) => a.msisdn === msisdn && a.active) || null;
}

module.exports = { findByMsisdn };
