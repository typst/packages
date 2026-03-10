/// A box that fills the available space with spaces
///
/// -> content
#let fill(width: 1fr) = box(width: width, repeat(sym.space.nobreak))

/// Fill the available space with an underline
///
/// -> content
#let uline(width: 1fr) = underline(fill(width: width))
// #let uline(width: 1fr) = box(width: width, line(length: 100%))

/// A horizontal line that stretches across the page
///
/// -> content
#let hline(stroke: 1pt) = line(length: 100%, stroke: stroke)

/// The horizontal line at the top of a three-part table
///
/// -> content
#let toprule = table.hline(stroke: 0.08em)

/// The horizontal line under the first row of a three-part table
///
/// -> content
#let midrule = table.hline(stroke: 0.05em)

/// The horizontal line at the bottom of a three-part table
///
/// -> content
#let bottomrule = toprule
