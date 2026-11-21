# Third-party notices

The bundled `plugin/chalks_engine.wasm` contains code from these Rust crates:

| Crate | Version | License used |
| --- | --- | --- |
| ciborium, ciborium-io, ciborium-ll | 0.2.2 | Apache-2.0 |
| half | 2.7.1 | MIT |
| serde, serde_core, serde_derive | 1.0.229 | MIT |
| cfg-if | 1.0.4 | MIT |
| zerocopy, zerocopy-derive | 0.8.55 | MIT |
| wasm-minimal-protocol | 0.1.0 | The Unlicense |

Copyright notices supplied by the dependencies include:

- cfg-if: Copyright (c) 2014 Alex Crichton.
- zerocopy: Copyright 2023 The Fuchsia Authors.

The applicable license texts are included in the `licenses/` directory.
Build-only procedural-macro dependencies are recorded by `Cargo.lock`; they
are not distributed as part of the WASM binary.
