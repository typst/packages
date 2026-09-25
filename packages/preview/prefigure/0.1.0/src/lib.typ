// PreFigure for Typst — public API.
//
// Typst drives the whole pipeline; the PreFigure core runs as a wasm plugin that
// does all geometry and label placement. The one thing the plugin cannot do is
// measure text (a plugin has no callback into Typst), so this file runs the
// metrics-injection handshake described in TYPST_PLUGIN_PLAN.md §4:
//
//   Pass A  plugin.extract_measurables(source) -> list of text runs to measure
//   Pass B  measure each run with Typst's own layout engine (measure.typ)
//   Pass C  plugin.build(source + metrics)      -> a complete SVG
//   Pass D  embed the SVG with image()
//
// Math is always rendered by Typst (each `<m>` converted with mitex) and overlaid
// as native content, so it matches the document's math font. A diagram that has
// any math is therefore drawn in native mode (text overlaid too, for one coherent
// pass); a math-free diagram can still bake its text into a self-contained SVG
// with `labels: "svg"` (the default). The shipped wasm has no math engine of its
// own — build.sh --with-math re-embeds RaTeX if a fully-baked SVG is wanted.

#import "fonts.typ": resolve-font-map
#import "measure.typ": measure-run
#import "native.typ": render-native
#import "measure.typ": measure-math
#import "@preview/xmlit:0.1.3": create-from-relaxng, xml-to-string

// Re-export the PreFigure element constructors as a submodule, so a diagram can
// be authored in native Typst syntax and handed straight to prefigure():
//   #import "@preview/prefigure:0.1.0": prefigure, tags
//   #prefigure(tags.diagram(…))
#import "tags.typ" // the module, re-exported as `tags`
#import "tags.typ": prefigure-handlers

#let _plugin = plugin("prefig_typst_plugin.wasm")

// RELAX NG validator for the PreFigure schema.
// Built lazily and memoised: the grammar is compiled once per document, and only
// when a `validate: true` call actually needs it (a validate:false-only document
// never loads it). Validates against pf_schema.rnc directly: every diagram a
// Typst document feeds in — read() of a `.xml` file, or a `tags.*` tree — is
// namespace-free, which is exactly what pf_schema.rnc accepts. (The pf_adapter.rnc
// wrapper additionally accepts the https://prefigure.org namespace for PreTeXt
// xi:inclusion, but it does so via `external "…" inherit = pf`, which the xmlit
// 0.1.3 validator plugin can't compile; that namespace case never arises here.)
#let _make-validator() = {
  create-from-relaxng(read("pf_schema.rnc")).utils.validate
}

// A validation result's errors (each `(message, snippet?)`) as a plain string,
// capped, for the `validate: "panic"` message.
#let _format-errors(errors) = {
  let msgs = errors.map(e => (
    "- "
      + e.message
      + (
        if e.at("snippet", default: none) != none { "\n" + e.snippet } else {
          ""
        }
      )
  ))
  let shown = msgs.slice(0, calc.min(msgs.len(), 5))
  (
    shown.join("\n")
      + (
        if msgs.len() > shown.len() {
          "\n…and " + str(msgs.len() - shown.len()) + " more error(s)"
        } else { "" }
      )
  )
}

