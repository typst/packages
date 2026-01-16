# Forensix

A professional Typst package for digital forensics, incident response, and malware analysis reports.

## Features

| Module | Description |
|--------|-------------|
| **[Hex Dump](docs/hexdump.md)** | Canonical hex dumps with highlighting, annotations, themes |
| **[MACB Timeline](docs/macb-timeline.md)** | File tree with MACB timestamps for forensic analysis |
| **[IOC Table](docs/ioc-table.md)** | Auto-defanging indicators of compromise |
| **[TTP References](docs/ttp.md)** | Inline MITRE ATT&CK technique cards |

![Examples](readme-quickstart.png)

## Installation

```typst
#import "@preview/forensix:0.1.0": *
```

## Quick Start

```typst
// Hex dump with highlighting
#hexdump(
  file: "/evidence/malware.bin",
  highlight: (0x4d, 0x5a),
  theme: "dracula",
)

// MACB timeline
#macb-timeline(entries: (
  folder-entry("C:\\Users\\Admin\\", depth: 0,
    modified: "2023-10-27 02:00:00", accessed: "2023-10-27 02:01:15",
    changed: "2023-10-27 02:00:00", birth: "2023-10-27 02:00:00"),
  file-entry("malware.exe", depth: 1, highlight: rgb("#fecaca"),
    modified: "2023-10-27 02:00:00", accessed: "2023-10-27 02:01:15",
    changed: "2023-10-27 02:00:00", birth: "2023-10-27 02:00:00"),
))

// IOC table (auto-defangs!)
#ioc-table(indicators: (
  "http://evil.com/payload.exe",
  "192.168.1.55",
  "44d88612fea8a8f36de82e1278abb02f",
))

// Inline TTP references
The attacker used #ttp("T1059.001") for execution.
```

## Documentation

### Online
The full documentation is available online at [teismar.github.io/typst-forensix/](https://teismar.github.io/typst-forensix/).

### Local
See the [docs/](docs/) folder for detailed configuration options:

- [Hex Dump](docs/hexdump.md) - Themes, highlighting, annotations, byte grouping
- [MACB Timeline](docs/macb-timeline.md) - File trees, timestamps, anomaly detection
- [IOC Table](docs/ioc-table.md) - Auto-defanging, type detection, custom types
- [TTP References](docs/ttp.md) - MITRE ATT&CK integration

## License

MIT
