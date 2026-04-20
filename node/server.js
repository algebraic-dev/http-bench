const http = require('node:http')

const OK = Buffer.from('Hello, World!')
const NF = Buffer.from('Not Found')
const BLOB = Buffer.alloc(1024 * 1024, 0x58)

http.createServer((q, r) => {
  r.sendDate = false
  if (q.url === '/plaintext') {
    r.writeHead(200, { 'content-type': 'text/plain; charset=utf-8', 'content-length': OK.length })
    r.end(OK)
  } else if (q.url === '/blob') {
    r.writeHead(200, { 'content-type': 'application/octet-stream', 'content-length': BLOB.length })
    r.end(BLOB)
  } else {
    r.writeHead(404, { 'content-length': NF.length })
    r.end(NF)
  }

}).listen(3000, '0.0.0.0')
