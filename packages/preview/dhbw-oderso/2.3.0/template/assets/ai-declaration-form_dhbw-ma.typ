//Declaration form for the use of AI-based tools in Projektarbeiten at DHBW Mannheim.
#import "../utils.typ": __linguify-content

#let ai-declaration-form(
  digital: true,
  name: "",
  identification-number: "",
  address: "",
  course: "",
  email: "",
  mobile-number: "",
  module-name: "",
  semester: "",
  module-submission-date: datetime.today().display("[day].[month].[year]"),
  exam-type: "",
  product-name: "",
  topic: "",
  topic-editing: "",
  research: "",
  design: "",
  signature-city: "",
  signature-date: datetime.today().display("[day].[month].[year]"),
  signature-image: none,
) = {
  //parameters
  let empty-field-placeholder = box(height: 0.3cm)
  let field-name = name + empty-field-placeholder
  let field-identification-number = (
    identification-number + empty-field-placeholder
  )
  let field-address = address + empty-field-placeholder
  let field-course = course + empty-field-placeholder
  let field-email = email + empty-field-placeholder
  let field-mobile-number = mobile-number + empty-field-placeholder
  let field-module-name-semester = (
    module-name
      + empty-field-placeholder
      + " / "
      + empty-field-placeholder
      + semester
  )
  let field-date = [#module-submission-date #empty-field-placeholder]
  let exam-type = exam-type //"Projektarbeit I", "Projektarbeit II", "Seminararbeit",   Bachelorarbeit"
  let field-production-name = product-name + empty-field-placeholder
  let field-topic = topic
  let field-topic-editing = topic-editing
  let field-research = research
  let field-design = design
  let field-signature

  let field-placeholder(content: []) = box(height: 2.6cm, content)
  let signature
  if (digital) {
    field-signature = field-placeholder(
      content: [#signature-city, #signature-date],
    )
    signature = signature-image
  } else {
    field-signature = field-placeholder()
    signature = field-placeholder()
  }

  //measurements and styles
  let margin = (top: 2cm, right: 1.5cm, left: 2.5cm, bottom: 3cm)
  let font-size-normal = 10pt
  let font-size-small = 7pt
  let check-rec = [#sym.square]
  let check-rec-filled = [#sym.square.filled]

  //page settings
  set page(paper: "a4", margin: margin)
  set par(leading: 0.2cm, spacing: 0.4cm)
  set v(weak: true)
  set grid(inset: (top: 0.1cm, bottom: 0.1cm))
  set text(size: font-size-normal, font: "Arial")

  show heading: it => {
    text(it.body) // Disable previous styling
  }
  show heading.where(level: 1): set text(size: 12pt)
  show heading.where(level: 2): set text(size: 10pt)

  //helpers
  let text-area(lines: 4, content: []) = {
    if (digital == false) {
      content = []
      let n = 0
      while n < lines {
        content = content + line(length: 100%) + v(0.9cm)
        n = n + 1
      }
      return content
    } else {
      return {
        content
        v(1cm)
      }
    }
  }
  // takes the thesis kind in the form
  // returns filled rec if the type is selected or not one of the placeholders
  let rec(kind) = {
    if (
      (kind == exam-type)
        or (
          (
            kind != "Projektarbeit I"
              and kind != "Projektarbeit II"
              and kind != "Seminararbeit"
              and kind != "Bachelorarbeit"
          )
            and (
              exam-type != "Projektarbeit I"
                and exam-type != "Projektarbeit II"
                and exam-type != "Seminararbeit"
                and exam-type != "Bachelorarbeit"
            )
        )
    ) {
      return check-rec-filled
    } else {
      return check-rec
    }
  }
  // takes the thesis type (e.g. 'Projektarbeit I, Bachelorarbeit')
  // returns a rectangle (checked if the exam type equals the thesis type) and the thesis type
  let fill-check-rec(kind) = {
    if (not kind.starts-with("Projektarbeit")) {
      return rec(kind) + " " + __linguify-content(lower(kind))
    } else {
      let a = lower(kind).split(" ")
      return (
        rec(kind)
          + " "
          + __linguify-content(a.at(0), args: (thesis-number: upper(a.at(1))))
      )
    }
  }

  let get-other-exam-types() = {
    if (
      exam-type != "Projektarbeit I"
        and exam-type != "Projektarbeit II"
        and exam-type != "Seminararbeit"
        and exam-type != "Bachelorarbeit"
    ) {
      return exam-type
    }
  }

  //content
  grid(
    columns: (76%, auto),
    inset: 0cm,
    align(left, heading(
      level: 1,
    )[#__linguify-content("ai-dec-title")]),
    align(right, image("DHBW-Logo.svg", width: 100%)),
  )

  v(0.7cm)

  heading(level: 2, outlined: false)[#__linguify-content(
    "ai-dec-personal-information",
  )]

  v(1.1cm)

  {
    set text(size: font-size-small)
    let lineSpacing = 0.3cm

    grid(
      columns: (60%, 40%),
      text(size: font-size-normal)[#field-name],
      text(size: font-size-normal)[#field-identification-number],
      grid.cell(stroke: (top: 1pt))[#__linguify-content(
        "ai-dec-last-first-name",
      )],
      grid.cell(stroke: (top: 1pt))[#__linguify-content(
        "ai-dec-matriculation-number",
      )],
      grid.cell(inset: lineSpacing, colspan: 2)[],
      text(size: font-size-normal)[#field-address],
      text(size: font-size-normal)[#field-course],
      grid.cell(stroke: (top: 1pt))[#__linguify-content("ai-dec-address")],
      grid.cell(stroke: (top: 1pt))[#__linguify-content("ai-dec-course")],
      grid.cell(inset: lineSpacing, colspan: 2)[],
      text(size: font-size-normal)[#field-email],
      text(size: font-size-normal)[#field-mobile-number],
      grid.cell(stroke: (top: 1pt))[#__linguify-content("ai-dec-mail")],
      grid.cell(stroke: (top: 1pt))[#__linguify-content("ai-dec-tel-number")],
    )

    v(1.1cm)

    grid(
      columns: (3.4cm, 5.9cm, 8cm),
      text(size: font-size-normal)[#__linguify-content("ai-dec-for-module")],
      grid.cell(colspan: 2, text(
        size: font-size-normal,
      )[#field-module-name-semester]),
      [],
      grid.cell(
        colspan: 2,
        stroke: (top: 1pt),
        align: center,
      )[#__linguify-content("ai-dec-module-semester")],
      text(size: font-size-normal)[#__linguify-content("ai-dec-have-to-on")],
      grid.cell(colspan: 2, text(size: font-size-normal)[#field-date]),
      [],
      grid.cell(stroke: (top: 1pt), align: center)[#__linguify-content(
        "ai-dec-deadline-date",
      )],
      [],
    )
  }

  v(0.6cm)

  pad(right: 1cm)[

    #__linguify-content("ai-dec-following-examination")
    #v(0.35cm)

    #grid(
      columns: (4.2cm, 4.1cm, 1.7cm, 5.8cm),
      [#fill-check-rec("Projektarbeit I")],
      [#fill-check-rec("Projektarbeit II")],
      [#fill-check-rec("Sonstige")],
      [#h(2pt) #get-other-exam-types()],
      grid.cell(colspan: 3)[],
      grid.cell(align: center, stroke: (top: 1pt), text(
        size: font-size-small,
      )[#__linguify-content("specific-descr")]),
      grid.cell(colspan: 4, inset: (top: 0.15cm, bottom: 0pt))[],
      [#fill-check-rec("Seminararbeit")],
      [#fill-check-rec("Bachelorarbeit")],
    )

    #v(2.2cm)

    #__linguify-content("ai-dec-intro")
  ]

  v(1cm)

  pad(left: 0.6cm, right: 1.2cm)[
    #set list(body-indent: 1em)

    #{
      show text: strong
      list(
        spacing: 0.6cm,
        [#__linguify-content("ai-dec-informed-performance-restrictions")],
        [#__linguify-content("ai-dec-independence-controlling")],
        [#__linguify-content("ai-dec-scientific-independent-work")],
        [#__linguify-content("ai-dec-scientific-responsibility")],
        [#__linguify-content("ai-dec-no-other-tools")],
        [#__linguify-content("ai-dec-all-specified")],
      )
    }
  ]

  v(2.1cm)

  pad(right: 1.1cm)[
    #set par(justify: true)

    #underline(__linguify-content("ai-dec-title-products-first"))
    #__linguify-content("ai-dec-title-products-second")
    #{
      if (digital) {
        v(0.7cm)
        field-production-name
      } else {
        v(1cm)
        line(length: 100%)
      }
    }

    #v(1.3cm)

    #__linguify-content("ai-dec-title-used-functions")
    #v(1cm)

    - #__linguify-content("ai-dec-topic-structure")
    #v(1cm)
    #text-area(content: field-topic)

    - #__linguify-content("ai-dec-topic-processing")
    #v(1cm)
    #text-area(content: topic-editing)

    - #__linguify-content("ai-dec-research-choose")
    #v(1cm)
    #text-area(content: research)

    #set par(justify: false)

    - #__linguify-content("ai-dec-formal-design")
    #v(1cm)
    #text-area(content: design)
  ]

  v(1.8cm)

  pad(right: 0.5cm)[
    #block(stroke: 0.5pt, inset: 3pt)[
      #__linguify-content("notice")

      #__linguify-content("ai-dec-notice")
    ]
  ]
  v(1.6cm)

  set text(size: 9pt)

  set image(height: 25mm)

  grid(
    columns: (4.9cm, 10.1cm),
    column-gutter: 0.5cm,
    align(bottom, text(size: font-size-normal, field-signature)),
    place(bottom, signature),
    grid.cell(stroke: (top: 1pt), [#__linguify-content("place-date")]),
    grid.cell(stroke: (top: 1pt), [#__linguify-content("signature-student")]),
  )
}

//example usage
#ai-declaration-form(
  digital: true,
  name: "Max Mustermann",
  identification-number: "1234567",
  address: "Musterstraße 1, 68161 Mannheim",
  course: "IMB21",
  email: "max.mustermann@dhbw-mannheim.de",
  mobile-number: "0171 1234567",
  module-name: "Projektmanagement",
  module-submission-date: datetime
    .today()
    .display(
      "[day].[month].[year]",
    ),
  exam-type: "Projektarbeit I", //"Projektarbeit I", "Projektarbeit II", "Seminararbeit",   Bachelorarbeit"
  product-name: "ChatGPT, DeepL",
  topic: "Automatisierung von Geschäftsprozessen",
  topic-editing: __linguify-content("ai-dec-structure"),
  research: __linguify-content("ai-dec-research-ai"),
  design: __linguify-content("ai-dec-generation-correction"),
  signature-city: "Mannheim",
  signature-date: datetime
    .today()
    .display(
      "[day].[month].[year]",
    ),
)
