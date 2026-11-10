#import "colors.typ": *

#let unit = 0.44in
#let titleinset = 1.63in

#let slide(title: false, body) = {
  set page(
    width: 13.33in,
    height: 7.5in,
    margin: (bottom: unit, rest: 0in),
    fill: leiden-blue,
    footer: context rect(
      width: 100%,
      height: unit,
      stroke: none,
      fill: leiden-blue,
      inset: if title {(left: titleinset, right: unit, rest: 0in)} else {(x: unit, rest: 0in)},
      align(
        horizon,
        box(
          height: 100%,
          text(fill: white, size: 18pt, [Discover the world at Leiden University])
        ) + if title {none} else {
          h(1fr) + box(
            height: 100%,
            if page.numbering != none {text(fill: white, size: 12pt, counter(page).display(page.numbering))}
          )
        }
      ),
    ),
    footer-descent: 0pt,
  )
  body
}

#let title(title, subtitle, subtitlecolor) = slide(
  title: true,
  {
    stack(
      dir: ttb,
      rect(
        width: 100%,
        height: 4.07in,
        stroke: none,
        fill: leiden-blue,
        inset: (left: titleinset, rest: unit),
        align(
          horizon,
          text(size: 54pt, fill: white, weight: "bold", title)
        )
      ),
      rect(
        width: 100%,
        height: 0.88in,
        stroke: none,
        fill: subtitlecolor,
        inset: (left: titleinset, rest: unit),
        align(
          horizon,
          text(size: 24pt, fill: white, subtitle)
        )
      ),
      context rect(
        width: 100%,
        height: 2.11in,
        stroke: none,
        fill: white,
        inset: 0.01in,
        if text.lang == "nl" {
          image("UL - Algemeen - RGB-Kleur.svg", height: 100%)
        } else {
          image("UL - Algemeen Internationaal - RGB-color.svg", height: 100%)
        },
      )
    )
  }
)

#let content(title, body) = slide(
  rect(
    width: 100%,
    height: 100%,
    stroke: none,
    fill: white,
    inset: unit,
    stack(
      dir: ttb,
      block(
        width: 100%,
        height: 0.47in,
        inset: 0in,
        text(size: 40pt, weight: "bold", title)
      ),
      v(1fr),
      block(
        width: 100%,
        height: 5.24in,
        inset: 0in,
        body
      )
    )
  )
)