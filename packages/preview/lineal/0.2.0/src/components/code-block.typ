// Typst loads each syntax into its own set. Compose local contexts into each
// complete definition rather than referring to unavailable bundled scopes.
#let typescript-contexts = read("code/typescript-contexts.yaml")
#let syntax-files = (
  bytes(read("code/svelte.sublime-syntax") + typescript-contexts + read("code/css-contexts.yaml")),
  bytes(read("code/svelte-typescript.sublime-syntax") + typescript-contexts),
)

// Bytes keep bundled themes independent of the consuming project's root.
#let DEFAULT_CODE_THEME = read("code/lineal-dark.tmTheme", encoding: none)
#let light-code-theme = read("code/lineal-light.tmTheme", encoding: none)
#let code-styles = (
  dark: (ground: rgb("#172126"), raised: rgb("#1d2b31"), ink: rgb("#f1f5f9"), muted: rgb("#a3b3bf"), wire: rgb("#40515d"), accent: rgb("#67d2ff"), accent-text: rgb("#9de2ff")),
  light: (ground: rgb("#f1f5f9"), raised: white, ink: rgb("#172126"), muted: rgb("#526475"), wire: rgb("#cbd5e1"), accent: rgb("#006b94"), accent-text: rgb("#005778")),
)

#let resolve-style(style) = {
  if type(style) == str {
    assert(style in code-styles, message: "code-block style must be dark, light, or a complete palette")
    return code-styles.at(style)
  }
  assert(type(style) == dictionary, message: "code-block style must be dark, light, or a complete palette")
  for key in ("ground", "raised", "ink", "muted", "wire", "accent", "accent-text") {
    assert(key in style and type(style.at(key)) == color, message: "code-block palette requires colour " + key)
  }
  style
}

#let resolve-theme(theme, style) = {
  if theme != auto { return theme }
  if style == "dark" { return DEFAULT_CODE_THEME }
  if style == "light" { return light-code-theme }
  none
}

#let resolved-code-width(width, body) = {
  assert(type(width) in (length, ratio, relative), message: "code-block width must be a length, ratio, or relative length")
  if type(width) == length {
    assert(width > 0pt, message: "code-block width must be positive")
    return body(width)
  }
  layout(size => {
    let actual = if type(width) == ratio { width * size.width } else { width.length + width.ratio * size.width }
    assert(actual > 0pt, message: "code-block width must be positive")
    body(actual)
  })
}

#let file-kind(filename) = {
  let filename = lower(filename)
  if filename.ends-with(".svelte.ts") { return "svelte-ts" }
  if filename.ends-with(".svelte") { return "svelte" }
  let extension = lower(filename.split(".").last())
  let extensions = (typescript: "ts", javascript: "js", python: "py", ts: "ts", tsx: "tsx", js: "js", jsx: "jsx", py: "py", json: "json", css: "css", html: "html", htm: "html", yaml: "yaml", yml: "yaml", md: "md", typ: "typ")
  extensions.at(extension, default: "text")
}

#let language-info(filename, language) = {
  let kind = if language == auto { file-kind(filename) } else { language }
  let aliases = (typescript: "ts", javascript: "js", python: "py", markdown: "md", typst: "typ", yml: "yaml", plaintext: "text", "svelte.ts": "svelte-ts")
  kind = aliases.at(kind, default: kind)
  let tags = (svelte: "lineal-svelte", "svelte-ts": "lineal-svelte-ts")
  let names = (ts: "TypeScript", tsx: "React TSX", svelte: "Svelte", "svelte-ts": "Svelte TS", js: "JavaScript", jsx: "React JSX", py: "Python", json: "JSON", css: "CSS", html: "HTML", yaml: "YAML", md: "Markdown", typ: "Typst", text: "Plain text")
  (tag: tags.at(kind, default: kind), label: names.at(kind, default: kind))
}

