# bob

````typ
#import "@preview/gviz:0.1.0": *
#show raw.where(lang: "bob"): it => render_bob(it)

#let svg = bob2svg("<--->")
#render_bob("<--->")
#render_bob(
    ```
      0       3  
       *-------* 
    1 /|    2 /| 
     *-+-----* | 
     | |4    | |7
     | *-----|-*
     |/      |/
     *-------*
    5       6
    ```,
    width: 25%,
)

```bob
"cats:"
 /\_/\  /\_/\  /\_/\  /\_/\ 
( o.o )( o.o )( o.o )( o.o )
```
````