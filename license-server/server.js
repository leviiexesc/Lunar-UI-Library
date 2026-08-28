const http = require("node:http");
const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");

const port = Number(process.env.PORT || 3000);
const adminToken = process.env.ADMIN_TOKEN;
const dataFile = process.env.DATA_FILE || path.join(__dirname, "licenses.json");

if (!adminToken) {
  console.error("Set ADMIN_TOKEN before starting the license server.");
  process.exit(1);
}

function readLicenses() {
  try {
    return JSON.parse(fs.readFileSync(dataFile, "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") return {};
    throw error;
  }
}

let licenses = readLicenses();

function saveLicenses() {
  const temporaryFile = `${dataFile}.tmp`;
  fs.writeFileSync(temporaryFile, JSON.stringify(licenses, null, 2));
  fs.renameSync(temporaryFile, dataFile);
}

function send(response, status, body) {
  response.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "content-type, x-admin-token",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  });
  response.end(JSON.stringify(body));
}

function readBody(request) {
  return new Promise((resolve, reject) => {
    let body = "";
    request.on("data", (chunk) => {
      body += chunk;
      if (body.length > 16 * 1024) request.destroy();
    });
    request.on("end", () => {
      try {
        resolve(JSON.parse(body || "{}"));
      } catch {
        reject(new Error("Invalid JSON body."));
      }
    });
    request.on("error", reject);
  });
}

function authorized(request) {
  const supplied = request.headers["x-admin-token"] || "";
  return supplied.length === adminToken.length && crypto.timingSafeEqual(Buffer.from(supplied), Buffer.from(adminToken));
}

function newKey() {
  return `LUNAR-${crypto.randomBytes(12).toString("hex").toUpperCase()}`;
}

const server = http.createServer(async (request, response) => {
  if (request.method === "OPTIONS") return send(response, 204, {});
  if (request.method !== "POST") return send(response, 405, { ok: false, error: "Method not allowed." });

  let body;
  try {
    body = await readBody(request);
  } catch (error) {
    return send(response, 400, { ok: false, error: error.message });
  }

  if (request.url === "/validate") {
    const key = typeof body.key === "string" ? body.key.trim() : "";
    const hwid = typeof body.hwid === "string" ? body.hwid.trim() : "";
    const license = licenses[key];
    if (!key || !hwid || !license) return send(response, 401, { ok: false, error: "Invalid license." });
    if (license.hwid && license.hwid !== hwid) return send(response, 409, { ok: false, error: "License is already bound to another device." });
    if (!license.hwid) {
      license.hwid = hwid;
      license.boundAt = new Date().toISOString();
      saveLicenses();
    }
    return send(response, 200, { ok: true, message: "License accepted." });
  }

  if (!authorized(request)) return send(response, 403, { ok: false, error: "Admin authorization required." });

  if (request.url === "/admin/create") {
    const key = newKey();
    licenses[key] = { createdAt: new Date().toISOString(), hwid: null, boundAt: null };
    saveLicenses();
    return send(response, 201, { ok: true, key });
  }

  if (request.url === "/admin/reset") {
    const key = typeof body.key === "string" ? body.key.trim() : "";
    if (!licenses[key]) return send(response, 404, { ok: false, error: "License not found." });
    licenses[key].hwid = null;
    licenses[key].boundAt = null;
    licenses[key].resetAt = new Date().toISOString();
    saveLicenses();
    return send(response, 200, { ok: true, message: "Device binding reset." });
  }

  return send(response, 404, { ok: false, error: "Not found." });
});

server.listen(port, () => console.log(`Lunar license server listening on port ${port}`));