/// Extension-aware SVG mark. Generic files use a tintable Lucide file icon.
#let file-icon(filename, size: 14pt, tint: rgb("#526475")) = {
  let names = (ts: "typescript", tsx: "react", jsx: "react", svelte: "svelte", "svelte-ts": "svelte")
  let kind = file-kind(filename)
  let name = names.at(kind, default: "file-code")
  let svg = read("../static/icons/code/" + name + ".svg")
  if kind == "svelte-ts" { svg = svg.replace("#FF3E00", "#3178C6") }
  image(bytes(svg.replace("currentColor", tint.to-hex())), width: size, height: size, alt: language-info(filename, auto).label + " file")
}

/// A compact filename lockup for headers, diagrams and ownership columns.
#let file-label(filename, size: 11pt, icon-size: auto, font: none, fill: rgb("#172126"), muted: rgb("#526475"), gap: 7pt) = {
  let parts = filename.split("/")
  let basename = parts.pop()
  let directory = if parts.len() == 0 { "" } else { parts.join("/") + "/" }
  grid(columns: (auto, 1fr), column-gutter: gap, align: horizon,
    file-icon(filename, size: if icon-size == auto { size * 1.25 } else { icon-size }, tint: fill),
    text(..if font == none { (:) } else { (font: font) }, size: size)[#text(fill: muted, directory)#text(weight: "semibold", fill: fill, basename)],
  )
}

/// Compatibility helpers retained for existing Lineal documents.
#let code-block-icon(language: "python") = file-icon("snippet." + language, size: .6em)
#let code-block-title(title: "Code block", language: "python") = file-label(title, size: .5em, fill: code-styles.dark.ink, muted: code-styles.dark.muted)

#let validate-lines(emphasize, first, count) = {
  let last = first + count - 1
  for entry in emphasize {
    if type(entry) == int {
      assert(first <= entry and entry <= last, message: "emphasized line is outside the source range")
    } else {
      assert(type(entry) == array and entry.len() == 2, message: "emphasize expects line numbers or inclusive (start, end) pairs")
      assert(type(entry.first()) == int and type(entry.last()) == int, message: "emphasis range endpoints must be integers")
      assert(first <= entry.first() and entry.first() <= entry.last() and entry.last() <= last, message: "emphasis range is outside the source range")
    }
  }
}

#let selected-line(number, emphasize) = emphasize.any(entry => {
  if type(entry) == int { return number == entry }
  entry.first() <= number and number <= entry.last()
})

#let code-header(options) = block(
  width: 100%, fill: options.style.ground, radius: (top-left: options.radius, top-right: options.radius),
  inset: (x: options.padding, y: 8pt),
  grid(columns: (1fr, auto), column-gutter: 10pt, align: horizon,
    file-label(options.filename, size: options.header-size, font: options.body-font, fill: options.style.ink, muted: options.style.muted),
    text(..if options.body-font == none { (:) } else { (font: options.body-font) }, size: options.header-size * .86, fill: options.style.muted, options.language.label),
  ),
)

#let source-line(line, options, width) = context {
  let number = options.start-line + line.number - 1
  let chosen = selected-line(number, options.emphasize)
  let number-width = if options.line-numbers { options.number-width } else { 0pt }
  let gap = if options.line-numbers { 10pt } else { 0pt }
  let available = width - 2 * options.padding - number-width - gap
  assert(available > 0pt, message: "code panel has no remaining width for source")
  if not options.wrap {
    assert(measure(line.body).width <= available, message: options.filename + ":" + str(number) + " exceeds code width; enable wrapping, widen the panel or reduce size")
  } else {
    for token in line.text.split(regex("\\s+")) {
      assert(measure(text(token)).width <= available, message: options.filename + ":" + str(number) + " contains an unbreakable token wider than the panel")
    }
  }
  let source = block(width: available, {
    set text(top-edge: "ascender", bottom-edge: "descender")
    set par(leading: options.size * .12, spacing: 0pt)
    line.body
  })
  let row-height = calc.max(options.size * 1.1, measure(source).height) + options.line-gap
  box(width: width, height: row-height,
    block(width: width, height: row-height, inset: (x: options.padding),
      fill: if chosen { options.style.accent.transparentize(87%) } else { none },
      {
      if chosen { place(top + left, dx: -options.padding, rect(width: 2pt, height: row-height, fill: options.style.accent)) }
      align(horizon, grid(columns: (number-width, 1fr), column-gutter: gap, align: top,
        if options.line-numbers {
          pad(top: options.size * .18, align(right, text(size: options.size * .72, fill: if chosen { options.style.accent-text } else { options.style.muted }, str(number))))
        } else { [] },
        source,
      ))
      },
    ),
  )
}

