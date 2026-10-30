// Pelermaid
//
// Renders Mermaid diagrams with Pele (https://github.com/obsidianmd/pele) running inside
// CtxJS (https://github.com/lublak/typst-ctxjs-package), and embeds the result as a Typst
// SVG image. The JavaScript wrapper resolves Pele's CSS variables and color-mix() calls
// because Typst's SVG renderer does not implement custom properties.
//
// The public surface intentionally mirrors the other Typst Mermaid packages:
//
// - `mermaid(source, ..)` embeds an image.
// - `mermaid-svg(source, ..)` returns SVG text.
// - `mermaid-result(source, ..)` returns a structured result instead of panicking.
// - `mermaid-figure(source, caption: ..)` wraps the image in `figure`.
// - `show-mermaid-blocks(..)` is a `show raw.where(lang: "mermaid")` handler.
//
// Layout is Pele's, not Mermaid.js's. The Typst wrapper only supplies the source,
// theme variables, and render options; it does not lay out or measure the diagram.

#import "@preview/ctxjs:0.5.0" as ctxjs

// Load the Pele bundle once per Typst module evaluation. `ctxjs` keeps the QuickJS
// context alive; each render call is a normal module function call.
#let _ctx0 = ctxjs.new-context()
#let (_ctx, _load-error) = ctxjs.ctx.load-module-bytecode(
  _ctx0,
  read("pele.kbc1", encoding: none),
  catch: true,
)

#let _load-error-message = {
  if _load-error == none {
    none
  } else if type(_load-error) == dictionary and "ctxjs_error" in _load-error {
    _load-error.ctxjs_error
  } else {
    repr(_load-error)
  }
}

// ---------------------------------------------------------------------------------------------
// Themes
// ---------------------------------------------------------------------------------------------

// Font stacks are deliberately broad. When document context is enabled, the document's
// actual font (and size, foreground, and page fill) replace these defaults. The stacks are
// only used with `document-context: false`.
#let _sans = "'DejaVu Sans', 'Liberation Sans', Arial, sans-serif"
#let _mono = "'DejaVu Sans Mono', 'Liberation Mono', Consolas, monospace"

#let presets = (
  modern: (
    bg: "#ffffff",
    "label-bg": "#ffffff",
    fg: "#1f2328",
    muted: "#59636e",
    line: "#59636e",
    border: "#1f2328",
    surface: "#f6f8fa",
    "surface-alt": "#eaeef2",
    accent: "#0969da",
    critical: "#cf222e",
    "fg-on-light": "#1f2328",
    "fg-on-dark": "#ffffff",
    error: "#cf222e",
    "series-1": "#0969da",
    "series-2": "#1a7f37",
    "series-3": "#9a6700",
    "series-4": "#cf222e",
    "series-5": "#8250df",
    "series-6": "#bf3989",
    "series-7": "#0550ae",
    "series-8": "#116329",
    font: _sans,
    "font-mono": _mono,
    stroke: "1.75px",
    radius: "6px",
    "title-weight": "bold",
    "heading-weight": "bold",
    "bold-weight": "bold",
  ),
  dark: (
    bg: "#0d1117",
    "label-bg": "#0d1117",
    fg: "#e6edf3",
    muted: "#8b949e",
    line: "#8b949e",
    border: "#8b949e",
    surface: "#161b22",
    "surface-alt": "#21262d",
    accent: "#58a6ff",
    critical: "#ff7b72",
    "fg-on-light": "#0d1117",
    "fg-on-dark": "#e6edf3",
    error: "#ff7b72",
    "series-1": "#58a6ff",
    "series-2": "#3fb950",
    "series-3": "#d29922",
    "series-4": "#f85149",
    "series-5": "#bc8cff",
    "series-6": "#db61a2",
    "series-7": "#79c0ff",
    "series-8": "#56d364",
    font: _sans,
    "font-mono": _mono,
    stroke: "1.75px",
    radius: "6px",
    "title-weight": "bold",
    "heading-weight": "bold",
    "bold-weight": "bold",
  ),
  print: (
    bg: "#ffffff",
    "label-bg": "#ffffff",
    fg: "#000000",
    muted: "#000000",
    line: "#000000",
    border: "#000000",
    surface: "#ffffff",
    "surface-alt": "#f2f2f2",
    accent: "#000000",
    critical: "#000000",
    "fg-on-light": "#000000",
    "fg-on-dark": "#ffffff",
    error: "#000000",
    "series-1": "#000000",
    "series-2": "#404040",
    "series-3": "#666666",
    "series-4": "#8c8c8c",
    "series-5": "#b3b3b3",
    "series-6": "#cccccc",
    "series-7": "#e0e0e0",
    "series-8": "#f0f0f0",
    font: _sans,
    "font-mono": _mono,
    stroke: "1.2px",
    radius: "0px",
    "title-weight": "bold",
    "heading-weight": "bold",
    "bold-weight": "bold",
  ),
)

