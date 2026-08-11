#import "@preview/tidy:0.4.3"
#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8"
#import "@preview/tableau-icons:0.336.0": ti-icon

#import "@preview/digidraw:0.9.0" as wave


#show "->": $->$

#import "@preview/chribel:1.2.0": callout
#let callout = callout.with(style: "quarto")

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#show: codly-init

#codly(
  languages: codly-languages,
  number-format: none,
  zebra-fill: gray.lighten(80%),
  display-name: true,
  display-icon: true,
  lang-format: (_, icon, paint) => box(
    height: 1.2em,
    fill: paint.lighten(80%),
    stroke: paint + 0.5pt,
    radius: 0.2em,
    width: 1.2em,
    inset: 1pt,
  )[#icon],
)


/* ------------------------- [CONFIGURATION] ------------------------- */

#let version = "0.9.0"
#let package-name = "Digidraw"

#let header-data = (
  signal: (
    (
      wave: "x2....0|.z1z0.dd",
      data: (
        text(1.2em)[*#package-name* Manual],
      ),
    ),
  ),
)
#let header-data2 = (
  signal: (
    (
      wave: "d2.xx",
      data: (
        text(1.2em)[#version],
      ),
    ),
  ),
)

#let footer-data = (
  signal: (
    (
      wave: "dd2.uu",
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
  wave-height: 1,
  show-guides: false,
  show-tick-lines: false,
  ticks-format: none,
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

#let custom-wave = wave.wave.with(
  size: 6mm,
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
        custom-wave(
          header-data2,
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




#let boxraw(
  ..args,
  fill: gray.lighten(80%),
  stroke: none,
  text-args: arguments(),
) = box(
  fill: fill, inset: (x: 0.2em), outset: (y: 0.2em),
  stroke: stroke,
  radius: 0.2em,
  text(..text-args, raw(..args)),
)

/* --------------------------- [SETTINGS] ---------------------------- */
#set text(font: ("Libertinus Sans", "Noto Color Emoji"))
#set smartquote(quotes: (single: (sym.quote.chevron.single.l, sym.quote.chevron.single.r), double: (sym.quote.chevron.double.l, sym.quote.chevron.double.r)))

#show raw: set text(font: "Fira Code")

#show heading.where(level: 2): it => {
  show raw: set text(1.15em)
  it
}
#show heading.where(level: 3): it => {
  show raw: set text(1.15em)
  it
}


#let example-layout(it, dir: ttb) = {
  let a = it.text.split("\n")
  let code = a.filter(x => x.position(">>>") != 0).join("\n")
  let render = a.map(x => x.replace(">>>","").trim()).join("\n")

  block(inset: (x: 5pt), grid(columns: if dir in (ltr,rtl) { (1fr,1fr)} else {1fr}, column-gutter: 5pt, row-gutter: 5pt,
    block(
      fill: rgb("#c7c7c7"),
      inset: 1pt,
      width: 100%,
      radius: 3pt,

      block(
        radius: 2pt,
        width: 100%,
        fill: white,
        inset: 5pt,
        {
          text(1.2em, raw(block: true, code, lang: "typst"))
        },
      ),
    ),
    block(
      fill: rgb("#e3e4e9"),
      inset: 5pt,
      width: 100%,
      radius: 3pt,

      block(
        width: 100%,
        fill: white,
        inset: 5pt,
        eval(render, mode: "markup", scope: (digidraw: wave))
      ),
    )
  ))
}


#show raw.where(block: true, lang: "vexample"): it => {
  block(inset: (x: 5pt), {    
    set text(font: ("Libertinus Sans", "Noto Color Emoji"))
    example-layout(it);
  })
}

#show raw.where(block: true, lang: "hexample"): it => {
  block(inset: (x: 5pt), {    
    set text(font: ("Libertinus Sans", "Noto Color Emoji"))
    example-layout(it, dir: ltr);
  })
}


#show heading: set text(font: "Open Sauce Two", weight: "bold")


#show heading.where(level: 1): set text(1.5em)
#show heading.where(level: 1): it => {
  block(width: 100%, below: 1em, above: 3em, {
    custom-wave(
      (signal: ((wave: "7.2............7.", data: (none,it,)), )),
      size: 1cm,
      bus-colors: ("7": olive.lighten(80%)),
      show-tick-lines: false,
      ticks-format: none,
      wave-height: 1.25,
      symbol-width: 1,
      stroke: olive + 1pt,
    )
  })
}


