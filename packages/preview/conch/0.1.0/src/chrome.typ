/// Window chrome presets — title bar styles for different OS looks.
/// Each preset is (bar: function(title, t, f) -> content, radius: length).

// ---------------------------------------------------------------------------
// macOS — three colored circles, centered title, rounded corners
// ---------------------------------------------------------------------------
#let _chrome-macos = (
  bar: (title, theme, font) => block(
    fill: theme.title-bg,
    width: 100%,
    inset: (x: 12pt, y: 8pt),
    {
      box(circle(fill: rgb("#ff5f57"), radius: 5pt))
      h(6pt)
      box(circle(fill: rgb("#febc2e"), radius: 5pt))
      h(6pt)
      box(circle(fill: rgb("#28c840"), radius: 5pt))
      h(1fr)
      if title != "" { text(..font, fill: theme.title-fg)[#title] }
      h(1fr)
      box(width: 42pt) // balance the circles
    },
  ),
  radius: 8pt,
)

// ---------------------------------------------------------------------------
// Windows (classic) — left title, square ─ □ ✕ buttons, sharp corners
// ---------------------------------------------------------------------------
#let _win-btn(content, f, fg, bg: none) = box(
  fill: bg,
  width: 32pt,
  height: 22pt,
  align(center + horizon, text(..f, fill: fg, size: 9pt)[#content]),
)

#let _chrome-windows = (
  bar: (title, theme, font) => block(
    fill: theme.title-bg,
    width: 100%,
    inset: (x: 12pt, y: 6pt),
    {
      if title != "" {
        box(height: 22pt, align(horizon, text(
          ..font,
          fill: theme.title-fg,
        )[#title]))
      }
      h(1fr)
      _win-btn([\u{2500}], font, theme.title-fg) // ─ minimize
      _win-btn([\u{25A1}], font, theme.title-fg) // □ maximize
      _win-btn([\u{2715}], font, white, bg: rgb("#e81123")) // ✕ close
    },
  ),
  radius: 0pt,
)

// ---------------------------------------------------------------------------
// Windows Terminal — tab-style title, modern buttons, rounded top
// ---------------------------------------------------------------------------
#let _chrome-windows-terminal = (
  bar: (title, theme, font) => block(
    fill: theme.title-bg,
    width: 100%,
    inset: (x: 8pt, y: 5pt),
    {
      box(
        fill: theme.bg,
        radius: (top-left: 6pt, top-right: 6pt),
        inset: (x: 14pt, y: 5pt),
        {
          if title != "" {
            text(..font, fill: theme.title-fg, size: 8pt)[#title]
          }
        },
      )
      h(1fr)
      _win-btn([\u{2500}], font, theme.title-fg)
      _win-btn([\u{25A1}], font, theme.title-fg)
      _win-btn([\u{2715}], font, white, bg: rgb("#e81123"))
    },
  ),
  radius: (top: 8pt, bottom: 0pt),
)

// ---------------------------------------------------------------------------
// GNOME — centered title, single close circle on the right
// ---------------------------------------------------------------------------
#let _chrome-gnome = (
  bar: (title, theme, font) => block(
    fill: theme.title-bg,
    width: 100%,
    inset: (x: 12pt, y: 7pt),
    {
      box(width: 22pt) // balance the close button
      h(1fr)
      if title != "" { text(..font, fill: theme.title-fg)[#title] }
      h(1fr)
      box(
        circle(
          fill: theme.title-fg.transparentize(50%),
          radius: 10pt,
          align(center + horizon, text(
            ..font,
            fill: theme.title-bg,
            size: 9pt,
            weight: "bold",
          )[\u{2715}]),
        ),
      )
    },
  ),
  radius: 10pt,
)

// ---------------------------------------------------------------------------
// Plain — no title bar, minimal radius
// ---------------------------------------------------------------------------
#let _chrome-plain = (
  bar: (title, theme, font) => none,
  radius: 4pt,
)

// ---------------------------------------------------------------------------
// Preset registry
// ---------------------------------------------------------------------------
#let _chrome-presets = (
  macos: _chrome-macos,
  windows: _chrome-windows,
  windows-terminal: _chrome-windows-terminal,
  gnome: _chrome-gnome,
  plain: _chrome-plain,
)

/// Resolve chrome: string name → preset, function → wrap as bar, dictionary → use directly.
#let _resolve-chrome(chrome) = {
  if chrome == auto { _chrome-macos } else if type(chrome) == str {
    _chrome-presets.at(chrome, default: _chrome-macos)
  } else if type(chrome) == function { (bar: chrome, radius: 8pt) } else if (
    type(chrome) == dictionary
  ) { _chrome-presets.macos + chrome } else { _chrome-macos }
}