// Canonical Pele theme variables. `series-N` is generated below.
#let theme-names = (
  "bg",
  "label-bg",
  "fg",
  "muted",
  "line",
  "border",
  "surface",
  "surface-alt",
  "accent",
  "critical",
  "error",
  "fg-on-light",
  "fg-on-dark",
  "font",
  "font-mono",
  "stroke",
  "radius",
  "title-weight",
  "heading-weight",
  "bold-weight",
  ..range(1, 9).map(index => "series-" + str(index)),
)

// Human-friendly spellings accepted in `theme:`. Values are canonical theme variables.
#let theme-aliases = (
  background: "bg",
  "label-background": "label-bg",
  "edge-label-background": "label-bg",
  foreground: "fg",
  text: "fg",
  "text-color": "fg",
  "main-bkg-color": "bg",
  "main-background-color": "bg",
  "primary-color": "surface",
  primary: "surface",
  "node-fill": "surface",
  "line-color": "line",
  "border-color": "border",
  "cluster-bkg-color": "surface-alt",
  "cluster-background-color": "surface-alt",
  "font-family": "font",
  "text-on-light": "fg-on-light",
  "text-on-dark": "fg-on-dark",
  "error-color": "error",
  "critical-color": "critical",
  "accent-color": "accent",
  "muted-color": "muted",
  "stroke-width": "stroke",
)

#let theme-lookup = {
  let out = (:)
  for name in theme-names {
    out.insert(name, name)
  }
  for (alias, name) in theme-aliases {
    out.insert(alias, name)
  }
  out
}

// Canonical Pele render options and their accepted spellings. `measure` is handled by
// the Typst wrapper, but is accepted here for compatibility.
#let option-names = (
  "fontSize",
  "fontFamily",
  "fontFamilyMono",
  "idPrefix",
  "maxWidth",
  "autoDirection",
  "directionBreakpoint",
  "maxEdges",
  "outputLimit",
  "linkRel",
  "linkSchemes",
  "imageSchemes",
  "padding",
  "responsive",
  "limit",
  "now",
  "measure",
  "links",
  "images",
  "monospace",
)

#let option-aliases = (
  "font-size": "fontSize",
  fontsize: "fontSize",
  "font-family": "fontFamily",
  fontfamily: "fontFamily",
  "font-mono": "fontFamilyMono",
  fontfamilymono: "fontFamilyMono",
  id: "idPrefix",
  "id-prefix": "idPrefix",
  idprefix: "idPrefix",
  "max-width": "maxWidth",
  maxwidth: "maxWidth",
  "auto-direction": "autoDirection",
  autodirection: "autoDirection",
  "direction-breakpoint": "directionBreakpoint",
  directionbreakpoint: "directionBreakpoint",
  "max-edges": "maxEdges",
  maxedges: "maxEdges",
  "output-limit": "outputLimit",
  outputlimit: "outputLimit",
  "link-rel": "linkRel",
  linkrel: "linkRel",
  "link-schemes": "linkSchemes",
  linkschemes: "linkSchemes",
  "image-schemes": "imageSchemes",
  imageschemes: "imageSchemes",
)

