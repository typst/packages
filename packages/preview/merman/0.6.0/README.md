# merman

Render Mermaid diagrams in Typst with the `merman` Rust renderer.

`merman` embeds a WebAssembly plugin so Typst documents can render Mermaid diagrams directly during compilation while reusing the parser, layout, and SVG renderer from the broader `merman` project. Typst package `0.6.0` bundles Merman `0.10.0` with Mermaid `12.3.0` behavior. It requires Typst `0.15.0` or newer.

## Quick Start

Save the following as `document.typ`:

```typst
#import "@preview/merman:0.6.0": mermaid

#mermaid("
flowchart TD
  A[Write Mermaid] --> B[Render with merman]
  B --> C[Embed SVG in Typst]
")
```

Compile it to PDF:

```sh
typst compile document.typ document.pdf
```

Upgrading from `0.3.0`? Mermaid 12 changed the default layout of flowcharts and several other graph families to ELK. To keep Dagre, see [Choose a Layout](#choose-a-layout); no custom plugin build is needed.

See [Upgrading from 0.5.0](#upgrading-from-050) and the [package changelog](CHANGELOG.md) for migration actions and rendering changes.

## Version Mapping

| Typst package | merman source version | Typst plugin ABI | Notes |
| --- | --- | --- | --- |
| `0.6.0` | `0.10.0` | `3` | Options 3, compiled themes, editable recipes, and theme catalog discovery. |
| `0.5.0` | `0.9.0` | `2` | Published package with Options 2 and Mermaid 12.1 rendering. |
| `0.4.0` | `0.8.0` | `2` | Mermaid 12.1 rendering; requires Typst `0.15.0` or newer. |
| `0.3.0` | `0.8.0-alpha.6` | `2` | Previous size-optimized WASM package. |
| `0.2.0` | Previously published source revision | `2` | Published registry channel; do not infer alpha.6 source provenance from this version. |
| `0.1.0` | `0.8.0-alpha.1` | `1` | Previous package API. |

The Typst package version tracks the `@preview/merman` wrapper API. The merman source version is the Rust workspace version used to build the package. The Typst plugin ABI tracks the WebAssembly export names and byte payload contracts; wrapper-only API breaks do not require an ABI bump when that plugin surface stays stable. Render option JSON follows shared binding options schema `3`, including top-level `theme` for compiled diagram themes, `site_config` for Mermaid configuration, `layout` for geometry, and `environment` for text measurement and math rendering. This options schema is independent from Typst plugin ABI 3 and native ABI 3.

Theme spec, authoring, recipe, materialization, support, and catalog contracts remain at version `1`, as do preset revisions. These versions are independent of the wrapper version, plugin ABI, and render options schema. Theme presets and authoring remain Alpha; catalog availability does not qualify every family or effect for Typst output.

## Upgrading from 0.5.0

Update imports to `@preview/merman:0.6.0`. The wrapper bundles Merman `0.10.0` and advances the plugin from ABI `2` to `3` and render options from schema `2` to `3`. Use the wrapper and WASM from the same package, including when building locally. The minimum compiler remains Typst `0.15.0`.

| 0.5.0 input | 0.6.0 action |
| --- | --- |
| `presentation-profile`, including `"merman-modern"` | Choose `theme-preset`, an editable `theme-recipe`, or a complete `diagram-theme` spec. |
| `host-theme` | Use `typography` for font intent and a compiled theme selection for colors and roles. |
| `theme` shorthand for Mermaid variables | Rename it to `theme-variables`; `theme-name` still selects Mermaid's own theme. |
| `scoped-css`, `css-override-policy`, or their raw SVG option fields | Use typed theme inputs, `theme-variables`, or `background`; raw CSS and cascade policy are rejected by general bindings. |
| Raw options `version: 2` with `presentation` | Use `version: 3` with top-level `theme: (preset: "editor", appearance: "dark")`, `theme: (recipe: recipe)`, or `theme: (spec: spec)`. |

The compiled theme selection works across render, figure, SVG/result, and raw-block helpers. Select paired designs with canonical IDs such as `editor`, `gruvbox`, or `ayu` and `theme-appearance: "light"` or `"dark"`; concrete IDs such as `editor-dark` keep their fixed appearance. See [Choose a Theme](#choose-a-theme) for selection and precedence rules.

SVG rendering now defaults to **14,100,000 layout work units**, retaining the other constrained ceilings. Explicit finite `resources.limits.max_layout_work_units` values can lower or raise that allowance; an explicit `constrained` profile retains **125,000** unless overridden. See [renderer parameters](#mermaidsource-) for raw options and profiles. [Issue #300](https://github.com/Latias94/merman/issues/300)

Mermaid advances from `12.1.0` to `12.3.0`, and ELK advances to `0.12.1`. Review geometry, label wrapping, typography, and document snapshots. Flowchart Step groups and badges render statically in Typst. ELK defaults and Dagre selection already shipped in `0.4.0`; see [Choose a Layout](#choose-a-layout) to keep an explicit layout choice.

## Upgrading from 0.4.0

The published `0.5.0` package bundles Merman `0.9.0`, retaining plugin ABI `2`, options schema `2`, and minimum Typst `0.15.0`. It improves Unicode line breaking, Markdown code/escaped markup, hollow relationship markers, and Block metadata. SVG backgrounds are transparent; pass `background: "white"` for opaque artwork. See the [package changelog](CHANGELOG.md#050---2026-10-13) for the corresponding fixes and PRs.

When upgrading directly from `0.4.0` to `0.6.0`, also apply the [0.5.0 to 0.6.0 migration](#upgrading-from-050) above.

## Earlier 0.3.0 to 0.4.0 migration

- The bundled renderer moves from Merman `0.8.0-alpha.6` to stable `0.8.0`, targeting Mermaid `12.1.0`. Agentflow and Usecase join the supported diagram families.
- Mermaid 12.0 changed layout and appearance defaults, and this package targets Mermaid 12.1. Flowchart, State, Class, ER, Requirement, Usecase, and Agentflow default to ELK; supported families adopt Redux/Neo presentation. Review existing diagrams for changed geometry, colors, and spacing. To request Dagre with the earlier theme and look, use `site-config: (layout: "dagre", theme: "default", look: "classic")`; this does not promise identical historical output.
- Replace family-local `defaultRenderer` settings with top-level `layout`. The Typst diagnostic analysis payload remains at schema `1`; analysis facts elsewhere in Merman use schema `2`. The operation result envelope, binding options schema, and Typst plugin ABI have separate versions.
- Embedded images still default to `resvg-safe`. Mathematical labels remain unsupported: this package does not include the `math` feature. `math-renderer: "ratex"` reports a missing capability.

The `0.4.0` release keeps the previous wrapper entry points. Layout uses deterministic Unicode-aware text measurement; it does not measure Typst's actual glyphs. See the [Merman 0.8.0 upgrade guide](https://github.com/Latias94/merman/blob/v0.8.0/docs/release/V070_TO_V080_UPGRADE_GUIDE.md) for renderer details.

## Examples

- [basic.typ](examples/basic.typ): minimal `#mermaid(...)` usage.
- [dagre.typ](examples/dagre.typ): use Dagre for individual diagrams and Mermaid raw blocks through a shared profile.
- [document-context.typ](examples/document-context.typ): opt-in document typography and width bridging.
- [elk.typ](examples/elk.typ): Mermaid's `layout: elk` frontmatter and the bundled ELK backend.
- [profile.typ](examples/profile.typ): reusable renderer settings shared by direct calls and raw blocks.
- [figure.typ](examples/figure.typ): Mermaid diagrams wrapped as Typst figures with reusable layout defaults.
- [raw-block.typ](examples/raw-block.typ): document-wide Mermaid fences with `show-mermaid-blocks`.
- [options.typ](examples/options.typ): themes, stable IDs, `mermaid-result`, SVG export, and placeholder errors.
- [print.typ](examples/print.typ): print-friendly white-background output.
- [presentation.typ](examples/presentation.typ): dark slide-sized output using a compiled theme preset.
- [svg-export.typ](examples/svg-export.typ): raw SVG and structured render payloads.
- [theme-authoring.typ](examples/theme-authoring.typ): materialize a shared design, inspect support, and copy an editable preset recipe.

Package fixtures are grouped by behavior family under [tests](https://github.com/Latias94/merman/tree/main/distribution/typst/merman/tests): API, option normalization, render environments, context, errors, figures, raw blocks, README examples, historical issues, and visual smoke coverage. These links point to the source repository because examples and tests are not included in the published Typst package.

## Choose a Layout

The `0.6.0` package includes both Dagre and ELK. Mermaid 12.0 made ELK the default for Flowchart, State, Class, ER, Requirement, Usecase, and Agentflow when ELK is available; other diagram families keep their own layout behavior. `flowchart LR` sets the direction, not the layout algorithm.

To use Dagre for one diagram, pass Mermaid site configuration. This does not require rebuilding the plugin:

```typst
#mermaid(
  "flowchart LR\n  Source --> Layout\n  Layout --> SVG",
  site-config: (layout: "dagre"),
)
```

To use Dagre throughout a document, reuse a profile for direct calls and Mermaid raw blocks:

```typst
#import "@preview/merman:0.6.0": mermaid, mermaid-profile, show-mermaid-blocks

#let dagre = mermaid-profile(site-config: (layout: "dagre"))
#show raw.where(lang: "mermaid"): show-mermaid-blocks(profile: dagre)

#mermaid("flowchart LR\n  Source --> Layout", profile: dagre)
```

If a call also passes `site-config`, that dictionary replaces the profile's entire `site-config`; include `layout: "dagre"` in the direct dictionary to keep Dagre.

To also request the earlier appearance, add `theme: "default", look: "classic"` to the `site-config` dictionary. This does not guarantee pixel-identical output. To select ELK explicitly for one diagram, use Mermaid frontmatter:

```typst
#mermaid("---\nconfig:\n  layout: elk\n---\nflowchart LR\n  Source --> Layout\n  Layout --> SVG\n")
```

Use `site-config: (layout: "dagre")` to choose the Mermaid layout algorithm. The wrapper's top-level `layout:` parameter is a different setting for container geometry (such as `container_width`); it does not select Dagre or ELK. Choosing Dagre at runtime does not remove ELK from the bundled WASM.

ELK is an embedded, modified Rust translation of Eclipse ELK. The wrapper and Merman-authored code remain under `MIT OR Apache-2.0`; the ELK-derived portion is under `EPL-2.0`. This is a component-level license boundary, not a relicensing of the whole package. When redistributing the package or a derivative artifact, preserve `THIRD_PARTY_NOTICES.md` and the matching files under `THIRD_PARTY_LICENSES/`.

## Choose a Theme

Package `0.6.0` provides compiled theme selection through its bundled ABI 3 plugin.

Select a built-in design directly, or choose one appearance of a paired design:

```typst
#mermaid(source, theme-preset: "paper-cut", width: 100%)
#mermaid(
  source,
  theme-preset: "editor",
  theme-appearance: "dark",
  document-context: true,
  width: 100%,
)
```

The built-in catalog groups 11 designs with 14 concrete appearances:

| Preset ID | Appearances | Default |
| --- | --- | --- |
| `editor`, `gruvbox`, `ayu` | `light`, `dark` | `light` |
| `one-dark`, `cyberpunk` | `dark` | `dark` |
| `brutalist`, `spotless`, `ghibli`, `paper-cut`, `carbon-copy`, `pop-art` | `light` | `light` |

Use `theme-catalog()` to discover the installed plugin's IDs, declared modes, availability, and `concrete_preset_id` values. An omitted appearance uses the selected design's default; an explicitly unavailable mode fails. The plugin does not detect the viewer's color mode. Paper Cut, Carbon Copy, and Pop Art are Light-only designs.

`theme-preset`, `theme-recipe`, and `diagram-theme` are alternative complete sources. Select at
most one in a profile and at most one at the call site. A direct source replaces the profile's
source **and its appearance**. A direct `theme-appearance` without a new source changes the mode
of the profile's selection. A complete `diagram-theme` spec is already concrete and cannot take
an appearance selector. These rules also apply to figures, SVG/results, and raw-block handlers.

Use `theme-recipe: json("custom.theme.json")` for an editable configuration saved from Playground
or exported with `export-theme-preset`. See [Theme authoring](#theme-authoring) for viewing,
copying, and editing the complete JSON without converting it into a private format.

## Document Fonts

`mermaid(...)` is explicit-only by default. It does not automatically inherit the surrounding Typst font, text size, or container width.

Pass `document-context: true` to content-rendering APIs when you want opt-in document context bridging. This forwards the current Typst text font, text size, and available width as renderer options unless you override them directly.

```typst
#mermaid(source, document-context: true, width: 100%)

#show raw.where(lang: "mermaid"): show-mermaid-blocks(
  document-context: true,
  width: 100%,
)
```

You can also pass typography intent explicitly:

```typst
#mermaid(
  source,
  typography: (
    font: ("Source Sans 3", "Arial", "sans-serif"),
    size: "16px",
  ),
)
```

The typography size accepts CSS `px` strings, absolute Typst lengths, or numeric CSS pixels. Typst lengths are converted through the SVG 96-DPI coordinate system (`72pt == 96px`) so layout measurement and SVG output use the same numeric `font_size_px`. Typst font descriptors are projected to their ordered family names in `theme.spec.typography.default.font_stack`; descriptor `covers` constraints have no CSS or deterministic-measurer equivalent and are therefore not preserved.

This changes the SVG style intent sent to the headless renderer. It does not mean the Typst plugin measured the exact Typst font file. The Typst plugin uses the built-in `deterministic` measurer; browser-style host callbacks and Typst font-asset measurement are not available through this transport. Other transports may install a host callback when the final display stack is authoritative.

Both `theme-preset` and `theme-recipe` compose with `typography` and `document-context: true`.
When needed, the wrapper uses the shared public materializer before applying the default text
style. The overlay changes `typography.default`; explicitly authored family fonts and role sizes
or weights still take precedence. For example, the three art designs retain their family fonts.
Edit their shared font tokens when you want to change those fonts throughout the recipe.

Check the compiled plugin capability surface with:

```typst
#let capabilities = merman-capabilities()
#capabilities.capabilities.text_measurement
```

## Profiles

Use `mermaid-profile(...)` for reusable diagram settings:

```typst
#let diagrams = mermaid-profile(
  typography: (
    font: ("Source Sans 3", "Arial", "sans-serif"),
    size: "16px",
  ),
  background: "#ffffff",
  theme-name: "base",
  figure: (
    placement: bottom,
    scope: "parent",
    caption-position: top,
    gap: 1em,
    outlined: false,
  ),
)

#mermaid(source, profile: diagrams, width: 100%)
#mermaid-figure(source, profile: diagrams, caption: [System flow], width: 100%)
```

Profiles work with `mermaid(...)`, `mermaid-figure(...)`, `mermaid-svg(...)`, `mermaid-result(...)`, `analyze-mermaid(...)`, and raw-block show rules. The optional `figure` section is consumed only by `mermaid-figure(...)`; it does not change raw SVG rendering or non-figure image calls.

For normal documents, start with `width`, `theme-preset` or `theme-recipe`, optional `theme-appearance`, `background`, `typography`, `document-context`, and reusable `profile` values. Use `diagram-theme` for a concrete spec and `theme-name`/`theme-variables` for Mermaid configuration. Lower-level renderer fields remain available for parity debugging or deterministic fixture control.

`base-theme` is a lower-priority compatibility alias for `theme-name`; prefer `theme-name` in new documents. When both are supplied, `theme-name` wins.

Raw `options` always wins. Without it, precedence is field-specific and deterministic:

- site config: profile full object, profile `theme-name`/`theme-variables`, direct full object, direct `theme-name`/`theme-variables`;
- environment: profile full object, profile measurement/math shorthands, direct full object, direct measurement/math shorthands;
- compiled diagram theme: direct `diagram-theme`/`theme-preset`/`theme-recipe` replaces the profile source and its appearance; without a direct source, direct `theme-appearance` overrides the profile mode;
- typography: document context, profile typography, and direct typography merge into `theme.spec.typography.default` in that order, preserving authored family and role overrides;
- layout: profile layout followed by container shorthands, unless a direct full `layout` object is present, in which case that object replaces the layout shorthands;
- scalar fields: direct value, profile value, package or renderer default.

`theme-name` and `theme-variables` replace the Mermaid `theme` or `themeVariables` field at their layer; they do not deep-merge individual theme-variable keys. They do not select a compiled Merman preset or its appearance.

A direct `site-config` object replaces the profile `site-config` object; use the direct `theme-name` and `theme-variables` shorthands when you want the documented theme-layer precedence instead of replacing the full object.

A profile that contains raw `options` is an opaque binding-options bundle: it bypasses the profile and call-site shorthands. Pass a direct raw `options` dictionary to replace that bundle, or use the structured profile fields when you want field-level overrides.

## Raw Blocks

Use `show-mermaid-blocks` with Typst's `raw.where` selector:

````typst
#import "@preview/merman:0.6.0": show-mermaid-blocks

#show raw.where(lang: "mermaid"): show-mermaid-blocks(width: 100%)

```mermaid
flowchart LR
  Source --> Typst
  Typst --> SVG
```
````

Raw-block show rules default to `error-mode: "placeholder"`, so one invalid fence stays visible as a marked block instead of aborting the whole document. Pass `error-mode: "panic"` when a document-wide rule must fail the compile on the first render error.

Avoid setting a fixed `id` in a document-wide raw-block show rule unless the document has only one Mermaid block; otherwise multiple diagrams will share the same SVG id.

For document-context-aware rendering, pass `document-context: true`. This reads the current Typst text font, text size, and container width inside `context`, then forwards them to the renderer.

```typst
#import "@preview/merman:0.6.0": show-mermaid-blocks

#show raw.where(lang: "mermaid"): show-mermaid-blocks(
  document-context: true,
  width: 100%,
)
```

## API Migration

For documents using the older compatibility context helpers, use the `document-context` parameter:

```typst
// Old:
#mermaid-context(source, width: 100%)
#show raw.where(lang: "mermaid"): show-mermaid-blocks-context(width: 100%)

// New:
#mermaid(source, document-context: true, width: 100%)
#show raw.where(lang: "mermaid"): show-mermaid-blocks(
  document-context: true,
  width: 100%,
)
```

`context` is a Typst keyword, so the public parameter is named `document-context`.

Measurement and math selection continue to use the render environment in binding options schema `3`:

```typst
#mermaid(source, text-measurement: "deterministic", math-renderer: "none")
#mermaid(
  source,
  environment: (
    text_measurement: "deterministic",
    math_renderer: "none",
  ),
)
```

The removed layout fields are rejected; they are not translated through a compatibility path.

The presentation aggregate from `0.5.0` is removed in `0.6.0`; migrate its inputs to a compiled theme:

```typst
// Old and rejected:
#mermaid(source, presentation-profile: "merman-modern")
#mermaid(source, host-theme: (appearance: "dark"))

// Select a compiled diagram theme:
#mermaid(source, theme-preset: "ayu-dark")

// Or provide one complete DiagramThemeSpec body:
#mermaid(
  source,
  diagram-theme: (
    typography: (
      default: (font_stack: ("Inter", "Arial"), font_size_px: 16),
    ),
  ),
)
```

The old Typst `theme` shorthand for Mermaid variables is now named `theme-variables`. `theme-name` still selects Mermaid's own theme through `site_config.theme`; neither field selects a compiled Merman diagram theme.

## API

### `mermaid(source, ..)`

Renders a Mermaid string or raw block as an SVG image.

Common parameters:

- `width`, `height`, `fit`, `alt`: forwarded to Typst's `image`.
- `scale`: wraps the rendered image with Typst `scale`; accepts ratios such as `120%` or numbers such as `1.2`.
- `document-context`: `false` by default. Set to `true` to inherit Typst text font, text size, and finite available width for image rendering. An auto-width page reports an infinite outer width, so Merman keeps its renderer default instead of serializing infinity.
- `profile`: reusable options produced by `mermaid-profile(...)`.
- `typography`: high-level font and size intent projected to `theme.spec.typography.default`.
- `theme-preset`: built-in Merman design, such as `"paper-cut"` or paired `"editor"`; concrete IDs such as `"editor-dark"` remain supported.
- `theme-recipe`: complete editable `ThemeRecipeV1` dictionary, for example `json("custom.theme.json")` or the result of `export-theme-preset(...)`.
- `theme-appearance`: optional `"light"` or `"dark"` selector for a preset or recipe; omitted uses the declared default. Automatic modes are not accepted.
- `diagram-theme`: one complete `DiagramThemeSpec` body, wrapped as top-level `theme.spec`.
- `id`: stable SVG root id. `diagram-id` is the lower-level binding name; precedence is direct `diagram-id`, direct `id`, profile `diagram-id`, then profile `id`.
- `background`: SVG root background color, mapped to `svg.root_background_color`.
- `theme-name`: Mermaid theme name, such as `"base"` or `"dark"`.
- `theme-variables`: Mermaid `themeVariables`.
- `error-mode`: `"panic"` by default. Use `"placeholder"` or `"text"` to show diagram errors in the document instead of failing the Typst compile. These modes handle structured errors returned by `merman`; missing wasm files, Typst plugin loading failures, invalid `error-mode` values, and SVG image decoding failures still fail the Typst compile.

This entry point is explicit-only unless `document-context: true` is set.

Advanced renderer parameters:

- `pipeline`: `"resvg-safe"` by default for embedded Typst images. Use `"parity"` when you need Mermaid-like SVG DOM output, or `"readable"` for inline SVG inspection.
- `site-config`: bounded Mermaid site config object. General bindings reject host-owned `themeCSS` and `secure`; use the typed theme inputs for appearance instead.
- `layout`: full binding layout object for container geometry. This overrides the container shorthands.
- `container-width`, `container-height`: shorthands for `layout.container_width` and `layout.container_height`.
- `environment`: full binding render-environment object. Use `text_measurement` and `math_renderer` fields when composing options directly.
- `text-measurement`, `math-renderer`: shorthands for `environment.text_measurement` and `environment.math_renderer`. Direct values override `environment`, which overrides profile environment values.
- `drop-native-duplicate-fallbacks`: SVG post-processing shorthand for removing duplicate native fallback text.
- `fixed-today`, `fixed-local-offset-minutes`: deterministic date controls for date-sensitive diagrams.
- `options`: escape hatch; when present, it supplies the Rust binding options and overrides shorthand parameters. It does not bypass general binding validation: `svg.scoped_css`, `svg.scopedCss`, `svg.css_override_policy`, and `svg.cssOverridePolicy` remain rejected because raw CSS and cascade policy belong to trusted Rust or native CLI hosts. The plugin applies the resource policy described below.

SVG rendering in `0.6.0` defaults to **14,100,000 layout work units**, taking the allowance from the shared `interactive` contract while retaining `constrained` as the base profile. Analysis and theme operations retain their ordinary constrained defaults.

An omitted or null `resources.profile` inherits this Typst default. Explicitly selecting `resources.profile` as `"constrained"` keeps the shared profile's **125,000** layout work units unless overridden. An explicit finite positive integer in `resources.limits.max_layout_work_units` takes precedence in either case and can tighten or raise the allowance.

```typst
#let layout-options = (
  resources: (limits: (max_layout_work_units: 20000000)),
)
#mermaid(read("diagram.mmd"), options: layout-options)

#let layout-profile = mermaid-profile(options: layout-options)
#mermaid(read("diagram.mmd"), profile: layout-profile)
```

Work units accumulate across iterations, including Mindmap's COSE layout. The 20,000,000-unit override above illustrates raising the default allowance; it is an example, not a measured total or a required value. A failure's `actual` value reports the first rejected charge, not the diagram's total cost. Zero, negative, fractional, null, and overflowing layout limit values are rejected.

Other limits may only be tightened. Looser profiles, unknown IDs, and hard-cap overrides remain rejected. Resources may be direct or inside one `analysis` or `merman` object wrapper. Theme preflight and options byte admission remain constrained.

Raw `options` bypasses shorthand generation; direct `options` replaces profile `options`. Include required theme and SVG settings in the same bundle.

Typst does not expose the removed `scoped-css` or `css-override-policy` high-level controls. Use `diagram-theme`, `theme-variables`, or `background` for document-owned presentation needs.

Use `typography` for Typst-facing font intent: it accepts Typst font descriptors, absolute Typst lengths, and numeric or string CSS pixels. It is projected into the typed `theme.spec.typography.default` object rather than a raw CSS or host-theme escape hatch.

### `mermaid-profile(..)`

Returns a reusable Typst settings dictionary. Profiles normalize into the same binding options used by direct parameters, so they do not create a second rendering path. The removed `presentation-profile`, `host-theme`, `merman-modern`, `scoped-css`, and `css-override-policy` inputs are not compatibility aliases; handwritten dictionaries using a removed field fail with a migration diagnostic.

### `mermaid-figure(source, ..)`

Renders a Mermaid diagram and wraps it in a Typst `figure`.

Use `document-context: true` when the figure should opt into the same document-context bridge as `mermaid(...)`.

Figure layout parameters are forwarded to Typst's native `figure`: `placement`, `scope`, `supplement`, `numbering`, `gap`, and `outlined`. Use `caption-position` and `caption-separator` when you need a top caption or document-specific caption separator. Direct figure parameters override `profile.figure` defaults.

### `mermaid-svg(source, ..)`

Returns the rendered SVG as a string instead of embedding it as an image.

This value-returning API does not enter Typst `context`; pass `typography`, a theme source and optional `theme-appearance`, `layout`, or `container-width` explicitly when exporting SVG text. Rendering failures panic; use `mermaid-result(...)` when the document needs programmatic error handling.

### `mermaid-result(source, ..)`

Returns a structured render payload:

```typst
#let result = mermaid-result("flowchart TD\nA --> B")
#if result.ok {
  result.svg
} else {
  result.message
}
```

The result also includes `operation`, `kind`, and `capability_id`. On failure, these fields let callers distinguish a missing compiled capability from invalid input or a general render error without parsing `message`.
Resource-limit failures additionally expose `details.resource` with the stable limit id, profile, and actual/max values.

### `analyze-mermaid(source, ..)`

Returns the canonical diagnostic analysis schema 1 payload produced by the Rust bindings:

```typst
#let analysis = analyze-mermaid("flowchart TD\nA --> B")
#analysis.version
#analysis.valid
#analysis.summary.errors
#analysis.diagnostics
```

### Theme authoring

`materialize-theme`, `describe-theme-support`, and `export-theme-preset` are thin projections of
the shared Rust-owned theme operations. The Typst wrapper encodes inputs and unwraps successful
results; it does not expand tokens or infer support locally.
`mermaid-theme-definition` composes materialization and rendering in one call, so a document can
render a shared design without manually carrying an intermediate complete spec.
Like `mermaid`, it accepts `document-context: true` when the rendered diagram should inherit the
current Typst text style and available width.

Theme authoring and presets remain Alpha. Their presence in Typst plugin ABI 3 makes the callable transport explicit; it is not a stability commitment for the theme authoring payloads.

```typst
#let definition = (
  tokens: (
    canvas: (type: "color", value: "#0f172a"),
    text: (type: "color", value: "#e5e7eb"),
    accent: (type: "color", value: "#38bdf8"),
  ),
  canvas: (base: (kind: "solid", color: (ref: "canvas"))),
  styles: (
    text: (fill: (kind: "solid", color: (ref: "text"))),
    node: (
      fill: (kind: "solid", color: (ref: "canvas")),
      stroke: (paint: (kind: "solid", color: (ref: "accent"))),
    ),
    edge: (stroke: (paint: (kind: "solid", color: (ref: "accent")))),
  ),
)
#let materialized = materialize-theme(definition)
#mermaid-theme-definition(
  "flowchart LR\nA --> B",
  definition,
  document-context: true,
  width: 80%,
)
#let support = describe-theme-support((
  schema_version: 1,
  family: "sequence",
  output: "standalone-svg",
  subject: (kind: "base-typography", property: "font-stack"),
))
#let preset = export-theme-preset("editor-dark")
```

Preset export returns one complete editable `ThemeRecipeV1`. For a paired design, its shared
values and `appearances`/`default_appearance` live inside `design`. Save that complete recipe;
a materialized `spec` retains only one concrete appearance. Ordinary rendering accepts the
exported dictionary directly:

```typst
#let recipe = export-theme-preset("editor")
#mermaid(source, theme-recipe: recipe, theme-appearance: "dark", document-context: true)
```

To view and copy every setting, display the complete JSON in the document, then save the text as
`custom.theme.json`. `json.encode` returns text; it does not write a file:

```typst
#let recipe = export-theme-preset("paper-cut")
#let recipe-json = json.encode(recipe, pretty: true)
#raw(recipe-json, lang: "json", block: true)

// In another document, load the saved file directly.
#let custom = json("custom.theme.json")
#mermaid(source, theme-recipe: custom)
```

Edit a shared token to update all its retained references. For Paper Cut, this changes the
default and family font stacks together without erasing other typography:

```typst
#let recipe = export-theme-preset("paper-cut")
#let tokens = recipe.design.tokens
#let body-font = tokens.at("body-font")
#body-font.insert("value", ("Source Sans 3", "Arial", "sans-serif"))
#tokens.insert("body-font", body-font)
#let design = recipe.design
#design.insert("tokens", tokens)
#recipe.insert("design", design)
#mermaid(source, theme-recipe: recipe, document-context: true)
// View/copy the edited full configuration with raw(json.encode(recipe, pretty: true)).
```

Carbon Copy uses `record-font` and `chart-font`; Pop Art uses `typeface` and `display-typeface`.
Edit both when you intend one font throughout those designs. Font names do not embed or install
fonts. The [theme-authoring example](examples/theme-authoring.typ) demonstrates the full JSON
round trip and includes a switch to display the exported configuration.

For inspection or explicit authoring-to-render requests, the same wrapper accepts schema-1 actions:

```typst
#let recipe = export-theme-preset("editor")
#let inspection = materialize-theme((schema_version: 1, action: "inspect", recipe: recipe))
#let dark-request = (
  schema_version: 1, action: "materialize", recipe: recipe, appearance: "dark",
)
#mermaid-theme-definition("flowchart LR\nA --> B", dark-request, width: 80%)
```

`materialize-theme` accepts a raw design or an action request containing a recipe; pass a
standalone portable recipe through `theme-recipe`, or wrap it in the action above. For original
downloaded JSON admission, preserve its text in the request rather than parsing it first:

```typst
#let saved-json = read("custom.theme.json")
#let request-json = "{\"schema_version\":1,\"action\":\"materialize\",\"recipe\":" + saved-json + "}"
#mermaid-theme-definition(source, request-json, document-context: true)
```

An omitted selector uses the declared default. An explicit unavailable appearance fails.
Resolve host appearance preferences before choosing `light` or `dark`; the plugin does not
detect the document viewer's color mode.

Each function returns the canonical result dictionary on success. On failure it returns the same
structured operation envelope used by rendering, including `ok`, `code_name`, `kind`, `message`,
and an optional `capability_id`. Theme-authoring operations retain constrained limits; caller
options may tighten those limits. SVG rendering uses the separate layout allowance described
under [renderer parameters](#mermaidsource-), with the remaining ceilings still constrained.

When ordinary rendering needs materialization, `mermaid-result` preserves the authoring error's
operation and full `details` and adds `svg: none`. Content calls honor their selected error mode
for these failures. Theme selection/argument validation can still panic before a plugin call.
Successful render results contain SVG, not a per-render theme execution report. Catalog
availability and support queries do not prove every effect rendered in a particular Typst PDF.

Invalid Mermaid source remains a schema-1 analysis payload with `valid: false`; transport, options, and missing-capability failures use the structured operation envelope instead.

### `theme-catalog()` (Alpha)

Returns the shared theme catalog for the installed plugin, including available presets, semantic
selectors, supported outputs, and effective constrained theme resource limits. The catalog remains
Alpha. Each preset groups `supported_appearances`, `default_appearance`, and `appearances`.
Family guidance, swatches, `qualified_cells`, and the exact `concrete_preset_id` live in each
appearance entry. Availability admits the entire design, including inactive modes; an available
appearance with empty qualification cells has no qualified artifact scope.

```typst
#let catalog = theme-catalog()
#let preset = export-theme-preset(catalog.presets.at(0).id)
```

Success returns theme catalog schema 1. This version is independent of plugin ABI 3, Options JSON
schema 3, and operation envelope schema 1. Failure returns the structured operation envelope with
operation `theme-catalog`. Discovery takes no options and describes the plugin's fixed default ceiling;
individual authoring calls may tighten that ceiling.

### `merman-capabilities()`

Returns the compiled plugin capability payload, including the current text measurement boundary:

```typst
#let capabilities = merman-capabilities()
#capabilities.capabilities.text_measurement.provider_ids
```

The flat catalog reports the artifact's capability, output, operation, registry, and resource sets. Shared profile capacities remain unchanged, including the `constrained` layout value of 125,000. Typst's effective default combines that base profile with the shared `interactive` layout allowance; explicit profile and limit selections follow the rules above. Other ceilings remain enforced. The options root and any `analysis` or `merman` wrapper must be objects; malformed or mixed wrappers return structured options errors.

### `show-mermaid-blocks(..)`

Returns a raw block show handler. This is the shortest way to enable Mermaid fences across a Typst document:

```typst
#show raw.where(lang: "mermaid"): show-mermaid-blocks(width: 100%)
```

## Development

The Typst package uses its own version track and is not locked to the Rust crate version. The embedded WebAssembly plugin also has a separate ABI version, documented in the Version Mapping table, for exported function and payload compatibility.

Build the publish Typst package locally:

```sh
cargo run --locked -p xtask -- build-typst-package --profile publish
```

The release build requires `wasm-tools` and Binaryen `wasm-opt version 133`. The package builder applies a pinned `wasm-opt -Oz` pass before stripping custom sections and records both tool versions in the artifact manifest.

The package is written to:

```sh
dist/typst/merman/0.6.0
```

The source package carries the examples shown above so they remain readable in the package review. `typst.toml` excludes `examples/**` from the runtime download; tests stay in the Merman source repository and are not bundled.

For a manual local install, copy that directory to `<package-root>/preview/merman/0.6.0` and pass the parent directory to Typst:

```text
<package-root>/preview/merman/0.6.0/typst.toml
<package-root>/preview/merman/0.6.0/lib.typ
<package-root>/preview/merman/0.6.0/merman_typst_plugin.wasm
```

```sh
typst compile --package-path <package-root> document.typ
```

The `typst-package-smoke` command creates this preview layout automatically in a temporary directory.

For local `@preview` smoke tests, copy the built package under a preview namespace package path and compile with `--package-path`:

```sh
cargo run --locked -p xtask -- typst-package-smoke --profile publish --skip-wasm-build
```

Use an explicit Typst binary when the CLI is downloaded outside `PATH`:

```sh
cargo run --locked -p xtask -- typst-package-smoke --profile publish --skip-wasm-build --typst /path/to/typst
```

Each smoke run owns an independent temporary directory under `target/typst-package-smoke/`. Positive fixtures preserve their nested output paths, and `tests/compile-fail/` fixtures must fail with the diagnostic declared by their adjacent `.error.txt` file. Successful runs remove their artifacts by default; pass `--keep-artifacts` to retain the run directory for inspection.

The build verifies artifact-recipe provenance from its private build directory, then stages only the
runtime wrapper, WASM, examples, and legal materials. The transaction snapshots source bytes,
verifies the complete file shape and contents, and rechecks live source identity immediately before
atomically replacing the version directory; build receipts are not included in the published package.

The sole package profile, `publish`, enables SVG rendering, analysis, the complete Mermaid language catalog, and the Cytoscape and ELK layout backends. There are no alternate bridge-only or SVG-only package profiles. ASCII, PNG, JPEG, and PDF are not compiled because this wrapper exposes no operation for those outputs. Maintainer experiments use direct Cargo features and do not create another package identity or release recipe.

## Current Limits

- Output is SVG embedded through Typst `image`; diagrams are not Typst-native vector elements.
- Font family and size can be forwarded as style intent, but exact Typst font glyph measurement is not automatic.
- RaTeX math rendering is not available in the Typst plugin. Its current upstream closure depends on browser system-font discovery; the capability will remain closed until a zero-browser-import implementation passes admission.
- Browser-only Mermaid interactions such as script callbacks and popup behavior are not expected to work in static Typst output.
- The minimum supported compiler is Typst 0.15.0. Typst 0.15 HTML export remains experimental and is not a package promise here.
- The `readable` and `parity` pipelines can embed SVG structures that Typst warns about; `resvg-safe` is the intended embedded-image path for package output.

## License

The wrapper and Merman-authored code are available under either MIT or Apache-2.0. The embedded ELK-derived implementation is a separate component under EPL-2.0; it does not relicense the rest of the package. `THIRD_PARTY_NOTICES.md` records the exact source revision, relationship, and scope for ELK and the other embedded or translated components, while `THIRD_PARTY_LICENSES/` contains their applicable legal files. Preserve these materials when redistributing the package or a derivative artifact.

The machine-readable Cargo dependency report remains in the source repository's release evidence instead of being duplicated in the downloaded Typst package.