// The same errors as a visible red callout, for `validate: true` (non-fatal):
// the diagram still renders and this block is shown beneath it.
#let _error-box(errors) = {
  let shown = errors.slice(0, calc.min(errors.len(), 5))
  block(
    width: 100%,
    above: 6pt,
    breakable: true,
    fill: rgb("#fff2f2"),
    stroke: 0.75pt + rgb("#cc0000"),
    radius: 3pt,
    inset: 8pt,
    {
      set text(fill: rgb("#a10000"), size: 0.85em)
      strong[⚠ PreFigure — input failed RELAX NG validation]
      text(size: 0.85em)[ (set `validate: false` to silence)]
      for e in shown {
        parbreak()
        [• #e.message]
        if e.at("snippet", default: none) != none {
          block(inset: (left: 1em, y: 2pt), raw(e.snippet, block: true))
        }
      }
      if errors.len() > shown.len() {
        parbreak()
        emph[…and #(errors.len() - shown.len()) more error(s)]
      }
    },
  )
}

// Nominal px size for native math, matching prefig-core's MATH_LABEL_SIZE.
#let _math-size = 14
// The `<m>` body xmlit writes for equation id "math-N" is wrapped ⟦math-N⟧.
#let _is-sentinel(body) = body.starts-with("⟦") and body.ends-with("⟧")
#let _sentinel-id(body) = body.replace("⟦", "").replace("⟧", "")

// Build a PreFigure diagram and return it as embeddable content.
//
//   source  the diagram, as any of:
//             * a PreFigure XML string — e.g. `read("diagram.xml")`;
//             * XML bytes — e.g. `read("diagram.xml", encoding: none)`;
//             * an xmlit tree — the result of the `tags.*` constructors (or any
//               xmlit tag functions / markup). It is serialized with
//               `xml-to-string(…, extract-math: true)`, so any `$…$` written in
//               the tree is carried across and drawn as native Typst math; no
//               separate `math-items` is needed.
//   width   passed to `image()`; `auto` keeps the SVG's own size, which Typst
//           reads at 96dpi (1px = 0.75pt), so a 300-unit diagram is 225pt.
//   fonts   per-document overrides of the generic→concrete font map (§4.1),
//           e.g. `(sans-serif: "Fira Sans")`.
//   labels  where text is rendered. "native" (the effective default when the
//           diagram has math) overlays live Typst text at PreFigure's positions
//           (selectable, in the document's fonts); "svg" bakes it into the SVG for
//           Typst's resvg to draw. Math is always overlaid natively, so any
//           diagram with math is drawn native regardless of this; "svg" only takes
//           effect for math-free diagrams (a self-contained SVG). See native.typ.
//   math-items  the equation table from xmlit's
//           `xml-to-string(…, extract-math: true)`, for a diagram *authored* in
//           Typst: each `<m>` sentinel is drawn from the authored `$…$` here.
//           When `source` is an xmlit tree this is filled in automatically (from
//           the tree's own `$…$`); pass it yourself only when handing in
//           pre-serialized sentinel XML. Non-sentinel `<m>` bodies (a figure's
//           own LaTeX, and math PreFigure generates) go through mitex either way,
//           so an existing LaTeX figure needs nothing — a plain `read()` renders
//           its math with Typst.
//   handlers  xmlit content handlers used when `source` is a tree (or markup),
//           defaulting to PreFigure's (`_…_` → `<it>`, `*…*` → `<b>`).
//   validate  check the serialized XML against the PreFigure RELAX NG schema:
//           `false` (default) skips the check; `true` renders the diagram and
//           shows any validation errors in a red callout beneath it (non-fatal);
//           `"panic"` makes an invalid diagram abort the compile instead.
//           CAVEAT: the schema is currently an imperfect oracle — it rejects many
//           engine-valid diagrams, and the validator itself crashes on some
//           nested-group diagrams (an uncatchable crash that aborts the compile
//           in `true`/`"panic"` mode). This is why validation is opt-in; see
//           SCHEMA_VALIDATION_REPORT.md.
//   format  "svg" (the only supported format here; tactile is out of scope).
//   ..image-args  forwarded to `image()` (alt, fit, height, …).
#let prefigure(
  source,
  width: auto,
  fonts: none,
  labels: "svg",
  math-items: (:),
  handlers: prefigure-handlers,
  validate: false,
  format: "svg",
  ..image-args,
) = {
  // Accept an xmlit tree or bytes in addition to an XML string. A tree is
  // serialized with math extraction so its authored `$…$` render as native
  // Typst math (merged under, so an explicit `math-items:` still wins on a
  // colliding id); bytes are decoded as UTF-8.
  assert(
    type(source) in (str, bytes, content, dictionary, array),
    message: "prefigure: source must be an XML string, bytes, or an xmlit tree "
      + "(content/dictionary/array), got "
      + str(type(source)),
  )
  if type(source) == bytes {
    source = str(source)
  } else if type(source) != str {
    let serialized = xml-to-string(
      source,
      extract-math: true,
      handlers: handlers,
    )
    source = serialized.xml
    math-items = serialized.math-items + math-items
  }
  assert(
    labels in ("svg", "native"),
    message: "prefigure: labels must be \"svg\" or \"native\"",
  )
  assert(
    format == "svg",
    message: "prefigure: format must be \"svg\" (got \"" + format + "\")",
  )

  // Validate the (serialized) XML against the PreFigure RELAX NG schema.
  //   validate: false   — skip.
  //   validate: "panic" — an invalid diagram aborts the compile with the errors.
  //   validate: true    — an invalid diagram still renders, with the errors shown
  //                       in a red callout beneath it (non-fatal, the default).
  // See SCHEMA_VALIDATION_REPORT.md for the schema's current limitations.
  assert(
    validate == true or validate == false or validate == "panic",
    message: "prefigure: validate must be true, false, or \"panic\" (got "
      + repr(validate)
      + ")",
  )
  let validation-errors = ()
  if validate != false {
    let result = (_make-validator())(source)
    if not result.valid {
      if validate == "panic" {
        panic(
          "prefigure: input failed RELAX NG validation (pass `validate: false` to "
            + "skip; see SCHEMA_VALIDATION_REPORT.md):\n"
            + _format-errors(result.errors),
        )
      }
      validation-errors = result.errors // validate == true → show them (below)
    }
  }

  let font-map = resolve-font-map(fonts)

  // Pass A — ask the plugin which runs need measuring, and which `<m>` bodies it
  // will emit. Math is always Typst-rendered (mitex) and overlaid as native
  // content, so a diagram with any math must use native labels too — text and
  // math overlay in one coherent pass.
  let extract-payload = (source: source, format: format, font_map: font-map)
  let extracted = json(_plugin.extract_measurables(bytes(
    json.encode(extract-payload),
  )))
  let measurables = extracted.measurables
  let math-bodies = extracted.at("math", default: ())

  // A diagram with any `<m>` is drawn native (its math is Typst-overlaid, so its
  // text must be too). `labels: "svg"` therefore only takes effect for math-free
  // diagrams. `math-items` implies math even if the count somehow differs.
  let has-math = math-bodies.len() > 0 or math-items.len() > 0
  let native = labels == "native" or has-math

  // Passes B–D happen inside one context so measure() is available.
  let diagram = context {
    // Pass B — measure every text run. In native mode, measure in the ambient
    // document font (so labels follow `#set text`); in svg mode, the mapped
    // family resvg will render.
    let metrics = measurables.map(m => measure-run(m, inherit-font: native))

    // Pass B (math) — build a Typst equation for each `<m>` body:
    //   * xmlit sentinels → the authored `$…$` from `math-items` (already Typst);
    //   * every other body is LaTeX — a figure's own authored `<m>` (e.g.
    //     `\nabla f(x_0)`) and the math PreFigure generates (tick numbers, log
    //     `10^{j}`, π-fractions `\frac{a\pi}{b}`, comma-thousands `\text{1{,}000}`).
    //     Convert it with mitex so it renders in the document's math font.
    // mitex is imported here, not at the top, and only when some `<m>` body
    // actually needs LaTeX conversion (a non-sentinel body). Typst resolves
    // package imports lazily, by execution, so a diagram with no math — or whose
    // math is all authored sentinels ($…$ from `math-items`) — never pulls mitex.
    // Then measure each into [w, above, below], keyed by the `<m>` body.
    let equations = (:)
    if has-math {
      let convert = none
      if math-bodies.any(b => not _is-sentinel(b)) {
        import "@preview/mitex:0.2.7": mitex
        // mitex renders *display* (block) math, whose baseline sits at the
        // bottom of its box — its below-baseline depth measures as 0, so a tall
        // equation (an integral, a fraction) would be placed by its bounding-box
        // bottom instead of its true baseline and float above the label's text.
        // Re-wrap each conversion as an *inline* equation, which carries a proper
        // ascent/descent split. Both measure.typ (Pass B) and native.typ read
        // these same equations, so this fixes the measured dims and the draw at
        // once. Authored `$…$` sentinels are already inline and untouched.
        convert = body => math.equation(block: false, mitex(body).body)
      }
      for body in math-bodies {
        if _is-sentinel(body) {
          // An unmatched sentinel means the caller extracted the math but did
          // not pass the table back. Without dimensions the plugin drops the
          // equation from its row and the diagram renders as if the author had
          // never written it, so say so instead of losing it silently.
          let id = _sentinel-id(body)
          assert(
            id in math-items,
            message: "prefigure: no equation for \""
              + id
              + "\" — pass the table from "
              + "xml-to-string(…, extract-math: true) as `math-items:`",
          )
          equations.insert(body, math-items.at(id))
        } else {
          equations.insert(body, convert(body))
        }
      }
    }
    let math-dims = (:)
    for (body, eq) in equations.pairs() {
      let m = measure-math(eq, size: _math-size)
      math-dims.insert(body, (m.width, m.above, m.below))
    }

    // Pass C — build with the measurements injected.
    let build-payload = (
      source: source,
      format: format,
      font_map: font-map,
      labels: if native { "native" } else { "svg" },
      metrics: metrics,
      math_dims: math-dims,
    )
    let built = _plugin.build(bytes(json.encode(build-payload)))

    // Pass D — embed.
    if native {
      render-native(json(built), width, equations: equations, ..image-args)
    } else {
      image(bytes(built), format: "svg", width: width, ..image-args)
    }
  }

  // `validate: true` is non-fatal: render the diagram, then the error callout.
  if validation-errors.len() == 0 { diagram } else {
    diagram + _error-box(validation-errors)
  }
}
