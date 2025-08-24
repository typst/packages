#import "@preview/bubble:0.2.2": *

#show: bubble.with(
  title: "Bubble template",
  subtitle: "Simple and colorful template",
  author: "hzkonor",
  affiliation: "University",
  date: datetime.today().display(),
  year: "Year",
  class: "Class",
  other: ("Made with Typst", "https://typst.com"),
  //main-color: "4DA6FF", //set the main color
  logo: image("logo.png"), //set the logo
) 

// Edit this content to your liking

= Introduction

This is a simple template that can be used for a report.

= Features
== Colorful items

The main color can be set with the `main-color` property, which affects inline code, lists, links and important items. For example, the words highlight and important are highlighted !

- These bullet
- points
- are colored

+ It also
+ works with
+ numbered lists!

== Customized items


Figures are customized but this is settable in the template file. You can of course reference them  : @ref.

#figure(caption: [Code example],
```rust
fn main() {
  println!("Hello Typst!");
}
```
)<ref>

#pagebreak()

= Enjoy !

#lorem(100)