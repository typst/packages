#import "@preview/hydra:0.6.0": hydra, anchor

#let front-matter(config) = context {
  let lang = config.lang
  let ttype = config.ttype
  let title = config.title
  let supervisor = config.supervisor
  let year = config.year
  let faculty = config.faculty
  let institute = config.institute
  let linguify = config.linguify
  set page(numbering: none)

  let signet_imgpath
  if lang == "pl" {
    signet_imgpath = "../assets/sygnet-pp-pl.svg"
  } else {
    signet_imgpath = "../assets/sygnet-pp-en.svg"
  }

  place(center + top, dy: 41pt)[
    #figure(
      image(signet_imgpath, width: 100%),
    )
    #v(-4pt)
    #upper(faculty)\
    #institute
  ]

  place(center + top, dy: 298pt)[
    #linguify(ttype + "-caption")
    #v(24pt)
    #text(size: 11.75pt, upper(strong(title)))
    #v(45pt)
    #let authors_block = [
      #for (student, student_id) in config.authors [
        #text(size: 11pt)[#student, #student_id]
        #v(-4pt)
      ]
    ]
    #authors_block
    #let authors_block_h = measure(authors_block).height
    #v(107pt - authors_block_h)
    #linguify("supervisor")\
    #supervisor
    #v(74pt)
    POZNAŃ #year
  ]
  pagebreak(weak: true)

  place(center + horizon, linguify("diploma-card-page"))
  pagebreak(weak: true, to: "odd")
}

// This is a bit of a hack, see https://github.com/tingerrr/hydra/issues/29
// Basically, hydra is supposed to automatically detect headings, and it should
// not be necessary to call the `anchor()` here. But since we're breaking some
// conventions hydra relies on with the custom Chapter headings, this is the
// only way to appease it.
#let header() = anchor() + context {
  // Do not show anything on chapter pages
  let following_chapters = query(selector(heading.where(level: 1)).after(here()))
  if following_chapters.len() > 0 {
    let next_chapter = following_chapters.first()
    if next_chapter.location().page() == here().page() {
      return
    }
  }

  let chapter = hydra(2, skip-starting: false)
  let page_num = numbering("1", ..counter(page).at(here()))

  if not state("book-print").get() or calc.odd(here().page()) {
    emph(chapter)
    h(1fr)
    page_num
  } else {
    page_num
    h(1fr)
    emph(chapter)
  }
}

#let footer() = context {
  // Show page number, only on chapter pages
  let preceding_chapters = query(selector(heading.where(level: 1)).before(here()))
  if preceding_chapters.len() > 0 {
    for chapter in preceding_chapters {
      if chapter.location().page() == here().page() {
        let page_num = numbering("1", ..counter(page).at(here()))
        return align(center, page_num)
      }
    }
  }
  none
}

#let colophon(config) = {
  let authors = config.authors
  let year = config.year
  let faculty = config.faculty
  let institute = config.institute
  let linguify = config.linguify
  pagebreak(weak: true)
  set page(numbering: none)
  set text(size: 8.5pt)
  set par(leading: 0.5em)
  place(left + bottom, dy: -5pt)[
    #image("../assets/logo-pp.svg", width: 15mm)
  ]
  place(left + bottom, dx: 19.5mm, dy: 2pt)[
    $copyright$
    #year
    #authors.map(x => x.at(0)).join(", ")

    #institute, #faculty\
    #linguify("put")

    #linguify("colophon-extra")
  ]
}
