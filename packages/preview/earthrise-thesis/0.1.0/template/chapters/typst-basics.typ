#import "../utils/global.typ": *
#import "../utils/symbols.typ": LaTeX

This chapter shows the Typst basics you need most often in a thesis. For everything else, use the official Typst tutorial #footnote()[see #link("https://typst.app/docs/tutorial/")].

== Headings <subsec:headings>
Write a heading with `=` at the start of a line, one `=` per level, much like `#` in Markdown. Level-one headings are chapters: the template starts each on a new page with a large title, as in @chp:typst_basics.

=== An even deeper heading <subsubsec:deepheading>
Add `=` signs for deeper sections.

==== Super deep heading <subsubsubsec:superdeep>
This heading sits four levels deep; from this level on, headings show no number. A label such as `<subsec:headings>` after a heading makes it referable from any chapter, as in these references to @subsubsec:deepheading and @chp:introduction; figures, tables and equations take labels the same way. Prefixes like `subsec:` merely keep the labels tidy and carry no meaning.

== Lists <subsec:lists>
Write unordered lists with `-`:
- One list item
- Another list item
  - A sub-item
  - Another sub-item

Write numbered lists with `+`:
+ A numbered list item
+ Another one
  - Sub-items can go here too

== Other Nifty Features <subsec:nifty>
- *Bold*, _italic_ and _*bold italic*_ text, and `inline code`, use Markdown-like syntax.
- Functions style the rest: #strike[strikethrough], #text(orange)[color], subscripts#sub[like this] and superscripts#super[like this].
- Characters can be moved, as in the #LaTeX symbol; `utils/symbols.typ` shows how.

Footnotes #footnote()[Footnotes are useful for clickable links: #link("https://typst.app/docs/reference/model/footnote/")] are built in. Content in `[brackets]` can itself call functions, so a footnote can hold styled text, as this one does #footnote()[_We can do *all sorts*_ of stuff in #text(blue)[here]].

Beyond this chapter, the Typst reference and guides go deeper, and the community-written _Typst Examples Book_ collects recipes #footnote()[see #link("https://sitandr.github.io/typst-examples-book/book/about.html")].

== Citing References <subsec:citing>
Cite an entry of `bibliography.bib` with `@` and its key @lowry1951protein. Every cited entry appears in the bibliography after the last chapter.
