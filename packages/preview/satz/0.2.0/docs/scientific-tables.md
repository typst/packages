# Scientific tables

Use the development API without copying a table template:

```typst
#import "@local/satz:0.2.0": report, scientific-table, scientific-tables
#show: report.with(config: (toc: (depth: 0),))
#show: scientific-tables

#figure(
  scientific-table(
    columns: (2fr, 1fr, 1fr),
    align: (left, right, right),
    header: ([Condition], [Mean], [SEM]),
    [Baseline], [0.12], [0.03],
    [Treatment], [0.38], [0.05],
  ),
  kind: table,
  caption: [The observed results.],
) <results>

See @results.
```

`scientific-table` uses native cells and repeated headers/footers. It adds
horizontal boundary/header rules, keeps cells ragged-right without hyphenation,
and accepts native table options. Supply deliberate column widths: fractions
fill the available width, while `auto` fits a column to its content. Numeric
columns usually need right alignment. Use `table.cell(colspan: ...)` for a
full-row group heading and `table.hline` for a group separator.

The opt-in `scientific-tables` show rule places table captions above the body,
keeps them ragged-right and controls figure breakability. It preserves native
figure labels, counters, cross-references and table lists. Pass `config:` to
change `tables.caption-position`, `tables.caption-gap` and `captions.size`.
There is no forced block width: that setting would propagate into cell blocks
and could collapse fractional columns beside auto columns.

For related tests and confidence intervals, put both native tables inside one
`figure([ ... ], kind: table, caption: [...])` and attach one label. Each table
can have its own headers. Do not create separate numbered figures merely to
stack related tables; that changes the document's table identities.

Table figures stay together by default. For a genuinely long table, apply
`#show: scientific-tables.with(breakable: true)` within the intended scope.
The repeated column headings and boundary rules then continue across pages.
Avoid floating a breakable table or wrapping it in an unbreakable block.

The [short example](../examples/scientific-table.typ) demonstrates an ordinary
caption/reference. The [flow specimen](../examples/latex-parity/scientific-table-flow.typ)
demonstrates related tables, a long table, repeated rules and both references.
Compile them and inspect rendered pages; successful compilation alone misses
collapsed columns, tiny text and badly separated groups.
