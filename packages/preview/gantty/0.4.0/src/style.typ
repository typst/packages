
/// The default style used for a gantt chart.
///
/// It is currently:
///
/// #gantty.default-style
#let default-style = (
  sidebar: (
    spacing: 10pt,
    padding: 5pt,
  ),
  milestones: (
    normal: (stroke: (paint: black, thickness: 1pt)),
    today: (stroke: (paint: red, thickness: 1pt)),
  ),
  gridlines: (
    table: (stroke: black, thickness: 1pt),
    task-dividers: (stroke: (paint: luma(66%), thickness: 0.5pt)),
    years: (stroke: (paint: luma(66%), thickness: 1pt)),
    months: (stroke: (paint: luma(66%), thickness: 0.7pt)),
    weeks: (stroke: (paint: luma(66%), thickness: 0.2pt)),
    days: (stroke: (paint: luma(66%), thickness: 0.1pt)),
  ),
  groups: (
    uncompleted: (stroke: (paint: black, thickness: 3pt)),
    completed-early: (
      timeframe: (stroke: (paint: olive, thickness: 3pt)),
      body: (stroke: (paint: black, thickness: 3pt)),
    ),
    completed-late: (
      timeframe: (stroke: (paint: orange, thickness: 3pt)),
      body: (stroke: (paint: black, thickness: 3pt)),
    ),
  ),
  tasks: (
    uncompleted: (stroke: (paint: luma(33%), thickness: 2pt)),
    completed-early: (
      timeframe: (stroke: (paint: olive, thickness: 2pt)),
      body: (stroke: (paint: luma(33%), thickness: 2pt)),
    ),
    completed-late: (
      timeframe: (stroke: (paint: orange, thickness: 2pt)),
      body: (stroke: (paint: luma(33%), thickness: 2pt)),
    ),
  ),
)

