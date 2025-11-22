#import "@preview/tufte-memo:0.1.1": *

#show: template.with(
  title: [Tufte inspired Typst template],
  shorttitle: [Tufte-Memo Usage Guide],
  subtitle: [The Tufte-Memo Usage guide and background],
  authors: (
    (
      name: "Noah Gula",
      role: "Designer",
      affiliation: "Optional Affiliation Line",
      email: "@nogula"
    ),
    (
      name: "First Last",
      role: "Role",
      affiliation: "Affiliation",
      email: "Email"
    ),
  ),
  document-number: [Version 0.1.1],
  abstract: [This Typst template adopts many aspects of the design and typography of Edward Tufte's books. The document itself demonstrates the functionality and usage of the template, including setup, sidenotes, figure display, citations, and more.],
  publisher: [Product Engineering Department],
  distribution: [authorized personnel],
  toc: false,
  footer-content: ([If the footer-content argument in the template call takes the form of an array, then the first item in that array is displayed here, as you see it, and the second item in that array is displayed on all subsequent pages after the first. If footer-content is not an array (and also not none), then the same content is displayed on all pages.],[This is the second element of the footer-content array, so it is displayed on all pages after the first.]),
  draft: false,
  bib: bibliography("references.bib")
)

= Introduction
Edward Tufte is an American statistician, professor, and pioneer in the field of data visualization, known for his work on the visual presentation of data and information. He is the author of influential books such as "The Visual Display of Quantitative Information" #notecite(<Tufte2001>)and is renowned for his principles on clarity, precision, and efficiency in data graphics. His books have inspired a unique design and typography, created by Howard Gralla.

This Typst template adopts many of the conventions used by Gralla and Tufte and allows the interested author to obtain a similar appearance to style of Tufte's publications. However, the design adapts the book-format to work as an article (i.e., not having multiple parts and chapters and so forth, but instead something more akin to a memo or academic journal article).

This document is a skeuomorph#note[This document is not only a skeuomorph, but also tests the template itself.] of the template; it intends to demonstrate the template's functionality across various frontmatter styles, citations, figures, and importantly, sidenotes.

= Using this template
Largely, this template is used by importing and calling the `#template()` function, understanding the quirks of its formatting, and making use of its features such as wideblocks and sidenotes.

The template is called just like any other Typst template, such as with: ```typst
#import "tufte-memo.typ": *
#show: template.with(...)[...]
```
The template can be configured with 13 arguments, which comprise:
- `title` (`content`, required).
- `shorttitle` (`content`, optional) displayed in the header if not `none`, otherwise the `title` is displayed instead.
- `subtitle` (`content`, optional).
- `authors` (`array`, required) takes the form as in the charged-ieee template #notecite(<Typst2024>) except instead of "department" there is "role" and "location" is ommitted.
- `date` (`datetime`, optional) displays the date on the title page if not `none`.
- `document-number` (`content`, optional) reference number for document's version or some other serialization. Displayed in the header if present.
#wideblock[
- `draft` (`bool`, optional) displays a note in the footer and also places a watermark across every page if `true`.
- `distribution` (`content`, optional) places a note in the footer if present.
- `abstract` (`content`, optional) displays the abstract below the author block if present.
- `publisher` (`content`, optional) displays below the title in the header if present.
- `toc` (`bool`, optional) displays an `outline` below the abstract if `true`.
- `bib` (`bibliography`, optional) displays a bibliography at the end of the document if not `none`. Must be a filepath reference if not `none`.
- `footer-content` (`content` or `array`, optional) if `content` then displays in the footer; if `array`, then displays first element in first page footer and second element in all other pages; or `none` and no content is displayed in footer.

== Title Page Configuration
The title page is configurable based on the combination and types of arguments supplied to the template. By default, the template produces a bare bones, simple title page: calling the template with no arguments produces a blank document with only three lines of text: "Paper Title", "First Last", and the date. The template requires an entry for the `title` and `authors` hence why there are placeholders for these values. Otherwise, the other 11 arguments optionally augment the title page to include additional information.

For instance, adding an `abstract` displays an indented block of text below the author block as you might expect, setting `toc` to `true` displays the table of contents, and so forth. Experiment with the optional arguments and see for yourself how they affect the document's setting.

== Wideblocks
You may have noticed that this text spans the entire width of the page whereas the preceeding two pages were compressed to a four-inch-wide column in the typical manner of Tufte books. The template makes permissible the ability to break the narrow column format when desired by using the `#wideblock()` function, which takes a single required argument representing the content to be displayed. The simplest way to use the wideblock is by entering `#wideblock[...]`.

