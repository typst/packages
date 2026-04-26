# Amlos makes list of symbols

[Amlos](https://github.com/uwni/Amlos) (阿米<del>诺</del>洛斯) is a Typst package for making list of symbols.


## Quick Start
this package exposes two function

```typ
 #defsym(
    group: "default",
    math: false,
    symbol, // the symbol you want to define
    desc    // the description of the symbol
 )
```

```typ
 // fn: takes an array of tuple (symbol, description, page)
 #use-symbol-list(group: "default", fn)
```

you use `defsym` to define a symbol and its description, and `use-symbol-list` to list all the symbols defined. crossing reference will be created for each symbol.

## More usage
Confirm [`manual.typ`](https://github.com/uwni/Amlos/blob/main/manual.typ) and [`manual.pdf`](https://github.com/uwni/Amlos/blob/main/manual.pdf)

## Change log

v 0.1.0: basic functionalities

v 0.2.0: support for list symbols from multiple groups

## License
Mozilla Public License Version 2.0