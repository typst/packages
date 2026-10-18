// Supporting parts for visualizing font metrics.
#let opt(it, key, default) = {
  let overrides = it.at("item-overrides", default: (:))
  if type(overrides) == dictionary and key in overrides {
    overrides.at(key)
  } else {
    it.theme.at(key, default: it.at(key, default: default))
  }
}

#let fallback-text(value, default) = if value == none or value == "" { default } else { value }

#let metric-line(label, value, th) = {
  let metric-stroke = if th.metric-line-stroke == auto {
    stroke(thickness: 0.5pt, paint: th.color-metric, dash: "dotted")
  } else {
    th.metric-line-stroke
  }

  grid(
    columns: (th.metric-label-width, 1fr, th.metric-value-width),
    column-gutter: th.metric-line-gutter,
    align: horizon,
    text(size: th.size-metric-label, fill: th.color-metric.darken(20%), weight: "bold", font: th.ui-font)[#label],
    line(length: 100%, stroke: metric-stroke),
    text(size: th.size-metric-value, fill: th.color-metric, font: th.mono-font)[
      #if value != none and value != 0 [#{value}u] else [---]
    ]
  )
}

#let anatomy-theme = (
  ui-font: "libertinus serif",
  mono-font: "Courier",

  color-primary: rgb("1a1a1a"),
  color-secondary: rgb("5f6368"),
  color-accent: rgb("d73a49"),
  color-metric: rgb("0366d6"),
  color-bg: rgb("ffffff"),
  color-divider: rgb("e1e4e8"),
  color-panel-bg: rgb("f6f8fa"),
  color-link: auto,

  card-stroke: 1pt + rgb("e1e4e8"),
  card-radius: 0.4em,
  card-inset: 2em,

  size-title: 1.8em,
  size-postscript: 0.8em,
  size-version: 0.8em,
  size-body: 0.9em,
  size-visual-label: 0.9em,
  size-spec-heading: 1.1em,
  size-metric-label: 0.7em,
  size-metric-value: 0.7em,
  size-legal: 0.75em,
  size-specimen-label: 0.7em,
  size-specimen: 1.4em,
  size-visual-sample: 8em,

  gap-header-divider-top: 1.5em,
  gap-header-divider-bottom: 1.5em,
  gap-columns: 3em,
  gap-visual-heading: 1em,
  gap-visual-stack: 0.6em,
  gap-spec-heading: 1em,
  gap-spec-stack: 0.8em,
  gap-legal-top: 2em,
  gap-legal-heading: 0.8em,
  gap-license-top: 0.5em,
  gap-specimen-top: 2.5em,
  gap-specimen-label: 0.8em,

  visual-panel-width: 1.2fr,
  details-panel-width: 1fr,
  spec-value-width: 1.1fr,
  metric-label-width: 6em,
  metric-value-width: 5em,
  metric-line-gutter: 0.5em,
  metric-line-stroke: auto,

  visual-sample-inset-top: 1.5em,
  visual-sample-inset-bottom: 2.6em,
  legal-leading: 1.3em,

  version-badge-inset: (x: 0.8em, y: 0.5em),
  version-badge-radius: 0.2em,
  specimen-inset: 1.2em,
  specimen-radius: 0.3em,
  specimen-label-tracking: 0.1em,
  divider-stroke: auto,
)

