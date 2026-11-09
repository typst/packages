#import "@preview/ling-handout:0.1.0": ling-handout, ex

#show: ling-handout.with(
  handout-title: [Your handout title],
  handout-author: "Your Name",
  handout-date: "01-01-2027",
  group: "Your Course/Conference/Group",
  location: "Your Institution",
)

= Introduction

Examples are numbered continuously through the whole document, as in @ex-first.

#ex[
  + A first sub-example.
  + A second sub-example.
] <ex-first>

#ex[A single-line example.] <ex-second>

Later on you can point back to @ex-second.
