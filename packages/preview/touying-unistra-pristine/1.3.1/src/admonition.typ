#import "colors.typ": *

// Credit: piepert
// https://github.com/piepert/grape-suite/blob/3be3e71a994bae82c9a9dedf41e918d7837ccc39/src/elements.typ

#let ADMONITION-TRANSLATIONS = (
  "task": (
    "sg": (
      "en": "Task",
      "fr": "Tâche",
    ),
    "pl": (
      "en": "Tasks",
      "fr": "Tâches",
    ),
  ),
  "definition": (
    "sg": (
      "en": "Definition",
      "fr": "Définition",
    ),
    "pl": (
      "en": "Definitions",
      "fr": "Définitions",
    ),
  ),
  "example": (
    "sg": (
      "en": "Example",
      "fr": "Exemple",
    ),
    "pl": (
      "en": "Examples",
      "fr": "Exemples",
    ),
  ),
  "brainstorming": (
    "sg": (
      "en": "Brainstorming",
      "fr": "Remue-méninges",
    ),
    "pl": (
      "en": "Brainstormings",
      "fr": "Remue-méninges",
    ),
  ),
  "question": (
    "sg": (
      "en": "Question",
      "fr": "Question",
    ),
    "pl": (
      "en": "Questions",
      "fr": "Questions",
    ),
  ),
)

#let admonition(
  body,
  title: none,
  time: none,
  primary-color: pink.E,
  secondary-color: pink.E.lighten(90%),
  tertiary-color: pink.E,
  dotted: false,
  figured: false,
  counter: none,
  numbering-format: (..n) => numbering("1.1", ..n),
  figure-supplement: none,
  figure-kind: none,
  text-color: black,
  emoji: none,
  ..args,
) = {
  let lang = args.named().at("lang", default: "fr")
  let plural = args.named().at("plural", default: false)
  let show-numbering = args.named().at("show-numbering", default: false)

  let title = if title == none {
    (ADMONITION-TRANSLATIONS)
      .at(figure-kind)
      .at(if plural {
          "pl"
        } else {
          "sg"
        })
      .at(lang)
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
      inset: 0.2em,
      outset: 0.2em,
      fill: secondary-color,

      stroke: (
        left: (
          thickness: 5pt,
          paint: primary-color,
          dash: if dotted {
            "dotted"
          } else {
            "solid"
          },
        ),
      ),

      pad(
        left: 0.3em,
        right: 0.3em,
        text(
          size: 1.1em,
          strong(
            text(
              fill: tertiary-color,
              emoji + " " + smallcaps(title) + if show-numbering or figured {
                [ ] + context numbering(
                  numbering-format,
                  ..counter.at(here()),
                ) + h(1fr) + time
              },
            ),
          ),
        ) + block(
          above: 0.8em,
          text(size: 1.2em, fill: text-color, body),
        ),
      ),
    )
  }

  if figured {
    figure(kind: figure-kind, supplement: figure-supplement, body)
  } else {
    body
  }
}

#let task(body, ..args) = admonition(
  body,
  primary-color: blue.E,
  secondary-color: blue.E.lighten(90%),
  tertiary-color: blue.E,
  figure-kind: "task",
  counter: counter("admonition-task"),
  emoji: emoji.hand.write,
  ..args,
)

#let definition(body, ..args) = admonition(
  body,
  primary-color: ngreen.C,
  secondary-color: ngreen.C.lighten(90%),
  tertiary-color: ngreen.B,
  figure-kind: "definition",
  counter: counter("admonition-definition"),
  emoji: emoji.brain,
  ..args,
)

#let brainstorming(body, ..args) = admonition(
  body,
  primary-color: orange.E,
  secondary-color: orange.E.lighten(90%),
  tertiary-color: orange.E,
  figure-kind: "brainstorming",
  counter: counter("admonition-brainstorming"),
  emoji: emoji.lightbulb,
  ..args,
)

#let question(body, ..args) = admonition(
  body,
  primary-color: violet.E,
  secondary-color: violet.E.lighten(90%),
  tertiary-color: violet.E,
  figure-kind: "question",
  counter: counter("admonition-question"),
  emoji: emoji.quest,
  ..args,
)