#import "../colors.typ": gibz-blue
#import "../state.typ": gibz-lang
#import "../i18n.typ": t
#import "./base_box.typ": base-box

// Icon/text two-column box using base_box
#let gibz-box(icon, content) = {
  set text(size: 10pt)
  base-box(
    [
      #grid(
        columns: (50pt, 1fr),
        align: (center + horizon, left + horizon),
        [
          #set text(size: 20pt)
          #pad(right: 15pt, bottom: 5pt, icon)
        ],
        [#content],
      )
    ],
  )
}

#let hint(hint) = gibz-box(emoji.lightbulb, hint)

#let question(question, task: none) = gibz-box(
  emoji.quest,
  {
    [
      #set text(weight: "bold")
      #question
    ]
    if task != none {
      linebreak()
      [#task]
    }
  },
)

#let video(url, title, description: none) = {
  show link: set text(font: "DejaVu Sans Mono", size: 7pt)
  gibz-box(
    [#emoji.clapperboard],
    [
      #[
        #set text(weight: "bold")
        #title #linebreak()
      ]
      #if description != none { [#description #linebreak()] }
      #link(url)
    ],
  )
}

#let supplementary(body, title: none, lang: none) = {
  context {
    let L = if lang != none { lang } else { gibz-lang.get() }

    base-box(
      [
        #block(below: 6pt, [
          #text(size: 0.75em, weight: 600, fill: gibz-blue)[📖 #t("supplementary-material", lang: L)]
        ])
        #v(6pt)

        #if title != none {
          block(below: 6pt, [ #text(size: 1.15em, weight: 700)[#title] ])
          v(3pt)
        }

        #body
      ],
    )
  }
}
