# anti-matter
This typst packages allows you to simply mark the end and start of your front matter and back matter
to change style and value of your page number without manually setting and keeping track of inner
and outer page counters.

## Example
```typst
#import "@preview/anti-matter:0.0.2": anti-matter, anti-front-end, anti-inner-end

#set page("a4", height: auto)
#show heading.where(level: 1): it => pagebreak(weak: true) + it

// add a title page and reset the counter
#[
  #set page(numbering: none)
  #counter(page).update(0)
]

#show: anti-matter

#include "front-matter.typ"
#anti-front-end()

#include "chapters.typ"
#anti-inner-end()

#include "back-matter.typ"

```

![An example outline showing the outer roman numbering interrupted by temporary inner arabic
numbering][example]

## Features
- Marking the start and end of front/end matter.
- Specifying the numbering styles for each matter and regular content

## FAQ
1. Why are the pages not correctly counted?
   - If you are setting your own page header, you must use `anti-header`, see section II in the
     [manual].
2. Why is my outline not displaying the correct numbering?
   - If you configure your own `outline.entry`, you must use `anti-page-at`, see section II in the
     [manual].
3. Why does my front/inner/back  matter numbering start on the wrong page?
   - The markers must be on the last page of their respective matter, if you have a `pagebreak`
     forcing them on the next page it will also incorrectly label that page.
   - Otherwise please open an issue with a minimal reproducible example.

## Etymology
The package name `anti-matter` was choosen as a word play on front/back matter.

## Glossary
- [front matter] - The first part of a thesis or book (intro, outline, etc.)
- [back or end matter] - The last part of a thesis or book (bibliography, listings,
  acknowledgements, etc.)

[front matter]: https://en.wikipedia.org/wiki/Book_design#Front_matter
[back or end matter]: https://en.wikipedia.org/wiki/Book_design#Back_matter_(end_matter)
[example]: example.png
[manual]: manual.pdf
