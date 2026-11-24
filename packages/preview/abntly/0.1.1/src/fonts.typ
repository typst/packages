// Typography of abntly: New Computer Modern in every element, the sans and the serif as `elements` gives them to
// each one, the Mono for code and the Math for equations, in the Regular weight. The 08 cuts of the serif and of the
// sans are for small letters only (the superscripts and the subscripts).
//
// Each family falls back to a font embedded in Typst, which embeds no sans. Whoever does not install New Computer
// Modern (sh scripts/fonts.sh or scripts/fonts.ps1) compiles all the same, with "unknown font family" warnings that
// name each missing family, one per rule that uses it: the sans and the 08 cuts fall back to the embedded serif New
// Computer Modern, and the mono to DejaVu Sans Mono.
//
// Sizes: the scale of the package (`sizes`), with short names from `xs` to `xxxl`, all of it in `em` of the body. The
// body is the only absolute size, 12 pt (NBR 14724, 5.1), and an author changes it with a plain
// `#set text(size: 11pt)` after `#show: abntly`: everything else follows, since it is all in `em`. Above 12 pt, the
// size of the scale is multiplied by the optical correction of the package (`correction`), a factor a little under 1
// that depends on the family and on the size. The bold sans, and every size up to 12 pt, take the size of the scale
// as it is.
//
// The main function (src/abntly.typ) applies `fonts`; `elements` gives the `text` arguments of each element to the
// other files of the package.

#let families = (
  serif: "New Computer Modern",
  serif-small: ("New Computer Modern 08", "New Computer Modern"),
  sans: ("New Computer Modern Sans", "New Computer Modern"),
  sans-small: ("New Computer Modern Sans 08", "New Computer Modern Sans", "New Computer Modern"),
  mono: ("New Computer Modern Mono", "DejaVu Sans Mono"),
  math: "New Computer Modern Math",
)

// The size scale of the package, with only the sizes its elements use (superscripts follow `script-size`). In `em` of
// the body: the pt values in the comments are those of a 12 pt body.
#let sizes = (
  xs: 10em / 12,        // 10 pt: long quotes, footnotes, sources of illustrations, page numbers
  sm: 10.95em / 12,     // 10.95 pt
  base: 1em,            // the body, 12 pt
  lg: 14.4em / 12,      // 14.4 pt
  xl: 17.28em / 12,     // 17.28 pt
  xxl: 20.74em / 12,    // 20.74 pt
  xxxl: 24.88em / 12,   // 24.88 pt
)

// The optical correction of the sizes above 12 pt, per family and range of sizes (in pt of a 12 pt body). The bold
// sans takes none.
#let correction = (
  sans-12: 0.9880,   // the sans above 12 pt, up to 15.5 pt
  sans-17: 0.9534,   // the sans above 15.5 pt
  serif-12: 0.9895,  // the serif above 12 pt, up to 15 pt
  serif-17: 0.9557,  // the serif above 15 pt (no element uses it)
)

