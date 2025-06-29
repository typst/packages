# $Z\cdot e^{ro}$

_Advanced scientific number formatting for Typst._

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FMc-Zen%2Fzero%2Fv0.4.0%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/zero)
[![Test Status](https://github.com/Mc-Zen/zero/actions/workflows/run_tests.yml/badge.svg)](https://github.com/Mc-Zen/zero/actions/workflows/run_tests.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Mc-Zen/zero/blob/main/LICENSE)


- [Introduction](#introduction)
- [Quick Demo](#quick-demo)
- [Number Formatting](#number-formatting)
- [Table Alignment](#table-alignment)
- [Units and Quantities](#units-and-quantities)
- [Zero for Third-Party Packages](#zero-for-third-party-packages)
- [Changelog](#changelog)

---

## Introduction

Proper number formatting is essential for clear and readable scientific documents. **Zero** provides tools for consistent formatting and simplifies adherence to established publication standards. Key features include:

- **Standardized** formatting
- Digit [**grouping**](#grouping), e.g., 299 792 458 instead of 299 792 458
- **Plug-and-play** number [**alignment in tables**](#table-alignment)
- Quick scientific notation, e.g., `"2e4"` becomes 2×10⁴
- Symmetric and asymmetric [**uncertainties**](#specifying-uncertainties)
- [**Rounding**](#rounding) in various modes
- [**Unit and quantity formatting**](#units-and-quantities)
- Helpers for package authors

A number in scientific notation consists of three parts: the _mantissa_, an optional _uncertainty_, and an optional _power_ (exponent). The following figure illustrates the anatomy of a formatted number:

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/a78ff9a4-eb90-44b4-9168-37d100452363">
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/b75dad9b-f4af-4caf-989b-f327603b2bf8">
    <img alt="Anatomy of a formatted number" src="https://github.com/user-attachments/assets/a78ff9a4-eb90-44b4-9168-37d100452363">
  </picture>
</p>

<!-- For generating formatted numbers, *Zero* provides the `num` type along with the types `coefficient`, `uncertainty`, and `power` that allow for fine-grained customization with `show` and `set` rules.  -->

---

## Quick Demo

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/925fb0ff-5af2-4373-a3e6-63f23523d60c">
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/655c57b0-b4d5-4ca4-b928-3b90104ed93c">
    <img alt="Quick demo" src="https://github.com/user-attachments/assets/925fb0ff-5af2-4373-a3e6-63f23523d60c">
  </picture>
</p>

---

## Number Formatting

- [Function `num`](#num)
- [Grouping](#grouping)
- [Rounding](#rounding)
- [Uncertainties](#specifying-uncertainties)

### `num`

Zero's core is the `num()` function, which provides flexible number formatting. Its defaults can be configured via `set-num()`. 

```typ
#num(
  number:                 str | content | int | float | dictionary | array,
  digits:                 auto | int = auto,
  fixed:                  none | int = none,

  decimal-separator:      str = ".",
  product:                content = sym.times,
  tight:                  bool = false,
  math:                   bool = true,
  omit-unity-mantissa:    bool = true,
  positive-sign:          bool = false,
  positive-sign-exponent: bool = false,
  base:                   int | content = 10,
  uncertainty-mode:       str = "separate",
  round:                  dictionary,
  group:                  dictionary,
)
```
- `number: str | content | int | float | array` : Number input; `str` is preferred. If the input is `content`, it may only contain text nodes. Numeric types `int` and `float` are supported but not encouraged because of information loss (e.g., the number of trailing "0" digits or the exponent). The remaining types `dictionary` and `array` are intended for advanced use, see [below](#zero-for-third-party-packages).
- `digits: auto | int = auto` : Truncates the number at a given (positive) number of decimal places or pads the number with zeros if necessary. This is independent of [rounding](#rounding).
- `fixed: none | int = none` : If not `none`, forces a fixed exponent. Additional exponents given in the number input are taken into account. 
- `decimal-separator: str = "."` : Specifies the marker that is used for separating integer and decimal part.
- `product: content = sym.times` : Specifies the multiplication symbol used for scientific notation. 
- `tight: bool = false` : If true, tight spacing is applied between operands (applies to × and ±). 
- `math: bool = true` : If set to `false`, the parts of the number won't be wrapped in a `math.equation`. This makes it possible to use `num()` with non-math fonts.
- `omit-unity-mantissa: bool = false` : Determines whether a mantissa of 1 is omitted in scientific notation, e.g., 10⁴ instead of 1·10⁴. 
- `positive-sign: bool = false` : If set to `true`, positive coefficients are shown with a + sign. 
- `positive-sign-exponent: bool = false` : If set to `true`, positive exponents are shown with a + sign. 
- `base: int | content = 10` : The base used for scientific power notation. 
- `uncertainty-mode: str = "separate"` : Selects one of the modes `"separate"`, `"compact"`, or `"compact-separator"` for displaying uncertainties. The different behaviors are shown below:

  <p align="center">
    <picture>
      <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/b7f5b106-efd5-477a-8299-c8daacdbd6e4">
      <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/f6bc45ff-74cb-499b-86a9-a03ba032bd33">
      <img alt="Uncertainty modes" src="https://github.com/user-attachments/assets/b7f5b106-efd5-477a-8299-c8daacdbd6e4">
    </picture>
  </p>

- `round: dictionary` : You can provide one or more rounding options in a dictionary. Also see [rounding](#rounding). 
- `group: dictionary` : You can provide one or more grouping options in a dictionary. Also see [grouping](#grouping). 

Configuration example: 
```typ
#set-num(product: math.dot, tight: true)
```

### Grouping


Digit grouping is important for keeping large figures readable. It is customary to separate thousands with a thin space, a period, comma, or an apostrophe (however, we discourage using a period or a comma to avoid confusion since both are used for decimal separators in various countries). 


<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/f900e134-b1d9-482f-b2c2-3100cad38793">
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/67e8516f-98d5-4678-8af0-b2a8786da507">
    <img alt="Digit grouping" src="https://github.com/user-attachments/assets/f900e134-b1d9-482f-b2c2-3100cad38793">
  </picture>
</p>


Digit grouping can be configured with the `set-group()` function. 


```typ
#set-group(
  size:       int = 3, 
  separator:  content = sym.space.thin,
  threshold:  int | dictionary = 5
)
```
- `size: int = 3` : Determines the size of the groups. 
- `separator: content = sym.space.thin` : Separator between groups. 
- `threshold: int | dictionary = 5` : Necessary number of digits needed for digit grouping to kick in. Four-digit numbers for example are usually not grouped at all since they can still be read easily. This parameter also accepts dictionary arguments of the form `(integer: int, fractional: int)` to allow turning on grouping for only the integer or fractional part, for example `(integer: 5, fractional: calc.inf)`. 



Configuration example: 
```typ
#set-group(separator: "'", threshold: 4)
```

Set `threshold: calc.inf` to disable grouping.



### Rounding

Rounding can be configured with the `set-round()` function. 

```typ
#set-round(
  mode:       none | str = none,
  precision:  int = 2,
  pad:        bool = true,
  direction:  str = "nearest",
)
```
- `mode: none | str = none` : Sets the rounding mode. The possible options are
  - `none` : Rounding is turned off. 
  - `"places"` : The number is rounded to the number of decimal places given by the `precision` parameter. 
  - `"figures"` : The number is rounded to a number of significant figures given by the `precision` parameter.
  - `"uncertainty"` : Requires giving an uncertainty value. The uncertainty is 
     rounded to significant figures according to the `precision` argument and 
    then the number is rounded to the same number of decimal places as the 
    uncertainty. 
- `precision: int = 2` : The precision to round to. Also see parameter `mode`. 
- `pad: bool = true` : Whether to pad the number with zeros if the 
   number has fewer digits than the rounding precision. 
- `direction: str = "nearest"` : Sets the rounding direction. 
  - `"nearest"`: Rounding takes place in the usual fashion, rounding to the nearer 
    number, e.g., 2.34 → 2.3 and 2.36 → 2.4. 
  - `"down"`: Always rounds down, e.g., 2.38 → 2.3 and 2.30 → 2.3. 
  - `"up"`: Always rounds up, e.g., 2.32 → 2.4 and 2.30 → 2.3. 



### Specifying Uncertainties

There are two ways of specifying uncertainties:
- Applying an uncertainty to the least significant digits using parentheses, e.g., `2.3(4)`,
- Denoting an absolute uncertainty, e.g., `2.3+-0.4` becomes 2.3±0.4. 

Zero supports both and can convert between these two, so that you can pick the displayed style (configured via `uncertainty-mode`, see above) independently of the input style. 

How do uncertainties interplay with exponents? The uncertainty needs to come first, and the exponent applies to both the mantissa and the uncertainty, e.g., `num("1.23+-.04e2")` becomes

    (1.23 ± 0.03)×10²

Note that the mantissa is now put in parentheses to disambiguate the application of the power. 

In some cases, the uncertainty is asymmetric which can be expressed via `num("1.23+0.02-0.01")`

$$ 1.23^{+0.02}_{-0.01}. $$

---

## Table Alignment

In scientific publication, presenting many numbers in a readable fashion can be a difficult discipline. A good starting point is to align numbers in a table at the decimal separator. With Zero, this can be easily accomplished by simply applying a show-rule to `table`. 


```typ
#{
  show table: zero.format-table(none, auto, auto)
  table(
    columns: 3,
    align: center,
    $n$, $α$, $β$,
    [1], [3.45], [-11.1],
    ..
  )
}
```

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/f964e693-b65a-43c5-81ce-e37a3122bea8">
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/c73d5fb5-56b6-42d4-90a6-924f6f03abd1">
    <img alt="Number alignment in tables" src="https://github.com/user-attachments/assets/f964e693-b65a-43c5-81ce-e37a3122bea8">
  </picture>
</p>

Arguments to `format-table` are `none`, `auto`, or dictionaries (see [below](#advanced-table-options)) that turn on or off number alignment for individual columns. In the example above, we activate number alignment for the second and third column. 

Be careful to scope the show-rule with curly `{}` or square `[]` brackets to avoid applying the rule twice when changing format for the next table. You can use this in your figures in the following way:
```typ
#figure(
  {
    show table: zero.format-table(..)
    table(..)
  },
  caption: []
)
```
Through this show-rule, Zero can interoperate seamlessly with many other table packages for Typst. 

Nevertheless, Zero also provides the function `ztable` that you can use as a drop-in replacement for the standard table function. It features an additional parameter `format` which takes an array of `none`, `auto`, or `dictionary` values to turn on number alignment for specific columns. With `ztable` the above example can be recreated like this:
```typ
#ztable(
  columns: 3,
  align: center,
  format: (none, auto, auto),
  $n$, $α$, $β$,
  [1], [3.45], [-11.1],
  ..
)
```

### Protect Non-Numerical Content

Non-number entries (e.g., in the header) are automatically recognized in some cases and will not be aligned. In ambiguous cases, adding a leading or trailing space tells Zero not to apply alignment to this cell, e.g., `[Angle ]` instead of `[Angle]`. 


In addition, you can prefix or suffix a numeral with content wrapped by the function `nonum[]` to mark it as _not belonging to the number_. The remaining content may still be recognized as a number and formatted/aligned accordingly. 
```typ
#ztable(
  format: (auto,),
  [#nonum[€]123.0#nonum(footnote[A special number])],
  [12.111],
)
```

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/337054ef-c7e6-4feb-b5fd-f50e36eb043a">
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/8e169759-f0cc-4c7a-a3e7-1de0f17d2114">
    <img alt="Avoid number recognition in tables" src="https://github.com/user-attachments/assets/337054ef-c7e6-4feb-b5fd-f50e36eb043a">
  </picture>
</p>


### Advanced Table Options

Zero not only aligns numbers at the decimal point but also at the uncertainty and exponent part. Moreover, by passing a `dictionary` instead of `auto`, a set of `num()` arguments to apply to all numbers in a column can be specified. 

```typ
#ztable(
  columns: 4,
  align: center,
  format: (none, auto, auto, (digits: 1)),
  $n$, $α$, $β$, $γ$,
  [1], [3.45e2], [-11.1+-3], [0],
  ..
)
```

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/0d707e0c-2231-4c0c-afd5-97f6bdf7fca0">
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/19ccb15c-c5ba-4b03-a4e1-054862543d75">
    <img alt="Advanced number alignment in tables" src="https://github.com/user-attachments/assets/0d707e0c-2231-4c0c-afd5-97f6bdf7fca0">
  </picture>
</p>

---

## Units and Quantities

Numbers are frequently displayed together with a (physical) unit forming a so-called _quantity_. Zero has built-in support for formatting quantities through the `zi` module. 

Zero takes a different approach to units than other packages: In order to avoid repetition ([DRY principle](https://de.wikipedia.org/wiki/Don%E2%80%99t_repeat_yourself)) and to avoid accidental errors, every unit is
- first _declared_ (or already predefined)
- and then used as a function to produce a quantity. 

Take a look at the example below:
```typ
#import "@preview/zero:0.4.0": zi

#let kgm-s2 = zi.declare("kg m/s^2")

- The current world record for the 100 metres is held by Usain Bolt with #zi.s[9.58]. 
- The velocity of light is #zi.m-s[299792458].
- A Newton is defined as #kgm-s2[1]. 
- The unit of a frequency is #zi.Hz(). 
```
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/566500e3-7e4f-44eb-ae2e-b527084703bc">
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/3e8a6365-fddc-4876-baef-3b4dc6719dce">
    <img alt="Units and quantities" src="https://github.com/user-attachments/assets/566500e3-7e4f-44eb-ae2e-b527084703bc">
  </picture>
</p>


### Declaring a New Unit

All common single units as well as a few frequent combinations have been predefined in the `zi` module. 

You can create a new unit through the `zi.declare` function. We recommend the following naming convention to uniquely assign a variable name to the unit. 

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/c0c6b280-d53e-4b4f-a719-5f86001c326e">
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/93954701-5c34-47cb-8ac2-457cff777283">
    <img alt="Declaring new units" src="[https://github.com/user-attachments/assets/9aa4a915-f8e3-4270-8f97-36a312340e75](https://github.com/user-attachments/assets/c0c6b280-d53e-4b4f-a719-5f86001c326e)">
  </picture>
</p>


### Configuring Units
The appearance of units can be configured via `set-unit`:
```typ
#set-unit(
  unit-separator:  content = sym.space.thin,
  fraction:        str = "power",
  breakable:       bool = false
)
```
- `unit-separator: content` : Configures the separator between consecutive unit parts in a composite unit. 
- `fraction: str` : Configures the appearance of fractions when there are units present in the denominator. Possible options are
  - `"power"` : Units with negative exponents are shown as powers. 
  - `"fraction"` : When units with negative exponents are present, a fraction is created and the concerned units are put in the denominator. 
  - `"inline"` : An inline fraction is created. 
- `breakable: bool` : Whether units and quantities can be broken across paragraph lines. 

These options are also available when instancing a quantity, e.g., `#zi.m(fraction: "inline")[2.5]`. 

Note that the configuration made through `set-num` also affects the numeral of a quantity. 


---

## Zero for Third-party Packages

This package provides some useful extras for third-party packages that generate formatted numbers (for example graphics libraries). 

Instead of passing a `str` to `num()`, it is also possible to pass a dictionary of the form
```typ
(
  mantissa:  str | int | float,
  e:         none | str,
  pm:        none | array
)
```
This way, parsing the number can be avoided which makes especially sense for packages that generate numbers (e.g., tick labels for a diagram axis) with independent mantissa and exponent. 

Furthermore, `num()` also allows `array` arguments for `number` which allows for more efficient batch-processing of numbers with the same setup. In this case, the caller of the function needs to provide `context`. 

Lastly, the function `align-columns` can be used to format and align an array of numerals into a single column. The returned array of items can be used to fill a column of a `table` or `stack`. Also here, the caller of the function needs to provide `context`. 


## Changelog


### Version 0.4.0
_Units and quantities_
- Adds the `zi` module for unit and quantity formatting. 
- Adds new way of applying table alignment via show-rules for seamless interoperability with other table packages. 
- Adds option to configure the group threshold individually for the integer and fractional part. 
- Fixes numbers in RTL direction context. 
- Fixes `figure.kind` detection of`ztable`. 
- Fixes direct usage of `nonum` in `ztable`. 
- Fixes uncertainties in combination with a `fixed` exponent. 

### Version 0.3.3
_Fix_
- Fixes an issue with negative numbers in parentheses due to a change in Typst 0.13. 

### Version 0.3.2
_Fixes and more helpers for third-party package developers_
- Adds `align-columns` for package developers. 
- Fixes issues arising for Typst 0.13.

### Version 0.3.1 
_Improvements for tables and math-less mode_
- Fixes `show` rules with `table.cell` for number-aligned cells. 
- Improves `math: false` mode: Formatting can now be handled entirely without equations which makes it possible to use Zero with fonts without math support. 
- Improves number recognition in tables. A number now needs to start with one of `0123456789+-,.`. This gets rid of many false positives (mostly encountered in header cells). 

### Version 0.3.0
_Support for non-numerical content in number cells_
- Adds `nonum[]` function that can be used to mark content in cells as _not belonging to the number_. The remaining content may still be recognized as a number and formatted/aligned accordingly. The content wrapped by `nonum[]` is preserved. 
- Fixes number alignment tables with new version Typst 0.12. 

### Version 0.2.0 
_Performance and math-less mode_
- Adds support for using non-math fonts for `num` via the option `math`. This can be activated by calling `#set-num(math: false)`. 
- Performance improvements for both `num()` and `ztable(9)`

### Version 0.1.0
_Initial release_