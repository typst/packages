#import "theme.typ": _resolve-font, _resolve-style, _resolve-theme
#import "chrome.typ": _resolve-chrome

// =========================================================================
// Layer 1: Terminal frame — a reusable themed terminal window
// =========================================================================

/// Render content inside a terminal window frame.
/// No shell, no WASM — just the visual chrome around arbitrary content.
///
/// ```typst
/// #terminal-frame(title: "my-app", theme: "dracula")[
///   #text(fill: green)[$ cargo build]
///   Compiling my-app v0.1.0
///   Finished release target
/// ]
/// ```
#let terminal-frame(
  body,
  title: none,
  theme: "dracula",
  font: auto,
  chrome: "macos",
  style: auto,
  width: auto,
  height: auto,
) = {
  let theme = _resolve-theme(theme)
  let font = _resolve-font(font)
  let chrome = _resolve-chrome(chrome)
  let style = _resolve-style(style)
  let term-width = if width == auto { 560pt } else { width }
  let term-height = if height == auto { auto } else { height }
  let title-text = if title != none { title } else { "" }
  let title-bar = (chrome.bar)(title-text, theme, font)

  block(
    fill: theme.bg,
    radius: chrome.radius,
    clip: true,
    width: term-width,
    height: term-height,
    {
      if title-bar != none { title-bar }

      // Body
      block(inset: style.inset, width: 100%, {
        set text(..font, fill: theme.fg)
        set par(leading: style.leading)
        body
      })
    },
  )
}
