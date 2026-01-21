#import "../_deps.typ": octique, codly

/// Shows an icon from the #github("0x6b/typst-octique") package.
/// -> content
#let icon(
  /// - name: A name from the Octique icon set.
  /// -> str
  name,
  /// - fill: The fill color for the icon. #value(auto) will use the fill of the surrounding text.
  /// -> color | auto
  fill: auto,
  /// - ..args: Further args for the #cmd[octique] command.
  /// -> any
  ..args,
) = context {
  octique.octique-inline(
    name,
    color: if fill == auto { text.fill } else { fill },
    baseline: 10%,
    ..args,
  )
}

/// The default info icon: #icons.info
#let info = icon("info")

/// The default info icon: #icons.warning
#let warning = icon("alert-fill")


/// Typst icon provided by #universe("codly"): #icons.typst
#let typst = codly.typst-icon.typ.icon
