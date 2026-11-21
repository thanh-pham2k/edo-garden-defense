import { createReadStream, createWriteStream } from "node:fs";
import { stat } from "node:fs/promises";
import { join } from "node:path";
import { pipeline } from "node:stream/promises";
import { constants, createBrotliCompress, createGzip } from "node:zlib";

const directory = process.argv[2];
if (!directory) {
  console.error("Usage: node tools/compress_web_export.mjs <export-directory>");
  process.exit(1);
}

const files = ["index.html", "index.js", "index.wasm", "index.pck"];
let brotliTotal = 0;
let gzipTotal = 0;
for (const filename of files) {
  const source = join(directory, filename);
  const brotli = source + ".br";
  const gzip = source + ".gz";
  await Promise.all([
    pipeline(
      createReadStream(source),
      createBrotliCompress({ params: { [constants.BROTLI_PARAM_QUALITY]: 10 } }),
      createWriteStream(brotli),
    ),
    pipeline(createReadStream(source), createGzip({ level: 9 }), createWriteStream(gzip)),
  ]);
  const brotliSize = (await stat(brotli)).size;
  const gzipSize = (await stat(gzip)).size;
  brotliTotal += brotliSize;
  gzipTotal += gzipSize;
  console.log(`${filename}: ${brotliSize.toLocaleString("en-US")} bytes Brotli, ${gzipSize.toLocaleString("en-US")} bytes gzip`);
}
console.log(`Total: ${brotliTotal.toLocaleString("en-US")} bytes Brotli, ${gzipTotal.toLocaleString("en-US")} bytes gzip`);
