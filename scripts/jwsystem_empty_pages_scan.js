#!/usr/bin/env node
/* eslint-disable no-console */

const fs = require('fs');
const puppeteer = require('puppeteer');

function readStdin() {
  return new Promise((resolve, reject) => {
    if (process.stdin.isTTY) return resolve('');
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', chunk => { data += chunk; });
    process.stdin.on('end', () => resolve(data));
    process.stdin.on('error', reject);
  });
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function clickByText(page, selector, text) {
  return page.evaluate(({ selector, text }) => {
    const els = Array.from(document.querySelectorAll(selector));
    const el = els.find(e => (e.innerText || '').trim() === text);
    if (!el) return false;
    el.click();
    return true;
  }, { selector, text });
}

async function login(page, baseUrl, creds) {
  await page.goto(`${baseUrl}/login`, { waitUntil: 'networkidle2' });
  await page.waitForSelector('input[placeholder="账号"]', { timeout: 30000 });

  await page.evaluate(() => {
    const inputs = Array.from(document.querySelectorAll('input'));
    for (const input of inputs) input.value = '';
  });

  await page.type('input[placeholder="账号"]', creds.username, { delay: 10 });
  await page.type('input[placeholder="密码"]', creds.password, { delay: 10 });
  await page.type('input[placeholder="验证码"]', creds.checkcode || '1', { delay: 10 });

  const roleClicked = await clickByText(page, '.el-radio', creds.roleLabel);
  if (!roleClicked) throw new Error(`无法选择身份：${creds.roleLabel}`);

  const btnClicked = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('button'));
    const btn = btns.find(b => (b.innerText || '').replace(/\s+/g, '') === '登录');
    if (!btn) return false;
    btn.click();
    return true;
  });
  if (!btnClicked) throw new Error('未找到登录按钮');

  await page.waitForFunction(() => location.pathname !== '/login', { timeout: 45000 });
  await page.waitForSelector('.app-wrapper', { timeout: 30000 });
  await sleep(300);
}

async function expandAllSidebars(page) {
  await page.evaluate(() => {
    const titles = Array.from(document.querySelectorAll('.sidebar-container .el-submenu__title'));
    for (const t of titles) t.click();
  });
  await sleep(300);
}

async function getSidebarItems(page) {
  return page.$$eval('.sidebar-container .el-menu-item', els => els.map(e => (e.innerText || '').trim()).filter(Boolean));
}

async function clickSidebarItemByIndex(page, index) {
  return page.evaluate((index) => {
    const items = Array.from(document.querySelectorAll('.sidebar-container .el-menu-item'));
    const el = items[index];
    if (!el) return false;
    el.scrollIntoView({ block: 'center' });
    el.click();
    return true;
  }, index);
}

function isTruthyText(s) {
  return typeof s === 'string' && s.trim().length > 0;
}

async function collectEmptySignals(page) {
  return page.evaluate(() => {
    const isVisible = (el) => {
      if (!el) return false;
      const style = window.getComputedStyle(el);
      if (!style) return false;
      if (style.visibility === 'hidden' || style.display === 'none') return false;
      const rect = el.getBoundingClientRect();
      return rect.width > 0 && rect.height > 0;
    };

    const emptyDescriptions = Array.from(document.querySelectorAll('.el-empty__description'))
      .filter(isVisible)
      .map(e => (e.innerText || '').trim())
      .filter(Boolean);

    const tableEmptyTexts = Array.from(document.querySelectorAll('.el-table__empty-text'))
      .filter(isVisible)
      .map(e => (e.innerText || '').trim())
      .filter(Boolean);

    const rawText = (document.body && document.body.innerText) ? document.body.innerText : '';
    const keywords = ['暂无数据', '暂无信息', '暂无记录', '没有数据', '没有信息', '暂无课程信息', '暂无描述', '暂无申请记录', '暂无成绩数据'];
    const keywordHits = keywords.filter(k => rawText.includes(k));

    const tableRows = Array.from(document.querySelectorAll('.el-table__body-wrapper tbody'))
      .reduce((sum, tbody) => sum + (tbody.querySelectorAll('tr').length), 0);

    return { emptyDescriptions, tableEmptyTexts, keywordHits, tableRows };
  });
}

async function run() {
  const input = await readStdin();
  if (!input) {
    console.error('Missing JSON input on stdin');
    process.exit(2);
  }
  const cfg = JSON.parse(input);
  const baseUrl = cfg.baseUrl || 'http://127.0.0.1:8081';
  const roles = cfg.roles || [];
  if (!Array.isArray(roles) || roles.length === 0) {
    console.error('No roles provided');
    process.exit(2);
  }

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const report = { baseUrl, roles: [] };

  try {
    for (const role of roles) {
      const context = (browser.createBrowserContext ? await browser.createBrowserContext() : await browser.createIncognitoBrowserContext());
      const page = await context.newPage();
      await page.setViewport({ width: 1400, height: 900 });

      const roleLabel = role.roleLabel;
      console.log(`\n=== EMPTY SCAN: ${roleLabel} ===`);

      await login(page, baseUrl, role);
      await page.waitForSelector('.sidebar-container', { timeout: 30000 });
      await expandAllSidebars(page);

      const menuTexts = await getSidebarItems(page);
      const pages = [];

      for (let i = 0; i < menuTexts.length; i++) {
        const prevPath = await page.evaluate(() => location.pathname);
        await clickSidebarItemByIndex(page, i);
        try {
          await page.waitForFunction(p => location.pathname !== p, { timeout: 5000 }, prevPath);
        } catch {
          // same route or redirect; still collect signals
        }
        await sleep(800);

        const url = await page.evaluate(() => location.href);
        const title = await page.evaluate(() => document.title);
        const path = await page.evaluate(() => location.pathname);
        const signals = await collectEmptySignals(page);

        const hasSignals = (signals.emptyDescriptions || []).some(isTruthyText)
          || (signals.tableEmptyTexts || []).some(isTruthyText)
          || (signals.keywordHits || []).length > 0;

        const entry = {
          menuText: menuTexts[i],
          path,
          url,
          title,
          signals,
          hasSignals
        };
        pages.push(entry);

        if (hasSignals) {
          const sample = []
            .concat(signals.emptyDescriptions || [])
            .concat(signals.tableEmptyTexts || [])
            .concat(signals.keywordHits || []);
          console.log(`- ${menuTexts[i]} -> ${path} (${sample.slice(0, 3).join(' | ')})`);
        }
      }

      report.roles.push({ roleLabel, pages });
      await context.close();
    }
  } finally {
    await browser.close();
  }

  const outPath = cfg.reportPath || '/tmp/jwsystem_empty_pages_report.json';
  fs.writeFileSync(outPath, JSON.stringify(report, null, 2), 'utf8');
  console.log(`\nReport: ${outPath}`);
  process.exit(0);
}

run().catch(err => {
  console.error(err && err.stack ? err.stack : String(err));
  process.exit(2);
});
