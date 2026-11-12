# Tlacuilolli

Tlacuilolli is a Typst library for research notes and scholarly essays. It starts with a centered title and justified serif prose on US Letter or A4. Photographs, equations, quotations, and tables sit in the running text. The same package supports English and Spanish documents.

The project takes its name from the Nahuatl word `tlacuilolli`, recorded in the Gran Diccionario Náhuatl as “escritura, pintura.” [Dictionary entry at UNAM](https://tlachia.iib.unam.mx/elementos/tlacuilolli)

## Start writing

Use Typst 0.15.1 or newer.

```typst
#import "@preview/tlacuilolli:0.1.0": *

#show: note-document.with(
  title: [Cuaderno de lectura],
  subtitle: [Notas sobre una primera edición],
  category: [Literatura],
  lang: "es",
)

Aquí comienza mi investigación.
```

The default body font is Libertinus Serif with New Computer Modern as the next choice. Both families ship with the official Typst CLI. Display and inline mathematics use Typst's bundled math font. Pass `font` to choose an installed family or an ordered list of families.

## Public API

| Functions | Purpose |
| --- | --- |
| `note-document` | Page layout, type, title, and PDF metadata |
| `image-left`, `image-right`, `image-center` | Figures with optional captions |
| `display-equation` | Native display math with optional numbering and references |
| `inner`, `set-builder`, `derivative`, `partial-derivative` | Mathematical notation |
| `theorem`, `definition`, `lemma`, `proposition`, `corollary`, `axiom`, `example`, `remark` | Bilingual statements with independent, document-wide counters |
| `proof` | Unnumbered proof with an optional closing mark |
| `roman-list`, `note-table` | Native enumerations and tables with restrained styling |

Side figures use two fixed columns. Long prose can continue in its column across pages, and the text after the macro resumes at full width. Use native `@key` citations and `#bibliography(...)` with your own `.bib` or Hayagriva file. The [API reference](https://github.com/MHAlberto/Tlacuilolli/blob/6e31764b567bf3c77f0ae578a2b3a40e83394eac/docs/api.md) documents parameters, examples, and page-break behavior.

Tables size their columns to the contents by default. For a wider table, specify flexible tracks such as `columns: (2fr, 1fr)`.

See the [example notes](https://github.com/MHAlberto/Tlacuilolli/tree/6e31764b567bf3c77f0ae578a2b3a40e83394eac/examples) for physics, mathematics, and literature.

The library is released under the [MIT license](LICENSE).
