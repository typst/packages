#import "../styling.typ" as styling
#import "../utils/html.typ": css, span, div, hr, target-choose

#let line-width = 3pt
#let body-inset = 1em
#let text-color(accent-color) = (
  accent-color.mix((text.fill.lighten(80%), 100%)).saturate(60%)
)


#let thmbox-html(title, tags, body, supplement, number, accent-color) = {
  let has-body = body != []
  let has-title = title not in ([], "", none)
  let has-headers = int(has-title) + tags.len() > 0
  let body-only = title == none
  div(
    css(
      border-left: (line-width, "solid", accent-color),
      padding: body-inset,
    ),
    {
      if not body-only {
        context div(
          css(
            ..(
              if has-headers {
                (
                  display: "flex",
                  justify-content: "space-between",
                  align-items: center,
                )
              } else { (:) }
            ),
            color: text-color(accent-color),
          ),
          {
            if has-title {
              div(css(flex: "1.7 1 1", text-align: left), strong(title))
            }
            let is-first = true
            for tag in tags {
              div(css(flex: "1 1 1", text-align: center), tag)
              is-first = false
            }
            div(
              css(
                flex: "1.7 1 1",
                text-align: if has-headers { right } else { left },
              ),
              strong(supplement + " " + number),
            )
          },
        )
      }
      show: styling.dividers-as(
        hr(
          css(
            background: accent-color,
            height: 0.18em,
            border: 0,
            margin: (0, 0, 0, -body-inset),
          ),
        ),
      )
      body
    },
  )
}

// Credits to https://github.com/s15n/typst-thmbox
#let thmbox-paged(title, tags, body, supplement, number, accent-color) = {
  let has-body = body != []
  let has-title = title not in ([], "", none)
  let has-tags = tags.len() > 0
  let has-headers = has-title or has-tags
  let body-only = title == none

  let bar = stroke(paint: accent-color, thickness: line-width)

  show: styling.dividers-as({
    line(
      length: 100% + 1em,
      start: (-1em, 0pt),
      stroke: accent-color + line-width * 0.8,
    )
    v(-0.2em)
  })

  block(
    stroke: (
      left: bar,
    ),
    inset: (
      left: 1em,
      top: 0.6em,
      bottom: 0.6em,
    ),
    spacing: 1.2em,
  )[
    #set align(left)
    // Title bar
    #if not body-only {
      block(
        above: 0em,
        below: 1.2em,
        context {
          set text(text-color(accent-color), weight: "bold")
          if has-title {
            title
          }
          if has-headers {
            h(3fr)
          }
          if has-tags {
            for tag in tags {
              text(tag, weight: "regular")
              h(1fr)
            }
            h(2fr)
          }
          supplement
          " "
          number
        },
      )
    }
    // Body
    #if has-body {
      block(
        inset: (
          right: 1em,
        ),
        spacing: 0em,
        width: 100%,
        body,
      )
    }
  ]
}

#let thmbox(
  title,
  tags,
  body,
  supplement,
  number,
  accent-color,
) = target-choose(
  html: () => thmbox-html(title, tags, body, supplement, number, accent-color),
  paged: thmbox-paged(title, tags, body, supplement, number, accent-color),
)

