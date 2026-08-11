# typograph-zx

**[Full documentation →](https://bencichos.github.io/typograph-zx/)**

`typograph-zx` is ZX-calculus and continuous-variable ZX-calculus notation
for [`typograph`](https://github.com/BenCichos/typograph): spiders,
Hadamards, multipliers, states and effects, and Pauli-web/fault-tolerance
edge highlighting. It's a normal _consumer_ of typograph's public API — a
theme, not a fork or an extension of the engine — built entirely from
`node-type()`, `edge-type()`, and `theme()`.

The package this notation is inspired by the workflow of
[tikzit](https://tikzit.github.io/) and includes notation for the
continuous-variable ZX calculus described by Shaikh, Yeh, and Gogioso in
[“The Focked-up ZX Calculus: Picturing Continuous-Variable Quantum
Computation”](https://arxiv.org/abs/2406.02905).

## Install and import

```typ
#import "@preview/typograph:0.1.0" as typ
#import "@preview/typograph-zx:0.1.0" as zx
#let diagram = typ.diagram.with(theme: zx.theme)
```

Both imports are needed: this package supplies the semantic constructors
and the bundled theme value, while the diagram engine itself — `diagram()`,
`edge()`, `group()`, and everything else that isn't ZX-specific — comes
from typograph directly.

## Quick start

```typ
#diagram({
  import zx: z, x
  let a = z(0, 0, label: $alpha$)
  let b = x(1, 0)
  typ.edge(a, b)
  typ.edge(a, (-1, 0))
  typ.edge(b, (2, 0))
})
```

<p align="center">
    <img alt="Render output showing a diagram with a z node labelled alpha and a phaseless x node, connected by an edge" src="docs/img/zx-quickstart.svg">
<p/>

See the [full documentation](https://bencichos.github.io/typograph-zx/)
for every constructor, the complete bundled palette and presets, and how
to extend this theme in a project of your own.

## Testing

```bash
bash tests/run.sh
```

Stages a local copy of `typograph` (this package's own dependency) and
runs the full fixture suite plus an outline-geometry snapshot and a
documentation-figure staleness check.

## License

MIT — see [LICENSE](LICENSE).
