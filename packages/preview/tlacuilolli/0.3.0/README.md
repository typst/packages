# Tlacuilolli

Tlacuilolli is a Typst library for research notes and scholarly essays. It starts with a centered title and justified serif prose on US Letter or A4. Photographs, equations, quotations, and tables sit in the running text. The same package supports English and Spanish documents.

The project takes its name from the Nahuatl word `tlacuilolli`, recorded in the Gran Diccionario Náhuatl as “escritura, pintura.” [Dictionary entry at UNAM](https://tlachia.iib.unam.mx/elementos/tlacuilolli)

## Start writing

Use Typst 0.15.1 or newer.

```typst
#import "@preview/tlacuilolli:0.3.0": *

#show: note-document.with(
  title: [Cuaderno de lectura],
  subtitle: [Notas sobre una primera edición],
  category: [Literatura],
  lang: "es",
)

Aquí comienza mi investigación.
```

The default body font is New Computer Modern with Libertinus Serif as a fallback. Both families ship with the official Typst CLI. Display and inline mathematics use Typst's bundled math font. Pass `font` to choose an installed family or an ordered list of families.

## Source code

Use a fenced block with a language tag to get syntax highlighting and line numbers automatically.

````typst
```python
def squared(x):
    return x * x
```
````

[See the code preview](https://github.com/MHAlberto/Tlacuilolli/blob/v0.3.0/docs/previews/code.png) or [download the full example PDF](https://github.com/MHAlberto/Tlacuilolli/releases/download/v0.3.0/code.pdf).

## Public API

| Functions | Purpose |
| --- | --- |
| `note-document` | Page layout, type, title, and PDF metadata |
| `image-left`, `image-right`, `image-center` | Figures with optional captions |
| `display-equation` | Native display math with optional numbering and references |
| `code-listing` | Syntax highlighting with optional titles and configurable line numbers |
| `inner`, `set-builder`, `derivative`, `partial-derivative` | Mathematical notation |
| `theorem`, `definition`, `lemma`, `proposition`, `corollary`, `axiom`, `example`, `remark` | Bilingual statements with independent, document-wide counters |
| `proof` | Unnumbered proof with an optional closing mark |
| `roman-list`, `note-table` | Native enumerations and tables with restrained styling |

Side figures use two fixed columns. Long prose can continue in its column across pages, and the text after the macro resumes at full width. Use native `@key` citations and `#bibliography(...)` with your own `.bib` or Hayagriva file. The [API reference](https://github.com/MHAlberto/Tlacuilolli/blob/v0.3.0/docs/api.md) documents parameters, examples, and page-break behavior.

Tables size their columns to the contents by default. For a wider table, specify flexible tracks such as `columns: (2fr, 1fr)`.

See the [example notes](https://github.com/MHAlberto/Tlacuilolli/tree/v0.3.0/examples) for physics, mathematics, literature, and code.

The library is released under the [MIT license](LICENSE).
