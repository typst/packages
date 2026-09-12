#import "./_tableau-icons-ref.typ" as tbl-ref


#let package-info = toml("./typst.toml")

/// When citing this package you can use this constant to display the current tabler icon set version.
///
/// ```example
/// #ti-icons-version
/// ```
///
#let ti-icons-version = tbl-ref.ti-icons-version

/// When citing this package you can use this constant to display the current package version.
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
  /// The `ti-icon` function is a wrapper function over the `text` function and thus supports all the parameter of `text`.
  /// 
  /// ```example
  /// #ti-icon("bowling")
  /// #ti-icon("bowling", fill: red)
  /// #ti-icon("bowling", fill: blue)
  /// #ti-icon("bowling", fill: olive)
  /// #ti-icon("bowling", fill: purple)
  /// ```
  ///
  /// ```example
  /// #set text(10pt)
  /// #ti-icon("bowling")
  /// #ti-icon("bowling", 2em)
  /// #ti-icon("bowling", 3em)
  /// #ti-icon("bowling", 4em)
  /// ```
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
  /// ```example
  /// #ti-icon("walk")
  /// #ti-icon("cat",  baseline: -0.3em)
  /// #ti-icon("dog",  baseline:  0.3em)
  /// #ti-icon("moon", baseline:  -2em)
  /// #ti-icon("building-tunnel", baseline:  2em)
  /// ```
  /// 
  /// 
  /// 
  /// -> arguments
  ..args,
) = text(
  font: "tabler-icons",
  tbl-ref.tabler-icons-unicode.at(name),
  ..args,
)

