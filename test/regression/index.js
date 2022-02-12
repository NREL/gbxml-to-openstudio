import 'dotenv/config'
import fs from 'fs';
import path from 'path';
import { execa } from 'execa';
import PQueue from 'p-queue';
import { mkdir, readFile, writeFile } from 'fs/promises';
import os from 'os';

const threads = os.cpus().length - 1;
const osVersion = process.env.OS_VERSION;

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
      return execa(`C:\\openstudio-${osVersion}\\bin\\openstudio.exe`, ['run', '-w', workflow]).catch(() => {
      });
    });
    const stop = Date.now();
    console.log(`Done: ${file} (${Math.round((stop - start) / 1000)}s)`);
  })();
});
