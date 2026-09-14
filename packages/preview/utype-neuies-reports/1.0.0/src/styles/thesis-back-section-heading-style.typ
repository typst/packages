#import "/src/styles/heading-spacing-style.typ": heading-spacing-style
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Tezin arka kısmındaki başlıkların stili. [Style of the headings in the back section of the thesis.]
#let thesis-back-section-heading-style(content) = {
  // Ek başlıklarının başlık stili. [Appendix headings style.]
  let APPENDIX-HEADING-NUMBERING(..nums) = (
    translator(key: language-keys.APPENDIX-PREFIX) + numbering("1.1.", ..nums.pos().slice(1))
  )

  // Ek başlıklarına yapılan atıfların numaralandırması. [Numbering of citations to appendix headings.]
  let APPENDIX-REFERENCE-NUMBERING(..nums) = numbering("1.1", ..nums.pos().slice(1))

  // Başlıklar sola hizalandı. [Headings are aligned left.]
  show heading: set align(left)

  // 1. düzey başlıklarda numaralandırma yok, buna yapılan atıflarda özel ön ek var, İçindekiler tablosunda var, PDF dökümanı hatlarında var. [1st level headings are non-numbered, has special prefix for citings to this, listed in the table of contents and appear in the PDF document.]
  show heading.where(level: 1): set heading(
    numbering: none,
    outlined: true,
    bookmarked: true,
    supplement: translator(key: language-keys.CHAPTER-REFERENCE-SUPPLEMENT),
  )

  // 2. düzey başlıklarda özel numaralandırma var, buna yapılan atıflarda özel ön ek var, İçindekiler tablosunda var, PDF dökümanı hatlarında var. [2nd level headings has special numbering, has not special prefix for citings to this, listed in the table of contents and appear in the PDF document.]
  show heading.where(level: 2).or(heading.where(level: 3)): set heading(
    numbering: APPENDIX-HEADING-NUMBERING,
    outlined: true,
    bookmarked: true,
    supplement: none,
  )

  // 4, 5 ve 6. düzey başlıklarda numaranlandırma yok, İçindekiler tablosunda yok, PDF dökümanı hatlarında yok. [4th, 5th and 6th level headings are not numbered, not listed in the table of contents and do not appear in the PDF document.]
  show heading.where(level: 4).or(heading.where(level: 5)).or(heading.where(level: 6)): set heading(
    numbering: none,
    outlined: false,
    bookmarked: false,
    supplement: translator(key: language-keys.HEADING-REFERENCE-SUPPLEMENT),
  )

  // 4, 5 ve 6. düzey başlıklar italik yapıldı. [4th, 5th and 6th level headings are italicized.]
  show heading.where(level: 4).or(heading.where(level: 5)).or(heading.where(level: 6)): set text(style: "italic")

  // Başlıklardan önce ve sonra olan boşluk miktarı ayarlandı. [Set the amount of space before and after headings.]
  show: heading-spacing-style

  content
}
