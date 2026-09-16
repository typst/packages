// Presentation helpers for the default theme.
#let opt(it, key, default) = {
  let overrides = it.at("item-overrides", default: (:))
  if type(overrides) == dictionary and key in overrides {
    overrides.at(key)
  } else {
    it.theme.at(key, default: it.at(key, default: default))
  }
}

#let fallback-text(value, default) = if value == none or value == "" { default } else { value }

#let format-style-badge(w, s) = {
  let ws = lower(str(w))
  let weight-map = (
    "thin": "Thin 100", "100": "Thin 100", "extralight": "ExtraLight 200", "200": "ExtraLight 200",
    "light": "Light 300", "300": "Light 300", "regular": "Regular 400", "400": "Regular 400",
    "medium": "Medium 500", "500": "Medium 500", "semibold": "SemiBold 600", "600": "SemiBold 600",
    "bold": "Bold 700", "700": "Bold 700", "extrabold": "ExtraBold 800", "800": "ExtraBold 800",
    "black": "Black 900", "900": "Black 900",
  )
  let weight-str = weight-map.at(ws, default: str(w))
  let style-str = if s == "italic" { "Italic" } else if s == "oblique" { "Oblique" } else { "" }
  if style-str != "" { weight-str + " " + style-str } else { weight-str }
}

#let resolve-detail-flags(it) = {
  let raw = opt(it, "show-details", false)
  let flags = (
    enabled: raw != false,
    author: false,
    manufacturer: false,
    designer-url: false,
    vendor-url: false,
    trademark: false,
    license: false,
    font-type: false,
    weight: false,
    width: false,
    styles-count: false,
    number-of-glyphs: false,
    postscript-name: opt(it, "show-postscript-name", true),
    version: opt(it, "show-version", true),
    copyright: opt(it, "show-copyright", true),
    license-url: opt(it, "show-license-url", true),
  )

  if type(raw) == dictionary {
    for (key, value) in raw {
      flags.insert(key.replace("_", "-"), value)
    }
  }

  flags
}

#let default-theme = (
  ui-font: "libertinus serif",
  color-primary: rgb("202124"), color-secondary: rgb("5f6368"), color-paragraph: auto,
  color-divider: rgb("f1f3f4"), color-waterfall-divider: rgb("e0e0e0"), color-desc-bg: rgb("f8f9fa"), color-link: auto,

  size-name: 1.6em, size-author: 0.9em, size-badge-label: 0.9em, size-badge-type: 0.7em,
  size-hero: 6.4em, size-waterfall-label: 0.75em, size-sub: 0.9em, size-paragraph: 0.95em,
  size-glyph-label: 0.8em, size-glyph: 1.2em, size-desc-title: 0.9em, size-desc: 0.9em,
  size-details-copyright: 0.8em, size-details: 0.7em,

  grid-column-gutter: 1.6em, grid-row-gutter: 0em, gap-author: 0.8em, gap-badges: 0.8em,
  gap-header: 1.6em, gap-hero: 3.2em, gap-waterfall-top: 0.8em, gap-waterfall-label: 0.8em,
  gap-waterfall-item: 1.6em, gap-sub: 1.2em, gap-section: 1.6em, gap-section-inner: 1.2em,
  gap-glyph-label: 0.6em, gap-glyph-item: 0.8em, gap-desc-title: 0.6em, gap-details: 1.2em,
  gap-details-inner: 0.8em, gap-details-copy: 0.6em, gap-details-version: 0.4em, gap-details-license: 0.2em,

  card-inset: 1.6em, card-radius: 0.6em, card-stroke: 0.5pt + rgb("dadce0"), card-spacing: 1.6em,
  badge-inset: (x: 0.6em, y: 0.3em), badge-radius: 1.0em, waterfall-inset: (bottom: 0.6em), waterfall-tracking: 0.05em,
  stroke-divider: auto, stroke-waterfall: auto, stroke-details: auto,
  desc-inset: 1.2em, desc-radius: 0.6em, leading-text: 1.4em
)