#show link: set text(blue)
#show link: emph
#show link: underline.with(offset: 0.15em)

#set par(justify: true)
#set terms(hanging-indent: 1em)



#let custom-wave = custom-wave.with(
  size: 6mm,
  ..{
    let temp = custom-wave-config
    temp.stroke = (black + 0.5pt)
    temp.show-tick-lines = true
    temp.bus-colors = auto
    temp
  },
)

#set table(stroke: 0.5pt)



#set enum(numbering: n => strong(text(blue, font: "Libertinus Sans", numbering("I.", n))))


#let package(content) = text(blue, content)

#let command(content) = text(blue, content)





#show ref: it => {
  let s = str(it.target)

  if s.contains("-wave.") {
    show link: set underline(stroke: 0pt)
    link(it.element.location(), box(
      inset: (left: 0.15em),
      stroke: blue + 0.5pt,
      outset: (y: 0.25em),
      radius: 0.2em,
      command(raw(it.element.body.body.text)) + box(height: 0.5em, ti-icon("arrow-right-dashed", size: 0.9em, baseline: -0.25em)),
    ))
  } else if s.contains("-wave") {
    show link: set underline(stroke: 0pt)
    link(it.element.location(), box(
      inset: (left: 0.15em),
      stroke: blue + 0.5pt,
      outset: (y: 0.25em),
      radius: 0.2em,
      command(raw(it.element.body.text)) + box(height: 0.5em, ti-icon("arrow-right-dashed", size: 0.9em, baseline: -0.25em)),
    ))
  } else if it.element.func() == heading and it.element.numbering == none {
    link(it.element.location(), it.element.body)
   
  } else {
    it
  }
}



/* ---------------------------- [CONTENT] ---------------------------- */

#place(
  top + center,
  scope: "parent",
  float: true,
  {
    v(5em)
    text(3.5em)[
      #wave.wave((signal: ((wave: "x012...u.dx",data: ([*#package-name*],)),)), wave-height: 2, symbol-width: 1.5, size: 1cm, show-tick-lines: false, ticks-format: none, stroke: blue, bus-colors: ( "x": tiling(size: (1.25mm, 1.25mm), box(width: 100%, height: 100%, fill: white, {
      set line(stroke: blue + 0.3pt)
      place(std.line(start: (0%, 100%), end: (100%, 0%)))
      place(std.line(start: (90%, 110%), end: (110%, 90%)))
      place(std.line(start: (-10%, 10%), end: (10%, -10%)))
    })),))
    ]
    v(1em, weak: true)
    v(0.5em, weak: true)
    text(1em)[
      A package for drawing digital timing diagrams
    ]
    v(5em)
  },
)



#package(package-name) is a Typst package to help drawing digital timing diagrams. The syntax tries to be like from #link("https://wavedrom.com/")[WaveDrom]. The package allows for additional styling such as colors and fonts.

The package uses #package("CeTZ") to draw everthing.

#callout(
  type: "caution",
  [Not all symbol combinations have been implemented so far (probably), so expect some undefined or unexpected behaviour.

  Please report them in the package repository:\ #link("https://codeberg.org/joelvonrotz/typst-#package-name/")],
)

#show outline.entry.where(level: 1): it => {
  show: strong
  it
}

#heading(level: 1, outlined: false, [Contents])
#block(width: 100%, columns(2)[
  #outline(title: none)
])

#pagebreak()

= Quickstart

== From Universe (aka. Stable Version)

To import the Universe version, insert following snippet

#raw(block: true, "#import \"@preview/" + lower(package-name) + ":" + version + "\"", lang: "typ")


== From Repository (aka. Development Version)

The repository will always be the #emph[development] version of #package[#package-name]. This will also include the latest changes, but might break here and there.

1. Clone the Repository into your project (for example into a `./packages/` folder or at root level).

  #raw(
    block: true,
    "cd /path/to/project/\ngit clone https://codeberg.org/joelvonrotz/typst-" + lower(package-name) + ".git",
    lang: "bash",
  )


  *OR* if your project is a git project, you can add it as a submodule, saving a little bit of space in your repository:

  #raw(
    block: true,
    "cd /path/to/project/\ngit submodule add https://codeberg.org/joelvonrotz/typst-" + lower(package-name) + ".git",
    lang: "bash",
  )

