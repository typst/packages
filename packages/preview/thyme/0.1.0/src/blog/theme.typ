// Perceptual `oklch` monochrome theme tokens, configurable font stacks,
// layout geometry, and content-addressed CSS stylesheet builder for the `blog` preset.

#import "../text.typ": short-hash

#let stylesheet-asset-path = "css/style.css"

#let _stix-cdn = "https://cdn.jsdelivr.net/gh/stipub/stixfonts@v2.13b171/fonts/static_otf_woff2/"
#let _commit-mono-cdn = "https://cdn.jsdelivr.net/npm/@fontsource/commit-mono@5.2.5/files/commit-mono-"

/// Canonical `.woff2` filenames expected under `theme.font-base` when self-hosting
/// upstream _STIX Two_ (`v2.13b171`) and _Commit Mono_ (`v1.143`) web fonts.
/// -> array
#let default-woff2-files = (
  "STIXTwoText-Regular.woff2",
  "STIXTwoText-Italic.woff2",
  "STIXTwoText-SemiBold.woff2",
  "STIXTwoText-SemiBoldItalic.woff2",
  "STIXTwoText-Bold.woff2",
  "STIXTwoText-BoldItalic.woff2",
  "STIXTwoMath-Regular.woff2",
  "CommitMono-400-Regular.woff2",
  "CommitMono-400-Italic.woff2",
  "CommitMono-700-Regular.woff2",
  "CommitMono-700-Italic.woff2",
)

#let _normalize-font-base(base) = {
  let s = str(base).trim()
  if s == "" {
    none
  } else if (
    s.starts-with("http://") or s.starts-with("https://") or s.starts-with("/")
  ) {
    s.trim("/", at: end) + "/"
  } else {
    "/" + s.trim("/") + "/"
  }
}

// `font-weight` and `font-style` are CSS keywords/numbers, not strings: quoting
// them (`font-weight: "400"`) is an invalid declaration the browser discards, so
// every face loses its weight and style descriptor and the family degrades to a
// single face. Only `font-family` and `src` take quoted values.
/// Format any Typst `color` as a lowercase `#rrggbb` hex string, for contexts that
/// need a plain sRGB literal rather than `oklch(...)` (e.g. `<meta name="theme-color">`).
/// -> str
#let css-hex(col) = {
  let (r, g, b, ..) = rgb(col).components()
  let h(v) = {
    // Channels are ratios in 0..1. Scale to an integer 0..255, then print it in
    // base 16 and pad to two digits so low channels do not collapse to `#f22`.
    let digits = str(int(calc.round(float(v) * 255)), base: 16)
    if digits.len() == 1 { "0" + digits } else { digits }
  }
  "#" + h(r) + h(g) + h(b)
}

#let _font-face-rule(family, url, weight, style) = (
  "@font-face {\n  font-family: \""
    + family
    + "\";\n  src: url(\""
    + url
    + "\") format(\"woff2\");\n  font-weight: "
    + str(weight)
    + ";\n  font-style: "
    + style
    + ";\n  font-display: swap;\n}"
)

