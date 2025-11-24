#import "@preview/polylux:0.4.0": slide as rawSlide

#let camDarkBlue = rgb(19, 56, 68)
#let camBlue = rgb(142, 232, 216)
#let camLightBlue = rgb(209, 249, 241)
#let camWarmBlue = rgb(0, 189, 182)
#let camSlate1 = rgb(236, 238, 241)
#let camSlate2 = rgb(181, 189, 200)
#let camSlate3 = rgb(84, 96, 114)
#let camSlate4 = rgb(35, 40, 48)

#let logo = state("logo", "assets/placeholder-logo.svg")

#let _titleSlide(body) = {
  set page(margin: 0pt)
  show heading: set text(size: 23pt)
  show heading: it => {
    block(below: 1.5em, it)
  }

  rawSlide(grid(
    columns: (40%, 60%),
    rows: 100%,
    gutter: 0pt,

    rect(
      width: 100%,
      height: 100%,
      fill: none,
      stroke: none,
      inset: (left: 1.5em, top: 1.5em, right: 1.5em, bottom: 1.5em),
      align(left + top)[
        // The Logo
        #context [
          #box(logo.get(), width: 5cm)
        ]

        // Spacing between Logo and Title
        #v(3em)
        // Title and Author goes here
        #block(width: 100%, body)
      ],
    ),

    // --- RIGHT COLUMN: Graphics ---
    box(
      width: 100%,
      height: 100%,
      clip: true,
      rect(
        width: 100%,
        height: 100%,
        fill: camWarmBlue,
        stroke: none,
        {
          place(top + right, dx: 100em + 0em, dy: -60em, circle(
            radius: 60em,
            fill: camDarkBlue.transparentize(75%),
            stroke: none,
          ))
          place(top + right, dx: 15em + 10em, dy: 2em, circle(
            radius: 20em,
            fill: camDarkBlue.transparentize(75%),
            stroke: none,
          ))
          place(top + right, dx: 35em, dy: -20em, circle(
            radius: 20em,
            fill: camLightBlue,
            stroke: none,
          ))

          place(top + right, dx: 15em + 10em, dy: 2em, circle(
            radius: 20em,
            fill: none,
            stroke: (paint: camWarmBlue, thickness: .1em),
          ))
        },
      ),
    ),
  ))
}

#let _alternativeSlide1(body) = {
  let conclusionBackground = image("assets/alt_background_1.png", width: 100%, height: 100%, fit: "cover")

  set page(
    background: conclusionBackground,
    margin: (bottom: 2em, top: 4em, rest: 1.5em),
    header: context {
      block(
        inset: (left: -1.5em, right: -1.5em, rest: 0em),
        box(
          width: 60%,
          height: 100%,
          clip: true,
          fill: none,
          {
            place(left + horizon, dx: 1cm, box(logo.get(), height: 1cm))
          },
        ),
      )
    },
  )

  rawSlide(body)
}

#let _alternativeSlide2(body) = {
  let conclusionBackground = image("assets/alt_background_2.png", width: 100%, height: 100%, fit: "cover")

  set page(
    background: conclusionBackground,
    margin: (bottom: 2em, top: 4em, rest: 1.5em),
    header: context {
      block(
        inset: (left: -1.5em, right: -1.5em, rest: 0em),
        box(
          width: 60%,
          height: 100%,
          clip: true,
          fill: none,
          {
            place(left + horizon, dx: 1cm, box(logo.get(), height: 1cm))
          },
        ),
      )
    },
  )

  rawSlide(body)
}

#let _lightSlide(body) = {
  set page(
    margin: (bottom: 2em, top: 4em, rest: 1.5em),
    header: context {
      block(
        inset: (left: -1.5em, right: -1.5em, rest: 0em),
        box(
          width: 60%,
          height: 100%,
          clip: true,
          fill: camLightBlue,
          {
            place(right + horizon, dx: 30% + 2.5cm, dy: -30%, circle(
              radius: 10em,
              fill: camBlue.transparentize(50%),
              stroke: none,
            ))


            place(left + horizon, dx: 1cm, box(logo.get(), height: 1cm))
          },
        ),
      )
    },
  )
  rawSlide(body)
}

#let _standardSlide(body) = {
  set page(
    margin: (bottom: 2em, top: 4em, rest: 1.5em),
    header: context {
      block(
        inset: (left: -1.5em, right: -1.5em, rest: 0em),
        box(
          width: 60%,
          height: 100%,
          clip: true,
          fill: camWarmBlue,
          {
            place(left + horizon, dx: -20em - 5em, dy: 30%, circle(
              radius: 20em,
              fill: camDarkBlue.transparentize(70%),
              stroke: none,
            ))

            place(left + horizon, dx: -20em - 10em, dy: 30%, circle(
              radius: 20em,
              fill: camWarmBlue.transparentize(30%),
              stroke: none,
            ))


            place(left + horizon, dx: 1cm, box(logo.get(), height: 1cm))
          },
        ),
      )
    },
  )
  rawSlide(body)
}


#let slide(type: "standard", body) = {
  set text(size: 2em, font: "Open Sans", fill: camSlate4)
  set page(fill: camSlate1)
  show heading: it => {
    block(below: 1em, it)
  }
  show heading: set text(font: "Feijoa Bold-Cambridge")
  if type == "title" {
    _titleSlide(body)
  } else if type == "standard" {
    _standardSlide(body)
  } else if type == "light" {
    _lightSlide(body)
  } else if type == "alt1" {
    _alternativeSlide1(body)
  } else if type == "alt2" {
    _alternativeSlide2(body)
  }
}

