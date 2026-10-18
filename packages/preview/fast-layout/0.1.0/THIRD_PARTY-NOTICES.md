# Third-party notices

The original layout implementations are ports of NetworkLayout.jl 0.4.10 at commit
`073192ac737ff3309d7a1204fdd99ea361232d2b`. NetworkLayout.jl is
Copyright (c) 2016 Abhijith Anilkumar and other contributors under the MIT
Expat License. `NETWORKLAYOUT-LICENSE.md` reproduces its complete notice,
including the notices it carries for GraphLayout.jl, PlotRecipes.jl, and
GraphPlot.jl.

The default stress SGD optimizer is independently implemented from Zheng,
Pawar, and Goodman, [Graph Drawing by Stochastic Gradient Descent](https://arxiv.org/abs/1710.04626)
(2019). The authors' [C++ `(sgd)²` implementation](https://github.com/jxz12/s_gd2)
is used as a benchmark reference. Its source is not included in this package.

The build, CBOR bridge, and Typst package structure were adapted from chalks,
Copyright (c) 2026 Jinguo Liu, under the MIT License.

The shipped WASM uses the following Cargo packages. Versions come from
`Cargo.lock`; license names come from each installed crate manifest. The
complete license texts and their crate/version mappings are in
[THIRD-PARTY-LICENSES.txt](THIRD-PARTY-LICENSES.txt). Identical texts are included
once; all copyright notices are retained.

| Packages | License declared by crate |
| --- | --- |
| approx 0.5.1, ciborium 0.2.2, ciborium-io 0.2.2, ciborium-ll 0.2.2, nalgebra 0.33.3, simba 0.9.1 | Apache-2.0 |
| bytemuck 1.25.2, safe_arch 0.7.4 | Zlib OR Apache-2.0 OR MIT |
| cfg-if 1.0.4, half 2.7.1, num-complex 0.4.6, num-integer 0.1.47, num-rational 0.4.2, num-traits 0.2.19, paste 1.0.15, proc-macro2 1.0.107, quote 1.0.47, serde 1.0.229, serde_core 1.0.229, serde_derive 1.0.229, syn 2.0.119, syn 3.0.5, typenum 1.20.1 | MIT OR Apache-2.0 |
| matrixmultiply 0.3.11, rawpointer 0.2.1 | MIT/Apache-2.0 |
| unicode-ident 1.0.24 | (MIT OR Apache-2.0) AND Unicode-3.0 |
| wide 0.7.33 | Zlib OR Apache-2.0 OR MIT in its manifest; the release contains its Zlib license text |
| zerocopy 0.8.57, zerocopy-derive 0.8.57 | BSD-2-Clause OR Apache-2.0 OR MIT |
| venial 0.5.0 | MIT |
| wasm-minimal-protocol 0.1.0 | The manifest has no SPDX value; its bundled LICENSE dedicates the work to the public domain under the Unlicense |

The table follows the normal-dependency graph reported by:

```sh
cargo tree --target wasm32-unknown-unknown --edges normal
```

Procedural macro crates appear because Cargo uses them while building the
shipped WASM. They do not become runtime modules inside the binary.
