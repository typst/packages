/// Function to apply the assignment template to a document.
/// -> content
#let assignment(
  /// The assignment's title. This argument is required.
  /// -> str
  title: "",
  /// The student authoring the assignment. Two keys are expected, `name` with
  /// a value of type string and `id` with a value of any type that can be
  /// converted to a string. This argument is required.
  /// -> dictionary
  student: (:),
  /// The subject the assignment is for. Two keys are expected, `name` and
  /// `code`, both of whose values are strings. This argument is required.
  /// -> dictionary
  subject: (:),
  /// The assignment's creation date. This argument is optional. The default is
  /// `datetime.today()`.
  /// -> none | auto | datetime
  date: datetime.today(),
  /// The assignment's content.
  /// -> content
  body,
) = {
  set document(
    title: title,
    author: student.name,
    description: subject.code + ": " + subject.name,
    date: date,
  )

  set text(size: 10pt)

  set page(
    paper: "a4",
    margin: (
      top: 118pt,
      bottom: 96pt,
      x: 128pt,
    ),
    header-ascent: 14pt,
    header: {
      set text(size: 8pt)
      grid(
        columns: (1fr, 1fr, 1fr),
        rows: (auto, auto),
        align: (left, center, right),
        gutter: 6pt,
        str(student.id), subject.code, date.display(),
        student.name, subject.name, title,
      )
    },
    footer-descent: 12pt,
    footer: context {
      set align(center)
      set text(size: 8pt)
      counter(page).display("1")
    },
  )

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(size: 10pt, weight: "bold")
    it.body + [.]
  }
  show heading.where(level: 2): it => {
    set text(size: 10pt, weight: "bold")
    it.body + [.]
  }

  set enum(indent: 5pt, numbering: "(a)")
  set list(indent: 5pt)

  show quote: set align(center)

  show math.equation: set block(breakable: true)

  set par(leading: 5pt, justify: true)

  body
}
