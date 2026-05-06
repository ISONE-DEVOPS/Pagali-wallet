const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const payerRoutes = require('./routes/payer');
const payeeRoutes = require('./routes/payee');
const g2pRoutes   = require('./routes/g2p');

const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan('[:date[iso]] :method :url :status :response-time ms'));

app.get('/health', (_, res) => res.json({ status: 'ok', service: 'core-connector' }));

app.use('/sendmoney', payerRoutes);
app.use('/g2p', g2pRoutes);
app.use('/', payeeRoutes);

const PORT = process.env.PORT || 8030;
app.listen(PORT, () => console.log(`Core Connector listening on port ${PORT}`));
