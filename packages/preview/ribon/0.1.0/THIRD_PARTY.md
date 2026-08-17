# Third-party notices

This document is a technical notice for the Typst Universe distribution and does not replace the license text of any component.

## RNAstructure 6.6 thermodynamic tables

The thermodynamic constants compiled into `ribon_plugin.wasm` are generated from 34 `data_tables/rna.*` files and 33 `data_tables/dna.*` files distributed with RNAstructure 6.6 under `GPL-2.0-only`. No RNAstructure C++ program code is compiled, linked, copied, or included in this package.

- Upstream: <https://rna2.urmc.rochester.edu/RNAstructureDownload.html>
- Version: 6.6
- Official macOS arm64 Conda archive SHA-256: `8a2904c4b9e16854a2aac3c6f3e510c844685f8cf330601e986d12f7d97dadc8`
- Normalized 34-file RNA bundle SHA-256: `0c00a31400f1dedbe9a3e161b2f9b1b74cde54941144ee988f48173d33bbcd7b`
- Normalized 33-file DNA bundle SHA-256: `019ad1d5c3dac421df37e0a5aeded6d3da50da03deecc23ba0ae5a6d5d06b977`
- License: `GPL-2.0-only`

The complete parameter text files and their GPL-2.0 license are available in the Ribon source repository under `crates/ribon-core/data/rnastructure-6.6/`. Because these tables are included, this Typst package, its Rust source, and its distributed WASM module are provided under `GPL-2.0-only`.

## Rust dependencies compiled into WASM

Exact dependency versions are recorded by `Cargo.lock` in the source repository.

| Component | License |
|---|---|
| serde / serde_json / proc-macro2 / quote / syn / itoa | MIT OR Apache-2.0 |
| unicode-ident | (MIT OR Apache-2.0) AND Unicode-3.0 |
| memchr | Unlicense OR MIT |
| wasm-minimal-protocol | Unlicense |

## Modified-nucleotide thermodynamic data

The WASM module contains independently transcribed numerical facts from published nearest-neighbor tables for m6A, pseudouridine, inosine-C/U, 7-deazaadenosine, and purine/nebularine, plus a separately identified published correction for dihydrouridine. Analysis results report DOI provenance and calibration type. No article text, figures, or upstream program code are included.

## Runtime boundary

The WASM module imports only the two `typst_env` functions required by the minimal protocol. Its inspected exports are `memory`, `run`, and toolchain data/heap globals. This package contains no third-party native archive, C/C++ runtime, filesystem bridge, process bridge, or network bridge.
