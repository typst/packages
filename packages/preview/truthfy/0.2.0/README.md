# truthfy
Make an empty or filled truth table in Typst

# Functions

```
generate-empty(info: array[math_block], data: array[str]): table
    Create an empty (or filled with "data") truth table. 

generate-table(..info: array[math_block]): table
    Create a filled truth table. Only "not and or xor => <=>" are consider in the resolution.
```

# Example 

```typ
#import "@preview/truthfy:0.2.0": generate-table, generate-empty

#generate-table($A and B$, $B or A$, $A => B$, $(A => B) <=> A$, $ A xor B$)

#generate-table($p => q$, $not p => (q => p)$, $p or q$, $not p or q$)
```

![image](https://media.discordapp.net/attachments/751591144919662752/1160216944138518588/image.png)

# Changelog

`0.1.0`: Create the package. <br/>
`0.2.0`: 
- You can now use `t`, `r`, `u`, `e`, `f`, `a`, `l`, `s` without any problems!
- You can now add subscript to a letter
- Only `generate-table` and `generate-empty` are now exported
- Better example with more cases
- Implemented the `a ? b : c` operator