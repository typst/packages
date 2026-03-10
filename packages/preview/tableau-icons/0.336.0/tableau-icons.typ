#import "./_tableau-icons-ref.typ" as tbl-ref


#let package-info = toml("./typst.toml")

/// When citing this package you can use this constant to display the current tabler icon set version (which is #raw(str(tableau-icons.ti-icons-version))).
/// 
/// ```example
/// #ti-icons-version
/// ```
/// 
#let ti-icons-version = tbl-ref.ti-icons-version

/// When citing this package you can use this constant to display the current package version (which is #raw(str(tableau-icons.ti-pkg-version))).
/// 
/// ```example
/// #ti-pkg-version
/// ```
/// 
#let ti-pkg-version = package-info.package.version

/// To draw the icons, this function can be used. `ti-icon` draws the icon as a text, meaning every text-related rule also affects this library's output! 
/// 
///  
/// -> content
#let ti-icon(
  /// #show link: underline
  ///  The name of the icon. Search the icon's label on #link("https://tabler.io/icons")[https://tabler.io/icons] and copy it. Attach "`-filled`" to get the filled version of the icon if available.
  /// 
  /// ```example
  /// #ti-icon("flag-3")
  /// #ti-icon("flag-3-filled")
  /// #ti-icon("lock-check")
  /// #ti-icon("cat")
  /// #ti-icon("photo-spark")
  /// #ti-icon("world-check")
  /// ```
  /// 
  /// -> string
  name,
  /// Color of the icon.
  /// 
  /// ```example
  /// #ti-icon("bowling")
  /// #ti-icon("bowling", fill: red)
  /// #ti-icon("bowling", fill: blue)
  /// #ti-icon("bowling", fill: olive)
  /// #ti-icon("bowling", fill: purple)
  /// ```
  /// 
  /// If no colour is given, the colour is defaulted to the text's currently assigned colour (which defaults to black).
  /// 
  /// ```example
  /// #set text(blue)
  /// #ti-icon("cheese")
  /// #ti-icon("pepper")
  /// #set text(red)
  /// #ti-icon("flag-check")
  /// #ti-icon("flag")
  /// ```
  /// 
  /// -> color
  fill: auto,
  /// Size of the icon (equivalent to font size)
  /// 
  /// ```example
  /// #ti-icon("book-2", size: 0.5em)
  /// #ti-icon("carrot")
  /// #ti-icon("cat", size: 1.5em) 
  /// ```
  /// 
  /// -> length
  size: 1em,
  /// The `baseline` parameter offsets the icon from its paragraph placement. It's the text's element baseline 
  /// 
  /// ```example
  ///   #ti-icon("walk")
  ///   #ti-icon("cat",       baseline: -0.3em)
  ///   #ti-icon("dog",       baseline:  0.3em)
  ///   #ti-icon("moon",       baseline:  -2em)
  /// 
  /// ```
  /// -> length
  baseline: 0pt,
  /// -> arguments
  ..args

  ) = context{
  if (type(name) != str) {
    panic("icon name is not a string")
  }

  

  text(
    top-edge: "ascender",
    bottom-edge: "descender",
    font: "tabler-icons",
    size: size,
    baseline: baseline,
    fill: if fill == auto {text.fill}else{fill},
    tbl-ref.tabler-icons-unicode.at(name),
    ..args,
  )
}
