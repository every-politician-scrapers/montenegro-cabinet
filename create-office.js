// wd create-entity create-office.js "Minister for X"
const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (label) => {
  return {
    type: 'item',
    labels: {
      en: label,
    },
    descriptions: {
      en: `cabinet position in ${meta.jurisdiction.name}`,
    },
    claims: {
      P31:   { value: 'Q294414' }, // instance of: public office
      P279:  { value: 'Q83307'  }, // subclas of: minister
      P17:   { value: meta.jurisdiction.id }, // country
      P1001: { value: meta.jurisdiction.id }, // jurisdiction
      P361: { // part of
        value: meta.cabinet.parent,
        references: { P854: meta.source.url },
      }
    }
  }
}
