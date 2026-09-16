#import "frontmatter.typ": frontmatter
#import "appendix.typ": appendix

#let thesis(
  title: "thesis-title",
  author: "thesis-author",
  degree: "thesis-degree",
  field: "thesis-field",
  committee-members: (
    (name: "thesis-chair", role: "thesis-chair-role"),
    (name: "thesis-member-1", role: "thesis-member-1-role")
  ),
  semester: "Spring",
  year: 2026,

  abstract: [#lorem(150)],
  acknowledgement: [#lorem(150)],
  appendices: (
    [#lorem(150)],
    [#lorem(150)]
  ),
  bib,
  doc
) = [
  // general formatting / spacing
  #set page(
    paper: "us-letter",
    margin: (top: 1.25in, bottom: 1in, left: 1in, right: 1in),
    number-align: top + right
  )
  #set par(justify: true, first-line-indent: 1.5em)
  #set text(size: 12pt)

  #show heading.where(level: 1): set text(size: 20pt)
  #show heading.where(level: 2): set text(size: 18pt)
  #show heading.where(level: 3): set text(size: 16pt)

  // https://forum.typst.app/t/figure-and-table-captions-with-chapter-number/1520/5
  #set figure(numbering: (..num) => 
    numbering("1.1", counter("chapter").get().first(), num.pos().first())
  )

  #let chapter-heading(it) = {
    // reset counters so they are counted per chapter.
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)

    // chapter counter
    counter("chapter").step()

    set text(size: 24pt, weight: "bold", hyphenate: false)
    set par(first-line-indent: 0em)

    pagebreak()
    v(2em)
    
    let chapter = counter("chapter")
    let chapter-num = chapter.get().first()

    [  
      Chapter #chapter.display(it.numbering)
      
      #it.body
      #label("chapter-" + str(chapter-num) + "-inner")
      #v(1em)
    ]
  }

  // pdf metadata
  #set document(title: title, author: author)

  #frontmatter(
    title: title,
    author: author,
    degree: degree,
    field: field,
    committee-members: committee-members,
    semester: semester,
    year: year,
    abstract: abstract,
    acknowledgement: acknowledgement
  )

  // make hyperlinks more visible
  #show link: underline
  #show link: set text(blue)

  // need to reset page numbering / heading numbering after frontmatter
  #counter(page).update(1)
  #set page(numbering: "1")
  #counter(heading).update(0)

  // main contents
  #[
    // depth-1 and depth-2 heading numberings
    #let numbering-fn = (..nums) => nums.pos().map(str).join(".")
    #show heading.where(level: 1): set heading(numbering: numbering-fn)
    #show heading.where(level: 2): set heading(numbering: numbering-fn)
    
    // use chapter-heading to get ucbthesis-like chapter headings
    #show heading.where(level: 1): it => {
      chapter-heading(it)
    }

    // header includes chapter, unless chapter-heading is on the same page
    #set page(header: context {
      let this_page = here().page()
      let logical_page = counter(page).get().first()
      let current_chapter = counter("chapter").get().first()
      if current_chapter == 0 {
        return align(right, [#logical_page])
      }

      let current_chapter_lbl = query(label("chapter-" + str(current_chapter) + "-inner")).first()
      let current_chapter_lbl_page = current_chapter_lbl.location().page()
      let current_page_has_chapter_title = current_chapter_lbl_page == this_page
      
      if current_page_has_chapter_title {
        return align(right, [#logical_page])
      }

      let header_text = "CHAPTER " + str(current_chapter) + ": " + upper(current_chapter_lbl)

      [
        #emph([#header_text])
        #box(width: 1fr)
        #logical_page
      ]
    
    })

    #doc
  ]

  // appendix counts as additional chapter for purpose of figure / table numbering
  #counter("chapter").step()
  #pagebreak()
  #appendix(contents: appendices)

  // references
  #pagebreak()
  #bib
]