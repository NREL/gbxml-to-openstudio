import 'dotenv/config';
import {execa} from 'execa';
import fs from 'fs';
import {mkdir, readFile, writeFile} from 'fs/promises';
import os from 'os';
import PQueue from 'p-queue';
import path from 'path';

const threads = Number(process.env.THREADS || Math.max(1, os.cpus().length - 3));
const osVersion = process.env.OS_VERSION;

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
    return `/usr/local/openstudio-${osVersion}/bin/openstudio`;
  }

  throw 'Unsupported OS';
}

const cliPath = getOpenStudioCLI(osVersion);

const unsortedFiles = fs.readdirSync('../../gbxmls/RegressionTesting', 'utf8');
const files = [];
for (let file of unsortedFiles) {
  const size = fs.statSync(`../../gbxmls/RegressionTesting/${file}`).size;
  files.push({file, size});
}
files.sort((a, b) => a.size - b.size);

const queue = new PQueue({concurrency: threads});
const osw = await readFile('../../workflows/RegressionTesting.osw', 'utf8');

const workflows = [];
for (const {file} of files) {
  await mkdir(`../../workflows/regression-tests/${osVersion}/${file}/`, {recursive: true});
  const workflow = `../../workflows/regression-tests/${osVersion}/${file}/${file.replace(/\.xml/, '')}.osw`;
  workflows.push(workflow);
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
