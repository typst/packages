#import "colors.typ": *
#import "options.typ": *

#let ADMONITION-TRANSLATIONS = (
  "hint": (
    "sg": (
      "de": "Hinweis",
      "en": "Hint",
    ),
    "pl": (
      "de": "Hinweise",
      "en": "Hints",
    ),
  ),
  "important": (
    "sg": (
      "de": "Wichtig",
      "en": "Important",
    ),
    "pl": (
      "de": "Wichtig",
      "en": "Important",
    ),
  ),
  "tip": (
    "sg": (
      "de": "Tipp",
      "en": "Tip",
    ),
    "pl": (
      "de": "Tipps",
      "en": "Tips",
    ),
  ),
  "example": (
    "sg": (
      "de": "Beispiel",
      "en": "Example",
    ),
    "pl": (
      "de": "Beispiele",
      "en": "Examples",
    ),
  ),
)

#let admonition(
  body,
  title: none,
  color: color.blue,
  dotted: false,
  figured: false,
  counter: none,
  numbering-format: (..n) => numbering("1.1", ..n),
  figure-supplement: none,
  figure-kind: none,
  text-color: black,
  plural: false,
  show-numbering: false,
  ..args,
) = context {
  let opts = options.final()

  let title = if title == none {
    (ADMONITION-TRANSLATIONS)
      .at(figure-kind)
      .at(if plural {
          "pl"
        } else {
          "sg"
        })
      .at(opts.lang)
  } else {
    title
  }

  if figured {
    if figure-supplement == none {
      figure-supplement = title
    }

    if figure-kind == none {
      panic("once parameter 'figured' is true, parameter 'figure-kind' must be set!")
    }
  }


  let body = {
    if show-numbering or figured {
      if counter == none {
        panic("parameter 'counter' must be set!")
      }

      counter.step()
    }


    block(
      width: 100%,
      height: auto,
      inset: 0.5em,
      outset: 0em,

      stroke: (
        bottom: (
          thickness: 2pt,
          paint: color,
          dash: "solid",
        ),
        left: (
          thickness: 2pt,
          paint: color,
          dash: "solid",
        ),
      ),

      pad(
        left: -0.28em,
        top: -0.4em,
        box(
          outset: 0.3em,
          fill: color,
          strong(
            text(
              fill: white,
              smallcaps(title) + if show-numbering or figured {
                [ ] + numbering(
                  numbering-format,
                  ..counter.at(here()),
                )
              }
            ),
          ),
        ) + h(1em) + body,
      ),
    )
  }

  if figured {
    figure(kind: figure-kind, supplement: figure-supplement, body)
  } else {
    body
  }
}

#let hint(body, ..args) = admonition(
  body,
  color: color.blue,
  figure-kind: "hint",
  counter: counter("admonition-hint"),
  ..args,
)

#let important(body, ..args) = admonition(
  body,
  color: color.red,
  figure-kind: "important",
  counter: counter("admonition-important"),
  ..args,
)

#let tip(body, ..args) = admonition(
  body,
  color: color.green,
  figure-kind: "tip",
  counter: counter("admonition-tip"),
  ..args,
)

#let example(body, ..args) = admonition(
  body,
  color: color.yellow,
  figure-kind: "example",
  counter: counter("admonition-example"),
  ..args,
)
