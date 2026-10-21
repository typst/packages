#import "@preview/cetz:0.5.2"

#import "./utility/utility.typ"
#import "./utility/defaults.typ": __digidraw-default-config, digidraw-x-pattern
#import "utility/symbols.typ"


/// The one and only
#let wave(///
  /// The wave data à la WaveDrom syntax.
  /// 
  /// #example(
  ///   `#let data = (signal: (
  ///  (wave: "3.0u7.", name: "A", data: "Hello World"),
  ///  (wave: "d5.04.", name: "B", data: ([Another],[World],)),
  ///))
  ///
  ///#dd.wave(data)`)
  ///
  /// -> dictionary
  data,

  /// Passing one (as a string) or more (as an array) of `"symbols"`, `"steps"`, `"coordinates"` and `"labels"`, displays the respective debugging information. Passing `true` enables all informations at once (*not recommended*). `false` disables it.
  /// 
  /// / `"symbols"`: Displays where each symbol is located and their length
  /// 
  /// / `"steps"`: Displays @-wave.step1, @-wave.step2 and @-wave.step3 via vertical lines (as these parameters are applied to every symbol)
  /// / `"coordinates"`: Shows coordinates (in `cetz` units), which comes in handy when placing elements via @-wave.others into the diagram.
  /// / `"labels"`: Renders a bounding box and a center point of where a bus label/data can be placed. Using `align(..)` defines the location (see default of @-wave.data-format on how it is used)
  ///  
  /// #example(`#dd.wave(debug: "symbols",
  ///  (signal: ((wave: "1.30..1"),)))
  /// 
  ///#dd.wave(debug: "steps",
  ///  (signal: ((wave: "1.30..1"),)))
  /// 
  ///#dd.wave(debug: "coordinates",
  ///  (signal: ((wave: "1.30..1"),)))
  /// 
  ///#dd.wave(debug: ("labels", "symbols"),
  ///  (signal: ((wave: "1.30..1"),)))
  /// 
  ///// not recommended:
  ///#dd.wave(debug: true,
  ///  (signal: ((wave: "1.30..1"),)))
  ///  
  ///`)
  /// 
  /// 
  /// -> string | array | bool
  debug: false,

  /// The width of #underline[one] symbol and also the reference size of the diagram. All other length-based parameters are scaled to `cetz` units using this parameter ($l_"relative" = l_"absolute"\/mono("symbol-width")$)
  ///
  /// #example(
  ///   `#let data = (signal: ((wave: "10|2"),))
  /// 
  ///*symbol-width: 1cm* (default)
  ///#dd.wave(data)
  /// 
  ///*symbol-width: 2cm*
  ///#dd.wave(data, symbol-width: 2cm)`)
  /// 
  /// -> length
  symbol-width: 1cm,

  /// The height of one symbol or one wave, but applied to all waves. Float and ratio values are treated as relative to @-wave.symbol-width.
  /// 
  /// 
  /// #example(
  ///   `#let data = (signal: ((wave: "10|2"),))
  /// 
  ///*symbol-height: 7mm* (default)
  ///#dd.wave(data)
  /// 
  ///*symbol-height: 50%*
  ///#dd.wave(data, symbol-height: 50%)`)
  /// 
  /// -> length | ratio | float
  symbol-height: 7mm,
  /// First inset at which a transition change starts (i.e. `"0"` $->$ `"1"`). The value is the *`X`*-axis component, while the `Y`-axis component is set by #tidylink(label("-wave()"),`wave`). The example below highlights the inset with red circles (not actually drawn in real-use).
  ///
  /// #example(```
  ///#let data = (signal: ((wave: "102"),))
  /// 
  ///#stack(dir: ltr, spacing: 5mm, [
  ///  *12.5%* (default)
  ///<<<  #dd.wave(data)
  ///>>>#dd.wave(data, others: (info) => {
  ///>>>  import cetz.draw: *
  ///>>>  let pos = ((1.125,0),(2.125,info.symbol-height))
  ///>>>  for p in pos {
  ///>>>    circle(p,radius: 0.5mm, stroke: (red + 0.5pt), fill: red)
  ///>>>  }
  ///>>>})
  ///],[
  ///  *0.5mm*
  ///<<<  #dd.wave(data, step1: 0.5mm)
  ///>>>#dd.wave(data, step1: 0.5mm, others: (info) => {
  ///>>>  import cetz.draw: *
  ///>>>  let pos = ((1 + 0.5mm / info.size-ref,0),(2 + 0.5mm / info.size-ref,info.symbol-height))
  ///>>>  for p in pos {
  ///>>>    circle(p,radius: 0.5mm, stroke: (red + 0.5pt), fill: red)
  ///>>>  }
  ///>>>})
  ///])```)
  /// 
  /// -> ratio | float | length
  step1: 12.5%,

  /// Second inset at which a transition change ends (i.e. `"0"` $->$ `"1"`). The value is the *`X`*-axis component, while the `Y`-axis component is set by #tidylink(label("-wave()"),`wave`). The example below highlights the inset with blue circles (not actually drawn in real-use).
  ///
  /// #example(```
  ///#let data = (signal: ((wave: "102"),))
  /// 
  ///#stack(dir: ltr, spacing: 5mm, [
  ///  *25%* (default)
  ///<<<  #dd.wave(data)
  ///>>>#dd.wave(data, others: (info) => {
  ///>>>  import cetz.draw: *
  ///>>>  let pos = ((1.25,info.symbol-height),(2.25,0))
  ///>>>  for p in pos {
  ///>>>    circle(p,radius: 0.5mm, stroke: (blue + 0.5pt), fill: blue)
  ///>>>  }
  ///>>>})
  ///],[
  ///  *4mm*
  ///<<<  #dd.wave(data, step2: 4mm)
  ///>>>#dd.wave(data, step2: 4mm, others: (info) => {
  ///>>>  import cetz.draw: *
  ///>>>  let pos = ((1 + 4mm / info.size-ref,info.symbol-height),(2 + 4mm / info.size-ref,0))
  ///>>>  for p in pos {
  ///>>>    circle(p,radius: 0.5mm, stroke: (blue + 0.5pt), fill: blue)
  ///>>>  }
  ///>>>})
  ///])```)
  /// 
  /// -> ratio | float | length
  step2: 25%,

  /// Third inset at which a tristate-like transition ends (i.e. `"1"` $->$ `"z"`). The value is the *`X`*-axis component, while the `Y`-axis component is set by #tidylink(label("-wave()"),`wave`). The example below highlights the inset with green circles (not actually drawn in real-use).
  ///
  /// #example(```
  ///#let data = (signal: ((wave: "=z."),))
  /// 
  ///#stack(dir: ltr, spacing: 5mm, [
  ///  *50%* (default)
  ///<<<  #dd.wave(data)
  ///>>>#dd.wave(data, others: (info) => {
  ///>>>  import cetz.draw: *
  ///>>>  let pos = ((1.5,info.symbol-height / 2),)
  ///>>>  for p in pos {
  ///>>>    circle(p,radius: 0.5mm, stroke: (olive + 0.5pt), fill: olive)
  ///>>>  }
  ///>>>})
  ///],[
  ///  *8mm*
  ///<<<  #dd.wave(data, step3: 8mm)
  ///>>>#dd.wave(data, step3: 8mm, others: (info) => {
  ///>>>  import cetz.draw: *
  ///>>>  let pos = ((1 + 8mm / info.size-ref,info.symbol-height / 2),)
  ///>>>  for p in pos {
  ///>>>    circle(p,radius: 0.5mm, stroke: (olive + 0.5pt), fill: olive)
  ///>>>  }
  ///>>>})
  ///])```)
  ///
  /// -> ratio | float | length
  step3: 50%,

  
  /// Third inset at which a tristate-like transition ends (i.e. `"1"` $->$ `"z"`). The value is the *`X`*-axis component, while the `Y`-axis component is set by #tidylink(label("-wave()"),`wave`). The example below highlights the bezier control point and its start and end points (controlled via @-wave.step1 and @-wave.step3 respectively) with red circles and red lines (not actually drawn in real-use).
  ///
  /// #example(```
  ///#let data = (signal: ((wave: "=zu"),))
  /// 
  ///#stack(dir: ltr, spacing: 5mm, [
  ///  *25%* (default)
  ///<<<  #dd.wave(data)
  ///>>>#dd.wave(data, others: (info) => {
  ///>>>  import cetz.draw: *
  ///>>>  let pos = ((1.25,info.symbol-height / 2),(2.25, 0))
  ///>>>  for p in pos {
  ///>>>    circle(p,radius: 0.5mm, stroke: (red + 0.5pt), fill: red)
  ///>>>  }
  ///>>>  
  ///>>>  line((1.125,0),(1.25, info.symbol-height / 2),(1.5, info.symbol-height / 2), stroke: (paint: red, thickness: 0.5pt)) 
  ///>>> 
  ///>>>  line((1.125,info.symbol-height),(1.25, info.symbol-height / 2), stroke: (paint: red, thickness: 0.5pt)) 
  ///>>>  
  ///>>>  line((2.125,info.symbol-height / 2),(2.25, 0), (2.5,0), stroke: (paint: red, thickness: 0.5pt))
  ///>>>})
  ///],[
  ///  *0%*
  ///<<<  #dd.wave(data, bezier-controlpoint: 0%)
  ///>>>#dd.wave(data, bezier-controlpoint: 0%, others: (info) => {
  ///>>>  import cetz.draw: *
  ///>>>  let pos = ((1 + 0,info.symbol-height / 2),(2, 0))
  ///>>>  for p in pos {
  ///>>>    circle(p,radius: 0.5mm, stroke: (red + 0.5pt), fill: red)
  ///>>>  }
  ///>>>  
  ///>>>  line((1.125,0),(1, info.symbol-height / 2),(1.5, info.symbol-height / 2), stroke: (paint: red, thickness: 0.5pt)) 
  ///>>> 
  ///>>>  line((1.125,info.symbol-height),(1, info.symbol-height / 2), stroke: (paint: red, thickness: 0.5pt))
  ///>>>  
  ///>>>  line((2.125,info.symbol-height / 2),(2, 0), (2.5,0), stroke: (paint: red, thickness: 0.5pt))
  ///>>>})
  ///])```)
  ///
  /// -> ratio | float | length
  bezier-controlpoint: 25%,

  /// The overshoot on the left and right side of each wave.
  /// 
  /// #example(`#let data = (signal: ((wave: "10|2"),))
  ///
  ///*edge-overshoot: 0%* (default)
  ///#dd.wave(data)
  /// 
  ///*edge-overshoot: 5mm*
  ///#dd.wave(data,edge-overshoot: 5mm)
  /// 
  ///// 100% is equal to 7mm (symbol-width = 7mm)
  ///`)
  /// -> ratio | float | length
  edge-overshoot: 0%,

  /// The spacing between waves. Not included when an empty wave is inserted (wave $=$ `(:)`).
  /// 
  /// Float and ratio values are treated as relative to @-wave.symbol-width.
  /// 
  /// #example(`#let data = (signal: ((wave: "10|2"),(wave: "10|2"),))
  ///
  ///*wave-gutter: 4mm* (default)
  ///#dd.wave(data)
  /// 
  ///*wave-gutter: 100%*
  ///#dd.wave(data, wave-gutter: 100%)
  /// 
  ///// 100% is equal to 7mm (symbol-width = 7mm)
  ///`)
  /// 
  /// -> ratio | float | length
  wave-gutter: 4mm,

  /// The spacing between wave and the wave name.
  /// 
  ///#example(
  ///`#let data = (signal: (
  ///   (wave: "10|2", name: emph[Hello]),
  /// ))
  ///
  ///*name-gutter: 0.4* (default)
  ///#dd.wave(data)
  /// 
  ///*name-gutter: 1.6*
  ///#dd.wave(data, name-gutter: 1.6)`)
  /// 
  /// -> ratio | float | length
  name-gutter: 3mm,

  /// Spacing between the $integral$ symbols of the time skip symbol.
  /// 
  /// #example(
  ///`#let data = (signal: ((wave: "5|."),))
  /// 
  /// #stack(dir: ltr,[
  ///   *s-spacing: 1mm* (default)
  ///   #dd.wave(data)
  /// ],[
  ///   *s-spacing: 50%*
  ///   #dd.wave(data, s-spacing: 50%)
  /// ], spacing: 5mm)
  ///`)
  /// 
  /// -> ratio | float | length
  s-spacing: 1mm,

  /// Width of the $integral$ symbols of the time skip symbol.
  /// 
  /// #example(
  ///`#let data = (signal: ((wave: "5|."),))
  /// 
  /// #stack(dir: ltr,[
  ///   *s-width: 1.5mm* (default)
  ///   #dd.wave(data)
  /// ],[
  ///   *s-width: 50%*
  ///   #dd.wave(data, s-width: 50%)
  /// ], spacing: 5mm)
  ///`)
  /// 
  /// -> ratio | float | length
  s-width: 1.5mm,

  /// The "overshoot" of the $integral$ symbols of the time skip symbol outside of the wave height.
  /// 
  /// #example(
  ///`#let data = (signal: ((wave: "5|."),))
  /// 
  /// #stack(dir: ltr,[
  ///   *s-outside: 1mm* (default)
  ///   #dd.wave(data)
  /// ],[
  ///   *s-outside: 50%*
  ///   #dd.wave(data, s-outside: 50%)
  /// ], spacing: 5mm)
  ///`)
  /// 
  /// -> ratio | float | length
  s-outside: 1mm,

  /// The size of the arrow marks applied to clocks (`"N"`, `"P"`) and logic signal flanks (`"L"`, `"H"`).
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "NNLHLPP"),
  /// ))
  ///
  ///*mark-scale: 1* (default)
  ///#dd.wave(data)
  /// 
  ///*mark-scale: 2*
  ///#dd.wave(data, mark-scale: 2)`)
  /// 
  /// -> float
  mark-scale: 1,

  /// The styling of the solid wave strokes.
  /// 
  /// #example(
  ///`#let data = (signal: ((wave: "10|uz3x"),))
  ///
  ///*Default*
  ///#dd.wave(data)
  ///
  ///#raw("(paint: red, join: \"round\", cap: \"round\")", lang: "typc")
  ///
  ///#dd.wave(data, stroke: (paint: red, join: "round", cap: "round")) 
  ///`)
  ///
  /// -> stroke
  stroke: (thickness: 0.5pt, cap: "square", paint: black),

  
  /// The styling of the dashed strokes of the symbols `"u"` and `"d"`. Missing configurations are inherited from @-wave.stroke (as seen in the example below).
  /// 
  /// #example(
  ///`#let data = (signal: ((wave: "d|u|.d."),))
  ///
  ///*Default*
  ///#dd.wave(data, stroke: 2pt)
  ///
  ///#raw("paint: red, dash: \"dotted\"", lang: "typc")
  ///
  ///#dd.wave(data, stroke: 2pt, stroke-dashed: (paint: red, dash: "dotted")) 
  ///`)
  ///
  /// -> stroke
  stroke-dashed: (dash: (2pt, 1.75pt), cap: "butt"),

  /// Controls the drawing of the tick lines and labels based on boolean conditions.
  /// `true` draws all tick lines and labels, `false` does not. Passing a function in the shape of
  /// `(n) => {..} -> bool` can be used to conditionally draw tick lines (e.g. only odd lines).
  ///
  /// #example(
  ///```
