#import "/src/constants/document-settings-constants.typ": FONT-NAME-MATH-EQUATIONS
#import "/src/constants/numbering-constants.typ": MATH-NUMBERING
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Matematiksel denklem stili. [Math equation style.]
#let math-equation-style(content) = {
  // Denklem numaralandırması, numaralandırma hizalandırması ve atıf eki. [Equation numbering, numbering alingment and reference supplement.]
  set math.equation(
    numbering: MATH-NUMBERING,
    number-align: end + horizon,
    supplement: translator(key: language-keys.MATH-EQUATION-REFERENCE-SUPPLEMENT),
  )

  // Matematiksel Denklemlerin yazı ayarlarını ayarla. [Set text settings of the Math Equations.
  show math.equation: set text(font: FONT-NAME-MATH-EQUATIONS)

  // Blok denklem sonraki sayfaya taştığında bölünmesin.
  show math.equation: set block(breakable: false)

  content
}