// Build deterministic `@font-face` rules without `local(...)` so OS-installed stripped
// subsets (e.g. Google Fonts' STIX Two Text without `smcp`/`c2sc`/`onum`) can never
// shadow the pinned upstream or self-hosted `.woff2` binaries.
#let _build-builtin-font-faces(font-base: none, font-version: none) = {
  let base = if font-base != none { _normalize-font-base(font-base) } else {
    none
  }
  let q = if font-version != none and str(font-version) != "" {
    "?v=" + str(font-version)
  } else {
    ""
  }
  let stix-prefix = if base != none { base } else { _stix-cdn }
  let cm-url = (self-file, cdn-suffix) => if base != none {
    base + self-file + q
  } else {
    _commit-mono-cdn + cdn-suffix + q
  }
  (
    "STIX Two Text": (
      _font-face-rule(
        "STIX Two Text",
        stix-prefix + "STIXTwoText-Regular.woff2" + q,
        400,
        "normal",
      ),
      _font-face-rule(
        "STIX Two Text",
        stix-prefix + "STIXTwoText-Italic.woff2" + q,
        400,
        "italic",
      ),
      _font-face-rule(
        "STIX Two Text",
        stix-prefix + "STIXTwoText-SemiBold.woff2" + q,
        600,
        "normal",
      ),
      _font-face-rule(
        "STIX Two Text",
        stix-prefix + "STIXTwoText-SemiBoldItalic.woff2" + q,
        600,
        "italic",
      ),
      _font-face-rule(
        "STIX Two Text",
        stix-prefix + "STIXTwoText-Bold.woff2" + q,
        700,
        "normal",
      ),
      _font-face-rule(
        "STIX Two Text",
        stix-prefix + "STIXTwoText-BoldItalic.woff2" + q,
        700,
        "italic",
      ),
    ).join("\n\n"),
    "STIX Two Math": _font-face-rule(
      "STIX Two Math",
      stix-prefix + "STIXTwoMath-Regular.woff2" + q,
      400,
      "normal",
    ),
    "CommitMono": (
      _font-face-rule(
        "CommitMono",
        cm-url("CommitMono-400-Regular.woff2", "latin-400-normal.woff2"),
        400,
        "normal",
      ),
      _font-face-rule(
        "CommitMono",
        cm-url("CommitMono-400-Italic.woff2", "latin-400-italic.woff2"),
        400,
        "italic",
      ),
      _font-face-rule(
        "CommitMono",
        cm-url("CommitMono-700-Regular.woff2", "latin-700-normal.woff2"),
        700,
        "normal",
      ),
      _font-face-rule(
        "CommitMono",
        cm-url("CommitMono-700-Italic.woff2", "latin-700-italic.woff2"),
        700,
        "italic",
      ),
    ).join("\n\n"),
  )
}

// Convert any Typst `color` into a perceptual CSS Color 4 `oklch(...)` string.
#let css-oklch(col) = {
  let (l, c, h, a) = oklch(col).components()
  let c-clean = if calc.abs(c) < 0.0005 { 0 } else { calc.round(c, digits: 4) }
  let h-clean = if c-clean == 0 { "0" } else {
    str(calc.round(h.deg(), digits: 2)) + "deg"
  }
  let l-str = str(calc.round(l / 1%, digits: 2)) + "%"
  if a < 100% {
    (
      "oklch(" + l-str + " " + str(c-clean) + " " + h-clean + " / " + str(calc.round(a / 1%, digits: 2)) + "%)"
    )
  } else {
    "oklch(" + l-str + " " + str(c-clean) + " " + h-clean + ")"
  }
}

#let _font-list(fonts) = {
  if type(fonts) == str {
    (fonts,)
  } else if type(fonts) == array {
    fonts.map(str)
  } else {
    ()
  }
}

#let _css-font-stack(fonts, generic-tail) = {
  let expanded = ()
  for f in _font-list(fonts) {
    expanded.push(f)
    if f == "CommitMono" and "Commit Mono" not in expanded {
      expanded.push("Commit Mono")
    }
  }
  let quoted = expanded.map(f => "\"" + f.replace("\"", "") + "\"")
  (quoted + generic-tail).join(", ")
}

