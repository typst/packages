#import "@preview/ilm:1.4.1": *

#set text(lang: "en")

#show: ilm.with(
  title: [The Beauty of\ Sharing Knowledge],
  author: "Max Mustermann",
  date: datetime(year: 2024, month: 03, day: 19),
  abstract: [
    'Ilm (Urdu: #text(lang: "ur", font: ("Noto Nastaliq Urdu", "Noto Naskh Arabic"), size: 0.8em)[عِلْم]) is the Urdu term for knowledge. In its general usage, 'ilm may refer to knowledge of any specific thing or any form of "learning". Subsequently, the term came to be used to refer to various categories of "sciences", especially when used in its plural form ('ulum).
  ],
  preface: [
    #align(center + horizon)[
      Thank you for using this template #emoji.heart,\ I hope you like it #emoji.face.smile
    ]
  ],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

= Layout
The template uses `A4` as its page size, you can specify a different #link("https://typst.app/docs/reference/layout/page#parameters-paper")[paper size string] using:

```typst
#show: ilm.with(
  paper-size: "us-letter",
)
```

'Ilm display's its content in the following order:
+ Cover page
+ Preface page (if defined)
+ Table of contents (unless disabled)
+ Body (your main content)
+ Appendix (if defined)
+ Bibliography (if defined)
+ Indices (if enabled) --- index of figures (images), tables, or listings (code blocks)

== Cover
The cover/title page has a title, author, date, and abstract which is a short description shown under the author name:

```typst
#show: ilm.with(
  title: [Your Title],
  author: "Author Name",
  date: datetime(year: 2024, month: 03, day: 19),
  abstract: [Your content goes here],
)
```

Only the `title` and `author` fields are necessary; `date` and `abstract` are optional.

By default, the date is shown in the format: `MMMM DD, YYYY`. You can change the date format by specifying a different format string:

```typst
#show: ilm.with(
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
)
```

See Typst's #link("https://typst.app/docs/reference/foundations/datetime/#format")[official documentation] for more info on how date format strings are defined.

== Preface
The preface content is shown on its own separate page after the cover page.

You can define it using:

```typst
#show: ilm.with(
  preface: [
    = Preface Heading
    Your content goes here.
  ],
)
```

#emoji.fire Tip: if your preface is quite long then you can define it in a separate file and import it in the template definition like so:

```typst
#show: ilm.with(
  // Assuming your file is called `preface.typ` and is
  // located in the same directory as your main Typst file.
  preface: [#include "preface.typ"],
)
```

== Table of Contents
By default, 'Ilm display a table of contents before the body (your main content). You can disable this behavior using:

```typst
#show: ilm.with(
  table-of-contents: none,
)
```

The `table-of-contents` option accepts the result of a call to the `outline()` function, so if you want to customize the behavior of table of contents then you can specify a custom `outline()` function:

```typst
#show: ilm.with(
  table-of-contents: outline(title: "custom title"),
)
```

See Typst's #link("https://typst.app/docs/reference/model/outline/")[official documentation] for more information.

== Body
By default, the template will insert a #link("https://typst.app/docs/reference/layout/pagebreak/")[pagebreak] before each chapter, i.e. first-level heading. You can disable this behavior using:

```typst
#show: ilm.with(
  chapter-pagebreak: false,
)
```

== Appendices
The template can display different appendix, if you enable and define it:

```typst
#show: ilm.with(
  appendix: (
    enabled: true,
    title: "Appendix", // optional
    heading-numbering-format: "A.1.1.", // optional
    body: [
      = First Appendix
      = Second Appendix
    ],
  ),
)
```

The `title` and `heading-numbering-format` options can be omitted as they are optional and will default to predefined values.

#emoji.fire Tip: if your appendix is quite long then you can define it in a separate file and import it in the template definition like so:

```typst
#show: ilm.with(
  appendix: (
    enabled: true,
    // Assuming your file is called `appendix.typ` and is
    // located in the same directory as your main Typst file.
    body: [#include "appendix.typ"],
  ),
)
```

== Bibliography
If your document contains references and you want to display a bibliography/reference listing at the end of the document but before the indices then you can do so by defining `bibliography` option:

```typst
#show: ilm.with(
  // Assuming your file is called `refs.bib` and is
  // located in the same directory as your main Typst file.
  bibliography: bibliography("refs.bib"),
)
```

