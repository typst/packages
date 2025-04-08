/* ---- Belge Düzeni [Document Layout] ---- */

// Kağıt boyutu [Paper size]
#let PAPER = "a4"

// Kenar boşlukları [Margin]
#let MARGIN = (
  left: 2.5cm,
  top: 2.5cm,
  right: 2.5cm,
  bottom: 2.5cm,
)

/* ---- Yazı Tipi Ayarları [Font Settings] ---- */

// Yazı tipi adı [Font name]
#let FONT-NAME = "Times New Roman"

// Ana yazı tipi boyutu [Main font size]
#let FONT-SIZE = 12pt

// Alternatif yazı tipi boyutu [Alternate font size]
#let ALTERNATE-FONT-SIZE = 10pt

// 2. alternatif yazı tipi boyutu [Second alternate font size]
#let ALTERNATE-FONT-SIZE-2 = 9pt

// Özet metinlerinin yazı tipi boyutu [Font size of the Abstract texts]
#let ABSTRACT-TEXT-FONT-SIZE = ALTERNATE-FONT-SIZE

// Tablo ve Şekil figürlerinin başlığının yazı tipi boyutu [Font size of the title of table and image figures' caption]
#let FIGURE-TITLE-TEXT-FONT-SIZE = ALTERNATE-FONT-SIZE

// Tablo ve Şekil figürlerinin içerğinin yazı tipi boyutu [Font size of the title of table and figure contents]
#let FIGURE-CONTENT-TEXT-FONT-SIZE = ALTERNATE-FONT-SIZE

// Dipnotların yazı tipi boyutu [Font size of the Footnotes]
#let FOOTNOTE-TEXT-FONT-SIZE = ALTERNATE-FONT-SIZE

// Varsayılan yazı kalınlığı [Default font weight]
#let DEFAULT-TEXT-FONT-WEIGHT = "regular"

/* ---- Paragraf Ayarları [Paragraph Settings] ---- */

// Paragraf ilk satır girintisi [Paragraph first line indent]
#let PARAGRAPH-FIRST-LINE-INDENT = 1.25cm

/*
Paragraflardaki satırlar arası boşluk miktarı.\
Office 365 Word'deki 1 satırlık boşluğu ayarı için öncelikle Word'ün aradaki boşluğu hesaplamak için kullandığı noktalar olan `top-edge: "ascender"` ve `bottom-edge: "descender"` yapılır. Word, ilk satırın üst sınırı ile sonraki satırın üst sınırı arasındaki mesafeye göre hesap yaparken Typst ilk satırın alt sınırı ile sonraki satırın üst sınırı arasındaki mesafeye göre hesap yapmaktadır. Word'deki 1 satırlık boşluğu font büyüklüğünün %117 olacak şekilde belirlenmektedir. Typst'daki hesaplama farklılığından dolayı 1 karakter boyu kadar yani %100 düşüldüğünde yani %17 (0.17em) olarak ayrlandığı taktirde Word'deki 1 satır aralığı elde edilir.\
[Space between lines in the paragraph.\
To set the 1 line space in Office 365 Word, first the `top-edge: "ascender"` and `bottom-edge: "descender"` are set. Word calculates the distance between the top of the first line and the top of the second line, while Typst calculates the distance between the bottom of the first line and the top of the second line. The 1 line space in Word is determined as 117% of the font size. Because of the calculation difference, when 1 character width is subtracted (100%), it is 17% (0.17em) and the 1 line space in Word is obtained.]

Kaynaklar [Sources]:
- https://practicaltypography.com/line-spacing.html
- https://forum.typst.app/t/getting-office-365-word-line-spacing-in-typst/3422
- https://github.com/typst/typst/issues/159#issuecomment-1609939896
- https://github.com/typst/typst/issues/4224#issuecomment-2755827083
*/
#let SINGLE-LINE-PARAGRAPH-LEADING-SIZE = 0.17em

/*
Paragraflardaki satırlar arası boşluk miktarı (1,5 satır yani 1.5em = FONT-SIZE x 1.5).\
Office 365 Word'deki 1,5 satırlık boşluğu ayarı için öncelikle Word'ün aradaki boşluğu hesaplamak için kullandığı noktalar olan `top-edge: "ascender"` ve `bottom-edge: "descender"` yapılır. Word, ilk satırın üst sınırı ile sonraki satırın üst sınırı arasındaki mesafeye göre hesap yaparken Typst ilk satırın alt sınırı ile sonraki satırın üst sınırı arasındaki mesafeye göre hesap yapmaktadır. Word'deki 1,5 satırlık boşluğu font büyüklüğünün %175 olacak şekilde belirlenmektedir. Typst'daki hesaplama farklılığından dolayı 1 karakter boyu kadar yani %100 düşüldüğünde yani %75 (0.75em) olarak ayrlandığı taktirde Word'deki 1,5 satır aralığı elde edilir.\
[Space between lines in the paragraph (1.5 lines so 1.5em = FONT-SIZE x 1.5).\
To set the 1.5 line space in Office 365 Word, first the `top-edge: "ascender"` and `bottom-edge: "descender"` are set. Word calculates the distance between the top of the first line and the top of the second line, while Typst calculates the distance between the bottom of the first line and the top of the second line. The 1.5 line space in Word is determined as 175% of the font size. Because of the calculation difference, when 1 character width is subtracted (100%), it is 75% (0.75em) and the 1.5 line space in Word is obtained.]

Kaynaklar [Sources]:
- https://practicaltypography.com/line-spacing.html
- https://forum.typst.app/t/getting-office-365-word-line-spacing-in-typst/3422
- https://github.com/typst/typst/issues/159#issuecomment-1609939896
- https://github.com/typst/typst/issues/4224#issuecomment-2755827083
*/
#let ONE-AND-HALF-LINE-PARAGRAPH-LEADING-SIZE = 0.75em

// Paragraflar arasında boşluk yok. [No spacing between paragraphs.]\
// Kaynak: https://practicaltypography.com/space-between-paragraphs.html
#let ZERO-PARAGRAPH-SPACING-SIZE = 0pt + SINGLE-LINE-PARAGRAPH-LEADING-SIZE

// Paragraflar arasındaki boşluk. [Spacing between paragraphs]\
// Kaynak: https://practicaltypography.com/space-between-paragraphs.html
#let DEFAULT-PARAGRAPH-SPACING-SIZE = 12pt + SINGLE-LINE-PARAGRAPH-LEADING-SIZE
