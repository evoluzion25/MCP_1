import { chromium } from "playwright";
(async () => {
  try {
    const browser = await chromium.launch({ headless: true, channel: process.env.PLAYWRIGHT_CHANNEL || (process.platform === 'win32' ? 'msedge' : undefined) });
    const page = await browser.newPage();
    await page.goto("https://example.com", { waitUntil: "load", timeout: 15000 });
    const title = await page.title();
    await browser.close();
    console.log(JSON.stringify({ ok: true, title }));
    process.exit(0);
  } catch (e) {
    console.error(JSON.stringify({ ok: false, error: e.message }));
    process.exit(1);
  }
})();
