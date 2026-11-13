# Pele 1.12.0 compatibility

`pele_rs` 0.3.0 implements the synchronous engine at upstream commit
[`36e584d59152181927e0d8bf70fddcd2a5f33d6c`](https://github.com/obsidianmd/pele/tree/36e584d59152181927e0d8bf70fddcd2a5f33d6c).
Compatibility compares complete SVG bytes, numeric dimensions, canonical types, Mermaid
aliases, link metadata, parse results, and structured diagnostics for identical source,
configuration, text measurement, assets, timestamp and timezone. `info` reports the pinned
upstream compatibility version.

## Diagram coverage

| Family | Canonical types |
| --- | --- |
| Flow and charts | `flowchart`, `pie`, `info`, `packet`, `quadrantChart`, `radar`, `xychart`, `cynefin` |
| Structured layouts | `mindmap`, `kanban`, `treemap`, `treeView`, `timeline`, `journey`, `ishikawa`, `eventmodeling`, `wardley` |
| Graphs | `er`, `class`, `state`, `requirement`, `usecase`, `architecture`, `c4`, `block`, `agentflow`, `swimlane` |
| Specialized engines | `sequence`, `gantt`, `gitGraph`, `sankey`, `venn`, `railroad` |

Detection retains all original headers, including `graph`, `flowchart-elk`, class/state
variants, all five C4 headers, and the default/EBNF/ABNF/PEG railroad grammars. The canonical
type and Mermaid alias remain separate in results, parsed models and errors. Configuration
sections retain `xychart → xyChart` and `wardley → wardley-beta`. Agentflow and event modeling
preserve comments through preprocessing.

Browser mounting, DOM measurement, zoom, and JavaScript lazy loading are outside this native
synchronous contract. The Typst layer resolves CSS variables and colors into SVG attributes;
its output is compared with native SVG after the same inlining step.

## Rust API

```rust
use pele_rs::{parse, render_parsed, ParseOptions, RenderOptions, Renderer};

let model = parse("sequenceDiagram\n A->>B: Hello", &ParseOptions::default())?;
let normal = render_parsed(&model, &RenderOptions::default())?;
let narrow = render_parsed(&model, &RenderOptions {
    max_width: Some(320.0),
    ..Default::default()
})?;

let mut selected = Renderer::empty();
selected.register_builtin("sequence");
assert!(selected.registered("sequence"));
# Ok::<(), pele_rs::PeleError>(())
```

`render`, `render_with`, `detect_type` and `supports` remain available. `try_detect_type`
reports preprocessing errors; `detect_type` returns `None` on those errors. `parse`,
`render_parsed` and `render_parsed_with` expose reusable typed `DiagramModel` values.
`ParsedDiagram` retains merged configuration, canonical type, alias and the original handler.
Changing registry entries does not change an existing parsed model. Rendering that model
ignores `config`, `limit` and `max_edges`, which only apply during parsing.

Rust strings contain well-formed Unicode. If a JavaScript diagnostic contains an unpaired
UTF-16 surrogate, `PeleError.message` uses the replacement character and `message_utf16`
retains the exact original code units. The oracle checks both representations and preserves
UTF-16 source positions; these diagnostics are not excluded from parity checks.

`Renderer::default()` registers every built-in type. `empty`, `register_builtin`, `register`
and `registered` support selective registration and custom `Diagram` implementations. Free
functions always use the complete registry. Icon/math caches and measurement contexts belong
to an individual render, including nested and concurrent renders.

`IconResolver` and `MathResolver` wrap cloneable callbacks. Icon callbacks receive decoded
names and return SVG content for a 24×24 viewport. Math callbacks receive decoded TeX and
font size and return `MathMarkup::Svg` or `MathMarkup::Html` with positive finite dimensions.
Missing or invalid math falls back to the original text. Resolver calls follow upstream's
cached layout probes and direct icon drawing calls.

Native Gantt defaults to the current time and system-local timezone. `now` overrides the
clock in Unix milliseconds; `time_zone` accepts an IANA timezone. Calendar behavior preserves
JavaScript normalization, DST ambiguity/gaps, excluded days and the ECMAScript Date range.
Chrono and chrono-tz provide calendar/timezone primitives; WASM builds disable native clocks.

## Typst and JSON plugin contract

`mermaid` adds `now: none`, `time-zone: "UTC"`, `monospace: none`, `icons: (:)`, and `math: (:)`.
Gantt requires a finite explicit `now`, even when every task has an absolute date. This makes
the today marker and date defaults reproducible in sandboxed Typst builds.

The JSON ABI uses `now`, `timeZone`, `monospace`, `icons` and `math`. `monospace` is an array
drawn from `members`, `attributes`, `files`, `messages`; omission uses upstream defaults.
`icons` maps decoded names to SVG strings. `math` maps TeX strings to objects with `svg`,
`width` and `height`; dimensions are fixed pixels. HTML math payloads are rejected by this
interface. Rust callers retain both SVG and HTML callbacks. No typesetter is bundled.

SVG inlining supports both attribute quote styles, nested SVG, inherited colors, gradients,
markers, custom properties, `color-mix()` and `calc()`. Asset markup is preserved inside the
viewport specified by its contract.

## Reproducible verification

[`reference.json`](pele_rs/scripts/reference.json) records the revision, version, corpus name
mapping, metrics measurer, fixed timestamp `1768478400000` and UTC timezone. Regeneration fails
if the upstream revision, registry, expected corpus counts or committed outputs differ.
[`coverage.json`](pele_rs/tests/fixtures/coverage.json) records each type's counts, including
all 522 documentation examples and 239 agentflow reference examples.

The fixture suite checks complete SVG, dimensions, detection, aliases, links, resolver calls,
independent parse outcomes and errors including original-source UTF-16 positions/snippets.
Models are reused at default → 320 → 500 → default width. Dedicated tests cover configuration
precedence, handler replacement, resolver changes, reentrancy, concurrency, limits and deep
nesting. Agentflow additionally compares semantic models, metadata, mappings and raw tokens;
Gantt has 7,118 date/calendar/model cases across UTC and America/Los_Angeles.

`scripts/fuzz.ts` uses seed `0x70656c65` to compare deterministic mutations with the pinned
engine, minimizes differences, and retains their inputs under `scripts/regressions/` for
the regular oracle. `tests/plugin-parity.py` compares native inlined SVG with the actual Typst
WASM ABI for every type, representative aliases, themes, fonts, icons and SVG math.

Regenerate and check the fixtures with [Bun](https://bun.sh) from a checkout of the pinned
upstream commit:

```sh
bun pele_rs/scripts/fixtures.ts /path/to/pinned/pele --check
bun pele_rs/scripts/gantt-calendar.ts /path/to/pinned/pele --check
bun pele_rs/scripts/agentflow-model.ts /path/to/pinned/pele --check
cargo test --workspace
cargo build --workspace --examples
bun pele_rs/scripts/fuzz.ts /path/to/pinned/pele 40
python3 tests/plugin-parity.py --typst typst
```

Release checks are `cargo fmt --all --check`, native and WASM Clippy with warnings denied,
workspace tests, oracle regeneration checks, the plugin build, and package smoke/parity
checks using both the committed and rebuilt WASM on Typst 0.13 and latest. Upstream's MIT
notice is retained in both license files and accompanies the packaged WASM.
