#import "@local/hetvid:0.1.0": *
#import "@preview/metalogo:1.2.0": TeX, LaTeX // For displaying the LaTeX logo
#import "@preview/cetz:0.3.4": canvas, draw
#import "@preview/fancy-units:0.1.1": num, unit, qty

#show: hetvid.with(
  title: [Hetvid: A Typst template for lightweight notes],
  author: "itpyi",
  affiliation: "Xijing Ci'en Institute of Translation, Tang Empire",
  header: "Instruction",
  date-created: "2025-03-27",
  date-modified: "2025-04-22",
  abstract: [This is a template designed for writing scientific notes. ],
  toc: true,
)

In this doc, upcoming features are represented by #text-muted[light font]. 

= Usage<sec-usage>
#let version = "0.1.0"

You can import this template in 3 ways.
- Copy the files (including `hetvid.typ` and `dingli.typ`) to your working directory, and import it by  
  ```typ
  #import "hetvid.typ": *
  ```
- Copy this repository to your dirctory for local packages, then import it by 
  #raw(
    block: true,
    lang: "typ",
    "#import \"@local/hetvid:"+version+"\": *"
  )
- #text-muted[After we have published this to Typst Universe, you can import it by
  #raw(
    block: true,
    lang: "typ",
    "#import \"@local/hetvid:"+version+"\": *"
  )
]
We recommend the second way.

Specifically, the directory for local packages is `{data-dir}/typst/packages/local/`, where `{data-dir}` is
- Linux: `$XDG_DATA_HOME` or `~/.local/share`;
- MacOS: `~/Library/Application Support`;
- Windows: `%APPDATA%`, where `%APPDATA` is a variable, usually being
  ```
  C:\Users\USERNAME\AppData\Roaming
  ```
  You can check this in cmd by command
  ```shell
  $ echo The value of ^%AppData^% is %AppData%
    The value of %AppData% is C:\Users\USERNAME\AppData\Roaming
  ```
  See https://superuser.com/questions/632891/what-is-appdata.
The user should copy this directory to this directory for local packages.
For example for Windows, there should be such a directory in the end:
#raw(
    block: true,
    "C:\Users\USERNAME\AppData\Roaming\typst\packages\local\hetvid\\"+version+"\\"
  )
Then the user can `#import` this template.

After importing, the user can set basic information by the following code.
Note that default values have been given to variables affecting the format.
If you do not need to change these default values, you do not need to write them when you use this template.
```typ
#show: hetvid.with(
  // Information for the title
  // Metadata
  title: [Title],
  author: "The author",
  affiliation: "The affiliation",
  header: "",
  date-created: datetime.today().display(),
  date-modified: datetime.today().display(),
  abstract: [],
  toc: true,

  // Language
  lang: "en",

  // Information for format, only write the term you need to change
  // Paper size
  paper-size: "a4",

  // Fonts
  body-font: ("New Computer Modern", "Libertinus Serif", "TeX Gyre Termes", "Songti SC", "Source Han Serif SC", "STSong", "Simsun", "serif"),
  raw-font: ("DejaVu Sans Mono", "Cascadia Code", "Menlo", "Consolas", "New Computer Modern Mono", "PingFang SC", "STHeiti", "华文细黑", "Microsoft YaHei", "微软雅黑"),
  heading-font: ("Helvetica", "Tahoma", "Arial", "PingFang SC", "STHeiti", "Microsoft YaHei", "微软雅黑", "sans-serif"),
  math-font: ("New Computer Modern Math", "Libertinus Math", "TeX Gyre Termes Math"),
  emph-font: ("New Computer Modern","Libertinus Serif", "TeX Gyre Termes", "Kaiti SC", "KaiTi_GB2312"),
  body-font-size: 11pt,
  body-font-weight: "regular", // set it to 450 if you want book-weight of NewCM fonts
  raw-font-size: 9pt,
  caption-font-size: 10pt,
  heading-font-weight: "regular",

  // Colors
  link-color: link-color,
  muted-color: muted-color,
  block-bg-color: block-bg-color,

  // indention
  ind: 1.5em,
  justify: true,

  // bibliography style, if lang == "zh", defult to be "gb-7714-2015-numeric"
  bib-style: (
    en: "springer-mathphys",
    zh: "gb-7714-2015-numeric",
  ),

  // Numbering level of theorems
  thm-num-lv: 1,
)
```

