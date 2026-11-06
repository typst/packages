#import "../src/ccicons.typ" as ccicons: *

// Official creative commons color palette
#let cctomato = rgb("#ed592f")
#let ccdarkslategray = rgb("#333333")
#let ccgold = rgb("#efbe00")
#let ccorange = rgb("#fb7729")
#let ccforestgreen = rgb("#04a635")
#let ccdarkturquoise = rgb("#05b5da")
#let ccdarkslateblue = rgb("#3c5c99")

#let color-header = ccdarkturquoise.lighten(50%)
#let color-default = ccgold.lighten(90%)
#let color-muted = ccforestgreen.lighten(90%)
#let color-empty = cctomato.lighten(50%)

#let pkg = toml("../typst.toml").package
#let ccico = text(cctomato, pkg.name)

#let command-map = (
  ccAttribution: "by",
  ccShareAlike: "sa",
  ccNoDerivatives: "nd",
  ccNonCommercial: "nc",
  ccNonCommercialEU: "nceu",
  ccNonCommercialJP: "ncjp",
  ccPublicDomain: "pd",
  ccZero: "zero",
  ccShare: "share",
  ccRemix: "remix",
  ccSampling: "sampling",
  ccSamplingPlus: "sampling.plus",
  cc-by: "cc-by",
  cc-by-sa: "cc-by-sa",
  cc-by-nd: "cc-by-nd",
  cc-by-nc: "cc-by-nc",
  cc-by-nc-sa: "cc-by-nc-sa",
  cc-by-nc-sa-eu: "cc-by-nceu-sa",
  cc-by-nc-sa-jp: "cc-by-ncjp-sa",
  cc-by-nc-nd: "cc-by-nc-nd",
  cc-by-nc-nd-eu: "cc-by-nceu-nd",
  cc-by-nc-nd-jp: "cc-by-ncjp-nd",
  cc-zero: "cc-zero",
  cc-pd: "cc-pd",
)

// Page setup
#set page(paper: "a4")
#set text(font: ("Source Sans Pro", "Roboto"), 12pt, ccdarkslategray)
#show link: set text(ccorange)
#set heading(numbering: "1.1.a")
#show heading: it => {
  set text(fill: cctomato)
  block(
    width: 100%,
    inset: (bottom: .33em),
    stroke: (bottom: .6pt + ccdarkturquoise),
    [#if it.numbering != none {
        (
          text(
            weight: "semibold",
            ccdarkturquoise,
            counter(heading.where(level: it.level)).display(it.numbering),
          )
            + h(1.28em)
        )
      } #it.body],
  )
}
#show raw.where(block: true, lang: "typst"): it => {
  show "{{VERSION}}": pkg.version
  show "{{NAME}}": pkg.name
  block(
    width: 100%,
    stroke: .6pt + ccdarkturquoise,
    radius: 2pt,
    inset: 1.28em,
    it,
  )
}
#let example = block.with(
  width: 100%,
  stroke: .6pt + ccforestgreen,
  radius: 2pt,
  inset: 1.28em,
)
#let show-example(code) = grid(
  columns: 1,
  row-gutter: .64em,
  code,
  {
    example(eval("#import ccicons: *\n" + code.text, mode: "markup", scope: (ccicons: ccicons)))

    place(
      right + top,
      dy: -7mm,
      polygon(
        fill: gradient.linear(ccdarkturquoise, ccforestgreen, angle: 90deg),
        stroke: none,
        (-5mm, 0mm),
        (5mm, 0mm),
        (5mm, 5mm),
        (10mm, 5mm),
        (0mm, 11mm),
        (-10mm, 5mm),
        (-5mm, 5mm),
        (-5mm, 0mm),
      ),
    )
  },
)
#let ex(code) = {
  raw(lang: "typst", code.text)
  sym.arrow.r
  eval("#import ccicons: *; " + code.text, mode: "markup", scope: (ccicons: ccicons))
}

#set align(center)
#v(2fr)

#block(
  width: 100%,
  inset: (y: 1.28em),
  stroke: (bottom: 2pt + ccdarkturquoise),
  [
    #set text(40pt)
    The #text(cctomato, weight: 600, pkg.name) package
  ],
)
#text(14pt)[Version #pkg.version]
#v(1fr)
A port of the `ccicon` LaTeX package for Typst.
#v(2fr)
#block(width: 100%, inset: (x: 10%), outline())
#v(2fr)

#pagebreak()
#set align(left)
= About

#ccico adds commands to add Creative Commons license logos to your document.

It is a port of the LaTeX package by the same name by Michael Ummels.

Please note that all icons in this package are trademarks of Creative Commons and are subject to the Creative Commons trademark policy (see #link("http://creativecommons.org/policies", "http://creativecommons.org/policies")).

The SVG files distributed in this package are available on #link("https://creativecommons.org/mission/downloads/", "the Creative Commons website") and licensed under #link("https://creativecommons.org/licenses/by/4.0/", "Creative Commons Attribution 4.0 International license").

= Usage

Add the package to your document by importing it at the top:

```typst
#import "@preview/{{NAME}}:{{VERSION}}": *
```

After the package has been imported, simply add a license icon to your document by using one of the shorthands provided (see @shorthands):

#table(
  columns: (1fr, 1fr, 1fr),
  align: center,
  `#cc-by-nc-sa`, `#cc-by-nc-sa-shield`, `#cc-by-nc-sa-badge`,
  cc-by-nc-sa, cc-by-nc-sa-shield, cc-by-nc-sa-badge,
)