The wideblock simply is a `block` but with the width parameter adjusted to make the block 6.5 inches wide. This can be useful when a full page does not contain any sidenotes and otherwise the text would look somewhat awkward being unnecessarily compressed into a narrow column.
]
== Sidenotes
In Tufte books, sidenotes#note[This is a sidenote; perhaps you have already noticed them in this document.] are a distinctive feature: sidenotes are used for a variety of purposes, but mainly to provide non-critical but related information. In a basic sense, they are simply footnotes but put on the side. Sidenotes, arguably, are more elegant than footnotes since they appear closer to the text being referenced, but still with enough of a breathe around them to not feel cluttered.

This template implements sidenotes with the `note()` function. The simplest sidenote is created with `#note[enter your content here]` which yields: #note[enter your content here]. Notice how the sidenote is automatically numbered like a footnote. This can be disabled with the `numbered: false` keyword argument.#note(numbered:false)[This sidenote is not numbered.]

On the backend, the `note()` function uses the #emph[drafting] #notecite(<Jessurun2023>) package, pre-configured with some defaults. Importantly, though, the `dy` argument can still be passed to `note()` in order to adjust the vertical offset as it appears. This is helpful when many notes are included in close vicinity. Though, #emph[drafting] package will attempt to automagically adjust vertical positions in such cases, sometimes a manual touch is necessary.

Strictly speaking, the `note()` function can be used with content of any kind, including figures. More will be discussed on the side figure topic, so it will be left for now.

There is one other type of sidenote: the citation-sidenote, which is called with the `notecite()` function. The `notecite()` function extends the simple `note()` function by placing an in-text citation at the location the function was called and by placing a simplified margin citation as well. The `notecite()` function must take a `label` key, and optionally a `supplement` for the in-text citation. E.g., this: #notecite(<Tufte2001>,supplement:[p.~47]) is produced by `#notecite(<Tufte2001>,supplement:[p.~47])`. Optionally, a `dy` argument can be passed as well.

== Figures
In this template, there are three different styles to display figures: plain, sidenote, and wideblock. A plain figure called in the body text (i.e., not in a `wideblock` or in a `note`) can be used as normal with the label applied as expected. This is demonstrated with @fig:plain-figure, below. These figures only occupy the four-inch-wide space making up the width of the document.

#figure(
  rect(
    width:100%,
    height:3in,
    fill: gradient.linear(..color.map.crest)
  ),
  caption:[This is just a plain figure.]
)<fig:plain-figure>

Alternatively, a `wideblock()` can be used to display a larger (or, at least wider) figure in the text, which spans 6.5 inches rather than four. This is demonstrated with @fig:wide.

#wideblock([#figure(
  rect(width:100%,height:3in),
  caption:[The widest figure you've ever seen!])
  <fig:wide>]
)

When a figure is used inside a `wideblock()`, it will display across the full page width. However, the figure must be wrapped in `[ ]` in order to allow for a label to be applied. E.g., see @code:figure-label.

#figure(
  ```typst
#wideblock([
  #figure(
    rect(width:100%,height:3in),
    caption:[Blah blah blah])
  <fig:label>
  ])
  ```,
  caption:[Example wide figure which has a label.]
)<code:figure-label>

But wait, there is yet one more option for displaying figures; in sidenotes! Here, the content of a `#note()` call is a `#figure()`. By convention, sidenote figures are not numbered, meaning the figure is produced like `#note(figure(...),numbered:false)`. Similar to wideblock figures, when a figure is used inside a note, it must be wrapped inside content brackets \[ \] in order to apply a label. See @code:figure-label for an example. @fig:side-figure demonstrates this.

#note([
  #figure(
    rect(width:100%,height:2in),
    caption:[This is a little figure in the sidenotes.]
  ) <fig:side-figure>
],
dy:-3in,
numbered:false)

== Other Formatting
This template supports headings up to and including the third level. It is an opinionated choice of the template's designer to not include headings level four and beyond, and even reluctantly#note[Third level headings are not included in the table of contents.] to include level three. Consider that if a fourth level heading is required (possibly a third level, for that matter), one should considering redesigning the content of the document:

#quote(block:true)[\[It is\] notable that the Feynman lectures (3 volumes) write about all of physics in 1800 pages, using only 2 levels of hierarchical headings: chapters and A-level heads in the text. It also uses the methodology of sentences which then cumulate sequentially into paragraphs, rather than the grunts of bullet points. #notecite(<Tufte>,dy:-0.25in)]

Conveniently this discussion on headings has allowed the demonstration of the block quote in this template. No adjustments have been made to the default styling of the block quote.

And finally, a few other things to note: text is displayed with a modest lightness (`luma(30)`) to reduce the harshness of the contrast between the type and the paper; links are displayed underline like #link("www.example.com"); if the `bib` argument in the template is left to `none` than no bibliography will be displayed and citations (normal in-text citations and citation-sidenotes alike) will not work.#note[Sometimes it is desirable to have the bibliography start at the top of a blank page. In which case, leave a pagebreak as the last line of your document.]

= Epilogue
Thank you to Edward Tufte for inspiring this template, and to other Typst contributes, particularly Nathan Jessurun for #emph[drafting].