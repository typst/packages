
#let titlepage(
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
) = {
    v(2cm)

    align(center)[
        #text(weight: "bold", size: 50pt)[#title]
        #v(-1cm)
        #text(size: 25pt)[#subtitle]
        #line(length: 100%, stroke: 1.5pt)
    ]

    if task-title != "" {
        text(weight: "semibold", size: 20pt)[#task-title]
    }
    if task-content != "" {
        v(-0.2cm)
        text(size: 16pt)[#task-content]
    }
    v(0.7cm)

    if author != "" {
        align(center)[
            #text(weight: "bold", size: 14pt)[
                #if lang == "de" [
                    Verfasser:#linebreak()
                ] else [
                    Author:#linebreak()
                ]
            ]
            #text(size: 25pt)[#author]
        ]
    }

    let first-grid = before-logo-info
    if class != "" {
        first-grid.push(
            (
              if lang == "de" [
                *Klasse:*
              ] else [
                *Class:*
              ],
              class,
            )
        )
    }
    if school-year != "" {
        first-grid.push(
            (
              if lang == "de" [
                *Schuljahr:*
              ] else [
                *School Year:*
              ],
              school-year,
            )
        )
    }
    if date != "" {
        first-grid.push(
            (
              if lang == "de" [
                *Datum:*
              ] else [
                *Date:*
              ],
              date,
            )
        )
    }

    grid(
        columns: 2*(auto,),
        gutter: 10pt,
        ..for cell in first-grid {
            (cell)
        }
    )

    align(center)[
      #if logo != none {
        show image: set image(width: 10cm)
        logo
      }
    ]

    let second-grid = after-logo-info
    if subject != "" {
        second-grid.push(
            (
              if lang == "de" [
                *Fach:*
              ] else [
                *Subject:*
              ],
              subject,
            )
        )
    }
    if school != "" {
        second-grid.push(
            (
              if lang == "de" [
                *Schule:*
              ] else [
                *School:*
              ],
              school,
            )
        )
    }
    if department != "" {
        second-grid.push(
            (
              if lang == "de" [
                *Abteilung:*
              ] else [
                *Department:*
              ],
              department,
            )
        )
    }
    if teachers != () {
        second-grid.push(
            (
              if lang == "de" [
                *Lehrer:*
              ] else [
                *Teachers:*
              ],
              teachers.join(",\n"),
            )
        )
    }

    grid(
        columns: 2*(auto,),
        gutter: 10pt,
        ..for cell in second-grid {
            (cell)
        }
    )

    // Rectangles and Things for Mainpage design
    let dark = color-scheme.darken(80%)
    let primary = color-scheme.darken(50%)
    let secondary = color-scheme.darken(20%)
    let light = color-scheme.lighten(60%)

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