#import "@preview/cetz:0.4.2"
#import "drawers.typ": default-drawer
#import "normalize.typ": normalize-gantt


/// Renders a gantt chart.
/// -> content
#let gantt(
  /// A gantt chart specifier.
  /// -> dictionary
  gantt,
  /// The drawer (see the #link(<drawers>)[Drawers] section)
  /// -> dictionary
  drawer: default-drawer,
) = (
  context {
    let gantt = normalize-gantt(gantt)

    layout(size => {
      cetz.canvas(length: size.width, {
        import cetz.draw: *
        set-style(stroke: none)

        (drawer.sidebar)(gantt)
        (drawer.field)(gantt)
        (drawer.headers)(gantt)
        (drawer.dividers)(gantt)
        (drawer.tasks)(gantt)
        (drawer.dependencies)(gantt)
        (drawer.field)(gantt)
        (drawer.milestones)(gantt)
      })
    })
  }
)
