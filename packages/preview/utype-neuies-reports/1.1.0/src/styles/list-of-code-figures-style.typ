#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/styles/figure-outline-entry-style.typ": figure-outline-entry-style

// Kod figürü listelerinin stili. [Lists of code figure style.]
#let list-of-code-figures-style(content) = {
  // Ana hattın stili. [Outline style.]
  set outline(
    depth: none,
    indent: auto,
    target: figure.where(kind: raw),
    title: upper(translator(key: language-keys.LIST-OF-CODES)),
  )

  // Figürler listelerinin girdilerinin stili. [Style of the entries of the figures lists.]
  show: figure-outline-entry-style

  content
}
