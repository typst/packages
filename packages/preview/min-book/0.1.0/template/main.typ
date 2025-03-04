#import "@preview/min-book:0.1.0": (
  book, note, horizontalrule, hr, blockquote
)

#show: book.with(
  title: "Book Title",
  subtitle: "Complementary subtitle, not more than two lines long",
  authors: "Author",
  date: (2025, 01, 12),
  titlepage: true,
  cover: image("assets/cover.png"),
  paper: "a5",
  part: "Subject",
  chapter: "Detail",
)


= Page Availability

== Usable Space

#lorem(507)


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

#lorem(40)

#lorem(40)

- Item A
- Item B
- Item C

#lorem(40)

#lorem(40)


=== Numbered lists

#lorem(40)

#lorem(40)

+ Item A
+ Item B
+ Item C

#lorem(40)

#lorem(40)

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

