#import "@preview/tableau-icons:0.1.0" as tbl

#let package-info = toml("../typst.toml")

#let tabler-icons-version = "v3.29.0"
#let package-version = package-info.package.version

#set text(font: "Atkinson Hyperlegible", 9pt)
#set page(margin: (x: 1cm, top: 1cm))

// Display block code in a larger block
// with more padding.
#show raw.where(block: true): block.with(
  fill: luma(240),
  width: 100%,
  breakable: true,
  inset: 5pt,
  radius: 4pt,
)


#show raw.where(block: false): it => text(1.1em, it)

#set enum(numbering: (it => align(text(weight: "bold", color.darken(blue, 10%), number-width: "tabular")[#it.], horizon)))


#show enum: set align(top)
#show enum: set par(leading: 0.8em)

#show heading.where(level: 1): it => {
  it
  block(
    line(length: 100%, stroke: (dash: (2pt, 4pt), cap: "round", thickness: 2pt, paint: blue)),
    above: 0.4em,
    below: 0.8em,
  )
}

#show heading.where(level: 3): it => {
  tbl.draw-icon("test-pipe", fill: blue) + h(0.3em) + it.body
}

#let icons_header = (
  "abacus",
  "access-point",
  "adjustments-alt",
  "alien",
  "anchor",
  "apple-filled",
  "armchair",
  "atom",
  "award",
  "backpack",
  "battery-charging",
  "bell-ringing",
  "bluetooth",
  "bomb-filled",
  "box",
  "brain",
  "brush",
  "bulb-filled",
  "calendar-event",
  "camera-selfie",
  "caravan",
  "chart-pie-filled",
  "check",
  "cloud-snow",
  "compass",
  "currency-bitcoin",
  "database",
  "device-laptop",
  "flag-filled",
  "dna",
  "dog-bowl",
  "ear",
  "edit",
  "external-link",
  "feather-filled",
  "flask",
  "device-gamepad",
  "ghost",
  "globe-filled",
  "guitar-pick",
  "hammer",
  "headphones",
  "heartbeat",
  "ice-cream",
  "jetpack",
  "key",
  "layers-difference",
  "lifebuoy-filled",
  "lock-open",
  "mail",
  "map-pin-filled",
  "moon-stars",
  "music",
  "navigation",
  "note",
  "octagon-filled",
  "palette-filled",
  "paw",
  "printer",
  "puzzle-filled",
  "rainbow",
  "rocket",
  "satellite",
  "scissors",
  "server",
  "shield-filled",
  "skull",
  "smart-home",
  "space",
  "speedboat",
  "stack",
  "steering-wheel",
  "sunrise",
  "target",
  "telescope",
  "temperature",
  "traffic-lights",
  "umbrella-filled",
  "vaccine",
  "vector",
  "wallet",
  "wind",
  "yin-yang",
  "zoom-in",
  "air-balloon",
  "alarm",
  "ambulance",
  "antenna",
  "archive-filled",
  "arrow-loop-left",
  "backhoe",
  "badge-filled",
  "balloon",
  "barcode",
  "ball-basketball",
  "battery-4",
  "beach",
  "beer",
  "bell-off",
  "bike",
  "binoculars",
  "bolt",
  "book-filled",
  "bookmark",
  "ball-bowling",
  "building-bridge",
  "briefcase",
  "bulldozer",
  "bus",
  "butterfly",
  "calculator",
  "calendar-check",
  "camera",
  "campfire-filled",
  "candle",
  "candy",
  "capsule-filled",
  "car",
  "carrot",
  "building-castle",
  "cat",
  "brand-line",
  "checkbox",
  "chess",
  "chevron-up",
  "cpu",
  "building-church",
  "circle-check-filled",
  "buildings",
  "clipboard-filled",
  "clock",
  "cloud-upload",
  "coffee",
  "compass-off",
  "device-desktop",
  "camper",
  "crane",
  "credit-card",
  "cube",
  "dashboard",
  "database-import",
  "backspace",
  "diamond-filled",
  "disc",
  "door",
  "download",
  "droplet",
  "globe",
  "egg",
  "elevator",
  "engine",
  "eraser",
  "eye-off",
  "building-factory",
  "player-skip-forward-filled",
  "file",
  "flame-filled",
  "flame",
  "lighter",
  "flower",
  "cell-signal-5",
  "cell-signal-off",
  "certificate",
  "certificate-2",
  "circle-half-2",
  "circle-half-vertical",
  "circle-key-filled",
  "circle-letter-a-filled",
  "charging-pile-filled",
  "chart-arcs",
  "chart-arcs-3",
  "chart-area",
  "coffee-off",
  "coffin",
  "coin",
  "coin-bitcoin-filled",
  "cone-2-filled",
  "cone-filled",
  "cone-off",
  "cone-plus",
  "confetti",
  "confetti-off",
  "cone-2",
  "copyright",
  "copyright-filled",
  "copyright-off",
  "corner-down-left",
  "corner-down-left-double",
  "corner-down-right",
  "corner-down-right-double",
  "cursor-text",
  "cut",
  "cylinder",
  "cylinder-off",
  "cylinder-plus",
  "dashboard",
  "device-ipad-horizontal-star",
  "device-ipad-horizontal-up",
  "device-ipad-horizontal-x",
  "device-ipad-minus",
  "device-ipad-off",
  "dice-1-filled",
  "dice-2",
  "dice-2-filled",
  "dice-3",
  "dice-4",
  "dice-4-filled",
  "dice-5",
  "dice-6-filled",
  "dice-filled",
  "dimensions",
  "direction",
  "drone",
  "drone-off",
  "drop-circle",
  "droplet",
  "droplet-bolt",
  "droplet-cancel",
  "droplet-check",
  "droplet-code",
  "dual-screen",
  "dumpling",
  "e-passport",
  "ear",
  "ear-off",
  "ear-scan",
  "ease-in",
  "ear-off",
  "ear-scan",
  "ease-in",
  "ease-in-control-point",
  "ease-in-out",
  "ease-in-out-control-points",
  "ease-out",
  "ease-out-control-point",
  "ear-off",
  "ear-scan",
  "ease-in",
  "ease-in-control-point",
  "ease-in-out",
  "ease-in-out-control-points",
  "ease-out",
  "ease-out-control-point",
  "egg-fried",
  "egg-off",
  "eggs",
  "elevator",
  "elevator-filled",
  "elevator-off",
  "emergency-bed",
  "empathize",
  "egg-off",
  "eggs",
  "elevator",
  "elevator-filled",
  "elevator-off",
  "emergency-bed",
  "empathize",
  "empathize-off",
  "emphasis",
  "engine",
  "engine-filled",
  "engine-off",
  "equal",
  "equal-double",
  "equal-not",
  "eraser",
  "eraser-off",
  "error-404",
  "error-404-off",
  "escalator",
  "escalator-down",
  "escalator-up",
  "exchange",
  "exchange-off",
  "exclamation-circle",
)

