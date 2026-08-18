#import "@preview/scripst:1.1.2": *

#let doc-countblocks = add-countblock(cb, "test", "This is a test", teal)

#show: scripst.with(
  title: [Scripst Documentation],
  info: [Article Style Set],
  author: ("AnZrew", "AnZreww", "AnZrewww"),
  // author: "Anzrew"
  time: datetime.today().display(),
  abstract: [Scripst is a simple and easy-to-use Typst language template, suitable for various scenarios such as daily documents, assignments, notes, papers, etc.],
  keywords: (
    "Scripst",
    "Typst",
    "template",
  ),
  contents: true,
  content-depth: 3,
  matheq-depth: 2,
  counter-depth: 3,
  countblocks: doc-countblocks,
  header: true,
  lang: "en",
  par-indent: 0em,
)

Typst is a simple document generation language with syntax similar to lightweight Markdown markup. Using appropriate `set` and `show` commands, you can highly customise the style of your documents.

Scripst is a simple and easy-to-use Typst language template, suitable for various scenarios such as daily documents, assignments, notes, papers, etc.

= Typesetting Typst Documents with Scripst

== Using Typst

Typst is a lighter language to use compared to LaTeX. Once the template is written, you can complete the document writing with lightweight markup similar to Markdown.

Compared to LaTeX, Typst has the following advantages:
- Extremely fast compilation speed
- Simple and lightweight syntax
- Strong code extensibility
- Easier mathematical formula input
- ...

Therefore, Typst is very suitable for writing lightweight daily documents. You can get even better typesetting results than LaTeX with the time cost of writing Markdown.

You can install Typst in the following ways:

```bash
sudo apt install typst # Debian/Ubuntu
sudo pacman -S typst # Arch Linux
winget install --id Typst.Typst # Windows
brew install typst # macOS
```
#newpara()
You can also find more information in the #link("https://github.com/typst/typst")[Typst GitHub repository].

== Using Scripst

Based on Typst, Scripst provides some simple templates for convenient daily document generation.

=== Online Usage

#link("https://typst.app/universe/package/scripst")[Scripst Package] has already been submitted to the community. If network available, you can directly use

```typst
#import "@preview/scripst:1.1.2": *
```
to import the Scripst templates in your document.

You can also use `typst init` to create a new project with the template:
```bash
typst init @preview/scripst:1.1.2 project_name
```

This method does not require downloading the template files, just import them in the document.

=== Offline Usage

/ Using extracted files:

You can find and download the Scripst templates in the #link("https://github.com/An-314/scripst")[Scripst GitHub repository].

You can choose `<> code` $->$ `Download ZIP` to download the Scripst templates. When using them, just place the template files in your document directory and import the template files at the beginning of your document.

#caution(count: false)[
  Consider the project directory structure to correctly import the template files.
  ```
  project/
  ├── src/
  │   ├── main.typ
  │   ├── ...
  │   └── components.typ
  ├── pic/
  │   ├── ...
  ├── main.typ
  ├── chap1.typ
  ├── chap2.typ
  ├── ...
  ```
  If the project directory structure is as shown above, then the way to import the template files in `main.typ` should be:
  ```typst
  #import "src/main.typ": *
  ```
]

The advantage of this method is that you can adjust some parameters in the template at any time. Since the template is designed modularly, you can easily find and modify the parts you need to change.

/ Local package management:

*A better way is* to refer to the official #link("https://github.com/typst/packages?tab=readme-ov-file#local-packages")[local package management documentation] and place the template files in the local package management directory `{data-dir}/typst/packages/{namespace}/{name}/{version}`, so you can use the Scripst templates anywhere.

Of course, you don't have to worry about not being able to modify the template files. You can directly use `#set, #show` commands in the document to override some parameters in the template.

For example, the template should be placed in
```
~/.local/share/typst/packages/preview/scripst/1.1.2               # in Linux
%APPDATA%\typst\packages\preview\scripst\1.1.2                    # in Windows
~/Library/Application Support/typst/packages/local/scripst/1.1.2  # macOS
```
You can execute the following command:
```bash
cd ~/.local/share/typst/packages/preview/scripst/
git clone https://github.com/An-314/scripst.git 1.1.2
```
If the directory structure is like this, then the way to import the template files in the document should be:
```typst
#import "@preview/scripst:1.1.2": *
```
The advantage of this is that you can directly use `typst init` to create a new project with the template:
```bash
typst init @preview/scripst:1.1.2 project_name
```
#newpara()

