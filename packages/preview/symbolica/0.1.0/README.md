# Symbolica

The official [Symbolica](https://symbolica.io/) plugin for Typst, powered by
Symbolica 3.0. It is free to use for any use within Typst, including academic
and commercial work.

Symbolica lets you do symbolic computations and numerical evaluations directly in your Typst document. This avoids error-prone copy-pasting and keeps the displayed results in sync when you
change an equation or parameter.

You can currently:

- expand, factor, collect, differentiate, and inspect expressions;
- combine, cancel, or decompose rational functions;
- calculate derivatives and series;
- integrate expressions and see the integration steps;
- replace recurring patterns with wildcards;
- solve systems exactly or numerically;
- evaluate formulas over points or grids; and
- solve exact matrix problems.

Start with the [user manual](symbolica/manual.pdf), the
[minimal example](symbolica/examples/basic.typ), or the
[polynomial-system showcase](symbolica/examples/showcase.typ). The manual contains
the conceptual guide, task-oriented examples, limitations, and complete API
reference.

## Quick start

### Exact factorization and differentiation

Import the published package to use Symbolica in a Typst document:

```typst
#import "@preview/symbolica:0.1.0": *

#let x = symbol("x")
#let f = math($x^4 - 5 x^2 + 4$)

$
  f(x) &= #to-typst(f) \
       &= #to-typst(factor(f)) \
  f'(x) &= #to-typst(derivative(f, x))
$
```

$$
\begin{aligned}
f(x) &= x^4 - 5x^2 + 4 \\
     &= (x - 2)(x - 1)(x + 1)(x + 2) \\
f'(x) &= 4x^3 - 10x
\end{aligned}
$$

The factorization and derivative are computed exactly while Typst compiles the document.
Symbolica expressions are opaque values; render them with `to-typst` or inspect
them with `canonical`.

### Numerical evaluation with π

Evaluate `π² + sin(π/4)` using Symbolica's built-in value of π:

```typst
#import "@preview/symbolica:0.1.0" as sym

#let expression = sym.math($pi^2 + sin(pi / 4)$)
#let value = sym.evaluate(expression)

$ pi^2 + sin(pi / 4) approx #calc.round(value.re, digits: 8) $
```

$$
\pi^2 + \sin\left(\frac{\pi}{4}\right) \approx 10.57671118
$$

`evaluate` returns a dictionary
with real and imaginary parts, `re` and `im`; here `im` is zero.

### Solve a system with parameters

Solve `x + y = a` and `x - y = b` for `x` and `y`, keeping `a` and `b` symbolic:

```typst
#import "@preview/symbolica:0.1.0" as sym

#let solutions = sym.solve(
  ($x + y - a$, $x - y - b$).map(sym.math),
  ($x$, $y$).map(sym.math),
  domain: "real",
)

#let (x, y) = solutions.branches.first().values.map(sym.to-typst)
$ x = #x, quad y = #y $
```

$$
x = \frac{a + b}{2}, \qquad y = \frac{a - b}{2}
$$


### Symbolic integration

```typst
#import "@preview/symbolica:0.1.0" as sym

#let x = sym.math($x$)
#let f = sym.math($x / (x + 1)$)
#sym.to-typst(sym.integrate(f, x))
```

$$
x - \log(x + 1)
$$

The first call to `integrate` or `integrate-with-steps` compiles and initializes
the integration rule sets, which may take about 10 seconds. Both functions share
the cached rules, so later calls and ordinary edits reuse them.


## Symbolic payloads

The `symbolica-typst-atom-payload` crate is the reusable boundary for extensions. It
combines Symbolica's exact native Atom export with schema-keyed portable
attachments and a generic render tree.

Several Typst packages are in development that make use of the symbolic payload, for example
the tensor algebra package [spenso](https://github.com/alphal00p/gammaloop).
## Install locally

To use this repository checkout, clone it and expose its root as a local
package. On Linux:

```sh
git clone https://github.com/symbolica-dev/symbolica-typst-plugin.git
cd symbolica-typst-plugin
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/local/symbolica"
ln -s "$PWD" \
  "${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/local/symbolica/0.1.0"
```

On macOS, use `~/Library/Application Support/typst/packages` in place of the
Linux data directory. For that local installation, replace `@preview` with
`@local` in your document import. The repository checks make the checkout
available under both namespaces, so public examples run unchanged.

## Use in the Typst web app

Before publication on Universe, upload the library files into your project
and import `"symbolica/lib.typ"`. A local installation on your computer is
not available to the web app.

Upload `lib.typ`, `render.typ`, `symbolica-inflate.wasm`, and
`symbolica.wasm.zlib` into a `symbolica` folder in the project. The engine is
compressed to about 6.08 MiB, with a separate 29 KiB decompression plugin.
The library first decompresses the engine in memory, then loads it through
Typst's `plugin` constructor. No file splitting or loader edits are needed.
Compression reduces the shipped files; the engine still expands to about
23.36 MiB in memory.

Once published on Universe, use `#import "@preview/symbolica:0.1.0" as sym`
instead; the package is fetched without manually uploading its Wasm.

## Documentation and examples

- [User manual](symbolica/manual.pdf) — quickstart, concepts, recipes, symbolic
  integration with nested Rubi steps, limitations, and complete API reference
- [Minimal example](symbolica/examples/basic.typ) — a compact first document
- [Rubi integration](symbolica/examples/integration.typ) — an antiderivative and
  its nested rule steps
- [Polynomial-system showcase](symbolica/examples/showcase.typ) — exact solving,
  factorization, substitution, and a Jacobian determinant in one case study
- [Batched expression grid](symbolica/examples/expression-grid.typ) — evaluate four
  formulas together over a two-dimensional parameter grid
- [Lotka–Volterra trajectory](symbolica/examples/lotka-volterra.typ) — evaluate
  both right-hand sides together inside a local Runge–Kutta loop
- [Complex phase portrait](symbolica/examples/phase-portrait.typ) — evaluate a
  rational function over thousands of complex points in one batch
- [Changelog](CHANGELOG.md) — user-visible changes and compatibility notes

## Attribution and licensing

The official `symbolica` Typst plugin is
free to use for any use within Typst, including academic and commercial work.
No Symbolica license or license key is needed for use within Typst.

The [Symbolica Typst permission](LICENSE-SYMBOLICA-TYPST.md) explicitly grants
free runtime use for all purposes within Typst, including commercial, server,
and hosted use. No payment, registration, activation, license key, or separate
runtime agreement is required. It also permits redistribution of the plugin
and rebuilding unmodified Symbolica as part of it. It grants no additional
rights to modify Symbolica itself or distribute modified Symbolica source.

The original Typst interface and Rust adapter code are under [MIT](LICENSE).
The `license = "MIT"` field in `typst.toml` describes that original plugin code.

**The bundled `symbolica/symbolica.wasm.zlib` is built from components under multiple
licenses and is not covered solely by MIT.** Symbolica's components are covered
by its [source-available license](LICENSE-SYMBOLICA.md), with the
[Symbolica Typst permission](LICENSE-SYMBOLICA-TYPST.md) taking precedence for
the uses it grants. Use outside Typst retains the otherwise applicable
Symbolica terms. Other dependencies retain their respective licenses,
including LGPL and MPL terms where applicable.

See the [third-party notices](THIRD_PARTY.md),
[complete dependency license texts](THIRD_PARTY_LICENSES.txt), and
[source locations and rebuilding instructions](REBUILDING.md). The MIT
declaration does not relicense any bundled dependency.

Thanks also to [Parsely](https://typst.app/universe/package/parsely/) for making
native Typst-math parsing possible, and to
[Tidy](https://typst.app/universe/package/tidy/) for the documentation tools.
The batched-evaluation, predator–prey, and phase-portrait examples were inspired
by TimeTravelPenguin's
[`symbolic-eval`](https://github.com/TimeTravelPenguin/symbolic-eval) package and
independently adapted to Symbolica's API. Their pinned sources and upstream
license declaration are recorded in the [third-party notices](THIRD_PARTY.md).
