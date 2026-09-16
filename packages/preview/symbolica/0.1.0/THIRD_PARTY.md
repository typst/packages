# Third-party notices

## License scope

The MIT license declared in `typst.toml` covers the original Typst interface
and Rust adapter code. The bundled `symbolica/symbolica.wasm` incorporates
components under multiple licenses and is not covered solely by MIT.
Symbolica's components remain subject to `LICENSE-SYMBOLICA.md` and
`LICENSE-SYMBOLICA-TYPST.md`; other dependencies retain their respective
licenses as recorded below and in `THIRD_PARTY_LICENSES.txt`.

## Bundled engine and dependencies

The runtime package includes [the collected license texts](THIRD_PARTY_LICENSES.txt)
for the 99 registry crates in the locked Wasm build, including build-time
dependencies conservatively. Each entry identifies the version, declared
license, repository, and source archive. For alternatives such as MIT OR
Apache-2.0, the distribution uses MIT where available, and otherwise an
applicable permissive alternative. Reproducing the alternative texts does not
require recipients to accept every alternative simultaneously.

Symbolica 3.0.0 is covered by its [source-available license](LICENSE-SYMBOLICA.md)
and the overriding [Symbolica Typst permission](LICENSE-SYMBOLICA-TYPST.md).
The latter grants runtime use within Typst without payment, registration,
activation, license keys, or a separate runtime agreement. The original
plugin code remains under [MIT](LICENSE).

The Wasm includes malachite-base, malachite-nz, and malachite-q 0.7.1 under
LGPL-3.0-only, as well as MPL-covered colored and smartstring components.
Their source and license obligations remain in effect. See
[source locations and rebuilding](REBUILDING.md) for the plugin source,
locked crates.io dependencies, and build instructions. A vendored source
archive is optional; maintaining access to the matching sources is required.

Maintainers regenerate the notices with `python3 scripts/update-licenses.py`.
The generator uses `Cargo.lock` and the actual Wasm build dependency tree;
missing license texts fail generation. Provenance for license texts omitted
from upstream crate archives is recorded in the development repository's
`docs/license-sources/README.md`.

## `symbolic-eval` example inspiration

The following Symbolica examples are new implementations inspired by examples
from TimeTravelPenguin's [`symbolic-eval`](https://github.com/TimeTravelPenguin/symbolic-eval)
repository at revision
[`79c6588`](https://github.com/TimeTravelPenguin/symbolic-eval/tree/79c6588351603b85b11b6c92b1fbff3faf478215):

- [`expression-grid.typ`](symbolica/examples/expression-grid.typ), inspired by
  [`eval_multiple_exprs.typ`](https://github.com/TimeTravelPenguin/symbolic-eval/blob/79c6588351603b85b11b6c92b1fbff3faf478215/examples/eval_multiple_exprs.typ);
- [`lotka-volterra.typ`](symbolica/examples/lotka-volterra.typ), inspired by
  [`solve_ode_system.typ`](https://github.com/TimeTravelPenguin/symbolic-eval/blob/79c6588351603b85b11b6c92b1fbff3faf478215/examples/solve_ode_system.typ),
  with the coherent parameters and numerical reference from
  [`rust/examples/ode.rs`](https://github.com/TimeTravelPenguin/symbolic-eval/blob/79c6588351603b85b11b6c92b1fbff3faf478215/rust/examples/ode.rs); and
- [`phase-portrait.typ`](symbolica/examples/phase-portrait.typ), inspired by
  [`phase_portrait.typ`](https://github.com/TimeTravelPenguin/symbolic-eval/blob/79c6588351603b85b11b6c92b1fbff3faf478215/examples/phase_portrait.typ).

The upstream package metadata identifies TimeTravelPenguin as the author and
declares `license = "MIT"`. That revision does not contain a separate license
file. No upstream images, WebAssembly binaries, or other generated artifacts
are included in Symbolica.
