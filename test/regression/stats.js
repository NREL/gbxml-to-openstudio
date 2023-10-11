import 'dotenv/config';
import { XMLParser } from 'fast-xml-parser';
import fs from 'fs';
import { readFile, writeFile } from 'fs/promises';
import { DateTime } from 'luxon';
import Papa from 'papaparse';
import path from 'path';

const parser = new XMLParser();
const osVersion = process.env.OS_VERSION;
const dir = `../../workflows/regression-tests/${osVersion}`;

const results = [];
const gbxmls = fs.readdirSync(dir, 'utf8').sort((new Intl.Collator(undefined, {
  numeric: true,
  sensitivity: 'base'
})).compare);

for (const gbxml of gbxmls) {
  const result = {Name: gbxml};
  const oswPath = path.join(dir, gbxml, 'out.osw');
  if (fs.existsSync(oswPath)) {
    console.log(`${gbxml}`);
  } else {
    console.error(`${gbxml} out.osw does not exist`);
    results.push(result);
    continue;
  }

  const file = await readFile(oswPath, 'utf-8');
  const data = JSON.parse(file);

  // continue if completed_status = Fail
  if (data.completed_status == "Fail") {
    continue;
  }

  data.steps.forEach(step => {
    if (['OpenStudio Results', 'Systems Analysis Report'].includes(step.name)) {
      result[step.name] = step.result.step_result
      return;
    }
    const start = DateTime.fromISO(step.result.started_at).valueOf() / 1000;
    const end = DateTime.fromISO(step.result.completed_at).valueOf() / 1000;
    result[step.name] = end - start;
  });

  const stdout = await readFile(path.join(dir, gbxml, 'run', 'stdout-energyplus'), 'utf-8');
  const match = /EnergyPlus Run Time=(\d+(?:\.\d+)?)hr +(\d+(?:\.\d+)?)min +(\d+(?:\.\d+)?)sec/g.exec(stdout);
  if (match) {
    const hours = Number(match[1]);
    const minutes = Number(match[2]);
    const seconds = Number(match[3]);

    result.EnergyPlus = Math.round(hours * 60 * 60 + minutes * 60 + seconds);
  } else {
    result.EnergyPlus = -1;
  }

  const start = DateTime.fromISO(data.started_at).valueOf() / 1000;
  const end = DateTime.fromISO(data.completed_at).valueOf() / 1000;
  result['Total Time'] = end - start;

  result.Status = data.completed_status;

  const eplustblPath = path.join(dir, gbxml, 'run', 'eplustbl.xml');
  if (fs.existsSync(eplustblPath)) {
    const xml = parser.parse(await readFile(eplustblPath, 'utf-8'));
    const energyUsage = xml.EnergyPlusTabularReports.AnnualBuildingUtilityPerformanceSummary.SiteAndSourceEnergy;
    energyUsage.forEach(({name, TotalEnergy}) => {
      if (['TotalSiteEnergy', 'TotalSourceEnergy'].includes(name)) {
        result[name] = TotalEnergy;
      }
    });
  }

  results.push(result);
}

const csv = Papa.unparse(results, {
  columns: [
    'Name',
    'Change Building Location',
    'ImportGbxml',
    'Advanced Import Gbxml',
    'GBXML HVAC Import',
    'Set Simulation Control',
    'gbxml_to_openstudio_cleanup',
    'Add XML Output Control Style',
    'EnergyPlus',
    'Total Time',
    'Status',
    'TotalSiteEnergy',
    'TotalSourceEnergy',
    'OpenStudio Results',
    'Systems Analysis Report'
  ]
});
// console.log(csv);
await writeFile(`stats-${osVersion}-sub-gpu.csv`, csv);