= Fonts

== Basic settings

We have defined several types of fonts, with their default values shown in the code in @sec-usage. The default values are font families, which in Typst are implemented as an `array` type variable containing several fonts. For each character, the compiler will display it using the first font in the family that supports that character.

The font types are as follows:

/ Body font (`body-font`): Mainly used for the main text. Its size and weight are determined by `body-font-size` and `body-font-weight`.

/ Monospace font (`raw-font`): Used for plain text content, such as code. The default values are all monospaced fonts. Since the size of monospaced fonts may not match regular fonts of the same size, we provide the `raw-font-size` variable for users to adjust the size of monospace fonts.

/ Heading font (`heading-font`): Used for document titles and section headings. The default value is sans-serif fonts (e.g., Heiti), making the headings distinct from the main text and more modern. Users can also modify it to bold serif fonts. The weight of the headings can be adjusted by setting `heading-font-weight`.

/ Math font (`math-font`): Used for mathematical formulas. See @sec:math-font for details.

/ Emphasis font (`emph-font`): For documents in Chinese language, not relevant here. 

Additionally, we provide the `caption-font-size` parameter to control the font size of captions.


== On math fonts <sec:math-font>

From a self-consistent perspective, we recommend setting the math font and the body font to the same font (its math variant and regular form). For example, in the equations, we often encounter characters with textual meaning displayed in upright form. We do not want these characters to appear in different fonts inside and outside the equation. Similarly, numbers frequently appear in formulas and in the main text, possibly referring to the same objects. Therefore, we also do not want them to appear in different fonts.

The default math font is New Computer Modern Math, which corresponds to the body font New Computer Modern. This is the default font for #LaTeX.

== On weight of New Computer Modern font

The default body font used in the template, New Computer Modern, and the math font, New Computer Modern Math, offer two weight options: the regular weight (400), which is the default in our template, and a slightly heavier book weight (450). If you wish to use the latter, set `body-font-weight` to 450.

The default behavior of the New Computer Modern font in Typst (version 0.13.1) can be slightly inconsistent. For example, if you set the fonts as follows:
```typ
#set text(font: "New Computer Modern")
#show math.equation: set text(font: "New Computer Modern Math") 
```
the body text will use the New Computer Modern font with a default weight of regular (400), while the equations will use the New Computer Modern Math font with a default weight of book (450). As a result, the equations may appear slightly bolder than the body text. Our template avoids this issue by explicitly specifying the weight for both fonts.

= Headings 

= Headings

The font size of first-level headings is #qty[1.4][em]. There is a vertical space of #qty[2][em] (relative to the heading font size, the same below) above the first-level heading and #qty[1.2][em] below it.

== Second-level headings

The font size of second-level headings is 1.2 em. There is a vertical space of #qty[1.5][em] above the second-level heading and #qty[1.2][em] below it.

=== Third-level headings

The font size of third-level headings is 1.1 em. There is a vertical space of #qty[1.5][em] above the third-level heading and #qty[1.2][em] below it.

Although Typst provides functionality for higher-level headings, the template author strongly discourages using headings with too many levels, so no special customization has been made for their behavior. Generally, notes under 100 pages rarely use third-level headings. For example, Kitaev's articles #cite(<kitaevQuantumComputationsAlgorithms1997>)#cite(<kitaevAnyonsExactlySolved2006>)#cite(<kitaevAlmostidempotentQuantumChannels2025>) and Witten's lecture notes #cite(<wittenNotesEntanglementProperties2018>)#cite(<wittenMiniIntroductionInformationTheory2020>)#cite(<wittenIntroductionBlackHole2025>) do not use third-level headings.

= Paragraphs and Indentation<sec:par>

Users can adjust whether to justify text alignment by setting `justify: true | false`, with the default of this template being justified alignment.
Users can adjust the indentation amount using the `ind` parameter. 

