const express = require('express');
const qrRoutes = require('./routes/qr');

const app = express();
app.use(express.json());

app.get('/health', (_, res) => res.json({ status: 'ok', service: 'qr-service' }));
app.use('/qr', qrRoutes);

const PORT = process.env.PORT || 8031;
app.listen(PORT, () => console.log(`QR Service listening on port ${PORT}`));
