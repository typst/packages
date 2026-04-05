#import "/src/constants/document-settings-constants.typ": (
  ABSTRACT-TEXT-FONT-SIZE,
  SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
  ZERO-PARAGRAPH-SPACING-SIZE,
)

// Özet sayfası stili. [Abstract page style.]
#let abstract-page-style(content) = {
  // Özet metni normal yazı büyüklüğünden daha küçük olacak şekilde ayarlandı. [The abstract text is set smaller than the normal font size.]
  set text(size: ABSTRACT-TEXT-FONT-SIZE)

  // Paragraf boşluklarını ayarla. [Set paragraph spacing.]
  set par(
    leading: SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
    spacing: ZERO-PARAGRAPH-SPACING-SIZE,
  )

  // Düzey 1 başlıklar ortaya hizalandı. [Level 1 headings are centered.]
  show heading.where(level: 1): set align(center)

  content
}
