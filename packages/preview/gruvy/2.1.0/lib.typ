#import "colors.typ": colors

/// Higher level abstraction for `colors`, may contain duplicates
#let theme-colors = (
  dark: (
    soft: (
      muted: colors.neutral,
      strong: colors.bright,
      fg0: colors.light0,
      fg1: colors.light1,
      fg2: colors.light2,
      fg3: colors.light3,
      fg4: colors.light4,
      bg0: colors.dark0-soft,
      bg1: colors.dark1,
      bg2: colors.dark2,
      bg3: colors.dark3,
      bg4: colors.dark4,
    ),
    medium: (
      muted: colors.neutral,
      strong: colors.bright,
      fg0: colors.light0,
      fg1: colors.light1,
      fg2: colors.light2,
      fg3: colors.light3,
      fg4: colors.light4,
      bg0: colors.dark0,
      bg1: colors.dark1,
      bg2: colors.dark2,
      bg3: colors.dark3,
      bg4: colors.dark4,
    ),
    hard: (
      muted: colors.neutral,
      strong: colors.bright,
      fg0: colors.light0,
      fg1: colors.light1,
      fg2: colors.light2,
      fg3: colors.light3,
      fg4: colors.light4,
      bg0: colors.dark0-hard,
      bg1: colors.dark1,
      bg2: colors.dark2,
      bg3: colors.dark3,
      bg4: colors.dark4,
    ),
  ),
  light: (
    soft: (
      muted: colors.neutral,
      strong: colors.faded,
      fg0: colors.dark0,
      fg1: colors.dark1,
      fg2: colors.dark2,
      fg3: colors.dark3,
      fg4: colors.dark4,
      bg0: colors.light0-soft,
      bg1: colors.light1,
      bg2: colors.light2,
      bg3: colors.light3,
      bg4: colors.light4,
    ),
    medium: (
      muted: colors.neutral,
      strong: colors.faded,
      fg0: colors.dark0,
      fg1: colors.dark1,
      fg2: colors.dark2,
      fg3: colors.dark3,
      fg4: colors.dark4,
      bg0: colors.light0,
      bg1: colors.light1,
      bg2: colors.light2,
      bg3: colors.light3,
      bg4: colors.light4,
    ),
    hard: (
      muted: colors.neutral,
      strong: colors.faded,
      fg0: colors.dark0,
      fg1: colors.dark1,
      fg2: colors.dark2,
      fg3: colors.dark3,
      fg4: colors.dark4,
      bg0: colors.light0-hard,
      bg1: colors.light1,
      bg2: colors.light2,
      bg3: colors.light3,
      bg4: colors.light4,
    ),
  ),
)

/// - theme-color (dictionary): Can be any of the presets from `theme-colors` (i.e. `theme-colors.{dark/light}.{light/medium/hard}`). Defaults to `theme-colors.dark.hard`.
/// - accent (color|none): Accent color for links, refs and footnote. Defaults to `theme-color.strong.blue`.
/// - hl (color|none): Highlight colors. Defaults to `theme-color.muted.yellow`.
/// - print (boolean): Wether or not to make the background pure white (`#FFFFFF`) and force light colors with hard contrast.
#let gruvbox(
  theme-color: theme-colors.dark.hard,
  accent: none,
  hl: none,
  print: false,
  body,
) = {
  let bg0 = theme-color.bg0

  if print {
    bg0 = white
    theme-color = theme-colors.light.hard
  }

  let fg0 = theme-color.fg0

  if accent == none {
    accent = theme-color.strong.blue
  }

  if hl == none {
    hl = theme-color.muted.yellow
  }

  set page(fill: bg0)
  set text(fill: fg0)
  set table(stroke: fg0)
  set line(stroke: fg0)
  set highlight(fill: hl)
  set raw(theme: if theme-color.fg0 == colors.dark0 {
    "gruvboxLight.tmTheme"
  } else { "gruvboxDark.tmTheme" })
  show highlight: set text(fill: fg0)
  show link: set text(fill: accent)
  show ref: set text(fill: accent)
  show footnote: set text(fill: accent)

  body
}
