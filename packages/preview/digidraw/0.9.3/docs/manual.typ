#import "@preview/cetz:0.5.2"
#import "@preview/tableau-icons:0.344.0": ti-icon
#import "@preview/alertoni:1.0.0" as at
#import "@preview/tiptoe:0.4.0" as tt
#import "@preview/tidy:0.4.3"

#import "template.typ": manual-template, myraw


#let types = (
  content: box([`content`], stroke: blue + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  array: box([`array`], stroke: orange + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  bool: box([`bool`], stroke: orange + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  string: box([`string`], stroke: olive + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  dictionary: box([`dictionary`], stroke: purple.lighten(40%) + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  length: box([`length`], stroke: red.lighten(40%) + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  float: box([`float`], stroke: blue.lighten(40%) + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  ratio: box([`ratio`], stroke: blue.lighten(40%) + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  function: box([`function`], stroke: olive.lighten(40%) + 0.5pt, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  "stroke": box([`stroke`], fill: gradient.linear(angle: 15deg,..color.map.spectral.map(x=>x.lighten(30%))), stroke: none, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  "none": box(text(red)[`none`], stroke: none, radius: 2pt, outset: (y: 2pt), inset: (x: 2pt)),
  "or": text(0.5em, [OR]),
)


#let paint = purple

#let dashed-line = cetz.draw.line.with(stroke: (
  paint: paint.lighten(40%),
  thickness: 0.5pt,
  dash: (0pt, 1.4pt),
  cap: "square",
))

#let T-line = cetz.draw.line.with(
  mark: (symbol: "|", anchor: "center"),
  stroke: paint.lighten(40%) + 0.75pt,
)

#let tidylink(..args, stroke: gray + 0.5pt, size: 0.8em) = {
  set underline(stroke: 0pt)
  show link: set text(paint)
  show "wave.": set text(gray)
  show "-": sym.zwj + "-" + sym.zwj
  box(fill: white, outset: (y: 3pt), inset: (x: 2pt), stroke: stroke, radius: 3pt, text(paint, size, link(..args)))
}


#import "@preview/digidraw:0.9.3"



#import "@preview/chribel:1.2.0": callout



#let smallcaps(content) = upper(content.first() + text(0.8em, weight: "medium", content.slice(1)))
#let package(content, paint: blue) = text(smallcaps(content), paint)

#let parameter(body) = box(
  raw(body, lang: "typc"),
  outset: (y: 3pt),
  inset: (x: 2pt),
  stroke: 0.5pt + gray,
  radius: 2pt,
)



#show: manual-template

/* ------------------------- [CONFIGURATION] ------------------------- */

#let toml = toml("../typst.toml")
#let version = toml.package.version
#let package-name = "Digidraw"

#let header-data = (
  signal: (
    (
      wave: "x2....0.|z1.z.0ddd2.xx",
      data: (
        text(1.2em)[#package(package-name, paint: black) Manual],
        text(1.2em)[#version],
      ),
    ),
  ),
)


#let footer-data = (
  signal: (
    (
      wave: "dd02.1u.",
      data: (
        context {
          let total = locate(<last-page>)
          show link: set text(black)
          show link: set underline(stroke: 0pt)
          [#counter(page).at(here()).first() / #total.page()]
        },
      ),
    ),
  ),
)

#let custom-wave-config = (
  stroke: gray.darken(50%) + 0.5pt,
  symbol-height: 6mm,
  show-ticks: false,
  tick-format: none,
  bus-colors: (
    "2": white,
    "3": rgb("#ffffb4"),
    "4": rgb("#ffe0b9"),
    "5": rgb("#b9e0ff"),
    "6": rgb("#ccfdfe"),
    "7": rgb("#cdfdc5"),
    "8": rgb("#f0c1fb"),
    "9": rgb("#f8d0ce"),
    "x": tiling(size: (1.25mm, 1.25mm), box(width: 100%, height: 100%, fill: white, {
      set line(stroke: gray.darken(50%) + 0.3pt)
      place(std.line(start: (0%, 100%), end: (100%, 0%)))
      place(std.line(start: (90%, 110%), end: (110%, 90%)))
      place(std.line(start: (-10%, 10%), end: (10%, -10%)))
    })),
  ),
)

#let custom-wave = dd.wave.with(
  symbol-width: (210mm - 40mm) / 22,
  ..custom-wave-config,
)

#set page(
  margin: (x: 20mm, top: 25mm, bottom: 25mm),
  header-ascent: 10mm,
  footer-descent: 10mm,
  header: grid(
    columns: (1fr, auto),
    rows: 6mm,
    align: (left + horizon, right + horizon),
    ..{
      (
        custom-wave(
          header-data,
        ),
      )
    }
  ),
  footer: grid(
    columns: 1fr,
    rows: 6mm,
    align: (center),
    ..{
      (
        custom-wave(
          footer-data,
        ),
      )
    }
  ),
)




/* --------------------------- [SETTINGS] ---------------------------- */
#set text(font: ("Libertinus Sans", "Noto Color Emoji"))
#set smartquote(quotes: (
  single: (sym.quote.chevron.single.l, sym.quote.chevron.single.r),
  double: (sym.quote.chevron.double.l, sym.quote.chevron.double.r),
))

#show raw: set text(font: "Maple Mono")

#show heading.where(level: 2): it => {
  show raw: set text(1.15em)
  it
}
#show heading.where(level: 3): it => {
  show raw: set text(1.15em)
  it
}

#show heading: set text(font: "Atkinson Hyperlegible Next", weight: "bold")