///#let data = (signal: ((wave: "1203.2."),))
  ///
  ///*show-ticks: `true`* (Default)
  ///#dd.wave(data)
  ///
  ///*show-ticks: `false`*
  ///#dd.wave(data, show-ticks: false)
  /// 
  ///*show-ticks: `calc.odd`*
  ///#dd.wave(data, show-ticks: (n) => calc.odd(n))
  ///```)
  /// -> bool | function
  show-ticks: true,

  /// Spacing between the tick numbers and tick lines (including @-wave.tick-overshoot). Length is relative to @-wave.symbol-width.
  /// 
  /// #example(
  ///```
///#let data = (signal: ((wave: "1203.2."),))
  ///
  ///*tick-gutter: `20%`* (Default)
  ///#dd.wave(data)
  ///
  ///*tick-gutter: `8mm`*
  ///#dd.wave(data, tick-gutter: 8mm)
  ///```)
  /// 
  /// -> ratio | float | length
  tick-gutter: 20%,

  /// Overshoot of the tick line outside of the *total* diagram height. Length is relative to @-wave.symbol-width.
  /// 
  /// #example(
  ///```
///#let data = (signal: ((wave: "1203.2."),(wave: "9102.d.")))
  ///
  ///*tick-overshoot: `1mm`* (Default)
  ///#dd.wave(data)
  ///
  ///*tick-overshoot: `100%`*
  ///#dd.wave(data, tick-overshoot: 100%)
  ///```)
  /// 
  /// -> ratio | float | length
  tick-overshoot: 1mm,

  /// A rendering function with one parameter representing the tick number. Must return `content` and essentially describes how the label numbers are rendered. Setting it to #text(red,`none`) removes the labels.
  /// 
  /// #example(
  ///```
