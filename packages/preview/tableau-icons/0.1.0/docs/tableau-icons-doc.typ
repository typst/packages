//#import "@preview/tableau-icons:0.1.0" as tbl
#import "../tableau-icons.typ" as tbl

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
#set enum(numbering: (it => text(weight: "bold", color.darken(blue, 10%))[#it.]))


#show heading.where(level: 1): it => {
  it
  block(
    line(length: 100%, stroke: (dash: (2pt, 4pt), cap: "round", thickness: 2pt, paint: blue)),
    above: 0.4em,
    below: 0.8em,
  )
}

#show heading.where(level: 3): it => {
  tbl.inline-outlined("test-pipe", fill: blue) + h(0.3em) + it.body
}

#let icons_header = (
  "accessible",
  "ad-circle",
  "ad",
  "adjustments",
  "aerial-lift",
  "affiliate",
  "air-balloon",
  "alarm-minus",
  "alarm-plus",
  "alarm-snooze",
  "alarm",
  "alert-circle",
  "alert-hexagon",
  "alert-octagon",
  "alert-square-rounded",
  "alert-square",
  "alert-triangle",
  "alien",
  "align-box-bottom-center",
  "align-box-bottom-left",
  "align-box-bottom-right",
  "align-box-center-middle",
  "align-box-left-bottom",
  "align-box-left-middle",
  "align-box-left-top",
  "align-box-right-bottom",
  "align-box-right-middle",
  "align-box-right-top",
  "align-box-top-center",
  "align-box-top-left",
  "align-box-top-right",
  "analyze",
  "app-window",
  "apple",
  "apps",
  "archive",
  "arrow-autofit-content",
  "arrow-autofit-down",
  "arrow-autofit-height",
  "arrow-autofit-left",
  "arrow-autofit-right",
  "arrow-autofit-up",
  "arrow-autofit-width",
  "arrow-badge-down",
  "arrow-badge-left",
  "arrow-badge-right",
  "arrow-badge-up",
  "arrow-big-down-line",
  "arrow-big-down-lines",
  "arrow-big-down",
  "arrow-big-left-line",
  "arrow-big-left-lines",
  "arrow-big-left",
  "arrow-big-right-line",
  "arrow-big-right-lines",
  "arrow-big-right",
  "arrow-big-up-line",
  "arrow-big-up-lines",
  "arrow-big-up",
  "arrow-down-circle",
  "arrow-down-rhombus",
  "arrow-down-square",
  "arrow-guide",
  "arrow-left-circle",
  "arrow-left-rhombus",
  "arrow-left-square",
  "arrow-move-down",
  "arrow-move-left",
  "arrow-move-right",
  "arrow-move-up",
  "arrow-right-circle",
  "arrow-right-rhombus",
  "arrow-right-square",
  "arrow-up-circle",
  "arrow-up-rhombus",
  "arrow-up-square",
  "artboard",
  "article",
  "aspect-ratio",
  "assembly",
  "asset",
  "atom-2",
  "automatic-gearbox",
  "award",
  "baby-carriage",
  "backspace",
  "badge",
  "badges",
  "balloon",
  "ballpen",
  "bandage",
  "barbell",
  "barrier-block",
  "basket",
  "bath",
  "battery-1",
  "battery-2",
  "battery-3",
  "battery-4",
  "battery-automotive",
  "battery-vertical-1",
  "battery-vertical-2",
  "battery-vertical-3",
  "battery-vertical-4",
  "battery-vertical",
  "battery",
  "bed-flat",
  "bed",
  "beer",
  "bell-minus",
  "bell-plus",
  "bell-ringing-2",
  "bell-ringing",
  "bell-x",
  "bell-z",
  "bell",
  "bike",
  "binary-tree-2",
  "binary-tree",
  "binoculars",
  "biohazard",
  "blade",
  "blender",
  "blob",
  "bolt",
  "bomb",
  "bone",
  "bong",
  "book",
  "bookmark",
  "bookmarks",
  "boom",
  "bottle",
  "bounce-left",
  "bounce-right",
  "bow",
  "bowl-chopsticks",
  "bowl-spoon",
  "bowl",
  "box-align-bottom-left",
  "box-align-bottom-right",
  "box-align-bottom",
  "box-align-left",
  "box-align-right",
  "box-align-top-left",
  "box-align-top-right",
  "box-align-top",
  "box-multiple",
  "brand-angular",
  "brand-apple",
  "brand-bitbucket",
  "brand-discord",
  "brand-dribbble",
  "brand-facebook",
  "brand-github",
  "brand-google",
  "brand-instagram",
  "brand-kick",
  "brand-linkedin",
  "brand-messenger",
  "brand-open-source",
  "brand-opera",
  "brand-patreon",
  "brand-paypal",
  "brand-pinterest",
  "brand-sketch",
  "brand-snapchat",
  "brand-spotify",
  "brand-steam",
  "brand-stripe",
  "brand-tabler",
  "brand-tiktok",
  "brand-tinder",
  "brand-tumblr",
  "brand-twitter",
  "brand-vercel",
  "brand-vimeo",
  "brand-weibo",
  "brand-whatsapp",
  "brand-windows",
  "brand-x",
  "brand-youtube",
  "bread",
  "briefcase-2",
  "briefcase",
  "brightness-auto",
  "brightness-down",
  "brightness-up",
  "brightness",
  "bubble-text",
  "bubble",
  "bug",
  "building-broadcast-tower",
  "bulb",
  "bus",
  "butterfly",
  "cactus",
  "calculator",
  "calendar-event",
  "calendar-month",
  "calendar-week",
  "calendar",
  "camera",
  "campfire",
  "candle",
  "cannabis",
  "capsule-horizontal",
  "capsule",
  "capture",
  "car-4wd",
  "car-crane",
  "car-fan",
  "car-suv",
  "car",
  "carambola",
  "caravan",
  "cardboards",
  "cards",
  "caret-down",
  "caret-left-right",
  "caret-left",
  "caret-right",
  "caret-up-down",
  "caret-up",
  "carousel-horizontal",
  "carousel-vertical",
  "cash-banknote",
  "category",
  "charging-pile",
  "chart-area-line",
  "chart-area",
  "chart-bubble",
  "chart-candle",
  "chart-donut",
  "chart-dots-2",
  "chart-dots-3",
  "chart-dots",
  "chart-funnel",
  "chart-grid-dots",
  "chart-pie-2",
  "chart-pie-3",
  "chart-pie-4",
  "chart-pie",
  "chef-hat",
  "cherry",
  "chess-bishop",
  "chess-king",
  "chess-knight",
  "chess-queen",
  "chess-rook",
  "chess",
  "christmas-tree",
  "circle-arrow-down-left",
  "circle-arrow-down-right",
  "circle-arrow-down",
  "circle-arrow-left",
  "circle-arrow-right",
  "circle-arrow-up-left",
  "circle-arrow-up-right",
  "circle-arrow-up",
  "circle-caret-down",
  "circle-caret-left",
  "circle-caret-right",
  "circle-caret-up",
  "circle-check",
  "circle-chevron-down",
  "circle-chevron-left",
  "circle-chevron-right",
  "circle-chevron-up",
  "circle-chevrons-down",
  "circle-chevrons-left",
  "circle-chevrons-right",
  "circle-chevrons-up",
  "circle-dot",
  "circle-key",
  "circle-letter-a",
  "circle-letter-b",
  "circle-letter-c",
  "circle-letter-d",
  "circle-letter-e",
  "circle-letter-f",
  "circle-letter-g",
  "circle-letter-h",
  "circle-letter-i",
  "circle-letter-j",
  "circle-letter-k",
  "circle-letter-l",
  "circle-letter-m",
  "device-remote",
  "device-speaker",
  "device-tablet",
  "device-tv-old",
  "device-tv",
  "device-unknown",
  "device-usb",
  "device-vision-pro",
  "device-watch",
  "dialpad",
  "diamond",
  "diamonds",
  "dice-1",
  "dice-2",
)