#let anatomy-render(it) = {
  let th = it.theme
  let ft = it.font-text

  let m = it.at("metrics", default: (:))
  let upm = m.at("units-per-em", default: 1000)
  let g-count = it.at("number-of-glyphs", default: "0")
  let p-name = it.at("postscript-name", default: none)
  let res-divider-stroke = if th.divider-stroke == auto { 0.5pt + th.color-divider } else { th.divider-stroke }
  let res-link-color = if th.color-link == auto { blue.lighten(30%) } else { th.color-link }
  let sample-text = fallback-text(opt(it, "sample-text", "Whereas recognition of the inherent dignity"), "Whereas recognition of the inherent dignity")

  block(
    breakable: false,
    width: 100%,
    stroke: th.card-stroke,
    inset: th.card-inset,
    radius: th.card-radius,
    fill: th.color-bg,
    [
      #grid(
        columns: (1fr, auto),
        [
          #text(size: th.size-title, weight: "bold", font: th.ui-font)[#it.name]
          #if opt(it, "show-postscript-name", true) and p-name != none [
            \
            #text(size: th.size-postscript, fill: th.color-secondary, font: th.mono-font)[#p-name]
          ]
        ],
        if opt(it, "show-version", true) and it.at("version", default: none) != none {
          box(fill: th.color-primary, inset: th.version-badge-inset, radius: th.version-badge-radius)[
            #text(fill: white, size: th.size-version, weight: "bold", font: th.mono-font)[#it.version]
          ]
        } else {
          []
        }
      )

      #v(th.gap-header-divider-top)
      #line(length: 100%, stroke: res-divider-stroke)
      #v(th.gap-header-divider-bottom)

      #grid(
        columns: (th.visual-panel-width, th.details-panel-width),
        column-gutter: th.gap-columns,
        [
          #text(weight: "bold", size: th.size-visual-label, fill: th.color-secondary, font: th.ui-font)[VISUAL RATIO (Unit/Em: #upm)]
          #v(th.gap-visual-heading)
          #stack(
            spacing: th.gap-visual-stack,
            align(center, block(inset: (top: th.visual-sample-inset-top, bottom: th.visual-sample-inset-bottom))[
              #ft(size: th.size-visual-sample, fill: th.color-primary)[Abg]
            ]),
            metric-line("ASCENT", m.at("ascender", default: none), th),
            metric-line("CAP-HEIGHT", m.at("cap-height", default: none), th),
            metric-line("X-HEIGHT", m.at("x-height", default: none), th),
            metric-line("DESCENT", m.at("descender", default: none), th),
          )
        ],
        [
          #set text(size: th.size-body, font: th.ui-font)
          #text(weight: "bold", size: th.size-spec-heading, font: th.ui-font)[Technical Specs]
          #v(th.gap-spec-heading)

          #let spec(label, val) = grid(
            columns: (1fr, th.spec-value-width),
            text(fill: th.color-secondary, font: th.ui-font)[#label],
            text(weight: "medium", font: th.ui-font)[#val]
          )

          #stack(
            spacing: th.gap-spec-stack,
            spec("Format", it.at("font-type", default: "Static")),
            spec("Total Glyphs", [#g-count units]),
            spec("Design UPM", upm),
            spec("Weight Class", it.at("weight", default: "400")),
            spec("Width Class", it.at("width", default: "5 (Normal)")),
            spec("Italic Angle", if m.at("italic-angle", default: 0) != 0 [#m.at("italic-angle", default: 0)°] else [0°]),
          )

          #if opt(it, "show-copyright", true) and it.at("copyright", default: none) != none [
            #v(th.gap-legal-top)
            #text(weight: "bold", size: th.size-spec-heading, font: th.ui-font)[Legal & Source]
            #v(th.gap-legal-heading)
            #[
              #set par(leading: th.legal-leading)
              #text(size: th.size-legal, fill: th.color-secondary, font: th.ui-font)[#it.copyright]
            ]
          ]

          #if opt(it, "show-license-url", true) and it.at("license-url", default: none) != none [
            #v(th.gap-license-top)
            #text(size: th.size-legal, fill: res-link-color, font: th.ui-font)[
              #link(it.at("license-url", default: ""))[License URL #sym.arrow.tr]
            ]
          ]
        ]
      )

      #v(th.gap-specimen-top)

      #block(
        width: 100%,
        fill: th.color-panel-bg,
        inset: th.specimen-inset,
        radius: th.specimen-radius,
        [
          #text(size: th.size-specimen-label, fill: th.color-secondary, weight: "bold", tracking: th.specimen-label-tracking, font: th.ui-font)[DESIGNER'S SPECIMEN] \
          #v(th.gap-specimen-label)
          #ft(size: th.size-specimen, fill: th.color-primary)[#sample-text]
        ]
      )
    ]
  )
}
