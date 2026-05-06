function encode(tag, value) {
  const len = String(value.length).padStart(2, '0');
  return `${tag}${len}${value}`;
}

function decode(qrString) {
  const fields = {};
  let i = 0;
  while (i < qrString.length) {
    const tag = qrString.slice(i, i + 2);
    const len = parseInt(qrString.slice(i + 2, i + 4), 10);
    const value = qrString.slice(i + 4, i + 4 + len);
    fields[tag] = value;
    i += 4 + len;
  }
  return fields;
}

module.exports = { encode, decode };
