#let opt(it, key, default) = {
  let overrides = it.at("item-overrides", default: (:))
  if type(overrides) == dictionary and key in overrides {
    overrides.at(key)
  } else {
    it.theme.at(key, default: it.at(key, default: default))
  }
}

#let fallback-text(value, default) = if value == none or value == "" { default } else { value }

#let terminal-theme = (
  ui-font: "Courier",
  color-primary: rgb("00ff41"),
  color-secondary: rgb("008f11"),
  card-radius: 0em,
  card-stroke: 1.5pt + rgb("008f11"),
  card-inset: 1.5em,
)

#let terminal-render(it) = {
  let th = it.theme
  let ft = it.font-text
  let meta-lines = ()
  let hero-text = opt(it, "hero-text", none)
  let sample-text = fallback-text(opt(it, "sample-text", "Whereas recognition of the inherent dignity"), "Whereas recognition of the inherent dignity")

  if opt(it, "show-author", true) {
    meta-lines.push([> AUTHOR: #it.at("author", default: "UNKNOWN")])
  }
  meta-lines.push([> TYPE:   #it.at("font-type", default: "Static")])
  if opt(it, "show-version", true) and it.at("version", default: none) != none {
    meta-lines.push([> VERSION: #it.version])
  }
  meta-lines.push([> STYLE:  #it.at("weight", default: "400") / #it.at("style", default: "normal")])

  block(
    breakable: false, width: 100%,
    fill: rgb("000000"),
    stroke: th.card-stroke,
    inset: th.card-inset,
    radius: th.card-radius,
    [
      #set block(spacing: 0pt)
      #set par(spacing: 0pt)

      #text(font: th.ui-font, fill: th.color-primary, size: 1em)[
        root\@typst-os:\~\# fetch-font-meta --name "#it.name"
      ]
      #v(0.5em)

      #text(font: th.ui-font, fill: th.color-secondary, size: 0.85em)[> LOADING METADATA... OK.]
      #for line in meta-lines [
        #text(font: th.ui-font, fill: th.color-secondary, size: 0.85em)[#line]
      ]

      #v(1.5em)

      #text(font: th.ui-font, fill: th.color-primary, size: 1em)[
        root\@typst-os:\~\# render-sample --target "#it.name"
      ]
      #v(0.8em)

      #block(
        width: 100%,
        stroke: (left: 2pt + th.color-secondary),
        inset: (left: 1em, top: 0.5em, bottom: 0.5em),
        [
          #if hero-text != none [
            #ft(size: 3em, fill: th.color-primary)[#hero-text]
            #v(0.5em)
          ]
          #ft(size: 1.4em, fill: th.color-primary)[#sample-text]
        ]
      )

      #v(1.5em)

      #text(font: th.ui-font, fill: th.color-primary, size: 1em, weight: "bold")[
        root\@typst-os:\~\# \_
      ]
    ]
  )
}
