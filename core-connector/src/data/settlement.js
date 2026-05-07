// Settlement engine — Net Debit Cap (NDC) e janelas de liquidação
const { v4: uuidv4 } = require('uuid');

const NDC_LIMITS = {
  BCVCVCV: 500000, // CVE — Banco Comercial do Atlântico
  CAIXACV: 300000, // CVE — Caixa Económica de Cabo Verde
  EXTERNAL: 999999,
};

const windows = [
  {
    windowId: uuidv4(),
    state: 'CLOSED',
    openedAt: new Date(Date.now() - 3600000 * 8).toISOString(),
    closedAt: new Date(Date.now() - 3600000 * 4).toISOString(),
    settlementAt: new Date(Date.now() - 3600000 * 3).toISOString(),
  },
];

// Janela actual — aberta no arranque
let currentWindow = {
  windowId: uuidv4(),
  state: 'OPEN',
  openedAt: new Date().toISOString(),
  closedAt: null,
  settlementAt: null,
};
windows.push(currentWindow);

function getWindows() { return [...windows].reverse(); }

function closeCurrentWindow() {
  if (currentWindow.state !== 'OPEN') return null;
  currentWindow.state = 'PENDING_SETTLEMENT';
  currentWindow.closedAt = new Date().toISOString();
  const closed = currentWindow;
  // Abre nova janela
  currentWindow = {
    windowId: uuidv4(),
    state: 'OPEN',
    openedAt: new Date().toISOString(),
    closedAt: null, settlementAt: null,
  };
  windows.push(currentWindow);
  setTimeout(() => {
    closed.state = 'SETTLED';
    closed.settlementAt = new Date().toISOString();
  }, 3000);
  return closed;
}

function computePositions(transfers) {
  const net = {}; // fspId → net position (positive = creditor, negative = debtor)
  transfers.forEach(t => {
    const pFsp = t.payer?.fspId || 'UNKNOWN';
    const rFsp = t.payee?.fspId  || 'UNKNOWN';
    const amt  = Number(t.amount) || 0;
    if (t.state !== 'COMMITTED') return;
    net[pFsp] = (net[pFsp] || 0) - amt; // payer debita
    net[rFsp] = (net[rFsp] || 0) + amt; // payee credita
  });

  return Object.entries(net).map(([fspId, position]) => ({
    fspId,
    position: parseFloat(position.toFixed(2)),
    ndcLimit: NDC_LIMITS[fspId] || 100000,
    ndcUsed: position < 0 ? parseFloat(Math.abs(position).toFixed(2)) : 0,
    ndcPct: position < 0
      ? Math.min(100, parseFloat((Math.abs(position) / (NDC_LIMITS[fspId] || 100000) * 100).toFixed(1)))
      : 0,
    status: position < 0 && Math.abs(position) > (NDC_LIMITS[fspId] || 100000)
      ? 'BREACH' : 'OK',
  }));
}

function computeMatrix(transfers) {
  const matrix = {};
  transfers.filter(t => t.state === 'COMMITTED').forEach(t => {
    const key = `${t.payer?.fspId || 'UNK'}→${t.payee?.fspId || 'UNK'}`;
    matrix[key] = (matrix[key] || 0) + (Number(t.amount) || 0);
  });
  return Object.entries(matrix).map(([pair, vol]) => ({
    pair, from: pair.split('→')[0], to: pair.split('→')[1],
    volume: parseFloat(vol.toFixed(2)), count: transfers.filter(t =>
      `${t.payer?.fspId}→${t.payee?.fspId}` === pair && t.state === 'COMMITTED').length,
  }));
}

module.exports = { getWindows, closeCurrentWindow, computePositions, computeMatrix, NDC_LIMITS };
