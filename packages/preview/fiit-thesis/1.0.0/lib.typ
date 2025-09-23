#import "pages.typ": *
#import "_pkgs.typ": muchpdf
#import "localization.typ": localization

#let _lang = state("lang")
#let _is-legacy = state("is-legacy")
#let _style = state("style")
#let _appendix-numbering = "A.1"

#let fiit-thesis(
  // title of your thesis
  title: "Záverečná práca",
  // type of the thesis: "bp1", "bp2", "dp1", "dp2", "dp3"
  thesis: "bp2",
  // a dictionary of type: <language_code>: <abstract>. Both "en" and "sk" are
  // mandatory
  abstract: (
    sk: lorem(150),
    en: lorem(150),
  ), // abstract
  // your full name
  author: "Jožko Mrkvička",
  // ID that you copied from AIS
  id: "FIIT-12345-123456",
  // full name of your thesis supervisor
  supervisor: "prof. Jozef Mrkva, PhD.",
  // supported values: "en", "sk"
  lang: "en",
  // acknowledgment text
  acknowledgment: [I would like to thank my supervisor for all the help and
    guidance I have received. I would also like to thank my friends and family
    for supporting during this work.],
  // assignment from AIS file path. DO NOT USE THIS FOR FINAL HAND-IN
  assignment: none,
  // enable list of tables
  tables-outline: false,
  // enable list of images (figures)
  figures-outline: false,
  // if this array is empty, the list of abbreviations does not appear
  abbreviations-outline: (),
  // set to "true" to disable the first (cover) sheet
  disable-cover: false,
  // style of the thesis
  // options: "regular", "compact", "legacy", "legacy-noncompliant",
  // "pagecount"
  style: "regular",
  body,
) = {
  ////////////////////////////////
  // style handling
  let is-legacy = style == "legacy" or style == "legacy-noncompliant"

  // regular style
  let text-size = 1.1em
  let page-margins = 3cm
  let bibliography-style = "iso-690-numeric"
  let use-binding = false
  let regular-headings = true

  let first-line-indent = 1em
  let leading = 1.3em
  let spacing = 1.5em
  let footer-descent = 30% + 0pt
  let header-ascent = 30% + 0pt
  let header-margin = if is-legacy { -1.6em } else { -1em }
  let header = context {
    let hdr = hydra(1)
    if hdr != none and style != "pagecount" {
      if is-legacy {
        hydra(
          display: (_, current-heading) => if current-heading.numbering
            != none {
            current-heading.supplement
            [ ]
            numbering(
              current-heading.numbering,
              counter(heading).at(current-heading.location()).at(0),
            )
            [. ]
            current-heading.body
          } else {
            current-heading.body
          },
          skip-starting: false,
        )
      } else {
        emph(hdr)
      }
      v(header-margin)
      line(length: 100%)
    }
  }

  if style == "compact" {
    page-margins = 2.5cm
    regular-headings = false
    leading = 0.8em
    spacing = 1.5em
    text-size = 1.2em
  } else if is-legacy {
    // general legacy styles
    page-margins = (
      inside: 1.5in,
      outside: 1in,
      top: 1.5in,
      bottom: 2in,
    )
    use-binding = true
    first-line-indent = 0em
    leading = 1.1em
    spacing = 2em
    footer-descent = 2em
    header-ascent = 2em
  } else if style == "pagecount" {
    leading = 1.2em
    spacing = leading
    first-line-indent = 0em
  }

  if style == "legacy-noncompliant" {
    bibliography-style = "ieee"
  }

  ////////////////////////////////
  // locale
  let locale = localization(lang: lang)
  let slovak = localization(lang: "sk")
  let english = localization(lang: "en")
  _lang.update(lang)
  _style.update(style)

  ////////////////////////////////
  // pagecount handling
  show pagebreak: it => if style == "pagecount" { none } else { it }
  show bibliography: it => if style == "pagecount" { none } else { it }
  show outline: it => if style == "pagecount" { none } else { it }
  show figure: it => if style == "pagecount" { none } else { it }
  show colbreak: it => if style == "pagecount" { none } else { it }

  show list.item: it => if style == "pagecount" { it.body } else { it }
  show list: it => if style == "pagecount" { it.body } else { it }
  show columns: it => if style == "pagecount" { it.body } else { it }
  show align: it => if style == "pagecount" { it.body } else { it }

  ////////////////////////////////
  // page setup

  set document(author: author, title: title)
  set text(font: "New Computer Modern", lang: lang)
  show math.equation: set text(weight: 400)
  set bibliography(style: bibliography-style, title: locale.bibliography)

  ////////////////////////////////
  // setup headings
  set heading(numbering: "1.1", supplement: locale.chapter.title)
  show heading: it => {
    if style != "pagecount" {
      if style != "compact" {
        set text(1.1em, weight: "semibold")
        numbering(it.numbering, ..counter(heading).at(it.location()))
        h(0.6cm)
        it.body
        v(-.2cm)
      } else {
        it
      }
    }
  }
  show heading.where(level: 1): it => {
    if style == "pagecount" {
      return
    }
    if regular-headings {
      // regular, legacy and legacy-noncompliant
      set text(1.6em, weight: if is-legacy { "medium" } else { "bold" })
      set par(first-line-indent: 0em)

      pagebreak(to: if use-binding { "odd" } else { none }, weak: true)
      if it.numbering == _appendix-numbering and not is-legacy {
        counter(page).update(1)
      }
      pagebreak(weak: true)
      block(height: 2.8cm)
      if it.numbering != none {
        [#it.supplement #numbering(it.numbering, counter(heading).get().at(0))]
        v(0cm)
      }
      it.body
      v(.4cm)
    } else {
      // compact
      pagebreak()
      if it.numbering == _appendix-numbering {
        counter(page).update(1)
      }
      pagebreak(weak: true)
      if it.numbering != none {
        it.supplement
        [ ]
        numbering(it.numbering, counter(heading).get().at(0))
      }
      linebreak()
      it.body
      linebreak()
      v(.5cm)
    }
  }

  ////////////////////////////////
  // figures
  let figure-supplement(the-figure) = {
    if the-figure.func() == raw {
      locale.figures.raw
    } else if the-figure.func() == table {
      locale.figures.table
    } else {
      locale.figures.figure
    }
  }
  set figure(supplement: figure-supplement)

  ////////////////////////////////
  // title page localization
  let fields = locale.title-page.fields
  let values = locale.title-page.values

  ////////////////////////////////
  // process potential multiple supervisors
  let supervisor-footer = ()
  if type(supervisor) == str {
    supervisor-footer = ((left: fields.supervisor, right: supervisor),)
  } else if type(supervisor) == array {
    for pair in supervisor {
      supervisor-footer.push((left: pair.at(0), right: pair.at(1)))
    }
  }

  ////////////////////////////////
  // cover sheet
  if not disable-cover and style != "pagecount" {
    title-page(
      id: id,
      author: author,
      title: title,
      type: values.thesis.at(thesis),
      header: [
        #locale.university \
        #locale.faculty
      ],
      footer: supervisor-footer,
      date: [#values.month.may #datetime.today().display("[year]")],
    )
    pagebreak(to: if use-binding { "odd" } else { none }, weak: true)
  }
  ////////////////////////////////
  // title page
  if style != "pagecount" {
    title-page(
      id: id,
      author: author,
      title: title,
      type: values.thesis.at(thesis),
      header: [
        #locale.university \
        #locale.faculty
      ],
      footer: (
        (left: fields.program, right: values.program.informatics),
        (left: fields.field, right: values.field.informatics),
        (left: fields.department, right: values.department.upai),
        ..supervisor-footer,
      ),
      date: [#values.month.may #datetime.today().display("[year]")],
    )
  }

  // intentional blank page
  pagebreak(to: if use-binding { "odd" } else { none })

  ////////////////////////////////
  // warning for AIS assignment
  if style != "pagecount" and assignment == none {
    page(
      fill: tiling(size: (40pt, 40pt))[
        #place(line(start: (0%, 0%), end: (100%, 100%), stroke: 2pt + red))
      ],
    )[
      #set text(30pt)
      #set par(justify: true)
      Don't forget to replace this page with your AIS assignment PDF using
      external tools!

      You can also specify assignment's file path using the `assignment`
      argument. Don't use this option for final hand-in! If you do hand in your
      thesis with this option instead of inserting it through external tools,
      you are doing so at your own risk. You have been warned.
    ]
  } else if style != "pagecount" {
    set page(margin: 0em)
    muchpdf(read(assignment, encoding: none))
  }
  pagebreak()
  pagebreak() // intentional blank page

  ////////////////////////////////
  // acknowledgment
  if style != "pagecount" {
    v(1fr)
    par(
      text(1.5em)[
        *#locale.acknowledgment*
      ],
    )

    text(1.1em)[
      #acknowledgment
      #v(1.5em)
    ]
  }
  pagebreak()
  pagebreak() // intentional blank page

  ////////////////////////////////
  // cestne vyhlasenie
  if style != "pagecount" {
    v(1fr)
    text(1.1em)[
      Čestne vyhlasujem, že som túto prácu vypracoval(a) samostatne, na základe
      konzultácií a s použitím uvedenej literatúry.
      #v(1.5em)
      // TODO: replace this with an appropriate Slovak date
      #grid(
        columns: (4fr, 3fr),
        rows: 2,
        gutter: 3pt,
        align: (left, center),
        row-gutter: .8em,
        grid.cell(
          rowspan: 2,
          align: start,
          datetime.today().display("V Bratislave, [day].[month].[year]"),
        ),
        repeat("."),
        author,
      )
    ]
  }
  pagebreak()
  pagebreak() // intentional blank page

  ////////////////////////////////
  // even if the language is Slovak, the university requires students to provide
  // both versions of the abstract
  if style != "pagecount" {
    abstract-page(
      title: slovak.annotation.title,
      university: slovak.university,
      faculty: slovak.faculty,
      program: (
        left: slovak.title-page.fields.program,
        right: slovak.title-page.values.program.informatics,
      ),
      author: (left: slovak.annotation.author, right: author),
      thesis: (left: slovak.title-page.values.thesis.at(thesis), right: title),
      supervisor: (
        left: slovak.title-page.fields.supervisor,
        right: supervisor,
      ),
      date: [#slovak.title-page.values.month.may #(
          datetime.today().display("[year]")
        )],
      abstract.sk,
    )
  }
  pagebreak() // intentional blank page

  ////////////////////////////////
  // english abstract
  if style != "pagecount" {
    abstract-page(
      title: english.annotation.title,
      university: english.university,
      faculty: english.faculty,
      program: (
        left: english.title-page.fields.program,
        right: english.title-page.values.program.informatics,
      ),
      author: (left: english.annotation.author, right: author),
      thesis: (left: english.title-page.values.thesis.at(thesis), right: title),
      supervisor: (
        left: english.title-page.fields.supervisor,
        right: supervisor,
      ),
      date: [#english.title-page.values.month.may #(
          datetime.today().display("[year]")
        )],
      abstract.en,
    )
  }

  pagebreak() // intentional blank page

  ////////////////////////////////
  // table of contents
  set par(
    first-line-indent: first-line-indent,
    justify: true,
    leading: leading,
    spacing: spacing,
  )
  set page(
    numbering: "i",
    number-align: center,
    margin: page-margins,
    header: header,
    footer-descent: footer-descent,
    header-ascent: header-ascent,
  ) // Roman numbering until the end of the contents
  set text(
    size: text-size,
  )
  show outline.entry.where(
    level: 1,
  ): it => {
    if it.element.func() == heading {
      // outline entry for the contents
      set block(above: 1.8em)
      show text: it => strong(it)
      link(
        it.element.location(),
        it.indented(it.prefix(), [#it.body()#h(1fr)#it.page()]),
      )
    } else {
      // outline entry for lists of figures
      link(
        it.element.location(),
        it.indented(strong(it.prefix()), it.inner()),
      )
    }
  }
  show outline.entry: set block(above: 1.2em)
  outline(title: locale.contents.title, depth: 3, indent: auto)
  if figures-outline {
    outline(title: locale.contents.figures, target: figure.where(kind: image))
  }
  if tables-outline {
    outline(title: locale.contents.tables, target: figure.where(kind: table))
  }
  if abbreviations-outline.len() > 0 and style != "pagecount" {
    list-of-abbreviations(
      title: locale.contents.abbreviations,
      abbreviations: abbreviations-outline,
      use-binding: use-binding,
    )
  }
  set page(numbering: none, margin: page-margins)
  v(1fr) // if the page is full, this will be a pagebreak
  pagebreak(weak: true) // if the page is not full, this will be a pagebreak
  counter(page).update(1) // start of the main section

  ////////////////////////////////
  // main body
  set par(
    first-line-indent: first-line-indent,
    justify: true,
    leading: leading,
    spacing: spacing,
  )
  set page(
    numbering: "1",
    number-align: center,
    margin: page-margins,
    header: header,
    footer-descent: footer-descent,
    header-ascent: header-ascent,
  )

  ////////////////////////////////
  // assertions
  context if thesis == "bp2" or thesis == "dp3" {
    // resume and plan of work are mandatory for the final theses
    let resume = query(
      heading.where(level: 1).and(<resume>),
    )
    let plan-of-work = query(
      heading.where(level: 1).and(<plan-of-work>),
    )
    assert(
      resume.len() == 1 and resume.at(0).numbering == none or lang == "sk",
      message: "Could not find <resume> label in your work. Please create a resume chapter in Slovak and mark it with the <resume> label.",
    )
    assert(
      lang != "sk" or resume.len() == 0,
      message: "Theses in Slovak should not have a resume. If for some reason you need to have it, remove the <resume> label from its heading.",
    )
    assert(
      plan-of-work.len() == 1,
      message: "Could not find <plan-of-work> label in your work. Please create a plan of work appendix and mark it with the <plan-of-work> label.",
    )
    assert(
      plan-of-work.at(0).numbering == _appendix-numbering,
      message: "The plan of work (<plan-of-work> label) should be an appendix. Check if its numbering is right, did you forget to use `#show: section-appendices.with()`?",
    )
  }
  assert(
    abstract.keys().contains("sk") and abstract.keys().contains("en"),
    message: "Please provide an abstract in both Slovak and English language",
  )
  assert(
    locale.title-page.values.thesis.keys().contains(thesis),
    message: "The thesis type you provided is not supported. Please contact the authors or choose one of the supported types",
  )
  if type(supervisor) != str {
    assert(
      type(supervisor) == array,
      message: "Please provide correct supervisor argument: either a string, or an array of pairs (\"position\", \"name\").",
    )
    for pair in supervisor {
      assert(
        type(pair) == array,
        message: "Please provide correct supervisor argument: one or more pairs are not arrays.
    Tip: if you have only one pair in the array, try to add a comma (,) after that element. Example: `supervisor: ((\"a\", \"b\"),)`",
      )
      assert(
        pair.len() == 2,
        message: "Please provide correct supervisor argument: one or more pairs do not have exactly 2 elements.",
      )
      assert(
        type(pair.at(0)) == str and type(pair.at(1)) == str,
        message: "Please provide correct supervisor argument: one or more pairs contain elements that are not strings.",
      )
    }
  }

  assert(
    type(abbreviations-outline) == array,
    message: "Please provide correct abbreviations-outline argument: either a string, or an array of pairs (\"abbreviation\", \"explanation\").",
  )
  for pair in abbreviations-outline {
    assert(
      type(pair) == array,
      message: "Please provide correct abbreviations-outline argument: one or more pairs are not arrays.
    Tip: if you have only one pair in the array, try to add a comma (,) after that element. Example: `abbreviations-outline: ((\"a\", \"b\"),)`",
    )
    assert(
      pair.len() == 2,
      message: "Please provide correct abbreviations-outline argument: one or more pairs do not have exactly 2 elements.",
    )
    assert(
      (type(pair.at(0)) == str or type(pair.at(0)) == content)
        and (type(pair.at(1)) == str or type(pair.at(1)) == content),
      message: "Please provide correct abbreviations-outline argument: one or more pairs contain elements that are not strings or content.",
    )
  }
  assert(
    type(style) == str
      and (
        style == "regular"
          or style == "compact"
          or style == "legacy"
          or style == "legacy-noncompliant"
          or style == "pagecount"
      ),
    message: "Please provide correct style of your thesis, possible options are: \"regular\", \"compact\", \"legacy\", \"legacy-noncompliant\" and \"pagecount\".",
  )

  body
}

// functions that are used in the thesis

#let section-appendices(body) = {
  let appendix-page-numbering(first, ..) = {
    // here, we don't need the `context` block. If we introduce it, it's going
    // to make outline entries dirty: it will assume that we need to use
    // current context, instead of the chapter's context
    let is-legacy = (
      _style.get() == "legacy" or _style.get() == "legacy-noncompliant"
    )
    if is-legacy {
      numbering("1", first)
    } else if counter(heading).get().at(0) != 0 [
      // if the first level heading is not zero, apply page numbering
      #numbering(_appendix-numbering, counter(heading).get().at(0))-#first
    ] else {
      none
    }
  }
  set page(numbering: appendix-page-numbering)
  // get the supplement from state
  // since getting a state value requires context, wrap the supplement into a
  // function
  set heading(numbering: _appendix-numbering, supplement: context {
    let locale = localization(lang: _lang.get())
    if _style.get() == "legacy" or _style.get() == "legacy-noncompliant" {
      locale.legacy-appendix
    } else { locale.appendix }
  })
  counter(heading).update(0)
  context if (
    not _style.get() == "legacy" or _style.get() == "legacy-noncompliant"
  ) {
    counter(page).update(1)
  }
  // appendices don't add up to page count
  show text: it => context if _style.get() == "pagecount" { none } else { it }
  body
}

#let resume(body) = {
  pagebreak()
  context {
    let locale = localization(lang: _lang.get())
    set heading(numbering: none)
    [
      = Resumé <resume>
    ]
  }
  body
}