#let option-lookup = {
  let out = (:)
  for name in option-names {
    out.insert(lower(name), name)
  }
  for (alias, name) in option-aliases {
    out.insert(alias, name)
  }
  out
}

// Canonical render options that may appear under `layout:`. Pele lays out diagrams itself;
// this dictionary is only a convenience alias for the subset of render options that affect
// layout. Accepted spellings are derived from `option-lookup`.
#let layout-option-names = (
  "padding",
  "fontSize",
  "maxWidth",
  "responsive",
  "autoDirection",
  "directionBreakpoint",
  "maxEdges",
  "outputLimit",
  "limit",
  "monospace",
  "measure",
)

#let layout-keys = option-lookup
  .pairs()
  .filter(pair => pair.at(1) in layout-option-names)
  .map(pair => pair.at(0))

#let normalize-key(key) = lower(str(key)).replace("_", "-")

#let theme-key(key) = {
  let raw = normalize-key(key)
  let name = if raw.starts-with("--pele-") { raw.slice(7) } else { raw }
  if name in theme-lookup {
    theme-lookup.at(name)
  } else if raw in option-lookup {
    panic(
      "pelermaid: theme key " + repr(str(key)) + " is a renderer option; "
        + "pass it in options: (...) instead. Theme keys are: "
        + theme-names.join(", "),
    )
  } else {
    panic(
      "pelermaid: unknown theme key " + repr(str(key)) + "; expected one of "
        + theme-names.join(", ")
        + ". Use --pele-* spellings or options: (...) for renderer options.",
    )
  }
}

#let option-key(key) = {
  let name = normalize-key(key)
  if name in option-lookup {
    option-lookup.at(name)
  } else {
    panic(
      "pelermaid: unknown render option " + repr(str(key)) + "; expected one of "
        + option-names.join(", "),
    )
  }
}

#let css-value(value) = {
  if type(value) == color {
    value.to-hex()
  } else if type(value) == str {
    value
  } else {
    repr(value)
  }
}

#let css-font(value, fallback: "sans-serif") = {
  let entries = if type(value) == array { value } else { (value,) }
  let families = entries.map(entry => {
    // `text.font` entries can be dictionaries with `name` and `covers`; only the family
    // name belongs in CSS.
    let name = if type(entry) == dictionary and "name" in entry { entry.name } else { entry }
    let name = str(name).trim()
    if name == "" {
      fallback
    } else if name.contains(" ") and not name.starts-with("\"") and not name.starts-with("'") {
      "'" + name + "'"
    } else {
      name
    }
  })
  let joined = families.join(", ")
  let joined-lower = lower(joined)
  let generics = ("serif", "sans-serif", "monospace", "cursive", "fantasy", "system-ui", "ui-monospace")
  let has-generic = generics.any(generic => joined-lower == generic or joined-lower.ends-with(", " + generic))
  if joined == "" {
    fallback
  } else if has-generic {
    joined
  } else {
    joined + ", " + fallback
  }
}

// Perceived brightness in sRGB, used to pick a preset and check document contrast.
#let luminance(color) = {
  let channels = rgb(color).components().map(float)
  0.2126 * channels.at(0) + 0.7152 * channels.at(1) + 0.0722 * channels.at(2)
}

#let mix-toward(base, target, ratio) = {
  color.mix((base, 100% - ratio), (target, ratio), space: rgb)
}

#let is-transparent(value) = {
  let text = lower(str(value)).trim()
  text == "" or text == "none" or text == "transparent"
}

