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

- DNS ipv4 Lookup: 20.207.73.85 (23 ms)
- DNS ipv6 Lookup: Error (25 ms): getaddrinfo ENOTFOUND api.github.com
- Proxy URL: None (1 ms)
- Electron fetch (configured): Error (31 ms): Error: net::ERR_ADDRESS_UNREACHABLE
  at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
  at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (38 ms): Error: connect EHOSTUNREACH 20.207.73.85:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (28 ms): TypeError: fetch failed
  at node:internal/deps/undici/undici:14900:13
  at processTicksAndRejections (node:internal/process/task_queues:105:5)
  at n.\_fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:26129)
  at n.fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:25777)
  at u (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4894:190)
  at CA.h (file:///c:/Users/sivak/AppData/Local/Programs/Microsoft%20VS%20Code/072586267e/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect EHOSTUNREACH 20.207.73.85:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://api.githubcopilot.com/_ping:

- DNS ipv4 Lookup: 140.82.114.22 (19 ms)
- DNS ipv6 Lookup: Error (19 ms): getaddrinfo ENOTFOUND api.githubcopilot.com
- Proxy URL: None (39 ms)
- Electron fetch (configured): Error (71 ms): Error: net::ERR_ADDRESS_UNREACHABLE
  at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
  at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (36 ms): Error: connect EHOSTUNREACH 140.82.114.22:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (47 ms): TypeError: fetch failed
  at node:internal/deps/undici/undici:14900:13
  at processTicksAndRejections (node:internal/process/task_queues:105:5)
  at n.\_fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:26129)
  at n.fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:25777)
  at u (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4894:190)
  at CA.h (file:///c:/Users/sivak/AppData/Local/Programs/Microsoft%20VS%20Code/072586267e/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect EHOSTUNREACH 140.82.114.22:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://copilot-proxy.githubusercontent.com/_ping:

- DNS ipv4 Lookup: 20.199.39.224 (19 ms)
- DNS ipv6 Lookup: Error (28 ms): getaddrinfo ENOTFOUND copilot-proxy.githubusercontent.com
- Proxy URL: None (28 ms)
- Electron fetch (configured): Error (28 ms): Error: net::ERR_ADDRESS_UNREACHABLE
  at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
  at SimpleURLLoaderWrapper.emit (node:events:519:28)
  [object Object]
  {"is_request_error":true,"network_process_crashed":false}
- Node.js https: Error (34 ms): Error: connect EHOSTUNREACH 20.199.39.224:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
- Node.js fetch: Error (24 ms): TypeError: fetch failed
  at node:internal/deps/undici/undici:14900:13
  at processTicksAndRejections (node:internal/process/task_queues:105:5)
  at n.\_fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:26129)
  at n.fetch (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4862:25777)
  at u (c:\Users\sivak\.vscode\extensions\github.copilot-chat-0.37.9\dist\extension.js:4894:190)
  at CA.h (file:///c:/Users/sivak/AppData/Local/Programs/Microsoft%20VS%20Code/072586267e/resources/app/out/vs/workbench/api/node/extensionHostProcess.js:116:41743)
  Error: connect EHOSTUNREACH 20.199.39.224:443
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Connecting to https://mobile.events.data.microsoft.com: Error (24 ms): Error: net::ERR_ADDRESS_UNREACHABLE
at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
at SimpleURLLoaderWrapper.emit (node:events:519:28)
[object Object]
{"is_request_error":true,"network_process_crashed":false}
Connecting to https://dc.services.visualstudio.com: Error (24 ms): Error: net::ERR_ADDRESS_UNREACHABLE
at SimpleURLLoaderWrapper.<anonymous> (node:electron/js2c/utility_init:2:10684)
at SimpleURLLoaderWrapper.emit (node:events:519:28)
[object Object]
{"is_request_error":true,"network_process_crashed":false}
Connecting to https://copilot-telemetry.githubusercontent.com/_ping: Error (32 ms): Error: connect EHOSTUNREACH 140.82.114.22:443
at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
Connecting to https://copilot-telemetry.githubusercontent.com/_ping: Error (13 ms): Error: connect EHOSTUNREACH 140.82.114.22:443
at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)
Connecting to https://default.exp-tas.com: Error (33 ms): Error: connect EHOSTUNREACH 13.107.5.93:443
at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1637:16)

Number of system certificates: 107

## Documentation

In corporate networks: [Troubleshooting firewall settings for GitHub Copilot](https://docs.github.com/en/copilot/troubleshooting-github-copilot/troubleshooting-firewall-settings-for-github-copilot).
