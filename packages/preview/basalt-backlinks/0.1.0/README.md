A Typst package for generating and getting backlinks.

# Setup
```typ
#import "@preview/basalt-backlinks:0.1.0" as backlinks
#show link: backlinks.generate
```

# Usage
```typ
Here's some content I want to link to. <linktome>

#pagebreak()

#link(<linktome>)[I'm linking to the content.]

#pagebreak()

#link(<linktome>)[I'm also linking to the content!]

#pagebreak()

#context {
  let backs = backlinks.get(<linktome>)
  for (i, back) in backs.enumerate() [
    #link(back.location())[
      Backlink for \<linktome> (\##i)
    ]

  ]
}
```
