#let declaration(
  name: none,
  birth-date: none,
  study-group: none,
  semester: none,
  student-id: none,
  submission-date: none,
  thesis-type: none,
  t: none,
) = {
  v(1fr)

  if name != none and study-group != none and semester != none and student-id != none {
    [
      #name#if birth-date != none {
        [, #t.born #birth-date]
      } (#study-group, #semester)
    ]
  }

  v(1cm)

  [
    #(t.declaration-of-independent-writing)(thesis-type: thesis-type)
  ]

  v(2cm)

  [#t.place-time #submission-date #h(1fr) #name]

  v(1cm)
}
