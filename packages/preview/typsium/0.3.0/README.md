[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/typsium)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/typsium/blob/main/LICENSE)
![User Manual](https://img.shields.io/badge/manual-.pdf-purple)

# Write beautiful chemical formulas and reactions with Typsium
## Usage
```typst
#import "@preview/typsium:0.3.0":*
```
Enter your chemical formula or reaction into the `#ce"` method like this: 
```typst
#ce("[Cu(H2O)4]^2+ + 4NH3 -> [Cu(NH3)4]^2+ + 4H2O")
```
![result](https://raw.githubusercontent.com/Typsium/typsium/main/tests/README-graphic1/ref/1.png)

You can also embed any kind of content into your chemical reactions like by using square brackets instead of a passing in a string. This will also apply any styling to the reaction. 

> **Warning:** Currently, brackets inside another bracket will not be parsed correctly. 

```typst
#ce[...]
```

![result2](https://raw.githubusercontent.com/Typsium/typsium/main/tests/README-graphic1/ref/1.png)

There are many different kinds of arrows to choose from. 
```typst
#ce[->]\
#ce[=>]\
#ce[<=>]\
#ce[<=]\
#ce("<->")\
#ce("<-")\
```

And you can add additional arguments to them (such as the top or bottom text) by adding square brackets.

```typst
#ce("->[top text][bottom text]")
```

The molecule parsing is flexible and allows many different ways of writing, so you can just copy paste in your formulas and they will probably work. Oxidation numbers can be added like this`^^`,  radicals can be added like this`.` and hydration groups can be added like this`*`.

You can use many kinds of brackets. they will auto scale by default, but you can disable it with a show rule.

Inline formulas often need to be a bit more compact, for this purpose there is an `affect-layout` rule, which can be toggled on and off for each part of the reaction separately.

You can use Typsium inside other packages and the styling will be consistent across the entire document.
