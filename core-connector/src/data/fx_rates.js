// Taxas de câmbio para CVE (Escudo Cabo-verdiano)
// EUR está fixado por acordo monetário com Portugal: 1 EUR = 110.265 CVE
const BASE_RATES = {
  EUR: 110.265, // fixo — acordo monetário
  USD: 102.10,
  GBP: 129.80,
  BRL: 18.45,   // diáspora no Brasil
};

const FX_FEE_RATE = 0.015; // 1.5% de taxa de câmbio

function getRate(from, to = 'CVE') {
  if (to !== 'CVE') throw new Error(`Apenas conversão para CVE suportada`);
  const rate = BASE_RATES[from];
  if (!rate) throw new Error(`Moeda ${from} não suportada`);
  // Simula ligeira variação de mercado (±0.1%)
  const fluctuation = 1 + (Math.random() - 0.5) * 0.002;
  return parseFloat((rate * fluctuation).toFixed(4));
}

function getAllRates() {
  return Object.entries(BASE_RATES).map(([currency, baseRate]) => ({
    currency,
    rate: parseFloat((baseRate * (1 + (Math.random() - 0.5) * 0.002)).toFixed(4)),
    baseCurrency: 'CVE',
    updatedAt: new Date().toISOString(),
  }));
}

module.exports = { getRate, getAllRates, FX_FEE_RATE };