2. Include the package into your document
  #raw(
    block: true,
    "#import \"./path/to/typst-" + lower(package-name) + "/lib.typ\" as " + lower(package-name),
    lang: "typ",
  )

= Usage

== Drawing Diagrams

Drawing a diagram is easy: 

```vexample
#digidraw.wave(
  (signal: (
    (wave: "x12.udx34z.5.x",data: "Hello This is Digidraw"),)
  )
)
```

#pagebreak()

You can turn on Debug mode by setting #box(stroke: gray + 0.5pt, outset: (y: 2pt), radius: 2pt, inset:(x: 2pt), raw(`debug : true`.text, lang: "typc")). This shows where and which symbol is placed. Additionally, it shows the exact placement of bus labels: #box(fill: olive.lighten(80%), outset: (y: 2pt), radius: 2pt, inset:(x: 2pt), [start reference #ti-icon("triangle-filled", size: 0.8em, fill: olive)], baseline: 0.1em) and #box(fill: red.lighten(80%), outset: (y: 2pt), radius: 2pt, inset:(x: 2pt),[end reference #ti-icon("triangle-inverted-filled", size: 0.8em, fill: red)], baseline: 0.1em) and inbetween the #box(fill: orange.lighten(80%), outset: (y: 2pt), radius: 2pt, inset:(x: 2pt),[label position #ti-icon("circle-filled", size: 0.8em, fill: orange)], baseline: 0.1em) are shown.


```vexample
#digidraw.wave(
  (signal: (
    (wave: "x12.udx34z.5.x",data: "Hello This is Digidraw"),)
  ),
  debug: true
)
```

Check out the chapters @sec:symbols and @sec:apireference for more.

== Data Structure

Let's talk about wave data structures! The data syntax is the one from #link("https://wavedrom.com/")[WaveDrom]. You can copy WaveDrom scripts and insert those into your document. Well, almost... You have to format it according to the JSON standard!

There's two ways on how to define the wave data: as dictionaries or as JSON structures.

=== Dictionaries

This allows for fancier styling labels. `.wave` and `.data` can contain #boxraw("content", stroke: blue.lighten(50%) + 0.5pt, fill: none). _Raw_'em, _Strong_'em, _Emph_'em, do what you want, as long as it turns into a `content`!

```vexample
#let data = (signal: (
  (wave: "0u3..0..1..2..", name: `Hello`, data: (text(1.5em,`World`),)),
  (wave: "012.3..45..u.1", name: "Hello", data: ($A$, [_B_], [*C*], `D`)),
  (wave: "0..1.....0.d.0"),
))
#digidraw.wave(data)
```

#colbreak()

=== JSON

Easier when copying from WaveDrom with the downside of not having much styling options.

```json
{"signal": [
  {"wave": "0u3..0..1..2..", "name": "Hello", "data": ["World"]},
  {"wave": "012.3..45..u.1", "name": "Hello", "data": "A B C"},
  {"wave": "0..1.....0.d.0"}
  // more waves
]}
```

```vexample
#let data = json(bytes(`{"signal": [
  {"wave": "0u3..0..1..2..", "name": "Hello", "data": ["World"]},
  {"wave": "012.3..45..u.1", "name": "Hello", "data": "A B C D"},
  {"wave": "0..1.....0.d.0"}
]}`.text)) // or json(read("file.json"))
#digidraw.wave(data)
```



/ `.signal`: #boxraw("array", stroke: orange.lighten(50%) + 0.5pt, fill: none) of #boxraw("dictionary", stroke: purple.lighten(50%) + 0.5pt, fill: none)\ A list/array containing the wave objects.


/ `.wave`: #boxraw("string", stroke: olive.lighten(50%) + 0.5pt, fill: none)\ The wave's contents built using the @sec:symbols.\ #underline[Example]: #raw(lang: "typc", `"10..u.10"`.text)

/ `.name`: #boxraw("string", stroke: olive.lighten(50%) + 0.5pt, fill: none) #text(0.6em,[or]) #boxraw("content", stroke: blue.lighten(50%) + 0.5pt, fill: none)\
  The name of the wave.\ #underline[Example]: #raw(lang: "typc", `"Mike"`.text)

