#import "/src/constants/document-settings-constants.typ": *
#import "/src/constants/numbering-constants.typ": PAGE-NUMBERING-ROMAN
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/styles/math-equation-style.typ": math-equation-style
#import "/src/styles/list-style.typ": list-style
#import "/src/styles/table-style.typ": table-style
#import "/src/styles/figure-style.typ": figure-style
#import "/src/styles/reference-style.typ": reference-style
#import "/src/styles/raw-style.typ": raw-style
#import "/src/styles/quotation-style.typ": quotation-style
#import "/src/styles/footnote-style.typ": footnote-style

// Dökümandaki ortak stil ayarları. [Common document style settings.]
#let common-document-style(
  language: none,
  report-title: none,
  author: none,
  keywords: none,
  content,
) = {
  // Döküman üst verisini ayarla. [Set document metadata.]
  set document(
    title: report-title.tur.title-case + " (" + report-title.eng.title-case + ")",
    author: (author.first-name + " " + upper(author.last-name)),
    keywords: (..keywords.tur, ..keywords.eng),
  )

  // Döküman düzeni ayarlarını ayarla. [Set document layout settings.]
  set page(
    paper: PAPER,
    header: auto,
    footer: auto,
    margin: MARGIN,
    number-align: center + bottom,
    numbering: PAGE-NUMBERING-ROMAN,
    columns: 1,
  )

  // Yazı ayarlarını ayarla. [Set text settings.]
  set text(
    font: FONT-NAME,
    size: FONT-SIZE,
    lang: language.language-code,
    region: language.region-code,
    ligatures: false,
    hyphenate: false,
    style: "normal",
    weight: DEFAULT-TEXT-FONT-WEIGHT,
    /*
    Typst varsayılanınını Office 365 Word'deki gibi ayarla.\
    Paragraflardaki satırlar arası boşluk miktarı.\
    Office 365 Word'deki 1 satırlık boşluğu ayarı için öncelikle Word'ün aradaki boşluğu hesaplamak için kullandığı noktalar olan `top-edge: "ascender"` ve `bottom-edge: "descender"` yapılır. Word, ilk satırın üst sınırı ile sonraki satırın üst sınırı arasındaki mesafeye göre hesap yaparken Typst ilk satırın alt sınırı ile sonraki satırın üst sınırı arasındaki mesafeye göre hesap yapmaktadır. Word'deki 1 satırlık boşluğu font büyüklüğünün %117 olacak şekilde belirlenmektedir (1,5 satırlık boşluk için %175, 2 satırlık yani çift satırlık boşluk için %233.). Typst'daki hesaplama farklılığından dolayı 1 karakter boyu kadar yani %100 düşüldüğünde yani %17 (0.17em) olarak ayrlandığı taktirde Word'deki 1 satır aralığı elde edilir. Diğerleri için de benzer bir hesap yapılır.\
    [Set Typst default to Office 365 Word's.]\
    [Space between lines in the paragraph.\
    To set the 1 line space in Office 365 Word, first the `top-edge: "ascender"` and `bottom-edge: "descender"` are set. Word calculates the distance between the top of the first line and the top of the second line, while Typst calculates the distance between the bottom of the first line and the top of the second line. The 1 line space in Word is determined as 117% of the font size (1.5 line space is 175%, 2 lines is 233%). Because of the calculation difference, when 1 character width is subtracted (100%), it is 17% (0.17em) and the 1 line space in Word is obtained. Similar calculations are made for others.]

    Kaynaklar [Sources]:
    - https://practicaltypography.com/line-spacing.html
    - https://forum.typst.app/t/getting-office-365-word-line-spacing-in-typst/3422
    - https://github.com/typst/typst/issues/159#issuecomment-1609939896
    - https://github.com/typst/typst/issues/4224#issuecomment-2755827083
    */
    top-edge: "ascender",
    bottom-edge: "descender",
  )

  // Başlık ayarlarını ayarla. [Set heading settings.]
  set heading(
    numbering: none,
    outlined: true,
    bookmarked: true,
  )

  // Başlıkların yazı büyüklüğünü ayarla. [Set heading font size.]
  show heading: set text(size: FONT-SIZE)

  // Paragraf ayarlarını ayarla. [Set paragraph settings.]
  set par(
    justify: true,
    first-line-indent: (amount: PARAGRAPH-FIRST-LINE-INDENT, all: true),
    leading: ONE-AND-HALF-LINE-PARAGRAPH-LEADING-SIZE,
    spacing: DEFAULT-PARAGRAPH-SPACING-SIZE,
  )

  /* ---- Matematiksel Denklem Stili [Math Equation Style] ---- */
  show: math-equation-style

  /* ---- Liste Stili [List Style] ---- */
  show: list-style

  /* ---- Tablo Stili [Table Style] ---- */
  show: table-style

  /* ---- Figür Stili [Figure Style] ---- */
  show: figure-style

  /* ---- Atıf Stili [Reference Style] ---- */
  show: reference-style

  /* ---- Ham/Kod Stili [Raw/Code Style] ---- */
  show: raw-style

  /* ---- Alıntı Stili [Quotation Style] ---- */
  show: quotation-style

  /* ---- Dipnot Stili [Footnote Style] ---- */
  show: footnote-style

  content
}
