#import "/lib/i18n.typ": en-us

#let __make-answer-stat(stat, i18n) = {
  let keys = stat.keys()
  let builder = ()
  if "submit-count" in keys {
    builder.push(i18n.submitted_prefix + str(stat.submit-count) + i18n.submitted_postfix)
  }
  if "ac-count" in keys {
    builder.push(i18n.passed_prefix + str(stat.ac-count) + i18n.passed_postfix)
  }
  if "ac-ratio" in keys {
    builder.push(i18n.ac-ratio_prefix + str(stat.ac-ratio) + i18n.ac-ratio_postfix)
  }
  if builder.len() == 3 [
    - #builder.at(0)\, #builder.at(1)\
      #builder.at(2)
  ] else if builder.len() > 0 [
    - #builder.join(", ")
  ]

  builder = ()
  if "first-solver" in keys {
    builder.push(i18n.first-solver_prefix + stat.first-solver + i18n.first-solver_postfix)
  }
  if "first-solve-time" in keys {
    builder.push(i18n.first_solved_at_prefix + str(stat.first-solve-time) + i18n.first_solved_at_postfix)
  }
  if builder.len() > 0 [
    - #builder.join(", ")
  ]
}

#let make-prob-meta(
  tags: (),
  difficulty: none,
  authors: (),
  stat-open: (
    submit-count: -1,
    ac-count: -1,
    ac-ratio: -1,
    first-solver: "",
    first-solve-time: -1,
  ),
  stat-onsite: none,
  i18n: en-us.make-prob-meta
) = [
  // Tags
  #text(size: .8em)[#tags.map(each => raw("#" + each)).join(", ") \ ]

  #i18n.difficulty_prefix#difficulty#i18n.difficulty_postfix

  #align(horizon)[
    #if type(authors) == array [
      #if authors.len() == 1 [
        - #i18n.author: #authors.at(0)
      ] else [
        - #i18n.authors: #authors.join(", ")
      ]
    ] else if (type(authors) == content) or (type(authors) == str) [
      - #i18n.author: #authors
    ]
    
    
    #if stat-onsite == none {
      __make-answer-stat(stat-open, i18n)
     } else [
      #table(
        columns: (1fr, 1fr),
        stroke: none,
        inset: (x: 0pt),
        [
          - #i18n.online-open-contest
            #__make-answer-stat(stat-open, i18n)
        ], [
          - #i18n.offline-onsite-contest
            #__make-answer-stat(stat-onsite, i18n)
        ]
      )
    ]
      
  ]
]