/// Default perceptual `oklch(L, 0, 0deg)` monochrome palette, unified _STIX Two_ +
/// _Helvetica Neue_ + _Commit Mono_ font stacks, and paged preview geometry.
/// -> dictionary
#let theme-default = (
  paper-light: oklch(96%, 0, 0deg),
  text-light: oklch(21%, 0, 0deg),
  muted-light: oklch(47%, 0, 0deg),
  border-light: oklch(47%, 0, 0deg),
  frame-light: oklch(21%, 0, 0deg),
  surface-1-light: oklch(96%, 0, 0deg),
  surface-2-light: oklch(92%, 0, 0deg),
  paper-dark: oklch(17%, 0, 0deg),
  text-dark: oklch(95%, 0, 0deg),
  muted-dark: oklch(70%, 0, 0deg),
  border-dark: oklch(70%, 0, 0deg),
  frame-dark: oklch(95%, 0, 0deg),
  surface-1-dark: oklch(17%, 0, 0deg),
  surface-2-dark: oklch(27%, 0, 0deg),
  serif-fonts: (
    "STIX Two Text",
    "Libertinus Serif",
  ),
  math-fonts: (
    "STIX Two Math",
    "New Computer Modern Math",
  ),
  sans-fonts: (
    "Helvetica Neue",
    "Helvetica",
    "Arial",
    "DejaVu Sans",
  ),
  mono-fonts: (
    "CommitMono",
    "DejaVu Sans Mono",
  ),
  font-faces: auto,
  font-base: none,
  font-version: none,
  page-width: 22cm,
  margin: (
    left: 2.2cm,
    right: 7.4cm,
    top: 2.0cm,
    bottom: 2.2cm,
  ),
  font-size: 10.8pt,
)

/// Merge a user `theme` override dictionary onto `theme-default`.
/// -> dictionary
#let resolve-theme(
  /// Partial theme dictionary overriding any subset of `theme-default` keys.
  /// -> dictionary | none
  overrides,
) = {
  if overrides == none or overrides == (:) {
    theme-default
  } else {
    theme-default + overrides
  }
}

/// Resolve the active theme inside `context` (preferring any enclosing per-post
/// `<blog-post-theme>` override over the site-wide `<site-config>`).
/// -> dictionary
#let active-theme() = {
  let post-themes = query(selector(<blog-post-theme>).before(here()))
  if post-themes.len() > 0 {
    post-themes.last().value
  } else {
    let found = query(<site-config>)
    if (
      found.len() > 0 and found.first().value.at("theme", default: none) != none
    ) {
      found.first().value.theme
    } else {
      theme-default
    }
  }
}

#let _resolve-font-faces(t) = {
  let ff = t.at("font-faces", default: auto)
  if ff == none or ff == false {
    ""
  } else if ff != auto and ff != "cdn" {
    str(ff)
  } else {
    let builtin = _build-builtin-font-faces(
      font-base: t.at("font-base", default: none),
      font-version: t.at("font-version", default: none),
    )
    let used = (
      _font-list(t.serif-fonts) + _font-list(t.math-fonts) + _font-list(t.sans-fonts) + _font-list(t.mono-fonts)
    )
    let blocks = ()
    for (fam, css-block) in builtin.pairs() {
      if fam in used {
        blocks.push(css-block)
      }
    }
    if blocks.len() > 0 { blocks.join("\n\n") } else { "" }
  }
}

/// Render `src/blog/style.css` substituting all `oklch(...)` palette tokens,
/// `--serif` / `--math` / `--sans` / `--mono` font stacks, and `@font-face` declarations from `theme`.
/// -> str
#let stylesheet-css(
  /// Theme dictionary (`theme-default` or user overrides).
  /// -> dictionary
  theme: theme-default,
) = {
  let t = resolve-theme(theme)
  let token-map = (
    "__FONT_FACES__": _resolve-font-faces(t),
    "__FONT_SERIF__": _css-font-stack(t.serif-fonts, ("Georgia", "serif")),
    "__FONT_MATH__": _css-font-stack(t.math-fonts, ("math",)),
    "__FONT_SANS__": _css-font-stack(t.sans-fonts, ("sans-serif",)),
    "__FONT_MONO__": _css-font-stack(t.mono-fonts, (
      "ui-monospace",
      "monospace",
    )),
    "__BG_LIGHT__": css-oklch(t.paper-light),
    "__FG_LIGHT__": css-oklch(t.text-light),
    "__MUTED_LIGHT__": css-oklch(t.muted-light),
    "__LINE_LIGHT__": css-oklch(t.border-light),
    "__FRAME_LIGHT__": css-oklch(t.frame-light),
    "__SURF1_LIGHT__": css-oklch(t.surface-1-light),
    "__SURF2_LIGHT__": css-oklch(t.surface-2-light),
    "__BG_DARK__": css-oklch(t.paper-dark),
    "__FG_DARK__": css-oklch(t.text-dark),
    "__MUTED_DARK__": css-oklch(t.muted-dark),
    "__LINE_DARK__": css-oklch(t.border-dark),
    "__FRAME_DARK__": css-oklch(t.frame-dark),
    "__SURF1_DARK__": css-oklch(t.surface-1-dark),
    "__SURF2_DARK__": css-oklch(t.surface-2-dark),
  )
  token-map.pairs().fold(read("style.css"), (css, pair) => css.replace(pair.at(0), pair.at(1)))
}

