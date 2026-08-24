# Bundled data notice

The thermodynamic constants compiled into the WASM are generated from the 34 `data_tables/rna.*` and 33 `data_tables/dna.*` free-energy and enthalpy tables distributed with RNAstructure 6.6 under GNU GPL version 2 only. The reference Bioconda macOS arm64 archive SHA-256 is `8a2904c4b9e16854a2aac3c6f3e510c844685f8cf330601e986d12f7d97dadc8`; the normalized RNA table-bundle SHA-256 is `0c00a31400f1dedbe9a3e161b2f9b1b74cde54941144ee988f48173d33bbcd7b`. The normalized DNA table-bundle SHA-256 is `019ad1d5c3dac421df37e0a5aeded6d3da50da03deecc23ba0ae5a6d5d06b977`.

The complete parameter text files and GPL-2.0 license are present in the source repository under `crates/ribon-core/data/rnastructure-6.6/`.

Sparse modified-nucleotide nearest-neighbor parameters come from the primary literature cited in the source repository. The runtime returns DOI provenance and calibration type alongside every used table.
