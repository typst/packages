#import "../utils.typ": *
#import "../styling/tokens.typ": tokens
#import "@preview/tieflang:0.1.0": tr
#import "@preview/biceps:0.0.1": flexwrap

#let title-page(
  school: none,
  institute-short: none,
  institute: none,
  work_type: none,
  title: none,
  authors: none,
  supervisors: none,
  co-supervisors: none,
  industry-partner: none,
  print-mode: false,
) = {
  set page(fill: if (not print-mode) { tokens.colour.main } else { none }, margin: 1cm, background: none)
  set par(leading: 0.8em)
  set text(
    fill: if (not print-mode) { white } else { tokens.colour.main },
    weight: "bold",
    font: tokens.font-families.headers,
  )

  let authors = ensure-array(authors)

  // Handle two formats for supervisors:
  // 1. String or array of strings: supervisors: ("Name 1", "Name 2")
  // 2. Dictionary: supervisors: (main: "Name", secondary: "Name", external: "Name")
  let supervisors-dict = none
  let supervisors-list = none

  if supervisors != none and type(supervisors) == dictionary {
    supervisors-dict = supervisors
  } else {
    supervisors-list = ensure-array(supervisors)
  }

  let co-supervisors = ensure-array(co-supervisors)

  let logo = (
    image(if (print-mode) { "../assets/zhaw_sw_pos.jpg" } else { "../assets/zhaw_logo.png" }),
    pad(right: 30%, top: 18pt, text(
      size: 18pt,
      tr().school_of + " " + school + linebreak() + institute,
    )),
  )

  let optical_alignment = 8pt

  let title = align(horizon, block(inset: (left: optical_alignment))[
    #pad(bottom: -1.2em, upper(text(size: 16pt, weight: "regular", font: tokens.font-families.body, work_type)))
    #linebreak()
    #par(leading: 2em, justify: false, first-line-indent: 0pt, text(size: 32pt, title))
  ])

  let info() = {
    set par(justify: false)
    set text(size: 10pt)

    let info-items = (
      block[
        #(tr().author)(authors.len()):\
        #text(font: tokens.font-families.body, weight: "regular", authors.join(linebreak()))
      ],
    )

    // Handle simple supervisors format
    if supervisors-list != none and supervisors-list.len() > 0 {
      info-items.push(
        align(start + top)[
          #(tr().supervisor)(supervisors-list.len()):\
          #text(font: tokens.font-families.body, weight: "regular", supervisors-list.join(linebreak())) \
        ],
      )
    }

    // Handle dictionary supervisors format
    if supervisors-dict != none {
      if "main" in supervisors-dict and supervisors-dict.main != none {
        let main-list = ensure-array(supervisors-dict.main)
        info-items.push(
          align(start + top)[
            #(tr().main_supervisor)(main-list.len()):\
            #text(font: tokens.font-families.body, weight: "regular", main-list.join(linebreak())) \
          ],
        )
      }

      if "secondary" in supervisors-dict and supervisors-dict.secondary != none {
        let secondary-list = ensure-array(supervisors-dict.secondary)
        info-items.push(
          align(start + top)[
            #(tr().secondary_supervisor)(secondary-list.len()):\
            #text(font: tokens.font-families.body, weight: "regular", secondary-list.join(linebreak())) \
          ],
        )
      }

      if "external" in supervisors-dict and supervisors-dict.external != none {
        let external-list = ensure-array(supervisors-dict.external)
        info-items.push(
          align(start + top)[
            #(tr().external_supervisor)(external-list.len()):\
            #text(font: tokens.font-families.body, weight: "regular", external-list.join(linebreak())) \
          ],
        )
      }
    }

    if co-supervisors != none {
      info-items.push(
        align(start + top)[
          #(tr().co_supervisor)(co-supervisors.len()):\
          #text(font: tokens.font-families.body, weight: "regular", co-supervisors.join(linebreak())) \
        ],
      )
    }

    if industry-partner != none {
      info-items.push(
        align(start + top)[
          #tr().industry_partner:\
          #text(font: tokens.font-families.body, weight: "regular", industry-partner) \
        ],
      )
    }

    info-items.push(
      align(start + top)[
        #tr().submitted_on:\
        #text(font: tokens.font-families.body, weight: "regular", today())
      ],
    )

    let min-gutter = 1.5cm

    block(inset: (left: optical_alignment))[
      #flexwrap(
        main-dir: ltr,
        cross-dir: ttb,
        main-spacing: min-gutter,
        cross-spacing: 1cm,
        ..info-items.map(item => block(width: auto, breakable: false, item)),
      )
    ]
  }

  grid(
    columns: (3cm, 1fr),
    rows: (3cm, 1fr, auto),
    gutter: 0.5cm,
    ..logo,
    "",
    title,
    "",
    info(),
  )
}
