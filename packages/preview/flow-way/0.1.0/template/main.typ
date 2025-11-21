#import "@preview/flow-way:0.1.0": *

#show: flow.with(
  title: "Flow-Way Template",
  subtitle: "A simple Typst template",
  authors: ("John Doe", "Jane Smith"),
  affiliation: "My Company",
  toc: true,
  breaks: true,
  year: 2025
)

= Introduction

This is a sample document demonstrating the Flow-Way template. 

The title of the current section is displayed in the header of each page.

== Lists

The lists are styled according to the main colour of the template, that you can customize.

- First item
- Second item
- Third item

+ First item
+ Second item
+ Third item

== Code

Here is an example of inline code: `let x = 10`. For code blocks:

```rs
fn main() {
  println!("Hello, world!");
}
```

== Images

Here is an example of a figure included in the document:

#figure(
  ```rs
  fn main() {
    println("Figure!");
  }
  ```,
  caption: [Some code]
)<example>

= That's it!

#lorem(300)