#let code-source(source, options, width) = {
  set text(font: options.font, size: options.size, fill: options.style.ink, hyphenate: false, ligatures: false)
  set par(leading: 0pt, spacing: 0pt)
  set block(spacing: 0pt)
  show raw: set text(font: options.font, size: options.size)
  show raw.line: line => source-line(line, options, width)
  block(width: width, inset: (y: options.padding * .7),
    raw(source, block: true, lang: options.language.tag, syntaxes: syntax-files, theme: options.theme, tab-size: options.tab-size),
  )
}

#let panel(source, options, width, height: auto) = block(
  width: width, height: height, fill: options.style.raised, clip: true,
  radius: options.radius, stroke: .6pt + options.style.wire,
  {
    set block(spacing: 0pt)
    if options.show-header { code-header(options) }
    code-source(source, options, width)
  },
)

#let render-code(source, options, width) = context {
  let intrinsic = measure(panel(source, options, width)).height
  let height = if options.height == none { intrinsic } else { options.height }
  assert(intrinsic <= height, message: options.filename + " needs " + repr(intrinsic) + "; requested height is " + repr(height))
  let content = {
    panel(source, options, width, height: height)
    if options.caption != none {
      v(7pt)
      text(..if options.body-font == none { (:) } else { (font: options.body-font) }, size: options.caption-size, fill: options.caption-fill, options.caption)
    }
  }
  if options.max-height != none {
    assert(measure(block(width: width, content)).height <= options.max-height, message: options.filename + " and caption exceed max-height")
  }
  content
}

/// Selectable, highlighted source with optional filename chrome and measured overflow.
/// A named style supplies its own syntax theme; a custom palette uses plain ink
/// unless theme is supplied. Explicit height aligns neighbouring panel bottoms.
#let code-block(
  content, filename: "app.py", language: auto, style: "dark",
  body-font: none, font: "DejaVu Sans Mono", size: 12pt,
  width: 100%, height: none, max-height: none,
  line-numbers: true, start-line: 1, emphasize: (),
  wrap: true, padding: 12pt, line-gap: 0pt, radius: 7pt,
  show-header: true, header-size: 10.5pt, caption: none, caption-size: 11pt,
  caption-fill: auto, tab-size: 2, theme: auto,
) = context {
  assert(type(content) == str, message: "code-block source must be a string")
  let theme = resolve-theme(theme, style)
  let style = resolve-style(style)
  assert(size > 0pt and padding >= 0pt and line-gap >= 0pt, message: "code dimensions must be positive")
  assert(start-line >= 1 and type(start-line) == int, message: "start-line must be a positive integer")
  assert(type(tab-size) == int and tab-size > 0, message: "code-block tab-size must be a positive integer")
  assert(height == none or type(height) == length and height > 0pt, message: "code-block height must be a positive length or none")
  assert(max-height == none or type(max-height) == length and max-height > 0pt, message: "code-block max-height must be a positive length or none")
  let source = content.replace("\r\n", "\n").trim("\n")
  let count = source.split("\n").len()
  validate-lines(emphasize, start-line, count)
  let number-width = measure(text(font: font, size: size * .72, str(start-line + count - 1))).width
  let options = (
    filename: filename, language: language-info(filename, language), style: style,
    body-font: body-font, font: font, size: size, height: height, max-height: max-height,
    line-numbers: line-numbers, start-line: start-line, emphasize: emphasize,
    wrap: wrap, padding: padding, line-gap: line-gap, radius: radius,
    show-header: show-header, header-size: header-size, caption: caption, caption-size: caption-size,
    caption-fill: if caption-fill == auto { text.fill } else { caption-fill }, tab-size: tab-size, theme: theme, number-width: number-width,
  )
  resolved-code-width(width, actual => render-code(source, options, actual))
}