/ `.data`: #math.underparen(boxraw("string", stroke: olive.lighten(50%) + 0.5pt, fill: none),[JSON, Typst]) #text(0.6em,[or]) #math.underparen([#boxraw("array", stroke: orange.lighten(50%) + 0.5pt, fill: none) of #boxraw("content", stroke: red.lighten(50%) + 0.5pt, fill: none)],[Typst]) #text(0.6em,[or]) #math.underparen([#boxraw("array", stroke: orange.lighten(50%) + 0.5pt, fill: none) of #boxraw("string", stroke: olive.lighten(50%) + 0.5pt, fill: none)],[JSON, Typst])\
  When buses are defined in the wave, labels can be inserted. The index of the label defines its position: first entry goes into the first bus, second in the second one, etc. If #raw("data") is a string, labels are split by spaces.\ #raw(`"Hello World"`.text, lang: "typc") is equal to  #raw(`("Hello", "World")`.text, lang: "typc")


#callout(width: 80%, type: "important", [
  Everything else from the WaveDrom syntax either hasn't been implemented yet or will not see the light of day. Help is very much appreciated or check out the README todo list!
])



= Configuration <sec:configuration>

#package("Digidraw") offers a lot of configurations through a configuration dictionary. For options and their effects, see Section @sec:apireference.

#let a = str(type(1)) == "integer"



== Global Configurations

Global configurations are done via #command(`#wave.with()`) and placed after the import statement.\ 
#text(0.6em)[Well you can say this isn't really how "global" should be. This was done, so I didn't have to use any `state` components!]

```typst
#let wave = digidraw.wave.with(
  wave-height: 2,
  symbol-width: 3,
  /* ... */
)
```

#callout(width: 80%, title: [Using in Multi-document project],[
  Usually in multi document projects, you probably have a _preamble_ file containing global imports. In there you define the global configuration.
])

== Local Configurations

Local configurations are done in the #command(`#wave`)-function.

```typst
#digidraw.wave(
  wave-height: 2,
  symbol-width: 3,
  /* ... */
  
  (signal: /* ... */)
)
```

== Reseting Configurations

Configurations can be reset to their default value by passing #text(red, `auto`) to the respective parameter.

```typst
#let wave = digidraw.wave.with(
  wave-height: 2,
)
/* ... */
#let wave = wave.with(
  wave-height: auto
)
```

#colbreak()

= Symbols <sec:symbols>

