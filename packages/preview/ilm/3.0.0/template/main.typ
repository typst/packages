#import "@preview/ilm:3.0.0": *

#set text(lang: "en")

#show: ilm.with(
  title: [The Beauty of\ Sharing Knowledge],
  authors: (
    "Max Mustermann",
    // Add additional authors here.
  ),
  date: datetime(year: 2024, month: 03, day: 19),
  abstract: [
    'Ilm (Urdu: #text(lang: "ur", font: ("Noto Nastaliq Urdu", "Noto Naskh Arabic"), size: 0.8em)[عِلْم]) is the Urdu term for knowledge. In its general usage, 'ilm may refer to _knowledge_ of any specific thing or any form of _learning_. Additionally, it is also used to refer to various categories of sciences, especially when used in its plural form ('ulum).
  ],
)

// Display cover page.
#cover-page()

// An example preface page that appears after cover and before table of contents page.
#page[
  #align(center + horizon)[
    Thank you for using this template #emoji.heart \
    Don't forget to give it a #emoji.star on #link("https://github.com/talal/ilm")[github.com/talal/ilm] if you like it #emoji.face.smile
  ]
]

// Display table of contents.
#outline()

= Layout
The template uses `A4` as its page size, you can specify a different #link("https://typst.app/docs/reference/layout/page#parameters-paper")[paper size] using:

```typst
#show: ilm.with(
  paper-size: "us-letter",
)
```

By default the template is set up to display its content in the following order:
+ Cover page
+ Preface page
+ Table of contents
+ Body (main content)
+ Appendix
+ List of figures (images), tables, and listings (code blocks)
+ Bibliography

== Cover
By default, 'Ilm generates a cover/title page with a title, author(s), date, and an abstract:

```typst
#show: ilm.with(
  title: [Your Title],
  authors: "Your Name",
  abstract: [Your abstract goes here],
)
```

Only the `title` and `authors` fields are required. `date` and `abstract` are optional.

Date will default to today's date and the font size for the title will be automatically adjusted based on the title's length.

=== Multiple authors
You can specify multiple authors by providing an array. Authors will be displayed on separate lines on the cover page, with font size automatically adjusted based on the number of authors:

```typst
#show: ilm.with(
  title: [Your Title],
  authors: ("John Doe", "Jane Smith", "Max Mustermann"),
)
```

The `authors` parameter accepts either a string (single author) or an array of strings (multiple authors).

=== Date format

By default, the date is shown in the format: `Month Day, Year`. You can change the date format by specifying a different format string:

```typst
#show: ilm.with(
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
)
```

See Typst's #link("https://typst.app/docs/reference/foundations/datetime/#format")[official documentation] for more info on how date format strings are defined.

=== Customizing the cover page
The cover page is inserted by using the `cover-page()` function.

If you want to remove the cover page entirely then just remove the `cover-page()` line.

If you want to design a custom cover page then simply replace this line with your own page.

== Preface

You can insert any content between the cover and the table of contents page.

As a reference for you, I have inserted a simple preface page (see below `cover-page()` line):


```typst
#page[
  #align(center + horizon)[
    Thank you for using this template #emoji.heart \
    Don't forget to give it a #emoji.star on #link("https://github.com/talal/ilm")[github.com/talal/ilm] if you like it #emoji.face.smile
  ]
]
```

#emoji.fire Tip: you can put your content in a separate file (`preface.typ`) and then insert it like so:

```typst
#page[#include "preface.typ"]
```

== Table of Contents
By default, 'Ilm displays a table of contents before the body (your main content) using the `outline()` function.

You can disable it by simply removing the `outline()` line.

You can customize the behavior of the outline via its different parameters. For example, you can use a different title:

```typst
#outline(title: "Custom Title")
```

See Typst's #link("https://typst.app/docs/reference/model/outline/")[official documentation] for more information.

== Body
By default, the template will insert a #link("https://typst.app/docs/reference/layout/pagebreak/")[pagebreak] before each chapter, i.e. first-level heading.

You can disable this behavior using:

```typst
#show: ilm.with(
  chapter-pagebreak: false,
)
```

== Appendices
To add appendices, wrap your appendix chapters in `#appendix[...]`:

```typst
#appendix[
  = First Appendix
  = Second Appendix
]
```

This resets the heading counter, configures headings with alphabetical numbering (`A.1`), and sets the heading supplement to `Appendix`.

