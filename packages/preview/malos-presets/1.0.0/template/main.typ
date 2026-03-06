#import "@preview/malos-presets:1.0.0": presets

#show: presets

#set text(lang: "en")

#set document(
  title: [Example Document Using Malo's Presets],
  author: "Malo",
)


#title()

#align(center, context document.author.join(linebreak()))

#outline()


= Fonts

Titles and headings use Libertinus Sans to contrast with the main text, which is typeset in Libertinus Serif. Mathematics are laid out in New Computer Modern Math, and raw text in Fira Mono.


= Paragraphs

Paragraphs are justified, with character-level justification enabled. They are also first-line-indented.

#lorem(80)

#lorem(100)


= Lists

Lists use en dashes as markers:
- First item.
- Second item.
- Third item.


= Footnotes

Footnote entries have minor styling adjustments.#footnote[Notably, the footnote number is not displayed in superscript in the entry.]


= Links

External links, such as to https://example.com/ are underlined.
