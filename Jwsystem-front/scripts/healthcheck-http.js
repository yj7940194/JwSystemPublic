const http = require('http')
const https = require('https')

const target = process.argv[2]
if (!target) {
  process.stderr.write('Usage: node healthcheck-http.js <url>\n')
  process.exit(2)
}

const client = target.startsWith('https:') ? https : http

const req = client.get(target, res => {
  res.resume()
  const status = res.statusCode || 0
  process.exit(status >= 200 && status < 400 ? 0 : 1)
})

req.on('error', () => process.exit(1))
req.setTimeout(2000, () => {
  req.destroy()
  process.exit(1)
})
