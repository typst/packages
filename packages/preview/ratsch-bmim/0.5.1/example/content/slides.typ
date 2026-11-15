// Slides shared by slides-longTitle.typ (as slides) and slides-article.typ
// (as article). The markers #article-text and #article-only are invisible on
// the slides.
#import "../preamble.typ": *

#bmim.title-slide()

= Motivation <touying:skip>

== Motivation

A slide with a motivation.
The section slide for this section was supressed by writing:
```typst
= Motivation <touying:skip>
```

// in article mode, this replaces the whole content of the slide
#article-text[
  This text replaces the motivation slide in article mode. Use
  `#article-text` to give prose instead of bullet points.
]


#bmim.outline-slide(title: "Contents")


= This is a first level heading

Content at the first level will appear here.
If no further content is present, it will also be used as the slide title

== This is a second level heading

Content at the second level will appear here.
If available, the second level heading will be used instead of the first level
heading in the slide title.

=== This is third level heading

Content at the third level will appear here.
This level will not appear in the slide title.


= Formatting I

== This is a very very very very very very very very long slide head

= Formatting II

== Paragraphs

#lorem(50)

#article-only[
  This paragraph only appears in article mode, e.g. for details that do not
  fit on a slide.
]

#lorem(100)

== Text

It is recommended that you _emphasize important things_ in your talk.
If you should mention even more important things, give them a
*strong emphasis*.

Sometimes, you have to show some functions names like `halt_and_catch_fire()`.
On top of that, we have inline code like ```c i = i+1``` but also code blocks:
```rust
fn main() {
    println!("Hello World!");
}
```

Here is a link to a very good website: https://umit-tirol.at


== Math

A very nice inline formula is this one: $ a^2 + b^2 = c^2$.

Depending on the context, maybe some math block works better:
$
integral_a^b f(x) dif x = F(b) - F(a)
$

== Enumerations

This is a bullet list:
- #lorem(20)
- A nested entry:
  - #lorem(10):
    - Another level
  - #lorem(10)

This is a numbered list:
+ #lorem(10)
  + #lorem(10)
    + #lorem(5)
  + #lorem(10)
+ #lorem(20)

This is a term list:
/ Controller: Technical device that does very nice things.
/ Student: Human beeing that struggles with the concept of a controller

== Highlighting

This is #highlight(fill: blue)[highlighted in blue].
This is #highlight(fill: yellow)[highlighted in yellow].
This is #highlight(fill: green)[highlighted in green].
This is #highlight(fill: red)[highlighted in red].


== Quotes

#let slides-quote(it, quotes, outset: 0.5em) = {
  box(
    fill: luma(220),
    outset: outset,
    width: 100%,
    quotes.at(0) + it.body + quotes.at(1)
    + if it.attribution != none {
      set text(size: 0.8em)
      linebreak()
      h(1fr)
      it.attribution
    },
  )
}

We know that #quote[to be or not to be] is from Shakespear, but do you now how
#set smartquote(quotes: (single: ("« ", " »"),  double: auto))
'Thou shalt not kill'
landed in the ten commandments?

On the other hand, a block quote can also be nice:

#show quote: it => slides-quote(it, ("« ", " »"))
#quote(
  attribution: [from the Henry Cary literal translation of 1897 | *Noticed the custom quotes?*],
)[
  ... I seem, then, in just this little thing to be wiser than this man at
  any rate, that what I do not know I do not think I know either.
]

== Citations

In this template, a citation will create a footnote@netwok2020.

= Bibliography

#bibliography(title: none, "../sources.bib")

= Animations

Put a `#pause` between parts of your slide you want to uncover.

#pause

#lorem(5)

#pause

#lorem(5)

#pause

#lorem(5)

#pause

#lorem(5)

#uncover("3-5")[Hier steht richtig viel Text]


== Speaker Notes

This slide contains a speaker-note.
You won't see it unless you use
```typst
#show: bmim.slides(
  ...
  notes: right // or bottom
  ...
}
```

#speaker-note[
  This is a speaker note.
]

== Code

#let code = ```typ
#rect()
```
#code
#eval(code.text, mode: "markup")

#show: appendix

= Appendix <touying:unoutlined>

== Appendix Slide

This slide contains additional content.
