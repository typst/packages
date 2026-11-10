#import "@preview/malos-presets:1.3.0": presets

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

Titles and headings use Libertinus Sans to contrast with the main text, which is typeset in Libertinus Serif with raw text in Inconsolata. Mathematics are laid out in New Computer Modern Math with Computer Modern-style blackboard bold: $QQ$, $RR$. This can be disabled to use AMS blackboard bold instead with the show-set rule ```typc show math.equation: set text(features: (ss03: 0))```: #[
  #show math.equation: set text(features: (ss03: 0))
  $QQ$, $RR$.
]


= Paragraphs

Paragraphs are justified, with character-level justification enabled.

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