#show heading.where(level: 1, outlined: true): set heading(numbering: (..n) => (
  text(blue, numbering("I", ..n)) + text(gray, weight: "regular", [ \\])
))

#show heading.where(level: 2): set heading(numbering: (..n) => {
  [#text(gray, weight: "regular", numbering("I.", n.at(0)))#text(blue, numbering("1", n.at(1)))]
})

#show heading.where(level: 3): set heading(numbering: (..n) => {
  [#text(gray, weight: "regular", numbering("I.1.", ..n.pos().slice(0, 2)))#text(blue, numbering("a", ..n
      .pos()
      .slice(2, 3)))]
})

#show heading.where(level: 1): set text(1.5em)
#show heading.where(level: 1): it => {
  block(width: 100%, below: 1em, above: 3em, {
    custom-wave(
      (signal: ((wave: "52.............d.", data: (none, align(left, pad(left: 0.3em, it)))),)),
      bus-colors: ("7": olive.lighten(80%)),
      show-ticks: false,
      tick-format: none,
      symbol-height: 1cm,
      symbol-width: 1cm,
      step1: 5%,
      step2: 30%,
      step3: 60%,
      stroke: blue + 1pt,
    )
  })
}

#let mylink(..args) = text(blue, underline(offset: 0.15em, emph(link(..args))))


#set par(justify: true)
#set table(stroke: 0.5pt)



#set enum(numbering: n => strong(text(blue, font: "Libertinus Sans", numbering("I.", n))))




/* ---------------------------- [CONTENT] ---------------------------- */

#place(
  top + center,
  scope: "parent",
  float: true,
  {
    v(1.5cm)
    text(1em)[
      #block(stroke: blue + 0.5pt, dd.wave(
        (
          signal: (
            // | d |i| g |i| d |r | a |   w
            (wave: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"),
            (wave: "x1................................x"),
            (wave: "x1........2..Ph......z.H.|.2..u...x"),
            (wave: "x0.5..0.50....51..50..............x"),
            (wave: "x1.50.50..........51..............x"),
            (wave: "x0.51.51505..0505..05.05..0515150.x"),
            (wave: "x1.50.5051505151505151.5151505051.x"),
            (wave: "x0.5..1.505..0505..050.5.5015151..x"),
            (wave: "x1..........51....................x"),
            (wave: "x0.hlH|.L.5..0.1..znnp....u.|.d2.0x"),
            (wave: "x0................................x"),
            (wave: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"),
          ),
        ),
        stroke: blue + 0.25pt,
        symbol-height: 170mm / 35,
        wave-gutter: 0.3mm,
        step2: 20%,
        step1: 10%,
        symbol-width: 170mm / 35,
        show-ticks: false,
        tick-format: none,
        bus-colors: (
          "5": blue,
          "x": dd.digidraw-x-pattern(stroke: blue + 0.3pt),
        ),
      ))
      *Created by Joel von Rotz* #h(1fr)Source Code on #box(text(
        rgb("#2684cf"),
        top-edge: "cap-height",
        bottom-edge: "baseline",
        link("https://codeberg.org/joelvonrotz/typst-digidraw", grid(
          [Codeberg], box(image("assets/codeberg-logo_icon_blue.svg")),
          columns: 2,
          align: horizon,
          gutter: 2pt,
        )),
      ), baseline: 0.24em)
    ]
    v(1cm)
  },
)



#package(package-name) is a Typst package to help with drawing digital timing diagrams. The syntax tries to be like from #mylink("https://wavedrom.com/", [WaveDrom]), although is slightly different in some areas. In addition, the package supports more customization such as configuring colors, fonts and others.

The package uses #package("CeTZ") to draw everthing.



#callout(
  type: "caution",
  width: 80%,
  [Not all symbol combinations have been implemented so far (probably) or they differ from WaveDrom, so expect some undefined or unexpected behaviour.

    If they are straying too far away from the timing diagram standard, please report them in the package repository: #mylink("https://codeberg.org/joelvonrotz/typst-" + lower(package-name) + "/")],
)

#show outline.entry.where(level: 1): it => {
  show: strong
  it
}

#heading(level: 1, outlined: false, [Contents])
#align(center, block(width: 80%, [
  #outline(title: none)
]))

#pagebreak()

= Installation

== From Universe (aka. Stable Version)

To import the Universe version, insert following snippet

#raw(block: true, "#import \"@preview/" + lower(package-name) + ":" + version + "\" as dd", lang: "typ")


== From Repository (aka. Development Version)

The repository will always be the #emph[development] version of #package(package-name). This will also include the latest changes, but might break here and there.

1. Clone the Repository into your project (for example into a `./packages/` folder or at root level).

  #myraw(
    block: true,
    "cd /path/to/project/\ngit clone https://codeberg.org/joelvonrotz/typst-" + lower(package-name) + ".git",
    lang: "bash",
  )


  *OR* if your project is a git project, you can add it as a submodule, saving a little bit of space in your repository:

  #myraw(
    block: true,
    "cd /path/to/project/\ngit submodule add https://codeberg.org/joelvonrotz/typst-" + lower(package-name) + ".git",
    lang: "bash",
  )

2. Include the package into your document
  #myraw(
    block: true,
    "#import \"./path/to/typst-" + lower(package-name) + "/lib.typ\" as dd",
    lang: "typ",
  )

= Usage

== Drawing Diagrams

Drawing a diagram is easy:

```vexample
#dd.wave(
  (signal: (
    (wave: "x12.udx34z.5.x.",data: "Hello This is Digidraw"),)
  )
)
```

