#import "polytechnique.typ"

#show:  polytechnique.apply

// Specific rules for the guide
#show link: set text(blue)


// Beginning of the content
#outline(title: [Guide content], indent: 1em, depth: 2)

= Discovering Typst and the template

Typst is a user-friendlier alternative to LaTeX.

== Doing some math

It is really easy to do some math, inline like $P V = n R T$ or if considering $f : x -> 1/18 x^4$, we have $forall x in RR, f(x) >= 0$. You can also do block content :
$ f(b) = sum_(k=0)^n (b-a)^k / k! f^((k))(a) + integral_a^b (b-t)^n / n! f^((n+1))(t) dif t $

== Table of contents

You can generate a table of contents using `#outline()`. Here are useful parameters you can specify :
- `indent`
- `depth`
- `title` (put the title inside brackets : [title])
For example, the previous table of contents was generated using :

```typc
#outline(title: [Guide content], indent: 1em, depth: 2)
```

== Cite an article

You can cite an article, a book or something like @example-turing (`@example-turing`). Just see the `#bibliography` command below - you need a `.bib` file containing the bibliography.

== Numbering pages

Useful commands to number pages (learn about #link("https://typst.app/docs/reference/model/numbering/")[numbering patterns]) :

```typc
#set page(numbering: none)     // to disable page numbering
#set page(numbering: "1 / 1")  // or another numbering pattern
#counter(page).update(1)       // to reset the page counter to 1 
```

*Warning* : put these instructions at the very beginning of a page, otherwise it will cause a pagebreak.

#heading(level: 2, numbering: none)[Heading without numbering]
#lorem(25)

== Dummy text with lorem

You can generate dummy text with the `#lorem(n)` command. For example : #lower(lorem(10))

=== Small heading

The small heading above won't appear in the table of contents (because depth is set to 2).

= Modify the template

== Contribute

Contributions are welcomed ! Check out the #link("https://github.com/remigerme/typst-polytechnique")[source repository].

You can also learn more about #link("https://github.com/typst/packages")[Typst packages] release pipeline.

#bibliography("assets/example.bib")
