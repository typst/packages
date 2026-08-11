#import "colors.typ": colors
#import "typography.typ"
#import "utils.typ": *
#import "tech-icons.typ": tech-icon, tech-icons
#import "timeline-state.typ": *

#let header(
  firstname,
  lastname,
  email: none,
  mobile: none,
  github: none,
  linkedin: none,
  position: none,
) = {
  set align(center)

  typography.name(firstname + " " + lastname)

  if position != none {
    typography.position(position)
    linebreak()
    v(0.4mm)
  }

  v(-2.5em)

  typography.social-entry({
    let items = ()

    if mobile != none {
      items.push(link("tel:" + mobile)[#mobile])
    }
    if email != none {
      items.push(link("mailto:" + email)[#email])
    }
    if github != none {
      items.push(link("https://github.com/" + github)[#github])
    }
    if linkedin != none {
      items.push(link("https://www.linkedin.com/in/" + linkedin)[#linkedin])
    }

    items.join("   |   ")
  })
}

#let section(title) = {
  v(0.5em)

  let title-str = if type(title) == str { title } else { str(title) }
  let first-three = title-str.slice(0, calc.min(3, title-str.len()))
  let rest = if title-str.len() > 3 { title-str.slice(3) } else { "" }

  let colored-title = [
    #text(fill: colors.awesome)[#first-three]#text(fill: black)[#rest]
  ]

  grid(
    columns: (auto, 1fr),
    column-gutter: 0.5em,
    align: (left, bottom),
    typography.section(colored-title),
    place(dy: 1.25em, line(length: 100%, stroke: 0.9pt + colors.gray)),
  )
  v(0em)
}

#let employer-info(
  name: "",
  duration: "",
  content,
) = {
  block({
    set align(horizon)
    stack(
      dir: ltr,
      spacing: 0.5em,
      {
          box(
            width: 2.5em,
            align(
              left + horizon,
              if content == none {
                square(width: 2.5em, fill: colors.lightgray.lighten(80%), radius: 0.5em)
              } else {
                content
              }
            )
          )
          h(0.5em)
      },
      stack(
        dir: ttb,
        spacing: 0.5em,
        {
          typography.org(name)
          linebreak()
          typography.duration(time-in-company(..duration))
        }
        )
    )
    v(1.5em)
  })
}

#let workstream(title: "", tech-stack: ()) = {
  grid(
    columns: (1fr, auto),
    align: (left, right + horizon),
    typography.workstream(title),
    if tech-stack.len() > 0 {
      tech-icons(tech-stack, size: 0.66em, spacing: 2pt)
    }
  )
  v(0em)
}

#let linkedin-job(
  title: "",
  date-range: "",
  description,
  company-id: none,
) = {
  let dot-radius = 1mm
  let dot-offset = 3.66mm
  let timeline-width = 0.33mm

  if company-id != none {
    timeline-state.update(s => {
      if company-id in s {
        s.at(company-id).current-position += 1
      }
      s
    })
  }

  let job-content = pad(
    left: 0mm,
    {
      grid(
        columns: (1fr, auto),
        align: (left, right),
        typography.project(title),
        entry-date(date-range)
      )

      v(-0.5em)

      typography.description(description)

      v(1em)
    }
  )

  let content-with-title = {
    grid(
      columns: (1fr, auto),
      align: (left, right),
      typography.project(title),
      typography.date(date-range)
    )
    v(-0.5em)
    typography.description(description)
  }

  block(
    breakable: true,
    {
      if company-id != none {
        context {
          let state-val = timeline-state.get()
          if company-id in state-val {
            let company-data = state-val.at(company-id)
            let measured = measure(job-content)
            place(
              top + left,
              dy: 0em,
              text(size: 6pt, fill: red)[
                [#company-data.current-position/#company-data.num-positions h=#measured.height]
              ]
            )
          }
        }
      }

      place(
        dx: -dot-offset - dot-radius,
        dy: 0.16em,
        circle(
          radius: dot-radius,
          stroke: 1.5pt + white,
          fill: colors.lightgray
        )
      )

      if company-id != none {
        context {
          let state-val = timeline-state.get()
          if company-id in state-val {
            let company-data = state-val.at(company-id)
            let current-pos = company-data.current-position
            let total = company-data.num-positions

            if current-pos < total {
              let full-content-size = measure(job-content)
              let full-height = full-content-size.height

              let spacing-offset = if full-height < 100pt {
                18pt
              } else {
                0pt
              }

              let line-height = full-height + 0.16em + spacing-offset - 2 * dot-radius

              place(
                dx: .5pt - dot-offset - timeline-width / 2,
                line(
                  start: (0pt, 0pt),
                  end: (0pt, line-height),
                  stroke: timeline-width + colors.lightgray.lighten(40%)
                )
              )
            }
          }
        }
      }

      job-content
    }
  )
}

#let linkedin-history(
  num-positions: 1,
  company-id: none,
  content,
) = {
  if company-id != none {
    init-company-timeline(company-id, num-positions: num-positions)
  }

  block(
    breakable: true,
    inset: (left: 8.5mm, right: 0mm, top: 0mm, bottom: 0mm),
    {
      content
      v(0.5em)
    }
  )
}

#let qualification(name, grade, date, institution) = {
  (
    text(size: 8pt, fill: colors.graytext, name),
    text(size: 8pt, style: "italic", fill: colors.graytext, grade),
    text(size: 8pt, style: "italic", fill: colors.graytext, date),
    text(size: 9pt, fill: colors.awesome, institution),
  )
}
