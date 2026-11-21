#import "plugin.typ": unimola-plugin

#let unimola-state = state("unimola-config", (
  theme: none,
  preamble: none,
  auto-wrap: true,
  deterministic: false,
  includes: (:),
))

#let resolve-opt(value, fallback) = if value == auto { fallback } else { value }

#let source-text-value(source) = {
  if type(source) == str {
    source
  } else if type(source) == content and source.has("text") {
    source.text
  } else {
    panic("unimola expects a string or raw code block as source")
  }
}

#let scale-factor(factor) = {
  if type(factor) == int or type(factor) == float {
    factor * 100%
  } else {
    factor
  }
}

#let scaled(body, factor) = {
  if factor == none or factor == auto {
    body
  } else {
    scale(x: scale-factor(factor), y: scale-factor(factor), reflow: true, body)
  }
}

#let diagram-error(result, width) = {
  let msg = if result.error == none { "unknown PlantUML error" } else { result.error }
  block(
    width: if width == auto { 100% } else { width },
    inset: 8pt,
    fill: rgb("#fff7f7"),
    stroke: rgb("#ef4444"),
  )[
    #strong[PlantUML diagram error (#result.kind)]
    #linebreak()
    #msg
  ]
}

/// Updates global Unimola defaults for subsequent `unimola`, `unimola-figure`, and `show-unimola-blocks` calls.
/// Pass `auto` to keep the current value for any parameter.
/// -> content
#let unimola-config(
  theme: auto,
  preamble: auto,
  auto-wrap: auto,
  deterministic: auto,
  includes: auto,
) = unimola-state.update(prev => (
  theme: resolve-opt(theme, prev.theme),
  preamble: resolve-opt(preamble, prev.preamble),
  auto-wrap: resolve-opt(auto-wrap, prev.auto-wrap),
  deterministic: resolve-opt(deterministic, prev.deterministic),
  includes: if includes == auto { prev.includes } else { includes },
))

/// Evaluates PlantUML source through the WASM plugin and returns the raw result dictionary.
/// -> dictionary
#let unimola-result(
  source,
  theme: none,
  preamble: none,
  auto-wrap: true,
  deterministic: false,
  includes: (:),
) = {
  let source-text = source-text-value(source)
  let options = json.encode((
    theme: theme,
    preamble: preamble,
    auto_wrap: auto-wrap,
    deterministic: deterministic,
    includes: includes,
  ))
  json(unimola-plugin.render_svg_json(bytes(source-text), bytes(options)))
}

/// Returns the rendered SVG string for a PlantUML diagram or panics on error.
/// -> str
#let unimola-svg(
  source,
  theme: none,
  preamble: none,
  auto-wrap: true,
  deterministic: false,
  includes: (:),
) = {
  let result = unimola-result(
    source,
    theme: theme,
    preamble: preamble,
    auto-wrap: auto-wrap,
    deterministic: deterministic,
    includes: includes,
  )
  if result.ok {
    result.svg
  } else {
    panic("unimola (" + str(result.kind) + "): " + str(result.error))
  }
}

/// Returns the reported PlantUML specification version from `plantuml-core`.
/// -> str
#let unimola-version() = str(unimola-plugin.plantuml_version())

/// Renders a PlantUML diagram directly as an inline/block SVG image.
/// Parameters set to `auto` inherit from `unimola-config(...)`.
/// -> content
#let unimola(
  source,
  theme: auto,
  preamble: auto,
  auto-wrap: auto,
  deterministic: auto,
  includes: auto,
  width: auto,
  height: auto,
  fit: "contain",
  scale: none,
  alt: none,
) = context {
  let cfg = unimola-state.get()
  let merged-includes = if includes == auto { cfg.includes } else { cfg.includes + includes }
  let result = unimola-result(
    source,
    theme: resolve-opt(theme, cfg.theme),
    preamble: resolve-opt(preamble, cfg.preamble),
    auto-wrap: resolve-opt(auto-wrap, cfg.auto-wrap),
    deterministic: resolve-opt(deterministic, cfg.deterministic),
    includes: merged-includes,
  )
  if result.ok {
    scaled(
      image(
        bytes(result.svg),
        format: "svg",
        width: width,
        height: height,
        fit: fit,
        alt: alt,
      ),
      scale,
    )
  } else {
    diagram-error(result, width)
  }
}
