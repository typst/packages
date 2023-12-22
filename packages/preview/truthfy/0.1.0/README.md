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
#import "@preview/truthfy:0.1.0": generate-table

#generate-table($A and B$, $B or A$, $A => B$, $(A => B) <=> A$, $ A xor B$)

#generate-table($p => q$, $not p => (q => p)$, $p or q$, $not p or q$)
```

![image](https://media.discordapp.net/attachments/751591144919662752/1160216944138518588/image.png)