The `bibliography` option accepts the result of a call to the `bibliography()` function, so if you want to customize the behavior of table of contents then you can do so by customizing the `bibliography()` function that you specify here. See Typst's #link("https://typst.app/docs/reference/model/bibliography/")[official documentation] for more information.

== Indices
The template also displays an index of figures (images), tables, and listings (code blocks) at the end of the document, if you enable them:

```typst
#show: ilm.with(
  figure-index: (
    enabled: true,
    title: "Index of Figures" // optional
  ),
  table-index: (
    enabled: true,
    title: "Index of Tables" // optional
  ),
  listing-index: (
    enabled: true,
    title: "Index of Listings" // optional
  ),
)
```

The `title` option can be omitted as it is optional and will default to predefined values.

== Footer
If a page does not begin with a chapter then the chapter's name, to which the current section belongs to, is shown in the footer.

Look at the page numbering for the current page down below. It will show "#upper[Layout]" next to the page number because the current subheading _Footer_ is part of the _Layout_ chapter.

When we say chapter, we mean the the first-level or top-level heading which is defined using a single equals sign (`=`).

= Text
Typst defaults to English for the language of the text. If you are writing in a different language then you need to define you language before the 'Ilm template is loaded, i.e. before the `#show: ilm.with()` like so:

```typst
#set text(lang: "de")
#show: ilm.with(
  // 'Ilm's options defined here.
)
```

By defining the language before the template is loaded, 'Ilm will set title for bibliography and table of contents as per your language settings as long as you haven't customized it already.

== External links
'Ilm adds a small maroon circle to external (outgoing) links #link("https://github.com/talal/ilm")[like so].

This acts as a hint for the reader so that they know that a specific text is a hyperlink. This is far better than #underline[underlining a hyperlink] or making it a #text(fill: blue)[different color]. Don't you agree?

If you want to disable this behavior then you can do so by setting the concerning option to `false`:

```typst
#show: ilm.with(
  external-link-circle: false,
)
```

== Blockquotes
'Ilm also exports a `blockquote` function which can be used to create blockquotes. The function has one argument: `body` of the type content and can be used like so:

```typst
#blockquote[
  A wizard is never late, Frodo Baggins. Nor is he early. He arrives precisely when he means to.
  --- Gandalf
]
```

The above code will render the following:

#blockquote[
  A wizard is never late, Frodo Baggins. Nor is he early. He arrives precisely when he means to.
  --- Gandalf
]

== Small- and all caps
'Ilm also exports functions for styling text in small caps and uppercase, namely: `smallcaps` and `upper` respectively.

These functions will overwrite the standard #link("https://typst.app/docs/reference/text/smallcaps/")[`smallcaps`] and #link("https://typst.app/docs/reference/text/upper/")[`upper`] functions that Typst itself provides. This behavior is intentional as the functions that 'Ilm exports fit in better with the rest of the template's styling.

Here is how Typst's own #std-smallcaps[smallcaps] and #std-upper[upper] look compared to the 'Ilm ones:\
#hide[Here is how Typst's own ] #smallcaps[smallcaps] and #upper[upper]

They both look similar, the only difference being that 'Ilm uses more spacing between individual characters.

If you prefer Typst's default spacing then you can still use it by prefixing `std-` to the functions:

```typst
#std-smallcaps[your content here]
#std-upper[your content here]
```

== Tables
In order to increase the focus on table content, we minimize the table's borders by using thin gray lines instead of thick black ones. Additionally, we use small caps for the header row. Take a look at the table below:

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

#figure(caption: ['Ilm's styling], si-table)

For comparison, this is how the same table would look with Typst's default styling:

#[
  #set table(inset: 5pt, stroke: 1pt + black)
  #show table.cell.where(y: 0): it => {
    v(0.5em)
    h(0.5em) + it.body.text + h(0.5em)
    v(0.5em)
  }
  #figure(caption: [Typst's default styling], si-table)
]

= Code
== Custom font
'Ilm uses the _Iosevka_@wikipedia_iosevka font for raw text instead of the default _Fira Mono_. If Iosevka is not installed then the template will fall back to Fira Mono.

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

#show raw: set text(font: "Fira Mono")
For comparison, here is what `code` in Fira Mono looks like:
#snip("Code snippet typeset in Fira Mono font")

#show raw: set text(font: ("Iosevka", "Fira Mono"))
and here is how the same `code` looks in Iosevka:
#snip("Code snippet typeset in Iosevka font")

In the case that both code snippets look identical then it means that Iosevka is not installed on your computer.
