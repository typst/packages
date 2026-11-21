# Goldstitch

A **Typst drawing library** for antisymmetrized Goldstone diagrams of CC equations and similarity-transformed Hamiltonians. Diagrams use Kállay–Surján integer notation and are rendered with [Fletcher](https://typst.app/universe/package/fletcher/). Drawing requires Typst, not Python.

## Quick start

```typ
#import "@preview/goldstitch:0.1.0": goldstone, kallay-label

#goldstone("220 000 000 000 4")
#kallay-label("220 000 000 000 4")
#goldstone("111 220 7")
#goldstone("111 111 220 10")
#goldstone("220 222 10")
```

See [`examples/basic.typ`](examples/basic.typ) and its [PDF](examples/basic.pdf).
The examples use the published package import. To build them against a working checkout before publication or during development, stage a temporary local package from this repository root:

```sh
package_path="$(mktemp -d)"
package_dir="$package_path/preview/goldstitch/0.1.0"
mkdir -p "$package_dir"
cp lib.typ typst.toml README.md LICENSE "$package_dir/"
for example in basic operators hamiltonian-lines; do
  typst compile --root . --package-path "$package_path" \
    "examples/$example.typ" "examples/$example.pdf"
done
rm -r "$package_path"
```

The library requires Typst 0.13.0 or later and imports `@preview/fletcher:0.5.8`.
First use needs access to the Typst package registry unless the dependency is already cached. Development tests were last run with Typst 0.13.0 and 0.15.1.

## Kállay notation

A diagram is a tuple of four amplitude triplets followed by an interaction-vertex number:

```text
((ε₀, ι₀, π₀), (ε₁, ι₁, π₁), (ε₂, ι₂, π₂), (ε₃, ι₃, π₃), η)
```

For example, `kallay-label("220 4")` renders `((2, 2, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), 4)`.

For each cluster-amplitude vertex `Tᵢ`:

1. `εᵢ` is its excitation level;
2. `ιᵢ` is the total number of internal lines contracted with the Hamiltonian;
3. `πᵢ` is the number of those internal lines that are outgoing particle lines.

`Tᵢ` has `ιᵢ − πᵢ` internal hole lines, `εᵢ − πᵢ` external particle lines, and `εᵢ − ιᵢ + πᵢ` external hole lines. The final integer `η` selects one of the 13 one- and two-electron Hamiltonian vertices in Fig. 1 of the paper:

| ID | Matrix element | Internal particles | Internal holes |
|---:|:---------------|-------------------:|---------------:|
| 0 | `f_ab` | 1 | 0 |
| 1 | `f_ji` | 0 | 1 |
| 2 | `f_ia` | 1 | 1 |
| 3 | `<ad‖bc>` | 2 | 0 |
| 4 | `<jk‖il>` | 0 | 2 |
| 5 | `<ja‖ib>` | 1 | 1 |
| 6 | `<ic‖ab>` | 2 | 1 |
| 7 | `<ij‖ak>` | 1 | 2 |
| 8 | `<ac‖ib>` | 1 | 0 |
| 9 | `<aj‖ik>` | 0 | 1 |
| 10 | `<ij‖ab>` | 2 | 2 |
| 11 | `f_ai` | 0 | 0 |
| 12 | `<ab‖ij>` | 0 | 0 |

These counts give the lower annihilation capacities, not all orbital indices of the matrix element. Equation diagrams use all these capacities; operator diagrams may leave some uncontracted. Vertices 11 and 12 are bare contributions, written simply as `"11"` and `"12"`.

All fields must be non-negative integers, and `η` must be between 0 and 12. Amplitude triplets are ordered lexicographically: excitation levels are nondecreasing; equal excitation levels have nondecreasing internal-line counts; and equal excitation levels and internal-line counts have nondecreasing internal particle-line counts.

Trailing `000` amplitudes can be omitted, so `"220 4"` and `"220 000 000 000 4"` are equivalent. For fields greater than nine, delimit a triplet with `/`, `:`, or `,`. Structured input is also accepted:

```typ
#goldstone("10/1/1 0")
#goldstone(((2, 2, 0), (0, 0, 0), 4))
```

`goldstone` checks that amplitude ranks and line counts are valid and do not exceed the interaction's particle/hole capacities. Use `mode: "equation"` to require complete contraction of the Hamiltonian annihilation lines.

## Styling

```typ
#goldstone(
  "220 4",
  spacing: 7.5mm,
  level-gap: 4.5mm,
  stroke: 0.65pt,
  hamiltonian-line: "default",
  mark-scale: 100%,
  arrows: "minimal",
  leg-angle: 20deg,
  loop-bend: 75deg,
  t1-bar-extension: 2.5pt,
  labels: false,
  debug: false,
)
```

### Hamiltonian lines

Use `hamiltonian-line` to distinguish contraction intermediates without changing the diagram's topology. It works in equation, operator, and automatic modes. Particle/hole lines, cluster bars, and vertex markers keep their own styling.

| Preset | Appearance |
|:-------|:-----------|
| `"default"` | Existing dashed line; also used when the option is omitted |
| `"dashed"` | Alias for `"default"` |
| `"solid"` | Single continuous line |
| `"dotted"` | Round dotted line |
| `"double"` | Two parallel continuous lines |
| `"wavy"` | Continuous wave |

For example:

```typ
#goldstone("221 10", mode: "operator", hamiltonian-line: "double")
```

For more control, pass a dictionary. `style` selects a preset and defaults to `"default"`; the remaining fields override its drawing options:

```typ
#goldstone(
  "221 10",
  mode: "operator",
  hamiltonian-line: (
    style: "dashed",
    stroke: blue + 0.9pt,
    dash: (array: (3pt, 1pt), phase: 0pt),
  ),
)
```

- **Stroke:** `stroke` accepts a Typst stroke, including color, thickness, and cap/join settings. Unless overridden, the Hamiltonian line has thickness `0.7 * stroke`, where the latter is the diagram-wide thickness.
- **Dash pattern:** `dash` accepts Fletcher's dash settings, including `none`, `"dashed"`, `"dotted"`, or a custom `(array: ..., phase: ...)` dictionary. A dash specified inside a custom `stroke` takes precedence over the separate `dash` field, following Fletcher's behavior.
- **Double-line spacing:** `extrude` sets the parallel-line offsets. For example, `(style: "double", extrude: (-1.5pt, 1.5pt))` gives 3 pt separation. The preset uses `(-2, 2)`, in units of the Hamiltonian stroke thickness.
- **Wave geometry:** with `style: "wavy"`, use `wave: (amplitude: 2pt, segments: 4)` to adjust the wave. The `wave` dictionary accepts CeTZ wave-decoration options, including `segment-length`. By default, amplitude is 1 pt and the segment count adapts to the line's physical length, with at least two segments so short interactions remain drawable.
- **Other decorations:** `decorations` accepts Fletcher's built-in decorations or a CeTZ decoration function. It overrides the preset decoration; `decorations: none` removes it. Other applicable named Fletcher edge options are forwarded as well. The `vertices` field is reserved because endpoints are determined by the diagram.

See [`examples/hamiltonian-lines.typ`](examples/hamiltonian-lines.typ) and its [PDF](examples/hamiltonian-lines.pdf) for the presets in both layouts and custom intermediate styles.

### Equation layout

#### Vertices and bars

Each solid horizontal bar represents a cluster amplitude, with one particle–hole pair meeting the bar for every excitation rank. Filled black dots mark these attachment sites. The Hamiltonian is drawn as a dashed line by default, with open circles at its fermionic endpoints.

For ranks above one, cluster bars end at their outermost attachment sites. A `T_1` bar extends by `t1-bar-extension` on either side of its single site. Set `labels: true` to show the `T` ranks and the Hamiltonian interaction number.

#### Arrows

Particles point out of a `T` vertex and holes point into it. At each fermionic vertex, one line arrives and one leaves. The segments therefore form continuous paths: either open paths with both ends outside the diagram, or closed loops.

The `arrows` option controls how many arrowheads are shown:

- `"minimal"` (default) places one arrow on a straight segment attached to the Hamiltonian, never on a curved particle–hole loop. It prefers an internal Hamiltonian–cluster contraction, falling back to an external Hamiltonian leg when no straight contraction is available. Within those choices, it prefers particles over holes, then longer segments over shorter ones.
- `"all"` places an arrow on every segment.

#### Geometry controls

- **Leg opening:** `leg-angle` sets the preferred opening angle at a cluster vertex. The default gives the steep, symmetric 80°–20°–80° geometry.
- **Particle–hole lenses:** `loop-bend` sets the opening of the curved lens formed when a particle and a hole connect the same cluster site to the same Hamiltonian endpoint.
- **Through-lines:** a line passing through a Hamiltonian endpoint continues straight, without a kink. Its contracted part and the free leg form a symmetric V at the cluster vertex.

#### Automatic placement

The input tuple has a canonical order, but that order does not fix the left-to-right positions of the cluster bars. The renderer arranges them to keep the diagram balanced and reduce avoidable crossings:

- **Cluster order:** bars are initially grouped by their Hamiltonian attachments, using mirrored tie-breaking for symmetric halves. The renderer then compares whole-bar orders to reduce crossings between the dashed Hamiltonian line and open cluster legs. Hamiltonian endpoints remain distinct, and ties retain the initial order. Endpoints with only upper legs may switch sides to avoid an open-leg crossing.
- **Contraction assignment:** lines of the same species are initially matched to cluster sites in left-to-right order, minimizing horizontal displacement. Attachment sites are then reordered to keep fully open particle–hole pairs outside. Crossings required by the topology are retained.
- **Hamiltonian alignment:** endpoints are centered over their actual attachment sites, keeping closed lenses vertical and shared contractions balanced. Shared lower endpoints may move away from open legs for clearance, preferably outward to preserve space between Hamiltonian endpoints. These adjustments do not reverse contraction sides or move closed lenses.
- **Open pairs:** fully open particle–hole pairs sharing a cluster site are grouped at one end of the bar. With multiple clusters, they face the nearest outside edge of the whole row rather than a gap between bars. For a lone or centered bar, the renderer chooses the side that shortens contractions. Singly open legs are not regrouped; the relative order of contracted sites and existing particle–hole pairings is preserved.
- **Interaction 5 with a single `T_1`:** the renderer uses the equivalent split form, with an upper V at one Hamiltonian endpoint and the lower particle–hole pair at the other.

## Operator rendering

The same `goldstone` function accepts partial-contraction tuples without converting them to projected equation diagrams:

```typ
#import "@preview/goldstitch:0.1.0": goldstone, diagram-signature

#goldstone("10")       // Bare two-body annihilation vertex
#goldstone("211 10")   // One T2; some H annihilators remain external
#assert(diagram-signature("211 10") == (1, 2, 1, 2))
#goldstone("242 10", mode: "operator") // Scalar correlation-energy term
```

`parse-kallay` parses compact strings, structured arrays, and dictionaries with `amplitudes` and `interaction` fields. `parse-diagram` returns the validated model, accepting partial Hamiltonian contractions; its result can also be passed to `goldstone`. `diagram-signature` returns the four external quasiparticle counts, ordered as (created particles, created holes, annihilated particles, annihilated holes). `kallay-label` also accepts partially contracted tuples.

Layout selection:

- `mode: "auto"` (default): preserves the equation layout when all H annihilation lines are contracted; otherwise uses the layered operator layout.
- `mode: "operator"`: forces the layered layout, including scalar and pure-creation sectors.
- `mode: "equation"`: requires complete contraction of H annihilation lines and uses the equation layout.

The layered layout puts T below H. Creation legs are short upward stubs; annihilation legs are short downward stubs. They do not share a projection boundary. Particle arrows run from creation to annihilation endpoints; hole arrows run oppositely. Coincident opposite-species contractions form curved lenses. Crossings without a marker are **not** vertices. T uses solid bars with filled black circles; H uses the selected Hamiltonian line style (dashed by default) and open circles. Dense diagrams can still have crossings.

Styling options above also apply here; the layered defaults are `arrows: "all"` and `mark-scale: 85%`. Use `labels: true` for T ranks and H's vertex number, and `excitation-symbol` to customize the T label.

See [`examples/operators.typ`](examples/operators.typ) and its [PDF](examples/operators.pdf) for all thirteen bare vertices, partial contractions, and a scalar correlation-energy term.

## Development and tests

The test suite lives in the [source repository](https://github.com/robertodr/ccdiagrams); it is not included in the published package.

The fourteen self-contained tests need Python 3.10+ and `typst` on `PATH`. These include SVG checks for Hamiltonian line styles, custom overrides, unchanged default rendering, and isolated package imports that compile the README examples without access to the source checkout:

```sh
python3 -m unittest discover -s tests -v
```

Three additional integration tests require a compatible diagram generator, which is not bundled here. They are explicitly skipped when it is unavailable. These tests compile CCSDT equation tuples and small operator hierarchies, checking incidence, signatures, and port conservation.

Missing Typst skips the rendering tests. Python and the optional generator are development tools only; neither is required for drawing diagrams.

## Reference

M. Kállay and P. R. Surján, “Higher excitations in coupled-cluster theory,” *J. Chem. Phys.* **115**, 2945–2954 (2001), [doi:10.1063/1.1383290](https://doi.org/10.1063/1.1383290), especially Eq. (8) and Fig. 1.