#pagebreak()

== Debugging Diagrams

You can turn on Debug mode by setting #parameter("debug: true") in the `wave()` function. This shows where and which symbol is placed and how long said symbol is. Additionally the #underline(stroke: red + 1pt, offset: 0.15em)[`step1`], #underline(stroke: blue + 1pt, offset: 0.15em)[`step2`] and #underline(stroke: olive + 1pt, offset: 0.15em)[`step3`] parameters are shown with respective coloured vertical lines. Debug mode also shows the exact placement of bus labels using a bounding box #box(stroke: red + 1pt, width: 1.5em, height: 0.5em, outset: (y: 2pt), {
  set line(stroke: (paint: red, thickness: 0.5pt, dash: "densely-dashed"))
  place(line(start: (0%,0% - 2pt), end: (100%,100% + 2pt)))
  line(start: (0%,100% + 2pt), end: (100%,0% - 2pt))
}) and a #box(fill: orange.lighten(80%), outset: (y: 4pt), radius: 2pt, inset: (x: 2pt), [center point #ti-icon("circle-filled", size: 0.7em, fill: orange)]).

```vexample
//+#dd.wave(
//-#wave(symbol-width: 1.4cm, symbol-height: 1.5cm,wave-gutter: 8mm,
  (signal: (
    (wave: "x12.udx345.", data: "Hello This is Digidraw"),
  )),
  debug: true
)
```

This looks quite cluttered and is not the actual recommended way to use this feature. Instead you can pass one or more of #{
  set raw(lang: "typc")
  [`"symbols"`, `"labels"`, `"coordinates"` and `"steps"`]
} to show the respective information.

- #raw("\"symbols\"", lang: "typc") -- shows the arrows below the respective wave to show which shape belongs to which symbol.

```hexample
//+#dd.wave(
//-#wave(symbol-width: 1cm, symbol-height: 1.5cm,wave-gutter: 8mm,
  (signal: ((wave: "x2.ud34."),)),
  tick-format: none,
  debug: "symbols"
)
```

- #raw("\"labels\"", lang: "typc") -- shows the area in which labels can be placed. By default labels are placed `horizon+center` in the respective box. This can be changed per entry by enclosing the label in a #raw("#align(..)", lang: "typst").

```hexample
//+#dd.wave(
//-#wave(symbol-width: 1cm, symbol-height: 1.5cm,wave-gutter: 8mm,
  (signal: ((wave: "x2.ud34."),)),
  tick-format: none,
  debug: "labels"
)
```

- #raw("\"steps\"", lang: "typc") -- shows the "steps" of each symbol. These are the x coordinates (per symbol) used for transition (i.e. `0`$->$`1`) and bezier curves (i.e. `2`$->$`u`).

```hexample
//+#dd.wave(
//-#wave(symbol-width: 1cm, symbol-height: 1.5cm,wave-gutter: 8mm,
  tick-format: none,
  (signal: ((wave: "x2.ud34."),)),
  debug: "steps"
)
```


- #raw("\"coordinates\"", lang: "typc") -- shows the vertical coordinates of each wave, which helps when using the #tidylink(size: 1em, <-wave.others>, [`others`]) parameter.
  #callout(type: "important", width: 70%, [Coordinates are given in *`cetz`* units and are relative to #tidylink(size: 1em, <-wave.symbol-width>, [`symbol-width`]). So #box($l_"actual" = l_"relative" dot mono("symbol-width")$, stroke: red + 0.25pt, radius: 2pt, outset: (y: 4pt), inset: (x: 3pt)) can be used to get the absolute lengths from relative coordinates.
  ])

```hexample
#dd.wave(
  symbol-width:  1cm,
  symbol-height: 5mm,
  wave-gutter: 7.5mm,
  (signal: (
    (wave: "x2.ud", name: "A Name"),
    (wave: "x2.ud", data: ([Data],)),
    (:),
    (wave: "x2.ud"))
  ),
  debug: "coordinates"
)
```


== Data Structure

Let's talk about wave data structures! The data syntax is the one from WaveDrom. You can copy _WaveDrom_ scripts and insert those into your document. Well, almost… there are certain features such as groups that are not yet implemented and are thus ignored.

There's two ways on how to define the wave data: as dictionaries or as JSON structures

=== Data-Format: Dictionaries

This allows for fancier styling labels. `.wave` and `.data` can contain _`content`_ . Raw'em, Strong'em, Emph'em,
do what you want, as long as it turns into a content.

```vexample
#let data = (signal: (
  (wave: "0u3..0..1..2|.", name: `Hello`, data: (text(1.5em,`World`),)),
  (wave: "012.3..45..u|1", name: "Hello", data: ($A$, [_B_], [*C*], `D`))
))

#dd.wave(data)
```

=== Data-Format: JSON

Easier when copying from WaveDrom with the downside of not having much styling options compared to the dictionary based structure.


```vexample
#let data = json(bytes(`{"signal": [
  {"wave": "0u3..0..1..2..", "name": "Hello", "data": ["Hello","World"]},
  {"wave": "012.3..45..u.1", "name": "Hello", "data": "A B C D"}
]}`.text)) // or json(read("file.json"))

#dd.wave(data)
```

=== Structure

```hexample
#let data = (
  signal: (
    ( wave: "10.u.10", name: "\#1" ),
    (
      wave: "z3....z",
      name: "\#2",
      data: ([doing some stuff],)
    ),
  )
)
#dd.wave(data)
```

/ `.signal`: #types.array of #types.dictionary\
  A list/array containing the wave objects.

