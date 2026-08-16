#let appendix(
  contents: (
    [#lorem(150)],
    [#lorem(150)]
  )
) = [
  #counter(heading).update(0)
  #set heading(
    numbering: (..nums) => numbering("A", counter(heading).get().first()),
    outlined: false
  )
  #show heading.where(level: 1): it => [
    #context block(
      [Appendix] + [ ] + numbering("A", counter(heading).get().first())
    )
  ]

  #for (i, appendix-content) in contents.enumerate() {
    let appendix-label = "appendix-" + numbering("a", i + 1)
    [
      =
      #label(appendix-label)
      #appendix-content
    ]
  }
]