#separator

After importing the template, create an `article` file in this way:

```typst
#show: scripst.with(
  title: [How to Use Scripst],
  info: [This is the article template],
  author: ("Author1", "Author2", "Author3"),
  time: datetime.today().display(),
  abstract: [Abstract],
  keywords: ("Keyword1", "Keyword2", "Keyword3"),
  contents: true,
  content-depth: 3,
  matheq-depth: 2,
  lang: "en",
)
```

See @para for the meaning of these parameters.

Then you can start writing your document.

= Template Parameter Description <para>

Scripst template provides some parameters to customise the style of the document.

```typst
#let scripst(
  template: "article",  // str: ("article", "book", "report")
  title: "",            // str, content, none
  info: "",             // str, content, none
  author: (),           // array
  time: "",             // str, content, none
  abstract: none,       // str, content, none
  keywords: (),         // array
  font-size: 11pt,      // length
  contents: false,      // bool
  content-depth: 2,     // int
  matheq-depth: 2,      // int: (1, 2, 3)
  counter-depth: 3,     // int: (1, 2, 3)
  cb-counter-depth: 2,  // int: (1, 2, 3)
  countblocks: cb,      // dict
  matheq-outline: "(1.1)", // str, function
  counter-outline: "1.1", // str, function
  link-color: blue,     // color
  ref-color: red,       // color
  header: true,         // bool
  lang: "en",           // str: ("zh", "en", "fr", ...)
  par-indent: 0em,      // length
  par-leading: none,    // length
  par-spacing: none,    // length
  body,
) = {
  ...
}
```

#newpara()

== template

#figure(
  three-line-table[
    | Parameter | Type | Optional Values | Default Value | Description |
    | --- | --- | --- | --- | --- |
    | template | `str` | `("article", "book", "report")` | `"article"` | Template type |
  ],
  numbering: none,
)

#newpara()

Currently, Scripst provides three templates: article, book, and report.

This template uses the article template.

- article: Suitable for daily documents, assignments, tiny notes, light papers, etc.
- book: Suitable for books, course notes, etc.
- report: Suitable for lab reports, papers, etc.

Passing other strings will cause a `panic`: `"Unknown template!"`.

== title

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | title | `content`, `str`, `none`| `""` | Document title |
  ],
  numbering: none,
)

#newpara()

The title of the document. (If not empty) it will appear at the beginning and in the header of the document.

== info

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | info | `content`, `str`, `none`| `""` | Document information |
  ],
  numbering: none,
)

#newpara()

The information of the document. (If not empty) it will appear at the beginning and in the header of the document. It can be used as a subtitle or supplementary information for the article.

== author

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | author | `str`, `content`, `array`, `none`| `()` | Document authors |
  ],
  numbering: none,
)

#newpara()

The authors of the document. Pass a list of `str` or `content`. Or, simply pass a `str` or `content` object.

#note(count: false)[
  Note, if there is only one author, you can simply pass a `str` or `content`, and for multiple authors, a list of one `str` or `content`, for example: `author: ("Author I", "Author II")`
]


It will be displayed at the beginning of the article with $min(\#"authors", 3)$ authors in a line.

== time

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | time | `content`, `str`, `none`| `""` | Document time |
  ],
  numbering: none,
)

#newpara()

The time of the document. It will appear at the beginning and in the header of the document.

You can choose to use Typst's `datetime` to get or format the time, such as today's date:

```typst
datetime.today().display()
```
#newpara()

== abstract

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | abstract | `content`, `str`, `none`| `none` | Document abstract |
  ],
  numbering: none,
)

#newpara()

The abstract of the document. (If not empty) it will appear at the beginning of the document.

It is recommended to define a `content` before using the abstract, for example:

```typst
#let abstract = [
  This is a simple document template used to generate simple daily documents to meet the needs of documents, assignments, notes, papers, etc.
]

#show: scripst.with(
  ...
  abstract: abstract,
  ...
)
```
Then pass it to the `abstract` parameter.

== keywords

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | keywords | `array`| `()` | Document keywords |
  ],
  numbering: none,
)

#newpara()

The keywords of the document. Pass a list of `str` or `content`.

Like `author`, the parameter is a list, not a string.

