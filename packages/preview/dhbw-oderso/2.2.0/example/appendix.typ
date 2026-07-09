// appendices: usage: (
//   title: "Title",
//   reference: "reference-label",
//   content: [content] || include("appendix.typ")
// )
#let appendices = (
  (
    title: "Relevant Stuff",
    reference: "appendix-relevant-stuff",
    content: [
      == This is some more source code
      #lorem(10)

      You can reference this appendix using `@appendix-relevant-stuff`.
    ],
  ), // appendix inline
  (
    title: "Table Examples",
    reference: "appendix-table-examples",
    content: include "appendix/tables.typ",
  ), // appendix from file
)