// Build a compact per-post `:root` CSS custom-property override block when a post inside
// a bundle overrides `theme` tokens, without discarding site-level external `stylesheets`.
#let theme-override-css(theme-config) = {
  let t = resolve-theme(theme-config)
  let bg-l = css-oklch(t.paper-light)
  let fg-l = css-oklch(t.text-light)
  let mu-l = css-oklch(t.muted-light)
  let ln-l = css-oklch(t.border-light)
  let fr-l = css-oklch(t.frame-light)
  let s1-l = css-oklch(t.surface-1-light)
  let s2-l = css-oklch(t.surface-2-light)
  let bg-d = css-oklch(t.paper-dark)
  let fg-d = css-oklch(t.text-dark)
  let mu-d = css-oklch(t.muted-dark)
  let ln-d = css-oklch(t.border-dark)
  let fr-d = css-oklch(t.frame-dark)
  let s1-d = css-oklch(t.surface-1-dark)
  let s2-d = css-oklch(t.surface-2-dark)
  (
    ":root { --bg: "
      + bg-d
      + "; --fg: "
      + fg-d
      + "; --muted: "
      + mu-d
      + "; --line: "
      + ln-d
      + "; --frame: "
      + fr-d
      + "; --surface-1: "
      + s1-d
      + "; --surface-2: "
      + s2-d
      + "; --serif: "
      + _css-font-stack(t.serif-fonts, ("Georgia", "serif"))
      + "; --math: "
      + _css-font-stack(t.math-fonts, ("math",))
      + "; --sans: "
      + _css-font-stack(t.sans-fonts, ("sans-serif",))
      + "; --mono: "
      + _css-font-stack(t.mono-fonts, ("ui-monospace", "monospace"))
      + "; }",
    "@media (prefers-color-scheme: light) { :root { --bg: "
      + bg-l
      + "; --fg: "
      + fg-l
      + "; --muted: "
      + mu-l
      + "; --line: "
      + ln-l
      + "; --frame: "
      + fr-l
      + "; --surface-1: "
      + s1-l
      + "; --surface-2: "
      + s2-l
      + "; } }",
    "@supports (color: light-dark(oklch(0% 0 0), oklch(100% 0 0))) { :root { --bg: light-dark("
      + bg-l
      + ", "
      + bg-d
      + "); --fg: light-dark("
      + fg-l
      + ", "
      + fg-d
      + "); --muted: light-dark("
      + mu-l
      + ", "
      + mu-d
      + "); --line: light-dark("
      + ln-l
      + ", "
      + ln-d
      + "); --frame: light-dark("
      + fr-l
      + ", "
      + fr-d
      + "); --surface-1: light-dark("
      + s1-l
      + ", "
      + s1-d
      + "); --surface-2: light-dark("
      + s2-l
      + ", "
      + s2-d
      + "); } }",
  ).join("\n")
}

// Compute a deterministic content-addressed `style.css?v=<hash>` href from the rendered CSS.
#let stylesheet-href(root-prefix: "", css: none, theme: theme-default) = {
  let rendered = if css != none { css } else { stylesheet-css(theme: theme) }
  root-prefix + stylesheet-asset-path + "?v=" + short-hash(rendered)
}