Keywords will only appear at the beginning of the document if `abstract` is not empty.

== font-size

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | font-size | `length`| `11pt` | Document font size |
  ],
  numbering: none,
)

#newpara()

The font size of the document. The default is `11pt`.

Refer to the `length` type values, you can pass `pt`, `mm`, `cm`, `in`, `em`, etc.

== contents

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | contents | `bool`| `false` | Whether to generate a table of contents |
  ],
  numbering: none,
)

#newpara()

Whether to generate a table of contents. The default is `false`.

== content-depth

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | content-depth | `int`| `2` | Depth of the table of contents |
  ],
  numbering: none,
)

#newpara()

The depth of the table of contents. The default is `2`.

== matheq-depth

#figure(
  three-line-table[
    | Parameter | Type | Optional Values | Default Value | Description |
    | --- | --- | --- | --- | --- |
    | matheq-depth | `int`| `1`, `2`, `3` | `2` | Depth of math equation numbering |
  ],
  numbering: none,
)

#newpara()

The depth of math equation numbering. The default is `2`.

#note(count: false)[ For detailed behavior of counters, see @counter. ]

#newpara()

== counter-depth <counter>

#figure(
  three-line-table[
    | Parameter | Type | Optional Values | Default | Description |
    | --- | --- | --- | --- | --- |
    | counter-depth | `int` | `1`, `2`, `3` | `2` | Counter depth |
  ],
  numbering: none,
)

#newpara()

The counter depth for images (`image`), tables (`table`), and code blocks (`raw`) within `figure` environments. Default is `2`.

#note(count: false, subname: [Counter Details])[

  When a counter has depth `1`, its numbering will be global and unaffected by chapters/sections, i.e., `1`, `2`, `3`, ...

  When a counter has depth `2`, its numbering will follow level-1 headings, i.e., `1.1`, `1.2`, `2.1`, `2.2`, ... However, if the document contains no level-1 headings, Scripst will automatically treat it as depth `1`.

  When a counter has depth `3`, its numbering will follow level-1 and level-2 headings, i.e., `1.1.1`, `1.1.2`, `1.2.1`, `1.2.2`, `2.1.1`, ... However:
  - If the document has level-1 headings but no level-2 headings, Scripst will treat it as depth `2`.
  - If the document has no level-1 headings, Scripst will treat it as depth `1`.
]

#newpara()

== cb-counter-depth

#figure(
  three-line-table[
    | Parameter | Type | Optional Values | Default | Description |
    | --- | --- | --- | --- | --- |
    | cb-counter-depth | `int` | `1`, `2`, `3` | `2` | Counter depth for `countblock` |
  ],
  numbering: none,
)

#newpara()

The default numbering depth for entries passed through `countblocks`. Per-counter depths configured with `set-countblock-depth` or `add-countblock(depth: ...)` take precedence. See @cb-counter for details.

== countblocks

The countblock registry used by the template. It defaults to `cb`. Pass an updated registry here before using custom countblocks so Ratchet can configure their numbering and references.

== matheq-outline

The equation numbering pattern. It defaults to `"(1.1)"`, so displayed equations and their references include parentheses.

== link-color

The text color of hyperlinks. It defaults to `blue`. Equation, figure, and countblock reference colors remain controlled by `matheq-color` and `counter-color`.

PDF link borders and hover feedback are controlled by the PDF viewer. Typst currently cannot reliably customize their appearance.

== ref-color

The text color of ordinary `@label` references. It defaults to `red`. Equation references remain controlled by `matheq-color`; figure and countblock references remain controlled by `counter-color`.

== header

#figure(
  three-line-table[
    | Parameter | Type | Default | Description |
    | --- | --- | --- | --- |
    | header | `bool` | `true` | Enable header |
  ],
  numbering: none,
)

#newpara()

Whether to generate headers. Default is `true`.

#note(count: false)[

  The header displays the document title, metadata, and current chapter/section title:
  - If all three exist, they will be displayed in the header in three equal parts.
  - If the document has no metadata, the header will show the title on the left and chapter title on the right.
    - If the document also lacks a title, only the chapter title will appear on the right.
  - If the document has no level-1 headings, the header will show the title on the left and metadata on the right.
    - If there's no metadata, only the title will appear on the left.
  - If none of these elements exist, the header will remain empty.
]

#newpara()

