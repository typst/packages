# IILC MoL Thesis

Typst port of the [official "Master of Logic
Titlepage"](https://msclogic.illc.uva.nl/current-students/graduation/titlepage/)
used by Master of Logic students at the ILLC in their thesis

## Usage

```typst
#import "@preview/illc-mol-thesis:0.1.0": titlepage

#titlepage(
  title: "Title of the Thesis",
  author: "John Q. Public",
  birth-date: "April 1st, 1980",
  birth-place: "Alice Springs, Australia",
  defense-date: "August 28, 2005",
  supervisors: ("Dr Jack Smith", "Prof Dr Jane Williams"),
  committee: (
    "Dr Jack Smith",
    "Prof Dr Jane Williams",
    "Dr Jill Jones",
    "Dr Albert Heijn"),
  degree: "MSc in Logic"
)
```
