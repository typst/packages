# Código Matemático

Mathematical notes with PDF and web (HTML) output from the same source.
Includes numbered definitions, axioms, theorems, propositions, lemmas,
corollaries, examples, exercises, problems, and proofs. Environment labels
are currently in Spanish, independently of the document's `lang` setting.
Requires Typst **0.15.0 or later**.

## Start a document

After publication, choose **Start from template** on Typst Universe or run:

```sh
typst init @preview/codigo-matematico:0.1.0 my-notes
cd my-notes
typst compile main.typ main.pdf
typst compile --features html --format html main.typ main.html
```

The initial document contains an original, editable example about distances
on the real line. To apply the package to an existing document:

```typst
#import "@preview/codigo-matematico:0.1.0": *

#show: templ.with(
  lang: "es",
  title: [Mis apuntes de matemáticas],
  authors: (),
  abstract: [Definiciones y resultados básicos.],
)

= Distancias

#definition(title: [Distancia usual])[
  Para $x, y in RR$, sea $d(x, y) = abs(x - y)$.
] <def-distancia>

Véase la @def-distancia.
```

## Document options

Pass options through `templ.with(...)`:

| Option | Default | Purpose |
| --- | --- | --- |
| `sheet` | `"a4"` | PDF paper size; `"tablet"` selects A5 with compact margins. |
| `lang` | `"en"` | Document language for Typst's built-in labels and hyphenation. |
| `title` | `none` | Document title, as content or a string. |
| `authors` | `()` | Array of author dictionaries. For both targets, provide `name`, `affiliation`, and `email`. |
| `abstract` | `[]` | Abstract content. |
| `parts` | `false` | Use level-two headings as chapters for image and table numbering. |
| `outline_depth` | `4` | Maximum heading depth in the outline. |
| `env_counter_reset_depth` | `auto` | Heading level that resets environment counters; `auto` means level one. |
| `web_css` | `auto` | Bundled stylesheet, `none` to omit it, or a replacement CSS string. |

## Mathematical environments

Use `#definition[...]`, `#theorem[...]`, `#proposition[...]`, `#lemma[...]`,
`#corollary[...]`, `#example[...]`, `#exercise[...]`, and `#problem[...]`.
They accept `title`, `number`, and `numbering`. Automatic numbering uses the
level-one heading number as a prefix. Axioms use `num` instead of `number`
and have their own global counter, as described below.

Attach a label immediately after an environment and reference it with `@label`.
Use `#proof[...]` or `#proof(ref: [@label])[...]` for demonstrations, and
`#remark[...]`, `#remark_notat[...]`, or `#remark_term[...]` for observations,
notation, and terminology.

## Output and typography

HTML export is still experimental in Typst 0.15, so the `html` feature flag
is required. Equations are emitted as accessible MathML. The template
detects the target with `target()` and embeds `src/web.css` in the generated
HTML; paged layout rules are preserved for PDF output.

MathML uses New Computer Modern Math font (the ubiquous TeX and LaTeX font).
The stylesheet first looks for a local installation and otherwise loads
pinned WOFF2 regular and bold files from the `web-computer-modern` package
through jsDelivr. When the CDN is unavailable, the CSS falls back to STIX
Two Math, Cambria Math, and the browser default serif font.

The HTML body font is loaded as a variable Noto Sans family from Google
Fonts, including its italic style and the full 100–900 weight range. Code
uses the official no-ligatures JetBrains Mono NL files from the v2.304
release, pinned and served through jsDelivr. System fonts remain as
fallbacks if a CDN cannot be reached.

Axioms have their own global, continuously increasing counter and are
displayed as `Axioma 1`, `Axioma 2`, and so on, independently of headings.
Pass `num` to set the counter explicitly; the following automatic axiom
continues from that value:

```typst
#axiom(num: 6, title: [Axioma de Euclides de la Regla Graduada])[
  Contenido del axioma.
]
```

In HTML output, proofs are collapsed by default using the native `details`
and `summary` elements. The disclosure marker can be activated with a
pointer or keyboard and reveals the complete proof without requiring
JavaScript. PDF output continues to display proofs in full.

Web links have a visible keyboard focus indicator. Smooth scrolling follows
the reader's reduced-motion preference, and the proof disclosure marker
turns when the proof is open.

Pass `web_css: none` to `templ.with` to omit the bundled stylesheet, or pass
a CSS string (for example, `read("custom.css")`) to replace it. The default
theme is dark. When developing a local copy of the package, select the
common light/dark palette through `palette_theme` in `src/palette.typ`.

## PDF fonts

For the intended PDF typography, install **Noto Sans** and **JetBrains Mono NL**
on your computer, or supply them with `typst compile --font-path /path/to/fonts`.
In the web editor, upload missing fonts to your project. New Computer Modern
Math is provided by Typst. Fonts are not bundled with this package; missing
text fonts may produce warnings and a different fallback appearance. The
HTML font loading described above works independently of PDF font discovery.

## License

The library in `src/` and this documentation are licensed under **MIT**;
see [LICENSE](LICENSE). The editable starter in `template/` is licensed under
**MIT-0**; see [LICENSE-MIT-0](LICENSE-MIT-0). You can use and distribute your
adapted starter document without attribution or including license text.