#let px(value) = {
  if type(value) == int or type(value) == float {
    value
  } else if type(value) == length {
    value.pt() * 96 / 72
  } else if type(value) == str {
    let text = value.trim()
    if text.ends-with("px") {
      float(text.slice(0, -2))
    } else if text.ends-with("pt") {
      float(text.slice(0, -2)) * 96 / 72
    } else {
      float(text)
    }
  } else {
    panic("pelermaid: expected a number, length, or CSS pixel string, found " + repr(value))
  }
}

// ---------------------------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------------------------

#let validate-measure(measure) = {
  if measure not in ("mono", "auto") {
    panic(
      "pelermaid: measure must be \"mono\" or \"auto\", found " + repr(measure),
    )
  }
  measure
}

// Read the surrounding document's typography and page colour. Must be called inside a
// `context` block. Returns `none` values for fills that cannot be represented as a colour.
#let document-values() = (
  font: text.font,
  size: text.size,
  fill: if type(text.fill) == color { text.fill } else { none },
  background: if type(page.fill) == color { page.fill } else { none },
)

#let build-config(
  base-theme: "auto",
  theme: none,
  document: none,
  background: auto,
  foreground: auto,
  font: auto,
  font-mono: auto,
  font-size: auto,
  stroke: auto,
  radius: auto,
  series: auto,
  id: none,
  layout: none,
  options: (:),
  measure: "auto",
) = {
  let auto-theme = base-theme == "auto"
  if not auto-theme and base-theme not in presets {
    panic(
      "pelermaid: unknown base-theme " + repr(base-theme) + "; expected \"auto\", "
        + presets.keys().map(repr).join(", "),
    )
  }

  // Choose the preset before applying document values. `auto` follows the page luminance;
  // an explicit base theme keeps its palette, even on a page of the opposite polarity.
  let preset = if auto-theme {
    if document != none and document.background != none and luminance(document.background) < 0.5 {
      "dark"
    } else {
      "modern"
    }
  } else {
    base-theme
  }
  let vars = (: ..presets.at(preset))
  let render-options = (:)
  let font-set = false
  let label-bg-set = false
  let bg-set = false
  let neutral-set = (:)
  let bg-color = none
  let fg-color = none

  // 1. Document typography. With the default `auto` base theme, colours also follow the
  // page; explicit base themes opt out so their fg/bg pairing stays intact. `main.js`
  // copies `font`/`font-mono` into Pele's measurement options, so the drawn and measured
  // stacks stay in sync.
  if document != none {
    if font == auto {
      vars.insert("font", css-font(document.font))
    }
    if font-size == auto {
      render-options.insert("fontSize", px(document.size))
    }
    if auto-theme {
      let page-color = document.background
      let text-color = document.fill
      let canvas = if page-color == none { white } else { page-color }
      // Only adopt the document foreground when it actually contrasts with the page. A
      // stray `text.fill` should not make the diagram invisible.
      if (
        foreground == auto
          and text-color != none
          and calc.abs(luminance(text-color) - luminance(canvas)) >= 0.4
      ) {
        vars.insert("fg", css-value(text-color))
        fg-color = text-color
      }
      if background == auto {
        if page-color == none {
          vars.insert("bg", "transparent")
          // Keep the preset label colour so edge labels remain legible on a transparent
          // canvas.
        } else {
          vars.insert("bg", css-value(page-color))
          vars.insert("label-bg", css-value(page-color))
          bg-color = page-color
        }
      }
    }
  }

  // 2. Explicit theme overrides.
  if theme != none {
    for (key, value) in theme {
      let name = theme-key(key)
      if name == "font" {
        font-set = true
      }
      if name == "label-bg" {
        label-bg-set = true
      }
      if name in ("surface", "surface-alt", "muted", "line", "border") {
        neutral-set.insert(name, true)
      }
      if name == "bg" {
        bg-set = true
        bg-color = if type(value) == color { value } else { none }
      } else if name == "fg" {
        fg-color = if type(value) == color { value } else { none }
      }
      if name in ("font", "font-mono") {
        vars.insert(
          name,
          css-font(value, fallback: if name == "font-mono" { "monospace" } else { "sans-serif" }),
        )
      } else {
        vars.insert(name, css-value(value))
      }
    }
    // A theme background also sets the label background unless that was set separately.
    if bg-set and not label-bg-set and not is-transparent(vars.at("bg")) {
      vars.insert("label-bg", vars.at("bg"))
    }
  }

  // 3. Named arguments.
  if background != auto {
    if background == none {
      vars.insert("bg", "transparent")
      bg-color = none
    } else {
      let value = css-value(background)
      vars.insert("bg", value)
      bg-color = if type(background) == color { background } else { none }
      if not label-bg-set {
        vars.insert("label-bg", value)
      }
    }
  }
  if foreground != auto {
    vars.insert("fg", css-value(foreground))
    fg-color = if type(foreground) == color { foreground } else { none }
  }
  if font != auto {
    vars.insert("font", css-font(font))
    font-set = true
  }
  if font-mono != auto {
    vars.insert("font-mono", css-font(font-mono, fallback: "monospace"))
  }
  if stroke != auto {
    vars.insert("stroke", css-value(stroke))
  }
  if radius != auto {
    vars.insert("radius", css-value(radius))
  }
  if series != auto {
    let colors = if type(series) == array { series } else { (series,) }
    if colors.len() > 8 {
      panic("pelermaid: series accepts at most 8 colors, found " + str(colors.len()))
    }
    if colors.len() > 0 {
      // Repeat short palettes instead of mixing them with preset colours.
      for index in range(8) {
        vars.insert(
          "series-" + str(index + 1),
          css-value(colors.at(calc.rem(index, colors.len()))),
        )
      }
    }
  }
  if font-size != auto {
    render-options.insert("fontSize", px(font-size))
  }
  if id != none {
    render-options.insert("idPrefix", str(id))
  }

  // 4. Document-adaptive neutrals. Presets are designed for their own bg/fg pair; when the
  // page supplies a different pair, derive surfaces and borders from the colours actually
  // in use. Explicit theme values win.
  if auto-theme and bg-color != none and fg-color != none {
    let dark-canvas = luminance(bg-color) < 0.5
    let ratios = if dark-canvas {
      (
        "surface": 6%,
        "surface-alt": 12%,
        "muted": 50%,
        "line": 50%,
        "border": 60%,
      )
    } else {
      (
        "surface": 4%,
        "surface-alt": 8%,
        "muted": 55%,
        "line": 55%,
        "border": 85%,
      )
    }
    for (name, ratio) in ratios {
      if name not in neutral-set {
        vars.insert(name, css-value(mix-toward(bg-color, fg-color, ratio)))
      }
    }
  }

  // 5. Layout aliases. These use the same option table as `options`, but reject keys that
  // do not affect layout.
  if layout != none {
    for (key, value) in layout {
      let normalized = normalize-key(key)
      if normalized not in layout-keys {
        panic(
          "pelermaid: layout." + normalized + " is not supported; Pele lays out diagrams "
            + "itself. Use the Mermaid frontmatter or options: (...). Supported layout keys: "
            + layout-option-names.join(", ") + " (and their aliases)",
        )
      }
      render-options.insert(option-key(key), value)
    }
  }

  // 6. Raw renderer options win, as in the other Mermaid packages.
  for (key, value) in options {
    render-options.insert(option-key(key), value)
  }

  // 7. Pelermaid preserves the direction written in the diagram (`flowchart LR` stays
  // left-to-right). Pele's auto-direction flips wide LR/RL diagrams to top-down below the
  // breakpoint, which changes the diagram's meaning; opt in with auto-direction: true.
  if "autoDirection" not in render-options {
    render-options.insert("autoDirection", false)
  }

  let measure = validate-measure(render-options.at("measure", default: measure))
  render-options.insert("measure", measure)

  // Monospace metrics are only meaningful for a monospace face. Without document context
  // or an explicit font, switch the diagram font to the preset's monospace stack.
  if measure == "mono" and not font-set and document == none {
    vars.insert("font", vars.at("font-mono"))
  }

  (theme: vars, options: render-options)
}