///#let data = (signal: (
  ///   (wave: "10|uz3x"),
  /// ))
  ///
  ///*Default*
  ///#dd.wave(data)
  /// 
  ///*tick-format:* `(n) => numbering("I", n)`
  ///#dd.wave(data, tick-format: (n) => numbering("I", n))
  /// 
  ///*tick-format:* `none`
  ///#dd.wave(data, tick-format: none)```)
  ///
  /// -> none | function
  tick-format: (n) => text(0.8em, numbering("1", n)),

  /// The stroke of the tick lines. `none` disables the lines and passing a function in the shape of `(n) => stroke | none` allows for special styling based on tick number
  /// 
  /// #example(
  ///```
///#let data = (signal: ((wave: "x0d|u=1"),))
  ///
  ///*Default*
  ///#dd.wave(data)
  /// 
  ///*tick-stroke: `function`*
  ///#dd.wave(data, tick-stroke: (n) => {
  ///  if calc.odd(n) {
  ///    red + 2pt
  ///  } else {
  ///    blue + 0.5pt
  ///  }
  ///})
  /// 
  ///*tick-stroke:* `none`
  ///#dd.wave(data, tick-stroke: none)```)
  /// 
  /// -> none | stroke | function
  tick-stroke: (thickness: 0.5pt, paint: gray, dash: "densely-dashed"),

  /// When set to a stroke or a dictionary with stroke entries `top` and `bottom`, this will draw horizontal lines at the _Low_ and _High_ level of each wave.
  /// 
  /// #example(
  ///```