If you need more control over the output, consider using the `#ccicon` function (see @ccicon).

The logos will scale and change color with the surrounding text:

#show-example(```typst
Lorem ipsum #cc-by-sa dolor sit amet

#set text(16pt, rgb("#ed592f"))
Lorem ipsum #cc-by-sa dolor sit amet

#set text(1.5em, rgb("#05b5da"))
Lorem ipsum #cc-by-sa dolor sit amet
```)

#pagebreak()
= Shorthand logo commands <shorthands>
The following commands can be used to typeset the icons provided by Creative Commons.

Licenses are a combination of the individual icons joined by a dash (`-`) and can be displayed as a set of icons, a "shield" or a "badge", by adding the format as a suffix.

#align(
  center,
  table(
    columns: (auto, 4cm, 4cm, 4cm),
    align: center + horizon,
    fill: color-default,
    inset: .26em,
    table.header(
      table.cell(rowspan: 2, fill: color-header)[*Markup*],
      table.cell(colspan: 3, fill: color-header)[*Result by suffix*],
      table.cell(fill: color-muted, ""),
      table.cell(fill: color-muted, `-shield`),
      table.cell(fill: color-muted, `-badge`),
    ),
    table.cell(fill: color-muted, raw(block: false, "#cc-logo")),
    ccicon("logo", scale: 2),
    table.cell(inset: 0pt, fill: color-empty)[],
    table.cell(fill: color-empty)[],
    table.cell(fill: color-muted, raw(block: false, "#cc")),
    ccicon("cc", scale: 2),
    table.cell(inset: 0pt, fill: color-empty)[],
    table.cell(fill: color-empty)[],
    ..for (name, icon) in command-map {
      (
        table.cell(fill: color-muted, raw(block: false, "#" + name)),
        ccicon(icon, scale: 2),
        if cc-is-valid(name + "-shield") {
          ccicon(icon, scale: 2, format: "shield")
        } else {
          table.cell(fill: color-empty)[]
        },
        if cc-is-valid(name + "-badge") {
          ccicon(icon, scale: 2.5, format: "badge")
        } else {
          table.cell(fill: color-empty)[]
        },
      )
    },
  ),
)

= The `ccicon` function <ccicon>

If you need more control over the output, you can use the `#ccicon` function. It can create an icon from the license name and takes the following options:

/ name: #[
    Name of the icon / license as a string (like `"cc-by-sa"`).
    - #ex(`#ccicon("nc")`)
    - #ex(`#ccicon("cc-by-sa")`)

    Append `-shield` or `-badge` to generate the other formats.
    - #ex(`#ccicon("cc-by-sa-shield")`)
    - #ex(`#ccicon("cc-by-sa-badge")`)

    You can also append a version number and language code each separated by a slash (`/`) to make the license version / language aware. This won't change the icon, but might be useful for using the `link` option (see below).
  ]
/ format: One of #auto, `"icon"`, `"badge"` or `"shield"`. Defaults to #auto.

  This will override the format detected in the license name.
  - #ex(`#ccicon("cc-by-sa-shield", format:"badge")`)
  - #ex(`#ccicon("cc-by-sa-badge", format:"icon")`)
/ scale: A scaling factor for the icon.
  - #ex(`#ccicon("cc-by-sa-shield", scale:2)`)
  - #ex(`#ccicon("cc-by-sa-badge", scale:.88)`)
/ baseline: Sets the `baseline` of the surronding `#box`.
  - #ex(`#ccicon("cc-by-sa", baseline:5pt)`)
  - #ex(`#ccicon("cc-by-sa-badge", baseline:-5pt)`)
/ link: #[
    If #true, the icon will be a clickable link to the license text.
    - #ex(`#ccicon("cc-by-sa", link:true)`)

    You can change the language of the license text, by appending a language code to the license name, separated by `/`:
    - #ex(`#ccicon("cc-by-sa-badge/de", link:true)`)

    Similarly, the license version may be provided:
    - #ex(`#ccicon("cc-by-sa-shield/3.0/de", link:true)`)
  ]
/ fill: Either #auto or a #color. #auto is the default and the icon will use the color of the surronding text. Otherwise, the `fill` will be used to color the icon.
  - #ex(`#text(fill: red, ccicon("cc-by-sa"))`)
  - #ex(`#ccicon("cc-by-sa", fill:red)`)

  Note that shields and badges will not be colored.
  - #ex(`#ccicon("cc-by-sa", format:"shield", fill:red)`)

= Other utilities

#ccico provides the following additional helper functions:

/ ```typst #cc-url(license-name)```: Creates an url to the license text on the Creative Commons website.
  - #ex(`#cc-url("cc-by-sa/de")`)
/ ```typst #cc-is-valid(license-name)```: Checks if the provided license name is valid and can be parsed by #ccico.
  - #ex(`#cc-is-valid("cc-by-sa")`)
  - #ex(`#cc-is-valid("cc-by-nc-sa-badge")`)
  - #ex(`#cc-is-valid("sa")`)
  - #ex(`#cc-is-valid("sa-badge")`)
  - #ex(`#cc-is-valid("not-a-license")`)