#box(clip: true, width: 100%, height: 8cm)[
  #box(
    inset: (left: -2em, top: -6em),
    width: 24cm,
    rotate(
      -10deg,
      [
        #for icon in icons_header {
          (
            tbl.draw-icon(icon, fill: color.lighten(blue, 10%), height: 2.9em, width: 2.9em)
          )
        }
      ],
    ),
  )
]

#v(-5.7cm)
#block(
  width: 100%,
  align(center + horizon)[
    #box(
      stroke: white + 2pt,
      fill: white,
      inset: 0em,
      radius: (top: 2em, bottom: 1em),
    )[
      #box(
        stroke: black + 2pt,
        fill: white,
        inset: 2em,
        radius: 2em,
        align(center + horizon)[#text(weight: "bold", 4em, font: "Atkinson Hyperlegible")[tableau-icons.typ]],
      )
      #block(height: 2em, above: 0.3em)[
        #set align(center + horizon)
        #set text(1.25em)
        #grid(columns: (30%, 30%), align: (left, right))[
          *Tabler Icons Version* #tabler-icons-version
        ][*Package* #package-version]
      ]
    ]
  ],
)

#v(3cm)
#align(center)[

  #block(radius: 0.6em, stroke: orange + 1pt, inset: 0.5em, width: 60%)[
    #set align(left)
    == #tbl.draw-icon("alert-triangle", fill: orange) This package has no association with Tabler

    This package contains the symbols from Tabler Icons #tabler-icons-version, but has no association with the Tabler.io team themselves.
  ]
]

#v(4mm)

