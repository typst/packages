# Third-party notices

Axodendron's `plugin.wasm` contains open-source Rust dependencies, the documentation and one example optionally use CeTZ, and the package includes four real-world SWC examples. This file records the applicable notices and data provenance; Axodendron's own source remains covered by `LICENSE`.

## WebAssembly dependencies

| Component | Version | License used for this distribution |
| --- | --- | --- |
| `ciborium`, `ciborium-io`, `ciborium-ll` | 0.2.2 | Apache-2.0 |
| `serde`, `serde_core`, `serde_derive` | 1.0.229 | MIT |
| `half` | 2.7.1 | MIT |
| `cfg-if` | 1.0.4 | MIT |
| `zerocopy`, `zerocopy-derive` | 0.8.55 | MIT |
| `wasm-minimal-protocol` | 0.2.0 | Unlicense |

The exact dependency versions and source checksums are pinned in the source repository's [`wasm-plugin/Cargo.lock`](https://github.com/rice8y/axodendron/blob/main/wasm-plugin/Cargo.lock). Procedural-macro build dependencies are not linked into `plugin.wasm`; their license expressions remain recorded by the lockfile and Cargo metadata.

Apache License 2.0: <https://www.apache.org/licenses/LICENSE-2.0>

MIT License: <https://opensource.org/license/mit>

The Unlicense: <https://unlicense.org/>

## Optional Typst example dependency

[`examples/cetz.typ`](examples/cetz.typ) and [`docs/documentation.typ`](docs/documentation.typ) import [CeTZ 0.5.2](https://github.com/cetz-package/cetz/tree/v0.5.2), licensed under [LGPL-3.0-or-later](https://github.com/cetz-package/cetz/blob/v0.5.2/LICENSE). CeTZ is resolved as a separate Typst package supplied by the caller; its source and WebAssembly component are not copied into Axodendron or `plugin.wasm`.

## Bundled morphology examples

The following standardized SWC files are included only as attributed package examples and documentation inputs. AA0109 is used by the basic, overview, analysis, and CeTZ examples; Nr5a1-Cre by the overview; Sst-IRES-Cre by Quick start; and Vipr2-IRES2-Cre by the overview and rendering examples. The rendered manual source at [`docs/documentation.typ`](docs/documentation.typ) uses all four in additional worked examples and places an attribution line next to every rendered occurrence. They were obtained from NeuroMorpho.Org, which distributes downloadable morphology data under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) and asks users to cite NeuroMorpho.Org, RRID:SCR_002145, the relevant original study, and the database publications described in its [terms of use](https://neuromorpho.org/useterm.jsp).

| Bundled file | NeuroMorpho record | Archive | Original-study reference | SHA-256 |
| --- | --- | --- | --- | --- |
| `examples/data/AA0109.CNG.swc` | [NMO 85226, AA0109](https://neuromorpho.org/api/neuron/id/85226) | MouseLight | [DOI 10.1002/jnr.23978](https://doi.org/10.1002/jnr.23978); reconstruction deposit [DOI 10.25378/janelia.5526706](https://doi.org/10.25378/janelia.5526706) | `d54fc74e3ba5fa38c9c21898137f5a5f369cf73c169e2b966a6c4766f8ba0db8` |
| `examples/data/Nr5a1-Cre_Ai14-187777-05-02-01_491392821_m.kp1.swc` | [NMO 62390](https://neuromorpho.org/api/neuron/id/62390) | Allen Cell Types | [DOI 10.1016/j.neuron.2015.02.022](https://doi.org/10.1016/j.neuron.2015.02.022) | `f7559c4511d6adf63327558eb58291aac85d25fdff6a8136597c1c2886c08d78` |
| `examples/data/Sst-IRES-Cre_Ai14-188740-03-02-01_491119369_m.kp12.swc` | [NMO 62495](https://neuromorpho.org/api/neuron/id/62495) | Allen Cell Types | [DOI 10.1016/j.neuron.2015.02.022](https://doi.org/10.1016/j.neuron.2015.02.022) | `4693e9a1a863dbe526570b5047d76eba8917813eb16b9d956ccf9949d7fa30b7` |
| `examples/data/Vipr2-IRES2-Cre_Ai14-310513-05-02-01_637021223_m.CNG.swc` | [NMO 102520](https://neuromorpho.org/api/neuron/id/102520) | Allen Cell Types | [DOI 10.1016/j.neuron.2015.02.022](https://doi.org/10.1016/j.neuron.2015.02.022) | `c89f732b80c51909b9c4bfca798a84cfacee392a8556b19ab228a676ed5c595c` |

No other downloaded NeuroMorpho.Org SWC is committed, packaged, or uploaded as a build artifact. The 30-case regression corpus remains checksum-pinned metadata plus a private ignored cache as described in the real-data policy section of [`docs/documentation.typ`](docs/documentation.typ).