// The `text` arguments of each element: `text(..elements.cover-title)[...]`. Weight and style appear only where they
// are not the regular.
#let elements = (
  body: (font: families.serif, size: sizes.base),

  // Headings: sans in the regular weight, the hierarchy by size
  // the primary heading, also the unnumbered ones, the abstract, the appendices and the part
  chapter: (font: families.sans, size: sizes.xxxl * correction.sans-17),
  section: (font: families.sans, size: sizes.xl * correction.sans-17),
  subsection: (font: families.sans, size: sizes.lg * correction.sans-12),
  // the fourth and the fifth levels, in the size of the body
  subsubsection: (font: families.sans, size: sizes.base),
  paragraph: (font: families.sans, size: sizes.base),

  // Cover: the title in bold
  cover-author: (font: families.sans, size: sizes.lg * correction.sans-12),
  cover-title: (font: families.sans, size: sizes.xxl, weight: "bold"),
  cover-place: (font: families.sans, size: sizes.lg * correction.sans-12),

  // Title page: the author and the title in sans, as on the cover; the rest in serif
  title-page-author: (font: families.sans, size: sizes.lg * correction.sans-12),
  title-page-title: (font: families.sans, size: sizes.xl, weight: "bold"),
  // the nature of the work and the institution, in the size of the body
  title-page-preamble: (font: families.serif, size: sizes.base),
  title-page-institution: (font: families.serif, size: sizes.base),
  title-page-advisor: (font: families.serif, size: sizes.lg * correction.serif-12),
  title-page-place: (font: families.serif, size: sizes.lg * correction.serif-12),

  // Approval sheet: the author and the title as on the title page
  approval-author: (font: families.sans, size: sizes.lg * correction.sans-12),
  approval-title: (font: families.sans, size: sizes.xl, weight: "bold"),
  approval-place: (font: families.serif, size: sizes.lg * correction.serif-12),

  // Catalog card: sans, a step under the body
  catalog-card: (font: families.sans, size: sizes.sm),

  // Table of contents: all sans, with the entries of part, chapter and section in bold
  toc-part: (font: families.sans, size: sizes.lg, weight: "bold"),
  toc-chapter: (font: families.sans, size: sizes.base, weight: "bold"),
  toc-section: (font: families.sans, size: sizes.base, weight: "bold"),
  toc-subsection: (font: families.sans, size: sizes.base),
  toc-subsubsection: (font: families.sans, size: sizes.sm),
  toc-paragraph: (font: families.sans, size: sizes.xs),
  // the dots from the sections down, in the serif of the body
  toc-leaders: (font: families.serif, size: sizes.base),

  // Smaller body: 10 pt of a 12 pt body
  footnote: (font: families.serif, size: sizes.xs),
  quote: (font: families.serif, size: sizes.xs),
  // the source, the legend and the notes of the illustrations
  source-and-note: (font: families.serif, size: sizes.xs),
  page-number: (font: families.serif, size: sizes.xs),
  // the running header, in italic
  header: (font: families.serif, size: sizes.xs, style: "italic"),

  // Caption: the title of an illustration or a table, in the size of the body
  caption: (font: families.serif, size: sizes.base),

  // Code in the size of the text
  code: (font: families.mono, size: sizes.base),
)

// Superscripts and subscripts (footnote marks, indices, ordinals): 8 pt in a 12 pt body and 7 pt in a 10 pt footnote.
#let script-size = (body: 8em / 12, footnote: 7em / 10)

// The rules of the typography, on a body of 12 pt.
#let fonts(body) = {
  set text(font: elements.body.font, size: 12pt)
  set super(size: script-size.body)
  set sub(size: script-size.body)
  // The 08 cut only for small letters: the indices of the body (8 pt) and of the footnotes (7 pt)
  show super: set text(font: families.serif-small)
  show sub: set text(font: families.serif-small)
  // Typst sets footnotes at 0.85 em of the body and this `em` counts from there: the size of the scale divided by it
  // (a size in pt would not follow a body the author sets)
  show footnote.entry: set text(size: elements.footnote.size / 0.85)
  show footnote.entry: set super(size: script-size.footnote)
  show footnote.entry: set sub(size: script-size.footnote)
  show quote.where(block: true): set text(size: elements.quote.size)
  // Typst sets `raw` at 0.8 of the text; the package, in the size of the text
  show raw: set text(font: families.mono, size: 1.25em)
  // Typst sets equations in weight 450, which in the Math is the Book cut, heavier than the Regular text
  show math.equation: set text(font: families.math, weight: "regular")
  // Typst enlarges headings by itself (1.4 em at level 1, 1.2 em at level 2, 1 em below) and the `em` of a rule
  // counts from there: the size of the scale divided by that factor, as `raw` above
  show heading: set text(font: families.sans, weight: "regular")
  show heading.where(level: 1): set text(size: elements.chapter.size / 1.4)
  show heading.where(level: 2): set text(size: elements.section.size / 1.2)
  show heading.where(level: 3): set text(size: elements.subsection.size)
  show heading.where(level: 4): set text(size: elements.subsubsection.size)
  show heading.where(level: 5): set text(size: elements.paragraph.size)
  // The indices of a heading follow its sans: in the 08 cut at the size of the body (levels 4 and 5, 8 pt indices);
  // from 9.5 pt up (levels 1 to 3) they are not small letters and keep the cut of the heading
  show heading: it => {
    let small = if it.level >= 4 { families.sans-small } else { families.sans }
    show super: set text(font: small)
    show sub: set text(font: small)
    it
  }
  body
}