== lang

#figure(
  three-line-table[
    | Parameter | Type | Default Value | Description |
    | --- | --- | --- | --- |
    | lang | `str`| `"zh"` | Document language |
  ],
  numbering: none,
)

#newpara()

The document language. The default is `"zh"`.

Accepts #link("https://en.wikipedia.org/wiki/ISO_639-1")[ISO_639-1] encoding format, such as `"zh"`, `"en"`, `"fr"`, etc.


== par-indent

#figure(
  three-line-table[
    | Parameter | Type | Default | Description |
    | --- | --- | --- | --- |
    | par-indent | `length` | `2em` | First-line paragraph indentation |
  ],
  numbering: none,
)

#newpara()

Controls first-line paragraph indentation. Default: `2em`. Set to `0em` to disable indentation.

== par-leading

#figure(
  three-line-table[
    | Parameter | Type | Default | Description |
    | --- | --- | --- | --- |
    | par-leading | `length` | Language-dependent | Line spacing within paragraphs |
  ],
  numbering: none,
)

#newpara()

Adjusts line spacing within paragraphs. Defaults to `1em` for Chinese documents.

#note(count: false)[
  Default values changes according to language script type, with details shown below:
  #set align(center)
  #three-line-table[
    | Script Category | Default |
    | --- | --- |
    | East Asian (Chinese/Japanese/Korean) | 1em |
    | South/Southeast Asian/Amharic (Thai/Hindi/etc.) | 0.85em |
    | Arabic Scripts (Arabic/Persian/etc.) | 0.75em |
    | Cyrillic Scripts (Russian/Bulgarian/etc.) | 0.7em |
    | Other Languages | 0.6em |
  ],
]

== par-spacing

#figure(
  three-line-table[
    | Parameter | Type | Default | Description |
    | --- | --- | --- | --- |
    | par-spacing | `length` | Language-dependent | Vertical spacing between paragraphs |
  ],
  numbering: none,
)

#newpara()

Sets vertical spacing between paragraphs. Defaults to `1.2em` for Chinese documents.

#note(count: false)[
  Default values changes according to language script type, with details shown below:
  #set align(center)
  #three-line-table[
    | Script Category | Default |
    | --- | --- |
    | East Asian (Chinese/Japanese/Korean) | 1.2em |
    | South/Southeast Asian/Amharic (Thai/Hindi/etc.) | 1.3em |
    | Arabic Scripts (Arabic/Persian/etc.) | 1.25em |
    | Cyrillic Scripts (Russian/Bulgarian/etc.) | 1.2em |
    | Other Languages | 1em |
  ],
]

== body

When using `#show: scripst.with(...)`, the `body` parameter does not need to be passed manually. Typst will automatically pass the remaining document content to the `body` parameter.

= Template Effect Display

== Front Page

The beginning of the document will display the title, information, authors, time, abstract, keywords, etc., as shown at the beginning of this document.

== Table of Contents

If the `contents` parameter is `true`, a table of contents will be generated, as shown in this document.

== Fonts and Environments

Scripst provides some commonly used fonts and environments, such as bold, italic, headings, images, tables, lists, quotes, links, math formulas, etc.

=== Fonts

This is normal text. C'est un texte normal.

*This is bold text.* *C'est un texte en gras.*

_This is italic text._ _C'est un texte en italique._

Install the CMU Serif font for better (LaTeX-like) display effects.

=== Environments

==== Headings

Level 1 headings are numbered according to the document language, including Chinese/Roman numerals/Greek letters/Kana/Numerals in Arabic/Hindi numerals, etc. Other levels use Arabic numerals.

==== Images

The image environment will automatically number the images, as shown below:

#figure(
  image("pic/pic.jpg", width: 60%),
  caption: "Little Scara",
)

==== Tables

Thanks to the `tablem` package, you can write tables in Markdown style when using this template, as shown below:

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  #figure(
    three-line-table[
      | Name | Age | Gender |
      | --- | --- | --- |
      | Jane | 18 | Male |
      | Doe | 19 | Female |
    ],
    caption: [`three-line-table` table example],
  )
  ```
][
  #figure(
    three-line-table[
      | Name | Age | Gender |
      | --- | --- | --- |
      | Jane | 18 | Male |
      | Doe | 19 | Female |
    ],
    caption: [`three-line-table` table example],
  )
]

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  #figure(
    tablem[
      | Name | Age | Gender |
      | --- | --- | --- |
      | Jane | 18 | Male |
      | Doe | 19 | Female |
    ],
    caption: [`tablem` table example],
  )
  ```
][
  #figure(
    tablem[
      | Name | Age | Gender |
      | --- | --- | --- |
      | Jane | 18 | Male |
      | Doe | 19 | Female |
    ],
    caption: [`tablem` table example],
  )
]