///#let data = (signal: ((wave: "PpH|7.0"),))
  ///
  ///*guide-stroke: `none`* (Default)
  ///#dd.wave(data)
  /// 
  ///*guide-stroke: `stroke`*
  ///#dd.wave(data, guide-stroke: red + 0.5pt)
  /// 
  ///*guide-stroke: `dictionary`*
  ///#dd.wave(data, guide-stroke: (top: red + 0.5pt, bottom: blue + 0.5pt))```)
  /// 
  /// -> none | stroke | dictionary
  guide-stroke: none,

  /// The formatting of the wave names, which are attached next to each respective wave.
  /// 
  /// #example(
  ///```
///#let data = (signal: ((wave: "3.P.H.", name: [Hello Digidraw]),))
  ///
  ///*Default*
  ///#dd.wave(data)
  /// 
  ///*name-format: `emph`*
  ///#dd.wave(data, name-format: emph)
  /// 
  ///*name-format: `raw`* (name is `content` here)
  ///#dd.wave(data, name-format: (name) => raw(name.text))```)
  /// 
  /// -> function
  name-format: name => text(1em, weight: "bold", bottom-edge: "baseline", name),

  /// The formatting of the wave bus data/labels. Similar to @-wave.name-format, with the exception that `data-format` also can use `#align` to align the labels in the respective bus.
  /// 
  /// Use `debug: "labels"` to see the bounding boxes of where labels can be placed.
  /// 
  /// 
  /// #example(
  ///```
