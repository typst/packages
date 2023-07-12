# whalogen

whalogen is a library for typsetting chemical formulas with Typst inspired by mhchem.



## Examples

![](gallery/example.png)

```typst
#import "@local/whalogen:0.1.0": ce

#set page(width: auto, height: auto)

$
#ce("HCl + H2O -> H3O+ + Cl-")
$
```

See the [manual](manual.pdf) for more details and examples.