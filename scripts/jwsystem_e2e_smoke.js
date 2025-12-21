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
  if (!roleClicked) {
    throw new Error(`无法选择身份：${creds.roleLabel}`);
  }

  const btnClicked = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('button'));
    const btn = btns.find(b => (b.innerText || '').replace(/\s+/g, '') === '登录');
    if (!btn) return false;
    btn.click();
    return true;
  });
  if (!btnClicked) throw new Error('未找到登录按钮');

  await page.waitForFunction(() => location.pathname !== '/login', { timeout: 30000 });
  await sleep(500);
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

function shouldIgnoreResponse(url, status) {
  if (status < 400) return true;
  if (status === 404 && url.includes('sockjs-node')) return true;
  if (status === 404 && (url.endsWith('.map') || url.includes('.map?'))) return true;
  return false;
}

function shouldIgnoreConsoleMessage(type, message) {
  if (type !== 'error' && type !== 'warning') return true;
  if (message.includes('Permissions policy violation: unload is not allowed in this document.')) return true;
  return false;
}

function shouldIgnoreFailedRequest(url, errorText) {
  if (errorText === 'net::ERR_BLOCKED_BY_ORB' && url.includes('/;jsessionid=')) return true;
  return false;
}

async function smokeSidebarRoutes(page, label) {
  await page.waitForSelector('.sidebar-container', { timeout: 30000 });
  await expandAllSidebars(page);

  const menuTexts = await getSidebarItems(page);
  const visited = [];
  for (let i = 0; i < menuTexts.length; i++) {
    const prevPath = await page.evaluate(() => location.pathname);
    await clickSidebarItemByIndex(page, i);
    try {
      await page.waitForFunction(p => location.pathname !== p, { timeout: 5000 }, prevPath);
    } catch {
      // same route or quick redirect; still continue
    }
    await sleep(600);
    const curPath = await page.evaluate(() => location.pathname);
    visited.push({ text: menuTexts[i], path: curPath });
  }
  console.log(`[${label}] visited sidebar items: ${visited.length}`);
  return visited;
}

