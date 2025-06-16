# Truthfy
Make an empty or filled truth table in Typst

# Export

```sh
truth-table-empty(info: array[math_block], data: array[str]): table
    # Create an empty (or filled with "data") truth table. 

truth-table(..info: array[math_block]): table
    # Create a filled truth table.

karnaugh-empty(info: array[math_block], data: array[str]): table
    # Create an empty karnaugh table.

NAND: Equivalent to sym.arrow.t
NOR: Equivalent to sym.arrow.b
```

# OPTIONS
## `sc`
Theses functions have a new named argument, called `sc` for symbol-convention.

You can add you own function to customise the render of the 0 and the 1. See examples.

Syntax: 
```typst
#let sc(symb) = {
    if (symb) {
        "an one"
    } else {
        "a zero"
    }
}
```
## `reverse`
Reverse your table, see issue #3 

# Examples

## Simple

```typst
#import "@preview/truthfy:0.4.0": truth-table, truth-table-empty

#truth-table($A and B$, $B or A$, $A => B$, $(A => B) <=> A$, $ A xor B$)

#truth-table($p => q$, $not p => (q => p)$, $p or q$, $not p or q$)
```

![image](https://github.com/Thumuss/truthfy/assets/42680097/7edb921d-659e-4348-a12a-07bcc3822012)

```typst
#import "@preview/truthfy:0.4.0": truth-table, truth-table-empty

#truth-table(sc: (a) => {if (a) {"a"} else {"b"}}, $a and b$)

#truth-table-empty(sc: (a) => {if (a) {"x"} else {"$"}}, ($a and b$,), (false, [], true))
```

![image](https://github.com/Thumuss/truthfy/assets/42680097/1ccf6077-5cfb-4643-b621-1dc9529b8176)

# Contributing

If you have any idea to add in this package, add a new issue [here](https://github.com/Thumuss/truthfy/issues)!

# Changelog

`0.1.0`: Create the package. <br/>
`0.2.0`: 
- You can now use `t`, `r`, `u`, `e`, `f`, `a`, `l`, `s` without any problems!
- You can now add subscript to a letter
- Only `generate-table` and `generate-empty` are now exported
- Better example with more cases
- Implemented the `a ? b : c` operator <br/>

`0.3.0`: 
- Changing the name of `generate-table` and `generate-empty` to `truth-table` and `truth-table-empty`
- Adding support of `NAND` and `NOR` operators.
- Adding support of custom `sc` function.
- Better example and README.md

`0.4.0`:
- Add `karnaugh-empty`
- Images re-added (see #2)
- Add `reverse` option (see #3)
