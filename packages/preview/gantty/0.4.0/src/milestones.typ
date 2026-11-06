#import "@preview/cetz:0.4.1"
#import "util.typ": EPSILON, content-if-fits, gantt-range, rects-intersect

#let draw-milestones(gantt, overhang: 5pt) = {
  import cetz.draw: *
  import cetz.coordinate: resolve
  import cetz.util: resolve-number

  let (start, end, end-m1) = gantt-range(gantt)
  let date-range = (end - start)

  get-ctx(ctx => {
    let used-rects = ()
    let rect-start = resolve(ctx, "bars.north-west").at(1)
    let rect-end = resolve(ctx, "bars.south-east").at(1)
    let overhang = resolve-number(ctx, overhang)

    for milestone in gantt.milestones {
      let today = milestone.at("today", default: false)
      let date = milestone.date
      let fract-x = (date - start) / (end - start)
      let x = rect-start.at(0) + fract-x * (rect-end.at(0) - rect-start.at(0))

      let style = if today {
        gantt.style.milestones.today
      } else {
        gantt.style.milestones.normal
      }

      let repr = block(inset: 5pt, align(center)[
        #set text(style.stroke.paint)
        #strong(milestone.name)#if not today {
          linebreak()
          date.display("[month repr:short] [day]")
        }
      ])

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
