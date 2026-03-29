/**
 * merge_ac.js
 * Merges all state-level _AC.json files from data/ac/ into one
 * FeatureCollection: data/india_ac_all.json
 *
 * Run with:  node merge_ac.js
 */
const fs   = require('fs');
const path = require('path');

const acDir   = path.join(__dirname, 'data', 'ac');
const outFile = path.join(__dirname, 'data', 'india_ac_all.json');

const files = fs.readdirSync(acDir).filter(f => f.endsWith('_AC.json'));
console.log(`Found ${files.length} AC files`);

let allFeatures = [];
let skipped = 0;

for (const f of files) {
  const raw = fs.readFileSync(path.join(acDir, f), 'utf8');
  let gj;
  try {
    gj = JSON.parse(raw);
  } catch (e) {
    console.warn(`  SKIP (parse error): ${f}`);
    skipped++;
    continue;
  }
  if (!gj.features || gj.features.length === 0) {
    console.warn(`  SKIP (no features): ${f}`);
    skipped++;
    continue;
  }
  allFeatures = allFeatures.concat(gj.features);
  console.log(`  + ${f.replace('_AC.json','').padEnd(22)} → ${gj.features.length} features`);
}

const merged = { type: 'FeatureCollection', features: allFeatures };
fs.writeFileSync(outFile, JSON.stringify(merged));

console.log(`\nTotal features : ${allFeatures.length}`);
console.log(`Files skipped  : ${skipped}`);
console.log(`Output written : ${outFile}`);
console.log(`File size      : ${(fs.statSync(outFile).size / 1024 / 1024).toFixed(2)} MB`);