// ---------------------------------------------------------------------------------------------
// Rendering
// ---------------------------------------------------------------------------------------------

#let source-text(source) = {
  if type(source) == str {
    source
  } else if type(source) == content and source.has("text") {
    source.text
  } else {
    panic("pelermaid: expected a Mermaid string or a raw block, found " + repr(source))
  }
}

#let runtime-error(message) = (
  ok: false,
  code: "runtime",
  message: message,
  line: 0,
  column: 0,
  snippet: "",
  type: none,
  mermaidType: none,
)

#let render-result-with-config(source, config) = {
  if _load-error-message != none {
    return runtime-error("Could not load the Pele runtime: " + _load-error-message)
  }

  let (_, result) = ctxjs.ctx.call-module-function(
    _ctx,
    "pele",
    "render",
    source-text(source),
    config.options,
    config.theme,
    catch: true,
  )

  if type(result) == dictionary and "ctxjs_error" in result {
    runtime-error(result.ctxjs_error)
  } else if type(result) == dictionary {
    result
  } else {
    runtime-error("Pele returned an unexpected value: " + repr(result))
  }
}

#let mermaid-result(source, ..args) = render-result-with-config(source, build-config(..args))

#let error-message(result) = {
  let message = if "message" in result and result.message != none {
    result.message
  } else {
    "unknown render error"
  }
  let location = if "line" in result and result.line > 0 {
    " (line " + str(result.line) + ", column " + str(result.column) + ")"
  } else {
    ""
  }
  "Mermaid error" + location + ": " + message
}

