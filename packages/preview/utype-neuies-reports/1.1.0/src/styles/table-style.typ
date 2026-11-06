#import "/src/constants/document-settings-constants.typ": ALTERNATE-FONT-SIZE, SINGLE-LINE-PARAGRAPH-LEADING-SIZE

// Tablo stili. [Table style.]
#let table-style(content) = {
  let normal-stroke-size = 1pt
  let bold-stroke-size = 1.5pt

  // Tablo başlığını (sadece tablonun ilk satırı) kalın yaz. [Bold the table header (only the first row of the table).]
  show table.header: set text(weight: "bold")
  show table.cell.where(y: 0): set text(weight: "bold")

  // Tablo ayarlarını ayarla. [Set table settings.]
  set table(
    align: center + horizon,
    gutter: 0pt,
    inset: (x: 0.15cm, y: 0.25cm),
    stroke: (x, y) => (
      left: none,
      top: if y == 0 { bold-stroke-size } else { 0pt },
      right: none,
      bottom: if y > 1 { normal-stroke-size } else if y == 1 or (x == 0 and y == 0) { bold-stroke-size } else { 0pt },
    ),
    fill: none,
  )

  // Tablo içerisindeki paragraf ayarlarını ayarla. [Set paragraph settings in the table.]
  show table: set par(
    first-line-indent: 0cm,
    hanging-indent: 0cm,
    justify: false,
    leading: SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
  )

  // Tablo içerisindeki yazı ayarlarını ayarla. [Set text settings in the table.]
  show table: set text(size: ALTERNATE-FONT-SIZE)

  // Tablo başlık satırının paragraf ayarlarını ayarla. [Set paragraph settings in the table header.]
  show table.header: set par(leading: SINGLE-LINE-PARAGRAPH-LEADING-SIZE)

  // Tablo altlık satırının paragraf ayarlarını ayarla. [Set paragraph settings in the table footer.]
  show table.footer: set par(justify: true, leading: SINGLE-LINE-PARAGRAPH-LEADING-SIZE)

  // Tablo altlık satırını yatayda sola ve dikeyde ortaya hizala. [Align the table footer horizontally to the left and vertically to the center.]
  show table.footer: set table.cell(align: left + horizon)

  // Tablo hücrelerini bölünebilir hale getir. [Make table cells breakable.]
  set table.cell(breakable: true)

  // Tablo başlığının tekrarlanmasını etkinleştir. [Enable the repetition of the table header.]
  set table.header(repeat: true)

  // Tablo altlık satırının tekrarlanmasını etkinleştir. [Enable the repetition of the table footer.]
  set table.footer(repeat: true)

  /*
    show table.footer: it => {
      set par(first-line-indent: 0cm, leading: 1em)
      set text(size: ALTERNATE-FONT-SIZE)
      set table.cell(align: right)
      it
    }
  */

  content
}
