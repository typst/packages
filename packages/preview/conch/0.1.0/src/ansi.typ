#import "theme.typ": _resolve-theme

// =========================================================================
// Layer 2: ANSI renderer — parse and render ANSI escape sequences
// =========================================================================

#let _has-ansi(s) = { s.contains("\u{1b}") }

/// Render a string containing ANSI escape sequences with proper colors.
/// Works standalone or inside a terminal-frame.
///
/// ```typst
/// #render-ansi("\u{1b}[32mOK\u{1b}[0m build passed", theme: "dracula")
/// ```
#let render-ansi(body, theme: "dracula") = {
  let t = _resolve-theme(theme)
  let ansi-colors = t.ansi
  let default-fg = t.fg
  let color-map = (
    "31": ansi-colors.red,
    "32": ansi-colors.green,
    "33": ansi-colors.yellow,
    "34": ansi-colors.blue,
    "35": ansi-colors.magenta,
    "36": ansi-colors.cyan,
    "37": ansi-colors.white,
    "91": ansi-colors.bright-red,
    "92": ansi-colors.bright-green,
    "93": ansi-colors.bright-yellow,
    "94": ansi-colors.bright-blue,
    "95": ansi-colors.bright-magenta,
    "96": ansi-colors.bright-cyan,
    "97": ansi-colors.bright-white,
  )
  let input = "\u{1b}[0m" + body
  let current-fill = default-fg
  let current-weight = "regular"
  for m in input.matches(regex("\u{1b}\\[([0-9;]*)m([^\u{1b}]*)")) {
    let codes = m.captures.at(0)
    let content = m.captures.at(1)
    for code in codes.split(";") {
      if code == "0" {
        current-fill = default-fg
        current-weight = "regular"
      } else if code == "1" { current-weight = "bold" } else if (
        code in color-map
      ) { current-fill = color-map.at(code) }
    }
    if content != "" {
      let parts = content.split("\n")
      for (i, part) in parts.enumerate() {
        if i > 0 { linebreak() }
        if part != "" {
          text(fill: current-fill, weight: current-weight)[#part]
        }
      }
    }
  }
}

// Internal variant that takes resolved theme + colors directly
#let _render-ansi-raw(body, default-fg, ansi-colors) = {
  let color-map = (
    "31": ansi-colors.red,
    "32": ansi-colors.green,
    "33": ansi-colors.yellow,
    "34": ansi-colors.blue,
    "35": ansi-colors.magenta,
    "36": ansi-colors.cyan,
    "37": ansi-colors.white,
    "91": ansi-colors.bright-red,
    "92": ansi-colors.bright-green,
    "93": ansi-colors.bright-yellow,
    "94": ansi-colors.bright-blue,
    "95": ansi-colors.bright-magenta,
    "96": ansi-colors.bright-cyan,
    "97": ansi-colors.bright-white,
  )
  let input = "\u{1b}[0m" + body
  let current-fill = default-fg
  let current-weight = "regular"
  for m in input.matches(regex("\u{1b}\\[([0-9;]*)m([^\u{1b}]*)")) {
    let codes = m.captures.at(0)
    let content = m.captures.at(1)
    for code in codes.split(";") {
      if code == "0" {
        current-fill = default-fg
        current-weight = "regular"
      } else if code == "1" { current-weight = "bold" } else if (
        code in color-map
      ) { current-fill = color-map.at(code) }
    }
    if content != "" {
      let parts = content.split("\n")
      for (i, part) in parts.enumerate() {
        if i > 0 { linebreak() }
        if part != "" {
          text(fill: current-fill, weight: current-weight)[#part]
        }
      }
    }
  }
}
