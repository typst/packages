#import "@preview/scripst:1.1.1": *

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
#import "@preview/scripst:1.1.1": *
```
to import the Scripst templates in your document.

You can also use `typst init` to create a new project with the template:
```bash
typst init @preview/scripst:1.1.1 project_name
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
~/.local/share/typst/packages/preview/scripst/1.1.1               # in Linux
%APPDATA%\typst\packages\preview\scripst\1.1.1                    # in Windows
~/Library/Application Support/typst/packages/local/scripst/1.1.1  # macOS
```
You can execute the following command:
```bash
cd ~/.local/share/typst/packages/preview/scripst/
git clone https://github.com/An-314/scripst.git 1.1.1
```
If the directory structure is like this, then the way to import the template files in the document should be:
```typst
#import "@preview/scripst:1.1.1": *
```
The advantage of this is that you can directly use `typst init` to create a new project with the template:
```bash
typst init @preview/scripst:1.1.1 project_name
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

The counter depth for countable elements. Default is `2`.

If you change the default depth of the `countblock` counter, you will also need to specify the changed depth when using it, or rewrap the function. See @cb-counter for details.

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

== countblock

#definition(subname: [countblock])[

  Countblock is a counter module provided by Scripst for numbering countable elements in documents.

  What you're seeing now is a `definition` block, which serves as an example of a counter module.
]

#newpara()

=== Default Countblocks

Scripst provides several default counters ready for use:

- Definition: `#definition`
- Theorem: `#theorem`
- Proposition: `#proposition`
- Lemma: `#lemma`
- Corollary: `#corollary`
- Remark: `#remark`
- Claim: `#claim`
- Exercise: `#exercise`
- Problem: `#problem`
- Example: `#example`
- Note: `#note`
- Caution: `#caution`

These functions share identical parameters and effects, differing only in counter names.
```typst
#definition(
  subname: [],
  count: true,
  lab: none,
  cb-counter-depth: 2,
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
  | `cb-counter-depth` | `int` | `2` | Counter depth |
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

==== `cb-counter-depth` Parameter

Detailed explanation in @cb-counter.

=== Global `cb` Variable <cb>

Scripst tracks all counters through the global `cb` variable, which includes default counter depth `cb-counter-depth`.

Default `cb` structure:
```typst
#let cb = (
  "def": ("Definition", mycolor.green, "def"),
  "thm": ("Theorem", mycolor.blue, "thm"),
  "prop": ("Proposition", mycolor.violet, "prop"),
  "lem": ("Lemma", mycolor.violet-light, "prop"),
  "cor": ("Corollary", mycolor.violet-dark, "prop"),
  "rmk": ("Remark", mycolor.violet-darker, "prop"),
  "clm": ("Claim", mycolor.violet-deep, "prop"),
  "ex": ("Exercise", mycolor.purple, "ex"),
  "prob": ("Problem", mycolor.orange, "prob"),
  "eg": ("Example", mycolor.cyan, "eg"),
  "note": ("Note", mycolor.grey, "note"),
  "cau": ("⚠️", mycolor.red, "cau"),
  "cb-counter-depth": 2,
)
```

#newpara()

=== Creating & Registering Countblocks <new-cb>

Use `add-countblock` to create counters and `reg-countblock` to register them. Add this at document start:
```typst
#let cb = add-countblock(cb, "test", "This is a test", teal)
#show: reg-countblock.with("test")
```
#note[
  This code first updates `cb`, then registers the counter.
]

#let cb = add-countblock(cb, "test", "This is a test", teal)
#show: reg-countblock.with("test")

#newpara()

==== `add-countblock` Function

Parameters for `add-countblock`:
```typst
#add-countblock(cb, name, info, color, counter-name: none) {return cb}
```
#three-line-table[
  | Parameter | Type | Default | Description |
  | --- | --- | --- | --- |
  | `cb` | `dict` | `` | Counter dictionary |
  | `name` | `str` | `` | Counter name |
  | `info` | `str` | `` | Display text |
  | `color` | `color` | `` | Header color |
  | `counter-name` | `str` | `none` | Counter ID |
]

- `cb` is a dictionary with the format shown in @cb. The function's purpose is to update `cb`, which requires explicit assignment during use.
  #note(count: false)[
    Since Typst's functions lack pointers or references, passed variables cannot be directly modified. We can only modify variables by explicitly returning values and passing them to subsequent functions. The author has not yet found a better approach.
  ]
- `name: (info, color, counter-name)` represents a counter's basic information. During rendering, the counter's top-left corner will display `info counter(counter-name)` (e.g., `Theorem 1.1`) as its identifier, with the color set to `color`.
- `counter-name` is the counter's identifier. If unspecified, it defaults to using `name` as the identifier.

==== `reg-countblock` Function

The parameters of the `reg-countblock` function are as follows:
```typst
#show reg-countblock.with(name, cb-counter-depth: 2)
```
Parameter specifications:
#three-line-table[
  | Parameter | Type | Default | Description |
  | --- | --- | --- | --- |
  | `counter-name` | `str` | `` | Counter identifier |
  | `cb-counter-depth` | `int` | `2` | Counter depth |
]
- `counter-name` is the counter identifier, explicitly specified in `add-countblock` (uses `name` if unspecified). For example, the default `clm` counter uses `prop`.
- `cb-counter-depth` defines the counter depth, which can be `1`, `2`, or `3`.

#separator

After this, you can use the `countblock` function to implement the counter.

=== Counter Depth for countblock <cb-counter>

This section details the `cb-counter-depth` parameter and its implementation, not previously mentioned.

The global variable `cb` has a default `cb-counter-depth` value of 2. Thus, default countblocks use depth 2.

#note[
  Directly modifying `cb-counter-depth` in the global variable will NOT affect existing counters. This is because counter creation uses the original `cb.at("cb-counter-depth")` as the default value. Updating `cb` does not retroactively change this value. You must re-register counters.
]

Counter logic aligns with @counter.

*To register a depth-3 counter:*
```typst
#let cb = add-countblock(cb, "test1", "This is a test1", green)
#show: reg-countblock.with("test1", cb-counter-depth: 3)
```
#let cb = add-countblock(cb, "test1", "This is a test1", green)
#show: reg-countblock.with("test1", cb-counter-depth: 3)

#newpara()

Use `reg-default-countblock` to set default counters. For example, to *set all default counters to depth 3*:
```typst
#show: reg-default-countblock.with(cb-counter-depth: 3)
```
#show: reg-default-countblock.with(cb-counter-depth: 3)
However, this alone is insufficient because the pre-packaged counters still default to depth 2. If you directly call:
```typst
#definition[
  This is a definition. Please understand it.
]
```
the counter depth remains 2:
#definition[
  This is a definition. Please understand it.
]
Explicitly specify depth 3:
```typst
#definition(cb-counter-depth: 3)[
  This is a definition. Please understand it.
]
```
#definition(cb-counter-depth: 3)[
  This is a definition. Please understand it.
]
Alternatively, *create a custom wrapper*:
```typst
#let definition = definition.with(cb-counter-depth: 3)
```
#let definition = definition.with(cb-counter-depth: 3)
Subsequent uses of `definition` will default to depth 3:
```typst
#definition[
  This is a definition. Please understand it.
]
```
#definition[
  This is a definition. Please understand it.
]

#note[
  In fact, the `cb-counter-depth` parameter mentioned earlier is set by calling the `reg-default-countblock` function when the document is initialized.
]

#newpara()

=== Using countblock

After defining and registering a counter, use the `countblock` function to create a block:
```typst
#countblock(
  name,
  cb,
  cb-counter-depth: cb.at("cb-counter-depth"), // default: 2
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
  | `cb-counter-depth` | `int` | `cb.at("cb-counter-depth")` | Counter depth |
  | `subname` | `str` | `` | Entry name |
  | `count` | `bool` | `true` | Enable numbering |
  | `lab` | `str` | `none` | Reference label |
]
- `name`: Counter name, as specified in `add-countblock`.
- `cb`: Dictionary formatted as @cb. Ensure it contains the latest counter by updating `cb` first.
- `cb-counter-depth`: Counter depth (`1`, `2`, or `3`).
- `subname`: Supplemental text displayed after the counter (e.g., theorem name).
- `count`: Set `false` to disable numbering.
- `lab`: Label for cross-referencing with `@lab`.

