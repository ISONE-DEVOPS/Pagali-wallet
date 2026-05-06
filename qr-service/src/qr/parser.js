const { decode } = require('./tlv');
const { crc16 } = require('./crc');

function parse(qrString) {
  const crcTag = qrString.slice(-4);
  const payload = qrString.slice(0, -4); // inclui "6304" no fim — input correcto para CRC
  const expectedCrc = crc16(payload);

  if (crcTag !== expectedCrc) {
    throw new Error(`CRC mismatch: got ${crcTag}, expected ${expectedCrc}`);
  }

  const root = decode(qrString);
  const merchantAccountInfo = root['26'] ? decode(root['26']) : {};

  return {
    valid: true,
    type: root['01'] === '11' ? 'STATIC' : 'DYNAMIC',
    schemeId: merchantAccountInfo['00'],
    dfspSwift: merchantAccountInfo['01'],
    merchantId: merchantAccountInfo['02'],
    subId: merchantAccountInfo['03'],
    mcc: root['52'],
    currency: root['53'],
    amount: root['54'] || null,
    countryCode: root['58'],
    merchantName: root['59'],
    merchantCity: root['60'],
    crc: crcTag,
  };
}

module.exports = { parse };