In Typst, first-line indentation can be controlled using the `all` option to determine whether all paragraphs are indented. However, its behavior is somewhat complex. In summary:
- The default behavior is `all: false`. In this case, for a paragraph, if the preceding block-level element is also a paragraph, the current paragraph will be indented; otherwise, it will not. Non-paragraph block-level elements include:
  - Empty elements: As a result, the first paragraph of block-level elements (e.g., block quotes, theorems) is not indented, which aligns with English typography conventions.
  - Section headings: The first paragraph of each section is not indented, which aligns with English typography conventions.
  - Displayed equations: No indentation follows displayed equations, which is generally expected. However, if a paragraph ends with a displayed equation, special handling is required.
  - Block quotes: Similar to displayed equations, this is generally expected. However, if a paragraph ends with a block quote, special handling is required (see @sec:quote).
  - Unordered and ordered lists: Similar to displayed equations, this is generally expected when lists appear within a paragraph. However, if a paragraph ends with a list, special handling is required.
  - Figures: Paragraph following a non-floating figure is not indented. This is expected only when the figure is part of the paragraph. Other cases require special handling (see @sec:fig).
  - Other block-level elements, such as theorem environments used in this template.
  Overall, this setting generally aligns with conventions but requires special handling in some cases.
- Setting `all: true` indents all paragraphs. This setting also introduces some issues requiring special handling, such as paragraphs following displayed equations or block quotes. Usually we do not mean to start a new paragraph in these cases, but the contents are always indented. We can avoid this by enclosing for example the equations in a box.

The template author believes that maintaining the simplicity of Typst's native syntax for displayed equations is crucial. Therefore, we adopt the first approach, i.e., not setting all paragraphs to be indented, while applying special handling to paragraphs that require indentation.

The implementation of this special handling is straightforward: a virtual paragraph is added before paragraphs that need indentation but are not indented by default. This makes the compiler treat it as a block-level "paragraph" element, but it does not appear in the compiled output. To achieve this, we provide the `par-vir` function to create such virtual paragraphs. In the template, we have already added virtual paragraphs where adjustments are needed for Chinese documents. In most cases, users do not need to worry about indentation behavior. Only when a user-written paragraph ends with a non-paragraph block-level element (e.g., equations, quotes, lists) and the following content needs to start a new paragraph, the user must insert:
```typ
#par-vir
```
to achieve correct indentation. See the example below.

#example[
  This paragraph ends with an equation,
  $ 1+1=2. $
  #par-vir
  We want to start a new paragraph.

  Without adding a virtual paragraph, we cannot start a new paragraph after the equation, even if we add a blank line.
  $ 1+1=2. $

  We failed to start a new paragraph. Of course, this blank line does not affect the vertical spacing.
]

= Quotes<sec:quote>


The template customizes the behavior of block quotes: they are indented by $2 times "ind"$ on both sides, where "ind" takes the value given to `ind` by the user, or takes the default value #qty[1.5][em]. There is a vertical spacing of #qty[1.5][em] above and below the block quote, and the subsequent content is treated as a continuation of the previous paragraph, with no first-line indentation.
#quote(attribution: [Lorem ipsum], block: true)[
  #lorem(33)

  #lorem(24)
]
As you see here, by default, the template does not create a new paragraph (that is, make an indentation) after a quote. If you need to start a new paragraph and want the subsequent content to have a first-line indentation, you can insert a virtual paragraph.

= Equation 

Displayed equations are numbered by default, such as  
$ cal(F)f (k) = 1/(2 pi "i") integral dif k thin "e"^("i"k x) f(x), $<eq:fourier>  
and can be referenced by their numbers, such as #eqref(<eq:fourier>). When referencing equations, we provide the custom command `@{KEY}` to display only the number, leaving the prefix and parentheses to the user. This is because users may use different prefixes in the same document, such as Equation (1), the integral (1), or the isomorphism (1), and may also reference multiple equations simultaneously, such as properties (1-3). On the other hand, we provide a command `#eqref` for referring equations with abbreviation "Eq." or "Eqs.", depending on the number of keys in the argument. For example, `#eqref(<eq:fourier>)` outputs #eqref(<eq:fourier>), while `#eqref(<eq:fourier>, <eq:trivial>)` outputs #eqref(<eq:fourier>, <eq:trivial>). We do this becase the space after the dot in "Eq." is supposed to be small and non-breaking, which is tedious for the user to type.

Displayed equations have vertical spacing of #qty[1.2][em] above and below, consistent with the default behavior of #LaTeX. Without this spacing, the layout would be too crowded, as shown in the example below.

