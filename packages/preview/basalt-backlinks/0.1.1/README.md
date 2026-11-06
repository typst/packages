A Typst package for generating and getting backlinks.

# Usage

```typ
#import "@preview/basalt-backlinks:0.1.1" as backlinks
#show: backlinks.generate

Here's <linktome> some content I want to link to.
#pagebreak()

I'm #link(<linktome>)[linking] to the content.
#pagebreak()

I'm also #link(<linktome>)[linking] to the content!
#pagebreak()

#context for (i, forward) in backlinks.get(<linktome>).enumerate() [
  #link(forward.location())[Backlink] for \<linktome> (\##i)

]
```
