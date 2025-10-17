import puppeteer from "puppeteer";
(async () => {
  try {
    const browser = await puppeteer.launch({ headless: true, args: ["--no-sandbox", "--disable-setuid-sandbox"] });
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
