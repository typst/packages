#import "@preview/wordometer:0.1.4": word-count, total-words
#import "@preview/cetz:0.3.4"

// LaTeX font sizes: https://tex.stackexchange.com/a/24600
#let font-sizes = (
  footnotesize: 8pt,
  small: 9pt,
  large:  12pt,
  Large:  14.4pt,
  huge:  20.74pt
)

/// Put the name of an author in the margin next to the previous heading.
/// - content (content): The name of the author.
/// -> content
/// ```example
/// >>>#import "@preview/amsterdammetje-article:0.1.1": heading-author
/// >>>#set text(0.7em)
/// == A heading
/// #heading-author[John Doe]
/// The author's name is in the margin.
/// ```
#let heading-author(content) = context {
  let heading-pos = query(
    selector(heading).before(here()),
  ).last().location().position()
  let here-pos = here().position()

  place(
    move(
      dx: -here-pos.x + 2.5mm,
      dy: -here-pos.y + heading-pos.y,
      box(width: 25mm, align(right, text(content, font-sizes.footnotesize)))
    )
  )
}

/// Return either the Dutch or English input based on the document language.
/// - nl (content): The Dutch content.
/// - en (content): The English content.
/// -> content
#let nl-en(nl, en) = context {
  if text.lang == "nl" { nl } else { en }
}

/// Add an abstract to the document.
/// - content (content): The text inside the abstract.
/// -> content
#let abstract(content) = {
  set text(font-sizes.small)
  set par(first-line-indent: (amount: 1.8em, all: true), justify: false)
  v(1em)
  align(center,
    strong(nl-en[Samenvatting][Abstract])
  )
  v(0.5em)
  box(
    inset: (x: 22pt),
    content
  )
}