Despite the bad naming (the name is translated _Table icons_, which is only one character away from _Tabler_ icons), this package implements a couple of functions to allow the use of Tabler.io Icons (#text(blue,underline(offset: 0.2em,link("https://tabler.io/icons")))) in your documents.

= #tbl.draw-icon("hammer", fill: blue, baseline: 0.15em) Usage

For the use, I highly recommend to not _wildcard_ include the package (#raw(sym.dots + package-version + "\": *")), but to give it a name, such as #text(purple)[`tbl`] or similar. This way, the function writing is a bit more readable.

#raw(block: true, "#import \"@preview/tableau-icons:" + package-version + "\" as tbl", lang: "typst")

== Prerequisites

As this package does not ship with the Tabler icons, the font files have to be installed separately! To do that:

#[
  1. Download the latest release on the Tabler Icons repository page #link("https://github.com/tabler/tabler-icons/releases",text(blue,`https://github.com/tabler/tabler-icons/releases`))
  2. Extract the zip file and enter the folders `./tabler-icons-X.XX.X/webfont/fonts`
  3. Install the font file `tabler-icons.ttf`
]

== #tbl.draw-icon("code", fill: blue) Draw Function
#columns(2)[
  To draw icons, grab the name of the desired icon over at \ #text(blue,underline(offset: 0.2em,link("https://tabler.io/icons"))) and insert it into #raw("#draw-icon()", lang: "typst") function.

  The function retrieves the given tag name and places it inside a #raw("#box", lang: "typst"), which can be configured via the #raw("..args", lang: "typst") parameter.

  ```typst
  #draw-icon(
    body,
    fill: rgb("#000000"),
    height: 1em,
    ..args
  )
  ```

  #colbreak()

  === Example:

  ```typst
  #tbl.draw-icon("ball-tennis", fill: red, height: 3em, width: 5em)]
  #tbl.draw-icon("trees", fill: olive, height: 4em)]
  #tbl.draw-icon("dog", fill: blue, height: 3em, width: 5em)]
  ```


  #columns(3)[
    #set align(center)

    #grid(
      columns: 2,
      [],
      grid.cell(inset: (bottom: 2pt), align: center + horizon)[`5em`],
      grid.cell(align: center + horizon)[#rotate(-90deg, `3em`)],
      box(stroke: (paint: (black), dash: (2pt, 2pt), thickness: 0.5pt))[
        #tbl.draw-icon(
          "ball-tennis",
          fill: red,
          height: 3em,
          width: 5em,
        )]
    )
    #colbreak()
    #grid(
      columns: 2,
      [],
      grid.cell(inset: (bottom: 2pt), align: center + horizon)[`4em`],
      grid.cell(align: center + horizon)[#rotate(-90deg, `4em`)],
      box(stroke: (paint: (black), dash: (2pt, 2pt), thickness: 0.5pt))[
        #tbl.draw-icon(
          "trees",
          fill: olive,
          height: 4em,
        )
      ]
    )
    #colbreak()
    #grid(
      columns: 2,
      [],
      grid.cell(inset: (bottom: 2pt), align: center + horizon)[`5em`],
      grid.cell(align: center + horizon)[#rotate(-90deg, `3em`)],
      box(stroke: (paint: (black), dash: (2pt, 2pt), thickness: 0.5pt))[
        #tbl.draw-icon("dog", fill: blue, height: 5em, width: 3em)]
    )
  ]
]

#pagebreak()

= #tbl.draw-icon("garden-cart", fill: blue, height: 1em, baseline: 0.15em) Updating the package

If some adjustments to the functions or a new Tabler icon version is released, the following steps should allow for an update to the package.


1. Clone the `tableau-icons` repository
2. Download the latest release of the `tabler/tabler-icons` repository
3. Install python and execute the `generate_unicode_reference.py` script inside the `tools` folder of the package repository

```bash
$ cd ~
$ git clone git@github.com:joelvonrotz/tableau-icons.git
$ # download the latest release from repo 'tabler/tabler-icons'
$ cd tableau-icons/tools
$ python ./generate_unicode_reference.py
```

#[
  #set enum(numbering: (it => text(weight: "bold", color.darken(red, 10%))[#it.]))
  4. Don't forget to update the package info and the changelog below!
]

= #tbl.draw-icon("versions", fill: blue, height: 1em, width: 1em, baseline: 0.15em) Changelog

== `v0.1.0`

#[
  - initial version
  - added Tabler Icons version v3.29.0
  - added #raw("#draw-icon()", lang: "typst")
]

#v(1cm)
#line(length: 30%)
*Used Fonts*: #text(blue,underline(offset: 0.2em,link("https://www.brailleinstitute.org/freefont/",[Atkinson Hyperlegible]))), #text(blue,underline(offset: 0.2em,link("https://github.com/microsoft/cascadia-code",[Cascadia Code])))\
*Created By* Joel von Rotz (\@joelvonrotz on #tbl.draw-icon("brand-github"))

