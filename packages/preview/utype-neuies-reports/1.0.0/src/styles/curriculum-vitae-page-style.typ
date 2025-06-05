#import "/src/constants/document-settings-constants.typ": ALTERNATE-FONT-SIZE-2

// Öz Geççmiş sayfası stili. [Curriculum vitae page style.]
#let curriculum-vitae-page-style(content) = {
  // 1. düzey başlıklar ortaya hizalandı. [Level 1 headings are centered.]
  show heading.where(level: 1): set align(center)

  // Yazı boyutununu ayarla. [Set text size.]
  set text(size: ALTERNATE-FONT-SIZE-2)
  show table.cell: set text(size: ALTERNATE-FONT-SIZE-2)

  // Paragraf ayarlarını ayarla. [Set paragraph settings.]
  set par(
    first-line-indent: 0cm,
    justify: false,
  )

  // Tablo ayarlarını ayarla. [Set table settings.]
  set table(
    column-gutter: auto,
    rows: auto,
    row-gutter: auto,
    inset: (
      left: 0.5em,
      top: 1em,
      bottom: 1em,
      right: 0.5em,
    ),
    align: left + horizon,
    stroke: 0.25pt + black,
  )

  // Tablo ortaya hizalandı. [Table is centered.]
  show table: set align(center)

  // Tablonun başlık satırı tekrar etmeyecek şekilde ayarlandı. [Table header row is set not to repeat.]
  set table.header(repeat: false)

  // Tablonun altlık satırı tekrar etmeyecek şekilde ayarlandı. [Table footer row is set not to repeat.]
  set table.footer(repeat: false)

  // Tablo hücresinin içinde kullanılan ayıraç çizginin stili ayarlandı. [Table cell separator line style is set.]
  set line(
    length: 95%,
    stroke: (paint: black, thickness: 0.25pt, dash: "dashed"),
  )

  // Tablo hücresinin içinde kullanılan ayıraç çizgisi ortaya hizalandı. [Table cell separator line is centered.]
  show line: set align(center)

  content
}
