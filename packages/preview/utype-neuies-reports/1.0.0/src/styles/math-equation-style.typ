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

  // Blok denklem sonraki sayfaya taştığında bölünmesin.
  show math.equation: set block(breakable: false)

  content
}
