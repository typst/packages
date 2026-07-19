// ---------------------------------------------------------------------------
// Themes — each includes terminal chrome colors + ANSI 16-color palette
// ---------------------------------------------------------------------------

#let themes = (
  dracula: (
    bg: rgb("#282a36"),
    fg: rgb("#f8f8f2"),
    prompt-user: rgb("#50fa7b"),
    prompt-path: rgb("#bd93f9"),
    prompt-sym: rgb("#f8f8f2"),
    title-bg: rgb("#44475a"),
    title-fg: rgb("#f8f8f2"),
    error: rgb("#ff5555"),
    cursor: rgb("#f8f8f2"),
    ansi: (
      red: rgb("#FF5555"),
      green: rgb("#50FA7B"),
      yellow: rgb("#F1FA8C"),
      blue: rgb("#BD93F9"),
      magenta: rgb("#FF79C6"),
      cyan: rgb("#8BE9FD"),
      white: rgb("#F8F8F2"),
      bright-red: rgb("#FF6E6E"),
      bright-green: rgb("#69FF94"),
      bright-yellow: rgb("#FFFFA5"),
      bright-blue: rgb("#D6ACFF"),
      bright-magenta: rgb("#FF92DF"),
      bright-cyan: rgb("#A4FFFF"),
      bright-white: rgb("#FFFFFF"),
    ),
  ),
  catppuccin: (
    bg: rgb("#1e1e2e"),
    fg: rgb("#cdd6f4"),
    prompt-user: rgb("#a6e3a1"),
    prompt-path: rgb("#89b4fa"),
    prompt-sym: rgb("#cdd6f4"),
    title-bg: rgb("#313244"),
    title-fg: rgb("#cdd6f4"),
    error: rgb("#f38ba8"),
    cursor: rgb("#cdd6f4"),
    ansi: (
      red: rgb("#F38BA8"),
      green: rgb("#A6E3A1"),
      yellow: rgb("#F9E2AF"),
      blue: rgb("#89B4FA"),
      magenta: rgb("#CBA6F7"),
      cyan: rgb("#94E2D5"),
      white: rgb("#CDD6F4"),
      bright-red: rgb("#F38BA8"),
      bright-green: rgb("#A6E3A1"),
      bright-yellow: rgb("#F9E2AF"),
      bright-blue: rgb("#89B4FA"),
      bright-magenta: rgb("#CBA6F7"),
      bright-cyan: rgb("#94E2D5"),
      bright-white: rgb("#FFFFFF"),
    ),
  ),
  monokai: (
    bg: rgb("#272822"),
    fg: rgb("#f8f8f2"),
    prompt-user: rgb("#a6e22e"),
    prompt-path: rgb("#66d9ef"),
    prompt-sym: rgb("#f8f8f2"),
    title-bg: rgb("#3e3d32"),
    title-fg: rgb("#f8f8f2"),
    error: rgb("#f92672"),
    cursor: rgb("#f8f8f2"),
    ansi: (
      red: rgb("#F92672"),
      green: rgb("#A6E22E"),
      yellow: rgb("#E6DB74"),
      blue: rgb("#66D9EF"),
      magenta: rgb("#AE81FF"),
      cyan: rgb("#66D9EF"),
      white: rgb("#F8F8F2"),
      bright-red: rgb("#F92672"),
      bright-green: rgb("#A6E22E"),
      bright-yellow: rgb("#E6DB74"),
      bright-blue: rgb("#66D9EF"),
      bright-magenta: rgb("#AE81FF"),
      bright-cyan: rgb("#66D9EF"),
      bright-white: rgb("#FFFFFF"),
    ),
  ),
  retro: (
    bg: rgb("#0a0a0a"),
    fg: rgb("#33ff33"),
    prompt-user: rgb("#33ff33"),
    prompt-path: rgb("#33ff33"),
    prompt-sym: rgb("#33ff33"),
    title-bg: rgb("#1a1a1a"),
    title-fg: rgb("#33ff33"),
    error: rgb("#ff3333"),
    cursor: rgb("#33ff33"),
    ansi: (
      red: rgb("#FF3333"),
      green: rgb("#33FF33"),
      yellow: rgb("#FFFF33"),
      blue: rgb("#3333FF"),
      magenta: rgb("#FF33FF"),
      cyan: rgb("#33FFFF"),
      white: rgb("#CCCCCC"),
      bright-red: rgb("#FF6666"),
      bright-green: rgb("#66FF66"),
      bright-yellow: rgb("#FFFF66"),
      bright-blue: rgb("#6666FF"),
      bright-magenta: rgb("#FF66FF"),
      bright-cyan: rgb("#66FFFF"),
      bright-white: rgb("#FFFFFF"),
    ),
  ),
  solarized: (
    bg: rgb("#002b36"),
    fg: rgb("#839496"),
    prompt-user: rgb("#859900"),
    prompt-path: rgb("#268bd2"),
    prompt-sym: rgb("#839496"),
    title-bg: rgb("#073642"),
    title-fg: rgb("#93a1a1"),
    error: rgb("#dc322f"),
    cursor: rgb("#839496"),
    ansi: (
      red: rgb("#DC322F"),
      green: rgb("#859900"),
      yellow: rgb("#B58900"),
      blue: rgb("#268BD2"),
      magenta: rgb("#D33682"),
      cyan: rgb("#2AA198"),
      white: rgb("#EEE8D5"),
      bright-red: rgb("#CB4B16"),
      bright-green: rgb("#859900"),
      bright-yellow: rgb("#B58900"),
      bright-blue: rgb("#268BD2"),
      bright-magenta: rgb("#6C71C4"),
      bright-cyan: rgb("#2AA198"),
      bright-white: rgb("#FDF6E3"),
    ),
  ),
  gruvbox: (
    bg: rgb("#282828"),
    fg: rgb("#ebdbb2"),
    prompt-user: rgb("#b8bb26"),
    prompt-path: rgb("#83a598"),
    prompt-sym: rgb("#ebdbb2"),
    title-bg: rgb("#3c3836"),
    title-fg: rgb("#ebdbb2"),
    error: rgb("#fb4934"),
    cursor: rgb("#ebdbb2"),
    ansi: (
      red: rgb("#CC241D"),
      green: rgb("#98971A"),
      yellow: rgb("#D79921"),
      blue: rgb("#458588"),
      magenta: rgb("#B16286"),
      cyan: rgb("#689D6A"),
      white: rgb("#EBDBB2"),
      bright-red: rgb("#FB4934"),
      bright-green: rgb("#B8BB26"),
      bright-yellow: rgb("#FABD2F"),
      bright-blue: rgb("#83A598"),
      bright-magenta: rgb("#D3869B"),
      bright-cyan: rgb("#8EC07C"),
      bright-white: rgb("#EBDBB2"),
    ),
  ),
)

