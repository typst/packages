#import "../index.typ": template, tufted
#import "@preview/cmarker:0.1.7"
#import "@preview/mitex:0.2.6": mitex
#show: template

= Embedding Markdown

You can embed Markdown content within your Typst documents using `cmarker`. This is particularly useful when incorporating existing Markdown files into your Typst-based website. To render mathematical expressions, use `mitex`.

```typst
#let md-content = read("tufted-titmouse.md")

#let def-dict = (
  image: (source, alt: none, format: auto) => figure(image(
    source,
    alt: alt,
    format: format,
  )),
)

#cmarker.render(md-content, math: mitex, scope: def-dict)
```

The content below is rendered from a Markdown file:


#let md-content = read("tufted-titmouse.md")

#let def-dict = (
  image: (source, alt: none, format: auto) => figure(image(
    source,
    alt: alt,
    format: format,
  )),
)

#cmarker.render(md-content, math: mitex, scope: def-dict)