You can choose `numbering: none,` to make the table unnumbered, as shown above, the tables in the previous chapters did not enter the full text table counter.

==== Math Formulas

Math formulas have inline and block modes.

Inline formula: $a^2 + b^2 = c^2$.

Block formula:
$
  a^2 + b^2 = c^2 \
  1 / 2 + 1 / 3 = 5 / 6
$
are numbered.

Thanks to the `physica` package, Typst's math input method is greatly expanded while still retaining its simplicity:
$
  &div vb(E) &=& rho / epsilon_0 \
  &div vb(B) &=& 0 \
  &curl vb(E) &=& -pdv(vb(B),t) \
  &curl vb(B) &=& mu_0 (vb(J) + epsilon_0 pdv(vb(E),t))
$

#newpara()

=== Lists

Typst provides a simple environment for lists, as shown:

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  - First item
  - Second item
  - Third item
  ```
][
  - First item
  - Second item
  - Third item
]

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  +  First item
  3. Second item
  +  Third item
  ```
][
  + First item
  3. Second item
  + Third item
]

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  / First item: 1
  / Second item: 2
  / Third item: 23
  ```
][
  / First item: 1
  / Second item: 2
  / Third item: 3
]

#newpara()

=== Quotes

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  #quote(attribution: "Einstein", block: true)[
    God does not play dice with the universe.
  ]
  ```
][
  #quote(attribution: "Einstein", block: true)[
    God does not play dice with the universe.
  ]
]

#newpara()

=== Links

#grid(columns: (1fr, 1fr), align: (horizon, horizon + center))[
  ```typst
  #link("https://www.google.com/")[Google]
  ```
][
  \
  #link("https://www.google.com/")[Google]
]

#newpara()

=== Hyperlinks and Citations

Use `<label>` and `@label` to achieve hyperlinks and citations.

== `#newpara()` Function

By default, some modules do not automatically wrap. This is necessary, for example, if the explanation of the above math formula does not wrap.

But sometimes we need to wrap, and this is where the `#newpara()` function comes in.

Unlike the official `#parbreak()` function, the `#newpara()` function inserts a blank line between paragraphs, so it will start a new natural paragraph in any scenario.

Whenever you feel the need to wrap, you can use the `#newpara()` function.

== labelset

Thanks to the `label` function in Typst, in addition to adding labels to this type, you can conveniently set styles for referenced objects using `label`.

Therefore, Scripst provides some commonly used settings, and you can set styles by simply adding a label.

```typst
== Schrödinger equation <hd.x>
The Schrödinger equation is as follows:
$
  i hbar dv(,t) ket(Psi(t)) = hat(H) ket(Psi(t))
$ <text.blue>
where
$
  ket(Psi(t)) = sum_n c_n ket(phi_n)
$ <eq.c>
is the wave function. From this, we can derive the time-independent Schrödinger equation:
$
  hat(H) ket(Psi(t)) = E ket(Psi(t))
$
<text.teal>
where $E$<text.red> is #[energy]<text.lime>.
```

#newpara()

== Schrödinger equation <hd.x>

The Schrödinger equation is as follows:
$
  i hbar dv(,t) ket(Psi(t)) = hat(H) ket(Psi(t))
$ <text.blue>
where
$
  ket(Psi(t)) = sum_n c_n ket(phi_n)
$ <eq.c>
is the wave function. From this, we can derive the time-independent Schrödinger equation:
$
  hat(H) ket(Psi(t)) = E ket(Psi(t))
$
<text.teal>
where $E$<text.red> is #[energy]<text.lime>.

Currently, Scripst provides the following settings:
#figure(
  three-line-table[
    | Label | Function |
    | --- | --- |
    | `eq.c` | Removes numbering from equations in math environments |
    | `hd.c` | Removes numbering from headings but still displays them in the table of contents |
    | `hd.x` | Removes numbering from headings and hides them in the table of contents |
    | `text.{color}` | Sets the text color \ `color in (black, gray, silver, white, navy, blue, aqua, teal, eastern, purple, fuchsia, maroon, red, orange, yellow, olive, green, lime,)` |
  ],
  caption: [Label Set],
)

