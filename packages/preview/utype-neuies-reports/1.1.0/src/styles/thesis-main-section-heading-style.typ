#import "/src/constants/document-settings-constants.typ": DEFAULT-PARAGRAPH-SPACING-SIZE
#import "/src/constants/numbering-constants.typ": HEADING-NUMBERING
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/styles/heading-spacing-style.typ": heading-spacing-style

// Tezin ana kısmındaki başlıkların stili. [Style of the headings in the main section of the thesis.]
#let thesis-main-section-heading-style(content) = {
  // Başlıklar sola hizalandı. [Headings are aligned left.]
  show heading: set align(left)

  // 1, 2 ve 3. düzey başlıklarda numaralandırma var ve numaralandırma biçimi ayarlandı, İçindekiler tablosunda var, PDF dökümanı hatlarında var. [1, 2 and 3 level headings are numbered, listed in the table of contents and appear in the PDF document.]
  show heading.where(level: 1).or(heading.where(level: 2)).or(heading.where(level: 3)): set heading(
    numbering: HEADING-NUMBERING,
    outlined: true,
    bookmarked: true,
  )

  // 4, 5 ve 6. düzey başlıklarda numaralandırma yok, İçindekiler tablosunda var, PDF dökümanı hatlarında var. [4, 5 and 6 level headings are numbered, listed in the table of contents and appear in the PDF document.]
  show heading.where(level: 4).or(heading.where(level: 5)).or(heading.where(level: 6)): set heading(
    numbering: none,
    outlined: true,
    bookmarked: true,
  )

  // 4, 5 ve 6. düzey başlıklar italik yapıldı. [4, 5 and 6 level headings are italicized.]
  show heading.where(level: 4).or(heading.where(level: 5)).or(heading.where(level: 6)): set text(style: "italic")

  // Başlıklardan önce ve sonra olan boşluk miktarı ayarlandı. [Set the amount of space before and after headings.]
  show: heading-spacing-style

  // Her numaralandırmaya sahip 1. düzey başlık için "Bölüm X" ön başlığını ekle. [For each numbered 1st level heading, add the prefix heading "Bölüm X".]
  show heading.where(level: 1): it => {
    if it.numbering != none {
      // Figür sayaçlarını sıfırla. [Reset figure counters.]
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)

      align(center)[
        #let chapter-heading-prefix = [
          #set heading(level: 1, numbering: HEADING-NUMBERING, outlined: false, bookmarked: false)
          // Sondaki noktayı kaldır. [Remove the last dot.]
          #upper(translator(key: language-keys.CHAPTER)) #counter(heading).get().first()
        ]
        #chapter-heading-prefix \
        // 1.5 satır aralığı (1em karakterin kendisi + 0.5em) ve paragraflar arası boşluk miktarı kadar boşluk eklendi.
        #v(0.5em + DEFAULT-PARAGRAPH-SPACING-SIZE)
      ]
    }
    it
  }

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