#let default-render(it) = {
  let th = it.theme
  let ft = it.font-text
  let display-name = if type(it.name) == array { it.name.join(", ") } else { str(it.name) }

  let res-color-paragraph = if th.color-paragraph == auto { th.color-primary.lighten(15%) } else { th.color-paragraph }
  let res-color-link = if th.color-link == auto { blue.lighten(30%) } else { th.color-link }
  let res-stroke-divider = if th.stroke-divider == auto { 0.5pt + th.color-divider } else { th.stroke-divider }
  let res-stroke-waterfall = if th.stroke-waterfall == auto { (bottom: 0.5pt + th.color-waterfall-divider) } else { th.stroke-waterfall }
  let res-stroke-details = if th.stroke-details == auto { 0.2pt + th.color-secondary.lighten(50%) } else { th.stroke-details }
  let show-badges = opt(it, "show-badges", true)
  let show-author = opt(it, "show-author", true)
  let show-description = opt(it, "show-description", true)
  let show-glyphs = opt(it, "show-glyphs", false)
  let align-key = opt(it, "align", left)
  let hero-text = opt(it, "hero-text", none)
  let sample-text = fallback-text(opt(it, "sample-text", "Whereas recognition of the inherent dignity"), "Whereas recognition of the inherent dignity")
  let sample-size = opt(it, "sample-size", 2.0em)
  let sub-text = opt(it, "sub-text", none)
  let paragraph-text = opt(it, "paragraph-text", none)
  let description = opt(it, "description", none)
  let waterfall = opt(it, "waterfall", ())

  let badges = ()
  if show-badges {
    let style-badge-label = format-style-badge(it.weight, it.style)
    badges.push(text(size: th.size-badge-label, fill: th.color-secondary, font: th.ui-font, weight: "bold")[#style-badge-label])
    if it.at("font-type", default: none) != none {
      badges.push(box(stroke: th.card-stroke, inset: th.badge-inset, radius: th.badge-radius, text(size: th.size-badge-type, fill: th.color-secondary, weight: "bold", font: th.ui-font)[#upper(it.font-type)]))
    }
  }

  let detail-flags = resolve-detail-flags(it)
  let detail-rows = ()
  let specimen-leading = opt(it, "leading", 0.8em)
  if detail-flags.enabled {
    if detail-flags.at("author", default: false) and it.at("author", default: none) != none {
      detail-rows.push((label: [Author], value: [#it.author]))
    }
    if detail-flags.at("manufacturer", default: false) and it.at("manufacturer", default: none) != none {
      detail-rows.push((label: [Manufacturer], value: [#it.manufacturer]))
    }
    if detail-flags.at("designer-url", default: false) and it.at("designer-url", default: none) != none {
      detail-rows.push((label: [Designer URL], value: [#link(it.at("designer-url", default: ""))[#it.at("designer-url", default: "")]]))
    }
    if detail-flags.at("vendor-url", default: false) and it.at("vendor-url", default: none) != none {
      detail-rows.push((label: [Vendor URL], value: [#link(it.at("vendor-url", default: ""))[#it.at("vendor-url", default: "")]]))
    }
    if detail-flags.at("trademark", default: false) and it.at("trademark", default: none) != none {
      detail-rows.push((label: [Trademark], value: [#it.trademark]))
    }
    if detail-flags.at("license", default: false) and it.at("license", default: none) != none {
      detail-rows.push((label: [License], value: [#it.license]))
    }
    if detail-flags.at("font-type", default: false) and it.at("font-type", default: none) != none {
      detail-rows.push((label: [Format], value: [#it.at("font-type", default: "")]))
    }
    if detail-flags.at("weight", default: false) and it.at("weight", default: none) != none {
      detail-rows.push((label: [Weight Class], value: [#it.weight]))
    }
    if detail-flags.at("width", default: false) and it.at("width", default: none) != none {
      detail-rows.push((label: [Width Class], value: [#it.width]))
    }
    if detail-flags.at("styles-count", default: false) and it.at("styles-count", default: none) != none {
      detail-rows.push((label: [Styles In Collection], value: [#it.at("styles-count", default: "")]))
    }
    if detail-flags.at("number-of-glyphs", default: false) and it.at("number-of-glyphs", default: none) != none {
      detail-rows.push((label: [Glyph Count], value: [#it.at("number-of-glyphs", default: "")]))
    }
    if detail-flags.at("postscript-name", default: true) and it.at("postscript-name", default: none) != none {
      detail-rows.push((label: [PostScript Name], value: [#it.at("postscript-name", default: "")]))
    }
    if detail-flags.at("version", default: true) and it.at("version", default: none) != none {
      detail-rows.push((label: [Version], value: [#it.version]))
    }
    if detail-flags.at("copyright", default: true) and it.at("copyright", default: none) != none {
      detail-rows.push((label: [Copyright], value: [#it.copyright]))
    }
    if detail-flags.at("license-url", default: true) and it.at("license-url", default: none) != none {
      detail-rows.push((label: [License URL], value: [#link(it.at("license-url", default: ""))[#it.at("license-url", default: "")]]))
    }
  }

  block(
    breakable: false, width: 100%, stroke: th.card-stroke, inset: th.card-inset, radius: th.card-radius, below: th.card-spacing,
    [
      #set block(spacing: 0pt)
      #set par(spacing: 0pt)

      #layout(size => {
        let strategy = opt(it, "title-overflow", auto)
        let stack-badge-position = if opt(it, "title-overflow-badge-position", "top") == "bottom" { "bottom" } else { "top" }
        let has-author = show-author and it.at("author", default: none) != none
        let has-badges = badges.len() > 0
        let title-content = text(size: th.size-name, weight: "bold", fill: th.color-primary, font: th.ui-font)[#display-name]
        let author-content = if has-author {
          text(size: th.size-author, fill: th.color-secondary, font: th.ui-font)[Designed by #it.author]
        } else {
          []
        }
        let badge-panel = if has-badges {
          grid(columns: badges.len(), gutter: th.gap-badges, align: horizon, ..badges)
        } else {
          []
        }

        let stack-header = if not has-badges {
          false
        } else if strategy == "stack" {
          true
        } else if strategy == "inline" {
          false
        } else {
          let title-width = measure(title-content).width
          let badge-width = measure(badge-panel).width
          let header-gap-width = measure([#h(th.gap-badges)]).width
          let required-width = title-width + badge-width + header-gap-width
          it.at("column-count", default: 1) > 1 and required-width > size.width
        }

        if stack-header [
          #if has-badges and stack-badge-position == "top" [
            #align(right)[#badge-panel]
            #v(th.gap-badges)
          ]
          #title-content
          #if has-author [
            #v(th.gap-author)
            #author-content
          ]
          #if has-badges and stack-badge-position == "bottom" [
            #v(th.gap-badges)
            #align(right)[#badge-panel]
          ]
        ] else [
          #if has-badges [
            #grid(
              columns: (1fr, auto),
              align: (left, horizon),
              [#title-content],
              [#badge-panel]
            )
          ] else [
            #title-content
          ]
          #if has-author [
            #v(th.gap-author)
            #author-content
          ]
        ]
      })
      #v(th.gap-header)

      #if hero-text != none [
        #align(center)[#ft(size: th.size-hero, fill: th.color-primary)[#hero-text]]
        #v(th.gap-hero)
      ]

      #[
        #set align(align-key)
        #if waterfall.len() > 0 {
          v(th.gap-waterfall-top)
          for s in waterfall [
            #block(width: 100%, breakable: false)[
              #box(width: 100%, stroke: res-stroke-waterfall, inset: th.waterfall-inset)[
                #text(size: th.size-waterfall-label, fill: th.color-secondary, font: th.ui-font, tracking: th.waterfall-tracking, weight: "bold")[#s]
              ]
              #v(th.gap-waterfall-label)
              #par(leading: specimen-leading)[#ft(size: s, fill: th.color-primary)[#sample-text]]
            ]
            #v(th.gap-waterfall-item)
          ]
        } else {
          par(leading: specimen-leading)[#ft(size: sample-size, fill: th.color-primary)[#sample-text]]
        }
      ]

      #if sub-text != none [
        #v(th.gap-sub)
        #[#set align(align-key); #ft(size: th.size-sub, fill: th.color-secondary)[#sub-text]]
      ]

      #if paragraph-text != none [
        #v(th.gap-section)
        #line(length: 100%, stroke: res-stroke-divider)
        #v(th.gap-section-inner)
        #[
          #set par(justify: true, leading: th.leading-text, spacing: 0.65em)
          #set block(spacing: 0.65em)
          #ft(size: th.size-paragraph, fill: res-color-paragraph)[#paragraph-text]
        ]
      ]

      #if show-glyphs [
        #v(th.gap-section)
        #line(length: 100%, stroke: res-stroke-divider)
        #v(th.gap-section-inner)
        #let glyph-data = it.at("glyphs", default: none)
        #if type(glyph-data) == array [
          #for cat in glyph-data [
            #text(size: th.size-glyph-label, fill: th.color-secondary, weight: "bold", font: th.ui-font)[#cat.name]
            #v(th.gap-glyph-label)
            #box(width: 100%, clip: true)[
              #set par(leading: specimen-leading, justify: true)
              #ft(size: th.size-glyph, fill: th.color-primary)[#cat.chars]
            ]
            #v(th.gap-glyph-item)
          ]
        ]
      ]

      #if show-description and description != none [
        #v(th.gap-section)
        #block(width: 100%, fill: th.color-desc-bg, inset: th.desc-inset, radius: th.desc-radius, [
          #text(size: th.size-desc-title, weight: "bold", fill: th.color-primary, font: th.ui-font)[About this font]\
          #v(th.gap-desc-title)
          #block[
            #set par(justify: false)
            #set text(hyphenate: false)
            #text(size: th.size-desc, fill: th.color-secondary, font: th.ui-font)[#description]
          ]
        ])
      ]

      #if detail-rows.len() > 0 [
        #v(th.gap-section)
        #line(length: 100%, stroke: res-stroke-details)
        #v(th.gap-section-inner)
        #for row in detail-rows [
          #grid(
            columns: (8.5em, 1fr),
            column-gutter: 0.9em,
            align: (left, top),
            text(size: th.size-details, fill: th.color-secondary, weight: "bold", font: th.ui-font)[#row.label],
            block(width: 100%)[
              #set text(size: th.size-details-copyright, fill: res-color-paragraph, font: th.ui-font)
              #row.value
            ]
          )
          #v(th.gap-details-inner)
        ]
      ]
    ]
  )
}