#let diagram-error(result, mode, width) = {
  let message = error-message(result)
  if mode == "text" {
    // Plain text: no box, so it can sit inline in a sentence or table cell.
    block(width: width, text(fill: rgb("#b42318"), message))
  } else {
    // Placeholder: a highlighted box that is hard to miss in a draft.
    block(
      width: width,
      inset: 8pt,
      radius: 4pt,
      fill: rgb("#fff5f5"),
      stroke: 0.75pt + rgb("#d92d20"),
      text(fill: rgb("#b42318"))[
        *Mermaid diagram could not be rendered.* #linebreak()
        #message
      ],
    )
  }
}

#let scale-factor(value) = {
  if type(value) == int or type(value) == float {
    value * 100%
  } else if type(value) == ratio {
    value
  } else {
    panic("pelermaid: scale must be a number or ratio, found " + repr(value))
  }
}

#let render-image(
  source,
  config,
  width,
  height,
  fit,
  alt,
  scale-value,
  alignment,
  error-mode,
  max-width-px,
) = {
  let result = render-result-with-config(source, config)
  if result.ok {
    let picture-width = width
    if width == auto and max-width-px != none and result.width > max-width-px + 0.5 {
      picture-width = 100%
    }
    let picture-alt = if alt == none {
      "Mermaid " + result.at("type", default: "diagram") + " diagram"
    } else {
      alt
    }
    let picture = image(
      bytes(result.svg),
      format: "svg",
      width: picture-width,
      height: height,
      fit: fit,
      alt: picture-alt,
    )
    let picture = if scale-value == none {
      picture
    } else {
      let factor = scale-factor(scale-value)
      std.scale(x: factor, y: factor, reflow: true, picture)
    }
    if alignment == none {
      picture
    } else {
      align(alignment, block(width: 100%, picture))
    }
  } else if error-mode == "panic" {
    panic(error-message(result))
  } else {
    diagram-error(result, error-mode, width)
  }
}

#let validate-error-mode(error-mode) = {
  if error-mode not in ("panic", "placeholder", "text") {
    panic(
      "pelermaid: error-mode must be \"panic\", \"placeholder\", or \"text\", found "
        + repr(error-mode),
    )
  }
  error-mode
}

