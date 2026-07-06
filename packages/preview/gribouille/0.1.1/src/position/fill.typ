///! Fill position adjustment.

#import "_cumulate.typ": cumulate-by-x
#import "../utils/radial.typ": is-radial

/// Fill position adjustment: stack and normalise each x bucket to sum = 1.
///
/// Typically set on a layer as `position: "fill"` rather than constructed
/// directly; the constructor exists for symmetry with the other positions.
///
/// \@category Positions
/// \@stability stable
/// \@since 0.0.1
///
/// \@returns Position dictionary with `name: "fill"`, consumed by \@plot.
///
/// \@examples Stacked bars normalised so each quarter sums to one, useful
/// for showing share of total.
/// ```
/// //| alt: "Stacked bar chart with three quarters on the x-axis and proportions from 0 to 1 on the y-axis; each bar splits into two coloured segments summing to the full height."
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 7),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 6),
///   (q: "Q3", grp: "a", y: 5),
///   (q: "Q3", grp: "b", y: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: "fill"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Compare with \@position-stack to show the same data in
/// absolute counts instead of proportions.
/// ```
/// //| alt: "Stacked bar chart with three quarters on the x-axis and absolute counts on the y-axis; each bar splits into two coloured segments showing component contributions."
/// #let d = (
///   (q: "Q1", grp: "a", y: 3), (q: "Q1", grp: "b", y: 7),
///   (q: "Q2", grp: "a", y: 4), (q: "Q2", grp: "b", y: 6),
///   (q: "Q3", grp: "a", y: 5), (q: "Q3", grp: "b", y: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: "stack"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@position-stack, \@position-dodge, \@position-identity
#let position-fill() = (kind: "position", name: "fill")

#let apply(data, mapping, params: (:), coord: none) = {
  let slice = if is-radial(coord) {
    (cum, yv, tot) => {
      let t = if tot == 0 { 1.0 } else { tot }
      (cum / t, (cum + yv) / t)
    }
  } else {
    (cum, yv, tot) => {
      let t = if tot == 0 { 1.0 } else { tot }
      ((tot - cum - yv) / t, (tot - cum) / t)
    }
  }
  cumulate-by-x(data, mapping, slice)
}
