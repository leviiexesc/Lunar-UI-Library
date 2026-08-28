# Lunar UI License Server

This small Node.js service binds each license key to one device identifier. A second device using the same key receives a rejection. The owner can clear a binding with the admin reset endpoint.

## Run locally

```powershell
$env:ADMIN_TOKEN = "replace-with-a-long-random-secret"
npm start
```

Deploy this folder to a private server or hosting provider. Set `ADMIN_TOKEN` there and keep it secret. `licenses.json` is created automatically and must be backed up or stored on persistent disk.

## Admin API

Create a key:

```powershell
Invoke-RestMethod -Method Post -Uri http://localhost:3000/admin/create -Headers @{ "x-admin-token" = $env:ADMIN_TOKEN }
```

Reset a key's device binding:

```powershell
Invoke-RestMethod -Method Post -Uri http://localhost:3000/admin/reset -Headers @{ "x-admin-token" = $env:ADMIN_TOKEN; "Content-Type" = "application/json" } -Body '{"key":"LUNAR-..."}'
```

The public `/validate` endpoint accepts `{ "key": "...", "hwid": "..." }`. Do not expose `ADMIN_TOKEN` in Roblox code or in the public repository.