#let resolve-width(width, available) = {
  if width == auto {
    available
  } else if type(width) == ratio {
    available * width
  } else if type(width) == relative {
    available * width.ratio + width.length
  } else if type(width) == length {
    width
  } else {
    panic(
      "pelermaid: width must be auto, a ratio, a relative length, or an absolute length, found "
        + repr(width),
    )
  }
}

#let mermaid(
  source,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  align: none,
  base-theme: "auto",
  theme: none,
  background: auto,
  foreground: auto,
  font: auto,
  font-mono: auto,
  font-size: auto,
  stroke: auto,
  radius: auto,
  series: auto,
  id: none,
  layout: none,
  options: (:),
  measure: "auto",
  error-mode: "panic",
  document-context: true,
) = {
  let error-mode = validate-error-mode(error-mode)

  let render-with = (document: none, available: none) => {
    let config = build-config(
      base-theme: base-theme,
      theme: theme,
      document: document,
      background: background,
      foreground: foreground,
      font: font,
      font-mono: font-mono,
      font-size: font-size,
      stroke: stroke,
      radius: radius,
      series: series,
      id: id,
      layout: layout,
      options: options,
      measure: measure,
    )

    let target = if type(width) == length {
      width
    } else if available != none {
      resolve-width(width, available)
    } else {
      none
    }
    let max-width = if target != none and target > 0pt and target < 100000pt {
      target.pt() * 96 / 72
    } else {
      none
    }

    let context-options = (: ..config.options)
    if max-width != none and "maxWidth" not in context-options {
      context-options.insert("maxWidth", max-width)
    }
    render-image(
      source,
      (theme: config.theme, options: context-options),
      width,
      height,
      fit,
      alt,
      scale,
      align,
      error-mode,
      max-width,
    )
  }

  if not document-context {
    render-with()
  } else if type(width) == length {
    // An absolute width already resolves without the page's available width, but the
    // document font and colours still need a context.
    context render-with(document: document-values())
  } else {
    // `layout` is also a named argument of `mermaid`, so use the std module to reach
    // Typst's layout function.
    context std.layout(size => render-with(document: document-values(), available: size.width))
  }
}

#let mermaid-svg(source, ..args) = {
  let result = mermaid-result(source, ..args)
  if result.ok {
    result.svg
  } else {
    panic(error-message(result))
  }
}

#let mermaid-figure(
  source,
  caption: none,
  placement: none,
  scope: none,
  supplement: none,
  numbering: none,
  outlined: none,
  gap: none,
  caption-position: none,
  caption-separator: none,
  ..args,
) = {
  let diagram = mermaid(source, ..args)
  let figure-options = (:)
  if caption != none {
    figure-options.insert(
      "caption",
      if caption-position != none and caption-separator != none {
        figure.caption(position: caption-position, separator: caption-separator, caption)
      } else if caption-position != none {
        figure.caption(position: caption-position, caption)
      } else if caption-separator != none {
        figure.caption(separator: caption-separator, caption)
      } else {
        caption
      },
    )
  }
  if placement != none {
    figure-options.insert("placement", placement)
  }
  if scope != none {
    figure-options.insert("scope", scope)
  }
  if supplement != none {
    figure-options.insert("supplement", supplement)
  }
  if numbering != none {
    figure-options.insert("numbering", numbering)
  }
  if outlined != none {
    figure-options.insert("outlined", outlined)
  }
  if gap != none {
    figure-options.insert("gap", gap)
  }
  figure(diagram, ..figure-options)
}

#let show-mermaid-blocks(
  width: 100%,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
  align: center,
  error-mode: "placeholder",
  ..args,
) = block => {
  mermaid(
    block.text,
    width: width,
    height: height,
    fit: fit,
    scale: scale,
    alt: alt,
    align: align,
    error-mode: error-mode,
    ..args,
  )
}