/ `.wave`: #types.string \
  The wave's contents built using the #mylink(<sec:symbols>, [Symbols]).\
  #underline[Example]: #raw(lang: "typc", `"10..u.10"`.text)

/ `.name`: #types.string #text(0.7em, [or])  #types.content\
  The name of the wave.\
  #underline[Example]: #raw(lang: "typc", `"Mike"`.text) or `[Mike]`

/ `.data`: #math.underparen(pad(bottom: 0.2em)[#types.string], [JSON, Typst]) #text(0.7em, [or]) #math.underparen(
    pad(bottom: 0.2em)[#types.array of #types.content],
    [Typst only],
  ) #text(0.7em, [or]) #math.underparen(pad(bottom: 0.2em)[#types.array of #types.string], [JSON, Typst])#v(1pt)
  When buses are defined in the wave, labels can be inserted. The index of the label defines its position: first entry goes into the first bus, second in the second one, etc. If data is a string, labels are split by spaces.

  i.e. #raw(lang: "typc", `"Hello World"`.text) is equal to #raw(lang: "typc", `("Hello","World")`.text)

#pagebreak()

= Symbols <sec:symbols>

#[
  #let boxraw(..args) = box(fill: gray.lighten(70%), outset: (y: 3pt), inset: (x: 2pt), radius: 2pt, raw(..args))

  == Clocks

  === Normal Clocks #boxraw("p") #boxraw("P")

  Capitalizing the letters adds an arrow mark to the line pointing up.

  ```hexample
  #dd.wave(
    (signal: ((wave: "pppPPP",),)),
    debug: "symbols"
  )
  ```

  === Inverted Clocks #boxraw("n") #boxraw("N")

  Capitalizing the letters adds an arrow mark to the line pointing up.

  ```hexample
  #dd.wave(
    (signal: ((wave: "nnnNNN",),)),
    debug: "symbols"
  )
  ```

  == Wires

  === Straight Signals #boxraw("l") #boxraw("L") #boxraw("h") #boxraw("H")

  Capitalizing the letters adds an arrow mark to the line pointing up.

  ```hexample
  #dd.wave(
    (signal: ((wave: "lhLHlLh",),)),
    debug: "symbols"
  )
  ```

  === Flanked Signals #boxraw("0") #boxraw("1")

  Using `0` and `1` instead of `l`/`L` and `h`/`H` inserts flanked/sloped signals.

  ```hexample
  #dd.wave(
    (signal: (
      (wave: "x01010x",),
      (wave: "x0..1..",),
      (wave: "000111x",),
    )),
    debug: "symbols"
  )
  ```

  === High-Impedance Signal #boxraw("z")
  The high impedance signal introduces curved transitions from any signal to high impedance.
  
  / Note: multiples of the symbols in a sequence are treated as one long one\
    #underline[Examples] #raw(lang:"typc",`"zzz2.zz"`.text) $->$ #raw(lang:"typc",`"z..2.z."`.text)

  
  ```hexample
  #dd.wave(
    (signal: (
      (wave: "xz0z1z.",),
      (wave: "zzz2.zz",),
    )),
    debug: "symbols"
  )
  ```

  === Transition Edges #boxraw("u") #boxraw("d")
  If the transition has of unknown duration/delay, a transition edge can be used.

  / Note: multiples of the symbols in a sequence are treated as one long one\
    #underline[Examples] #raw(lang:"typc",`"uuuddduuu"`.text) $->$ #raw(lang:"typc",`"u..d..u.."`.text)
  
  ```hexample
  #dd.wave(
    (signal: (
      (wave: "du.xd2u",),
      (wave: "0uuuddd",),
    )),
    debug: "symbols"
  )
  ```

  == Buses

  === Don't Care #boxraw("x")

  Indicates a section, where the signal value is not important, aka. _don't care_.

  / Note: multiples of the symbols in a sequence are treated as one long one\
    #underline[Examples] #raw(lang:"typc",`"xxx|xxx20"`.text) $->$ #raw(lang:"typc",`"x..|...20"`.text)
  
  ```hexample
  #dd.wave(
    (signal: (
      (wave: "x0x1x|x.",),
      (wave: "xxx|xx20",),
    )),
    debug: "symbols"
  )
  ```

  === Simple Bus #boxraw("=") #boxraw("2")
  `=` and `2` are similar in that they have the same bus color. That's it, nothing special, really! 

  ```hexample
  #dd.wave(
    (signal: (
      (wave: "20212|2.",),
      (wave: "=0=1=|=.",),
    )),
    debug: "symbols"
  )
  ```
#pagebreak()

  === Coloured Buses #boxraw("3") #boxraw("4") #boxraw("5") #boxraw("6") #boxraw("7") #boxraw("8") #boxraw("9")

  The databus can be also colored using numbers `"3"` through `"9"`.

  ```hexample
  #dd.wave(
    (signal: (
      (wave: "30313|3.", data: (`3`,)),
      (wave: "40414|4.", data: (`4`,)),
      (wave: "50515|5.", data: (`5`,)),
      (wave: "60616|6.", data: (`6`,)),
      (wave: "70717|7.", data: (`7`,)),
      (wave: "80818|8.", data: (`8`,)),
      (wave: "90919|9.", data: (`9`,)),
    )),
  )
  ```

  == Extender #boxraw(".")

  The extender can be used to extend signals. If a signal doesn't look right, you might have to replace some of the symbols with the extender. And if that doesn't work, report it!

  For example, while a `"1111"` inserts high signals with impulses, `"1..."` stretches.

  ```hexample
  #dd.wave(
    (signal: (
      (wave: "11111..."),
      (wave: "00000..."),
    )),
    debug: "symbols"
  )
  ```

  == Time Skip #boxraw("|")

  To insert a timeskip to indicate the passing of a long time, insert the symbol `"|"`.

  ```hexample
  #dd.wave(
    (signal: (
      (wave: "z|u|d|.1"),
      (wave: "z|d|d|.1"),
    )),
    debug: "symbols"
  )
  ```
]


