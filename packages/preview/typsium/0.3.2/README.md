[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Typsium/typsium)
[![MIT License](https://github.com/Typsium/typsium/blob/0.3.2/LICENSE)
[![User Manual](https://img.shields.io/badge/manual-.pdf-purple)](https://raw.githubusercontent.com/Typsium/typsium/0.3.2/docs/manual.pdf)

# Write beautiful chemical formulas and reactions with Typsium
## Usage
```typst
#import "@preview/typsium:0.3.2":*
```
Enter your chemical formula or reaction into the `#ce"` method like this: 
```typst
#ce("[Cu(H2O)4]^2+ + 4NH3 -> [Cu(NH3)4]^2+ + 4H2O")
```
<img alt="An example chemical reaction with prettier formatting. Counts are subscripted and charges superscripted and proper reaction arrows are used." src="https://raw.githubusercontent.com/Typsium/typsium/0.3.2/tests/README-graphic1/ref/1.png" />

You can also embed any kind of content into your chemical reactions by using square brackets instead of passing in a string, for example. This will also apply any styling to the reaction. ~Hoping this feature doesn't have bugs.~

```typst
#ce[[Cu(H2O)4]^2+ + 4NH3 -> [Cu(NH3)4]^2+ + 4H2O]
```

![result2](https://raw.githubusercontent.com/Typsium/typsium/0.3.2/tests/README-graphic1/ref/1.png)
> The formulae will automatically break if they are longer than the page width now.
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

Molecule parsing is flexible and supports many different ways of writing, so you can copy and paste your formulas, and they will probably work. Oxidation numbers can be added like this`^^`,  radicals can be added like this`.`, and hydration groups can be added like this`*`.

You can use many kinds of brackets. They will auto-scale by default, but you can disable it with a show rule.

Inline formulas often need to be a bit more compact; for this purpose, there is an `affect-layout` rule, which can be toggled on and off for each part of the reaction separately.

You can use Typsium within other packages, and the styling will be consistent throughout the document.
