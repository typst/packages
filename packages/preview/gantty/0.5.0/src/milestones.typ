#import "@preview/cetz:0.4.2"
#import "util.typ": EPSILON, content-if-fits, rects-intersect

#let _text-color-from-style(style) = {
  if style.keys().contains("stroke") and style.stroke.keys().contains("paint") {
    style.stroke.paint
  } else {
    black
  }
}

#let _milestone-today(milestone) = {
  milestone.x.gantty.today
}

#let _milestone-show-date(milestone) = {
  milestone.x.gantty.show-date
}

/// The default formatter for milestone content
/// -> content
#let default-milestone-content(
  /// The milestone to format.
  /// -> milestone
  milestone,
) = {
  let today = _milestone-today(milestone)
  let show-date = _milestone-show-date(milestone)
  block(inset: 5pt, align(center)[
    #strong(milestone.name)#if not today and show-date {
      linebreak()
      milestone.date.display("[month repr:short] [day]")
    }
  ])
}

/// The default formatter for the today milestone.
/// -> content
#let default-today-content(
  /// The date to format.
  /// -> datetime
  date,
  /// Localized version of today
  localized-name: "Today",
) = {
  block(inset: 5pt, align(center)[
    *#localized-name*
  ])
}

/// The default drawer for milestones.
/// -> cetz
#let default-milestones-drawer(
  /// The gantt chart.
  /// -> gantt
  gantt,
  /// The 'overhang' of the milestones at the bottom.
  /// -> length
  overhang: 5pt,
  /// The style of the milestone line.
  /// -> style
  style: (stroke: (paint: black, thickness: 1pt)),
  /// The style of the today milestone.
  /// -> style
  today-style: (stroke: (paint: red, thickness: 1pt)),
  /// The formatter for the milestone's content.
  ///
  /// Should be a function of `milestone -> content`
  /// -> function
  milestone-content: default-milestone-content,
  /// The formatter for the today milestone
  ///
  /// Should be a function of `datetime -> content` or `none` to disable showing
  /// today.
  /// -> none | function
  today-content: default-today-content,
) = {
  import cetz.draw: *
  import cetz.coordinate: resolve
  import cetz.util: resolve-number

  let date-range = (gantt.end - gantt.start)

  let milestones = gantt.milestones

  if (
    today-content != none
      and gantt.start <= datetime.today()
      and datetime.today() <= gantt.end
  ) {
    milestones.push((date: datetime.today(), x: (gantty: (today: true))))
  }

  get-ctx(ctx => {
    let used-rects = ()
    let rect-start = resolve(ctx, "field.north-west").at(1)
    let rect-end = resolve(ctx, "field.south-east").at(1)
    let overhang = resolve-number(ctx, overhang)

    for milestone in milestones {
      let date = milestone.date
      let fract-x = (date - gantt.start) / date-range
      let x = rect-start.at(0) + fract-x * (rect-end.at(0) - rect-start.at(0))

      let style = if _milestone-today(milestone) {
        today-style
      } else {
        style
      }

      let repr = {
        set text(_text-color-from-style(style))
        if _milestone-today(milestone) {
          today-content(milestone)
        } else {
          milestone-content(milestone)
        }
      }

      let coord = (x, rect-end.at(1) - overhang)
      let size = measure(repr)
      let size = (
        width: resolve-number(ctx, size.width),
        height: resolve-number(ctx, size.height),
      )
      let our-rect = (
        x: coord.at(0) - size.width / 2,
        y: coord.at(1),
        ..size,
      )
      let again = true
      let loop_count = 0
      while again {
        again = false
        for used-rect in used-rects {
          if rects-intersect(used-rect, our-rect) {
            /// XXX: An epsilon is needed to prevent this becoming an infinite
            //       loop owing to floating point imprecision
            our-rect.y = used-rect.y - used-rect.height - EPSILON
            again = true
            break
          }
        }
        loop_count += 1
      }

      coord.at(1) = our-rect.y

      used-rects.push(our-rect)

      line((x, rect-start.at(1)), coord, ..style)
      content(coord, repr, anchor: "north")
    }
  })
}
