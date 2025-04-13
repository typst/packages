#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/styles/math-equation-outline-entry-style.typ": math-equation-outline-entry-style

// Matematiksel Denklem listesi stili. [List of Math Equations style.]
#let list-of-math-equations-style(content) = {
  // Ana hattın stili. [Outline style.]
  set outline(
    depth: none,
    indent: auto,
    target: math.equation,
    title: upper(translator(key: language-keys.LIST-OF-EQUATIONS)),
  )

  // Matematiksel Denklem listelerinin girdilerinin stili. [Style of the entries of the figures lists.]
  show: math-equation-outline-entry-style

  content
}
