#import "src/theme.typ": active-theme, active-theme-name, active-theme-overrides, resolve-theme, set-theme, themes
#import "src/helpers.typ": format-date, get-meta-pairs, render-cover-divider, render-cover-logo, render-divider, render-logo
#import "src/cover.typ": (
  assignment-cover, render-cover-architecture, render-cover-classic, render-cover-editorial, render-cover-geometric,
  render-cover-minimal, render-cover-modern, render-cover-swiss, render-header-banner, title-page,
)
#import "src/components.typ": ans, answer, kv-table, kvtable, note, que, question, question-counter, watermark
#import "src/layout.typ": assignment, template

#let colors = themes.at("nord-light")
