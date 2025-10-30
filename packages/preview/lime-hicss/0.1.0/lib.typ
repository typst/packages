#import "@preview/wordometer:0.1.4": word-count, total-words

// This function gets your whole document as its `body` and formats
// it as an article in the style of the hicss.
#let hicss(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // A list of index terms to display after the abstract.
  key-words: (),

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // The paper's content.
  body
) = {
  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))

  // Adapt supplement in caption independently from supplement used for
  // references.
  set figure.caption(separator: [. ])
  show figure: fig => {
    let prefix = (
      if fig.kind == table [TABLE]
      else if fig.kind == image [Figure]
      else [#fig.supplement]
    )
    let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    // Wrap figure captions in block to prevent the creation of paragraphs. In
    // particular, this means `par.first-line-indent` does not apply.
    // See https://github.com/typst/templates/pull/73#discussion_r2112947947.
    show figure.caption: it => block[#prefix~#numbers#it.separator#h(1em)#it.body]
    show figure.caption.where(kind: table): smallcaps
    // [HICSS.tex]: Figure and table captions should be 9-point boldface Helvetica.
    // [HICSS.sty]: \fontfamily{cmss}\selectfont \textbf
    set text(9pt, weight: "bold", font: "TeX Gyre Heros")
    set block(above: 12pt, below: 12pt)
    fig
  }
  // [HICSS.tex]: Type your main text in 10-point Times, single-spaced. [...] All paragraphs should be indented 1/4 inch (approximately 0.5 cm). Be sure your text is fully justified [...]
  // Set the body font.
  set text(font: "TeX Gyre Termes", size: 10pt)
  set par(first-line-indent: 1in/4, justify: true, spacing: 0em)

  // Code blocks
  show raw: set text(
    font: "TeX Gyre Cursor",
    ligatures: false,
    size: 1em / 0.8,
    spacing: 100%,
  )

  // Configure the page and multi-column properties.
  // [HICSS.tex]: Columns are to be 3 inches (7.85 cm) wide, with a 5.1/16 inch (0.81 cm) space between them.
  set columns(gutter: 5.1in/16)
  set page(
    columns: 2,
    paper: "us-letter",
    // The margins depend on the paper size.
    margin: (
      // [HICSS.tex]: The second and following pages should begin 1.0 inch (2.54 cm) from the top edge. On all pages, the bottom margin should be 1-1/8 inches (2.86 cm) from the bottom edge of the page for 8.5 x 11-inch paper. (Letter-size paper)
      top: 1in,
      bottom: 1in,
    )
    
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 1in/4, body-indent: 0.5em, spacing: 1em)
  set list(indent: 1in/4, body-indent: 0.5em, spacing: 1em)
  show enum: set block(above: 1em, below: 1em)
  show list: set block(above: 1em, below: 1em)

  // Configure headings.
  set heading(numbering: (..n) => numbering("1.1.1.", ..n) + h(1em))
  show heading.where(level: 1): set text(size: 12pt)
  show heading.where(level: 2): set text(size: 11pt)
  show heading.where(
    level: 3
  ): it => {
    // https://forum.typst.app/t/can-i-format-a-heading-without-a-newline/4227/2
    v(12pt + 0.65em)
    h(-10pt)  // HACK: remove first-line-indent
    box([#it]) + "."
  }

  
  // [HICSS.tex]: headings... with one 12-point blank line before, and one blank line after.
  // note: 0.3em is half of the default line spacing, which is 0.65em.
  show heading: set block(above: 12pt + 0.3em, below: 12pt + 0.3em)
  
  // unused stuff about handling an acknowledgements section.
  // show heading: it => {
  //   // Find out the final number of the heading counter.
  //   let levels = counter(heading).get()
  //   let deepest = if levels != () {
  //     levels.last()
  //   } else {
  //     1
  //   }

  //   set text(10pt, weight: 400)
  //   if it.level == 1 {
  //     // We don't want to number the acknowledgment section.
  //     let is-ack = it.body in ([Acknowledgment], [Acknowledgement], [Acknowledgments], [Acknowledgements])
  //     set text(if is-ack { 10pt } else { 12pt }, weight: "bold")
  //     show: block.with(above: 15pt, below: 13.75pt, sticky: true)
  //     if it.numbering != none and not is-ack {
  //       numbering("1.1.1.", deepest)
  //     }
  //     it.body
  //   } else if it.level == 2 {
  //     // Second-level headings are run-ins.
  //     set text(style: "italic")
  //     show: block.with(spacing: 10pt, sticky: true)
  //     if it.numbering != none {
  //       numbering("A.", deepest)
  //       h(7pt, weak: true)
  //     }
  //     it.body
  //   } else [
  //     // Third level headings are run-ins too, but different.
  //     #if it.level == 3 {
  //       numbering("a)", deepest)
  //       [ ]
  //     }
  //     _#(it.body):_
  //   ]
  // }

  // [HICSS.tex]: List and number all bibliographical references in 9-point Times, single-spaced, and in an alphabetical order at the end of your paper.
  show std.bibliography: set text(9pt)  
  set std.bibliography(title: text(12pt)[References], style: "american-psychological-association")

  show std.bibliography: it => {
    show par: set par(hanging-indent: 2.5in)
    it
  }

  // Display the paper's title and authors at the top of the page,
  // spanning all columns (hence floating at the scope of the
  // columns' parent, which is the page).
  place(
    top,
    float: true,
    scope: "parent",
    block(
      height: 5cm,
      {
        {
          // The main title (on the first page) should begin 1-3/8 inches (3.49 cm) from the top edge of the page, centered, and in Times 14-point, boldface type.
          v(3in/8)
          set align(center)
          set text(size: 14pt, weight: "bold")
          block(
            title,
            // Leave two 12-point blank lines after the title.
            below: 12pt * 2,
          )

        }

        // TODO: adapt authors to HICSS template.
        // Display the authors list.
        set par(leading: 0.6em)
        for i in range(calc.ceil(authors.len() / 3)) {
          let end = calc.min((i + 1) * 3, authors.len())
          let is-last = authors.len() == end
          let slice = authors.slice(i * 3, end)
          grid(
            columns: slice.len() * (1fr,),
            gutter: 12pt,
            ..slice.map(author => align(center, {
              text(size: 11pt, author.name)
              if "department" in author [
                \ #emph(author.department)
              ]
              if "organization" in author [
                \ #emph(author.organization)
              ]
              if "location" in author [
                \ #author.location
              ]
              if "email" in author {
                if type(author.email) == str [
                  \ #link("mailto:" + author.email)
                ] else [
                  \ #author.email
                ]
              }
            }))
          )
  
          if not is-last {
            v(16pt, weak: true)
          }
        }
      }
    )
    
  )

  set par(justify: true, first-line-indent: (amount: 1em, all: true), spacing: 0.5em, leading: 0.5em)

  // Display abstract and index terms.
  if abstract != none {

    
    [
      // [HICSS.tex]: Use the word “Abstract” as the title, in 12-point Times, boldface type, centered relative to the column, initially capitalized.

      #set align(center)
      #set text(size: 12pt, weight: "bold")
      Abstract
      // [HICSS.tex]: `\vskip 2ex`
      #v(12pt)
    ]
    
    // [HICSS.tex]: The abstract is to be in fully-justified italicized text, at the top of the left-hand column as it is here, below the author information.
    
    word-count(total => {
      text(style: "italic", abstract)

      if total.words > 150 [
        #set text(fill: red)
        Word count of abstract exceeds limit of 150 words. Word count: #total.words<no-wc>
      ]
    }, exclude: <no-wc>)
    
    // [HICSS.tex]: The abstract is to be in 10-point, single-spaced type, and up to 150 words in length. Leave two blank lines after the abstract, and then begin the main text.

    if key-words != () {
        v(12pt)
        par(
          first-line-indent: 0em,
          [*Keywords*: #key-words.join[, ]]
        )
    }
  }

  // Display the paper's contents.
  body

  // Display bibliography.
  bibliography
}