#emoji.fire Tip: if your appendix is quite long, you can put it in a separate file (`appendix.typ`) and include it:

```typst
#appendix[
  #include "appendix.typ"
]
```

== Indices
You can display a list of figures (images), tables, and listings (code blocks) using:

```typst
#list-of-figures()
#list-of-tables()
#list-of-listings()
```

Each function accepts the same arguments as Typst's `outline()`. For example, you can specify a custom title:

```typst
#list-of-tables(title: "Custom Title")
```

See Typst's #link("https://typst.app/docs/reference/model/outline/")[official documentation] for more information.

== Bibliography
If your document contains references and you want to display a bibliography, simply call Typst's `#bibliography()` function at the desired location:

```typst
#bibliography("refs.bib")
```

See Typst's #link("https://typst.app/docs/reference/model/bibliography/")[official documentation] for more information.

== Footer
By default, 'Ilm displays page numbers in the footer with alternating alignment (left on even pages, right on odd pages). If a page does not begin with a chapter, the chapter's name is shown alongside the page number.

Look at the page numbering for the current page. It should show _Layout_ (in small caps) next to the page number because the current _Footer_ section is part of the _Layout_ chapter.

When we say chapter, we mean the first-level or top-level heading which is defined using a single equals sign (`=`).

=== Customizing page numbering
You can customize the page numbering style in footer or disable it entirely:

Disable page numbering:
```typst
#show: ilm.with(
  footer: none,
)
```

Change style:
```typst
// Centered page number only
#show: ilm.with(
  footer: "page-number-center",
)
```


*Available style options:*
```typst
// Alternating sides with chapter name (default)
footer: "page-number-alternate-with-chapter"

// Left-aligned with chapter name
footer: "page-number-left-with-chapter"

// Right-aligned with chapter name
footer: "page-number-right-with-chapter"

// Centered page number only (no chapter name)
footer: "page-number-center"

// Left-aligned page number only (no chapter name)
footer: "page-number-left"

// Right-aligned page number only (no chapter name)
footer: "page-number-right"
```

= Text
== Language
Typst defaults to English for the language of the text. If you are writing in a different language then you need to define your language before the 'Ilm template is loaded, i.e. before the `#show: ilm.with()` like so:

```typst
#set text(lang: "de")
#show: ilm.with(
  // 'Ilm's options defined here.
)
```

By defining the language before the template is loaded, 'Ilm will set the title for bibliography and table of contents as per your language settings as long as you haven't customized it already.

== External links
'Ilm adds a small maroon circle to external (outgoing) links #link("https://github.com/talal/ilm")[like so].

This acts as a hint for the reader so that they know that a specific text is a hyperlink. This is far better than #underline[underlining a hyperlink] or making it a #text(fill: blue)[different color]. Don't you agree?

If you want to disable this behavior then you can do so by setting the concerning option to `false`:

```typst
#show: ilm.with(
  external-link-circle: false,
)
```

#pagebreak(weak: true)
== Blockquotes
'Ilm also exports a `blockquote` function which can be used to create blockquotes. The function has one argument: `body` of the type content and can be used like so:

```typst
#blockquote[
  _A wizard is never late, Frodo Baggins. Nor is he early. He arrives precisely when he means to._

  --- Gandalf
]
```

The above code will render the following:

#blockquote[
  _A wizard is never late, Frodo Baggins. Nor is he early. He arrives precisely when he means to._

  --- Gandalf
]

== Small- and all caps
'Ilm also exports functions for styling text in small caps and uppercase, namely: `smallcaps` and `upper` respectively.

These functions will overwrite the standard #link("https://typst.app/docs/reference/text/smallcaps/")[`smallcaps`] and #link("https://typst.app/docs/reference/text/upper/")[`upper`] functions that Typst itself provides. This behavior is intentional as the functions that 'Ilm exports fit in better with the rest of the template's styling.

Here is how Typst's own #std.smallcaps[smallcaps] and #std.upper[upper] look compared to the 'Ilm ones:\
#hide[Here is how Typst's own ] #smallcaps[smallcaps] and #upper[upper]

They both look similar, the only difference being that 'Ilm uses more spacing between individual characters.

If you prefer Typst's default spacing then you can use Typst's standard library directly via the `std.` prefix:

```typst
#std.smallcaps[your content here]
#std.upper[your content here]
```

