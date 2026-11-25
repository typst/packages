#let declaration(
  name: none,
  birth-date: none,
  study-group: none,
  semester: none,
  student-id: none,
  submission-date: none,
  thesis-type: none,
  ai-used: false,
  declaration-text: none,
  t: none,
) = {
  if name == none {
    panic("Declaration requires a name")
  }

  v(1fr)

  if study-group != none and semester != none and student-id != none {
    [
      #name#if birth-date != none {
        [, #t.born #birth-date]
      } (#study-group, #semester)
    ]
  }

  v(1cm)

  [
    #if declaration-text != none {
      declaration-text
    } else {
      (t.declaration-of-independent-writing)(thesis-type: thesis-type, ai-used: ai-used)
    }
  ]

  v(2cm)

  [#t.place-time #submission-date #h(1fr) #name]

  v(1cm)
}
