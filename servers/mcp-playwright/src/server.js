import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { chromium, firefox, webkit } from "playwright";

function pickEngine(engine = "chromium") {
  switch ((engine || "chromium").toLowerCase()) {
    case "chromium": return chromium;
    case "firefox": return firefox;
    case "webkit": return webkit;
    default: return chromium;
  }
}

let browser; let currentEngine = "chromium";
async function getBrowser(engine = "chromium") {
  if (!browser || engine !== currentEngine) {
    if (browser) await browser.close().catch(() => {});
    currentEngine = engine;
    const launcher = pickEngine(engine);
    const channelEnv = process.env.PLAYWRIGHT_CHANNEL;
    const launchOpts = { headless: true };
    if (engine === "chromium") { launchOpts.channel = channelEnv || (process.platform === "win32" ? "msedge" : undefined); }
    browser = await launcher.launch(launchOpts);
  }
  return browser;
}

async function withPage(engine, fn) {
  const b = await getBrowser(engine);
  const context = await b.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();
  try { return await fn(page); } finally { await context.close().catch(() => {}); }
}

async function main() {
  const mcp = new McpServer({ name: "mcp-playwright", version: "0.2.0" });

  mcp.registerTool("navigate", { description: "Navigate and return final URL/title.", inputSchema: { url: z.string(), engine: z.enum(["chromium","firefox","webkit"]).optional().default("chromium"), waitUntil: z.enum(["load","domcontentloaded","networkidle"]).optional().default("load"), timeoutMs: z.number().int().optional().default(30000) } }, async ({ url, engine = "chromium", waitUntil = "load", timeoutMs = 30000 }) => {
    const result = await withPage(engine, async (page) => { const resp = await page.goto(url, { waitUntil, timeout: timeoutMs }); return { finalUrl: page.url(), title: await page.title(), status: resp?.status() ?? null, engine }; });
    return { content: [{ type: "text", text: JSON.stringify(result) }], structuredContent: result };
  });

  mcp.registerTool("screenshot", { description: "Take PNG screenshot; clip by selector if provided.", inputSchema: { url: z.string().optional(), selector: z.string().optional(), fullPage: z.boolean().optional().default(true), engine: z.enum(["chromium","firefox","webkit"]).optional().default("chromium"), waitUntil: z.enum(["load","domcontentloaded","networkidle"]).optional().default("domcontentloaded"), timeoutMs: z.number().int().optional().default(30000) } }, async ({ url, selector, fullPage = true, engine = "chromium", waitUntil = "domcontentloaded", timeoutMs = 30000 }) => {
    const result = await withPage(engine, async (page) => { if (url) await page.goto(url, { waitUntil, timeout: timeoutMs }); let clip; if (selector) { await page.waitForSelector(selector, { timeout: timeoutMs }); const el = await page.locator(selector).elementHandle(); const box = await el?.boundingBox(); if (!box) throw new Error(`No bounding box for selector: ${selector}`); clip = box; } const png = await page.screenshot({ type: "png", fullPage: clip ? false : fullPage, clip }); const dataUri = `data:image/png;base64,${png.toString("base64")}`; return { dataUri, engine }; });
    return { content: [{ type: "text", text: "PNG screenshot captured (data URI returned)." }], structuredContent: result };
  });

  mcp.registerTool("getContent", { description: "Get text content or full HTML.", inputSchema: { url: z.string(), selector: z.string().optional(), engine: z.enum(["chromium","firefox","webkit"]).optional().default("chromium"), waitUntil: z.enum(["load","domcontentloaded","networkidle"]).optional().default("domcontentloaded"), timeoutMs: z.number().int().optional().default(30000) } }, async ({ url, selector, engine = "chromium", waitUntil = "domcontentloaded", timeoutMs = 30000 }) => {
    const result = await withPage(engine, async (page) => { await page.goto(url, { waitUntil, timeout: timeoutMs }); if (selector) { await page.waitForSelector(selector, { timeout: timeoutMs }); const text = await page.locator(selector).innerText(); return { url: page.url(), text, engine }; } const html = await page.content(); const title = await page.title(); return { url: page.url(), title, html, engine }; });
    return { content: [{ type: "text", text: JSON.stringify(result) }], structuredContent: result };
  });

  const transport = new StdioServerTransport();
  await mcp.connect(transport);
  process.on("SIGINT", async () => { await browser?.close().catch(() => {}); process.exit(0); });
}

main().catch((err) => { console.error("Fatal error starting mcp-playwright:", err); process.exit(1); });
