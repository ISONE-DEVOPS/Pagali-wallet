const express = require('express');
const merchantRoutes = require('./routes/merchants');

const app = express();
app.use(express.json());

app.get('/health', (_, res) => res.json({ status: 'ok', service: 'merchant-registry' }));
app.use('/merchants', merchantRoutes);

const PORT = process.env.PORT || 4002;
app.listen(PORT, () => console.log(`Merchant Registry listening on port ${PORT}`));
