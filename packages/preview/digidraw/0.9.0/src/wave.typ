#import "@preview/cetz:0.4.2"

#import "./utility/objects.typ": objects
#import "./utility/utility.typ"
#import "./utility/defaults.typ": __digidraw-default-config, __digidraw-x-pattern 




///
/// -> content
#let wave(
  ///
  /// The wave data à la WaveDrom syntax.
  /// 
  /// #example(
  ///   `#let data = (signal: (
  ///  (wave: "3.0u7.", name: "A", data: "Hello World"),
  ///  (wave: "d5.04.", name: "B", data: ([Another],[World],)),
  ///))
  ///
  ///#wave(data)`)
  ///
  /// -> dictionary
  data,
  /// Sets the size of one "unit" of the diagram $->$ it's just the _length_ parameter of _cetz.canvas()_.
  ///
  /// To calculate the actual sizes, use following:
  ///
  /// - Actual symbol width $mono("size") dot mono("symbol-width")$
  /// - Actual wave height $mono("size") dot mono("wave-height")$
  ///
  /// #example(`#let data = (signal: ((wave: "10|2"),))
  ///
  ///*size: 8mm* (default)
  ///#wave(data)
  /// 
  ///*size: 1.25cm*
  ///#wave(data, size: 1.25cm)`)
  ///
  /// -> length
  size: 8mm,
  /// If enabled, shows which characters are assigned to each tick slot. Helps a lot with figuring out which symbol is inserted where.
  ///
  /// #example(
  ///   `#let data = (signal: ((wave: "10..|.2"),))
  ///
  ///*Debug OFF*
  ///#wave(data, debug: false)
  /// 
  ///*Debug ON*
  ///#wave(data, debug: true)`)
  ///
  /// -> boolean
  debug: false,
  /// When tick lines are enabled, defines the amount of overshoot times `size` added to the top and bottom of the tick line.
  /// 
  /// #example(
  ///   `#let data = (signal: ((wave: "10..|.2"),))
  /// 
  ///*tick-overshoot: 25%* (default)
  ///#wave(data)
  /// 
  ///*tick-overshoot: 50%*
  ///#wave(data, tick-overshoot: 50%)`)
  /// 
  /// -> ratio
  tick-overshoot: 25%,
  /// The width of the timing diagram in tick counts. If #text(red,`auto`) is given, uses the largest wave as tick count. If set to an integer, symbols after the given value are not rendered.
  ///
  /// #example(`#let data = (signal: ((wave: "10|2.z"),))
  /// 
  ///*wave-width: auto* (default)
  ///#wave(data)
  /// 
  ///*wave-width: 4*
  ///#wave(data, wave-width: 4)`)
  ///
  /// -> auto | integer
  wave-width: auto,
  /// The width of one symbol. The actual symbol width equals to $mono("size") dot mono("symbol-width")$
  ///
  /// #example(
  ///   `#let data = (signal: ((wave: "10|2"),))
  /// 
  ///*symbol-width: 1.3* (default)
  ///#wave(data)
  /// 
  ///*symbol-width: 2*
  ///#wave(data, symbol-width: 2)`)
  ///
  /// -> float
  symbol-width: 1.3,
  /// The height of one wave. The actual wave height equals to $mono("size") dot mono("wave-height")$
  ///
  /// #example(
  ///   `#let data = (signal: ((wave: "10|2"),))
  /// 
  ///*wave-height: 1* (default)
  ///#wave(data)
  /// 
  ///*wave-height: 1.5*
  ///#wave(data, wave-height: 1.5)`)
  ///
  /// -> float
  wave-height: 1,

  /// Ratio of the first inset and usually applied as a transition delay.
  ///
  /// #example(
  ///   `#let data = (signal: ((wave: "10|2"),))
  /// 
  ///*inset-1: 10%* (default)
  ///#wave(data)
  /// 
  ///*inset-1: 40%*
  ///#wave(data, inset-1: 40%)`)
  /// 
  /// -> ratio | float
  inset-1: 10%,

  /// Ratio of the second inset and usually applied to transition.
  ///
  /// #example(
  ///   `#let data = (signal: ((wave: "10|2"),))
  /// 
  ///*inset-2: 20%* (default)
  ///#wave(data)
  /// 
  ///*inset-2: 40%*
  ///#wave(data, inset-2: 0%)`)
  /// 
  /// -> ratio | float
  inset-2: 20%,

  /// The spacing between waves. Not included when an empty wave is inserted ($->$ #box(inset: (x: 1pt), outset: (y: 2.5pt), radius: 2pt, stroke: gray + 0.5pt, `(:)`)).
  /// 
  /// #example(
  ///   `#let data = (signal: ((wave: "10|2"),(wave: "10|2"),))
  ///
  ///*wave-gutter: 0.8* (default)
  ///#wave(data)
  /// 
  ///*wave-gutter: 0.2*
  ///#wave(data, wave-gutter: 0.2)`)
  /// 
  /// -> float
  wave-gutter: 0.8,

  /// The spacing between wave and the wave name.
  /// 
  ///#example(
  ///`#let data = (signal: (
  ///   (wave: "10|2", name: emph[Hello]),
  ///   (wave: "10|2", name: raw("World")),
  /// ))
  ///
  ///*name-gutter: 0.4* (default)
  ///#wave(data)
  /// 
  ///*name-gutter: 1.6*
  ///#wave(data, name-gutter: 1.6)`)
  /// 
  /// -> ratio
  name-gutter: 0.4,

  /// Spacing of the time skip symbol ($integral.double$).
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "1|0|2"),
  /// ))
  ///
  ///*s-spacing: 0.1* (default)
  ///#wave(data)
  /// 
  ///*s-spacing: 0.4*
  ///#wave(data, s-spacing: 0.4)`)
  /// 
  /// -> float
  s-spacing: 0.1,

  /// How much the time skip symbol reaches outside the wave.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "1|0|2"),
  /// ))
  ///
  ///*s-outside: 0.1* (default)
  ///#wave(data)
  /// 
  ///*s-outside: 0.3*
  ///#wave(data, s-outside: 0.3)`)
  /// 
  /// -> float
  s-outside: 0.1,
  
  /// The size of the arrow marks applied to clocks, .
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "NNLHLPP"),
  /// ))
  ///
  ///*mark-scale: 1* (default)
  ///#wave(data)
  /// 
  ///*mark-scale: 2*
  ///#wave(data, mark-scale: 2)`)
  /// 
  /// -> float
  mark-scale: 1,

  /// Renders two lines the "0" level and "1" level of the wave and uses @-wave.stroke-guides for the stroke styling.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "10|uz3x"),
  /// ))
  ///
  ///*show-guides: false* (default)
  ///#wave(data)
  /// 
  ///*show-guides: true*
  ///#wave(data, show-guides: true)`)
  /// 
  /// -> boolean
  show-guides: false,
  
  /// Changes/sets the styling of the wave strokes.
  /// 
  /// / Note: it is recommended to set at least `(cap: "round")`, so the line segments of the wave are correctly connect. It is a WIP fix!
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "10|uz3x"),
  /// ))
  ///
  ///*Default*
  ///#wave(data)
  /// 
  ///#raw("(paint: red, join: \"round\", cap: \"round\")", lang: "typc")
  ///#wave(data, stroke: (paint: red, join: "round", cap: "round"))`)
  /// 
  /// -> dictionary | stroke
  stroke: (thickness: 0.5pt, paint: black, join: "round", cap: "round"),
  
  /// An extension of @-wave.stroke for the transition edges `"u"` and `"d"`.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "d|u|.d."),
  /// ))
  ///
  ///*Default*
  ///#wave(data)
  /// 
  ///#raw("(paint: red, dash: \"loosely-dotted\",
  /// thickness: 2pt)", lang: "typc")
  ///#wave(data, stroke-dashed: (paint: red, dash: "loosely-dotted", thickness: 2pt))`)
  /// 
  /// -> dictionary | stroke
  stroke-dashed: (cap: "butt", join: "round", dash: (2pt, 2pt)),
  
  /// Renders the tick lines uses @-wave.stroke-tick-lines for the stroke styling.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "10|uz3x"),
  /// ))
  ///
  ///*show-tick-lines: true* (default)
  ///#wave(data)
  /// 
  ///*show-tick-lines: false*
  ///#wave(data, show-tick-lines: false)`)
  /// 
  /// -> boolean
  show-tick-lines: true,
  
  /// A rendering function with one parameter representing the tick number. Must return `content` and essentially describes how the label numbers are rendered. Setting it to #text(red,`none`) removes the labels.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "10|uz3x"),
  /// ))
  ///
  ///*Default*
  ///#wave(data)
  /// 
  ///*ticks-format:* #raw("(n) => numbering(\"I\", n)", lang: "typc")
  ///#wave(data, ticks-format: (n) => numbering("I", n))
  /// 
  ///*ticks-format:* #raw("none", lang: "typc")
  ///#wave(data, ticks-format: none)`)
  /// 
  /// -> function
  ticks-format: (n) => text(0.8em, numbering("1", n)),
  
  /// A rendering function with the wave name as parameter. Set it to #raw("none", lang: "typc") to not render any label (and removes @-wave.name-gutter)
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "10|ux", name: [Name]),
  /// ))
  ///
  ///*Default*
  ///#wave(data)
  /// 
  ///*name-format:* #raw("(name) => emph(name)", lang: "typc")
  ///#wave(data, name-format: (name) => emph(name))
  /// 
  ///*name-format:* #raw("none", lang: "typc")
  ///#wave(data, name-format: none)`)
  /// 
  /// -> function
  name-format: (name) => text(1em, weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", if type(name) != str [#name] else [#eval(name, mode: "markup")]),
  
  /// A rendering function with the respective data name as parameter. Set it to #raw("none", lang: "typc") to not render.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "14|uz3x", data: "Hello World"),
  /// ))
  ///
  ///*Default*
  ///#wave(data)
  /// 
  ///*data-format:* #raw("(data) => emph(data)", lang: "typc")
  ///#wave(data, data-format: (data) => emph(data))
  /// 
  ///*data-format:* #raw("none", lang: "typc")
  ///#wave(data, data-format: none)`)
  /// 
  /// -> function
  data-format: (data) => text(
    0.9em, top-edge: "cap-height", bottom-edge: "baseline",
    if type(data) != str [#data] else [#eval(data, mode: "markup")],
  ),

  /// The stroke styling of the tick lines.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "10|uz3x"),
  /// ))
  ///
  ///*Default*
  ///#wave(data)
  /// 
  ///*stroke-tick-lines: red*
  ///#wave(data, stroke-tick-lines: red)`)
  /// 
  /// -> dictionary | stroke
  stroke-tick-lines: (cap: "round", thickness: 0.5pt, paint: gray, dash: "dashed"),
  
  /// The stroke styling of the guide lines.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "10|uz3x"),
  /// ))
  ///
  ///*Default*
  ///#wave(data)
  /// 
  ///*stroke-guides: red*
  ///#wave(data, stroke-guides: red, show-guides: true)`)
  /// 
  /// -> dictionary | stroke
  stroke-guides: (cap: "round", thickness: 0.25pt, paint: gray),
  
  /// In case the debuging symbols are a bit off or hard to read, the debug-offset can be used to move the debug information vertically.
  /// 
  /// #example(
  ///`#let data = (signal: (
  ///   (wave: "10|uz3x"),
  /// ))
  ///
  ///*Default*
  ///#wave(data, debug: true)
  /// 
  ///*debug-offset: -0.5*
  ///#wave(data, debug-offset: -0.5, debug: true)`)
  /// 
  /// -> float
  debug-offset: 0.4,
  


  /// A dictionary containing the bus number/type as the key and fill colors, tilings or gradients as value.
  /// 
  /// / Note: When not all bus colors are configured, the remaining ones *will* be set to the default values.
  /// 
  /// 
  /// #example(
  ///   `#let data = (signal: (
  ///  (wave: "80|2.3x"),)
  ///)
  ///#let bus-colors = ("2": red.lighten(50%))
  ///
  ///#wave(data)
  /// 
  ///*New Bus Colors*
  ///#wave(data, bus-colors: bus-colors, debug: true)`)
  /// 
  /// `__digidraw-x-pattern` is the gray diagonal lines (as seen in the example below).
  /// 
  /// -> dictionary
  bus-colors: (
    "2": white,
    "3": rgb("#ffffb4"),
    "4": rgb("#ffe0b9"),
    "5": rgb("#b9e0ff"),
    "6": rgb("#ccfdfe"),
    "7": rgb("#cdfdc5"),
    "8": rgb("#f0c1fb"),
    "9": rgb("#f8d0ce"),
    "x": __digidraw-x-pattern,
  ),
) = {
  assert(type(data) == dictionary, message: "'data' must be a dictionary à la WaveDrom.")
  assert(wave-width == auto or wave-width > 0, message: "'wave-width' must be either 'auto' or larger than 0.")

  let config = (
    __digidraw-default-config
      + (
        symbol-width: symbol-width,
        wave-height: wave-height,
        inset-1: inset-1,
        inset-2: inset-2,
        wave-gutter: wave-gutter,
        name-gutter: name-gutter,
        s-spacing: s-spacing,
        s-outside: s-outside,
        mark-scale: mark-scale,
        show-guides: show-guides,
        stroke: stroke,
        stroke-dashed: stroke-dashed,
        show-tick-lines: show-tick-lines,
        ticks-format: ticks-format,
        name-format: name-format,
        stroke-tick-lines: stroke-tick-lines,
        stroke-guides: stroke-guides,
        debug-offset: debug-offset,
        data-format: data-format,
        bus-colors: bus-colors,
      )
        .pairs()
        .filter(x => x.last() != auto)
        .to-dict()
  )

  // Merge bus colors
  let _bus-colors = __digidraw-default-config.bus-colors
  for (k,v) in bus-colors.pairs() {
    _bus-colors.at(k) = v
  }
  config.bus-colors = _bus-colors

  /* ---------------------------- [1] Sanitization ---------------------------- */
  data.signal = data.signal.map(x => {
    // split data labels into arrays if they aren't already
    if x.at("data", default: none) != none and type(x.data) == str {
      x.data = x.data.split(" ")
    }

    if x != (:) {
      // convert '=' buses to '2' buses as they are both the same
      x.wave = x.wave.replace("=", "2")

      // converts any unknown symbol to '/' which indicates an invalid symbol (-> default object)
      x.wave = x.wave.clusters().map(x => if x not in utility.lists.all { "/" } else { x }).join()
    }

    x
  })

  // get the wave width. When set to 'auto' largest wave is used.
  let wave-width = if wave-width == auto { calc.max(..data.signal.map(x => x.at("wave", default: "").len())) } else {
    wave-width
  }

  // update inset-1 and inset-2 to actual values
  config.inset-1 = float(config.inset-1 * config.symbol-width)
  config.inset-2 = float(config.inset-2 * config.symbol-width)
  tick-overshoot = float(tick-overshoot)


  // process waves!
  cetz.canvas(length: size, {
    import cetz.draw: *

    // global stroke styling
    set-style(stroke: config.stroke)


    scale(y: -1, x: config.symbol-width)

    // draw the tick lines and labels if respectively enabled
    if config.show-tick-lines or config.ticks-format != none {
      // drawing lines
      for i in range(wave-width + 1) {
        if config.show-tick-lines {
          line(
            (i, -(tick-overshoot)),
            (
              i,
              data.signal.len() * (config.wave-height)
                + data.signal.filter(x => x != (:)).len() * (config.wave-gutter)
                - config.wave-gutter
                + (tick-overshoot),
            ),
            stroke: config.stroke-tick-lines,
          )
        }

        // drawing tick labels
        if config.ticks-format != none {
          content((i, -(tick-overshoot)), anchor: "south", padding: (bottom: 0.2), (config.ticks-format)(i))
        }
      }
    }

    // go through each element in the 'signal' chunk of the data
    for (i, signal) in data.signal.enumerate() {
      if signal != (:) {
        // preprocess the wave symbols
        // -> merge specific characters together (i.e. "xxx" -> "x..")
        // -> split different symbol groups (i.e. "xx01" -> ("x.","0","1"))
        // -> if c is "." or "|" -> add it to the previous group instead of the current one
        let groups = ()
        for (i, c) in signal.wave.clusters().enumerate() {
          if c in (".", "|") and i > 0 {
            groups.at(-1) += c
          } else if c in (utility.lists.merge-chars) and groups.at(-1, default: (none,)).first() == c {
            groups.at(-1) += "."
          } else {
            groups += (c,)
          }
        }

        // draw wave name
        if "name" in signal.keys() and config.name-format != none {
          content((0, config.wave-height / 2), anchor: "east", padding: (right: config.name-gutter), (
            config.name-format
          )(signal.name))
        }

        // if enabled, draw the horizontal lines at each wave bottom and top
        if config.show-guides {
          line(
            (0, 0),
            (wave-width, 0),
            stroke: config.stroke-guides,
          )
          line(
            (0, config.wave-height),
            (wave-width, config.wave-height),
            stroke: config.stroke-guides,
          )
        }


        let data-pos = ()
        let s-pos = ()
        let pos = 0
        let data-idx = 0

        scope({
          // the scope is used to invert the y-axis for easier drawing
          translate(y: config.wave-height)
          scale(y: -config.wave-height)

          let last = none
          let length = 0
          for (current, prev, next) in groups.zip(((none,),) + groups.slice(0, -1), (groups.slice(1) + ((none,),))) {
            length += current.len()
            let difference = length - wave-width
            if difference > 0 { next = (none,) }

            // [4] --------------------------------------------
            if current == "|" and prev != "|" { last = prev }
            let current = if difference > 0 { current.slice(0, difference) } else { current }

            // draw element
            (objects.at(lower(current.first()), default: objects.default))(
              current,
              if current == "|" { last } else { prev },
              next,
              config,
            )

            // render the double s where necessary
            let double-s-pos = current.matches("|").map(x => x.start)
            if double-s-pos != () {
              //s-pos += double-s-pos.map(x => pos + x)
              on-layer(1, {
                utility.draw-timeskippers(config.s-outside, config.s-spacing, offset: double-s-pos)
              })
            }


            if debug {
              on-layer(1, {
                line(
                  (0, -config.debug-offset),
                  (current.len(), -config.debug-offset),
                  mark: config.mark-debug-line,
                  stroke: config.stroke-debug-line,
                )
                for (i, c) in current.clusters().enumerate() {
                  content((i + 0.5, -config.debug-offset), (config.debug-format)(c))
                }
              })
            }

            // offset the x-axis for the next symbol group
            translate(x: current.len())

            if signal.at("data", default: none) != none {
              if current.first() in (..utility.lists.buses-labelable,) and data-idx < signal.data.len() {
                let start = (
                  pos
                    + if lower(prev.first()) in (lower(none),) {
                      0
                    } else if lower(prev.first()) in ("z",) {
                      config.inset-1 + config.inset-2 / 2
                    } else {
                      config.inset-1 + config.inset-2 
                    }
                )
                let end = {
                  (
                    pos
                      + current.len()
                      + if lower(next.first()) in (lower(none),"l","p","h","n") {
                        0
                      } else {
                        config.inset-1
                      }
                  )
                }


                data-pos += (
                  (
                    start: start,
                    end: end,
                    data: signal.data.at(data-idx),
                  ),
                )
                data-idx += 1
              }
              pos += current.len()
            }

            if length >= wave-width {
              break
            }
          }

          translate(x: -signal.wave.len())

          for data in data-pos {
            if debug {
              set-style(mark: (symbol: ">", fill: red, stroke: red + 1pt), scale: config.mark-scale)

              line((data.start, 0.5), (data.end, 0.5), mark: none, stroke: (
                dash: "densely-dotted",
                paint: gray,
                thickness: 0.5pt,
              ))
              mark((data.end, 0.5), (data.end, 0))
              mark((data.start, 0.5), (data.start, 1), stroke: olive, fill: olive)
              mark(
                ((data.start + data.end) / 2, 0.5),
                (data.end, 0.1),
                stroke: orange,
                fill: orange,
                symbol: "o",
                anchor: "center",
                scale: config.mark-scale * 0.5,
              )
            }

            if config.data-format != none {
              content(((data.start + data.end) / 2, 0.5), anchor: "center", (config.data-format)(data.data))
            }
          }

          if s-pos != () {
            utility.draw-timeskippers(config.s-outside, config.s-spacing, offset: s-pos)
          }
        })

        // place labels where needed
      }

      translate(y: config.wave-height + if signal != (:) { config.wave-gutter })
    }
  })
}