/// Default font settings. Keys match Typst's `text()` parameters,
/// so the resolved dict can be spread directly: `set text(..f)`.
#let _default-font = (
  font: (
    "JetBrains Mono",
    "Menlo",
    "Monaco",
    "DejaVu Sans Mono",
    "Courier New",
  ),
  size: 9pt,
)

/// Resolve font: auto → defaults, dictionary → merge with defaults.
/// Pass any valid `text()` parameter (font, size, weight, style,
/// tracking, ligatures, etc.) and it will be applied.
#let _resolve-font(font) = {
  if font == auto { _default-font } else if type(font) == dictionary {
    _default-font + font
  } else { _default-font }
}

/// Default layout style. Override any key to customize spacing.
#let _default-style = (
  inset: (x: 12pt, y: 6pt),
  leading: 0.4em,
)

/// Resolve style: auto → defaults, dictionary → merge with defaults.
#let _resolve-style(style) = {
  if style == auto { _default-style } else if type(style) == dictionary {
    _default-style + style
  } else { _default-style }
}

/// Resolve a theme: accepts a built-in name (string) or a custom dictionary.
#let _resolve-theme(theme) = {
  if type(theme) == str { themes.at(theme) } else if type(theme) == dictionary {
    theme
  } else { themes.at("dracula") }
}
