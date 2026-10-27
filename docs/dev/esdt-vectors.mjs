// Esdt 向量生成器。
//
// 说明（证据等级见 docs/api/evidence-register.md §8.8）：
// - 本脚本是按 docs/api/登录接口文档.md §3 的算法描述独立重写的 JavaScript 实现，
//   与 Dart 端 lib/core/protocol/esdt_codec.dart 无共享代码；
// - 生成结果属于「独立工具生成」的向量资产，可用于回归测试，
//   但不代表协议已在真实平台验证（协议正确性仍需样本取证）。
//
// 用法：node docs/dev/esdt-vectors.mjs

import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..', '..');

/** ECMAScript 遗留 escape()，F 按码元逐个处理。 */
function legacyEscape(text) {
  const keep = new Set('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@*_+-./');
  let out = '';
  for (const ch of text) {
    const unit = ch.charCodeAt(0);
    if (keep.has(ch)) {
      out += ch;
    } else if (unit < 0x100) {
      out += '%' + unit.toString(16).toUpperCase().padStart(2, '0');
    } else {
      out += '%u' + unit.toString(16).toUpperCase().padStart(4, '0');
    }
  }
  return out;
}

/** 按 §3 步骤实现 Esdt：码元十进制拼串 + ^ + 长度列表，再 escape。 */
function esdt(input) {
  if (input === '') return '';
  const digits = [];
  const lengths = [];
  for (let i = 0; i < input.length; i += 1) {
    const dec = input.charCodeAt(i).toString(10);
    digits.push(dec);
    lengths.push(dec.length);
  }
  return legacyEscape(digits.join('') + '^' + lengths.join(','));
}

const inputs = [
  '', // 空串
  '123', // 文档 §3 示例
  'A1', // 文档 §3 示例
  '610525199001011234', // 身份证号
  'A1b2C3', // 混合字母数字
  'Passw0rd!@#', // 含特殊字符
  '中文', // 非 ASCII（>0x100，走 %uXXXX）
  'a^b,c', // 输入本身含 ^ , 需二次转义
  '  ', // 空格
  '~', // 0x7E 需转义
];

const vectors = inputs.map((input) => ({ input, expected: esdt(input) }));

const outDir = join(root, 'test', 'vectors', 'esdt');
mkdirSync(outDir, { recursive: true });
writeFileSync(join(outDir, 'vectors.json'), JSON.stringify({ vectors }, null, 2) + '\n', 'utf8');
writeFileSync(
  join(outDir, 'meta.json'),
  JSON.stringify(
    {
      protocol: 'esdt',
      source: 'docs/api/登录接口文档.md §3（算法描述）',
      generatedBy: 'docs/dev/esdt-vectors.mjs（独立 JavaScript 实现）',
      generatedAt: new Date().toISOString(),
      collectedBy: 'agent',
      platformVersion: '未采集',
      note: '文档示例 123 / A1 与生成结果一致；其余为算法推导，未经真实平台请求验证。',
    },
    null,
    2,
  ) + '\n',
  'utf8',
);

console.log(`wrote ${vectors.length} vectors to test/vectors/esdt/`);
