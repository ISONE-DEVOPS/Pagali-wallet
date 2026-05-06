const { encode } = require('./tlv');
const { crc16 } = require('./crc');

const SCHEME_GUID = 'com.pagali.p2m';
const DEFAULT_CURRENCY = '132'; // ISO 4217 numeric: CVE (Cabo Verde Escudo)
const DEFAULT_COUNTRY = 'CV';

function generate({ merchantId, dfspSwift, merchantName, merchantCity, mcc, currency, amount }) {
  const merchantAccountInfo =
    encode('00', SCHEME_GUID) +
    encode('01', dfspSwift) +
    encode('02', merchantId);

  const isStatic = !amount;

  let payload =
    encode('00', '01') +
    encode('01', isStatic ? '11' : '12') +
    encode('26', merchantAccountInfo) +
    encode('52', mcc || '0000') +
    encode('53', currency || DEFAULT_CURRENCY) +
    (amount ? encode('54', String(amount)) : '') +
    encode('58', DEFAULT_COUNTRY) +
    encode('59', merchantName.slice(0, 25)) +
    encode('60', merchantCity.slice(0, 15)) +
    encode('63', '0000'); // placeholder for CRC

  const checksum = crc16(payload);
  return payload.slice(0, -4) + checksum;
}

module.exports = { generate };
