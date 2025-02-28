#import "@preview/mantys:1.0.1": *
#import "@preview/cetz:0.3.2"
#import "./cetz-timing.typ": texttiming, timingtable, wave, parse-sequence

#let package = toml("typst.toml").package

#show: mantys(
  ..toml("typst.toml"),
  date: datetime.today(),
  subtitle: package.description,
)

#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { center }
    else { left }
  )
)

= Introduction

This package uses CeTZ to produce timing diagrams inside text./* */

It is a port of `tikz-timing` by Martin Scharrer to Typst.

The signal levels of the timing diagram can be given by corresponding characters/letters like '`H`' for _Logical High_
or '`L`' for _Logical Low_. So e.g. '`HLZXD`' gives '#texttiming("HLZXD")'. In order to fit (in)to normal text size the diagram size (i.e. its height, width and line width) is defined relatively to the size of the character 'A' in the current context.

This way the diagram can also be scaled width the font size. (Example: #text(size: 8pt, [Hello #texttiming("HLZXD")]), #text(size: 14pt, [Hello #texttiming("HLZXD")])).
A single timing character produces a diagram width a width identical to its height ('`H`' $->$ '#texttiming("H")'). Longer diagrams can be produced by either using the same character multiple times ('`HHH`' $->$ '#texttiming("HHH")') or writing the width as number in front of the character ('`3H`' $->$ '#texttiming("3H")')/* */.
Recurring character combinations can be repeated using character groups ('`3{HLZ}`' $->$ '#texttiming("3{HLZ}")') /* */. Character groups can be nested arbitrarily ('`2{H3{ZL}}`' $->$ #texttiming("2{H3{ZL}}")).

= Usage

== Timing Characters

The logic levels are described by so called timing characters. Actually all of them are letters, but the general term character
is used here. @timing-chars shows all by default defined logic characters and @timing-transitions all possible two-character transitions.

#figure(
  table(
    columns: 4,
    table.header(
      [Character], [Description], [Diagram], [Transition Example]
    ),
    [`H`], 
    [High], 
    [#texttiming("H", draw-grid: true)], 
    [#texttiming("H", initchar: "L", draw-grid: true)],
    [`L`], 
    [Low], 
    [#texttiming("L", draw-grid: true)],
    [#texttiming("L", initchar: "H", draw-grid: true)],
    [`Z`], 
    [High impedance], 
    [#texttiming("Z", draw-grid: true)], 
    [#texttiming("Z", initchar: "L", draw-grid: true)],
    [`X`], 
    [Don't care], 
    [#texttiming("X", draw-grid: true)], 
    [#texttiming("X", initchar: "L", draw-grid: true)],
    [`D`], 
    [Data], 
    [#texttiming("D", draw-grid: true)], 
    [#texttiming("D", initchar: "D", draw-grid: true)],
    [`U`], 
    [Unknown data], 
    [#texttiming("U", draw-grid: true)], 
    [#texttiming("U", initchar: "D", draw-grid: true)],
    [`T`], [Toggle],
    [#texttiming("L", draw-grid: true) or #texttiming("H", draw-grid: true) ], 
    [#texttiming("TTTT", draw-grid: true)],
    [`C`], [Clock], 
    [#texttiming("L", draw-grid: true) or #texttiming("H", draw-grid: true) ], 
    [#texttiming("CCCC", draw-grid: true)],
    [`M`], [Metastable condition], [#texttiming("M", draw-grid: true)], [#texttiming("M", initchar: "D", draw-grid: true)],
    [`G`], [Glitch], [-], [-],
    [`S`], [Space], [-], [-],
  ),
  caption: [Timing Characters]
) <timing-chars>

#figure(
  table(
    columns: 10,
    table.header(
      [From], [H], [L], [Z], [X], [M], [D], [U], [T], [C]
    ),
    [H],
    [#texttiming("HH", draw-grid: true)],
    [#texttiming("HL", draw-grid: true)],
    [#texttiming("HZ", draw-grid: true)],
    [#texttiming("HX", draw-grid: true)],
    [#texttiming("HM", draw-grid: true)],
    [#texttiming("HD", draw-grid: true)],
    [#texttiming("HU", draw-grid: true)],
    [#texttiming("HT", draw-grid: true)],
    [#texttiming("HC", draw-grid: true)],
    [L],
    [#texttiming("LH", draw-grid: true)],
    [#texttiming("LH", draw-grid: true)],
    [#texttiming("LZ", draw-grid: true)],
    [#texttiming("LX", draw-grid: true)],
    [#texttiming("LM", draw-grid: true)],
    [#texttiming("LD", draw-grid: true)],
    [#texttiming("LU", draw-grid: true)],
    [#texttiming("LT", draw-grid: true)],
    [#texttiming("LC", draw-grid: true)],
    [Z], 
    [#texttiming("ZH", draw-grid: true)],
    [#texttiming("ZH", draw-grid: true)],
    [#texttiming("ZZ", draw-grid: true)],
    [#texttiming("ZX", draw-grid: true)],
    [#texttiming("ZM", draw-grid: true)],
    [#texttiming("ZD", draw-grid: true)],
    [#texttiming("ZU", draw-grid: true)],
    [#texttiming("ZT", draw-grid: true)],
    [#texttiming("ZC", draw-grid: true)],
    [X], 
    [#texttiming("XH", draw-grid: true)],
    [#texttiming("XH", draw-grid: true)],
    [#texttiming("XZ", draw-grid: true)],
    [#texttiming("XX", draw-grid: true)],
    [#texttiming("XM", draw-grid: true)],
    [#texttiming("XD", draw-grid: true)],
    [#texttiming("XU", draw-grid: true)],
    [#texttiming("XT", draw-grid: true)],
    [#texttiming("XC", draw-grid: true)],
    [M], 
    [#texttiming("MH", draw-grid: true)],
    [#texttiming("MH", draw-grid: true)],
    [#texttiming("MZ", draw-grid: true)],
    [#texttiming("MX", draw-grid: true)],
    [#texttiming("MM", draw-grid: true)],
    [#texttiming("MD", draw-grid: true)],
    [#texttiming("MU", draw-grid: true)],
    [#texttiming("MT", draw-grid: true)],
    [#texttiming("MC", draw-grid: true)],
    [D], 
    [#texttiming("DH", draw-grid: true)],
    [#texttiming("DH", draw-grid: true)],
    [#texttiming("DZ", draw-grid: true)],
    [#texttiming("DX", draw-grid: true)],
    [#texttiming("DM", draw-grid: true)],
    [#texttiming("DD", draw-grid: true)],
    [#texttiming("DU", draw-grid: true)],
    [#texttiming("DT", draw-grid: true)],
    [#texttiming("DC", draw-grid: true)],
    [U], 
    [#texttiming("UH", draw-grid: true)],
    [#texttiming("UH", draw-grid: true)],
    [#texttiming("UZ", draw-grid: true)],
    [#texttiming("UX", draw-grid: true)],
    [#texttiming("UM", draw-grid: true)],
    [#texttiming("UD", draw-grid: true)],
    [#texttiming("UU", draw-grid: true)],
    [#texttiming("UT", draw-grid: true)],
    [#texttiming("UC", draw-grid: true)],
    [T], 
    [#texttiming("TH", draw-grid: true)],
    [#texttiming("TH", draw-grid: true)],
    [#texttiming("TZ", draw-grid: true)],
    [#texttiming("TX", draw-grid: true)],
    [#texttiming("TM", draw-grid: true)],
    [#texttiming("TD", draw-grid: true)],
    [#texttiming("TU", draw-grid: true)],
    [#texttiming("TT", draw-grid: true)],
    [#texttiming("TC", draw-grid: true)],
    [C],
    [#texttiming("CH", draw-grid: true)],
    [#texttiming("CH", draw-grid: true)],
    [#texttiming("CZ", draw-grid: true)],
    [#texttiming("CX", draw-grid: true)],
    [#texttiming("CM", draw-grid: true)],
    [#texttiming("CD", draw-grid: true)],
    [#texttiming("CU", draw-grid: true)],
    [#texttiming("CT", draw-grid: true)],
    [#texttiming("CC", draw-grid: true)],
  ),
  caption: [Overview over all transitions]
) <timing-transitions>

#figure(
  table(
    columns: 2,
    table.header(
      [Modifier Syntax], [Description]
    ),
    [`D|D`], [Produces an explicit transition. By default, repeating signals don't have a transition. _E.g.:_ '`3D|D`' $->$ #texttiming("3D|D", draw-grid: true), '`L|LLL`' $->$ #texttiming("L|LLL", draw-grid: true)]
  ),
  caption: [Modifiers for Timing Characters]
) <timing-modifier>

== Timing Diagram Table

Using the `timingtable` command, a timing diagram with several logic lines can be drawn to a CeTZ canvas.

The used layout is shown in @timing-layout.

#figure(
  {
    set text(30pt) 
  context {
    let transition-width = 0.4
    let xunit = 2.0
    let amplitude = 2.0
    let cetz-length = measure("X").width / xunit
  cetz.canvas(length: cetz-length, {
    import cetz.draw: * 

    let spec0 = "4{HL}"
    let (parsed0, num-ticks) = parse-sequence(spec0)

    let spec1 = "8C"
    let (parsed1, _) = parse-sequence(spec1)

    let col-dist-pt = 1.4 * cetz-length
    let row-dist-pt = calc.max(text.size, cetz-length) * 1.4
    line((0, -3), (0, 6), stroke: (dash: "dashed", paint: gray))
    line((xunit, -3), (xunit, 6), stroke: (dash: "dashed", paint: gray))
    line((-col-dist-pt, -3), (-col-dist-pt, (6)), stroke: (dash: "dashed", paint: gray))

    let xend = num-ticks * xunit + 1

    line((0, amplitude / 2.0), (xend, amplitude / 2.0), stroke: (dash: "dashed", paint: gray))
    line((0, 0), (xend, 0), stroke: (dash: "dashed", paint: gray))
    line((0, -amplitude / 2.0), (xend, -amplitude / 2.0), stroke: (dash: "dashed", paint: gray))

    line((0, -row-dist-pt), (xend, -row-dist-pt), stroke: (dash: "dashed", paint: gray))

    line((3 * xunit, -3), (3 * xunit, (6)), stroke: (dash: "dashed", paint: gray))
    line((3 * xunit + transition-width, -3), (3 * xunit + transition-width, (6)), stroke: (dash: "dashed", paint: gray))

    circle((0, 0),
      radius: (0.1), 
      name: "origin", 
      fill: black
      )

    content("origin",
      anchor: "north-west", 
      padding: .1, 
      [#text(size: 8pt, [origin])]
      )

    content((-col-dist-pt, 0), anchor: "mid-east", "First Row")
    wave(
      initchar: "L",
      xunit: xunit,
      amplitude: amplitude,
      spec0
      )

    content((-col-dist-pt, -row-dist-pt), anchor: "mid-east", "Second Row")
    wave(
      initchar: "L",
      origin: (x: 0, y: -row-dist-pt / cetz-length), 
      xunit: xunit,
      amplitude: amplitude,
      spec1
      )
    set-style(mark: (symbol: ">", scale: 0.5, fill: black))
    line((0, 5), (xunit, 5), name: "xunit")
    content("xunit.mid", angle: 90deg, anchor: "west", padding: .4, [#text(size: 8pt, [xunit])])

    line((-col-dist-pt, 5), (0, 5), name: "coldist")
    content("coldist.mid", angle: 90deg, anchor: "west", padding: .4, [#text(size: 8pt, [col-dist])])

    line((xend, -amplitude / 2.0), (xend, amplitude / 2.0), name: "amplitude")
    content("amplitude.mid", anchor: "west", padding: .4, [#text(size: 8pt, [amplitude])])


    line((num-ticks + xunit / 2.0, 0), (num-ticks + xunit / 2.0, -row-dist-pt), name: "rowdist")
    content("rowdist.mid", anchor: "west", padding: .4, [#text(size: 8pt, [row-dist])])

    line((3 * xunit, 5), (3 * xunit + transition-width, 5), name: "trans")
    content("trans.mid", anchor: "west", padding: .4, [#text(size: 8pt, [transition-width])])
  })

  }},
  caption: [Distances inside a `timingtable`]
) <timing-layout>

= Available Commands

#command("texttiming", arg(strok:black + 1pt), arg(initchar:none), arg(draw-grid:false), arg(sequence:str))[
  This macro places a single timing diagram line into the current text. The signal have the same height has an uppercase letter (like 'X') of the current font, i.e. they scale with the font size. The macro argument must contain only valid logic characters and modifiers which define the logical levels of the diagram line.

  #argument("strok", types:"stroke", default: black + 1pt)[
    Stroke of the diagram line. This does not affect `X`, `Z`, and `M` logic levels.
    
    Note: I couldn't manage to get `stroke` to work, so it is named `strok` for now.

    *Examples*

    `#texttiming(strok: orange + 1pt, "HLZXDUTCM")` $->$ #texttiming(strok: orange + 1pt, "HLZXDUTCM")

    `#texttiming(strok: blue + 1pt, "HLZXDUTCM")` $->$ #texttiming(strok: blue + 1pt, "HLZXDUTCM")
  ]
  #argument("initchar", types:"str", default: none)[
    Initial logical level. This is used to draw a transition right at the beginning. It must be `none` or one of the logic levels.

    *Examples*

    `#texttiming(initchar: "L", "Z")` $->$ #texttiming(initchar: "L", "Z")

    `#texttiming(initchar: "H", "Z")` $->$ #texttiming(initchar: "H", "Z")
  ]
  #argument("draw-grid", types:"bool", default: false)[
    Draw a gray grid on the CeTZ canvas background.

    *Examples*

    `#texttiming(draw-grid: true, "HLZXDUTCM")` $->$ #texttiming(draw-grid: true, "HLZXDUTCM")
  ]
  #argument("sequence", types: "str")[
    The timing sequence to visualize.
  ]
]

#command("timingtable", arg(col-dist:10pt), arg(row-dist:auto), arg(xunit:2.0), arg(amplitude:2.0), arg(draw-grid:false), sarg[body])[
  This macro draws a timing diagram table to a CeTZ canvas.

  #argument("col-dist", types:"length", default: 10pt)[
    The distance between columns.

    *Example*

    #grid(
     columns: (40%, 40%), 
     [

        *20 pt*
        ```typst
        #timingtable(col-dist: 20pt, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(col-dist: 20pt, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ], 
     [
        *40 pt*
        ```typst
        #timingtable(col-dist: 40pt, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(col-dist: 40pt, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ]
    )
  ]
  #argument("row-dist", types: "length", default: auto)[
    The distance between rows.
    
    *Example*

    #grid(
     columns: (40%, 40%), 
     [

        *10 pt*
        ```typst
        #timingtable(row-dist: 10pt, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(row-dist: 10pt, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ], 
     [
        *40 pt*
        ```typst
        #timingtable(row-dist: 40pt, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(row-dist: 40pt, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ]
    )
  ]

  #argument("xunit", types: "float", default: 2.0)[
    Number of CeTZ units per timing character.

    *Example*

    #grid(
     columns: (40%, 40%), 
     [

        *1.0*
        ```typst
        #timingtable(xunit: 1.0, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(xunit: 1.0, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ], 
     [
        *3.2*
        ```typst
        #timingtable(xunit: 4.2, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(xunit: 4.2, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ]
    )
  ]

  #argument("amplitude", types: "float", default:2.0)[
    Signal aplitude (peak-to-peak) in CeTZ units.

    The row distance is automatically adjusted.

    *Example*

    #grid(
     columns: (40%, 40%), 
     [

        *1.0*
        ```typst
        #timingtable(amplitude: 1.0, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(amplitude: 1.0, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ], 
     [
        *3.2*
        ```typst
        #timingtable(amplitude: 4.2, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(amplitude: 4.2, show-grid: true,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ]
    )
  ]

  #argument("body", is-sink: true)[
    Signal names and character sequences that describe the timing diagram.
  ]
]

#command("wave", arg(origin: (x: 0, y: 0)), arg(initchar:none), arg(stroke:1pt + black), arg(xunit:2.0), arg(amplitude:2.0), arg[sequence])[
  Draw wave specified by character sequence in cetz.canvas context.

  *Example*

  ```typst
  #cetz.canvas({
    import cetz.draw: *
    import cetz-timing: wave

    grid((0, 1), (10, -3), stroke: gray)

    circle((0, 0), radius: 0.1, fill: black, name: "origin")
    content("origin", anchor: "east", padding: .3, [signal 0, origin])
    wave("XHHLX") 

    circle((0, -2), radius: 0.1, fill: black, name: "sig1")
    content("sig1", anchor: "east", padding: .3, [signal 1])
    wave(origin: (x: 0, y: -2), "UD|DUU") 

    for i in range(6) {
      content((i * 2, -3.2), [#i])
    }
  })
  ```

  #cetz.canvas({
    import cetz.draw: *

    grid((0, 1), (10, -3), stroke: gray)

    circle((0, 0), radius: 0.1, fill: black, name: "origin")
    content("origin", anchor: "east", padding: .3, [signal 0, origin])
    wave("XHHLX") 

    circle((0, -2), radius: 0.1, fill: black, name: "sig1")
    content("sig1", anchor: "east", padding: .3, [signal 1])
    wave(origin: (x: 0, y: -2), "UD|DUU") 

    for i in range(6) {
      content((i * 2, -3.2), [#i])
    }
  })

  #argument("origin", types:"dict", default: (x: 0, y: 0))[
    A dictionary that specifies the origin position on the CeTZ canvas. 
  ]

  #argument("initchar", types:"str", default: none)[
    Initial logical level. This is used to draw a transition right at the beginning. It must be `none` or one of the logic levels.
  ]

  #argument("stroke", types:"stroke", default: 1pt + black)[
    Stroke of the wave.
  ]

  #argument("xunit", types:"float", default: 2.0)[
    Size of one character in the sequence in CeTZ coordinate space.
  ]

  #argument("amplitude", types:"float", default: 2.0)[
    Size of the peak-to-peak amplitude in CeTZ coordinate space.
  ]
  #argument("sequence", types:"str")[
    The character sequence to visualize.
  ]
]

= TODO

- Add data labels: `D[MISO]`. `content` in braces.
- Add CeTZ anchors for diagram.
- Add optional CeTZ anchors for individual signals: `D<miso>`, `D<miso>[MISO]`.
- Make anchors available so users can do custom arrows and annotations -> leave drawing CeTZ `canvas` to the user?
- Apply color to `U` pattern.
- Add option to omit first column of timing table.
- [_Optional_] Add caption to timing table.
- [_Optional_] Add table header to timing table.
- [_Optional_] Add tick marks.
- [_Optional_] Add grouping of table rows.
- [_Optional_] Add highlighting of row groups and ticks.
- [_Optional_] Correct `strok` argument.
- [_Optional_] Resolve `mantys` warnings.
- [_Optional_] Allow non-integer lengths for logic levels.

= Examples

I am an inline timing diagram: '#texttiming("HL3{CX}2Z")'.

I am a basic timing diagram with multiple rows:

#timingtable(
  [Clock], [6{C}],
  [Chip Select], [H4LH],
  [Data], [U4DU],
)