#example[
  #show math.equation.where(block: true): set block(above: 0.5em, below: 0.5em)
  If the text before and after the equation fills an entire line, and there is no spacing between the equation and the surrounding text, such as  
  $ 1+1=2, $<eq:trivial>
  the visual effect will be very crowded. We want to avoid such an effect, so we add spacing above and below the equation.
]

= Theorems

Since existing theorem packages are unsatisfactory in detail, the author has developed the #link("https://github.com/itpyi/typst-dingli")[dingli package] to implement theorem environments. As the dingli package has not yet been published, for user convenience, we have copied the package into this template, i.e., the `dingli.typ` file. Functions are defined within to implement theorems, definitions, lemmas, corollaries, examples, proofs, etc. Examples in this document have used the provided `#example` function.

Our theorem package customizes the following details:
- Indentation issues, including the indentation of the paragraph following the theorem and the indentation of the theorem itself in Chinese documents.
- Vertical spacing with the surrounding context. This template sets it to #qty[1.5][em].
- Numbering level issues. You can choose not to number by headings, number by first-level headings, or number by higher-level headings. This can be adjusted via `thm-num-lv: 0|1|...`. The template defaults to numbering by first-level headings.

#theorem[This is a theorem. In Chinese environments, the theorem still indents the first line by 2 characters, does not indent as a whole, and is not flush with the left margin.]

This is a paragraph following the theorem, note the vertical spacing.

#theorem([$s$-Theorem])[This is a named theorem. Note the realization of the theorem name and separator.]

#theorem[This is a theorem.
The vertical spacing before and after the theorem is set to weak, so there is no extra spacing.]
#proof[This is a proof.
$ 1 + 1 = 2 $
Does this really need proof?

This is another paragraph in the proof.
]

Other types include lemmas, corollaries, definitions, etc.

#lemma[This is a lemma.]
#corollary[This is a corollary.]
#definition[This is a definition.]<def:example>

You can reference theorems using Typst's general syntax, such as @def:example.

= Figures and tables<sec:fig>

== In-paragraph figures and tables

Sometimes we insert figures or tables directly into the text: they are closely related to the context and do not have much standalone value. Therefore, we want them to be part of the paragraph rather than independent figures with captions. For such figures or tables, we recommend using
```typ
#align(center,image("{SOURCE}")) //figure
#align(center)[#table({...}] //table
```
rather than `#figure` command to insert. 
This is because `#figure` is mainly designed for floating figures, and its default behavior may not match the requirements for in-paragraph figures or tables.

== Standalone figures and tables

We suggest adding captions to all standalone figures and tables.
For such figures, we provide a customized `#figure` function. Compared to Typst's default `figure`, it has the following features:
+ If the caption is short (fits in one line), it is centered; if it is long (spans multiple lines), it is left-aligned. See @fig:short-caption and @fig:long-caption. This is implemented by detecting the number of lines in the caption, following the approach in #link("https://sitandr.github.io/typst-examples-book/book/snippets/layout/multiline_detect.html")[Typst Examples Book: Multipline detection].
+ The caption label (e.g., "Figure 1", "Table 1") is bold.
+ The caption font size is slightly smaller than the body text, controlled by `caption-font-size`.
+ There is vertical space of #qty[2][em] above and below the figure to separate it from the main text.
Features 3 and 4 are intended to avoid mixing of the caption and the body.

#figure(
  canvas({
    let N = 6
    let n = 4
    let space = 1
    let vspace = 2
    let offset = (N - n) / 2
    let r = 0.1
    import draw: *
    for i in range(N) {
      circle((i*space, 0), radius: r, fill: black)
      content((i*space, -r),[#i],anchor: "north", padding: 2pt)
    }
    for i in range(n) {
      rect((i*space + offset - r, vspace - r),(i*space + offset + r, vspace + r), fill: black)
      i = i + 1
    }
    let links = ((1,2,4,5),
                 (0,2,3,5),
                 (0,4),
                 (1,4))
    for j in (0,1,2,3) {
      for i in links.at(j) {
        line((i*space, 0), (j*space + offset, vspace))
      }
    }
    }),
  caption: [Short caption is centered.]
)<fig:short-caption>

#figure(
  canvas({
    let N = 6
    let n = 4
    let space = 1
    let vspace = 2
    let offset = (N - n) / 2
    let r = 0.1
    import draw: *
    for i in range(N) {
      circle((i*space, 0), radius: r, fill: black)
    }
    for i in range(n) {
      rect((i*space + offset - r, vspace - r),(i*space + offset + r, vspace + r), fill: black)
      i = i + 1
    }
    let links = ((1,2,4,5),
                 (0,2,3,5),
                 (0,4),
                 (1,4))
    for j in (0,1,2,3) {
      for i in links.at(j) {
        line((i*space, 0), (j*space + offset, vspace))
      }
    }
    }),
  caption: [If the caption is longer than one line, it is left-aligned. This is a bipartite graph with 4 nodes on the top, 6 nodes on the bottom, and each top node is connected to an even number of bottom nodes.]
)<fig:long-caption>