#pagebreak()
= API Reference

A lot of things in a timing diagram can be customized, ranging from sizing and gutter spacing to coloring and text formatting. Below the most important and useful parameters are shown and their graphical effect.

#v(1cm, weak: true)
#align(center, {
  dd.wave(
    (
      signal: (
        (wave: "12.zuNL.", name: box(stroke: paint.transparentize(40%) + 0.75pt, outset: 3pt, radius: 1mm)[Wave Name]),
        (
          wave: "02.02345",
          data: (box(stroke: paint.transparentize(40%) + 0.75pt, outset: 3pt, radius: 1mm)[Bus Label],),
        ),
        (
          wave: "0.1.0.1.",
        ),
      ),
    ),
    wave-gutter: 2cm,
    show-ticks: true,
    symbol-width: 1.25cm,
    symbol-height: 8mm,
    tick-overshoot: 3mm,
    stroke: (thickness: 1pt, cap: "square"),
    tick-gutter: 2mm,
    name-gutter: 5mm,
    guide-stroke: (paint: gray, thickness: 0.25pt),
    tick-stroke: (paint: gray, thickness: 0.25pt),
    edge-overshoot: 1mm,
    others: (diagram) => {
      let (tot-width, tot-height, sym-width, sym-height, origins) = diagram.values()

      import cetz.draw: *

      let dotted(..args) = line(..args, stroke: (
        paint: paint.transparentize(40%),
        thickness: 0.5pt,
        dash: (0pt, 1.4pt),
        cap: "square",
      ))

      let t-bar(..args) = line(..args, mark: (symbol: "|", anchor: "center"), stroke: paint.transparentize(40%) + 0.75pt)

      let purparr(..args) = line(
        ..args,
        mark: (symbol: ">", anchor: "center", fill: paint.transparentize(40%), offset: 2mm, stroke: 0pt),
        stroke: paint.transparentize(40%) + 0.75pt,
      )
      
      let grayarr(..args) = line(
        ..args,
        stroke: gray + 0.5pt, mark: (end: (symbol: ">", scale: 0.6, fill: gray))
      )

      let rounded(..args) = rect(
        ..args,
        radius: (rest: (1mm, 1mm)),
        stroke: paint.transparentize(40%) + 0.75pt,
      )
      

      t-bar((tot-width + 0.3, 0), (tot-width + 0.3, sym-height))
      dotted((tot-width, 0), (tot-width + 0.2, 0))
      dotted((tot-width, sym-height), (tot-width + 0.2, sym-height))
      content((tot-width + 0.5, sym-height/2), anchor: "west", tidylink(<-wave.symbol-height>)[`symbol-height`])

      t-bar((tot-width - 1, -0.7), (tot-width, -0.7))
      dotted((tot-width - 1, -5mm), (tot-width - 1, -3mm))
      dotted((tot-width, -5mm), (tot-width, -3mm))
      dotted((tot-width - 1, -7mm), (tot-width - 1, -8mm))
      dotted((tot-width, -7mm), (tot-width, -8mm))
      content((tot-width - 0.5, -1), anchor: "south", tidylink(<-wave.symbol-width>)[`symbol-width`])

      purparr((5, sym-height/2),(5.5, sym-height + 3mm / sym-width),(6, sym-height/2))
      content((5.5, sym-height + 7mm / sym-width), anchor: "south", tidylink(<-wave.mark-scale>)[`mark-scale`])


      t-bar((0, 1.3), (-5mm, 1.3))
      dotted((-5mm, 0.5), (-5mm, 1.2))
      grayarr((-0.9cm, 2.5cm), (-5.5mm, 1.45,))
      content((-0.8cm, 2.5cm), anchor: "south-east", tidylink(<-wave.name-gutter>)[`name-gutter`])

      grayarr((-1.6, 1.1), (-1.6, sym-height - 0.05))
      content((-1.6, 1.1), anchor: "north", tidylink(<-wave.name-format>)[`name-format`])

      t-bar((-2mm, -3mm ), (-2mm, 0))
      dotted((0mm, 0mm), (-1mm, 0mm))
      grayarr((-1.1cm, -5mm), (-3.5mm, -2mm))
      content((-1cm, -4.5mm), anchor: "east", tidylink(<-wave.tick-overshoot>)[`tick-overshoot`])

      t-bar(
        (5mm, -3mm),
        (5mm, -5mm),
      )
      dotted((4mm, -5mm), (0mm, -5mm))
      dotted((4mm, -3mm), (-1mm, -3mm))
      grayarr((5mm, -12mm), (5mm, -6mm))
      content((5mm, -12mm), anchor: "north", tidylink(<-wave.tick-gutter>)[`tick-gutter`])

      rounded(
        (4 - 1mm/sym-width, -4mm),
        (4 + 1mm/sym-width, (4mm/sym-width + tot-height)),
      )
      grayarr((4, 12mm/sym-width + tot-height), (4, 5mm/sym-width + tot-height))
      content((4, 10mm/sym-width + tot-height), anchor: "north", tidylink(<-wave.tick-stroke>)[`tick-stroke`])

      rounded((3 - 2mm / sym-width, -3.5mm),(3 + 2mm / sym-width, -4.5mm - 1em),)
      grayarr((3, -15.5mm), (3, -5.5mm - 1em))
      content((3, -15.5mm), anchor: "south", tidylink(<-wave.tick-format>)[`tick-format`])

      grayarr((2.2, 2.24 + sym-height + 6mm / sym-width), (2.2, 2.24 + sym-height + 1mm / sym-width))
      content((2.2, 2.24 + sym-height + 6mm / sym-width), anchor: "north", tidylink(<-wave.data-format>)[`data-format`])

      t-bar((1, sym-height), (1, (2cm/sym-width) + sym-height))
      content((1.2, (1cm/sym-width) + sym-height), anchor: "west", tidylink(<-wave.wave-gutter>)[`wave-gutter`])

      rounded((12.5mm * 5 + 1mm, -1mm),(12.5mm * 4.5 - 1mm, 1mm),)
      grayarr((4.75, -1.3cm), (4.75, -2mm))
      content((4.75, -1.3cm), anchor: "north", tidylink(<-wave.stroke-dashed>)[`stroke-dashed`])

      line((7.25, sym-height + 7mm / sym-width), (7.25, sym-height), stroke: gray + 0.5pt, mark: (
        end: (symbol: "o", scale: 1, stroke: paint, fill: paint, anchor: "center"),
      ))

      content((7.25, sym-height + 7mm / sym-width), anchor: "north", tidylink(<-wave.stroke>)[`stroke`])

      purparr((5.8, 2.24 + sym-height * 2), (4.9, 2.24 + sym-height/3))
      purparr((6,   2.24 + sym-height * 2),   (5.7, 2.24 + sym-height/3))
      purparr((6.3, 2.24 + sym-height * 2), (6.7, 2.24 + sym-height/3))
      purparr((6.6, 2.24 + sym-height * 2), (7.5, 2.24 + sym-height/3))
      content((6.2, 2.24 + sym-height + 5mm / sym-width), anchor: "north", tidylink(<-wave.bus-colors>)[`bus-colors`])

      grayarr((8.6, -(4mm + 0.5em)), (8.2, -(4mm + 0.5em)))
      content((8.6, -(4mm + 0.5em)), anchor: "west", tidylink(<-wave.show-ticks>)[`show-ticks`])

      t-bar((-1mm, 4.48 + sym-height + 3mm/sym-width), (0, 4.48 + sym-height + 3mm/sym-width))
      dotted((-1mm, 4.48 + sym-height + 2mm/sym-width), (-1mm, 0))
      grayarr((-0.5mm, 4.48 + sym-height + 10mm/sym-width), (-0.5mm, 4.48 + sym-height + 5mm/sym-width))
      content((-0.5mm, 4.48 + sym-height + 10mm/sym-width), anchor: "north", tidylink(<-wave.edge-overshoot>)[`edge-overshoot`])

      t-bar((8.08, 4.48 + sym-height + 3mm/sym-width), (8, 4.48 + sym-height + 3mm/sym-width))
      dotted((8.08, 4.48 + sym-height + 2mm/sym-width), (8.08, 1))
      line((8.04, 4.48 + sym-height + 10mm/sym-width), (8.04, 4.48 + sym-height + 5mm/sym-width), stroke: gray + 0.5pt, mark: (end: (symbol: ">", scale: 0.6, fill: gray)))
      content((8.04, 4.48 + sym-height + 10mm/sym-width), anchor: "north", tidylink(<-wave.edge-overshoot>)[`edge-overshoot`])


      rounded(
        (-1mm / 12.5mm, tot-height - sym-height + 1mm / sym-width),
        (8 + 1mm / 12.5mm, tot-height - sym-height - 1mm / sym-width),
      )

      rounded(
        (-1mm / 12.5mm, tot-height + 1mm / sym-width),
        (8 + 1mm / 12.5mm, tot-height - 1mm / sym-width),
      )

      purparr((-0.15, tot-height), (-0.5, tot-height - sym-height/2), (-0.15, tot-height - sym-height))
      content((-0.6, tot-height - sym-height/2), anchor: "east", tidylink(<-wave.guide-stroke>)[`guide-stroke`])
    },
  )
})


