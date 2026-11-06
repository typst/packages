#let school-color = rgb(165, 28, 48)

#let frontmatter(
    title: none,
    abstract: [],
    author: "John Harvard",
    advisor: "Dear Advisor",
    department: "Department of Physics",
    doctor-of: "Philosophy",
    major: "Physics",
    completion-date: datetime.today().display("[month repr:long] [year]"),
    creative-commons: true,
    doc
) = {
    set page(
        paper:"us-letter",
        // margin is automatically 2.5/11 times the short side of us-letter
        // which is about 1.01 inch
        margin: (x: 1.375in,
            y: 1.375in
        ),
        numbering: "I",
    )
    set text(font:"New Computer Modern", size:12pt)

    set heading(numbering: "1.1")
    show heading.where(
        level: 1, outlined: true
    ): it => [
        #set align(right)
        #set text(20pt, weight: "regular")
        #pagebreak()
        #v(25%)
        #text(100pt, school-color, counter(heading).display())\
        #text(24.88pt, it.body)
        #v(4em)
    ]
    show heading.where(level: 1): smallcaps
    show heading.where(level: 1): it => {
      counter(math.equation).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      it
    }
    set math.equation(numbering: (..num) =>
      numbering("(1.1)", counter(heading).get().first(), num.pos().first())
    )
    set figure(numbering: (..num) =>
      numbering("1.1", counter(heading).get().first(), num.pos().first())
    )
    set page(numbering:none)
    set align(center + horizon)
    counter(page).update(1)
    grid(
        [
            #text(school-color, 24.88pt)[#(title)]

            #v(100pt)
            #show: smallcaps

            A dissertation presented\
            by\
            #author\
            to\
            The #department\
            #v(12pt)
            in partial fulfillment of the requirements\
            for the degree of\
            Doctor of #doctor-of\
            in the subject of\
            #major
            #v(12pt)
            Harvard University\
            Cambridge, Massachusetts\
            #completion-date
        ]
    )

    pagebreak()
    show link: it => {set text(fill: school-color); it}

    [
        #if creative-commons [
            This work is licensed via #underline[
                #link("https://creativecommons.org/licenses/by/4.0/")[CC BY 4.0]
            ]
        ]

        Copyright #sym.copyright #datetime.today().display("[year]") #author
    ]
    pagebreak()

    // "Preliminary pages (abstract, table of contents, list of tables, graphs, illustrations, and
    // preface) should use small Roman numerals"
    set page(numbering: "I")
    set align(top)
    grid(
        columns:(auto, 1fr, auto),
        [Dissertation Advisor: #advisor],
        [],
        [#author]
    )

    v(5%)
    text(school-color, 17.28pt)[#(title)]
    v(7%)

    // to mimic Double Spacing
    // https://github.com/typst/typst/issues/106#issuecomment-2041051807
    set text(top-edge: 0.7em, bottom-edge: -0.4em)
    set par(justify:true, spacing: 1.8em, leading: 1em)


    [*Abstract*]

    set align(left)
    abstract
    pagebreak()

    show outline.entry.where(level: 1): set outline.entry(fill: none)
    show outline.entry.where(level: 1): it => {smallcaps(it)}

    show ref: it => {set text(fill: school-color); it}
    show figure.caption: it => [
      #set text(size: 10pt)
      #set par(justify:true)
      #set align(left)
      #strong([#it.supplement
        #context it.counter.display(it.numbering):
      ]) #it.body
      ]

    outline(
        title: grid([
            #set text(23pt)
            #h(1fr)
            Contents
            #v(2em)
        ])
    )


    set page(numbering:none)
    counter(page).update(1)
    set page(numbering:"1")
    doc
}