Contents after a figure becomes a new paragraph with first-line indentation.
Due to the difference of the font size and a vertical separation, the text does not visually blend with a long figure caption.

#figure(
  canvas({
    let N = 6
    let n = 4
    let space = 1
    let vspace = 2
    let offset = (N - n) / 2
    let r = 0.1
    import draw: *
    for i in range(N) {
      circle((i*space, 0), radius: r, fill: black)
    }
    for i in range(n) {
      rect((i*space + offset - r, vspace - r),(i*space + offset + r, vspace + r), fill: black)
      i = i + 1
    }
    let links = ((1,2,4,5),
                 (0,2,3,5),
                 (0,4),
                 (1,4))
    for j in (0,1,2,3) {
      for i in links.at(j) {
        line((i*space, 0), (j*space + offset, vspace))
      }
    }
    }),
  placement: top,
  caption: [This figure is placed at the top of the page. Note that in Typst, the numbering of floating figures depends on their position in the source code, not their position in the generated document.]
)<fig:placement>

One can also place a figure at a fixed position on a page rather than position relative to texts. See @fig:placement. Note that in Typst, the numbering of floating figures depends on their position in the source code, not their position in the generated document. This ensures that figure numbering follows the logical flow of the text, which is reasonable. However, if a document mixes figures placed in-flow and figures floated to the top or bottom of the page, the resulting figure numbers may appear out of order. Our suggestion is to always place figures at the top or bottom of the page for consistency.


== Texts in figures and tables

The font size of texts in tables is the same as `body-font-size`. For figures, since this template is primarily intended for academic notes and assumes users will use the #link("https://typst.app/universe/package/cetz/")[cetz] package for drawing, the recommended font size for text inside figures matches the caption font size. This template customizes the default text size in a figure and therefore in `canvas` from the cetz package to align with `caption-font-size`. See @fig:short-caption for an example.


= Bibliography and citation

The style of bibliography and citations can be set through the `bib-style` parameter, which is a dictionary mapping language codes to bibliography styles. For example, for English documents, the default is `"springer-mathphys"`, and for Chinese documents, it is `"gb-7714-2015-numeric"`. You can customize these styles as needed by modifying the `bib-style` dictionary when calling `hetvid.with`.

Please refer to @BibliographyFunctionTypst for available bibliography styles.

= Designing philosophy and goals

The design philosophy of this template is to provide a lightweight, clear, and aesthetically pleasing environment for writing scientific notes. The main goals are:

- Simplicity: Avoid unnecessary complexity in both appearance and usage. The template adheres to common typesetting conventions and minimizes decorative elements, relying on indentation and spacing to separate content.
- Readability: Prioritize legibility by using appropriate font choices, sizes, and weights. The template ensures that headings, body text, captions, and mathematical content are visually distinct yet harmonious.
- Consistency: Maintain consistent formatting for similar elements (e.g., headings, theorems, figures) throughout the document, reducing cognitive load for both writers and readers.
- Customizability: Allow users to easily adjust key parameters (fonts, colors, spacing, numbering) to suit their needs, while providing sensible defaults for most use cases.
- Academic focus: Support features commonly needed in scientific writing, such as theorem environments, equation numbering, citation management, and figure/table handling.

By following these principles, the template aims to help users focus on content creation without being distracted by formatting issues.

The name hetvid of this template derives from the Latin transcription of Sanskrit word _hetuvidyā_. 
Hetuvidyā is the Sanskrit term for Buddhist logic and debate, introduced to China by the monk Xuanzang.


#bibliography("ref.bib")
