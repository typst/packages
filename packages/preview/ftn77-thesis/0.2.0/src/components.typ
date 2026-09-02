#import "../style.typ" as style

#let ftn-logo-template = read("../assets/logo/ftn-logo.template.svg")

#let ftn-logo = context {
  let logo = ftn-logo-template.replace("{{COLOUR}}", text.fill.to-hex())

  image(
    bytes(logo),
    height: 2.4cm,
    width: auto,
    alt: "ФТН лого",
    format: "svg",
  )
}

#let ftn-logo-new = pad(x: 2.4cm - 1.8cm)[
  #image(
    "../assets/logo/logoftnnovi.png",
    height: 1.8cm,
    width: auto,
    alt: "Нови ФТН лого",
  )
]
#let uns-logo-template = read("../assets/logo/uns-logo.template.svg")

#let uns-logo = context {
  let logo = uns-logo-template
    .replace("{{COLOUR}}", text.fill.to-hex())
    .replace(
      "{{COLOURED_STROKE}}",
      if text.fill not in (black, white) { text.fill.transparentize(50%).to-hex() } else {
        "#6f90bc"
      },
    )

  pad(2.4cm - 2.28cm)[
    #image(
      bytes(logo),
      height: 2.28cm,
      width: auto,
      alt: "УНС лого",
    )
  ]
}

#let form-heading(
  style: style,
  lang: auto,
  body,
) = {
  import style: gray
  show: style.form-heading

  set heading(numbering: none, supplement: [Формулар], outlined: true, bookmarked: true)
  let inset = 0.28em // 1mm on 10pt text
  show heading: upper

  layout(size => {
    grid(
      columns: (auto, 1fr),
      rows: measure(ftn-logo).height / 2 + inset,
      align: center + horizon,
      stroke: 0.15em + text.fill,
      inset: inset,

      grid.cell(
        ftn-logo,
        rowspan: 2,
      ),

      pdf.artifact[
        #stack(
          dir: ttb,
          spacing: 0.6em,

          ..if ("sr", "ba").contains(if lang == auto { text.lang } else { lang }) {
            (
              upper[#text(weight: "light")[Универзитет у Новом Саду] #sym.circle.filled *Факултет
                техничких наука*],
              text(weight: "light", tracking: 0.1em)[2100 НОВИ САД, Трг Доситеја Обрадовића 6],
            )
          } else {
            (
              upper[#text(weight: "light")[University of Novi Sad] #sym.circle.filled *Faculty of
                technical sciences*],
              text(weight: "light", tracking: 0.1em)[21000 NOVI SAD, Trg Dositeja Obradovića 6],
            )
          },
        )
      ],
      grid.cell(
        fill: gray,
      )[
        // #body
        // add supplement just to id form headings if needed
        #heading[#body]
      ],
    )
  })
}

#let assignment-form-heading(
  number: sym.space,
  date: sym.space,
  style: style,
  lang: auto,
  body,
) = {
  import style: gray
  show: style.form-heading

  set heading(numbering: none, supplement: [Формулар], outlined: true, bookmarked: true)
  let inset = 0.28em // 1mm on 10pt text
  show heading: upper
  let date = if date == auto { datetime.today() } else { date }

  layout(size => {
    let stroke = 0.15em + text.fill

    grid(
      columns: (auto, 1fr, 0.35fr),
      rows: measure(ftn-logo).height / 2 + inset,
      align: center + horizon,
      stroke: stroke,
      inset: inset,

      grid.cell(
        ftn-logo,
        rowspan: 2,
      ),

      grid.cell(
        rowspan: 2,
        inset: 0pt,
      )[
        #grid(
          rows: (1fr, 1fr),
          columns: 1fr,
          stroke: stroke,
          inset: inset,

          pdf.artifact[
            #stack(
              dir: ttb,
              spacing: 0.6em,

              ..if ("sr", "ba").contains(if lang == auto { text.lang } else { lang }) {
                (
                  upper[#text(weight: "light")[Универзитет у Новом Саду] #sym.circle.filled
                    *Факултет техничких наука*],
                  text(weight: "light", tracking: 0.1em)[2100 НОВИ САД, Трг Доситеја Обрадовића 6],
                )
              } else {
                (
                  upper[#text(weight: "light")[University of Novi Sad] #sym.circle.filled *Faculty
                    of technical sciences*],
                  text(weight: "light", tracking: 0.1em)[21000 NOVI SAD, Trg Dositeja Obradovića 6],
                )
              },
            )
          ],
          grid.cell(
            fill: gray,
          )[
            #heading[#body]
          ],
        )
      ],

      grid.cell(
        rowspan: 2,
        inset: 0pt,
      )[
        #table(
          rows: (1fr,) * 4,
          columns: 1fr,
          stroke: stroke,
          align: left,
          // inset: (left: 3em, right: 3em),

          [Број:],
          [#number],
          [Датум:],
          if type(date) == datetime [
            #date.day().#numbering("I", date.month())#sym.space.nobreak#date.year().
          ] else [#date],
        )
      ],
    )
  })
}
