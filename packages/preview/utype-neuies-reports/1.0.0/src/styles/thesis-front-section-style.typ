#import "/src/constants/numbering-constants.typ": PAGE-NUMBERING-ROMAN
#import "/src/styles/thesis-front-section-heading-style.typ": thesis-front-section-heading-style

// Tezin ön kısmının stili. [Style of the front section of the thesis.]
#let thesis-front-section-style(content) = {
  // Roman rakamlı sayfa numaralandırmasını ayarla. [Set centered roman page numbering.]
  set page(numbering: PAGE-NUMBERING-ROMAN)

  // Başlık stili. [Heading style.]
  show: thesis-front-section-heading-style

  content
}
