#import "@preview/light-report-uia:0.1.0": *

// CHANGE THESE
#show: report.with(
  title: "New project",
  authors: (
    "Lars Larsen",
    "Lise Lisesen",
    "Knut Knutsen",
  ),
  group_name: "Group 14",
  course_code: "IKT123-G",
  course_name: "Course name",
  date: "august 2024",
  lang: "en", // use "no" for norwegian
)

// neat code
#import "@preview/codly:1.0.0": *
#show: codly-init.with()

= Introduction
#lorem(25)

= Examples
== Citation
This is something stated from a source @example-source.

== Tables
Here's a table:
#figure(
  caption: [Table of numbers],
  table(
    columns: (auto, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [*Letters*], [*Number*], 
    ),
    [Five], [5],
    [Eight], [8],
  ) 
)

== Code blocks
Here's a rust code block:
#figure(
  caption: [Epic code],
  ```rs
  fn main() {
      let name = "buddy";
      let greeting = format!("Hello, {}!", name);
      println!("{}", greeting);
  }
  ```
)

== Math
Here's some math:
$ integral_0^infinity e^(-x^2) dif x = sqrt(pi)/2 $
And some more: $sigma / theta dot i$.