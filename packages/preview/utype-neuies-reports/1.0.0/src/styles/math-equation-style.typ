#import "/src/constants/document-settings-constants.typ": MATH-EQUATIONS-FONT-NAME
#import "/src/constants/numbering-constants.typ": MATH-EQUATION-NUMBERING
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Matematiksel Denklem stili. [Math Equation style.]
#let math-equation-style(content) = {
  // Matematiksel Denklem numaralandırması, numaralandırma hizalandırması ve atıf eki. [Math Equation numbering, numbering alingment and reference supplement.]
  set math.equation(
    numbering: MATH-EQUATION-NUMBERING,
    number-align: end + horizon,
    supplement: translator(key: language-keys.MATH-EQUATION-REFERENCE-SUPPLEMENT),
  )

  // Matematiksel Denklemlerin yazı ayarlarını ayarla. [Set text settings of the Math Equations.
  show math.equation: set text(font: MATH-EQUATIONS-FONT-NAME)

  // Blok Matematiksel Denklemler sonraki sayfaya taştığında bölünmesin. [Block Math Equations should not be split when it overflows to the next page.]
  show math.equation: set block(breakable: false)

  content
}