#caution(count: false)[
  Note that the strings above have been used for styling settings. You can override their styles, but do not use these strings when working with labels and references.
]

#newpara()

== Unified numbering powered by Ratchet <ratchet>

Scripst 1.1.2 uses #link("https://github.com/An-314/ratchet")[Ratchet 0.0.3] as its unified numbering engine. Ratchet manages numbering, heading-level resets, and cross-references for equations, figures, tables, raw blocks, and custom `figure(kind: ...)` families. Every Scripst countblock is built on the same mechanism.

This integration keeps displayed numbers, references, and outline entries on one configuration. Each counter family can independently use depth `1`, `2`, or `3`, and new countblocks no longer require handwritten registration or heading-reset rules.

#note(count: false)[
  Scripst configures Ratchet automatically, so no additional import is needed. Ratchet can also be used as a standalone package in other projects; see its #link("https://typst.app/universe/package/ratchet")[Universe page].
]

#newpara()

== countblock

#definition(subname: [countblock])[

  Countblock is a counter module provided by Scripst for numbering countable elements in documents.

  What you're seeing now is a `definition` block, which serves as an example of a counter module.
]

#newpara()

=== Default Countblocks

Scripst provides the following countblocks. Depth `2` means numbering follows level-1 headings; every entry initially inherits `cb-counter-depth: 2`.

#pagebreak()

#figure(
  three-line-table[
    | Block | `cb` name | `counter-name` | Default depth | Color | Function |
    | --- | --- | --- | --- | --- | --- |
    | Definition | `def` | `def` | `2` | `mycolor.green` | `#definition` |
    | Theorem | `thm` | `thm` | `2` | `mycolor.blue` | `#theorem` |
    | Proposition | `prop` | `prop` | `2` | `mycolor.violet` | `#proposition` |
    | Lemma | `lem` | `prop` | `2` | `mycolor.violet-light` | `#lemma` |
    | Corollary | `cor` | `prop` | `2` | `mycolor.violet-dark` | `#corollary` |
    | Remark | `rmk` | `prop` | `2` | `mycolor.violet-darker` | `#remark` |
    | Claim | `clm` | `prop` | `2` | `mycolor.violet-deep` | `#claim` |
    | Exercise | `ex` | `ex` | `2` | `mycolor.purple` | `#exercise` |
    | Problem | `prob` | `prob` | `2` | `mycolor.orange` | `#problem` |
    | Example | `eg` | `eg` | `2` | `mycolor.cyan` | `#example` |
    | Note | `note` | `note` | `2` (unnumbered by default) | `mycolor.grey` | `#note` |
    | Caution | `cau` | `cau` | `2` (unnumbered by default) | `mycolor.red` | `#caution` |
  ],
  caption: [Default Scripst countblock configuration],
  numbering: none,
)

`proposition`, `lemma`, `corollary`, `remark`, and `claim` use the same `counter-name`, `"prop"`. They therefore share one number sequence and reset depth, while retaining separate titles and colors.

These functions share identical parameters and effects, differing only in counter names.
```typst
#definition(
  subname: [],
  count: true,
  lab: none,
)[
  ...
]
```
Parameter specifications:
#three-line-table[
  | Parameter | Type | Default | Description |
  | --- | --- | --- | --- |
  | `subname` | `array` | `[]` | Entry name |
  | `count` | `bool` | `true` | Enable numbering |
  | `lab` | `str` | `none` | Entry label |
]
Example usage:
```typst
#theorem(subname: [_Fermat's Last Theorem_], lab: "fermat")[

  No three $a, b, c in NN^+$ can satisfy the equation
  $
    a^n + b^n = c^n
  $
  for any integer value of $n$ greater than 2.
]
#proof[Cuius rei demonstrationem mirabilem sane detexi. Hanc marginis exiguitas non caperet.]
```
This creates a numbered theorem block:
#theorem(subname: [_Fermat's Last Theorem_], lab: "fermat")[

  No three $a, b, c in NN^+$ can satisfy the equation
  $
    a^n + b^n = c^n
  $
  for any integer value of $n$ greater than 2.
]
#proof[Cuius rei demonstrationem mirabilem sane detexi. Hanc marginis exiguitas non caperet.]

