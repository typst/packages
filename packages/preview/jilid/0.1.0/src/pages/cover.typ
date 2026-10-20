#import "../state.typ": section, sections
#import "../utils.typ": filled, prefixed, styled

#let default-cover(c, it) = {
  let t = it.labels

  let id-line(label, person) = {
    let id = person.at("id", default: none)
    if not filled(id) [] else if not filled(label) {
      styled(c.id, [#id])
    } else { styled(c.id, [#label #id]) }
  }

  let title-text = styled(c.title, it.title)
  let kind-text = styled(c.kind, it.kind)

  let logo = if it.logo != none {
    set image(width: c.logo-width)
    it.logo
  }

  let lecturers = if it.lecturers.len() > 0 [
    #styled(c.label, t.lecturer)\
    #for l in it.lecturers [
      #styled(c.lecturer-name, l.name)\
      #if filled(l.at("id", default: none)) [#id-line(t.lecturer-id, l)\ ]
    ]
    #v(c.gap)
  ]

  // a grid filled column by column.
  // id-pos "right", name and id side by side.
  // id-pos "below", id under the name in one cell.
  let students(cols) = if it.students.len() == 0 { none } else {
    let list = it.students
    let beside = c.student-id-pos == "right"
    let rows = calc.ceil(list.len() / cols)
    let cells = range(rows * cols).map(j => {
      let i = calc.rem(j, cols) * rows + calc.quo(j, cols)
      if i >= list.len() { if beside { ([], []) } else { [] } } else {
        let s = list.at(i)
        let name = styled(c.student-name, s.name)
        if beside { (name, id-line(t.student-id, s)) } else [
          #name
          #if filled(s.at("id", default: none)) [\ #id-line(t.student-id, s)]
        ]
      }
    })

    context stack(
      spacing: par.leading,
      styled(c.label, t.students),
      align(center, grid(
        columns: (auto,) * (if beside { 2 * cols } else { cols }),
        // create a gaps between students name and its id.
        column-gutter: if beside {
          range(2 * cols - 1).map(g => if calc.odd(g) { 1.5em } else { 0pt })
        } else { 1em },
        row-gutter: if beside { par.leading } else { 1em },
        align: if beside { (left, right) * cols } else { center },
        inset: (x: 4pt),
        ..if beside { cells.flatten() } else { cells },
      )),
    )
  }

  let body(cols) = align(center)[
    #v(c.top)

    #if c.kind-pos == "top" [
      #if filled(it.kind) { kind-text + v(0.1cm) }
      #title-text
    ] else [
      #title-text
      #if filled(it.kind) { v(0.1cm) + kind-text }
    ]

    #if filled(it.subtitle) [
      #v(0.5cm)
      #styled(c.subtitle, it.subtitle)
    ]

    #for (label, value) in it.details [
      #v(0.5cm)
      #styled(c.details, [#label \ #value])
    ]

    #v(1fr)
    #if logo != none { v(c.gap-logo) + logo + v(c.gap-logo) }
    #v(1fr)

    #if filled(it.course) [
      #styled(c.label, t.course)\
      #styled(c.course, it.course)
      #v(c.gap)
    ]

    #lecturers
    #students(cols)

    #v(1fr)
    #v(c.gap-institution)

    #styled(c.institution)[
      #for line in (it.university, it.faculty, it.department, it.program) {
        if filled(line) [#line\ ]
      }
      #if filled(it.year) [#it.year]
    ]
  ]

  layout(size => {
    let height(cols) = measure(block(width: size.width, body(cols))).height

    // auto: the fewest columns up to 3 that fit,
    // else the shortest cover.
    let cols = c.student-columns
    if cols == auto {
      let options = (1, 2, 3)
      cols = options.find(n => height(n) <= size.height)
      if cols == none { cols = options.sorted(key: height).first() }
    }
    body(cols)
  })
}

#let cover-page(cfg) = {
  let info = cfg.info
  let t = cfg.t
  let unit(label, value) = if filled(value) { prefixed(label, value) }
  let render = if cfg.cover.render == auto {
    default-cover.with(cfg.cover)
  } else { cfg.cover.render }

  page(numbering: none, footer: none)[
    #section.update(sections.cover)
    #render((
      title: info.title,
      kind: info.kind,
      subtitle: info.subtitle,
      details: info.cover-details,
      course: info.course,
      lecturers: info.lecturers,
      students: info.students,
      logo: info.logo,
      university: info.university,
      faculty: unit(t.faculty, info.faculty),
      department: unit(t.department, info.department),
      program: unit(t.program, info.program),
      year: info.year,
      labels: t,
    ))
  ]
}
