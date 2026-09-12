#let opt(it, key, default) = {
  let overrides = it.at("item-overrides", default: (:))
  if type(overrides) == dictionary and key in overrides {
    overrides.at(key)
  } else {
    it.theme.at(key, default: it.at(key, default: default))
  }
}

#let fallback-text(value, default) = if value == none or value == "" { default } else { value }

#let inspector-theme = (
  ui-font: "libertinus serif",
  mono-font: "Courier",
  color-primary: rgb("1f2a3a"),
  color-secondary: rgb("607089"),
  color-muted: rgb("8b98ab"),
  color-panel: rgb("f5f7fb"),
  color-panel-2: rgb("fbfcfe"),
  color-stroke: rgb("d4dbe7"),
  color-accent: rgb("0f6dff"),
  color-capability: rgb("eef4ff"),
  color-capability-stroke: rgb("bfd2ff"),
  card-stroke: 0.5pt + rgb("d4dbe7"),
  card-radius: 0.6em,
  card-inset: 1.2em,
  size-title: 1.15em,
  size-meta: 0.8em,
  size-sample: 1.5em,
  size-badge: 0.72em,
  size-codepoints: 0.78em,
  gap-header: 0.35em,
  gap-section: 0.9em,
  gap-badges: 0.6em,
  gap-grid: 0.8em,
  gap-table-row: 0.35em,
  probe-glyph-ids: (0, 1, 2, 3, 4, 5, 6, 7),
  sample-codepoint-count: 8,
  sample-text: "Glyph metrics inspector",
)

#let capability-badge(label, active, th) = {
  box(
    inset: (x: 0.55em, y: 0.25em),
    radius: 999pt,
    stroke: 0.5pt + (if active { th.color-capability-stroke } else { th.color-stroke }),
    fill: if active { th.color-capability } else { th.color-panel-2 },
    text(size: th.size-badge, fill: if active { th.color-accent } else { th.color-secondary }, weight: "bold", font: th.ui-font)[#label: #if active { "yes" } else { "no" }],
  )
}

#let wrapped-name-cell(name, th) = {
  block(width: 100%)[
    #set par(justify: false, leading: 0.06em)
    #set text(hyphenate: true, lang: "en", font: th.ui-font)
    #name
  ]
}