==== `subname` Parameter

`subname` displays supplemental information after the counter, such as theorem names. In the example above, it shows "Fermat's Last Theorem".

==== `lab` Parameter

Use the `lab` parameter to create cross-references. For instance, reference the `fermat` theorem using `@fermat`:
```typst
Fermat never publicly proved @fermat.
```
Fermat never publicly proved @fermat.

Note that `proposition`, `lemma`, `corollary`, `remark`, and `claim` share the same counter:
#lemma[

  This is a lemma. Please prove it.
]

#proposition[

  This is a proposition. Please prove it.
]

#corollary[

  This is a corollary. Please prove it.
]

#remark[

  This is a remark. Please note it.
]

#claim[

  This is a claim. Please prove it.
]

Other counters operate independently.

==== `count` Parameter

Set `count: false` to disable numbering. `note` and `caution` default to `count: false`.
```typst
#note(count: true)[

  This is a numbered note.
]

#note[

  This is an unnumbered note.
]
```

#note(count: true)[

  This is a numbered note.
]

#note[

  This is an unnumbered note.
]

#newpara()

=== Changing the depth of all countblocks <cb-counter>

`cb-counter-depth` is the global default and accepts `1`, `2`, or `3`:

- `1`: continuous document-wide numbering;
- `2`: reset at level-1 headings;
- `3`: reset at level-1 and level-2 headings.

```typst
#show: scripst.with(
  countblocks: cb,
  cb-counter-depth: 3,
)
```

This changes every countblock that has no explicit depth. Per-counter overrides in `countblocks` take precedence.

=== Changing an individual countblock depth

Use `set-countblock-depth` to override one counter family:

```typst
#let blocks = set-countblock-depth(cb, "thm", 3)

#show: scripst.with(
  countblocks: blocks,
  cb-counter-depth: 2,
)
```

Only the theorem counter uses depth `3`; other independent counters inherit depth `2`.

```typst
#set-countblock-depth(cb, name, depth, detach: false)
```

#three-line-table[
  | Parameter | Type | Default | Description |
  | --- | --- | --- | --- |
  | `cb` | `dict` |  | Original registry |
  | `name` | `str` |  | `cb` entry to configure |
  | `depth` | `int` |  | New depth: `1`, `2`, or `3` |
  | `detach` | `bool` | `false` | Detach this block from a shared counter |
]

==== Shared counter families

Because `proposition`, `lemma`, `corollary`, `remark`, and `claim` all use `counter-name: "prop"`, the following changes the entire shared family:

```typst
#let blocks = set-countblock-depth(cb, "lem", 3)
```

Blocks sharing one counter must reset together and therefore cannot use different depths.

==== Detaching one block

To make only `lemma` use global depth `1` while the remaining `prop` family stays at depth `2`:

```typst
#let blocks = set-countblock-depth(cb, "lem", 1, detach: true)
#let lemma = countblock.with("lem", blocks)

#show: scripst.with(
  countblocks: blocks,
  cb-counter-depth: 2,
)
```

`detach: true` changes the lemma counter from `"prop"` to `"lem"`. Rewrap the function with the updated registry whenever its counter identity changes. A depth-only change to an already independent block such as `theorem` does not require rewrapping.

=== Adding a new countblock <new-cb>

Use `add-countblock`, then pass the updated registry through `countblocks`:

```typst
#let blocks = add-countblock(
  cb,
  "alg",
  "Algorithm",
  yellow,
  depth: 3,
)
#let algorithm = countblock.with("alg", blocks)

#show: scripst.with(
  countblocks: blocks,
  cb-counter-depth: 2,
)
```

`algorithm` now has an independent depth-3 counter while existing blocks retain the global depth.

```typst
#add-countblock(cb, name, info, color, counter-name: none, depth: none)
```

#three-line-table[
  | Parameter | Type | Default | Description |
  | --- | --- | --- | --- |
  | `cb` | `dict` |  | Original registry |
  | `name` | `str` |  | New registry key |
  | `info` | `str` or `content` |  | Displayed block title |
  | `color` | `color` |  | Background and left-border color |
  | `counter-name` | `str` | `none` | Actual counter kind; defaults to `name` |
  | `depth` | `int` or `none` | `none` | Explicit depth; `none` inherits `cb-counter-depth` |
]

