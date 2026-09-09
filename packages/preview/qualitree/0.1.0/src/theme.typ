// Shared visual defaults; callers can override individual drawing arguments.
#let qfd-theme = (
  font: ("IBM Plex Sans", "New Computer Modern"),
  serif-font: ("IBM Plex Serif", "Libertinus Serif"),
  font-size: 9pt, ink: rgb("20252A"),
  grid-thickness: 0.35pt, frame-thickness: 0.7pt,
  symbol-size: 7pt, symbol-thickness: 1.1pt,
  added-fill: rgb("E4F2E5"), removed-fill: rgb("F8E3E3"),
  changed-fill: rgb("FFF2CE"),
)

// Five source-palette styles. Additional alternatives cycle these defaults;
// callers can provide explicit color, marker, dash, and thickness per series.
#let qfd-palette = (
  (color: rgb("0072B2"), marker: "circle", dash: "solid", thickness: 1.2pt, marker-size: 6.5pt, marker-thickness: 1.1pt, fill-lighten: 45%),
  (color: rgb("D55E00"), marker: "triangle", dash: "dashed", thickness: 0.8pt, marker-size: 7pt, marker-thickness: 0.9pt, fill-lighten: 45%),
  (color: rgb("009E73"), marker: "square", dash: "dotted", thickness: 0.8pt, marker-size: 5.5pt, marker-thickness: 0.9pt, fill-lighten: 45%),
  (color: rgb("CC79A7"), marker: "diamond", dash: "dash-dotted", thickness: 0.8pt, marker-size: 7pt, marker-thickness: 1pt, fill-lighten: 50%),
  (color: rgb("56B4E9"), marker: "pentagon", dash: (4pt, 2pt, 0.8pt, 2pt, 0.8pt, 2pt), thickness: 0.7pt, marker-size: 5.5pt, marker-thickness: 0.8pt, fill-lighten: 60%),
)

