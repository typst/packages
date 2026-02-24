#import "/src/constants/document-settings-constants.typ": (
  DEFAULT-PARAGRAPH-SPACING-SIZE,
  SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
)

// Kaynaklar sayfası stili. [References page style.]
#let bibliography-page-style(content) = {
  // Kaynaklar sayfasındaki paragraf stili. [Paragraph style in References page.]
  set par(
    first-line-indent: 0cm,
    hanging-indent: 1.25cm,
    justify: true,
    leading: SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
    spacing: DEFAULT-PARAGRAPH-SPACING-SIZE,
  )

  content
}