#v(5mm, weak: true)

#align(center, {
  dd.wave(
    (
      signal: (
        (wave: "=|."),
      ),
    ),
    wave-gutter: 2cm,
    symbol-width: 3cm,
    symbol-height: 1.75cm,
    tick-overshoot: 3mm,
    stroke: 1pt,
    step1: 10%,
    step2: 30%,
    step3: 50%,
    bezier-controlpoint: 20%,
    tick-gutter: 2mm,
    s-outside: 3mm,
    s-width: 6mm,
    s-spacing: 1cm,

    name-gutter: 5mm,
    guide-stroke: (paint: gray, thickness: 0.25pt),
    tick-stroke: (paint: gray, thickness: 0.25pt),
    edge-overshoot: 1mm,
    bus-colors: ("2": white.transparentize(100%)),
    others: (diagram) => {
      let (tot-width, tot-height, sym-width, sym-height, origins) = diagram.values()

      import cetz.draw: *

      mark((1.5, sym-height/2), (1.5, 1), "x", anchor: "center", width: 1mm, length: 1mm, stroke: 1pt + red.lighten(20%))
      
      
      T-line((1.5 + 1cm / 3cm / 2, sym-height + 5mm / sym-width), (1.5 - 1cm / 3cm / 2, sym-height + 5mm / sym-width),)
      dashed-line((1.5 + 1cm / 3cm / 2, sym-height + 4mm / sym-width), (1.5 + 1cm / 3cm / 2, sym-height/2),)
      dashed-line((1.5 - 1cm / 3cm / 2, sym-height + 4mm / sym-width), (1.5 - 1cm / 3cm / 2, sym-height/2),)
      line((1.5, sym-height + 11mm / sym-width), (1.5, sym-height + 6mm / sym-width), stroke: gray + 0.5pt, mark: (end: (symbol: ">", scale: 0.6, fill: gray)))
      content((1.5, sym-height + 11mm / sym-width), anchor: "north", tidylink(<-wave.s-spacing>)[`s-spacing`])


      T-line((1.1, sym-height), (1.1, sym-height + 2mm/sym-width),)
      dashed-line((1.13,sym-height + 2mm/sym-width), (1.5 - 1.6 / 6, sym-height + 2mm/sym-width),)
      T-line((1.1, 0), (1.1, -2mm/sym-width),)
      dashed-line((1.13,-2mm/sym-width), (1.5 - 0.3/4, -2mm/sym-width),)
      line((1.1, 0.05), (1.1, sym-height - 0.05), stroke: gray + 0.5pt, mark: (symbol: ">", scale: 0.6, fill: gray))
      content((1, sym-height/2), anchor: "mid", tidylink(<-wave.s-outside>)[`s-outside`])
      

      T-line((1.5 + (1cm - 6mm)/3cm/2 , -5mm), (1.5 + (1cm + 6mm)/3cm/2, -5mm),)
      dashed-line((1.5 + 0.4/6,-4mm), (1.5 + 0.4/6, sym-height + 2mm/sym-width),)
      dashed-line((1.5 + 1.6/6,-2mm), (1.5 + 1.6/6, -4mm),)
      line((1.5 + 1/6, -11mm), (1.5 + 1/6, -6mm), stroke: gray + 0.5pt, mark: (end: (symbol: ">", scale: 0.6, fill: gray)))
      content((1.5 + 1/6 , -11mm), anchor: "south", tidylink(<-wave.s-width>)[`s-width`])
    },
  )
})
#v(5mm, weak: true)
#align(center, {
  dd.wave(
    (
      signal: (
        (wave: "0122z1d"),
      ),
    ),
    wave-gutter: 2cm,
    debug: "steps",
    symbol-width: 2cm,
    symbol-height: 1.75cm,
    tick-overshoot: 3mm,
    stroke: 1pt,
    step1: 10%,
    step2: 30%,
    step3: 50%,
    bezier-controlpoint: 20%,
    tick-gutter: 2mm,

    name-gutter: 5mm,
    guide-stroke: (paint: gray, thickness: 0.25pt),
    tick-stroke: (paint: gray, thickness: 0.25pt),
    edge-overshoot: 1mm,
    bus-colors: ("2": white.transparentize(100%)),
    others: (diagram) => {
      let (tot-width, tot-height, sym-width, sym-height, origins) = diagram.values()

      import cetz.draw: *

      line((4.1, 0), (4.2, sym-height/2), (4.5, sym-height/2), stroke: (thickness: 0.5pt, dash: "densely-dashed", paint: purple))
      line((4.1, sym-height), (4.2, sym-height/2), stroke: (thickness: 0.5pt, dash: "densely-dashed", paint: purple))
      mark((4.2, sym-height/2), (4.2, 2), mark: (symbol: "x", width: 1.5mm, length: 1.5mm, stroke: purple + 1.5pt))

      line((6.1, 0), (6.2, sym-height), (6.5, sym-height), stroke: (thickness: 0.5pt, dash: "densely-dashed", paint: purple))
      mark((6.2, sym-height), (6.2, 2), mark: (symbol: "x", width: 1.5mm, length: 1.5mm, stroke: purple + 1.5pt))

      let red-points = ((1.1, sym-height), (2.1, 0), (3.1, 0), (3.1, sym-height), (4.1, sym-height), (4.1, 0), (5.1, sym-height/2), (6.1, 0))
      let blue-points = ((1.3, 0), (2.3, sym-height), (3.3, 0), (3.3, sym-height))
      let green-points = ((4.5, sym-height/2), (6.5, sym-height))

      red-points
        .map(p => mark(p, (p.first(), 2), mark: (symbol: "x", width: 1.5mm, length: 1.5mm, stroke: red + 1.5pt)))
        .sum()

      blue-points
        .map(p => mark(p, (p.first(), 2), mark: (symbol: "x", width: 1.5mm, length: 1.5mm, stroke: blue + 1.5pt)))
        .sum()

      green-points
        .map(p => mark(p, (p.first(), 2), mark: (symbol: "x", width: 1.5mm, length: 1.5mm, stroke: olive + 1.5pt)))
        .sum()
    },
  )
})


