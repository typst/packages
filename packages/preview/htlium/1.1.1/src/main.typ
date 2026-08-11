/*
* @author: Elias Pöschl
* @description: Template für Protokolle
*/

#import "@preview/icu-datetime:0.2.2"

#let titlepage(
    title,
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
) = {
    v(2cm)

    align(center)[
        #text(weight: "bold", size: 50pt)[#title]
        #v(-1cm)
        #text(size: 25pt)[#subtitle]
        #line(length: 100%, stroke: 1.5pt)
    ]

    text(weight: "semibold", size: 20pt)[#task-title]
    v(-0.2cm)
    text(size: 16pt)[#task-content]
    v(0.7cm)

    align(center)[
        #text(weight: "bold", size: 14pt)[Verfasser:#linebreak()]
        #text(size: 25pt)[#author]
    ]

    grid(
        columns: 2*(auto,),
        rows: 3*(auto,),
        gutter: 10pt,
        [
            *Klasse:*
        ],
        [
            #class
        ],
        [
            *Schuljahr:*
        ],
        [
            #school-year
        ],
        [
            *Datum:*
        ],
        [
            #date
        ]
    )

    align(center)[
      #if logo != none {
        logo
      }
    ]

    grid(
        columns: 2*(auto,),
        rows: 4*(auto,),
        gutter: 10pt,
        [
            *Fach:*
        ],
        [
            #subject
        ],
        [
            *Schule:*
        ],
        [
            #school
        ],
        [
            *Abteilung:*
        ],
        [
            #department
        ],
        [
            *Lehrer:*
        ],
        [
            #teachers.join(",\n")
        ]
    )

    // Rectangles and Things for Mainpage design
    let dark = rgb(40, 9, 5)
    let primary = rgb(116, 10, 3)
    let secondary = rgb(195, 17, 12)
    let light = rgb(230, 80, 27)

    let rect_temp(
      placement: top + left,
      dx: -3cm,
      dy: -2.5cm,
      rotation: -10deg,
      width: 5cm,
      height: 3cm,
      fill: light,
    ) = place(
      placement,
      dx: dx,
      dy: dy,
      rotate(
        rotation,
        rect(
          width: width,
          height: height,
          fill: fill,
        ),
      ),
    )

    if fancy-design {
      rect_temp(placement: top + left, dx: -6cm, dy: -2cm, rotation: -40deg, fill: light, width: 20cm)
      rect_temp(placement: top + right, dx: 6cm, dy: -2cm, rotation: 40deg, width: 20cm)
      rect_temp(placement: top, dx: -5cm, rotation: 0deg, width: 25cm)
      
      rect_temp(placement: top + left, dx: -3cm, dy: -3cm, rotation: -20deg, fill: secondary, width: 20cm)
      rect_temp(placement: top + right, dx: 3cm, dy: -3cm, rotation: 20deg, fill: secondary, width: 20cm)

      rect_temp(placement: top + left, dx: -8cm, dy: -3cm, rotation: -15deg, fill: primary, width: 20cm)
      rect_temp(placement: top + right, dx: 8cm, dy: -3cm, rotation: 15deg, fill: primary, width: 20cm)
      rect_temp(placement: top + left, dx: -3cm, dy: -3.7cm, rotation: 0deg, fill: primary, width: 20cm)

      rect_temp(fill: dark, rotation: -7deg, width: 15cm, dy: -4cm, dx: -3cm)
      rect_temp(fill: dark, rotation: 7deg, width: 15cm, dy: -4cm, dx: 6cm)


      rect_temp(placement: bottom, fill: light, rotation: 7deg, width: 15cm, dy: 2cm)
      rect_temp(placement: bottom, fill: light, rotation: -7deg, width: 15cm, dy: 2cm, dx: 5cm)

      rect_temp(placement: bottom, fill: secondary, rotation: -7deg, width: 15cm, dy: 2cm, dx: -6.28cm)
      rect_temp(placement: bottom, fill: secondary, rotation: 7deg, width: 15cm, dy: 2cm, dx: 8.22cm)

      rect_temp(placement: bottom, fill: primary, rotation: 10deg, width: 15cm, dy: 3cm)
      rect_temp(placement: bottom, fill: primary, rotation: -10deg, width: 15cm, dy: 3cm, dx: 5cm)

      rect_temp(placement: bottom, fill: dark, rotation: -3deg, width: 15cm, height: 5cm, dy: 5cm, dx: -6.35cm)
      rect_temp(placement: bottom, fill: dark, rotation: 3deg, width: 15cm, height: 5cm, dy: 5cm, dx: 8.3cm)
    }

    pagebreak()
}

#let template(
  body,
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
  fancy-design: true
) = {
  let htlorange = rgb(255, 108, 76)
  
  set heading(
    numbering: "1.",
  )
  show heading: set text(fill: htlorange)
  
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
                fill: rgb(195, 17, 12)
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
    lang: "de",
  )
  
  titlepage(
    title,
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
    fancy-design
  )
  
  outline()
  pagebreak()
  
  if do-lof {
    show outline.entry: it => {
      it.indented(none, it.prefix() + ": " + it.inner())
    }
    outline(
      title: [Abbildungsverzeichnis],
      target: figure.where(kind: image),
    )
  }
  if do-lot {
    show outline.entry: it => {
      it.indented(none, it.prefix() + ": " + it.inner())
    }
    outline(
      title: [Tabellenverzeichnis],
      target: figure.where(kind: table),
    )
  }
  if do-lot or do-lof {
    pagebreak()
  }
  
  body
  
  if do-bib {
    bibliography(bib-src, style: "ieee",
    title: [Literaturverzeichnis])
  }
}



