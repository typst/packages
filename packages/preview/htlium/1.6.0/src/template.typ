/*
* @author: Elias Pöschl
* @description: Template für Protokolle
*/

#import "@preview/icu-datetime:0.2.2"
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#import "lib/titlepage.typ": *
#import "lib/boxes.typ": *

#let template(
  body,
  lang: "de",
  color-scheme: red,
  author: "Your Name",
  class-long: "Protokoll",
  logo: image,
  school-year: "2025/26",
  title: "Title",
  subtitle: "Subtitle",
  task-title: "Task Title",
  task-content: "Task Content",
  class: "Class",
  date: datetime.today().display("[Day padding:None].[month].[year]"),
  subject: "Subject",
  school: "School",
  department: "Department",
  teachers: ("Frau Mag. Mustermann", "Herr Mag. Muster"),
  do-lof: true,
  do-lot: true,
  do-bib: true,
  bib-src: "refs.bib",
  fancy-design: true,
  before-logo-info: (),
  after-logo-info: (),
  ) = {
  let title-color = color-scheme.darken(20%)

  import "@preview/codly:1.3.0": *
  import "@preview/codly-languages:0.1.1": *
  show: codly-init.with()
  codly(languages: codly-languages)
  codly-enable()

  set heading(
    numbering: "1.1",
  )
  //if fancy-design {
  show heading: set text(fill: title-color)
  //}
  
  set page(
    paper: "a4",
    margin: (top: 2.95cm, bottom: 2.54cm, left: 1.57cm, right: 1.57cm),
    numbering: "1",
    header: context {
      if counter(page).get().first() > 1 {
        
      grid(
        columns: 3 * (1fr,),
        rows: (7fr, 1fr),
        [
          #author
          #if fancy-design {
             place(
              left + top,
              dx: -1.7cm,
              dy: -0.7cm,
              rect(
                width: 0.5cm,
                height: 31cm,
                fill: color-scheme.darken(20%),
              )
            )
          }
        ],
        align(center)[
          #class-long
        ],
        align(right)[
          #if logo != none [
            #show image: set image(width: 3cm)
            #logo
          ]
        ],
        
        [
          #line(length: 300%, stroke: 0.5pt)
        ],
      )
      }
    },
    footer: context {
      if counter(page).get().first() > 1 [
        #grid(
          columns: 2 * (1fr,),
          [
            #school-year
          ],
          align(right)[
            #counter(page).display("1")
          ],
        )
      ]
    },
  )
  
  set document(
    title: title,
    author: author,
  )
  
  set text(
    font: "Arial",
    size: 12pt,
    lang: lang,
  )

  show table: t => {
    if (t.has("label") and t.label == <nostyle>) {
      return t
    }
    let fields = t.fields()
    if ("label" in fields.keys()) {
      let _ = fields.remove("label")
    }
    let chld = fields.remove("children")

    block(
      radius: 4pt,
      clip: true,
      stroke: 1pt,
    )[
      #table(
        ..fields,
        fill: (x, y) => {
          if (calc.odd(y)) {
            color-scheme.darken(60%).transparentize(90%)
          } else {
            rgb(0, 0, 0, 0)
          }
        },
        ..chld
      )<nostyle>
    ]
  }

  set cite(
    style: "ieee"
  )

  titlepage(
    title,
    lang,
    color-scheme,
    subtitle,
    task-title,
    task-content,
    author,
    class,
    school-year,
    date,
    logo,
    subject,
    school,
    department,
    teachers,
    fancy-design,
    before-logo-info,
    after-logo-info
  )

  show outline.entry.where(
    level: 1
  ): set text(weight: "bold") 
  outline()
  pagebreak()
  
  if do-lof {
    show outline.entry: it => {
      it.indented(none, it.prefix() + ": " + it.inner())
    }
    show outline.entry.where(
      level: 1,
    ): set text(weight: "regular")
    outline(
      title: [
        #if lang == "de" [
          Abbildungsverzeichnis
        ] else [
          List of Figures
        ]
        ],
      target: figure.where(kind: image),
    )
  }
  if do-lot {
    show outline.entry: it => {
      it.indented(none, it.prefix() + ": " + it.inner())
    }
    show outline.entry.where(
      level: 1,
    ): set text(weight: "regular")
    outline(
      title: [
        #if lang == "de" [
          Tabellenverzeichnis
        ] else [
          List of Tables
        ]
      ],
      target: figure.where(kind: table),
    )
  }
  if do-lot or do-lof {
    pagebreak()
  }
  
  body
  
  if do-bib {
    bibliography(bib-src, style: "ieee",
    title: [
      #if lang == "de" [
        Literaturverzeichnis
      ] else [
        List of References
      ]
    ])
  }
}



