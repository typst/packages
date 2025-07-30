#import "@preview/amlos:0.1.0": *
#set document(author: "Uwni", date: datetime.today(), title: "Amlos: makes list of symbols")

= Amlos makes list of symbols

#link("https://github.com/uwni", [uwni\@GitHub])

== Quick Start
this package exposes two function

```typ
 #defsym(group: "default", math: false, symbol, desc)
```

```typ
 #use-symbol-list(group: "default", fn)
```

you use `defsym` to define a symbol and its description, and `use-symbol-list` to list all the symbols defined. crossing reference will be created for each symbol.

== Example

```typ
#defsym("Almos")[Amlos makes list of symbols] is a package of #defsym([Typst])[The Typst typesetting system] that helps you to manage symbols and their descriptions. It provides two functions, `defsym` and `use-symbol-list`. You use `defsym` to define a symbol and its description, and `use-symbol-list` to list all the symbols defined.
```

will produce:

#defsym("Almos")[Amlos makes list of symbols] is a package of #defsym([Typst])[The Typst typesetting system] that helps you to manage symbols and their descriptions. It provides two functions, `defsym` and `use-symbol-list`. You use `defsym` to define a symbol and its description, and `use-symbol-list` to list all the symbols defined.

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

=== math
you may want to define a symbol in math mode, set `math` to `true` in `defsym` to enable math mode. or you can redefine a curried function like this:

```typ
#let defsymm = defsym.with(math: true)
```