#import "/src/constants/document-settings-constants.typ": ALTERNATE-FONT-SIZE, ONE-AND-HALF-LINE-PARAGRAPH-LEADING-SIZE

// Çalışma Takvimi sayfası stili. [Work Schedule page style.]
#let work-schedule-page-style(content) = {
  // Sayfa başlığı ortaya hizalandı. [Center page heading.]
  show heading.where(level: 1): set align(center)

  // Paragraf ayarları. [Paragraph settings.]
  set par(
    justify: false,
    first-line-indent: (amount: 0cm, all: true),
  )

  // Tablo ayarları. [Table settings.]
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
    align: left,
    stroke: 0.25pt + black,
  )

  // Tablo yazı tipi boyutu. [Table text size.]
  show table: set text(size: ALTERNATE-FONT-SIZE)

  // Tabloyu ortaya hizala. [Center table.]
  show table: set align(center)

  // Tablonun başlık satırı tekrar etmeyecek şekilde ayarlandı. [Table header row is set not to repeat.]
  set table.header(repeat: false)

  // Tablonun altlık satırı tekrar etmeyecek şekilde ayarlandı. [Table footer row is set not to repeat.]
  set table.footer(repeat: false)

  content
}
