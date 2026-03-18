#import "@preview/scripst:1.1.0": *

#show: scripst.with(
  title: [Scripst Documentation],
  info: [Article Style Set],
  author: ("AnZrew", "AnZreww", "AnZrewww"),
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
  lang: "en",
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

=== Using Extracted Files

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

=== Local Package Management

*A better way is* to refer to the official #link("https://github.com/typst/packages?tab=readme-ov-file#local-packages")[local package management documentation] and place the template files in the local package management directory `{data-dir}/typst/packages/{namespace}/{name}/{version}`, so you can use the Scripst templates anywhere.

Of course, you don't have to worry about not being able to modify the template files. You can directly use `#set, #show` commands in the document to override some parameters in the template.

For example, the template should be placed in
```
~/.local/share/typst/packages/preview/scripst/1.1.0               # in Linux
%APPDATA%\typst\packages\preview\scripst\1.1.0                    # in Windows
~/Library/Application Support/typst/packages/local/scripst/1.1.0  # macOS
```
You can execute the following command:
```bash
cd ~/.local/share/typst/packages/preview/scripst/1.1.0
git clone https://github.com/An-314/scripst.git 1.1.0
```
If the directory structure is like this, then the way to import the template files in the document should be:
```typst
#import "@preview/scripst:1.1.0": *
```
The advantage of this is that you can directly use `typst init` to create a new project with the template:
```bash
typst init @preview/scripst:1.1.0 project_name
```
#newpara()

=== Online Package Management

We will submit it to the community as soon as possible so that you can directly use
```typst
#import "@preview/scripst:1.1.0": *
```
to import the Scripst templates in your document.

You can also use `typst init` to create a new project with the template:
```bash
typst init @preview/scripst:1.1.0 project_name
```

This method does not require downloading the template files, just import them in the document.


---------------------------------------------------------------------------------------------------------------------

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
  content-depth: 2,
  matheq-depth: 2,
  lang: "en",
)
```

See @para for the meaning of these parameters.

Then you can start writing your document.

= Template Parameter Description <para>

The Scripst template provides some parameters to customise the style of the document.

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
  matheq-depth: 2,      // int: (1, 2)
  lang: "en",           // str: ("zh", "en", "fr", ...)
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
    | author | `array`| `()` | Document authors |
  ],
  numbering: none,
)

#newpara()

The authors of the document. Pass a list of `str` or `content`.

#caution(count: false)[
  Note, if there is only one author, do not pass a `str` or `content`, but pass a list of one `str` or `content`, for example: `author: ("Author",)`
]

#newpara()

It will be displayed at the beginning of the article with $min(\#"authors", 3)$ authors per line.

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
    | matheq-depth | `int`| `1`, `2` | `2` | Depth of math equation numbering |
  ],
  numbering: none,
)

#newpara()

The depth of math equation numbering. The default is `2`.

Generally, use `1` when there are no chapters, and use `2` when there are chapters.

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

== Countblock

Countblock is a counter module provided by Scripst for counting certain countable content in the document.

The global variable `cb` records all available counters, and you can add a counter using the `add-countblock` function.

The default countblocks include:
```typst
#let cb = (
  "thm": ("Theorem", color.blue),
  "def": ("Definition", color.green),
  "prob": ("Problem", color.purple),
  "prop": ("Proposition", color.purple-grey),
  "ex": ("Example", color.green-blue),
  "note": ("Note", color.grey),
  "cau": ("⚠️", color.red),
)
```

These counters are already initialised, and you can use them directly.

#note(count: false)[
  Since Typst language functions do not have pointers or references, variables passed cannot be modified. We can only modify variables via explicit return values and pass them to the next function. Currently, the author has not found a better method.
]

#newpara()

=== Creating and Registering countblocks

You can also add (or overload) a counter using the `add-countblock` function and register it using the `register-countblock` function:

```typst
#let cb = add-countblock("test", "This is a test", teal)
#show: register-countblock.with("test")
```

After that, you can use the countblock function to count this counter.

#let cb = add-countblock("test", "This is a test", teal)
#show: register-countblock.with("test")

=== Using countblocks

Use the `countblock` function to create a block:

```typst
#countblock(
  name,
  subname,
  count: true,
  cb: cb,
  lab: none,
)[
  ...
]
```
Where `name` is the counter's name, `subname` is the entry's name, `count` indicates whether it should be counted, and `cb` is the counter's list. For example:

```typst
#countblock("thm", subname: [_Fermat's Last Theorem_], lab: "fermat", cb)[

  No three $a, b, c in NN^+$ can satisfy the equation
  $
    a^n + b^n = c^n
  $
  for any integer value of $n$ greater than 2.
]
#proof[Cuius rei demonstrationem mirabilem sane detexi. Hanc marginis exiguitas non caperet.]
```

This will create a theorem block and count it:
#countblock("thm", subname: [_Fermat's Last Theorem_], lab: "fermat", cb)[

  No three $a, b, c in NN^+$ can satisfy the equation
  $
    a^n + b^n = c^n
  $
  for any integer value of $n$ greater than 2.
]
#proof[Cuius rei demonstrationem mirabilem sane detexi. Hanc marginis exiguitas non caperet.]
Where `subname` is required as passed.

Additionally, you can use the `lab` parameter to assign a label to this block, so you can reference it later in the text. For example, the `fermat` theorem block can be referenced as `@fermat`.

```typst
Fermat did not provide proof publicly for @fermat.
```
Fermat did not provide proof publicly for @fermat.

You can also encapsulate it into another function:

```typst
#let test = countblock.with("test", cb)
```

For the previously created `test` counter, you can use the `countblock` function to count:

```typst
#countblock("test", cb)[
  1 + 1 = 2
]

#test[
  1 + 2 = 3
]
```

#let test = countblock.with("test", cb)
#countblock("test", cb)[
  $
    1 + 1 = 2
  $
]
#test[
  $
    1 + 2 = 3
  $
]


Other default counters can also be used with the pre-packaged functions:

```typst
#definition(subname: [...])[]
#theorem(subname: [...])[]
#proposition(subname: [...])[]
#problem(subname: [...])[]
#note(count: false)[]
#caution(count: false)[]
```

#definition[

  This is a definition, please understand it.
]

#theorem(lab: "test")[

  This is a theorem, please use it. (Added a label to this countblock for referencing later)
]

#problem[

  This is a problem, please solve it.
]

#proposition[

  This is a proposition, please prove it.
]

#note(count: false)[

  This is a note, please take note of it.
]

#caution(count: false)[
  This is a reminder, please be cautious about it.
]

#theorem[

  This is a test of referencing @test.
]

You can also have Typst list all countblocks:

```typst
#outline(title: [List of Thms], target: figure.where(kind: "thm"))
```
#outline(title: [List of Thms], target: figure.where(kind: "thm"))

#newpara()

#note(count: false)[
  The `kind` parameter here is the `name` specified when defining the countblock, which is the key string in the `cb` dictionary.
]

The numbering logic for these counters is as follows:

- If there is no section, there will be only one counter number;
- If there are sections, the counter number will be *section number. number of this type of block within the section up to this point*

*Thus, you can register and use any number of counters.*

= Conclusion

The above documentation demonstrated Scripst, explained the template parameters, and showed the template effects.

I hope this document helps you better use Typst and Scripst.

You are also welcome to provide suggestions, improvements, and/or contribute code to Scripst.

Thank you for your support of Typst and Scripst!
