// Demonstrates optional internal layout controls for the eight reusable components.
// The default values are designed to retain the existing component appearance.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12.4cm, height: 9.5cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 8pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center)[#text(fill: rgb("#444444"))[Horizontal Chevron Block — body column and icon offsets]]
#align(center + horizon)[
  #horizontal-chevron-block(
    body: [The text column and icon can be moved independently, and the copy width can be specified directly.],
    width: 10.8cm, height: 1.75cm,
    body-width: 5.8cm, text-offset-x: 0.1cm, text-offset-y: 0.08cm,
    icon-offset-x: -0.08cm, icon-offset-y: 0.06cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Three Color Infographic Card — independent text widths, offsets, and title gap]]
#align(center + horizon)[
  #three-color-infographic-card(
    title: [ADJUSTABLE TITLE],
    body: [Adjust the title and body widths and offsets independently; title-gap changes their vertical spacing.],
    width: 9.2cm, height: 4cm,
    title-width: 4.4cm, body-width: 4.9cm, title-gap: 0.3cm,
    title-offset-x: 0.08cm, body-offset-y: 0.06cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Neumorphic Text Panel — content width, title/body gap, icon and text offsets]]
#align(center + horizon)[
  #neumorphic-text-panel(
    title: [LAYOUT],
    body: [Change the spacing between title and copy, then position the medallion or either text block independently.],
    width: 4.8cm, height: 6cm, content-width: 4.1cm,
    title-body-gap: 0.15cm, icon-offset-y: -0.06cm,
    title-offset-x: -0.1cm, body-offset-x: 0.12cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Vertical Chevron List Item — column widths, horizontal gap, number size and offsets]]
#align(center + horizon)[
  #vertical-chevron-list-item(
    title: [ADJUSTABLE TITLE],
    body: [Choose the title/body column widths and the horizontal gap between them; resize and position the number independently.],
    width: 10.8cm, height: 1.7cm, title-width: 3.2cm, body-width: 4.6cm,
    title-body-gap: 0.3cm, number-size: 18pt, number-offset-y: 0.03cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Stacked Banner Row — functional padding, title/body gap, widths and icon offsets]]
#align(center + horizon)[
  #stacked-banner-row(
    title: [ADJUSTABLE TITLE],
    body: [Padding now changes the text inset. Title/body spacing and the icon and text positions can also be adjusted.],
    width: 10.8cm, height: 1.7cm, padding: 0.16cm,
    title-body-gap: 0.18cm, content-width: 6.2cm,
    icon-offset-x: 0.08cm, body-offset-y: 0.04cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Text Box Display Card — independent title/body widths and positions]]
#align(center + horizon)[
  #text-box-display-card(
    title: [ADJUSTABLE TITLE],
    body: [The title and body widths can be set independently; the icon, copy, and title can each be repositioned.],
    width: 4.8cm, height: 6.8cm, body-width: 3.5cm, title-width: 4cm,
    body-title-gap: 0.35cm, icon-offset-y: 0.05cm,
    body-offset-x: 0.08cm, title-offset-y: -0.04cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Quad Step Card — title/body controls plus independent medallion, icon and number offsets]]
#align(center + horizon)[
  #quad-step-card(
    number: [07], title: [ADJUSTABLE TITLE],
    body: [Both text columns and their gap can be tuned; each medallion, the icon, and the number can be positioned independently.],
    width: 4.8cm, height: 4.8cm, title-width: 4.1cm, body-width: 3.7cm,
    title-body-gap: 0.38cm, number-size: 11pt,
    icon-offset-y: 0.04cm, top-ring-offset-y: -0.04cm,
    bottom-badge-offset-y: 0.04cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Looped Chevron Callout — body width, text/icon position, chevron spacing and offset]]
#align(center + horizon)[
  #looped-chevron-callout(
    body: [Adjust the text column and icon position, move the chevrons, and set their spacing directly.],
    width: 11.2cm, height: 4.7cm, body-width: 5.8cm,
    body-offset-x: 0.08cm, icon-offset-y: -0.05cm,
    chevron-spacing: 0.52cm, chevron-offset-x: 0.08cm,
  )
]
