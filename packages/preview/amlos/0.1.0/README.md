# Amlos makes list of symbols

Amlos (阿米<del>诺</del>洛斯) is a Typst package for making list of symbols.


## Quick Start
this package exposes two function

```typ
 #defsym(group: "default", math: false, symbol, desc)
```

```typ
 #use-symbol-list(group: "default", fn)
```

you use `defsym` to define a symbol and its description, and `use-symbol-list` to list all the symbols defined. crossing reference will be created for each symbol.

## More Usage
Confirm `manual.typ` and `manual.pdf`

## License
Mozilla Public License Version 2.0