#align(center, [
  #box(cetz.canvas(cetz.draw.mark((4.2, 0.5), (4.2, 2), mark: (
    symbol: "x",
    width: 1.5mm,
    length: 1.5mm,
    stroke: red + 1.5pt,
  )))) $->$ #sym.space.hair #tidylink(<-wave.step1>)[`step1`]#h(2em)
  #box(cetz.canvas(cetz.draw.mark((4.2, 0.5), (4.2, 2), mark: (
    symbol: "x",
    width: 1.5mm,
    length: 1.5mm,
    stroke: olive + 1.5pt,
  )))) $->$ #sym.space.hair #tidylink(<-wave.step2>)[`step2`]#h(2em)
  #box(cetz.canvas(cetz.draw.mark((4.2, 0.5), (4.2, 2), mark: (
    symbol: "x",
    width: 1.5mm,
    length: 1.5mm,
    stroke: blue + 1.5pt,
  )))) $->$ #sym.space.hair #tidylink(<-wave.step3>)[`step3`]#h(2em)
  #box(cetz.canvas(cetz.draw.mark((4.2, 0.5), (4.2, 2), mark: (
    symbol: "x",
    width: 1.5mm,
    length: 1.5mm,
    stroke: purple + 1.5pt,
  )))) $->$ #sym.space.hair #tidylink(<-wave.bezier-controlpoint>)[`bezier-controlpoint`]
])
#v(1cm, weak: true)

