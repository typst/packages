#import "/lib/i18n.typ": en-us
#import "/lib/colors.typ": color
#import "/lib/utils/make-prob-meta.typ": make-prob-meta

#let make-problem(
  id: none,
  title: none,
  tags: (),
  difficulty: none,
  authors: (),
  stat-open: (
    submit-count: -1,
    ac-count: -1,
    ac-ratio: -1,
    first-solver: none,
    first-solve-time: -1,
  ),
  stat-onsite: none,
  pallete: (
    primary: color.bluegray.at(2),
    secondary: white,
  ),
  i18n: en-us.make-problem,
  body
) = {
  set page(margin: (top: 3em))
  set text(size: 20pt)
  [= #text(fill: pallete.primary, size: 1.35em)[#id. #title]]
  [\ ]
  make-prob-meta(
    tags: tags,
    difficulty: difficulty,
    authors: authors,
    stat-open: stat-open,
    stat-onsite: stat-onsite,
    i18n: i18n.make-prob-meta
  )
  set page(
    header: text(
      size: .8em
    )[
      #text(fill: pallete.primary)[
        #text(weight: "bold")[#id\.] #title
      ]
    ]
  )
  set align(horizon)
  set list(marker: [#text(font: "inter", fill: pallete.primary)[✓]])
  body
}
