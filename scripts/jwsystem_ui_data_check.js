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

async function setInputValue(page, selector, value) {
  return page.evaluate(({ selector, value }) => {
    const el = document.querySelector(selector);
    if (!el) return false;
    el.focus();
    el.value = value;
    el.dispatchEvent(new Event('input', { bubbles: true }));
    return true;
  }, { selector, value });
}

async function login(page, baseUrl, creds) {
  await page.goto(`${baseUrl}/login`, { waitUntil: 'networkidle2' });
  await page.waitForSelector('input[placeholder="账号"]', { timeout: 30000 });

  const okUser = await setInputValue(page, 'input[placeholder="账号"]', creds.username);
  const okPass = await setInputValue(page, 'input[placeholder="密码"]', creds.password);
  const okCode = await setInputValue(page, 'input[placeholder="验证码"]', creds.checkcode || '1');
  if (!okUser || !okPass || !okCode) throw new Error('登录页输入框未找到');

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

  await page.waitForFunction(() => location.pathname !== '/login', { timeout: 30000 });
  await page.waitForSelector('.app-wrapper', { timeout: 30000 });
  await sleep(300);
}

async function gotoAndWait(page, url) {
  await page.goto(url, { waitUntil: 'networkidle2' });
  await page.waitForSelector('.app-wrapper', { timeout: 30000 });
  await sleep(300);
}

async function getDashboardMetrics(page) {
  return page.evaluate(() => {
    const canvasCount = document.querySelectorAll('canvas').length;
    const noticeRowsCount = document.querySelectorAll('.el-table__body-wrapper tbody tr').length;

    const findCardValue = (labelText) => {
      const cards = Array.from(document.querySelectorAll('.el-card'));
      const card = cards.find(c => (c.innerText || '').includes(labelText));
      if (!card) return null;
      const v = card.querySelector('.middle-card-content span');
      return v ? (v.textContent || '').trim() : null;
    };

    const findMetricValue = (labelText) => {
      const metrics = Array.from(document.querySelectorAll('.metric'));
      for (const m of metrics) {
        const labelEl = m.querySelector('.metric-label');
        const label = labelEl ? (labelEl.textContent || '').trim() : '';
        if (label !== labelText) continue;
        const v = m.querySelector('.metric-value');
        const value = v ? (v.textContent || '').trim() : '';
        if (value) return value;
      }
      return null;
    };

    const findValue = (labelText) => findCardValue(labelText) || findMetricValue(labelText);

    const courseNumText = findCardValue('课程数');
    const totalTimeText = findValue('总学时');
    const upCourseRateText = findValue('到课率');
    const eligiableRateText = findValue('合格率');

    return {
      canvasCount,
      noticeRowsCount,
      studentCards: {
        courseNumText: courseNumText || findValue('课程数'),
        totalTimeText,
        upCourseRateText,
        eligiableRateText
      }
    };
  });
}

async function getTeacherTeamOptionsCount(page) {
  const clicked = await page.evaluate(() => {
    const select = document.querySelector('.dashboard-container .el-select');
    if (!select) return false;
    select.click();
    return true;
  });
  if (!clicked) return 0;

  try {
    await page.waitForSelector('.el-select-dropdown__item', { timeout: 5000 });
  } catch {
    return 0;
  }

  const count = await page.$$eval('.el-select-dropdown__item:not(.is-disabled)', els => els.length);
  await page.keyboard.press('Escape');
  await sleep(150);
  return count;
}

async function countElements(page, selector) {
  return page.evaluate((selector) => document.querySelectorAll(selector).length, selector);
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
      await page.setViewport({ width: 1280, height: 720 });

      const roleLabel = role.roleLabel;
      console.log(`\\n=== UI CHECK: ${roleLabel} ===`);

      await login(page, baseUrl, role);
      await gotoAndWait(page, `${baseUrl}/dashboard`);

      const dashboard = await getDashboardMetrics(page);

      let teacherTeams = null;
      let studentScheduleCells = null;
      let studentScoreRows = null;
      let teacherScheduleCells = null;
      let teacherCourseRows = null;

      if (roleLabel === '教师') {
        teacherTeams = await getTeacherTeamOptionsCount(page);
        await gotoAndWait(page, `${baseUrl}/teacher/schedule`);
        teacherScheduleCells = await countElements(page, '.course-cell');
        await gotoAndWait(page, `${baseUrl}/teacher/course`);
        teacherCourseRows = await countElements(page, '.el-table__body-wrapper tbody tr');
      }

      if (roleLabel === '学生') {
        await gotoAndWait(page, `${baseUrl}/student/schedule`);
        studentScheduleCells = await countElements(page, '.course-cell');
        await gotoAndWait(page, `${baseUrl}/student/score`);
        studentScoreRows = await countElements(page, '.el-table__body-wrapper tbody tr');
      }

      const entry = {
        roleLabel,
        dashboard,
        teacherTeams,
        studentScheduleCells,
        studentScoreRows,
        teacherScheduleCells,
        teacherCourseRows
      };
      report.roles.push(entry);

      await context.close();
    }
  } finally {
    await browser.close();
  }

  const outPath = cfg.reportPath || '/tmp/jwsystem_ui_data_check_report.json';
  fs.writeFileSync(outPath, JSON.stringify(report, null, 2), 'utf8');
  console.log(`\\nReport: ${outPath}`);

  const problems = [];
  for (const r of report.roles) {
    if (r.roleLabel === '教务人员') {
      if ((r.dashboard.noticeRowsCount || 0) <= 0) problems.push(`${r.roleLabel}: noticeRowsCount=0`);
    }
    if (r.roleLabel === '教师') {
      if ((r.teacherTeams || 0) <= 0) problems.push(`${r.roleLabel}: teacherTeams=0`);
      if ((r.teacherScheduleCells || 0) <= 0) problems.push(`${r.roleLabel}: teacherScheduleCells=0`);
      if ((r.teacherCourseRows || 0) <= 0) problems.push(`${r.roleLabel}: teacherCourseRows=0`);
    }
    if (r.roleLabel === '学生') {
      const courseNum = Number((r.dashboard.studentCards.courseNumText || '').replace(/[^\d.]/g, ''));
      if (!courseNum || courseNum <= 0) problems.push(`${r.roleLabel}: courseNum=0`);
      if ((r.studentScheduleCells || 0) <= 0) problems.push(`${r.roleLabel}: studentScheduleCells=0`);
      if ((r.studentScoreRows || 0) <= 0) problems.push(`${r.roleLabel}: studentScoreRows=0`);
    }
  }

  if (problems.length > 0) {
    console.error(`\\nUI data checks failed:\\n- ${problems.join('\\n- ')}`);
    process.exit(1);
  }
  process.exit(0);
}

run().catch(err => {
  console.error(err && err.stack ? err.stack : String(err));
  process.exit(2);
});