#let inspector-render(it) = {
  let th = it.theme
  let ft = it.font-text
  let sample-text = fallback-text(opt(it, "sample-text", "Glyph metrics inspector"), "Glyph metrics inspector")
  let glyph-details = it.at("glyph-details", default: ())
  let glyph-name-index = it.at("glyph-name-index", default: (:))
  let codepoint-samples = it.at("codepoint-samples", default: ())
  let capabilities = it.at("capabilities", default: (:))
  let variations = it.at("variations", default: (:))
  let variation-request = it.at("variation-request", default: (:))
  let table-sizes = it.at("table-sizes", default: (:))
  let probe-glyph-ids = opt(it, "probe-glyph-ids", (0, 1, 2, 3))
  let sample-codepoint-count = opt(it, "sample-codepoint-count", 8)
  let preview-count = if sample-codepoint-count < codepoint-samples.len() { sample-codepoint-count } else { codepoint-samples.len() }

  let badges = (
    capability-badge("color", capabilities.at("has-color-glyphs", default: false), th),
    capability-badge("svg", capabilities.at("has-svg-images", default: false), th),
    capability-badge("raster", capabilities.at("has-raster-images", default: false), th),
    capability-badge("variable", capabilities.at("is-variable", default: false), th),
  )

  let table-cells = (
    [*ID*], [*Name*], [*Advance*], [*Side Bearing*], [*BBox*],
  )
  for gid in probe-glyph-ids {
    let glyph = glyph-details.at(gid, default: none)
    if glyph != none {
      let bbox = glyph.at("bounding-box", default: none)
      let bbox-label = if bbox == none {
        "-"
      } else {
        str(bbox.at("width", default: "?")) + " x " + str(bbox.at("height", default: "?"))
      }
      table-cells.push([#gid])
      table-cells.push([#wrapped-name-cell(glyph.at("name", default: "(unnamed)"), th)])
      table-cells.push([#glyph.at("horizontal-advance", default: "-")])
      table-cells.push([#glyph.at("horizontal-side-bearing", default: "-")])
      table-cells.push([#bbox-label])
    }
  }

  let codepoint-lines = ()
  for entry in codepoint-samples.slice(0, preview-count) {
    let name-suffix = if entry.at("glyph-name", default: none) == none {
      ""
    } else {
      " / " + entry.at("glyph-name", default: "")
    }
    codepoint-lines.push([
      #entry.at("char", default: "?")
      #h(0.5em)
      #text(font: th.mono-font)[U+#str(entry.at("codepoint", default: 0), base: 16)]
      #h(0.5em)
      gid=#entry.at("glyph-id", default: "?")#name-suffix
    ])
  }

  let variation-lines = ()
  let requested-values = variation-request.at("values", default: (:))
  for axis in variations.at("axes", default: ()) {
    let tag = axis.at("tag", default: "?")
    let requested = requested-values.at(tag, default: none)
    let axis-name = axis.at("name", default: none)
    let requested-suffix = if requested == none { "" } else { " requested " + str(requested) }
    variation-lines.push([
      #text(font: th.mono-font)[#tag]
      #h(0.6em)
      #if axis-name == none { "(unnamed)" } else { axis-name }
      #h(0.6em)
      range #axis.at("min-value", default: "?")..#axis.at("max-value", default: "?")
      #h(0.6em)
      default #axis.at("default-value", default: "?")#requested-suffix
    ])
  }

  let table-size-lines = ()
  for tag in table-sizes.keys() {
    table-size-lines.push([
      #text(font: th.mono-font)[#tag]
      #h(0.5em)
      #table-sizes.at(tag) bytes
    ])
  }

  block(
    breakable: false,
    width: 100%,
    fill: th.color-panel-2,
    stroke: th.card-stroke,
    inset: th.card-inset,
    radius: th.card-radius,
    [
      #text(size: th.size-title, weight: "bold", fill: th.color-primary, font: th.ui-font)[#it.name]
      #v(th.gap-header)
      #text(size: th.size-meta, fill: th.color-secondary, font: th.ui-font)[
        glyphs=#glyph-details.len() / named=#glyph-name-index.len() / codepoint samples=#codepoint-samples.len()
      ]
      #v(th.gap-section)
      #ft(size: th.size-sample, fill: th.color-primary)[#sample-text]
      #v(th.gap-section)
      #grid(columns: badges.len(), column-gutter: th.gap-badges, ..badges)
      #v(th.gap-section)
      #grid(
        columns: (1.2fr, 1fr),
        column-gutter: th.gap-grid,
        align: (left, top),
        [
          #text(size: th.size-meta, weight: "bold", fill: th.color-secondary, font: th.ui-font)[Glyph Probe]
          #v(0.5em)
          #block[
            #set par(justify: false)
            #set text(hyphenate: false)
            #grid(columns: (auto, 0.9fr, auto, auto, auto), column-gutter: 0.8em, row-gutter: th.gap-table-row, ..table-cells)
          ]
        ],
        [
          #text(size: th.size-meta, weight: "bold", fill: th.color-secondary, font: th.ui-font)[Codepoint Samples]
          #v(0.5em)
          #stack(spacing: 0.25em, ..codepoint-lines)
        ],
      )
      #if variation-lines.len() > 0 [
        #v(th.gap-section)
        #text(size: th.size-meta, weight: "bold", fill: th.color-secondary, font: th.ui-font)[Variation Axes]
        #v(0.5em)
        #stack(spacing: 0.25em, ..variation-lines)
      ]
      #if table-size-lines.len() > 0 [
        #v(th.gap-section)
        #text(size: th.size-meta, weight: "bold", fill: th.color-secondary, font: th.ui-font)[Table Diagnostics]
        #v(0.5em)
        #stack(spacing: 0.2em, ..table-size-lines)
      ]
    ],
  )
}
