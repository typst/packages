#import "utils.typ": *

#let _frontispiece-phd(
  title,
  author,
  supervisor,
  cosupervisor,
  academic-year,
  logo,
  cycle,
  chair,
  tutor,
  colored-headings: false,
) = {
  set page(
    margin: (top: 0cm),
    background: context {
      place(
        dx: 102mm,
        dy: -41mm,
        _raggiera-image(147mm),
      )
    },
  )

  v(4.85cm)

  logo

  v(4.4cm)

  text(
    size: _sizes.at("12pt").huge,
    weight: 700,
    fill: if (colored-headings) { bluepoli } else { black },
    title,
  )

  v(0.35cm)

  align(end, context {
    set text(size: _sizes.at("12pt").Large)
    _localization.at(text.lang).dissertation + ":\n" + text(weight: "bold", author)
  })

  v(1fr)

  align(start, context {
    set text(size: _sizes.at("12pt").large)
    _show-starvisor(supervisor, "supervisor")
    _show-starvisor(cosupervisor, "cosupervisor")
    _show-field(_localization.at(text.lang).tutor + ": ", tutor)
    _show-field(none, academic-year, separator: "")
    _show-cycle(cycle)
    _show-field(_localization.at(text.lang).chair + ": ", chair)
  })
}

#let _frontispiece-deib-phd(
  title,
  author,
  supervisor,
  cosupervisor,
  academic-year,
  logo,
  cycle,
  chair,
  tutor,
  colored-headings: true,
) = {
  set page(
    margin: (top: 0cm),
    background: context {
      place(
        dx: 102mm,
        dy: -41mm,
        _raggiera-image(147mm),
      )
    },
  )

  v(3.8cm)

  logo

  // v(4.4cm)
  v(3cm)

  text(
    size: _sizes.at("12pt").huge,
    weight: 700,
    fill: if (colored-headings) { bluepoli } else { black },
    title,
  )

  // v(0.35cm)
  v(0.26cm)

  align(end, context {
    set text(size: _sizes.at("12pt").Large)
    _localization.at(text.lang).dissertation + ":\n" + text(weight: "bold", author)
  })

  v(1fr)

  align(start, context {
    set text(size: _sizes.at("12pt").large)
    _show-starvisor(supervisor, "supervisor")
    _show-starvisor(cosupervisor, "cosupervisor")
    _show-field(_localization.at(text.lang).tutor + ": ", tutor)
    _show-field(none, academic-year, separator: "")
    _show-cycle(cycle)
    _show-field(_localization.at(text.lang).chair + ": ", chair)
  })
}

#let _frontispiece-classical-master(
  title,
  author,
  supervisor,
  cosupervisor,
  academic-year,
  logo,
  course,
  student-id,
) = {
  // assert(
  //   course != none and couse != "",
  //   message: "You need to specify a course for the Classical Master frontispiece.",
  // )

  set page(
    margin: (top: 0cm),
    background: context {
      place(
        dx: 102mm,
        dy: -41mm,
        _raggiera-image(147mm),
      )
    },
  )

  v(4.7cm)

  logo

  v(4.2cm)

  text(
    fill: bluepoli,
    size: _sizes.at("12pt").huge,
    weight: "bold",
    title,
  )

  v(0.2cm)

  text(
    fill: bluepoli,
    size: _sizes.at("12pt").large,
    weight: "bold",
    smallcaps[
      Tesi di Laurea Magistrale In
      #linebreak()
      #course
    ],
  )

  v(0.6cm)

  context text(
    size: _sizes.at("12pt").Large,
    _localization.at(text.lang).author + ": " + strong(author),
  )

  // v(1.1fr)

  align(bottom + start, context {
    set text(size: _sizes.at("12pt").normalsize)
    _show-field(_localization.at(text.lang).student-id + ": ", student-id)
    _show-starvisor(supervisor, "supervisor")
    _show-starvisor(cosupervisor, "cosupervisor")
    _show-field(
      _localization.at(text.lang).academic-year + ": ",
      academic-year,
      separator: none,
    )
  })
}

#let _frontispiece-cs-eng-master(
  title,
  author,
  supervisor,
  cosupervisor,
  academic-year,
  logo,
  student-id,
  preface: [
    Tesi di Laurea Magistrale In\
    Computer Science and Engineering\
    Ingegneria Informatica
  ],
) = {
  set page(
    margin: (top: 0cm),
    background: context {
      place(
        dx: 102mm,
        dy: -41mm,
        _raggiera-image(147mm),
      )
    },
  )

  v(4.7cm)

  logo

  v(2.1cm)

  align(
    center,
    text(
      fill: bluepoli,
      size: _sizes.at("12pt").large,
      weight: "bold",
      smallcaps(preface),
    ),
  )

  v(0.4cm)

  align(
    center,
    text(
      size: _sizes.at("12pt").huge,
      weight: "bold",
      title,
    ),
  )

  v(0.2cm)

  context {
    _localization.at(text.lang).author + ":\n"
    text(
      weight: "bold",
      size: _sizes.at("12pt").large,
      author,
    )
    if student-id != none {
      parbreak()
      _localization.at(text.lang).student-id + ":\n"
      text(
        weight: "bold",
        size: _sizes.at("12pt").large,
        student-id,
      )
    }
  }

  align(bottom + start, context {
    set text(size: _sizes.at("12pt").normalsize)
    _show-starvisor(supervisor, "supervisor", separator: ":\n", out: strong)
    _show-starvisor(cosupervisor, "cosupervisor", separator: ":\n", out: strong)
    _show-field(none, academic-year, separator: "")
  })
}
