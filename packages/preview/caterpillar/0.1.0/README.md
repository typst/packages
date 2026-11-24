# A Typst content parser

This package is used to parse the content that the Typst compiler outputs, mainly for creating custom syntactic rules, but hopefully flexible enough for other purposes. It provides a combinatory parsing engine that aims to handle differences in content structure by itself.

**DISCLAIMER**. This package is for personal use only. It is built around content inspection, which is an antipattern and undocumented behavior that might change without warnings. It also introduces certain obscurity to documents, despite making them look cleaner. Do not you this in production.

Suppose you are writing notes in raw text, formatting theorems like this:

```
Theorem 1.2'. Blah blah *blah* blah blah.
```

It so happens that you need to compile it to PDF using a theorem formatter (e.g. Beautiframe). You do not want to rewrite every theorem in Typst script: you appreciate the conciseness of your own syntax. Great news: Caterpillar will parse the content to find every paragraph that is a theorem, and show them as theorems.

```typst
#import "@preview/caterpillar:0.1.0": *
#import parsers as p
#import "@preview/beautiframe:0.4.0": theorem, beautiframe-setup
#beautiframe-setup(style: "academic")

#let theorem-parser = (
  ([Theorem], p.space),
  p.until(p.anything, ([.], p.space)),
  ([.], p.space)
)
#let theorem-handler((_, num, _), rest) = theorem(rest, number: num.join())
#show par: crawl.with((theorem-parser, theorem-handler))

Theorem 1.2'. Blah blah *blah* blah blah.
```

![Example that shows a beautiframe theorem](assets/example.svg)

What happens here is:

- `theorem-parser` is a functional parser built from Caterpillar's blocks.
  - An array of parsers runs parsers sequentially.
  - Content matches content, splitting text if needed.
  - `p.space` matches either a `space` element or a `" "` text.
  - `p.until` runs the first parser repeatedly until the second succeeds.
  - `p.anything` matches any piece of content.
- `theorem-handler` takes the result of parsing --- the parsed content and the remaining part --- and builds a theorem from it.
- `crawl` in a show rule assembles the pipeline: runs any number of parsers on every paragraph, and, if a parser succeeds, applies the corresponing handler on its output.

There are more constants and combinators. Regex is supported, and so are fully custom parsers. See [documentation.pdf](documentation.pdf) for a tutorial and an API reference.
