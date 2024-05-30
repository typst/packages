# Truthfy
Make an empty or filled truth table in Typst

# Export

```
truth-table-empty(info: array[math_block], data: array[str]): table
    Create an empty (or filled with "data") truth table. 

truth-table(..info: array[math_block]): table
    Create a filled truth table. Only "not and or xor => <=>" are consider in the resolution.

NAND: Equivalent to sym.arrow.t
NOR: Equivalent to sym.arrow.b
```

# OPTIONS

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

# Examples

```typst
#import "@preview/truthfy:0.3.0": truth-table, truth-table-empty

#truth-table($A and B$, $B or A$, $A => B$, $(A => B) <=> A$, $ A xor B$)

#truth-table($p => q$, $not p => (q => p)$, $p or q$, $not p or q$)
```

![image](https://media.discordapp.net/attachments/751591144919662752/1160216944138518588/image.png)

```typst
#import "@preview/truthfy:0.3.0": truth-table, truth-table-empty

#truth-table(sc: (a) => {if (a) {"a"} else {"b"}}, $a and b$)

#truth-table-empty(sc: (a) => {if (a) {"x"} else {"$"}}, ($a and b$,), (false, [], true))
```

![image](https://media.discordapp.net/attachments/751591144919662752/1177380678715834389/image.png?ex=65724c34&is=655fd734&hm=c088867a3b3c960cf09ec054ffbc6d3f140d7aa389d637d0c6e7e9c08501d85e&=&format=webp&width=228&height=588)

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