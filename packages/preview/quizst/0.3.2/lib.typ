// This function gets your whole document as its `body` and formats
#let quiz(
  title: none,
  authors: (),
  json_data: (),
  paper-size: "a4",
  highlight-answer: false,
  body
) = {
  // Determine document title based on quiz type
  let doc_title = if json_data.type == "lesson" {
    json_data.module + " - " + json_data.subject
  } else if title != none {
    title
  } else {
    json_data.title + (if "module" in json_data { " - " + json_data.module } else { "" })
  }

  set document(title: doc_title, author: authors.map(author => author.name))

  set page(
    paper: paper-size,
    numbering: "1/1",
    margin: (x: 21.5pt, top: 30.51pt, bottom: 30.51pt)
  )

  show link: it => [
    #set text(12pt, weight: 500, style: "italic", blue)
    #emph(underline(it))
  ]

  // Header based on quiz type
  v(3pt, weak: true)
  if json_data.type == "lesson" {
    align(center)[
      #text(24pt, smallcaps(json_data.module))
      #v(2mm)
      #text(18pt, json_data.subject + " - " + json_data.lesson)
    ]
  } else {
    align(center)[
      #text(24pt, smallcaps(json_data.title))
      #if "module" in json_data {
        v(2mm)
        text(18pt, json_data.module)
      }
      #if "tags" in json_data and json_data.tags.len() > 0 {
        v(2mm)
        text(14pt, json_data.tags.join(", "))
      }
    ]
  }
  v(5.35mm, weak: true)

  // Display the authors list.
  for i in range(calc.ceil(authors.len() / 3)) {
    let end = calc.min((i + 1) * 3, authors.len())
    let is-last = authors.len() == end
    let slice = authors.slice(i * 3, end)
    grid(
      columns: slice.len() * (1fr,),
      gutter: 14pt,
      ..slice.map(author => align(center, {
        text(12pt, author.prefix)
        if "name" in author [
          \ #emph(link(author.link)[#author.name])
        ]
      }))
    )
  }

  // Questions section
  set text(20pt, weight: 500)
  v(2em)
  
  for mcq in json_data.questions [
    + #mcq.question:
      #set text(17pt, weight: 500)
      #block(inset: (left: 1.5em))[
        #for opt in ("a", "b", "c", "d", "e", "f", "g") {
          if opt in mcq and mcq.at(opt) != "" {
            if highlight-answer and opt == mcq.answer {
              highlight(opt + ") " + mcq.at(opt))
            } else {
              opt + ") " + mcq.at(opt)
            }
            linebreak()
          }
        }
      ]
    #linebreak()
  ]

  // Answers section
  v(3em)
  align(center, text(24pt, smallcaps("Answers")))
  v(1em)

  grid(
    align: center,
    columns: (1fr, 1fr, 1fr, 1fr),
    gutter: 1em,
    ..json_data.questions.map(mcq => [#mcq.sn. #mcq.answer])
  )

  // add body
  body
}