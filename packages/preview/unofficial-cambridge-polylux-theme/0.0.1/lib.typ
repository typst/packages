#import "@preview/polylux:0.4.0": slide as raw-slide

#let cam-dark-blue = rgb(19, 56, 68)
#let cam-blue = rgb(142, 232, 216)
#let cam-light-blue = rgb(209, 249, 241)
#let cam-warm-blue = rgb(0, 189, 182)
#let cam-slate-1 = rgb(236, 238, 241)
#let cam-slate-2 = rgb(181, 189, 200)
#let cam-slate-3 = rgb(84, 96, 114)
#let cam-slate-4 = rgb(35, 40, 48)

#let logo = state("logo", "assets/placeholder-logo.svg")

#let _title-slide(body) = {
  set page(margin: 0pt)
  show heading: set text(size: 23pt)
  show heading: it => {
    block(below: 1.5em, it)
  }

  raw-slide(grid(
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
        fill: cam-warm-blue,
        stroke: none,
        {
          place(top + right, dx: 100em + 0em, dy: -60em, circle(
            radius: 60em,
            fill: cam-dark-blue.transparentize(75%),
            stroke: none,
          ))
          place(top + right, dx: 15em + 10em, dy: 2em, circle(
            radius: 20em,
            fill: cam-dark-blue.transparentize(75%),
            stroke: none,
          ))
          place(top + right, dx: 35em, dy: -20em, circle(
            radius: 20em,
            fill: cam-light-blue,
            stroke: none,
          ))

          place(top + right, dx: 15em + 10em, dy: 2em, circle(
            radius: 20em,
            fill: none,
            stroke: (paint: cam-warm-blue, thickness: .1em),
          ))
        },
      ),
    ),
  ))
}

#let _alternative-slide-1(body) = {
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

  raw-slide(body)
}

#let _alternative-slide-2(body) = {
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

  raw-slide(body)
}

#let _light-slide(body) = {
  set page(
    margin: (bottom: 2em, top: 4em, rest: 1.5em),
    header: context {
      block(
        inset: (left: -1.5em, right: -1.5em, rest: 0em),
        box(
          width: 60%,
          height: 100%,
          clip: true,
          fill: cam-light-blue,
          {
            place(right + horizon, dx: 30% + 2.5cm, dy: -30%, circle(
              radius: 10em,
              fill: cam-blue.transparentize(50%),
              stroke: none,
            ))


            place(left + horizon, dx: 1cm, box(logo.get(), height: 1cm))
          },
        ),
      )
    },
  )
  raw-slide(body)
}

#let _standard-slide(body) = {
  set page(
    margin: (bottom: 2em, top: 4em, rest: 1.5em),
    header: context {
      block(
        inset: (left: -1.5em, right: -1.5em, rest: 0em),
        box(
          width: 60%,
          height: 100%,
          clip: true,
          fill: cam-warm-blue,
          {
            place(left + horizon, dx: -20em - 5em, dy: 30%, circle(
              radius: 20em,
              fill: cam-dark-blue.transparentize(70%),
              stroke: none,
            ))

            place(left + horizon, dx: -20em - 10em, dy: 30%, circle(
              radius: 20em,
              fill: cam-warm-blue.transparentize(30%),
              stroke: none,
            ))


            place(left + horizon, dx: 1cm, box(logo.get(), height: 1cm))
          },
        ),
      )
    },
  )
  raw-slide(body)
}


#let slide(type: "standard", body) = {
  set text(size: 2em, font: "Open Sans", fill: cam-slate-4)
  set page(fill: cam-slate-1)
  show heading: it => {
    block(below: 1em, it)
  }
  show heading: set text(font: "Feijoa Bold-Cambridge")
  if type == "title" {
    _title-slide(body)
  } else if type == "standard" {
    _standard-slide(body)
  } else if type == "light" {
    _light-slide(body)
  } else if type == "alt1" {
    _alternative-slide-1(body)
  } else if type == "alt2" {
    _alternative-slide-2(body)
  }
}

