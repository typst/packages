#import "../style.typ" as style

#let ftn-logo = image(
  "../assets/logo/ftn-logo-light.svg",
  height: 2.4cm,
  width: auto,
  alt: "ФТН лого",
)

#let ftn-logo-new = image(
  "../assets/logo/logoftnnovi.png",
  height: 1.8cm,
  width: auto,
  alt: "Нови ФТН лого",
)

#let uns-logo = image(
  "../assets/logo/uns-logo-light.svg",
  height: 2.28cm,
  width: auto,
  alt: "УНС лого",
)

#let form-heading(
  style: style,
  lang: auto,
  body,
) = context {
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
      stroke: 0.15em + black,
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
  let stroke = 1.5pt + black
  show heading: upper

  layout(size => {
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
          if type(date) == datetime { date.display() } else { [#date] },
        )
      ],
    )
  })
}
