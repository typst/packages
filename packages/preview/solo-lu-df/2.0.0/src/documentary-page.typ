#let signature-line(length: 6em) = box(
  width: length,
  stroke: (bottom: 0.5pt),
  height: 0.65em,
)

#let fmt-date(date) = strong(date.display("[day].[month].[year]."))

#let thesis-config(labels) = (
  bachelor: (
    label: labels.thesis.label.bachelor,
    intro-suffix: labels.documentary.page.intro_suffix.bachelor,
    make-footer: (submission-date, defense-date) => [
      #labels.documentary.page.submitted_line #submission-date \
      #let authorized_person = labels.documentary.page.authorized_person
      #authorized_person.label #authorized_person.title #authorized_person.name ~#signature-line()

      #v(1fr)

      #labels.documentary.page.defense_line.bachelor
      ~#signature-line() \
      #defense-date #labels.documentary.page.protocol_label
      ~#signature-line(length: 4em) \
      #labels.documentary.page.committee_secretary_label
      ~#signature-line(length: 15em)
    ],
  ),
  master: (
    label: labels.thesis.label.master,
    intro-suffix: labels.documentary.page.intro_suffix.master,
    make-footer: (submission-date, defense-date) => [
      #labels.documentary.page.submitted_line #submission-date \
      #let authorized_person = labels.documentary.page.authorized_person
      #authorized_person.label #authorized_person.title #authorized_person.name ~#signature-line()

      #v(1fr)

      #labels.documentary.page.defense_line.master ~#signature-line() \
      #defense-date #labels.documentary.page.protocol_label
      ~#signature-line(length: 4em) \
      #labels.documentary.page.committee_secretary_label
      ~#signature-line(length: 15em)
    ],
  ),
  course: (
    label: labels.thesis.label.course,
    intro-suffix: labels.documentary.page.intro_suffix.course,
    make-footer: (submission-date, _) => [
      #labels.documentary.page.submitted_line #submission-date \
      #labels.documentary.page.footer.course
    ],
  ),
  qualification: (
    label: labels.thesis.label.qualification,
    intro-suffix: labels.documentary.page.intro_suffix.qualification,
    make-footer: (submission-date, _) => [
      #labels.documentary.page.submitted_line #submission-date \
      #labels.documentary.page.footer.qualification
    ],
  ),
)

#let get-thesis-label(thesis-type, labels) = (
  thesis-config(labels)
    .at(thesis-type, default: (
      label: str(thesis-type),
    ))
    .label
)

#let get-thesis-config(thesis-type, labels) = {
  thesis-config(labels).at(thesis-type, default: (
    label: str(thesis-type),
    intro-suffix: "",
    make-footer: (submission-date, _) => [],
  ))
}

#let make-author-lines(authors, submission-date, labels) = {
  if authors.len() > 1 [
    #labels.documentary.page.authors.plural:\
  ] else [
    #labels.documentary.page.authors.singular:
  ]
  authors
    .map(it => [*#it.name, #it.code* ~#signature-line()~ #submission-date])
    .join("\n")
}

#let make-advisor-lines(advisors, submission-date, labels) = {
  if advisors.len() > 0 [
    #if advisors.len() > 1 [
      #labels.documentary.page.advisors.plural:\
    ] else [
      #labels.documentary.page.advisors.singular:
    ]
    #(
      advisors
        .map(it => [*#it.title #it.name* ~#signature-line()~ #submission-date])
        .join("\n")
    )
  ]
}

#let make-dokumentary(
  title,
  authors,
  advisors,
  reviewer,
  thesis-type,
  submission-date,
  defense-date,
  labels,
) = {
  let cfg = get-thesis-config(thesis-type, labels)

  [
    #cfg.label "*#title*" #labels.documentary.page.developed_at
    #labels.documentary.page.faculty_name.

    #labels.documentary.page.declaration#cfg.intro-suffix.
    #set par(hanging-indent: 1cm)

    #v(0.2fr)

    #make-author-lines(authors, submission-date, labels)

    #v(1fr)

    #labels.documentary.page.recommendation\
    #make-advisor-lines(advisors, submission-date, labels)

    #v(1fr)

    #if reviewer != none [
      #labels.documentary.page.reviewer_label: *#reviewer.title  #reviewer.name*
      #v(1fr)
    ]

    #(cfg.make-footer)(submission-date, defense-date)

    #v(1fr)
  ]
}

#let normalize-title(title) = {
  if type(title) != content or "children" not in title.fields() {
    return title
  }

  let children = title
    .fields()
    .children
    .filter(it => it.func() != linebreak)
    .fold((), (acc, it) => {
      if it == [ ] and (acc.len() == 0 or acc.last() == [ ]) {
        acc
      } else {
        acc + (it,)
      }
    })

  let children = if children.len() > 0 and children.last() == [ ] {
    children.slice(0, -1)
  } else {
    children
  }

  children.join("")
}

#let make-documentary-page(
  title,
  authors,
  advisors,
  reviewer,
  thesis-type,
  submission-date,
  defense-date,
  labels,
) = {
  set page(numbering: none)
  set par(spacing: 2em)
  heading(
    level: 1,
    outlined: false,
    numbering: none,
    labels.documentary.page.title,
  )

  make-dokumentary(
    normalize-title(title),
    authors,
    advisors,
    reviewer,
    thesis-type,
    fmt-date(submission-date),
    fmt-date(defense-date),
    labels,
  )
}
