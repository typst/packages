/// Theme management for the assignment template.
/// Provides preset palettes (nord-light, catppuccin-latte, paper, github-light)
/// and state-based theme switching.

#let themes = (
  "nord-light": (
    name: "nord-light",
    primary: rgb("#5E81AC"),
    accent: rgb("#88C0D0"),
    text: rgb("#2E3440"),
    text-muted: rgb("#4C566A"),
    background: rgb("#FFFFFF"),
    surface: rgb("#F8FAFC"),
    border: rgb("#E5E9F0"),
    border-dark: rgb("#D8DEE9"),
    code-bg: rgb("#F2F4F8"),
    info: rgb("#5E81AC"),
    tip: rgb("#A3BE8C"),
    warning: rgb("#D08770"),
  ),

  "catppuccin-latte": (
    name: "catppuccin-latte",
    primary: rgb("#1e66f5"),
    accent: rgb("#179299"),
    text: rgb("#4c4f69"),
    text-muted: rgb("#6c6f85"),
    background: rgb("#eff1f5"),
    surface: rgb("#e6e9ef"),
    border: rgb("#ccd0da"),
    border-dark: rgb("#bcc0cc"),
    code-bg: rgb("#e6e9ef"),
    info: rgb("#1e66f5"),
    tip: rgb("#40a02b"),
    warning: rgb("#df8e1d"),
  ),

  "paper": (
    name: "paper",
    primary: rgb("#111111"),
    accent: rgb("#444444"),
    text: rgb("#111111"),
    text-muted: rgb("#666666"),
    background: rgb("#ffffff"),
    surface: rgb("#f9f9f9"),
    border: rgb("#e0e0e0"),
    border-dark: rgb("#cccccc"),
    code-bg: rgb("#f5f5f5"),
    info: rgb("#111111"),
    tip: rgb("#333333"),
    warning: rgb("#555555"),
  ),

  "github-light": (
    name: "github-light",
    primary: rgb("#0969da"),
    accent: rgb("#0550ae"),
    text: rgb("#1f2328"),
    text-muted: rgb("#636c76"),
    background: rgb("#ffffff"),
    surface: rgb("#f6f8fa"),
    border: rgb("#d0d7de"),
    border-dark: rgb("#afb8c1"),
    code-bg: rgb("#f6f8fa"),
    info: rgb("#0969da"),
    tip: rgb("#1a7f37"),
    warning: rgb("#9a6700"),
  ),
)

#let default-theme = themes.at("nord-light")

#let active-theme-name = state("assignment-theme-name", "nord-light")
#let active-theme-overrides = state("assignment-theme-overrides", (:))
#let active-theme = state("assignment-active-theme", default-theme)

/// Set or update the active theme.
#let set-theme(theme-target) = {
  if type(theme-target) == str {
    active-theme-name.update(theme-target)
    active-theme-overrides.update((:))
    active-theme.update(themes.at(theme-target, default: default-theme))
  } else if type(theme-target) == dictionary {
    active-theme-overrides.update(theme-target)
    active-theme.update(default-theme + theme-target)
  }
}

/// Resolves theme dictionary with optional color overrides.
#let resolve-theme(theme-target, primary: none, accent: none) = {
  let base = if type(theme-target) == str {
    themes.at(theme-target, default: default-theme)
  } else if type(theme-target) == dictionary {
    default-theme + theme-target
  } else {
    default-theme
  }

  let overrides = (:)
  if primary != none { overrides.insert("primary", primary) }
  if accent != none { overrides.insert("accent", accent) }

  let t = base + overrides
  if "info" not in t { t.insert("info", t.primary) }
  if "tip" not in t { t.insert("tip", rgb("#40a02b")) }
  if "warning" not in t { t.insert("warning", rgb("#df8e1d")) }
  if "code-bg" not in t { t.insert("code-bg", t.surface) }
  if "border-dark" not in t { t.insert("border-dark", t.border.darken(10%)) }
  if "highlight" not in t { t.insert("highlight", t.primary.lighten(92%)) }
  if "secondary" not in t { t.insert("secondary", t.text-muted) }
  if "success" not in t { t.insert("success", t.tip) }
  t
}
