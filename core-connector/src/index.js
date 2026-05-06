const express = require('express');
const payerRoutes = require('./routes/payer');
const payeeRoutes = require('./routes/payee');

const app = express();
app.use(express.json());

app.get('/health', (_, res) => res.json({ status: 'ok', service: 'core-connector' }));

app.use('/sendmoney', payerRoutes);
app.use('/', payeeRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Core Connector listening on port ${PORT}`));
