#import "modules/page_settings.typ": page-setup
#import "modules/figure_setup.typ": figure_setup
#import "modules/code_setup.typ": code_setup
#import "modules/cover.typ": cover-page
#import "modules/outline.typ": outline_with_sizes
#import "modules/references.typ": references-page
#import "modules/appendix.typ": appendix-page
#import "presets/course-report.typ": course-report
#import "presets/cs-thesis.typ": cs-thesis
#import "modules/thesis.typ": thesis-report

#let presets = (
  "course-report": course-report,
  "cs-thesis": cs-thesis,
)

#let font_config = (
  latin: ("Times New Roman", "Libertinus Serif"),
  song: ("SimSun", "Noto Serif CJK SC"),
  hei: ("SimHei", "Noto Sans CJK SC"),
  kai: ("KaiTi", "Noto Serif CJK SC"),
  cover: ("STZhongsong", "Noto Serif CJK SC"),
)

#let page_config = (
  paper: "a4",
  margin: (top: 9.5em),
  header-font: font_config.kai,
  footer-font: font_config.cover,
)

#let bibliography_config = (
  style: "gb-7714-2015-numeric",
  font: (..font_config.latin, ..font_config.song),
  title-font: (..font_config.latin, ..font_config.hei),
)

#let appendix_style = (
  font: (..font_config.latin, ..font_config.hei),
  size: 18pt,
)

#let content_style = state("report-content-style", (
  bibliography: bibliography_config,
  appendix: appendix_style,
))

#let references(source: none, title: [参考文献], full: false, style: auto) = context {
  assert(source != none, message: "请在主文件中使用 references(source: path(\"references.bib\"))")
  let settings = content_style.get().bibliography
  if style != auto { settings += (style: style) }
  references-page(..(settings + (source: source, title: title, full: full)))
}

#let appendix(title: none, body) = context {
  appendix-page(title: title, ..content_style.get().appendix, body)
}

#let thesis_config = (
  margin: (left: 1.25in, right: 1.25in, top: 1.28in, bottom: 1.06in),
  leading: 0.8em,
  heading-sizes: (18pt, 14pt, 12pt),
  cover: (
    logo-top: 151pt,
    heading-top: 221pt,
    title-top: 326pt,
    fields-top: 441pt,
    row-height: 46.656pt,
    date-top: 703pt,
    min-gap: 18pt,
  ),
)

#let report(
  preset: "course-report", cover: (:), outline: (:),
  front-matter: (:), statement: auto, acknowledgments: auto, body,
) = {
  assert(preset in presets, message: "未知配置集：" + preset)
  let defaults = presets.at(preset)
  let cover = defaults.cover + cover
  let outline = defaults.outline + outline
  let is-thesis = defaults.at("layout", default: "course-report") == "cs-thesis"
  let bibliography = bibliography_config + defaults.at("bibliography", default: (:))
  if is-thesis { bibliography += (outlined: true, title-size: 18pt) }
  let body = [
    #content_style.update((bibliography: bibliography, appendix: appendix_style))
    #body
  ]

  if is-thesis {
    return thesis-report(
      cover, outline,
      defaults.front-matter + front-matter,
      if statement == auto { defaults.statement } else { statement },
      if acknowledgments == auto { defaults.acknowledgments } else { acknowledgments },
      font_config, thesis_config, body,
    )
  }

  show: page-setup.with(..page_config)
  show: figure_setup.with(font: (..font_config.latin, ..font_config.hei))
  show: code_setup

  set text(font: (..font_config.latin, ..font_config.song), size: 12pt, lang: "zh")
  show heading: set text(font: (..font_config.latin, ..font_config.hei))

  cover-page(title-font: font_config.cover, font: font_config.cover, ..cover)
  outline_with_sizes(
    font: (..font_config.latin, ..font_config.song),
    title-font: (..font_config.latin, ..font_config.hei),
    ..outline,
  )
  body
}