/// The actual template. Use it in a `show` rule to wrap the entire document in
/// a function call.
/// - authors (array, str): The authors of the document.
/// - ids (array, str): The UvAnetIDs of the authors.
///   The first ID corresponds with the first author,
///   the second ID with the second author, etc.
/// - tutor (str, none): 
/// - mentor (str, none): 
/// - group (str, none): 
/// - lecturer (str, none): 
/// - course (str, none): 
/// - course-id (str, none): You can find this on #link("https://datanose.nl")[DataNose].
/// - assignment-name (str, none): The name of the assignment as given by the instructor.
/// - assignment-type (str, none): The type of the assignment,
///   such as "technical report" or "essay".
/// - title (str, none): 
/// - date (datetime): 
/// - link-outline (bool): Whether to surround links with a rectangle,
///   similar to what hyperref does.
/// -> function
#let article(
  authors: (),
  ids: (),
  tutor: none,
  mentor: none,
  group: none,
  lecturer: none,
  course: none,
  course-id: none,
  assignment-name: none,
  assignment-type: none,
  title: "",
  date: datetime.today(),
  link-outline: true
) = doc => {
  let authors = if type(authors) == str { (authors,) } else { authors }
  let ids = if type(ids) == str { (ids,) } else { ids }

  // LaTeX look: https://typst.app/docs/guides/guide-for-latex-users/#latex-look
  set page(margin: (rest: 30mm, top: 35mm))
  set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
  set text(font: "New Computer Modern", 10pt)
  show raw: set text(font: "New Computer Modern Mono", 10pt)
  set par(spacing: 0.55em)
  show heading: set block(above: 1.4em, below: 1em)

  set heading(numbering: "1.1  ")
  set document(title: title, author: authors, date: date)
  set bibliography(style: "american-sociological-association")
  show figure.where(kind: table): set figure.caption(position: top)
  show bibliography: set par(first-line-indent: 0em)

  set outline.entry(fill: repeat([.], gap: 0.5em))
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): body => linebreak() + strong(body)

  let stroke = none
  if link-outline {
    stroke = 0.5pt + color.rgb(0, 255, 255)
  }
  show link: body => box(body, stroke: stroke)
  show ref: body => box(body, stroke: stroke)

  // Draw an Andrew's cross (known as Andreaskruis in Dutch) in a Cetz canvas.
  let andrew-cross(color: black) = {
    import cetz.draw: *
    group({
      rotate(45deg)
      line(
        (1, 0), (2, 0), (2, 1), (3, 1), (3, 2), (2, 2),
        (2, 3), (1, 3), (1, 2), (0, 2), (0, 1), (1, 1),
        close: true,
        fill: color,
        stroke: none,
      )
    })
  }

  // Draw a line of Andrew's crosses.
  let andrew-line(scale-factor, amount, distance, gradient: false) = {
    set align(center)
    cetz.canvas({
      import cetz.draw: *

      for i in range(amount) {
        group({
          translate(x: i * distance)
          scale(scale-factor)

          if gradient {
            andrew-cross(
              color: color.luma(calc.floor(255 * (
                1 - calc.sin((i + 2) * calc.pi / (amount + 2))
              ))),
            )
          } else {
            andrew-cross(color: color.luma(64))
          }
        })
      }
    })
  }

  // Format the given date in Dutch.
  let format-date-nl() = {
    let months = (
      [januari], [februari], [maart], [april], [mei], [juni],
      [juli], [augustus], [september], [oktober], [november], [december],
    )
    [#date.day() #months.at(date.month() - 1) #date.year()]
  }

  // Format the given date in English.
  let format-date-en() = {
    let months = (
      [January], [February], [March], [April], [May], [June],
      [July], [August], [September], [October], [November], [December],
    )
    [#months.at(date.month() - 1) #date.day(), #date.year()]
  }

  // Return an entry for the right column on the first page.
  let meta-info(nl, en, value) = {
    if value != none [
      _#nl-en(nl, en):_ \
      #value
      #v(0.2cm)
    ]
  }

  // Put the UvA logo and assignment name in the header of every page, except
  // the first.
  set page(
    header: context {
      let c = counter(page)
      if c.get() != (1,) {
        stack(
          dir: ltr,
          nl-en(
            image("logoUvA_nl.svg", width: 5cm),
            image("logoUvA_en.svg", width: 5cm),
          ),
          align(right,
            text(font-sizes.footnotesize,
              smallcaps[
                #assignment-type \
                #assignment-name
              ]
            )
          ),
        )
        andrew-line(0.04, 74, 0.2)
      }
    },
  )

  // Add the page count and word count / authors in the footer.
  set page(
    footer: context {
      andrew-line(0.04, 74, 0.2)

      let c = counter(page)
      if c.get() == (1,) {
        text(font-sizes.small,
          emph[#total-words #nl-en[woorden][words]]
        )
      } else {
        text(font-sizes.footnotesize, authors.join([, ]))
      }

      h(1fr)

      upper(
        text(font-sizes.small * 0.8,
          c.display(
            both: true,
            (from, to) => {
              nl-en[pagina #from van #to][page #from of #to]
            },
          )
        )
      )
    },
  )

  show: word-count

  // The front page of the document.
  align(
    stack(
      nl-en(
        image("logoUvA_nl.svg", width: 7cm),
        image("logoUvA_en.svg", width: 7cm),
      ),
      v(1cm),
      text(font-sizes.Large, smallcaps(assignment-name)),
      v(0.4cm),
      text(font-sizes.huge, strong(title)),
      v(0.4cm),
      andrew-line(0.1, 29, 0.5, gradient: true),
      v(0.4cm),
      text(font-sizes.large, nl-en(format-date-nl(), format-date-en())),
      v(0.5cm),

      grid(columns: (1fr, 41%, 41%, 1fr),
        [],
        align(left + horizon)[
          _#if authors.len() == 1 {
            [Student]
          } else {
            nl-en[Studenten][Students]
          }:_ \
          #authors.zip(ids).map(((author, id)) => [
            #author \
            #text(font-sizes.small, id)
            #v(0.2cm - 0.5em) \
          ]).join()
        ],
        align(right + horizon)[
          #meta-info([Tutor], [Tutor], tutor)
          #meta-info([Mentor], [Mentor], mentor)
          #meta-info([Practicumgroep], [Group], group)
          #meta-info([Docent], [Lecturer], lecturer)
          #meta-info([Cursus], [Course], course)
          #meta-info([Vakcode], [Course code], course-id)
        ],
        [],
      ),
    ), center,
  )

  doc
}