///#let data = (signal: ((wave: "3.P..5.", data: "Hello Digidraw"),))
  ///
  ///*Default*
  ///#dd.wave(data)
  /// 
  ///*data-format: `emph`*
  ///#dd.wave(data, data-format: name => align(horizon+center, emph(name)))
  /// 
  ///*data-format: blue text*
  ///#dd.wave(data, data-format: (name) => align(horizon,text(blue, name)))```)
  /// 
  /// -> function
  data-format: data => align(center + horizon, text(
    0.9em,
    bottom-edge: "baseline",
    data,
  )),

  /// A dictionary containing the bus number/type as the key and fill colors, tilings or gradients as value.
  /// 
  /// / Note: When not all bus colors are configured, the remaining ones *will* be set to the default values.
  /// 
  /// 
  /// #example(```
  ///#let data = (signal: (
  ///  (wave: "80|2.3x"),)
  ///)
  ///#let bus-colors = ("2": blue.lighten(50%))
  ///
  ///#dd.wave(data, debug: "symbols")
  /// 
  ///*New Bus Colors*
  ///#dd.wave(data, debug: "symbols", bus-colors: bus-colors)
  ///```)
  /// 
  /// `digidraw-x-pattern()` is the gray diagonal lines (as seen in the example below). It can be customized
  /// 
  /// -> dictionary
  bus-colors: (
    "=": white,
    "2": white,
    "3": rgb("#ffffb4"),
    "4": rgb("#ffe0b9"),
    "5": rgb("#b9e0ff"),
    "6": rgb("#ccfdfe"),
    "7": rgb("#cdfdc5"),
    "8": rgb("#f0c1fb"),
    "9": rgb("#f8d0ce"),
    "x": digidraw-x-pattern(),
  ),

  /// After the diagram is rendered, additional `cetz` elements can be added on top of it. The parameter accepts a function with following shape
  /// 
  /// #align(center, block(stroke: 0.5pt + gray, radius: 0.5em, inset: 0.5em, `(info) => {..}`))
  /// 
  /// where `info` consists of various information useful when placing elements (the values of these properties are given *in `cetz` units*):
  /// 
  /// #align(center, block(stroke: 0.5pt + gray, radius: 0.5em, inset: 0.5em, `(total-width, total-height, size-ref, symbol-height, wave-origins)`))
  /// 
  /// / `total-width`: is equal to the longest wave and can be read from the tick numbers
  /// / `total-height`: is equal to the sum of all wave heights and gutters
  /// / `size-ref`: (or `symbol-width`) is useful when you want to convert lengths to respective cetz units or in reverse.
  /// / `symbol-height`: is equal to the symbols' height
  /// / `wave-origins`: the actual points used to draw the waves (equal to the top left corner of a wave). 
  /// 
  /// Use `debug: "coordinates"` to find specific points. Additionally you can use `set-origin(..)` to jump to specific points the diagram:
  /// 
  /// - `"diagram-origin"` is the top left corner of the diagram, indicated by the blue circle with a dot inside in the example.
  /// - `"waveX"` where `X` is the 0-indexed number of the respective wave. Is equal to the *bottom left corner* of each wave, also indicated by the red dots in the example. 
  /// 
  /// #callout(type: "caution", [I'm currently not too happy about the implementation\ and it might change in the future.], width: auto)
  /// 
  /// #example(```
  ///#import "@preview/cetz:0.4.2"
  ///
  ///#dd.wave((signal: (
  ///  (wave: "80|2.3x"), (wave: "0d.|.l."),
  ///  (wave: "5..|.d."), (wave: "xxx00xx"),
  ///)), others: (info) => {
  ///  import cetz.draw: *
  /// 
  ///  set-origin("wave1")
  ///  content((info.total-width/2,-info.symbol-height/2),text(red, strong[Hello World]))
  /// 
  ///  for i in range(4) {
  ///    set-origin("wave" + str(i))
  ///    circle((0,0),radius: 2pt, fill: red)
  ///  }
  /// 
  ///  set-origin("diagram-origin")
  ///  circle((0,0),radius: 3pt, fill: blue)
  ///  circle((0,0),radius: 0.5pt, fill: black, stroke: 0.5pt)
  ///})
  /// 
  ///```)
  /// -> cetz
  others: none,
) = {
  assert(type(data) == dictionary, message: "'data' must be a dictionary à la WaveDrom.")
  
  assert(
    type(symbol-width) == length,
    message: "`symbol-width` must be of type length",
  )

  assert(type(debug) == bool or type(debug) == array or debug in ("labels", "symbols", "steps", "coordinates"))
  assert(type(tick-gutter) in (ratio, float, int, length), message: "`tick-gutter` must be a ratio or float")
  assert(
    type(show-ticks) in (bool, function) or show-ticks == none,
    message: "`show-ticks` must be a boolean or function or none",
  )
  assert(type(name-gutter) in (ratio, float, int, length), message: "`name-gutter` must be a ratio or float or length")
  assert(type(wave-gutter) in (ratio, float, int, length), message: "`wave-gutter` must be a ratio or float or length")
  assert(
    type(edge-overshoot) in (ratio, float, int, length),
    message: "`edge-overshoot` must be a ratio or float or length",
  )
  assert(type(bezier-controlpoint) in (ratio, float, int), message: "`bezier-controlpoint` must be a ratio or float")
  assert(
    type(tick-overshoot) in (ratio, float, int, dictionary, length),
    message: "`tick-overshoot` must be a ratio or float",
  )

  assert(
    type(guide-stroke) in (std.stroke, dictionary, std.color) or guide-stroke == none,
    message: "`guide-stroke` must be either none, stroke or a stroke dictionary (accepted keys: top,bottom,y)",
  )

  let size-ref = symbol-width

  /* -------------------------------------------------------------------------- */
  /*                                 Conversion                                 */
  /* -------------------------------------------------------------------------- */
  symbol-height = utility.length-to-float(symbol-height, size-ref)

  step1 = utility.length-to-float(step1, size-ref)
  step2 = utility.length-to-float(step2, size-ref)
  step3 = utility.length-to-float(step3, size-ref)
  bezier-controlpoint = utility.length-to-float(bezier-controlpoint, size-ref)

  wave-gutter = utility.length-to-float(wave-gutter, size-ref)
  name-gutter = utility.length-to-float(name-gutter, size-ref)

  tick-gutter = utility.length-to-float(tick-gutter, size-ref)
  tick-overshoot = utility.length-to-float(tick-overshoot, size-ref)
  tick-stroke = if type(tick-stroke) == function { tick-stroke } else { n => tick-stroke }

  stroke = utility.fallback-stroke(std.stroke(stroke))

  stroke-dashed = utility.merge-strokes(std.stroke(stroke), std.stroke(stroke-dashed))

  s-spacing = utility.length-to-float(s-spacing, size-ref)
  s-outside = utility.length-to-float(s-outside, size-ref)
  s-width = utility.length-to-float(s-width, size-ref)

  guide-stroke = if guide-stroke == none or type(guide-stroke) == dictionary and ("top" in guide-stroke or "bottom" in guide-stroke) {
    guide-stroke
  } else {
    (top: guide-stroke, bottom: guide-stroke)
  }

  bus-colors = __digidraw-default-config.bus-colors + bus-colors

  let config = (
    //__digidraw-default-config +
    (
      symbol-height: symbol-height,
      step1: float(step1),
      step2: float(step2),
      step3: float(step3),
      bezier-controlpoint: float(bezier-controlpoint),
      edge-overshoot: if type(edge-overshoot) == length { edge-overshoot / symbol-width } else {
        float(edge-overshoot)
      },
    )
  )

  debug = (
    "symbols": debug == true or debug == "symbols" or (type(debug) == array and "symbols" in debug),
    "steps": debug == true or debug == "steps" or (type(debug) == array and "steps" in debug),
    "labels": debug == true or debug == "labels" or (type(debug) == array and "labels" in debug),
    "coordinates": debug == true or debug == "coordinates" or (type(debug) == array and "coordinates" in debug),
  )

  /* -------------------------------------------------------------------------- */
  /*                                Sanitization                                */
  /* -------------------------------------------------------------------------- */

  let needs-gutter = data.signal.enumerate().map(x => (x.last() != (:)) and not (x.first() == data.signal.len() - 1))
  let is-empty = data.signal.enumerate().map(x => x.last() == (:))

  /* ---------------- 1. Get Total Width and Height of Diagram ---------------- */
  // Total Width
  let total-width = calc.max(..data.signal.map(x => x.at("wave", default: "").len()))

  // Total Height
  let total-height = 0
  let wave-origin-points = for (gut, emp) in needs-gutter.zip(is-empty) {
    if not emp {
      (total-height,)
    }
    total-height += symbol-height + if gut { wave-gutter }
  }

  /* -------------------------- 2. Get Wave From Data ------------------------- */
  // process each wave and extract the most important elements
  let waves = for wave in data.signal.filter(wave => wave != (:)) { (wave,) }

  // waves-data:
  // - name [content/string/array]
  // - data [content/string/array]
  // - primary [elements]
  // - secondary [elements]
  // - bodies [elements]
  // - s [x coords]
  let waves-data = for wave in waves {
    let processed-symbols = utility.wave-groupify(wave.wave, config)

    let symbol-coords = processed-symbols
      .entries
      .enumerate()
      .map(x => {
        let (i, curr) = x

        let prev = if i == 0 { none } else { processed-symbols.entries.at(i - 1).symbol }
        let next = processed-symbols.entries.at(i + 1, default: (symbol: none)).symbol

        (
          (symbols.symbol2lines.at(lower(curr.symbol)))(prev, next, curr, config)
            + if curr.symbol in bus-colors { (fill: bus-colors.at(curr.symbol)) }
        )
      })

    let marks-up = symbol-coords.filter(x => ("mark" in x) and (x.symbol == ">")).map(x => x.mark).flatten()
    let marks-down = symbol-coords.filter(x => ("mark" in x) and (x.symbol == "<")).map(x => x.mark).flatten()

    let (primary, dashed) = utility.coords2elements(symbol-coords.map(x => x.primary).sum())
    let secondary = symbol-coords
      .map(x => if "secondary" in x { utility.coords2elements(x.secondary) })
      .filter(x => x != none)
      .map(x => x.first().first())
    let bodies = symbol-coords.filter(x => ("body" in x)).map(x => (x.body, x.fill).flatten())
    let labels = symbol-coords.filter(x => ("label" in x)).map(x => x.label)
    

    (
      if "name" in wave { (name: wave.name) }
        + if "data" in wave {
          (
            data: if type(wave.data) == str {
              wave.data.split(" ")
            } else {
              wave.data
            },
          )
        }
        + (primary: primary, secondary: secondary, mark-up: marks-up, mark-down: marks-down, bodies: bodies, s: processed-symbols.s, label-pos: labels, symbols: processed-symbols.entries)
        + if dashed != none { (dashed: dashed) },
    )
  }

  /* -------------------------------------------------------------------------- */
  /*                               Rendering Part                               */
  /* -------------------------------------------------------------------------- */
  cetz.canvas(length: size-ref, {

    import cetz.draw: circle, content, hide, line, merge-path, scale, set-origin, translate, mark, rect

    /* ------------------------- 5. Place Origin Element ------------------------ */
    hide(circle((0, 0), radius: 2pt, stroke: 0pt, fill: red, name: "diagram-origin"))

    /* ------------------------ 6. Draw General Elements ------------------------ */
    // tick lines and numbers
    if show-ticks == true or type(show-ticks) == function {
      for i in range(0, total-width, inclusive: true) {
        // skip if it is not needed (if function)
        if type(show-ticks) == function and not show-ticks(i) {
          continue
        }

        // tick number
        if tick-format != none and tick-format(i) != none {
          content((i, tick-overshoot + tick-gutter), tick-format(i), anchor: "south")
        }

        if tick-stroke(i) != none {
          line((i, tick-overshoot), (i, -total-height - tick-overshoot), stroke: tick-stroke(i))
        }
      }
    }

    // guide lines
    if guide-stroke != none {
      wave-origin-points
        .map(y-start => {
          if "top" in guide-stroke {
            line((0, -y-start), (total-width, -y-start), stroke: guide-stroke.top)
          }
          if "bottom" in guide-stroke {
            line((0, -y-start - symbol-height), (total-width, -y-start - symbol-height), stroke: guide-stroke.bottom)
          }
        })
        .sum()
    }

    scale(y: -1) // easier to draw waves and debug elements

    /* ------------------------- 7. Render Debug Part 1 ------------------------- */
    if debug.steps {
      set-origin("diagram-origin")
      for i in range(0,total-width) {
        line((i + step1, -1mm), (i + step1, total-height + 1mm / size-ref), stroke: 0.5pt + red, mark: (symbol: "o", width: 3pt, length: 3pt, stroke: 0pt, fill: red, anchor:"center"))
        line((i + step2, -1mm), (i + step2, total-height + 1mm / size-ref), stroke: 0.5pt + blue, mark: (symbol: "o", width: 3pt, length: 3pt, stroke: 0pt, fill: blue, anchor:"center"))
        line((i + step3, -1mm), (i + step3, total-height + 1mm / size-ref), stroke: 0.5pt + olive, mark: (symbol: "o", width: 3pt, length: 3pt, stroke: 0pt, fill: olive, anchor:"center"))
      }
    }

    /* ----------------------------- 8. Render Waves ---------------------------- */
    // render the wave origin points first, so they're accesible
    for (i, origin) in wave-origin-points.enumerate() {
      hide(circle((0, origin + symbol-height), radius: 2pt, stroke: 0pt, fill: red, name: "wave" + str(i)))
    }

    for (i, (data, origin)) in waves-data.zip(wave-origin-points).enumerate() {
      set-origin("wave" + str(i))

      /* prepare correct scaling */
      scale(y: -1)

      /* Bodies */
      data.bodies.map(elem => merge-path(elem.slice(0,-1), fill: elem.last(), stroke: none)).flatten()

      /* Secondary */
      data.secondary.map(elem => merge-path(elem.sum(), stroke: stroke)).flatten()

      /* Dashed Lines */      
      data.at("dashed", default: ()).map(elem => line(..elem, stroke: stroke-dashed)).flatten()

      /* Primary */
      data.primary.map(elem => merge-path(elem.sum(), stroke: stroke)).flatten()

      /* Marks */
      data.mark-up.map(x => mark((x,symbol-height/2), (x,1), mark: (symbol: ">", fill: if stroke.paint == auto {black} else {stroke.paint}, stroke: 0pt, scale: mark-scale), anchor: "center")).flatten()
      data.mark-down.map(x => mark((x,symbol-height/2), (x,0), mark: (symbol: ">", fill: if stroke.paint == auto {black} else {stroke.paint}, stroke: 0pt, scale: mark-scale), anchor: "center")).flatten()

      /* Bus Labels */
      if "data" in data {
        data.data.zip(data.label-pos).map(x => {
          let (label,l) = x
          content((l.first(), 0), (l.last(), symbol-height), data-format(label))
        }).flatten()
      }

      /* Double S */
      data.s.map(x => {
        let shape = utility.draw-s(x, s-width, s-spacing, s-outside, stroke, symbol-height)
        merge-path(shape, stroke: none, fill: white)
        shape
      }).flatten()

      /* Name */
      if "name" in data {
        content((-name-gutter, symbol-height / 2), anchor: "east", name-format(data.name))
      }

      /* reset scaling */
      scale(y: -1)
    }

    /* ------------------------- 9. Render Debug Part 1 ------------------------- */
    if debug.steps {
      set-origin("diagram-origin")
      for i in range(0,total-width) {
        line((i + step1, -1mm), (i + step1, total-height + 1mm / size-ref), stroke: (thickness: 0.45pt, paint: red, dash: "densely-dotted"))
        line((i + step2, -1mm), (i + step2, total-height + 1mm / size-ref), stroke: (thickness: 0.45pt, paint: blue, dash: "densely-dotted"))
        line((i + step3, -1mm), (i + step3, total-height + 1mm / size-ref), stroke: (thickness: 0.45pt, paint: olive, dash: "densely-dotted"))
      }
    }

    if debug.labels {
      for (i,label-pos) in waves-data.map(x => x.label-pos).enumerate() {
        if label-pos == () {
          continue
        }

        set-origin("wave" + str(i))
        label-pos.map(it => {
          let (start,end) = it
          mark(((start + end) / 2,-symbol-height/2),((start + end) / 2,0),symbol: (symbol: "o", stroke: 0pt, fill: orange.transparentize(30%), anchor: "center"))
          line((start,-symbol-height),(end,-symbol-height), stroke: (paint: gray, thickness: 0.25pt, dash: "densely-dashed"))
          mark(((start + end) / 2,-symbol-height/2),((start + end) / 2,0), symbol: (symbol: "x", width: end - start, length: symbol-height, stroke: (paint: red, thickness: 0.25pt, dash: "densely-dashed"), fill: red.transparentize(30%), anchor: "center"))
          rect((start,0),(end, -symbol-height), stroke: red + 0.75pt)
        }).flatten()
      }
    }

    if debug.coordinates {
      set-origin("diagram-origin")
      let number-box(n, corner-at: "top-left") = box(inset: 2pt, fill: red.lighten(60%), stroke: 0.75pt + red, radius: ((corner-at,0pt),).to-dict() + (rest: 3pt), text(8pt, raw(str(calc.round(n, digits: 3)))))

      wave-origin-points.map(y => {
        content((0,y), anchor: "north-west", number-box(y))
      }).flatten()

      line((-name-gutter, 0), (-name-gutter, total-height), stroke: 0.75pt + red)
      content((-name-gutter,0), number-box(name-gutter, corner-at: "bottom-right"), anchor: "east")

      line((0, -tick-gutter - tick-overshoot), (total-width, -tick-gutter - tick-overshoot), stroke: 0.75pt + red)
      content((0,-tick-gutter - tick-overshoot), number-box(tick-gutter + tick-overshoot, corner-at: "bottom-right"), anchor: "south-east")
    }

    if debug.symbols {
      for (i,data) in waves-data.enumerate() {
        set-origin("wave" + str(i))
        data.symbols.map(x => {
          line((x.offset,2mm),(x.offset + x.length,2mm), stroke: red + 0.75pt, mark: (symbol: ">", stroke: 0pt, fill: red))
          content((x.offset + x.length / 2,2mm), text(7pt, box(fill: red.lighten(60%),  radius: 1pt, width: 7pt, height: 7pt, align(center+horizon, raw(x.symbol)))))
        }).flatten()
      }
    }

    

    /* --------------------------- 10. Render `others` --------------------------- */
    set-origin("diagram-origin") // reset to origin
    if others != none {
      let diagram = (total-width: total-width, total-height: total-height, size-ref: symbol-width, symbol-height: symbol-height, wave-origins: wave-origin-points)
      others(diagram)
    }
  })
}