#box(clip: true, width: 100%, height: 8cm)[
  #box(
    inset: (left: -3cm, top: -3cm),
    width: 24cm,
    rotate(
      -10deg,
      [

        #for icon in icons_header {
          (
            tbl.inline-filled(icon, fill: color.lighten(blue, 10%), width: 3em, baseline: 20%)
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

#v(3.5cm)
#align(center)[

  #block(radius: 0.6em, stroke: orange + 1pt, inset: 0.5em, width: 60%)[
    #set align(left)
    == #tbl.inline-outlined("alert-triangle", fill: orange) This package has no association with Tabler

    This package contains the symbols from Tabler Icons #tabler-icons-version, but has no association with the Tabler.io team themselves.
  ]
]

#v(4mm)

Despite the bad naming (the name is translated _Table icons_, which is only one character away from _Tabler_ icons), this package implements a couple of functions to allow the use of Tabler.io Icons (#text(blue,underline(offset: 0.2em,link("https://tabler.io/icons")))) in your documents.

= Usage

For the use, I highly recommend to not _wildcard_ include the package (#raw(sym.dots + package-version + "\": *")), but to give it a name, such as #text(purple)[`tbl`] or similar. This way, the function writing is a bit more readable.

#raw(block: true, "#import \"@preview/tableau-icons:" + package-version + "\" as tbl", lang: "typst")

#v(0.8cm)

#columns(2)[
  == Block Functions
  To draw icons, grab the name of the desired icon over at \ #text(blue,underline(offset: 0.2em,link("https://tabler.io/icons"))) and insert it into one of the two icon type functions.

  ```typst
  #filled(body,
    fill: rgb("#000000"),
    width: 1em,
    height: auto
  )
  #outlined( ⋯ )  // same as 'filled'
  ```

  #colbreak()

  === Example:

  ```typst
#tbl.filled("spider", fill: black,
            width: 2em, height: 3em)
#tbl.outlined("trees", fill: olive,
              width: 5em, height: 3em)
  ```


  #columns(2)[
    #set align(center)

    #grid(
      columns: 2,
      [],
      grid.cell(inset: (bottom: 2pt), align: center + horizon)[`2em`],
      grid.cell(align: center + horizon)[#rotate(-90deg, `3em`)],
      box(stroke: (paint: (black), dash: (2pt, 2pt), thickness: 0.5pt))[
        #tbl.filled(
          "spider",
          fill: black,
          width: 2em,
          height: 3em,
        )]
    )
    #colbreak()
    #grid(
      columns: 2,
      [],
      grid.cell(inset: (bottom: 2pt), align: center + horizon)[`5em`],
      grid.cell(align: center + horizon)[#rotate(-90deg, `3em`)],
      box(stroke: (paint: (black), dash: (2pt, 2pt), thickness: 0.5pt))[
        #tbl.outlined(
          "trees",
          fill: olive,
          width: 5em,
          height: 3em,
        )]
    )
  ]
]

