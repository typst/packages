# anti-matter
This typst packages allows you to simply mark the end and start of your front matter and back matter
to change style and value of your page number without manually setting and keeping track of inner
and outer page counters.

## Example
```typst
#import "@preview/anti-matter:0.0.1": anti-matter, anti-front-end, anti-back-start

#set page("a4", height: auto)
#show heading.where(level: 1): it => pagebreak(weak: true) + it

// add a title page and reset the counter
#[
  #set page(numbering: none)
  #counter(page).update(0)
]

#show: anti-matter

#include "front-matter.typ"
#anti-front-end

#include "chapters.typ"

#anti-back-start
#include "back-matter.typ"

```

![An example outline showing the outer roman numbering interrupted by temporary inner arabic
numbering](example.png)

## Features
- Marking the start and end of front/end matter.
- Specifying the numbering styles for each matter and regular content

## FAQ
1. Why are the pages not correctly counted?
   - If you are setting your own page header, you must use `anti-header`, see section II in the
     [manual].
2. Why is my outline not displaying the correct numbering?
   - If you configure your own `outline.entry`, you must use `anti-page-at`, See section II in the
     [manual].
3. Why does my front/inner/back  matter numbering start on the wrong page?
   - This is likely a bug, please open an issue with a minimal reproducible example.

## Etymology
The package name `anti-matter` was choosen as a word play on front/back matter.

## Glossary
- [front matter](https://en.wikipedia.org/wiki/Book_design#Front_matter) - The first part of a
  thesis or book (intro, outline, etc.)
- [back or end matter](https://en.wikipedia.org/wiki/Book_design#Back_matter_(end_matter)) - The
  last part of a thesis or book (bobliography, listings, acknowledgements, etc.)

  [manual]: https://github.com/tingerrr/typst-anti-matter/tree/87eb0108bdd79c16e996372013d8223647c9a64a/docs/manual.pdf
