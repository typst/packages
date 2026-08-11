#import "@preview/min-book:1.1.0": book

#show: book.with(
  title: "Book Title",
  subtitle: "Book subtitle, not more than two lines long",
  authors: "Book Author",
  date: (2025, 01, 12),
  dedication: [
    To someone special;\
    May your days be plenty and your happiness long-lasting.
  ],
  part: "Subject",
  chapter: "Detail",
)


= Parts & Chapters


== First Chapter

This example document is divided into *"Subject"* parts and *"Detail"* chapters,
which are just headings of level 1 and 2, respectively. The chapter numbering is
sequential and do not restart at every new part.

Almost all features demonstrated here can be customized and adapted to specific
needs; for more information, refer to the official
#link("https://typst.app/universe/package/min-book/")[release page], where can
be found the manual and the source code, among other information.

#v(2em)

Sincerelly,

#link("https://github.com/mayconfmelo", "mayconfmelo.")


= Page Availability

#lorem(269)


== Paragraphs Style

#lorem(45)

#lorem(45)

#lorem(45)

#lorem(45)

#lorem(25)


= Heading Levels


== Level 2

#lorem(25)


=== Level 3

#lorem(25)


==== Level 4

#lorem(25)


===== Level 5

#lorem(18)


====== Level 6

#lorem(18)


= Some Default Elements


== Inline Markup

_#lorem(40)_

*#lorem(40)*

#quote[#lorem(40)]

#raw(lorem(40))

#lorem(3) https://example.com #lorem(15)
#link("https://github.com", "GitHub") #lorem(20)#footnote[This is an actual footnote.]

#pagebreak()


== Lists


=== Simple lists

#lorem(30)

- Item
- Item
- Item

#lorem(30)

- Item
  - Item
    - Item
      - Item
        - Item
          - Item
            - Item

#lorem(30)


=== Numbered lists

#lorem(30)

+ Item
+ Item
+ Item

#lorem(30)

+ Item
  + Item
    + Item
      + Item
        + Item
          + Item
            + Item

#lorem(30)

#pagebreak()


== Terms

#lorem(75)

/ Term A: #lorem(20)
/ Term B: #lorem(20)
/ Term C: #lorem(20)

#lorem(75)


== Raw Code

#lorem(80)

```rust
// This is a Rust code block:
fn main() {
    println!("Hello World!");
}
```

#lorem(80) ```rust main()```


= Optional Commands

#import "@preview/min-book:1.1.0": (
  note, horizontalrule, hr, blockquote, appendices, annexes
)


== End notes

#lorem(20)#note[Note A]
#lorem(20)#note[Note B]

#lorem(40)#note[Note C]

#lorem(40)#note[Note D]

#lorem(40)#note[Note E]

#lorem(40)#note[Note F]


== Block Quotes

#lorem(80)

#blockquote(by: "Author")[
  #lorem(40)
]

#lorem(80)


== Horizontal Rule

#lorem(65)

#horizontalrule()

#lorem(65)

#hr()

#lorem(65)


#appendices[
  = Some Extra Data

  #lorem(150)
  
  == Some Additional Things
  
  #lorem(50)
  
  = Even More Extra Data
  
  
  #lorem(220)
]


#annexes[
  = An Important Document Create by Someone Else

  #lorem(150)
  
  == Important Explanation
  
  #lorem(49)
  
  = Another Important Third-party Document
  
  #lorem(220)
]