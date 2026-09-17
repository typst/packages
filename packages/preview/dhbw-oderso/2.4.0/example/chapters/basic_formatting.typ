#import "@preview/dhbw-oderso:2.4.0": tablefigure

= Basic Formatting

#let typst-preview(caption, typst-code) = tablefigure(
  caption: caption,
  columns: 2,
  align: (_, row) => if row == 0 { center } else { horizon + left },
  table-content: (
    table.header("Typst Code", "Output"),
    align(horizon, box(width: 100%, raw(typst-code, lang: "typ", block: true))),
    box(width: 100%, {
      set heading(outlined: false)
      eval(typst-code, mode: "markup")
    }),
  ),
)

- *Headings and Subheadings:* Create headings by typing `=` followed by your heading text. Increase the number of `=` signs for subheadings, indicating their level within the document structure.

- *Emphasizing Text:* Use `_underscores_` to _italicize words or phrases_, adding emphasis where needed.

- *Lists:* Generate ordered lists with `+` and unordered lists with `-`. Indent lists for sub-items, creating a hierarchical structure.

#typst-preview(
  "Headings in Typst",
  "== Main Heading
_This_ is a *level 2* heading.

=== Subheading
+ This is an ordered list.
+ It can contain multiple items.",
)
