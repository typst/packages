/// Theme data and loading for Codly.
#import "@preview/elembic:1.1.1" as e
#import "declarations.typ": __default, __codly-prefix, __declaration

// Typography uses show rules because it is native text styling, not an
// element field. Resolve those rules from the latest scoped theme so an older
// theme's show rule cannot repaint a newer nested theme.
#let __style = e.element.declare(
  "codly-theme-style",
  prefix: __codly-prefix,
  display: _ => [],
  ..__declaration("elements", "theme-style"),
)

// Small, language-independent TextMate themes made from the editor palettes.
// Palette references:
// https://github.com/primer/github-vscode-theme
// https://ethanschoonover.com/solarized/
// https://github.com/atom/one-light-syntax/blob/master/styles/colors.less
#let __syntax(foreground, comment, keyword, string, constant, function-color, type-color) = {
  let rule(scope, color) = (
    "<dict><key>scope</key><string>"
      + scope
      + "</string><key>settings</key><dict><key>foreground</key><string>"
      + color.to-hex()
      + "</string></dict></dict>"
  )
  bytes(
    "<?xml version=\"1.0\"?><plist version=\"1.0\"><dict><key>settings</key><array>"
      + "<dict><key>settings</key><dict><key>foreground</key><string>"
      + foreground.to-hex()
      + "</string></dict></dict>"
      + rule("comment", comment)
      + rule("keyword, storage", keyword)
      + rule("string", string)
      + rule("constant", constant)
      + rule("entity.name.function, support.function", function-color)
      + rule("entity.name.type, entity.name.class, support.type", type-color)
      + "</array></dict></plist>",
  )
}

#let __editor(foreground, background, muted, accent, band, syntax) = (
  foreground: foreground,
  muted: muted,
  fill: background,
  accent: accent,
  stroke: 0.5pt + band,
  header-fill: band,
  footer-fill: band,
  bubble-fill: band,
  syntax: syntax,
  language-colors: false,
  file: (stroke: 0.5pt + band, radius: 0.32em),
  bubble: (stroke: 0.5pt + band),
)

// Five accents for each preset, shared with the ordinary highlight defaults.
#let __palettes = (
  thesis: ("283593", "2e7d32", "ef6c00", "6a1b9a", "00838f"),
  dark: ("569cd6", "c586c0", "4ec9b0", "dcdcaa", "ce9178"),
  clean: ("283593", "287d3c", "b55b00", "7b3fb0", "007a82"),
  github-light: ("0969da", "1a7f37", "9a6700", "8250df", "bc4c00"),
  solarized-light: ("268bd2", "859900", "b58900", "d33682", "2aa198"),
  one-light: ("4078f2", "50a14f", "986801", "a626a4", "0184bc"),
)
/// Six built-in themes. `thesis` uses Codly's ordinary visual defaults.
#let presets = {
  let result = (
    thesis: (
      foreground: auto,
      muted: auto,
      fill: __default("line", "fill"),
      accent: __default("lang", "default-color"),
      stroke: __default("line", "stroke"),
      radius: __default("line", "radius"),
      inset: __default("line", "inset"),
      header-fill: luma(240),
      footer-fill: none,
      bubble-fill: luma(245),
      syntax: auto,
      language-colors: true,
      highlight-fill: __default("highlight", "fill"),
      file: (stroke: 0.5pt + luma(160), radius: 2pt),
      bubble: (stroke: 0.6pt + luma(80)),
      block: (__diff-colors: (:)),
    ),
    dark: __editor(
      rgb("d4d4d4"),
      rgb("1e1e1e"),
      rgb("a0a0a0"),
      rgb("569cd6"),
      rgb("2d2d2d"),
      __syntax(
        rgb("d4d4d4"),
        rgb("6a9955"),
        rgb("c586c0"),
        rgb("ce9178"),
        rgb("b5cea8"),
        rgb("dcdcaa"),
        rgb("4ec9b0"),
      ),
    )
      + (
        highlight-fill: color => color.darken(65%),
        block: (
          __diff-colors: (
            added-fill: rgb("173b25"),
            removed-fill: rgb("472124"),
            meta-fill: rgb("18344d"),
          ),
        ),
      ),
    clean: (
      foreground: auto,
      muted: luma(110),
      fill: none,
      stroke: none,
      radius: 0pt,
      header-fill: none,
      footer-fill: none,
      bubble-fill: luma(245),
      syntax: auto,
      language-colors: false,
      // lang's scalar `none` uses the language color as a fallback;
      // a callback returning `none` gives the clean preset an unpainted badge.
      lang: (fill: _ => none, stroke: none, radius: 0pt),
      file: (fill: none, stroke: none, radius: 0pt),
    ),
    github-light: __editor(
      rgb("1f2328"),
      white,
      rgb("656d76"),
      rgb("0969da"),
      rgb("f6f8fa"),
      __syntax(
        rgb("1f2328"),
        rgb("6e7781"),
        rgb("cf222e"),
        rgb("0a3069"),
        rgb("0550ae"),
        rgb("8250df"),
        rgb("953800"),
      ),
    ),
    solarized-light: __editor(
      rgb("657b83"),
      rgb("fdf6e3"),
      rgb("586e75"),
      rgb("268bd2"),
      rgb("eee8d5"),
      __syntax(
        rgb("657b83"),
        rgb("93a1a1"),
        rgb("859900"),
        rgb("2aa198"),
        rgb("d33682"),
        rgb("268bd2"),
        rgb("b58900"),
      ),
    ),
    one-light: __editor(
      rgb("383a42"),
      rgb("fafafa"),
      rgb("696c77"),
      rgb("4078f2"),
      rgb("f0f0f1"),
      __syntax(
        rgb("383a42"),
        rgb("a0a1a7"),
        rgb("a626a4"),
        rgb("50a14f"),
        rgb("986801"),
        rgb("4078f2"),
        rgb("c18401"),
      ),
    ),
  )
  for (name, palette) in __palettes {
    result.at(name).insert("highlight-colors", palette.map(rgb))
  }
  result
}

