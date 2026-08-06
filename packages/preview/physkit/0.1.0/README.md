# PhysKit

Composable, object-oriented physics diagrams for Typst.

PhysKit models diagrams as **objects**, **constraints**, and **connections**. A box can rest on a surface, a pulley can be fixed to a ceiling, and a rope can connect named anchors without duplicating trigonometry throughout a document.

## Status

PhysKit `0.1.0` provides mechanics, free-body, and Cartesian vector diagrams. This is the first public release. The `0.x` API is experimental and may change between minor versions.

[Manual em português](docs/manual.pdf) · [Example gallery](examples/exercise-gallery.typ)

## Quick start

```typst
#import "@preview/physkit:0.1.0": mechanics, vectors

#let ramp = mechanics.inclined-plane(
  "ramp",
  origin: (0, 0),
  length: 5,
  angle: 30deg,
)

#let block = mechanics.box("block", label: [$m$])

#mechanics.diagram(
  objects: (ramp, block),
  constraints: (
    mechanics.on-surface(block, ramp, distance: 3),
  ),
)
```

## Architecture

PhysKit exposes two architectural levels:

- `primitives`: low-level geometry, anchors, shapes, arrows and surfaces;
- `mechanics`: high-level bodies, surfaces, constraints, ropes, pulleys, forces and free-body diagrams;
- `vectors`: high-level Cartesian planes, vector components, polar vectors and resultants.

Internally, the two levels share a geometry kernel with coordinate frames, directed ports and circle tangencies. This keeps physical documents free of manual coordinate corrections.

Relations involving multiple objects remain high-level constraints. For example, `align-rope-parallel` jointly resolves a rope source, pulley, reference plane and ceiling; it is not a third public API layer.

Future high-level modules will cover thermodynamics, electricity, magnetism, optics and waves while sharing the same core.

## Vectors and free-body diagrams

```typst
#let a = vectors.vector("a", (3, 2), label: [$arrow(a)$])
#let b = vectors.polar-vector("b", 2, 90deg, from: a.end)
#let r = vectors.resultant("r", (a, b), label: [$arrow(R)$])

#vectors.diagram(vectors: (a, b, r))

#mechanics.free-body(body, forces: (weight, normal, friction))
```

See the complete [mechanics example](examples/inclined-pulley.typ), [vector and free-body example](examples/vectors-free-body.typ), and [primitive drawing example](examples/primitives.typ).

## Public API

The entrypoint exports three modules. Constructors return data descriptions; `diagram` and `free-body` render them.

### `mechanics`

- Objects and surfaces: `box`, `pulley`, `surface`, `floor`, `ceiling`, `wall`, `inclined-plane`.
- Constraints: `on-surface`, `fixed-to`, `align-rope-parallel`, `suspended-from`.
- Connections: `connect`, `wrap`, `rope`.
- Forces: `force`, `weight`.
- Rendering: `diagram`, `free-body`.

Constraints are resolved in declaration order. Objects referenced by a constraint must therefore be resolvable at that point. `on-surface` and `suspended-from` currently support boxes; `align-rope-parallel` currently requires a horizontal support.

### `vectors`

- `vector`: construct a non-zero vector from Cartesian components.
- `polar-vector`: construct a vector from a positive magnitude and angle.
- `resultant`: add the components of one or more vectors.
- `diagram`: render vectors with optional axes, grid, ticks, and component guides.

### `primitives`

The low-level module is intended for custom diagrams and extensions:

- Drawing: `canvas`, `line`, `polygon`, `circle`, `arc`, `label`, `arrow`, `rectangle`, `surface`.
- Vector geometry: `add`, `sub`, `scale`, `midpoint`, `dot`, `cross`, `magnitude`, `normalize`, `rotate`, `perpendicular`, `polar`, `lerp`, `tangent`, `normal`, `angle-of`, `distance`.
- Anchors and frames: `rectangle-anchor`, `circle-anchor`, `surface-anchor`, `frame`, `local-to-world`, `world-to-local`, `surface-frame`.
- Ports and tangencies: `port`, `circle-tangent-points`, `select-tangent`, `nearest`.
- Styling: `default-theme` and the color constants `ink`, `body-fill`, `surface-fill`, `surface-ink`, `force-ink`, `accent`, and `rope-ink`.

Coordinates and scalar distances are expressed in CeTZ canvas units. Angles use Typst angles, label positions are percentages, and force directions are global Cartesian vectors.

## Local development

Compile the smoke test directly:

```sh
typst compile --root . tests/smoke.typ
```

The distributed examples deliberately use package-style imports. Run
`scripts/test-package.sh` to stage the working tree as a temporary local package
and compile every test, example, and the manual. See `PUBLISHING.md` for the
release and Typst Universe submission workflow.

## Versioning

PhysKit follows Semantic Versioning. During the `0.x` series, minor releases may contain breaking API changes. Releases are documented in `CHANGELOG.md`.

## Contributing

See `CONTRIBUTING.md`. New high-level objects should be expressed through the primitive layer rather than calling CeTZ directly.

## License

MIT.