#pagebreak(weak: true)
== Tables
In order to increase the focus on table content, we minimize the table's borders by using thin gray lines instead of thick black ones. Additionally, we use small caps for the header row (regardless of whether you use `table.header()` or regular rows). Take a look at the table below:

#let unit(u) = math.display(math.upright(u))
#let si-table = table(
  columns: 3,
  table.header[Quantity][Symbol][Unit],
  [length], [$l$], [#unit("m")],
  [mass], [$m$], [#unit("kg")],
  [time], [$t$], [#unit("s")],
  [electric current], [$I$], [#unit("A")],
  [temperature], [$T$], [#unit("K")],
  [amount of substance], [$n$], [#unit("mol")],
  [luminous intensity], [$I_v$], [#unit("cd")],
)

#figure(caption: ['Ilm style], si-table)

For comparison, this is how the same table would look with Typst's default styling:

#[
  #set table(inset: 0% + 5pt, stroke: 1pt + black)
  #show table.cell.where(y: 0): it => table.cell(inset: 0% + 5pt, it.body)
  #figure(caption: [Typst's default styling], si-table)
]

If you want to disable small caps for the header row, you can override it with a show rule:

```typst
#show table.cell.where(y: 0): it => table.cell(inset: 7pt, it.body)
```

If you want to remove all styling and restore Typst's default styling, use:

```typst
#set table(inset: 0% + 5pt, stroke: 1pt + black)
#show table.cell.where(y: 0): it => table.cell(inset: 0% + 5pt, it.body)
```

= Code
== Font and size
#let plex = "IBM Plex Mono"
#let deja = "DejaVu Sans Mono"

'Ilm uses the #text(font: plex, size: 0.8em)[#plex] @wikipedia_ibm_plex font for raw text instead of the default #text(font: deja, size: 0.8em)[#deja]. If #plex is not available then the template will fall back to #deja.

#[
  #let snip(cap) = figure(caption: cap)[
    ```rust
    fn main() {
        let user = ("Adrian", 38);
        println!("User {} is {} years old", user.0, user.1);

        // tuples within tuples
        let employee = (("Adrian", 38), "die Mobiliar");
        println!("User {} is {} years old and works for {}", employee.0.1, employee.0.1, employee.1);
    }
    ```
  ]

  #show raw: set text(font: deja)
  For comparison, here is how `inline code` in #deja looks like:
  #snip([Code snippet typeset in #deja font.])

  #show raw: set text(font: (plex, deja))
  and here is how the same `inline code` looks in #plex:
  #snip([Code snippet typeset in #plex font.])
]

In the case that both code snippets look identical then it means that #plex is not installed on your system.

#appendix[
  = Happy Accident

  #blockquote[
    _Anything we don't like, we'll turn it into a happy little tree or something, because as you know, we don't make mistakes, we just have happy accidents._

    --- Bob Ross, 1990
  ]

  #figure(
    image(
      bytes(
        `<svg viewBox="0 0 100 120" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none">
          <!-- Tree trunk -->
          <rect x="46" y="92" width="8" height="22" rx="2" fill="#795548" stroke="#4e342e"/>
          <path d="M 28,114 Q 50,111 72,114" stroke="#4e342e" stroke-width="2"/>

          <!-- Bottom tier -->
          <path d="M 50,56 L 20,95 Q 38,87 50,91 Q 62,87 80,95 Z" fill="#388e3c" stroke="#1b5e20"/>
          <path d="M 32,80 Q 50,74 63,82" stroke="#a5d6a7" stroke-width="1.5"/>

          <!-- Middle tier -->
          <path d="M 50,32 L 30,66 Q 42,60 50,63 Q 58,60 70,66 Z" fill="#4caf50" stroke="#2e7d32"/>
          <path d="M 38,52 Q 50,47 57,53" stroke="#a5d6a7" stroke-width="1.5"/>

          <!-- Top tier -->
          <path d="M 50,12 L 38,40 Q 45,36 50,38 Q 55,36 62,40 Z" fill="#66bb6a" stroke="#2e7d32"/>
          <path d="M 44,28 Q 50,24 53,28" stroke="#a5d6a7" stroke-width="1.5"/>
        </svg>`.text,
      ),
      format: "svg",
      width: 20%,
    ),
    caption: [A happy little tree],
  )
]


// Display list of figures, tables, and listings.
#pagebreak(weak: true)
#list-of-figures()
#list-of-tables()
#list-of-listings()

#bibliography("refs.bib")
