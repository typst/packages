#import "../../tools/miscellaneous.typ": content-to-string
#let presentation(content) = {
  set text(fill: white, size: 18pt)


  set page(
    paper: "presentation-4-3",
    fill: black.lighten(27%),

    footer: context [
      #block(
        fill: blue.lighten(20%),
        outset: (left: 70pt, right: 70pt),
        width: 100%,
        height: 100%,


        align(
          horizon,
          grid(
            columns: (1fr, 1fr, 1fr),
            align: (left, center, right),
            [Nom/Prenom ? ],
            [],
            [
              _Page #counter(page).display() / #counter(page).final().at(0)_

            ],
          ),
        ),
      )
    ],
  )

  show heading: it => {
    if content-to-string(it) != "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
      pagebreak(weak: true)
      place(dy: -25pt, box(radius: 15pt, fill: green.darken(10%), outset: (left: 100pt, right: 60pt, rest: 20pt), it))
      v(1cm)
    }
  }


  content
}

#let get-small-title(title) = context {
  return ""
}
