const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const payerRoutes = require('./routes/payer');
const payeeRoutes = require('./routes/payee');
const g2pRoutes   = require('./routes/g2p');
const fxRoutes         = require('./routes/fx');
const settlementRoutes = require('./routes/settlement');
const r2pRoutes        = require('./routes/r2p');
const agentRoutes      = require('./routes/agents');
const taxRoutes        = require('./routes/tax');
const cbdcRoutes       = require('./routes/cbdc');
const pispRoutes       = require('./routes/pisp');

const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan('[:date[iso]] :method :url :status :response-time ms'));
app.use(express.static(path.join(__dirname, '../public')));

app.get('/health', (_, res) => res.json({ status: 'ok', service: 'core-connector' }));

app.use('/sendmoney', payerRoutes);
app.use('/g2p', g2pRoutes);
app.use('/fx',         fxRoutes);
app.use('/settlement', settlementRoutes);
app.use('/requests',   r2pRoutes);
app.use('/agents',     agentRoutes);
app.use('/tax',        taxRoutes);
app.use('/cbdc',       cbdcRoutes);
app.use('/pisp',       pispRoutes);
app.use('/', payeeRoutes);

const PORT = process.env.PORT || 8030;
app.listen(PORT, () => console.log(`Core Connector listening on port ${PORT}`));
