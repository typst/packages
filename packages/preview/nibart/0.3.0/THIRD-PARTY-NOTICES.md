# Third-party notices

`nibart.wasm` is compiled from the Rust crate in `rust/` and statically links the crates below
(resolved in `rust/Cargo.lock`). All are under permissive licences compatible with this package's MIT licence.
`wasm-minimal-protocol` ships an MIT licence file in its repository.

| crate | version | licence |
|---|---|---|
| arrayvec | 0.7.8 | MIT OR Apache-2.0 |
| euclid | 0.22.14 | MIT OR Apache-2.0 |
| i_float | 5.0.0 | MIT |
| i_key_sort | 0.11.0 | MIT |
| i_overlay | 9.0.0 | MIT OR Apache-2.0 |
| i_shape | 5.0.0 | MIT |
| i_tree | 0.19.0 | MIT |
| itoa | 1.0.18 | MIT OR Apache-2.0 |
| kurbo | 0.13.1 | Apache-2.0 OR MIT |
| libm | 0.2.16 | MIT |
| memchr | 2.8.3 | Unlicense OR MIT |
| num-traits | 0.2.19 | MIT OR Apache-2.0 |
| polycool | 0.4.0 | MIT OR Apache-2.0 |
| proc-macro2 | 1.0.107 | MIT OR Apache-2.0 |
| quote | 1.0.47 | MIT OR Apache-2.0 |
| serde | 1.0.229 | MIT OR Apache-2.0 |
| serde_core | 1.0.229 | MIT OR Apache-2.0 |
| serde_derive | 1.0.229 | MIT OR Apache-2.0 |
| serde_json | 1.0.151 | MIT OR Apache-2.0 |
| smallvec | 1.16.2 | MIT OR Apache-2.0 |
| syn | 3.0.6 | MIT OR Apache-2.0 |
| unicode-ident | 1.0.26 | (MIT OR Apache-2.0) AND Unicode-3.0 |
| venial | 0.5.0 | MIT |
| wasm-minimal-protocol | 0.2.1 | MIT (licence file) |
| zmij | 1.0.23 | MIT |

MetaPost / Metafont (D. Knuth, J. Hobby, T. Hoekwater et al.) inspired the path language and the algorithm (J. D. Hobby,
*Smooth, easy to compute interpolating splines*, 1986); no MetaPost code is included.
Calligraphic options (`follow`, dashes with jitter, pressure, layered, debug) follow the *behaviour* described by the `nibst`
package (B. Auguie, MPL-2.0); no code from `nibst` is used.
