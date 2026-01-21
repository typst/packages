#import "colours.typ": colours, get-accent-colour
#import "timeline-state.typ": *
#import "typography.typ"
#import "utils.typ": parse-date

#let TOP-PADDING = -10pt

#let format-duration(start, end) = {
  let months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  let start-date = parse-date(start)
  let start-month = months.at(start-date.at(0) - 1)
  let start-year = str(start-date.at(1))

  let end-str = if end == "current" {
    "current"
  } else {
    let end-date = parse-date(end)
    let end-month = months.at(end-date.at(0) - 1)
    str(end-month) + " " + str(end-date.at(1))
  }

  start-month + " " + start-year + " — " + end-str
}

#let timeline-frame(
  title: none,
  duration: none,
  group-id: none,
  body,
) = {
  let dot-radius = 3pt
  let dot-offset = 3.66mm
  let border-width = .5pt
  let border-color = colours.lightgray

  if group-id != none {
    timeline-state.update(s => {
      if group-id in s {
        s.at(group-id).current-position += 1
      }
      s
    })
  }

  let frame-content = context {
    let should-show-stroke = true
    if group-id != none {
      let state-val = timeline-state.get()
      if group-id in state-val {
        let group-data = state-val.at(group-id)
        let current-pos = group-data.current-position
        let total = group-data.num-positions
        should-show-stroke = current-pos < total
      }
    }

    block(
      width: 100%,
      breakable: true,
      stroke: if should-show-stroke { (left: border-width + border-color) } else { none },
      inset: (
        left: 12pt,
        right: 0pt,
        top: 0pt,
        bottom: 0pt,
      ),
      radius: if should-show-stroke { (right: 2pt) } else { 0pt },
      {
        v(TOP-PADDING)

        if title != none {
          let title-content = if duration != none {
            stack(
              dir: ltr,
              typography.workstream(title),
              h(1fr),
              align(right + horizon, typography.duration(format-duration(duration.at(0), duration.at(1))))
            )
          } else {
            title
          }

          text(
            weight: "semibold",
            size: 11pt,
            fill: black,
            title-content
          )
          v(-0.5em)
        }

        text(
          size: 10pt,
          fill: colours.darktext,
          body
        )

        v(2.5em)
      }
    )
  }

  if group-id != none {
    context {
      let state-val = timeline-state.get()
      let group-data = state-val.at(group-id, default: none)
      let current-pos = if group-data != none { group-data.current-position } else { 0 }
      let total = if group-data != none { group-data.num-positions } else { 0 }
      let draw-line = current-pos < total

      block(
        breakable: true,
        {
          place(
            dx: -dot-radius,
            dy: TOP-PADDING + dot-radius / 2,
            circle(
              radius: dot-radius,
              stroke: 2.5pt + white,
              fill: colours.lightgray
            )
          )

          if draw-line {
            let content-size = measure(frame-content)
            let full-height = content-size.height

            let spacing-offset = if full-height < 100pt { 18pt } else { 0pt }

            let line-height = full-height + 10pt + spacing-offset - 2 * dot-radius - 10pt
          }

          frame-content
        }
      )
    }
  } else {
    block(
      breakable: true,
      {
        place(
          dx: -12pt - dot-radius,
          dy: 10pt + 5.5pt,
          circle(
            radius: dot-radius,
            stroke: 1.5pt + white,
            fill: border-color
          )
        )

        frame-content
      }
    )
  }
}

#let frame-group(
  num-frames: 1,
  group-id: none,
  content,
) = {
  if group-id != none {
    init-company-timeline(group-id, num-positions: num-frames)
  }

  block(
    breakable: true,
    inset: (left: 1.5em, right: 0mm, top: 0mm, bottom: 0mm),
    content
  )
}

#let connected-frames(
  group-id,
  ..frames
) = {
  let frame-list = frames.pos()

  frame-group(
    num-frames: frame-list.len(),
    group-id: group-id,
  )[
    #for (idx, frame-data) in frame-list.enumerate() {
      if type(frame-data) == dictionary {
        timeline-frame(
          title: frame-data.at("title", default: none),
          duration: frame-data.at("duration", default: none),
          group-id: group-id,
          frame-data.body
        )
      } else {
        timeline-frame(
          group-id: group-id,
          frame-data
        )
      }
    }
  ]
}