#table(
  columns: (auto, 1fr),
  table.header([*Type*], [*Symbols*]),
  [@sec:clocks], [#boxraw("p") #boxraw("P") #boxraw("n") #boxraw("N")],
  [@sec:buses],
  [#boxraw("x") #boxraw("=") #boxraw("2") #boxraw("3") #boxraw("4") #boxraw("5") #boxraw("6") #boxraw("7") #boxraw(
      "8",
    ) #boxraw("9")],

  [@sec:wires],
  [#boxraw("l") #boxraw("L") #boxraw("h") #boxraw("H") #boxraw("0") #boxraw("1") #boxraw("z") #boxraw("u") #boxraw(
      "d",
    )],

  link(<sec:extender>)[Extender], [#boxraw(".")],
  link(<sec:timeskip>)[Time Skip], [#boxraw("|")],
  link(<sec:invalidsym>)[Invalid Symbols], [#boxraw("/") and everything else],
)

== Clocks <sec:clocks>

=== Normal Clock #boxraw("p") #boxraw("P")

Capitalizing the letters adds an arrow mark to the line pointing up.


```hexample
#digidraw.wave(
  (signal: ((wave: "pppPPP",),)),
  debug: true
)
```

=== Inverted Clock #boxraw("n") #boxraw("N")

Capitalizing the letters adds an arrow mark to the line pointing down.

```hexample
#digidraw.wave(
  (signal: ((wave: "nnnNNN",),)),
  debug: true
)
```

== Wires <sec:wires>

=== Straight Signals #boxraw("l") #boxraw("L") #boxraw("h") #boxraw("H")

Capitalizing the letters adds an arrow mark to the line pointing down.

```hexample
#digidraw.wave(
  (signal: ((wave: "lhLHlLh",),)),
  debug: true
)
```

=== Flanked Signals #boxraw("0") #boxraw("1")

Using `0` and `1` instead of `l/L` and `h/H` inserts flanked/sloped signals.


```hexample
#digidraw.wave(
  (signal: (
    (wave: "x01010x",),
    (wave: "x0..1..",),
    (wave: "000111x",),
  )),
  debug: true
)
```

=== High-Impedance Signal #boxraw("z")

The high impedance signal introduces curved transitions from any signal to high impedance.

/ Note: that multiples of the symbols are combined\ #underline[Example]: #raw(`"zzz2.zz"`.text, lang: "typc") $->$ #raw(`"z..2.z."`.text, lang: "typc")

```hexample
#digidraw.wave(
  (signal: (
    (wave: "xz0z1z.",),
    (wave: "zzz2.zz",)
  )),
  debug: true
)
```


=== Transition Edges #boxraw("u") #boxraw("d")


If the transition has of unknown duration/delay, a transition edge can be used.

/ Note: that multiples of the symbols are combined\ #underline[Example]: #raw(`"uuuddduuu"`.text, lang: "typc") $->$ #raw(`"u..d..u.."`.text, lang: "typc")

```hexample
#digidraw.wave(
  (signal: (
    (wave: "du.xd2u",),
    (wave: "0uuuddd",),
  )),
  debug: true
)
```


#pagebreak()
== Buses <sec:buses>


Buses are grouped into two groups: _don't care_ and data buses.

=== Don't Care #boxraw("x")

Indicates a section, where the signal value is not important, aka. _don't care_.


/ Note: that multiples of the symbols are combined\ #underline[Example]: #raw(`"xxx|xxx20"`.text, lang: "typc") $->$ #raw(`"x..|...20"`.text, lang: "typc")


```hexample
#let data = (signal: (
  (wave: "x0x1x|x."),
  (wave: "xxx|xx20"),
),)

#digidraw.wave(data, symbol-width: 1.1, debug: true)
```

=== Simple Bus #boxraw("=") #boxraw("2")

`=` and `2` are both the same and respectively handled that way (`=` gets turned into `2`).

```hexample
#let data = (signal: (
  (wave: "20212|2."),
  (wave: "=0=1=|=."),
),)

#digidraw.wave(data, symbol-width: 1.1, debug: true)
```

=== Coloured Buses #boxraw("3") #boxraw("4") #boxraw("5") #boxraw("6") #boxraw("7") #boxraw("8") #boxraw("9")

The databus can be also colored using numbers `"3"` through `"9"`.

#let data = "#let data = (signal: (
  " + ("3","4","5","6","7","8","9",).map(x => "(wave: \"" + x + "0" + x + "1" + x + "|" + x + ".\", data: (`" + x + "`,)),").join("\n  ") + "
),)

#digidraw.wave(data, symbol-width: 1.1, wave-gutter: 0.4)
"

#raw(block: true, lang: "hexample", data)

#pagebreak()
== Extender #boxraw(".") <sec:extender>

The extender can be used to extend signals. If a signal doesn't look right, you might have to replace some of the symbols with the extender. And if that doesn't work, report it!

For example, while a `"1111"` inserts high signals with impulses, `"1..."` stretches.

/ Note: Some signals are automatically modified with extenders, such as `"zzz"` $->$ `"z.."`

```hexample
#let data = (signal: (
  (wave: "11111..."),
  (wave: "00000..."),
))

#digidraw.wave(data, symbol-width: 1.1, debug: true)
```

== Time Skip #boxraw("|") <sec:timeskip>

To insert a timeskip to indicate the passing of a long time, insert the symbol #strong(boxraw("|")).

```hexample
#let data = (signal: (
  (wave: "z|u|d|.1"),
  (wave: "z|d|d|.1"),
),)

#digidraw.wave(data, symbol-width: 1.1, debug: true)
```


== Invalid Symbols #boxraw("/") <sec:invalidsym>

Any other symbol will result in the #boxraw("/") symbol. This indicates a default or invalid character. 

```hexample
#let data = (signal: (
  (wave: "abcdefghi"),
),)

#digidraw.wave(data, symbol-width: 1, debug: true)
```

#colbreak()
= API Reference <sec:apireference>

#tidy.show-module(
  tidy.parse-module(
    read("../src/wave.typ"),
    scope: (wave: wave.wave, boxraw: boxraw,),
  ),
  style: tidy.styles.default,
  show-module-name: false,
  show-outline: false,
  first-heading-level: 1,
)

#metadata("last-page") <last-page>



