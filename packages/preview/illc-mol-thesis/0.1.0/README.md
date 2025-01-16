# IILC MoL Thesis

This is a Typst port of the [official "Master of Logic
Titlepage"](https://msclogic.illc.uva.nl/current-students/graduation/titlepage/)
used by Master of Logic students at the ILLC in their thesis.

## Usage

Please paste the following code in your Typst file. This snippet is using the
default argument values, so if your name really is "John Q. Public" and you are
indeed a MSc in Logic student, you do not need to pass values to the `author`
and `degree` arguments.

```typst
#import "@preview/illc-mol-thesis:0.1.0": titlepage

#titlepage(
  title: "Title of the Thesis",
  author: "John Q. Public",
  birth-date: "April 1st, 1980",
  birth-place: "Alice Springs, Australia",
  defense-date: "August 28, 2005",
  /* Only one supervisor? The singleton array ("Dr Jack Smith",) needs the
     training comma. */
  supervisors: ("Dr Jack Smith", "Prof Dr Jane Williams"),
  committee: (
    "Dr Jack Smith",
    "Prof Dr Jane Williams",
    "Dr Jill Jones",
    "Dr Albert Heijn"),
  degree: "MSc in Logic"
)
```
