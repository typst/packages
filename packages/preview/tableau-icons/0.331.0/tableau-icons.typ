#import "./_tableau-icons-ref.typ" as tbl-ref


#let package-info = toml("./typst.toml")

#let tabler-icons-version = tbl-ref.tabler-icons-version
#let package-version = package-info.package.version


/// The `draw-icon` function takes a `name` argument to render it's respective Tabler.io icon.
/// 
/// ```example
/// This is an icon #draw-icon("function", fill: red, baseline: 15%) and another one #draw-icon("bowling", fill: olive, baseline: 15%) and finally this one #draw-icon("dog", fill: blue, baseline: 15%).
/// ```
/// 
/// The icon is contained inside the box specified by the `width` and `height` arguments. Meaning, the square aspect ratio of the icon is kept and cannot be skewed.
/// 
/// 
/// ```example
/// #let border = color.lighten(gray, 40%)
/// #box(stroke: border, draw-icon("ball-tennis", fill: red, height: 3em, width: 5em))
/// #box(stroke: border, draw-icon("trees", fill: olive, height: 4em))
/// #box(stroke: border, draw-icon("dog", fill: blue, height: 5em, width: 3em))
/// ```
/// -> string
#let draw-icon(
  /// Name of the icon. Search the icon on #text(blue,underline(link("https://tabler.io/icons"))) and copy the label. Attach `-filled` to get the filled version of the icon.
  /// 
  /// #import "@preview/shadowed:0.2.0": shadowed
  /// #import "@preview/tableau-icons:0.331.0": *

  /// #grid(columns: (1fr, 1fr))[
  ///    #shadowed(radius: 4pt, color: color.lighten(black, 50%))[
  ///      ```typst
  ///      #draw-icon("flag-3")
  ///      #draw-icon("flag-3-filled")
  ///      #draw-icon("lock-check")
  ///      #draw-icon("cat")
  ///      #draw-icon("photo-spark")
  ///      #draw-icon("world-check")
  ///      ```
  ///    ]
  ///  ][
  ///    #set align(center+horizon)
  ///    #shadowed(radius: 4pt, inset: 6pt, color: color.lighten(black, 50%))[
  ///    #set align(left)
  ///      
  ///      #tableau-icons.draw-icon("flag-3", height: 2em)
  ///      #tableau-icons.draw-icon("flag-3-filled", height: 2em)
  ///      #tableau-icons.draw-icon("lock-check", height: 2em)
  ///      #tableau-icons.draw-icon("cat", height: 2em)
  ///      #tableau-icons.draw-icon("photo-spark", height: 2em)
  ///      #tableau-icons.draw-icon("world-check", height: 2em)
  ///      
  ///    ]
  ///  ]
  /// 
  /// -> string
  name,
  /// Configures the color of the icon
  /// 
  /// #import "@preview/shadowed:0.2.0": shadowed
  /// #import "@preview/tableau-icons:0.331.0": *

  /// #grid(columns: (1fr, 1fr))[
  ///    #shadowed(radius: 4pt, color: color.lighten(black, 50%))[
  ///      ```typst
  ///      #draw-icon("bowling")
  ///      #draw-icon("bowling", fill: red)
  ///      #draw-icon("bowling", fill: blue)
  ///      #draw-icon("bowling", fill: olive)
  ///      #draw-icon("bowling", fill: purple)
  ///      ```
  ///    ]
  ///  ][
  ///    #set align(center+horizon)
  ///    #shadowed(radius: 4pt, inset: 6pt, color: color.lighten(black, 50%))[
  ///    #set align(left)
  ///      
  ///      #tableau-icons.draw-icon("bowling" , height: 2em)
  ///      #tableau-icons.draw-icon("bowling", fill: red , height: 2em)
  ///      #tableau-icons.draw-icon("bowling", fill: blue , height: 2em)
  ///      #tableau-icons.draw-icon("bowling", fill: olive , height: 2em)
  ///      #tableau-icons.draw-icon("bowling", fill: purple , height: 2em)
  ///      
  ///    ]
  ///  ]
  /// 
  /// -> color
  fill: black,
  /// Height of the icon
  /// 
  /// #import "@preview/shadowed:0.2.0": shadowed
  /// #import "@preview/tableau-icons:0.331.0": *

  /// #grid(columns: (1fr, 1fr))[
  ///    #shadowed(radius: 4pt, color: color.lighten(black, 50%))[
  ///      ```typst
  ///      #set box(stroke: gray)
  ///      #box(draw-icon("home"))
  ///      #box(draw-icon("home", height: 2em))
  ///      #box(draw-icon("home", height: 4em))
  ///      #box(draw-icon("home", height: 6em))
  ///      ```
  ///    ]
  ///  ][
  ///    #set align(center+horizon)
  ///    #shadowed(radius: 4pt, inset: 6pt, color: color.lighten(black, 50%))[
  ///    #set align(left)
  ///      #set text(1.5em)
  ///      #box(stroke: gray, tableau-icons.draw-icon("home"))
  ///      #box(stroke: gray, tableau-icons.draw-icon("home", height: 2em)) // 3em
  ///      #box(stroke: gray, tableau-icons.draw-icon("home", height: 4em)) // 6em
  ///      #box(stroke: gray, tableau-icons.draw-icon("home", height: 6em)) // 9em
  ///      
  ///    ]
  ///  ]
  /// 
  /// -> length
  height: 1em,
  /// Width of the icon
  /// 
  /// #import "@preview/shadowed:0.2.0": shadowed
  /// #import "@preview/tableau-icons:0.331.0": *

  /// #grid(columns: (1fr, 1fr))[
  ///    #shadowed(radius: 4pt, color: color.lighten(black, 50%))[
  ///      ```typst
  ///      #set box(stroke: gray)
  ///      #box(draw-icon("home"))
  ///      #box(draw-icon("home", width: 2em))
  ///      #box(draw-icon("home", width: 4em))
  ///      #box(draw-icon("home", width: 6em))
  ///      ```
  ///    ]
  ///  ][
  ///    #set align(center+horizon)
  ///    #shadowed(radius: 4pt, inset: 6pt, color: color.lighten(black, 50%))[
  ///    #set align(left)      
  ///      #set text(1.5em)
  ///      #box(stroke: gray, tableau-icons.draw-icon("home"))
  ///      #box(stroke: gray, tableau-icons.draw-icon("home", width: 2em)) // 3em
  ///      #box(stroke: gray, tableau-icons.draw-icon("home", width: 4em)) // 6em
  ///      #box(stroke: gray, tableau-icons.draw-icon("home", width: 6em)) // 9em
  ///    ]
  ///  ]
  /// 
  /// -> length
  width: auto,
  /// Arguments for the box (such as `baseline`), which the icon is encased in.
  /// 
  /// #import "@preview/shadowed:0.2.0": shadowed
  /// #import "@preview/tableau-icons:0.331.0": *

  /// #grid(columns: (1fr, 1fr))[
  ///    #shadowed(radius: 4pt, color: color.lighten(black, 50%))[
  ///      ```typst 
  ///      Hello #draw-icon("planet", baseline: 100%), come up here #draw-icon("flag-filled", baseline: 10%) 
  ///      ```
  ///    ]
  ///  ][
  ///    #set align(center+horizon)
  ///    #shadowed(radius: 4pt, inset: 6pt, color: color.lighten(black, 50%))[
  ///    #set align(left)      
  ///      #set text(1.5em)
  ///      Hello #tableau-icons.draw-icon("planet", baseline: 100%), up here #tableau-icons.draw-icon("flag-filled", baseline: -100%)!
  ///    ]
  ///  ]
  /// 
  /// -> arguments
  ..args) = {
  if (type(name) != str) {
    panic("icon name not set")
  }

  if width == auto {
    width = height
  }


  box(
    height: height,
    width: width,
    align(
      center + horizon,
      if name in tbl-ref.tabler-icons-unicode {
        text(
          bottom-edge: "descender",
          font: "tabler-icons",
          fill: fill,
          size: calc.min(height, width),
          tbl-ref.tabler-icons-unicode.at(name),
        )
      } else {
        text(
          fill: red,
          weight: "bold",
          size: height,
          [X],
        )
      },
    ),
    ..args,
  )
}