#let __sections = (
  "block",
  "line",
  "number",
  "lang",
  "file",
  "header",
  "footer",
  "highlight",
  "callout",
  "bubble",
  "annotation",
)
#let __tokens = (
  "foreground",
  "muted",
  "fill",
  "accent",
  "stroke",
  "radius",
  "inset",
  "header-fill",
  "footer-fill",
  "bubble-fill",
  "syntax",
  "highlight-fill",
  "highlight-colors",
  "language-colors",
)

// Merge element sections one field at a time, while replacing paints, fill
// palettes, callbacks, and the nested values of each field as complete values.
#let __merge(base, overrides) = {
  for (key, value) in overrides {
    assert(key in (__tokens + __sections), message: "codly: unknown theme setting: " + key)
    if key in __sections {
      assert(type(value) == dictionary, message: "codly: theme " + key + " must be a dictionary")
      base.insert(key, base.at(key, default: (:)) + value)
    } else {
      base.insert(key, value)
    }
  }
  base
}

/// Define a theme from a preset or theme dictionary.
/// Element dictionaries override shared tokens; their `text` key accepts native text settings.
#let define(base: "thesis", ..overrides) = {
  assert(overrides.pos().len() == 0, message: "codly: theme overrides must be named")
  assert(type(base) in (str, dictionary), message: "codly: a theme must be a name or dictionary")
  let chosen = if type(base) == str {
    assert(base in presets, message: "codly: unknown theme: " + base)
    presets.at(base)
  } else { base }
  let result = __merge(__merge(presets.thesis, chosen), overrides.named())
  let colors = result.at("highlight-colors")
  if type(colors) == array {
    assert(colors.len() > 0, message: "codly: highlight color palettes must not be empty")
  }
  if "accent" in overrides.named() and "highlight-colors" not in overrides.named() {
    // Accent overrides replace the first inherited color, unless a palette is also supplied.
    if type(colors) == array {
      result.at("highlight-colors").at(0) = result.accent
    } else {
      result.insert("highlight-colors", result.accent)
    }
  }
  result
}

/// Produce the element set rules for a theme without changing block content,
/// numbering, language definitions, or opt-in rendering features.
#let __settings(config) = {
  let settings = (
    block: (radius: config.radius),
    line: (fill: config.fill, stroke: config.stroke, inset: config.inset),
    number: (fill: auto),
    lang: (
      default-color: config.accent,
      fill: if config.at("language-colors") { __default("lang", "fill") } else {
        config.at("header-fill")
      },
      stroke: if config.at("language-colors") { __default("lang", "stroke") } else {
        config.stroke
      },
      radius: config.radius,
      inset: config.inset,
    ),
    file: (fill: config.at("header-fill"), stroke: config.stroke, radius: config.radius),
    header: (fill: config.at("header-fill")),
    footer: (fill: config.at("footer-fill")),
    highlight: (
      color: config.at("highlight-colors"),
      fill: config.at("highlight-fill"),
      stroke: __default("highlight", "stroke"),
      radius: __default("highlight", "radius"),
    ),
    callout: (fill: auto, stroke: auto),
    bubble: (fill: config.at("bubble-fill"), stroke: config.stroke),
    annotation: (:),
  )
  for name in __sections {
    settings.at(name) += config.at(name, default: (:))
  }
  settings
}

/// Apply a theme through scoped set rules. Custom elements retain their normal
/// precedence: explicit fields and subsequent local set rules win.
#let __apply-elements(body, settings, elements) = {
  let rules = ()
  for name in __sections {
    let fields = settings.at(name)
    let typography = fields.remove("text", default: (:))
    rules.push(e.set_(elements.at(name), ..fields))
    if typography.len() > 0 {
      rules.push(e.show_(elements.at(name), it => e.get(get => {
        let typography = get(__style).typography.at(name, default: (:))
        show text: set text(..typography)
        it
      })))
    }
  }
  show: e.apply(..rules)
  body
}

#let apply(body, config: none, elements: none) = context {
  let foreground = if config.foreground == auto { text.fill } else { config.foreground }
  let muted = if config.muted == auto { foreground } else { config.muted }
  let settings = __settings(config)
  settings.number.text = (fill: muted) + settings.number.at("text", default: (:))
  let typography = (:)
  for name in __sections {
    typography.insert(name, settings.at(name).at("text", default: (:)))
  }
  show: e.set_(
    __style,
    foreground: foreground,
    syntax: config.syntax,
    typography: typography,
  )
  // Set raw.theme inside Codly, including strings/files turned into raw by
  // its renderer; ordinary inline and standalone raw keep their own styling.
  // Typst ignores tmTheme's foreground for unstyled tokens. Apply it to the
  // raw.line container so styled syntax tokens can still override it (#108).
  show: e.show_(elements.block, it => e.get(get => {
    let style = get(__style)
    let foreground = style.foreground
    set raw(theme: style.syntax)
    set text(fill: foreground)
    show raw.line: set text(fill: foreground)
    it
  }))
  __apply-elements(body, settings, elements)
}