A new block can share an existing sequence by using the same `counter-name`:

```typst
#let blocks = add-countblock(
  cb,
  "asm",
  "Assumption",
  aqua,
  counter-name: "thm",
)
#let assumption = countblock.with("asm", blocks)
```

All entries sharing a `counter-name` must resolve to the same depth. Scripst reports an error for conflicting configurations.

=== The `cb` registry structure <cb>

Each entry is `(info, color, counter-name, depth)`. The fourth field may be omitted or set to `none` to inherit `cb-counter-depth`:

```typst
#let cb = (
  "def": ("Definition", mycolor.green, "def", none),
  "thm": ("Theorem", mycolor.blue, "thm", none),
  "prop": ("Proposition", mycolor.violet, "prop", none),
  "lem": ("Lemma", mycolor.violet-light, "prop", none),
  // ...
  "cb-counter-depth": 2,
)
```

#let blocks = add-countblock(cb, "test", "This is a test", teal)
#let test = countblock.with("test", blocks)

#newpara()

=== Using countblock

After defining a block, use the `countblock` function to create it:
```typst
#countblock(
  name,
  cb,
  subname: "",
  count: true,
  lab: none
)[
  ...
]
```
Parameter specifications:
#three-line-table[
  | Parameter | Type | Default | Description |
  | --- | --- | --- | --- |
  | `name` | `str` | `` | Counter name |
  | `cb` | `dict` | `` | Counter dictionary |
  | `subname` | `str` | `` | Entry name |
  | `count` | `bool` | `true` | Enable numbering |
  | `lab` | `str` | `none` | Reference label |
]
- `name`: Counter name, as specified in `add-countblock`.
- `cb`: Dictionary formatted as @cb. Ensure it contains the latest counter by updating `cb` first.
- `subname`: Supplemental text displayed after the counter (e.g., theorem name).
- `count`: Set `false` to disable numbering.
- `lab`: Label for cross-referencing with `@lab`.

Example using the `test` counter created in @new-cb:
```typst
#countblock("test", blocks)[
  1 + 1 = 2
]
```
#test[
  1 + 1 = 2
]

Alternatively, create a wrapper function:
```typst
#let test = countblock.with("test", blocks)
#test[
  1 + 1 = 2
]
```
#test[
  1 + 1 = 2
]

#newpara()

=== Summary

Use `add-countblock` to extend the registry, pass the entire registry to the template with `countblocks`, and use `countblock` to create individual blocks. Ratchet manages numbering, resets, and references.

#example(count: false)[
  Combined example: default blocks use depth `3`, `remark` is detached from the `prop` family with depth `1`, and a new `algorithm` uses depth `2`.

  ```typst
  #let blocks = set-countblock-depth(cb, "rmk", 1, detach: true)
  #let blocks = add-countblock(blocks, "alg", "Algorithm", yellow, depth: 2)
  #let remark = countblock.with("rmk", blocks)
  #let algorithm = countblock.with("alg", blocks)

  #show: scripst.with(
    // ...
    countblocks: blocks,
    cb-counter-depth: 3,
  )
  ```
  Put the registry and wrapper definitions before `#show: scripst.with(...)`.
]

#newpara()

== Some Other Blocks

=== Blank Block

#blankblock[

  Additionally, Scripst provides this type of block without a title, and you can use it by customizing the color.

  For example:

  ```typst
  #blankblock(color: color.red)[
    This is a red block.
  ]
  ```
  #blankblock(color: color.red)[
    This is a red block.
  ]
]

=== Proof and $qed$ (Quod Erat Demonstrandum)

```typst
#proof[
  This is a proof.
]
```

#proof[

  This is a proof.
]

This provides a simple proof environment along with a tombstone symbol.

=== Solution

```typst
#solution[
  This is a solution.
]
```

#solution[

  This is a solution.
]

This provides a simple solution environment.

=== Separator

```typst
#separator
```

You can use the `#separator` function to insert a separator.

#separator

#newpara()

= Conclusion

The above documentation demonstrated Scripst, explained the template parameters, and showed the template effects.

I hope this document helps you better use Typst and Scripst.

You are also welcome to provide suggestions, improvements, and/or contribute code to Scripst.

Thank you for your support of Typst and Scripst!
