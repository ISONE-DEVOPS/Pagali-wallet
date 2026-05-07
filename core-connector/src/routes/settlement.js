const express = require('express');
const { getWindows, closeCurrentWindow, computePositions, computeMatrix } = require('../data/settlement');
const { list } = require('../data/transfers');

const router = express.Router();

// GET /settlement/windows — janelas de liquidação
router.get('/windows', (_, res) => res.json(getWindows()));

// POST /settlement/close — fechar janela actual e liquidar
router.post('/close', (_, res) => {
  const closed = closeCurrentWindow();
  if (!closed) return res.status(400).json({ error: 'Sem janela aberta' });
  return res.json({ message: 'Janela encerrada', window: closed });
});

// GET /settlement/positions — posições líquidas por FSP
router.get('/positions', (_, res) => {
  const txs = list();
  return res.json(computePositions(txs));
});

// GET /settlement/matrix — fluxo entre FSPs
router.get('/matrix', (_, res) => {
  const txs = list();
  return res.json(computeMatrix(txs));
});

// GET /settlement/report — relatório completo (JSON)
router.get('/report', (_, res) => {
  const txs = list();
  const positions = computePositions(txs);
  const matrix = computeMatrix(txs);
  const windows = getWindows();
  const total = txs.reduce((s, t) => s + (Number(t.amount) || 0), 0);

  return res.json({
    generatedAt: new Date().toISOString(),
    scheme: 'Pagali IIPS — Cabo Verde',
    operator: 'Banco de Cabo Verde (BCV)',
    summary: {
      totalTransfers: txs.length,
      totalVolumeCVE: parseFloat(total.toFixed(2)),
      breakdown: {
        P2P: txs.filter(t => t.kind === 'P2P').length,
        P2M: txs.filter(t => t.kind === 'P2M').length,
        G2P: txs.filter(t => t.kind === 'G2P').length,
        FX:  txs.filter(t => t.kind === 'FX').length,
      },
    },
    fspPositions: positions,
    fspMatrix: matrix,
    settlementWindows: windows,
    transfers: txs,
  });
});

// GET /settlement/report.csv — exportar para CSV
router.get('/report.csv', (_, res) => {
  const txs = list();
  const header = 'transferId,kind,payerFsp,payeeFsp,amount,fee,state,completedAt';
  const rows = txs.map(t =>
    [t.transferId, t.kind, t.payer?.fspId, t.payee?.fspId,
     t.amount, t.fee, t.state, t.completedAt].join(',')
  );
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename="pagali-settlement.csv"');
  return res.send([header, ...rows].join('\n'));
});

module.exports = router;