#v(5mm)

#columns(2)[
  == Inline Functions
  Similar to the previous two functions, the following ones can be used as _inline_.

  ```typst
  #inline-filled(body,
    baseline: 15%,
    fill: rgb("#000000"),
    width: 1em,
    height: auto
  )
  #inline-outlined( ⋯ ) // same as 'inline-filled'
  ```
  #colbreak()

  === Example:

  ```typst
  It's time to set a flag right here #tbl.inline-filled("flag", fill: red, width: 3mm) and over there #tbl.inline-outlined("flag", fill: green).
  ```

  It's time to set a flag right here #box(baseline: 10%, inset: (x: 0.1em),
    grid(
      columns: 1,
      align: center,
      grid.cell(inset: (bottom: 2pt), align: center + horizon)[`6mm`],
      grid.cell(align: center + horizon)[],
      box(baseline: 15%, stroke: (paint: (black), dash: (2pt, 2pt), thickness: 0.5pt))[
        #tbl.inline-filled(
          "flag",
          fill: red,
          width: 6mm,
        )]
    ),
  ) and over there #box(baseline: 10%, inset: (left: 0.1em, right: -0.6em),
    grid(
      columns: 1,
      align: left,
      grid.cell(inset: (bottom: 2pt), align: center + horizon)[`1em`],
      grid.cell(align: center + horizon)[],
      box(baseline: 15%, stroke: (paint: (black), dash: (2pt, 2pt), thickness: 0.5pt))[
        #tbl.inline-outlined(
          "flag",
          fill: green
        )]
    ),
  ) .

  It's time to set a flag right here #tbl.inline-filled("flag", fill: red, width: 6mm) and over there #tbl.inline-outlined("flag", fill: green).


]

#pagebreak()

#columns(2)[
  == General Function
  The `#render-icon` function is the base function, which the other functions use. It can be directly called.
  ```typst
  #render-icon(body,
    fill: rgb("#000000"),
    icon_type: "outline",
    width: 1em,
    height: auto
  )
  ```
  #colbreak()

  === Example:

  ```typst
  #tbl.render-icon("flag", fill: red, icon_type: "filled", width: 5em, height: 3em)
  ```
  #set align(center)
  #grid(
    columns: 2,
    [],
    grid.cell(inset: (bottom: 2pt), align: center + horizon)[`5em`],
    grid.cell(align: center + horizon)[#rotate(-90deg, `3em`)],
    box(stroke: (paint: (black), dash: (2pt, 2pt), thickness: 0.5pt))[#tbl.render-icon(
        "flag",
        fill: red,
        icon_type: "filled",
        width: 5em,
        height: 3em,
      )]
  )
]

= Updating the package

If some adjustments to the functions or a new Tabler icon version is released, the following steps should allow for an update to the package.


1. Clone the repositories of the package and the _Tabler Icons_ somewhere smart
2. Install python and call the `generate_svg_spritesheets.py` script inside the `tools` folder of the package repository

```bash
$ cd ~
$ git clone git@github.com:joelvonrotz/tableau-icons.git
$ git clone git@github.com:tabler/tabler-icons.git # or pull if already exists
$ cd tableau-icons/tools
$ python ./generate_svg_spritesheets.py
```

#[
#set enum(numbering: (it => text(weight: "bold", color.darken(red, 10%))[#it.]))
3. Don't forget to update the package info and the changelog below!
]

= Changelog

== `v0.1.0`

- initial version
- added Tabler Icons version v3.29.0
- added #raw("#filled()", lang: "typst"), #raw("#outlined()", lang: "typst"), #raw("#inline-filled()", lang: "typst"), #raw("#inline-outlined()", lang: "typst"), #raw("#render-icon()", lang: "typst")

#v(1cm)
#line(length: 30%)
*Used Fonts*: #text(blue,underline(offset: 0.2em,link("https://www.brailleinstitute.org/freefont/",[Atkinson Hyperlegible]))), #text(blue,underline(offset: 0.2em,link("https://github.com/microsoft/cascadia-code",[Cascadia Code])))\
*Created By* Joel von Rotz (\@joelvonrotz on #tbl.inline-filled("brand-github"))

