#import "../translations.typ": *

#let declaration(
  name: none,
  birth-date: none,
  study-group: none,
  semester: none,
  student-id: none,
  submission-date: none,
  thesis-type: none
) = { 
  v(1fr)

  if name != none and study-group != none and semester != none and student-id != none {
    [
      #name#if birth-date != none {
        [, #translations.born #birth-date]
      } (#study-group, #semester)
    ]
  }

  v(1cm)

  [
    #declaration-of-independent-writing-translation(thesis-type: thesis-type)
  ]

  v(2cm)

  [#translations.place-time #submission-date #h(1fr) #name]

  v(1cm)
}
