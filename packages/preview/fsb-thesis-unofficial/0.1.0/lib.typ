#let project(
  title: "",
  subtitle: none,
  author: "",
  degree: "Master of Software Engineering",
  university: "FPT UNIVERSITY",
  ministry: "MINISTRY OF EDUCATION AND TRAINING",
  supervisors: (),
  year: str(datetime.today().year()),
  abstract: [],
  acknowledgments: [],
  // We keep this optionally, but for full control you can place it manually
  bibliography: none,
  appendix: [],
  body,
) = {
  // --- 1. Global Setup ---
  set document(author: author, title: title)
  set text(font: "Times New Roman", size: 12pt, lang: "en")
  set page(paper: "a4", margin: 2.5cm)
  set par(leading: 0.7em, first-line-indent: 0pt, spacing: 12pt, justify: true)

  // --- 2. Cover Page ---
  page(header: none, footer: none)[
    #set align(center)
    #v(1cm)
    #text(weight: "bold")[#ministry \ #university]
    #v(4cm)
    #text(weight: "bold", size: 16pt, title)
    #if subtitle != none {
      par(leading: 0.5em)[#subtitle]
    }
    #v(4cm)
    by \
    #text(weight: "bold", author)
    #v(1fr)
    A thesis submitted in conformity with the requirements \
    for the degree of #degree
    #v(2cm)
    Copyright by #author \
    #year
  ]

  // --- 3. Title Page ---
  page(header: none, footer: none)[
    #set align(center)
    #v(1cm)
    #text(weight: "bold")[#ministry \ #university]
    #v(3cm)
    #text(weight: "bold", size: 16pt, title)
    #v(3cm)
    by \
    #text(weight: "bold", author)
    #v(1fr)
    A thesis submitted in conformity with the requirements \
    for the degree of #degree
    #v(1fr)
    #align(left)[
      #text(weight: "bold")[Supervisor:]
      #grid(
        columns: (auto, auto),
        gutter: 1em,
        ..supervisors
          .enumerate()
          .map(((i, name)) => (
            [#(i + 1).],
            [#name],
          ))
          .flatten()
      )
    ]
    #v(2cm)
    Copyright by #author \
    #year
  ]

  // --- 4. Abstract ---
  page[
    #set align(center)
    #text(weight: "bold", size: 14pt)[#title] \
    #v(0.5em)
    #author \
    Degree: #degree \
    #university \
    Year of Convocation: #year
    #v(1cm)
    #text(weight: "bold", size: 14pt)[Abstract]
    #set align(left)
    #set par(leading: 1em)
    #abstract
  ]

  // --- 5. Acknowledgments ---
  if acknowledgments != [] {
    page[
      #heading(outlined: false, numbering: none)[Acknowledgments]
      #acknowledgments
    ]
  }

  // --- 6. Front Matter ---
  set page(numbering: "i")
  counter(page).update(1)

  outline(title: "Table of Contents", indent: auto)
  pagebreak()

  context {
    let figs = query(figure.where(kind: table))
    if figs.len() > 0 {
      outline(title: "List of Tables", target: figure.where(kind: table))
      pagebreak()
    }
  }

  context {
    let figs = query(figure.where(kind: image))
    if figs.len() > 0 {
      outline(title: "List of Figures", target: figure.where(kind: image))
      pagebreak()
    }
  }

  context {
    let figs = query(figure.where(kind: "appendix"))
    if figs.len() > 0 {
      outline(title: "List of Appendices", target: figure.where(kind: "appendix"))
      pagebreak()
    }
  }

  // --- 7. Main Body ---
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(2em)
    align(center, text(size: 14pt, weight: "bold", it))
    v(1em)
  }
  show heading.where(level: 2): it => {
    text(size: 12pt, weight: "bold", it)
    v(0.5em)
  }

  body

  // Note: Bibliography is now manual to allow correct ordering before Appendices
  if bibliography != none {
    pagebreak()
    set text(size: 12pt)
    bibliography
  }

  // --- 8. Appendices ---
  if appendix != [] and appendix != none {
    // Reset counter and change numbering to Alpha (A.1)
    counter(heading).update(0)
    set heading(numbering: "A.1")

    // Custom display for Appendix Heading 1: "Appendix A: Title"
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      // Create a phantom figure to populate the List of Appendices
      // We put it here so it registers with the correct page number
      // but doesn't affect visual layout significantly (it's empty/hidden).
      // Typst doesn't have a pure "phantom" figure yet, but we can hide it.
      // However, standard `outline` picks up the caption.
      // We want the outline to show "Appendix A: Title".
      // The standard Outline for figures usually shows "Figure 1: Caption".
      // We can force the caption to be what we want.

      let appendix-number = counter(heading).display("A")
      let entry-title = [Appendix #appendix-number: #it.body]

      // We insert a hidden figure.
      // using place so it doesn't take up layout space
      // using hide so it is not visible
      context {
        place(hide(figure(
          kind: "appendix",
          supplement: "",
          numbering: none,
          caption: entry-title,
          [],
        )))
      }

      v(2em)
      align(center, text(size: 14pt, weight: "bold")[
        #entry-title
      ])
      v(1em)
    }

    appendix
  }
}
