const http = require('http');

const options = {
  hostname: 'localhost',
  port: 5678,
  path: '/mcp-server/http',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/event-stream',
    'Authorization': 'Bearer YOUR_TOKEN_HERE'
  }
};

const req = http.request(options, (res) => {
  console.log(`STATUS: ${res.statusCode}`);
  res.setEncoding('utf8');
  res.on('data', (chunk) => {
    console.log(`BODY: ${chunk}`);
  });
});

req.on('error', (e) => {
  console.error(`problem with request: ${e.message}`);
});

// JSON-RPC payload for initialization
const payload = JSON.stringify({
  jsonrpc: "2.0",
  id: 1,
  method: "initialize",
  params: {
    protocolVersion: "2024-11-05", // Example version
    capabilities: {
      roots: { listChanged: true }
    },
    clientInfo: {
      name: "test-client",
      version: "1.0.0"
    }
  }
});

req.write(payload);
req.end();
