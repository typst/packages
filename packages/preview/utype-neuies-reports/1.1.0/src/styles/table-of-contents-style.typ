#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/styles/table-of-contents-outline-entry-style.typ": table-of-contents-outline-entry-style

// İçindekiler stili. [Table of Contents' style.]
#let table-of-contents-style(content) = {
  // Ana hat ayarları. [Outline settings.]
  set outline(
    depth: 3,
    indent: n => n * 1em,
    target: heading,
    title: upper(translator(key: language-keys.TABLE-OF-CONTENTS)),
  )

  // İçindekiler'in girdilerinin stili. [Style of the entries of the Table of Contents.]
  show: table-of-contents-outline-entry-style

  content
}