async function adminClassesCrud(page, baseUrl) {
  await page.goto(`${baseUrl}/admin/classes`, { waitUntil: 'networkidle2' });
  await page.waitForSelector('.el-table', { timeout: 30000 });
  await sleep(500);

  const testName = `E2E班级_${Date.now().toString().slice(-6)}`;

  const addClicked = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('button'));
    const btn = btns.find(b => (b.innerText || '').trim() === '新增');
    if (!btn) return false;
    btn.click();
    return true;
  });
  if (!addClicked) throw new Error('班级页未找到“新增”按钮');

  await page.waitForSelector('.el-dialog__wrapper', { timeout: 30000 });
  const nameFilled = await page.evaluate((value) => {
    const items = Array.from(document.querySelectorAll('.el-dialog__wrapper .el-form-item'));
    const item = items.find(i => (i.innerText || '').includes('班级名称'));
    if (!item) return false;
    const input = item.querySelector('input');
    if (!input) return false;
    input.focus();
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    return true;
  }, testName);
  if (!nameFilled) throw new Error('新增班级：未能填写班级名称');

  // Select first college and specialty if available.
  const selectFirstOption = async (labelText) => {
    const clicked = await page.evaluate((labelText) => {
      const items = Array.from(document.querySelectorAll('.el-dialog__wrapper .el-form-item'));
      const item = items.find(i => {
        const label = i.querySelector('.el-form-item__label');
        return label && (label.innerText || '').includes(labelText);
      });
      if (!item) return false;
      const select = item.querySelector('.el-select');
      if (!select) return false;
      select.click();
      return true;
    }, labelText);
    if (!clicked) return false;
    await page.waitForFunction(() => {
      const dropdowns = Array.from(document.querySelectorAll('.el-select-dropdown'));
      const visible = dropdowns.find(d => getComputedStyle(d).display !== 'none');
      if (!visible) return false;
      return Boolean(visible.querySelectorAll('.el-select-dropdown__item:not(.is-disabled)').length);
    }, { timeout: 10000 });

    for (let attempt = 0; attempt < 3; attempt++) {
      await page.evaluate((attempt) => {
        const dropdowns = Array.from(document.querySelectorAll('.el-select-dropdown'));
        const visible = dropdowns.find(d => getComputedStyle(d).display !== 'none');
        const opts = visible ? Array.from(visible.querySelectorAll('.el-select-dropdown__item:not(.is-disabled)')) : [];
        const opt = opts[attempt] || opts[0];
        if (opt) opt.click();
      }, attempt);
      await sleep(200);
      const selectedText = await page.evaluate((labelText) => {
        const items = Array.from(document.querySelectorAll('.el-dialog__wrapper .el-form-item'));
        const item = items.find(i => {
          const label = i.querySelector('.el-form-item__label');
          return label && (label.innerText || '').includes(labelText);
        });
        const input = item && item.querySelector('.el-select input');
        return input ? (input.value || '').trim() : '';
      }, labelText);
      if (selectedText) return true;
    }
    return false;
  };

  const collegeSelected = await selectFirstOption('所属学院');
  const specialtySelected = await selectFirstOption('所属专业');
  if (!collegeSelected || !specialtySelected) {
    throw new Error('新增班级：未能选择学院/专业（下拉无数据或未渲染）');
  }

  await page.evaluate(() => {
    const inputs = Array.from(document.querySelectorAll('.el-dialog__wrapper input'));
    for (const input of inputs) {
      if (input.placeholder && input.placeholder.includes('例如')) {
        input.value = '2023级';
        input.dispatchEvent(new Event('input', { bubbles: true }));
      }
    }
  });

  const submitClicked = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('.el-dialog__wrapper button'));
    const btn = btns.find(b => (b.innerText || '').trim() === '确认');
    if (!btn) return false;
    btn.click();
    return true;
  });
  if (!submitClicked) throw new Error('班级新增弹窗未找到“确认”按钮');

  try {
    await page.waitForFunction(() => {
      const w = document.querySelector('.el-dialog__wrapper');
      if (!w) return true;
      return getComputedStyle(w).display === 'none' || w.getAttribute('aria-hidden') === 'true';
    }, { timeout: 10000 });
  } catch {
    const errors = await page.$$eval('.el-form-item__error', els => els.map(e => (e.innerText || '').trim()).filter(Boolean));
    throw new Error(`新增班级提交失败（表单未关闭）。校验错误: ${errors.join('；') || 'unknown'}`);
  }
  await sleep(800);

  // Search and verify appears.
  await page.waitForSelector('input[placeholder*=\"班级名称\"]', { timeout: 10000 });
  await page.click('input[placeholder*=\"班级名称\"]', { clickCount: 3 });
  await page.keyboard.press('Backspace');
  await page.type('input[placeholder*=\"班级名称\"]', testName, { delay: 5 });
  await page.keyboard.press('Enter');
  await sleep(1200);

  const found = await page.evaluate((testName) => {
    const rows = Array.from(document.querySelectorAll('.el-table__body-wrapper tbody tr'));
    return rows.some(r => (r.innerText || '').includes(testName));
  }, testName);
  if (!found) throw new Error('新增班级未出现在列表中');

  // Delete via row delete button (popover confirm).
  const deleteClicked = await page.evaluate((testName) => {
    const rows = Array.from(document.querySelectorAll('.el-table__body-wrapper tbody tr'));
    const row = rows.find(r => (r.innerText || '').includes(testName));
    if (!row) return false;
    const delBtn = row.querySelector('button.el-button--danger');
    if (!delBtn) return false;
    delBtn.click();
    return true;
  }, testName);
  if (!deleteClicked) throw new Error('未能点击班级行删除按钮');

  await sleep(300);
  const confirmClicked = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('.el-popover button'));
    const btn = btns.find(b => (b.innerText || '').trim() === '确定');
    if (!btn) return false;
    btn.click();
    return true;
  });
  if (!confirmClicked) throw new Error('未能点击删除确认按钮');

  await sleep(1500);
  return { attempted: true, createdAndDeleted: true };
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

  const overall = { roles: [] };

  try {
    for (const role of roles) {
      const context = (browser.createBrowserContext ? await browser.createBrowserContext() : await browser.createIncognitoBrowserContext());
      const page = await context.newPage();
      await page.setViewport({ width: 1280, height: 720 });

      const errors = [];
      const badResponses = [];
      const failedRequests = [];

      page.on('pageerror', err => errors.push({ type: 'pageerror', message: String(err) }));
      page.on('console', msg => {
        const t = msg.type();
        const text = msg.text();
        if (!shouldIgnoreConsoleMessage(t, text)) errors.push({ type: t, message: text });
      });
      page.on('requestfailed', req => {
        const url = req.url();
        const errorText = req.failure() && req.failure().errorText;
        if (!shouldIgnoreFailedRequest(url, errorText)) failedRequests.push({ url, errorText });
      });
      page.on('response', res => {
        const status = res.status();
        const url = res.url();
        if (!shouldIgnoreResponse(url, status)) badResponses.push({ status, url });
      });

      const roleLabel = role.roleLabel;
      console.log(`\\n=== ROLE: ${roleLabel} ===`);

      await login(page, baseUrl, role);
      await page.waitForSelector('.app-wrapper', { timeout: 30000 });

      const visited = await smokeSidebarRoutes(page, roleLabel);

      let extra = null;
      if (roleLabel === '管理员') {
        extra = await adminClassesCrud(page, baseUrl);
      }

      overall.roles.push({
        roleLabel,
        visitedCount: visited.length,
        badResponsesCount: badResponses.length,
        failedRequestsCount: failedRequests.length,
        errorsCount: errors.length,
        sample: {
          badResponses: badResponses.slice(0, 10),
          failedRequests: failedRequests.slice(0, 10),
          errors: errors.slice(0, 10)
        },
        extra
      });

      await context.close();
    }
  } finally {
    await browser.close();
  }

  const outPath = cfg.reportPath || '/tmp/jwsystem_e2e_smoke_report.json';
  fs.writeFileSync(outPath, JSON.stringify(overall, null, 2), 'utf8');
  console.log(`\\nReport: ${outPath}`);

  const hasIssues = overall.roles.some(r => r.badResponsesCount > 0 || r.failedRequestsCount > 0 || r.errorsCount > 0);
  process.exit(hasIssues ? 1 : 0);
}

run().catch(err => {
  console.error(err && err.stack ? err.stack : String(err));
  process.exit(2);
});
