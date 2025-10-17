import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import puppeteer from "puppeteer";
import fs from "fs";
import path from "path";

function resolveEdgePathWindows() {
  const candidates = [
    process.env.GP_MS_EDGE_PATH,
    path.join(process.env["ProgramFiles"] || "C:/Program Files", "Microsoft", "Edge", "Application", "msedge.exe"),
    path.join(process.env["ProgramFiles(x86)"] || "C:/Program Files (x86)", "Microsoft", "Edge", "Application", "msedge.exe"),
  ].filter(Boolean);
  for (const p of candidates) {
    try { if (p && fs.existsSync(p)) return p; } catch {}
  }
  return null;
}

function getLaunchOptions() {
  const opts = { headless: true, args: ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"] };
  const envPath = process.env.PUPPETEER_EXECUTABLE_PATH;
  if (envPath && fs.existsSync(envPath)) { opts.executablePath = envPath; return opts; }
  if (process.platform === "win32") {
    const edge = resolveEdgePathWindows();
    if (edge) { opts.executablePath = edge; return opts; }
  }
  return opts; // bundled Chromium
}

let browser;
async function getBrowser() { if (!browser) { browser = await puppeteer.launch(getLaunchOptions()); } return browser; }
async function withPage(fn) {
  const b = await getBrowser();
  const page = await b.newPage();
  try { await page.setViewport({ width: 1280, height: 800 }); return await fn(page); } finally { await page.close().catch(() => {}); }
}

async function main() {
  const mcp = new McpServer({ name: "mcp-puppeteer", version: "0.2.0" });

  mcp.registerTool("navigate", { description: "Navigate and return final URL/title.", inputSchema: { url: z.string(), waitUntil: z.enum(["load","domcontentloaded","networkidle0","networkidle2"]).optional().default("load"), timeoutMs: z.number().int().optional().default(30000) } }, async ({ url, waitUntil = "load", timeoutMs = 30000 }) => {
    const result = await withPage(async (page) => { const resp = await page.goto(url, { waitUntil, timeout: timeoutMs }); return { finalUrl: page.url(), title: await page.title(), status: resp?.status() ?? null }; });
    return { content: [{ type: "text", text: JSON.stringify(result) }], structuredContent: result };
  });

  mcp.registerTool("screenshot", { description: "Take PNG screenshot; clip by selector if provided.", inputSchema: { url: z.string().optional(), selector: z.string().optional(), fullPage: z.boolean().optional().default(true), waitUntil: z.enum(["load","domcontentloaded","networkidle0","networkidle2"]).optional().default("networkidle2"), timeoutMs: z.number().int().optional().default(30000) } }, async ({ url, selector, fullPage = true, waitUntil = "networkidle2", timeoutMs = 30000 }) => {
    const result = await withPage(async (page) => { if (url) await page.goto(url, { waitUntil, timeout: timeoutMs }); let clip; if (selector) { await page.waitForSelector(selector, { timeout: timeoutMs }); const el = await page.$(selector); if (!el) throw new Error(`Selector not found: ${selector}`); const box = await el.boundingBox(); if (!box) throw new Error(`No bounding box for selector: ${selector}`); clip = box; } const png = await page.screenshot({ type: "png", fullPage: clip ? false : fullPage, clip }); const dataUri = `data:image/png;base64,${png.toString("base64")}`; return { dataUri }; });
    return { content: [{ type: "text", text: "PNG screenshot captured (data URI returned)." }], structuredContent: result };
  });

  mcp.registerTool("getContent", { description: "Get text content or full HTML.", inputSchema: { url: z.string(), selector: z.string().optional(), waitUntil: z.enum(["load","domcontentloaded","networkidle0","networkidle2"]).optional().default("domcontentloaded"), timeoutMs: z.number().int().optional().default(30000) } }, async ({ url, selector, waitUntil = "domcontentloaded", timeoutMs = 30000 }) => {
    const result = await withPage(async (page) => { await page.goto(url, { waitUntil, timeout: timeoutMs }); if (selector) { await page.waitForSelector(selector, { timeout: timeoutMs }); const text = await page.$eval(selector, (el) => el.innerText); return { url: page.url(), text }; } const html = await page.content(); const title = await page.title(); return { url: page.url(), title, html }; });
    return { content: [{ type: "text", text: JSON.stringify(result) }], structuredContent: result };
  });

  const transport = new StdioServerTransport();
  await mcp.connect(transport);
  process.on("SIGINT", async () => { await browser?.close().catch(() => {}); process.exit(0); });
}

main().catch((err) => { console.error("Fatal error starting mcp-puppeteer:", err); process.exit(1); });
