// Theme entry implementation for Touying Endfield Theme.

#import "@preview/touying:0.6.3": *
#import "./slide-fns.typ": slide, new-section-slide

/// Touying endfield theme.
///
/// Example:
/// ```typst
/// #show: endfield-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))
/// ```
#let endfield-theme(
  aspect-ratio: "16-9",
  navigation: "mini-slides",
  sidebar: (
    width: 10em,
    filled: false,
    numbered: false,
    indent: .5em,
    short-heading: true,
  ),
  mini-slides: (
    height: auto,
    x: 2em,
    display-section: false,
    inline: true,
    display-subsection: true,
    spacing: .2em,
    short-heading: true,
    current-slide-sym: $triangle.small.b.filled$,
    other-slides-sym: $triangle.small.t.stroked$,
  ),
  footer: none,
  footer-right: context text(utils.slide-counter.display(), fill: rgb("#FFFA01"), weight: "black")
    + text(" / " + utils.last-slide-number, size: 0.618em),
  primary: rgb("#FFFA01"),
  alpha: 40%,
  subslide-preamble: self => block(
    text(
      1.2em,
      weight: "bold",
      fill: self.colors.primary,
      utils.display-current-heading(depth: self.slide-level, style: auto),
    ),
  ),
  ..args,
  body,
) = {
  sidebar = utils.merge-dicts(
    (
      width: 10em,
      filled: false,
      numbered: false,
      indent: .5em,
      short-heading: true,
    ),
    sidebar,
  )
  mini-slides = utils.merge-dicts(
    (
      height: auto,
      x: 2em,
      display-section: false,
      inline: true,
      display-subsection: true,
      spacing: .2em,
      short-heading: true,
      current-slide-sym: $triangle.small.b.filled$,
      other-slides-sym: $triangle.small.t.stroked$,
    ),
    mini-slides,
  )

  // Compute a dynamic default height from `inline` while preserving explicit overrides.
  if mini-slides.height == auto {
    mini-slides = utils.merge-dicts(
      mini-slides,
      (height: if mini-slides.inline { 2.5em } else { 3em },),
    )
  }

  // Extract font configuration from config-fonts if provided.
  // config-fonts returns config-store which is in args.pos().
  let font-config = args.pos().find(item => type(item) == dictionary and "fonts" in item)

  let fonts = if font-config != none {
    font-config.fonts
  } else {
    (
      cjk: ("HarmonyOS Sans SC", "Source Han Sans", "Noto Sans CJK"),
      latin: ("HarmonyOS Sans", "Source Sans 3", "Noto Sans"),
      combined: (
        "HarmonyOS Sans",
        "Source Sans 3",
        "Noto Sans",
        "HarmonyOS Sans SC",
        "Source Han Sans",
        "Noto Sans CJK",
      ),
    )
  }

  let text-lang = if font-config != none { font-config.at("text-lang", default: "en") } else { "en" }
  let text-region = if font-config != none { font-config.at("text-region", default: "us") } else { "us" }

  set text(size: 20pt, font: fonts.combined, lang: text-lang, region: text-region)
  set par(justify: false)

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      fill: gradient.linear(angle: 90deg, rgb("#e6e6e6").lighten(20%), rgb("#e6e6e6").darken(20%)),
      background: place(bottom, image("../contour_map.svg", width: 100%)),
      header-ascent: 0em,
      footer-descent: 0em,
      margin: if navigation == "sidebar" {
        (top: 2em, bottom: 2em, left: sidebar.width)
      } else if navigation == "mini-slides" {
        (top: mini-slides.height, bottom: 2em, x: mini-slides.x)
      } else {
        (top: 2em, bottom: 2em, x: mini-slides.x)
      },
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      show-strong-with-alert: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          fill: self.colors.neutral-darkest,
          font: self.store.fonts.combined,
          lang: self.store.text-lang,
          region: self.store.text-region,
        )
        show heading: set text(fill: self.colors.neutral-darkest)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-darkest: rgb("#191919"),
      neutral-dark: rgb("#7C7C7C"),
      neutral: rgb("#828282"),
      neutral-light: rgb("#D9D9D9"),
      neutral-lightest: rgb("#E6E6E6"),
      primary: primary,
    ),
    config-store(
      navigation: navigation,
      sidebar: sidebar,
      mini-slides: mini-slides,
      footer: footer,
      footer-right: footer-right,
      alpha: alpha,
      subslide-preamble: subslide-preamble,
      title-height: 4em,
      fonts: fonts,
      text-lang: text-lang,
      text-region: text-region,
    ),
    ..args,
  )

  body
}
