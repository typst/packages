# Cleanified HPI Thesis Template

A clean-asthetic template for writing a research proposal.
There are no official guidelines on how to write a research proposal.

## Getting Started

```
typst init @preview/cleanified-hpi-research-proposal
```

## Configuration

An example configuration is located in [`example/`](./example/main.typ).

```typst
#import "@preview/cleanified-hpi-research-proposal:0.0.1": *

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  name: "Max Mustermann",
  date: "17. Juli, 2025",
  chair: "Data-Intensive Internet Computing",
)

= Introduction
#lorem(80)

== Contributions
#lorem(40)

=== Really Small Stuff
#lorem(20)

= Related Work
#lorem(500)
```

## Copyright Notes

Please note that Hasso Plattner Institute Logo is subject to copyright purposes ([HPI Logo Usage Guidelines](https://hpi.de/en/imprint/)).

## You like this template? Consider supporting!

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://coff.ee/robert.richter)

![](./0.0.1/thumbnail.png)
