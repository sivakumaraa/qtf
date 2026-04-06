## GitHub Copilot Chat

- Extension: 0.37.9 (prod)
- VS Code: 1.109.5 (072586267e68ece9a47aa43f8c108e0dcbf44622)
- OS: win32 10.0.26200 x64
- GitHub Account: sivakumaraa

## Network

User Settings:

```json
  "http.systemCertificatesNode": true,
  "github.copilot.advanced.debug.useElectronFetcher": true,
  "github.copilot.advanced.debug.useNodeFetcher": false,
  "github.copilot.advanced.debug.useNodeFetchFetcher": true
```

Connecting to https://api.github.com:

- DNS ipv4 Lookup: 20.207.73.85 (21 ms)
- DNS ipv6 Lookup: Error (25 ms): getaddrinfo ENOTFOUND api.github.com
- Proxy URL: None (3 ms)
- Electron fetch (configured): Error (26 ms): Error: net::ERR_ADDRESS_UNREACHABLE
  at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
  at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (46 ms): Error: connect EHOSTUNREACH 20.207.73.85:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (32 ms): TypeError: fetch failed
  at node:internal/deps/undici/undici:14900:13
  at processTicksAndRejections (node:internal/process/task_queues:105:5)
  at n.\_fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:26129)
  at n.fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:25777)
  at u (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4894:190)
  at CA.h (file:///c:/Users/sivak/AppData/Local/Programs/Microsoft%20VS%20Code/072586267e/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect EHOSTUNREACH 20.207.73.85:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://api.githubcopilot.com/_ping:

- DNS ipv4 Lookup: 140.82.112.22 (20 ms)
- DNS ipv6 Lookup: Error (19 ms): getaddrinfo ENOTFOUND api.githubcopilot.com
- Proxy URL: None (20 ms)
- Electron fetch (configured): Error (2 ms): Error: net::ERR_ADDRESS_UNREACHABLE
  at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
  at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (39 ms): Error: connect EHOSTUNREACH 140.82.112.22:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (41 ms): TypeError: fetch failed
  at node:internal/deps/undici/undici:14900:13
  at processTicksAndRejections (node:internal/process/task_queues:105:5)
  at n.\_fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:26129)
  at n.fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:25777)
  at u (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4894:190)
  at CA.h (file:///c:/Users/sivak/AppData/Local/Programs/Microsoft%20VS%20Code/072586267e/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect EHOSTUNREACH 140.82.112.22:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://copilot-proxy.githubusercontent.com/_ping:

- DNS ipv4 Lookup: 52.175.140.176 (19 ms)
- DNS ipv6 Lookup: Error (24 ms): getaddrinfo ENOTFOUND copilot-proxy.githubusercontent.com
- Proxy URL: None (8 ms)
- Electron fetch (configured): Error (27 ms): Error: net::ERR_ADDRESS_UNREACHABLE
  at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
  at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (44 ms): Error: connect EHOSTUNREACH 52.175.140.176:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (35 ms): TypeError: fetch failed
  at node:internal/deps/undici/undici:14900:13
  at processTicksAndRejections (node:internal/process/task_queues:105:5)
  at n.\_fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:26129)
  at n.fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:25777)
  at u (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4894:190)
  at CA.h (file:///c:/Users/sivak/AppData/Local/Programs/Microsoft%20VS%20Code/072586267e/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect EHOSTUNREACH 52.175.140.176:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://mobile.events.data.microsoft.com: Error (2 ms): Error: net::ERR_ADDRESS_UNREACHABLE
at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
at SimpleURLLoaderWrapper.emit (node:events:519:28)
[object Object]
{"is_request_error":true,"network_process_crashed":false}
Connecting to https://dc.services.visualstudio.com: Error (26 ms): Error: net::ERR_ADDRESS_UNREACHABLE
at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
at SimpleURLLoaderWrapper.emit (node:events:519:28)
[object Object]
{"is_request_error":true,"network_process_crashed":false}
Connecting to https://copilot-telemetry.githubusercontent.com/_ping: Error (54 ms): Error: connect EHOSTUNREACH 140.82.112.22:443
at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
Connecting to https://copilot-telemetry.githubusercontent.com/_ping: Error (27 ms): Error: connect EHOSTUNREACH 140.82.112.22:443
at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
Connecting to https://default.exp-tas.com: Error (45 ms): Error: connect EHOSTUNREACH 13.107.5.93:443
at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Number of system certificates: 107

## Documentation

In corporate networks: [Troubleshooting firewall settings for GitHub Copilot](https://docs.github.com/en/copilot/troubleshooting-github-copilot/troubleshooting-firewall-settings-for-github-copilot).
