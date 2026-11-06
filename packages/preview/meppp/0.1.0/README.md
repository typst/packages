# meppp
A simple template for modern physics experiments (MPE) courses at the Physics School of PKU.
## meppp-lab-report

The recommended report format of MPE course.
Default arguments are shown as below:
```typ
#import "@preview/meppp:0.1.0": *

#let meppp-lab-report(
  title: "",
  author: "",
  info: [],
  abstract: [],
  keywords: (),
  author-footnote: [],
  heading-numbering-array: ("I","A","1","a"),
  heading-suffix: ". ",
  doc
)=...
```
- `title` is the title of the report. 
- `author` is the name of the author.
- `info` is a line (or lines) of brief information of author and the report (e.g. student ID, school, experiment date...)
- `abstract` is the abstract of the report, not shown when it is empty.
- `keywords` are keywords of the report, only shown when the abstract is shown.
- `author-footnote` is the phone number or the e-mail of the author, shown in the footnote.
- `heading-numbering-array` is the heading numbering of each level. Only shows the numbering of the deepest level.
- `heading-suffix` is the suffix of headings

It is recommended to use `#show` to use the template:
```typ
#show: doc=>meppp-lab-report(
    ..args,
    doc
)
...your report below.
```

## meppp-tl-table
Modify your input `table` to a three-lined table (AIP style), returned as a `figure`. Double-lines above and below the table, and a single line below the header.
```typ
#let meppp-tl-table(
  caption: none,
  supplement: auto,
  stroke:0.5pt,
  tbl
)=...
```
- `caption` is the caption above the table, center-aligned
- `supplement` is same as the supplement in the figure.
- `stroke` is the stroke used in the three lines (maybe five lines).
- `tbl` is the input table, which must contains a `table.header`

Example:
```typ
#meppp-tl-table(
  table(
    columns:4,
    rows:2,
    table.header([Item1],[Item2],[Item3],[Item4]),
    [Data1],[Data2],[Data3],[Data4],
  )
)
```

## pku-logo
The logo of PKU, returned as a `image`
```typ
#let pku-logo(..args) = image("pkulogo.png",..args)
```
Example:
```
#pku-logo(width:50%)
#pku-logo()
```