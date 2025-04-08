#import "/src/styles/figure-outline-entry-style.typ": figure-outline-entry-style
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Tablo figürleri listesi stili. [List of table figures style.]
#let list-of-table-figures-style(content) = {
  // Ana hattın stili. [Outline style.]
  set outline(
    depth: none,
    indent: auto,
    target: figure.where(kind: table),
    title: upper(translator(key: language-keys.LIST-OF-TABLES)),
  )

  // Figürler listelerinin girdilerinin stili. [Style of the entries of the figures lists.]
  show: figure-outline-entry-style

  content
}
