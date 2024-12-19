import 'dotenv/config';
import { execa } from 'execa';
import fs from 'fs';
import { mkdir, rm, readFile, writeFile } from 'fs/promises';
import os from 'os';
import PQueue from 'p-queue';
import path from 'path';

const threads = Number(process.env.THREADS || Math.max(1, os.cpus().length - 3));
const osVersion = process.env.OS_VERSION;
const args = process.argv;

if (!osVersion) {
  throw 'OS_VERSION missing from .env file';
}

function getOpenStudioCLI(osVersion) {
  if (process.env.OS_CLI) {
    return process.env.OS_CLI;
  }

  if (process.platform === 'win32') {
    return `C:\\openstudio-${osVersion}\\bin\\openstudio.exe`;
  } else if (process.platform === 'darwin') {
    return `/Applications/OpenStudio-${osVersion}/bin/openstudio`;
  } else if (process.platform === 'linux') {
    return `/usr/local/bin/openstudio-${osVersion}`;
  }

  throw 'Unsupported OS';
}

function getOswType(args) {
  if (args[2] === 'annual') {
    console.log('running workflow: annual simulations')
    return 'annual';
  } else if (args[2] === 'sizing') {
    console.log('running workflow: sizing simulations')
    return 'sizing';
  }
  throw "missing argument for 'sim' or 'siz'";
}

// test only a subset of the xml files. Used for faster feedback on CI.
// default false
let subset = false;
let subsetTestFiles = null;
if (args[3] === 'subset') {
  console.log('Subset set to true. Only a subset of test files will be ran');
  subset = true;
  // List of tests that are < 1000 KB
  subsetTestFiles = [
    'A00.xml',
    'Bank.xml',
    'ExteriorWindowRatioCW.xml',
    'Villa.xml',
    'Villa Spaces.xml',
    'Clerestory.xml',
    'House.xml',
    'ExteriorWindowRatioWindow.xml',
    'Roofs.xml',
    'Residential.xml',
    'Glass Tower Shade.xml',
    'Emerson.xml',
    '11 Jay St.xml'
  ];
}

const cliPath = getOpenStudioCLI(osVersion);
if (fs.existsSync(cliPath)) {
  console.log(`Found OpenStudio CLI at ${cliPath}`);
} else {
  throw `Cannot locate CLI for version ${osVersion}, tried ${cliPath}`;
}

if (subset) {
  var unsortedFiles = subsetTestFiles;
} else {
  var unsortedFiles = fs.readdirSync('../fixtures/', 'utf8');
}

const files = [];
for (let file of unsortedFiles) {
  const size = fs.statSync(`../fixtures/${file}`).size;
  files.push({file, size});
}
files.sort((a, b) => a.size - b.size);

var oswType = getOswType(args)
var runDir = `output/${oswType}/${osVersion}`

const queue = new PQueue({concurrency: threads});
const osw = await readFile(`${oswType}.osw`, 'utf8');

// TODO remove existing dirs and only make all or subset
console.log(`removing directory: test/integration/output/${oswType}/${osVersion}`)
rm(`${runDir}/*`, {recursive: true, force: true});

const workflows = [];
for (const {file} of files) {
  await mkdir(`${runDir}/${file}/`, {recursive: true});
  const workflow = `${runDir}/${file}/${file.replace(/\.xml/, '')}.osw`;
  if (subset && subsetTestFiles.includes(file)) {
    workflows.push(workflow);
  } else if (!subset) {
    workflows.push(workflow);
  }
  await writeFile(workflow, osw.replace(/GBXML_INPUT\.xml/g, file));
}

workflows.forEach(workflow => {
  (async () => {
    const file = path.basename(workflow);
    let start;
    await queue.add(() => {
      start = Date.now();
      console.log(`Start: ${file}`);
      return execa(cliPath, ['run', '-w', workflow]).catch(() => {
        console.error(`Error running ${workflow} with CLI at ${cliPath}`);
      });
    });
    const stop = Date.now();
    console.log(`Done: ${file} (${Math.round((stop - start) / 1000)}s)`);
  })();
});
