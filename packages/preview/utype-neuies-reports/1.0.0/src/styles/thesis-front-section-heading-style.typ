#import "/src/styles/heading-spacing-style.typ": heading-spacing-style
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Tezin ön kısmındaki başlıkların stili. [Style of the headings in the front section of the thesis.]
#let thesis-front-section-heading-style(content) = {
  // 1. düzey başlıklar ortaya hizalandı. [1st level headings are aligned center.]
  show heading.where(level: 1): set align(center)

  // 2. düzey başlıklar sola hizalandı. [2nd level headings are aligned left.]
  show heading
    .where(level: 2)
    .or(heading.where(level: 3))
    .or(heading.where(level: 4))
    .or(heading.where(level: 5))
    .or(heading.where(level: 6)): set align(left)

  // 1. düzey başlıklarda numaralandırma yok, İçindekiler tablosunda var, PDF dökümanı hatlarında var. [1st level headings are numbered, listed in the table of contents and appear in the PDF document.]
  show heading.where(level: 1): set heading(numbering: none, outlined: true, bookmarked: true)

  // 2. düzey başlıklarda numaralandırma yok, İçindekiler tablosunda yok, PDF dökümanı hatlarında var. [2nd level headings are numbered, listed in the table of contents and appear in the PDF document.]
  show heading
    .where(level: 2)
    .or(heading.where(level: 3))
    .or(heading.where(level: 4))
    .or(heading.where(level: 5))
    .or(heading.where(level: 6)): set heading(numbering: none, outlined: false, bookmarked: true)

  // 4, 5 ve 6. düzey başlıklar italik yapıldı. [4th, 5th and 6th level headings are italicized.]
  show heading.where(level: 4).or(heading.where(level: 5)).or(heading.where(level: 6)): set text(style: "italic")

  // Başlıklardan önce ve sonra olan boşluk miktarı ayarlandı. [Set the amount of space before and after headings.]
  show: heading-spacing-style

  // Tezin ana bölümündeki başlıklara yapılan atıfların ön ekini ayarla. [Set the supplement of references to headings in the main section of the thesis.]
  show heading.where(level: 1): set heading(supplement: translator(key: language-keys.CHAPTER-REFERENCE-SUPPLEMENT))
  show heading
    .where(level: 2)
    .or(heading.where(level: 3))
    .or(heading.where(level: 4))
    .or(heading.where(level: 5))
    .or(heading.where(level: 6)): set heading(supplement: translator(key: language-keys.HEADING-REFERENCE-SUPPLEMENT))

  content
}
