#import "@preview/amlos:0.2.1": *
#set document(author: "Uwni", date: datetime.today(), title: "Amlos: makes list of symbols")

= Amlos makes list of symbols

#link("https://github.com/uwni", [uwni\@GitHub])

== Quick Start
this package exposes two function

```typ
#defsym(
  group: "default", // string, the group of the symbol
  math: false,      // bool, enable math mode
  symbol,           // content, the symbol
  desc              // content, the description of the symbol
)
```

```typ
#use-symbol-list(
  group: "default", // string or array of string, the group of the symbol
  fn,               // function, A function that takes  a list of (symbol, description, page) tuple
)
```

you use `defsym` to define a symbol and its description, and `use-symbol-list` to list all the symbols defined. crossing reference will be created for each symbol.

== Example

```typ
#defsym("Almos")[Amlos makes list of symbols] is a package of #defsym([Typst])[The Typst typesetting system] that helps you to manage symbols and their descriptions. It provides two functions, `defsym` and `use-symbol-list`. You use `defsym` to define a symbol and its description, and `use-symbol-list` to list all the symbols defined.
```

will produce:

_#defsym("Almos")[Amlos makes list of symbols] is a package of #defsym([Typst])[The Typst typesetting system] that helps you to manage symbols and their descriptions. It provides two functions, `defsym` and `use-symbol-list`. You use `defsym` to define a symbol and its description, and `use-symbol-list` to list all the symbols defined._

and use `use-symbol-list` to list all the symbols defined. you may use it like this:

```typ
#use-symbol-list(it => [
  #table(
    columns: 3,
    column-gutter: 1fr,
    align: (left, left, right),
    stroke: none,
    table.hline(),
    table.header(
      smallcaps[*Symbol*],
      smallcaps[*Description*],
      smallcaps[*Page*],
    ),
    table.hline(stroke: 0.5pt),

    ..it.flatten(),
    table.hline(),
  )
])

```
which will produce:

#use-symbol-list(it => [
  #table(
    columns: 3,
    column-gutter: 1fr,
    align: (left, left, right),
    stroke: none,
    table.hline(),
    table.header(
      smallcaps[*Symbol*],
      smallcaps[*Description*],
      smallcaps[*Page*],
    ),
    table.hline(stroke: 0.5pt),

    ..it.flatten(),
    table.hline(),
  )
])

== Details

=== group

Amlos supports multiple groups of symbols, you can use the `group` parameter in `defsym` to specify the group of the symbol. specify the group in `use-symbol-list` to list the symbols in the according group.

_I will define a #defsym("symbol", group: "group1")[This is a symbol defined in `group1`] here._

#use-symbol-list(
  group: "group1",
  it => [
    #table(
      columns: 3,
      column-gutter: 1fr,
      align: (left, left, right),
      stroke: none,
      table.hline(),
      table.header(
        smallcaps[*Symbol*],
        smallcaps[*Description*],
        smallcaps[*Page*],
      ),
      table.hline(stroke: 0.5pt),

      ..it.flatten(),
      table.hline(),
    )
  ],
)

or print the symbols in multiple groups by passing an array of group names to `group` parameter in `use-symbol-list`. like

this will print symbols in both `default` and `group1` group.

#use-symbol-list(
  group: ("default", "group1"),
  it => [
    #table(
      columns: 3,
      column-gutter: 1fr,
      align: (left, left, right),
      stroke: none,
      table.hline(),
      table.header(
        smallcaps[*Symbol*],
        smallcaps[*Description*],
        smallcaps[*Page*],
      ),
      table.hline(stroke: 0.5pt),

      ..it.flatten(),
      table.hline(),
    )
  ],
)


=== math
you may want to define a symbol in math mode, set `math` to `true` in `defsym` to enable math mode. or you can redefine a curried function like this:

```typ
#let defsymm = defsym.with(math: true)
```