Example using the `test` counter created in @new-cb:
```typst
#countblock("test", cb)[
  1 + 1 = 2
]
```
#countblock("test", cb)[
  1 + 1 = 2
]

Alternatively, create a wrapper function:
```typst
#let test = countblock.with("test", cb)
#test[
  1 + 1 = 2
]
```
#let test = countblock.with("test", cb)
#test[
  1 + 1 = 2
]

#newpara()

For the `test1` counter (depth 3 registered in @cb-counter), specify depth during use:
```typst
#countblock("test1", cb, cb-counter-depth: 3)[
  1 + 1 = 2
]
#let test1 = countblock.with("test1", cb, cb-counter-depth: 3)
#test1[
  1 + 1 = 2
]
```
#countblock("test1", cb, cb-counter-depth: 3)[
  1 + 1 = 2
]
#let test1 = countblock.with("test1", cb, cb-counter-depth: 3)
#test1[
  1 + 1 = 2
]

#newpara()

=== Summary

Scripst provides a simple counter module system. You can use the `add-countblock` function to create counters, `reg-countblock` to register them, and `countblock` to implement them.

By default, all counters have a depth of 2. Use `reg-default-countblock` to configure default counters.

- If you want all countblocks to use depth 2, no special configuration is needed.
- If you want all countblocks to use depth 3, specify the depth during registration and usage.

#example(count: false)[
  Example: A user wants all default countblocks to use depth 3, while making `remark` independent from the shared counter for `proposition`, `lemma`, `corollary`, and `claim`. Also create a depth-3 `algorithm` counter.

  ```typst
  #show: scripst.with(
    // ...
    cb-counter-depth: 3,
  )
  #let cb = add-countblock(cb, "rmk", "Remark", mycolor.violet-darker)
  #let cb = add-countblock(cb, "algorithm", "Algorithm", mycolor.yellow)
  #show: reg-countblock.with("rmk", cb-counter-depth: 3)
  #show: reg-countblock.with("algorithm", cb-counter-depth: 3)
  #let definition = definition.with(cb-counter-depth: 3)
  #let theorem = theorem.with(cb-counter-depth: 3)
  // ...
  #let remark = countblock.with("rmk", cb, cb-counter-depth: 3) // Re-encapsulate due to counter changes
  #let algorithm = countblock.with("algorithm", cb, cb-counter-depth: 3)
  ```
  Place this code at the beginning of the document, after `#script`.
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
