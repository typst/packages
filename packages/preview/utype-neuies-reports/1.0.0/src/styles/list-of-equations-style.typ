#import "/src/styles/equation-outline-entry-style.typ": equation-outline-entry-style
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Matematiksel Denklem listesi stili. [List of equations style.]
#let list-of-equations-style(content) = {
  // Ana hattın stili. [Outline style.]
  set outline(
    depth: none,
    indent: auto,
    target: math.equation,
    title: upper(translator(key: language-keys.LIST-OF-EQUATIONS)),
  )

  // Matematiksel Denklem listelerinin girdilerinin stili. [Style of the entries of the figures lists.]
  show: equation-outline-entry-style

  content
}
