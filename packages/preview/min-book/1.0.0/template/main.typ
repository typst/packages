#import "@preview/min-book:1.0.0": (
  book, note, horizontalrule, hr, blockquote, appendices, annexes
)

#show: book.with(
  title: "Book Title",
  subtitle: "Complementary subtitle, not more than two lines long",
  authors: "A. Author",
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

This document is divided in _parts_ and _chapters_ --- headings of levels 1
and 2, respectively; here, each part is called a
*Subject*, while each chapter is called a *Detail*. 

The *Detail* chapter numbering is sequential and do not restart at every new
*Subject* part.


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
  
  #lorem(50)
  
  = Another Important Third-party Document
  
  #lorem(220)
]