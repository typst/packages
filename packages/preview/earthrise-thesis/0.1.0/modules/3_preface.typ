#let preface-page(supervisors, cosupervisors, committee, preface_body) = page([
  #if preface_body != none {
    show heading.where(level: 1): it => {
      v(7.5%)
      text(32pt, weight: "bold", it.body)
      v(5%, weak: true)
    }
    heading(level: 1, outlined: false, bookmarked: true, "Preface")
    preface_body
  }

  #v(1fr)

  #set par(spacing: 1.5em)
  #if (supervisors, cosupervisors, committee).any(it => it not in (none, ())) {
    heading(
      level: 2,
      "Defense Committee",
      numbering: none,
      outlined: false,
      bookmarked: false,
    )
  }
  #if committee not in (none, ()) {
    grid(
      columns: (1fr, 1fr),
      gutter: 1.5em,
      text(weight: "semibold", if committee.len() > 1 {
        "Committee Members:"
      } else {
        "Committee Member:"
      }),
      ..committee.map(value => [#value.title #value.name]).intersperse(""),
    )
  }
  #if cosupervisors not in (none, ()) {
    grid(
      columns: (1fr, 1fr),
      gutter: 1.5em,
      text(weight: "semibold", if cosupervisors.len() > 1 {
        "Co-Supervisors:"
      } else {
        "Co-Supervisor:"
      }),
      ..cosupervisors.map(value => [#value.title #value.name]).intersperse(""),
    )
  }
  #if supervisors not in (none, ()) {
    grid(
      columns: (1fr, 1fr),
      gutter: 1.5em,
      text(weight: "semibold", if supervisors.len() > 1 {
        "Supervisors:"
      } else {
        "Supervisor:"
      }),
      ..supervisors.map(value => [#value.title #value.name]).intersperse(""),
    )
  }
])
