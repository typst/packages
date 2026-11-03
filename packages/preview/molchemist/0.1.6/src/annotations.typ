// Public annotation descriptors; drawing is handled by annotation-renderer.typ.

/// Create a free arrow overlay drawn after the molecule.
///
/// - from (any): Source anchor or CeTZ coordinate.
/// - to (any): Destination anchor or CeTZ coordinate.
/// - label (content, none): Optional content placed near the arrow midpoint.
/// - from-anchor (str): Anchor used when `from` is a named object.
/// - to-anchor (str): Anchor used when `to` is a named object.
/// - label-anchor (str): CeTZ anchor used to place the label.
/// - label-offset (array): Relative label offset from the arrow midpoint.
/// - mark (any): CeTZ line mark configuration.
/// - stroke (any): CeTZ stroke configuration.
/// - boxed (bool): Whether to draw a background box around the label.
/// - label-size (length): Label text size.
/// - label-fill (any): Label box fill.
/// - label-stroke (any): Label box stroke.
/// - label-inset (any): Label box inset.
/// - label-radius (length): Label box corner radius.
/// - name (str, none): Optional CeTZ object name.
/// -> dictionary
#let arrow-annotation(
  from,
  to,
  label: none,
  from-anchor: "mid",
  to-anchor: "mid",
  label-anchor: "south",
  label-offset: (0, 0.45),
  mark: (end: ">>", fill: black),
  stroke: black,
  boxed: false,
  label-size: 0.85em,
  label-fill: white,
  label-stroke: 0.35pt + luma(72%),
  label-inset: 2pt,
  label-radius: 2pt,
  name: none,
) = (
  type: "arrow",
  from: from,
  to: to,
  label: label,
  from-anchor: from-anchor,
  to-anchor: to-anchor,
  label-anchor: label-anchor,
  label-offset: label-offset,
  mark: mark,
  stroke: stroke,
  boxed: boxed,
  label-size: label-size,
  label-fill: label-fill,
  label-stroke: label-stroke,
  label-inset: label-inset,
  label-radius: label-radius,
  name: name,
)

/// Create a free text label without a leader line.
///
/// - at (any): Target anchor or CeTZ coordinate.
/// - label (content): Label content.
/// - anchor (str): Anchor used to resolve `at`.
/// - label-anchor (str): CeTZ anchor used to place the label.
/// - offset (array): Relative offset from the target.
/// - boxed (bool): Whether to draw a background box around the label.
/// - label-size (length): Label text size.
/// - label-fill (any): Label box fill.
/// - label-stroke (any): Label box stroke.
/// - label-inset (any): Label box inset.
/// - label-radius (length): Label box corner radius.
/// - name (str, none): Optional CeTZ object name.
/// -> dictionary
#let label-annotation(
  at,
  label,
  anchor: "mid",
  label-anchor: "south",
  offset: (0, 0.45),
  boxed: false,
  label-size: 0.85em,
  label-fill: white,
  label-stroke: 0.35pt + luma(72%),
  label-inset: 2pt,
  label-radius: 2pt,
  name: none,
) = (
  type: "label",
  at: at,
  label: label,
  anchor: anchor,
  label-anchor: label-anchor,
  offset: offset,
  boxed: boxed,
  label-size: label-size,
  label-fill: label-fill,
  label-stroke: label-stroke,
  label-inset: label-inset,
  label-radius: label-radius,
  name: name,
)

/// Create an external publication-style label with a leader line.
///
/// Automatic placement uses `side`; explicit CeTZ coordinates can override the
/// label and either end of the leader for final figure adjustments.
///
/// - at (any): Target anchor or CeTZ coordinate.
/// - label (content): Label content.
/// - anchor (str): Anchor used to resolve `at`.
/// - side (str): Placement preset: `"east"`, `"west"`, `"north"`, `"south"`, or a diagonal combination.
/// - label-at (auto, dictionary, str, array): Explicit label coordinate, or `auto`.
/// - label-offset (auto, array): Relative label offset used by automatic placement.
/// - target-offset (auto, array): Relative endpoint offset from the target.
/// - target-gap (int, float): Automatic clearance between the leader and target.
/// - label-anchor (auto, str): CeTZ anchor for the label content.
/// - leader (str): Leader style: `"curve"`, `"straight"`, or `"elbow"`.
/// - leader-start (auto, dictionary, str, array): Explicit leader start coordinate.
/// - leader-end (auto, dictionary, str, array): Explicit leader end coordinate.
/// - leader-points (array): Intermediate CeTZ coordinates for routing the leader.
/// - leader-start-offset (array): Fine adjustment applied to the leader start.
/// - leader-end-offset (array): Fine adjustment applied to the leader end.
/// - mark (any): Optional CeTZ line mark configuration.
/// - stroke (any): CeTZ stroke configuration for the leader.
/// - label-size (length): Label text size.
/// - label-gap (int, float): Clearance between an unboxed label and its leader.
/// - label-inset (any): Label box inset.
/// - label-radius (length): Label box corner radius.
/// - label-fill (any): Label box fill.
/// - label-stroke (any): Label box stroke.
/// - boxed (bool): Whether to draw a background box around the label.
/// - name (str, none): Optional CeTZ object name.
/// -> dictionary
#let callout-annotation(
  at,
  label,
  anchor: "mid",
  side: "north-east",
  label-at: auto,
  label-offset: auto,
  target-offset: auto,
  target-gap: 0.2,
  label-anchor: auto,
  leader: "curve",
  leader-start: auto,
  leader-end: auto,
  leader-points: (),
  leader-start-offset: (0, 0),
  leader-end-offset: (0, 0),
  mark: none,
  stroke: luma(40%) + 0.35pt,
  label-size: 0.82em,
  label-gap: 0.14,
  label-inset: 2.2pt,
  label-radius: 3pt,
  label-fill: white,
  label-stroke: 0.35pt + luma(70%),
  boxed: false,
  name: none,
) = (
  type: "callout",
  at: at,
  label: label,
  anchor: anchor,
  side: side,
  label-at: label-at,
  label-offset: label-offset,
  target-offset: target-offset,
  target-gap: target-gap,
  label-anchor: label-anchor,
  leader: leader,
  leader-start: leader-start,
  leader-end: leader-end,
  leader-points: leader-points,
  leader-start-offset: leader-start-offset,
  leader-end-offset: leader-end-offset,
  mark: mark,
  stroke: stroke,
  label-size: label-size,
  label-gap: label-gap,
  label-inset: label-inset,
  label-radius: label-radius,
  label-fill: label-fill,
  label-stroke: label-stroke,
  boxed: boxed,
  name: name,
)

/// Create an annotation that runs custom CeTZ drawing code.
///
/// - body (function): Function receiving the generated molecule group name.
/// - name (str, none): Optional annotation name retained in the descriptor.
/// -> dictionary
#let cetz-annotation(body, name: none) = (
  type: "cetz",
  body: body,
  name: name,
)
