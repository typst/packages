#import "@preview/wrap-it:0.1.1": wrap-content
#import "@preview/datify:0.1.3": day-name, month-name, custom-date-format
#import "@preview/droplet:0.3.1": dropcap
#let azulunir = rgb("#0098cd")

#let ijimai(conf: none, photos: (), logo: none, bib-data: none, body) = {
  set text(font: "Libertinus Serif", size: 9pt, lang: "en")
  set columns(gutter: 0.4cm)
  let authors = conf.authors.filter(author => author.include == true)
  let institutions-names = authors.map(author => { author.institution }).dedup()
  let institutions-dict = institutions-names.enumerate(start: 1).map(institution-name => { (institution-name) })
  let authors-string = (
    authors
      .enumerate(start: 1)
      .map(author => {
        let institution-number = institutions-dict
          .filter(institution-dict => (
            institution-dict.at(1) == author.at(1).institution
          ))
          .at(0)
          .at(0)
        [#author.at(1).name #h(-.09cm) #super[#institution-number]]
        if author.at(1).corresponding [#super[#sym.star]]
      })
      .join(", ")
  )

  counter(page).update(conf.paper.starting-page)


  show bibliography: it => {
    show link: set text(blue)
    show link: underline
    it
  }

  show figure.caption: it => {
    if (it.fields().at("kind") == image) {
      context [
        Fig.~#it.counter.display()#it.separator#it.body]
    } else {
      context [#v(.2cm)
        TABLE #smallcaps()[~#it.counter.display()#it.separator#it.body]]
    }
  }

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set block(breakable: true)


  let regex-fig = regex("Figure\s(\d+)")
  show regex-fig: it => {
    let (d) = it.text.match(regex-fig).captures
    set text(fill: azulunir)
    [Fig. #d.at(0)]
  }

  let regex-table = regex("Table\s(\d+)")
  show regex-table: it => {
    let (d) = it.text.match(regex-table).captures
    set text(fill: azulunir)
    [Table #d.at(0)]
  }

  set math.equation(numbering: "(1)", supplement: none)
  show ref: it => {
    set text(fill: azulunir)
    if it.element != none and it.element.func() == math.equation {
      [(#it)]
    } else {
      [#it]
    }
  }

  set page(
    paper: "a4",
    margin: (bottom: 1.5cm, rest: 1.5cm),
    columns: 2,
    height: 27.9cm,
    width: 21.6cm,
    header: [#if (conf.paper.special-issue == true) [
        #context [
          #if calc.odd(here().page()) {
            place(
              top + left,
              dx: -80%,
              dy: -8%,
              rect(
                width: 165%,
                height: 17pt,
                fill: gradient.linear(white, azulunir, angle: 180deg),
              ),
            )
          } else {
            place(
              top + left,
              dx: -8%,
              dy: -8%,
              rect(
                width: 165%,
                height: 17pt,
                fill: gradient.linear(white, azulunir, angle: 180deg).sharp(5),
              ),
            )
          }
        ]]

      #context [
        #if calc.odd(here().page()) {
          align(center)[#text(size: 10pt, fill: azulunir, font: "Unit OT", weight: "regular", style: "italic")[
              #if (conf.paper.special-issue == true) [
                *#conf.paper.special-issue-title*
              ] else [*Regular issue*]
            ]]
        } else {
          align(center)[#text(size: 10pt, fill: azulunir, font: "Unit OT", weight: "regular", style: "italic")[
              *#conf.paper.journal, Vol. #conf.paper.volume, N#super("o")#conf.paper.number*
            ]]
        }]
    ],
    footer: context [
      #align(
        center,
        text(
          fill: azulunir,
          weight: "regular",
          font: "Unit OT",
          size: 8pt,
          "- " + counter(page).display("1") + " -",
        ),
      )
    ],
  )


  place(
    top + left,
    scope: "parent",
    float: true,
    dy: 0.6cm,
  )[
    #align(left)[
      #par(spacing: 0.7cm, leading: 1.5em)[
        #text(size: 24pt)[#conf.paper.title]
      ]]

    #text(fill: azulunir, size: 13pt)[#authors-string]

    #text(fill: black, size: 10pt)[
      #(
        institutions-names
          .enumerate(start: 1)
          .map(institution-name => super[#institution-name.at(0)] + " " + institution-name.at(1))
          .join([\ ])
      )
    ]

    #text(fill: azulunir)[#super[#sym.star] Corresponding author:] #(
      authors.filter(author => author.corresponding).at(0).email
    )

    #v(0.3cm)
    #let received-date-string = [#conf.paper.received-date.day() #month-name(
        conf.paper.received-date.month(),
        true,
      ) #conf.paper.received-date.year()]
    #let accepted-date-string = [#conf.paper.accepted-date.day() #month-name(
        conf.paper.accepted-date.month(),
        true,
      ) #conf.paper.accepted-date.year()]
    #let published-date-string = [#conf.paper.published-date.day() #month-name(
        conf.paper.published-date.month(),
        true,
      ) #conf.paper.published-date.year()]
    #underline(offset: 4pt, stroke: azulunir)[#overline(offset: -10pt, stroke: azulunir)[#text(
          font: "Unit OT",
          size: 8pt,
        )[Received #received-date-string | Accepted #accepted-date-string | Published #published-date-string]]]

    #context [
      #let abstract-y = here().position().y
      #place(
        top + left,
        dx: 14.8cm,
        dy: abstract-y - 5cm,
        logo,
      )]
    #v(1.3cm)


    #grid(
      columns: (3.5fr, 1fr),
      rows: (auto, 60pt),
      gutter: 25pt,
      [#text(size: 15pt, font: "Unit OT", weight: "regular", fill: azulunir)[A]#text(
          size: 13pt,
          font: "Unit OT",
          weight: "regular",
          fill: azulunir,
        )[BSTRACT]#v(-.3cm)#line(length: 100%, stroke: azulunir) #par(justify: true, leading: 5.5pt)[#text(
            size: 8.8pt,
          )[#conf.paper.abstract]]],
      [#text(size: 15pt, font: "Unit OT", weight: "regular", fill: azulunir)[K]#text(
          size: 13pt,
          font: "Unit OT",
          weight: "regular",
          fill: azulunir,
        )[EYWORDS]#v(-.3cm)#line(length: 100%, stroke: azulunir) #par(justify: false, leading: 4pt)[#text(
            size: 9.6pt,
          )[#conf.paper.keywords]] #align(left + bottom)[
          #underline(offset: 4pt, stroke: azulunir)[#overline(offset: -10pt, stroke: azulunir)[#text(
                font: "Unit OT",
                size: 7.5pt,
              )[#text(fill: azulunir, "DOI: ") #conf.paper.doi]]]]],
    )
    #v(-1.7cm)
  ]


  set heading(numbering: "I.A.a)")

  show heading: it => {
    let levels = counter(heading).get()
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    set text(10pt, weight: "regular")
    if it.level == 1 {
      let is-ack = it.body in ([Acknowledgment], [Acknowledgement], [Acknowledgments], [Acknowledgements])
      set align(center)
      set text(if is-ack { 10pt } else { 11pt })
      show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      show: smallcaps
      if it.numbering != none and not is-ack {
        numbering("I.", deepest)
        h(7pt, weak: true)
      }
      it.body
    } else if it.level == 2 {
      //set par(first-line-indent: 0pt)
      set text(style: "italic")
      show: block.with(spacing: 10pt, sticky: true)
      v(.15cm)
      if it.numbering != none {
        emph(text(fill: azulunir)[#numbering("A.", deepest)])
        h(7pt, weak: true)
      }
      emph(text(fill: azulunir)[#it.body])
    } else [
      #if it.level == 3 {
        numbering("a)", deepest)
        [ ]
      }
      _#(it.body):_
    ]
  }

  show heading.where(level: 1): it => {
    text(fill: azulunir)[#it]
    v(-12pt)
    line(length: 100%, stroke: azulunir + 0.5pt)
  }

  show heading.where(level: 2): it => {
    emph(text(fill: azulunir)[#it])
  }

  set par(justify: true, leading: 5pt, first-line-indent: 1em, spacing: .25cm)

  let author-bios = (
    authors
      .enumerate()
      .map(author => {
        let author-photo = image(bytes(photos.at(author.at(0))), width: 2cm)
        let author-bio = [#par(
            text(fill: azulunir, font: "Unit OT", size: 8.0pt, weight: "regular", author.at(1).name),
          ) #(
            text(size: 8pt, author.at(1).bio)
          )]
        wrap-content(author-photo, author-bio)
      })
      .join()
  )

  show regex("Equation"): set text(fill: azulunir)

  body
  show regex("^\[\d+\]"): set text(fill: azulunir)

  set par(leading: 4pt, spacing: 5.5pt, first-line-indent: 0pt)
  set text(size: 7.5pt, lang: "en")

  bibliography(bib-data, style: "ieee", title: "References")
  v(1cm)
  set par(leading: 4pt, spacing: 9.5pt)
  author-bios
}


#let first-paragraph(conf: none, first-word: "The", body) = {
  let doi-link-text = "https://dx.doi.org/" + conf.paper.doi
  let doi-link = link(doi-link-text, doi-link-text)
  let last-page = context counter(page).final().first()

  let cite-string = [
    #conf.paper.short-author-list. #conf.paper.title. #conf.paper.journal, vol. #conf.paper.volume, no. #conf.paper.number, pp. #conf.paper.starting-page - #last-page, #conf.paper.publication-year, #doi-link]

  let cite-as-section = align(
    left,
    rect(
      fill: silver,
      width: 100%,
      stroke: 0.5pt + azulunir,
    )[#par(leading: .1cm)[#text(size: 8.1pt)[Please, cite this article as: #cite-string]]],
  )

  dropcap(
    height: 2,
    gap: 1pt,
    hanging-indent: 1em,
    overhang: 0pt,
    fill: azulunir,
  )[
    #upper(text(fill: azulunir, weight: "semibold", first-word)) #body
  ]
  figure(
    cite-as-section,
    scope: "parent",
    placement: bottom,
  )
}