/ Note: values assigned to #tidylink(<-wave.step1>, size: 0.9em)[`step1`], #tidylink(<-wave.step2>, size: 0.9em)[`step2`], #tidylink(<-wave.step3>, size: 0.9em)[`step3`] and #tidylink(<-wave.bezier-controlpoint>, size: 0.9em)[`bezier-controlpoint`] are *X*-axis components. The Y-axis components are assigned by the #tidylink(label("-wave()"), `#wave`, size: 0.9em) function. The example above has the values $10%, 30%, 50%, 20%$ respectively.


#[
  #show link: underline.with(offset: 0.15em)
  #show link: set text(blue)
  #set raw(lang: "typc")

  #show ref: it => {
    if str(it.target).starts-with("-wave") {
      tidylink(size: 0.9em, it.target,str(it.target).replace("-wave.",""))
    } else if str(it.target).starts-with("-digidraw-x-pattern") {
      tidylink(size: 0.9em, it.target,str(it.target).replace("-digidraw-x-pattern.",""))
    } else {
      it
    }
  }
  
  

  #import "tidy-style/mystyle.typ"

  #let docs = tidy.parse-module(read("../src/wave.typ"), scope: (dd: dd, tidylink: tidylink.with(size: 0.9em), callout: callout, cetz: cetz))

  #tidy.show-module(docs, style: mystyle, show-outline: false, first-heading-level: 1)

  #let defaults = tidy.parse-module(read("../src/utility/defaults.typ"), scope: (dd: dd, tidylink: tidylink.with(size: 0.9em), callout: callout, cetz: cetz))
  #tidy.show-module(defaults, style: mystyle, show-outline: false, first-heading-level: 1)

]

#pagebreak()


= Tips & Tricks

== Pre-Configuring the `#wave` Function

To preconfigure a function or set a "Global" configuration, you can use the #mylink("https://typst.app/docs/reference/foundations/function/#definitions-with")[`with`]-function to pre-apply parameters.


```vexample
#let my-wave = dd.wave.with(stroke: gradient.linear(..color.map.rainbow))

#my-wave(
  (signal: (
    (wave: "xzz2..0|2.0.2.x",data: ([I'm `my-wave`],[now],[hihi],)),)
  )
)
```


== Making Diagrams Referenceable

To make timing diagrams referencable, enclose it in a `#figure` element. Additionally, to make labelling (`... <a-label>`) work, define a new function or "overload" the `#wave` function:

````vexample
#let wave(..args, caption: none) = figure(
  dd.wave(
    ..args
  ),
  caption: caption,
  supplement: [Diagram],
  kind: "timing-diagrams"
)

#wave(
  (signal: (
    (wave: "x12.udx34z.5.x.",data: "Hello This is Digidraw"),)
  ),
  caption: [Use case of a timing diagram.]
) <dd:example>

//-#set align(left)
When a need to reference the @dd:example occurs, `@dd:example` can be used. And for listing the diagrams, the outline target `figure.where(kind: "timing-diagrams")` is to be used:

```typst
#outline(target: figure.where(kind: "timing-diagrams"))
```
````
#pagebreak()
#show link: set text(blue)
#show link: underline.with(offset: 0.15em)

= Symbol Matrix

The symbol matrix shows all symbol combinations. This is also how the system is debugged (to some degree).
If you find any wrong combinations, please report them at #link("https://codeberg.org/joelvonrotz/typst-digidraw","https://codeberg.org/joelvonrotz/typst-digidraw")!

Due to the sheer size of the table, it’s rather small. So it’s recommended to use a PDF viewer instead of a
printed version. Or checkout the matrix as a standalone document over at #link("https://codeberg.org/joelvonrotz/typst-digidraw/src/tag/" + toml.package.version + "/docs/symbol_matrix.pdf","https://codeberg.org/joelvonrotz/typst-digidraw/src/tag/" + toml.package.version + "/docs/symbol_matrix.pdf"),
#v(1fr)
#scale(115%, image("symbol_matrix.pdf"), origin: top+center)
#v(1fr)
#pagebreak()

#import "@preview/cmarker:0.1.10"
#show heading.where(level: 2): set heading(numbering: none)
#show heading.where(level: 3): set heading(numbering: none)
#show heading.where(level: 3): it => {
  show "Added": [#box(ti-icon("circle-plus", olive,baseline: 0.1em)) #box(it)]
  show "Changed": [#box(ti-icon("circle-dot", orange,baseline: 0.1em)) #box(it)]
  show "Removed": [#box(ti-icon("circle-minus", red,baseline: 0.1em)) #box(it)]
  show "Highlight": [#box(ti-icon("school-bell", blue,baseline: 0.1em)) #box(it)]
  it
}
#show raw: set text(blue)
#cmarker.render(read("../CHANGELOG.md"))


#metadata("last-page") <last-page>
