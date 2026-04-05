#import "/src/constants/numbering-constants.typ": PAGE-NUMBERING-ARABIC
#import "/src/styles/thesis-main-section-heading-style.typ": thesis-main-section-heading-style

// Tezin ana kısmının stili. [Style of the main section of the thesis.]
#let thesis-main-section-style(content) = {
  // Ortalanmış Arap rakamlı sayfa numaralandırmasını ayarla. [Set centered arabic page numbering.]
  set page(numbering: PAGE-NUMBERING-ARABIC)

  // Sayfa numaralandırmasını 1'den başlat. [Start page numbering from 1.]
  counter(page).update(1)

  // Başlık stili. [Heading style.]
  show: thesis-main-section-heading-style

  content
}
