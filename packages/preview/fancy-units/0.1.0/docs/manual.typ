#import "/src/lib.typ": *
#import "./my-tidy.typ"

#set page(numbering: "1")
#set par(justify: true)
#set heading(numbering: "1.1")

#set raw(lang: "typc")
#set table(stroke: none)
#show link: set text(blue)

#align(center)[
  #text(18pt)[`fancy-units`]

  https://github.com/janekfleper/typst-fancy-units \
  Version 0.1.0 \
  Requires Typst 0.11+
]



= Introduction <introduction>

Since a comparison to the LaTeX package #link("https://ctan.org/pkg/siunitx?lang=de")[siunitx] is inevitable for a units package, I will get this out of the way immediately.
I used the same names for the functions ```typc num()```, ```typc unit()```, ```typc qty()``` etc. and tried to use same (or at least similar) names for the options.
However, this package is not supposed to be a port of siunitx.
There are already two Typst packages available that aim to replace siunitx, namely #link("https://typst.app/universe/package/unify/")[unify] and #link("https://typst.app/universe/package/metro/")[metro].
For the formatting of numbers there is also the package #link("https://typst.app/universe/package/zero")[zero].

My goal was to create a package to format numbers and units that makes use of the Typst language and the built-in styling as much as possible.
This package therefore does not have to be nearly as complex as siunitx, which I consider a good thing.
I am definitely planning to implement more features over time, but I kept the initial version rather simple and somewhat opinionated by design.

For the impatient reader I will already show a few examples.
Please refer to the later sections for the parameters of the functions and more examples to showcase all the available options.

#fancy-units-configure((uncertainty-mode: "conserve"))
#my-tidy.show-example-table(
  scope: (num: num, unit: unit, qty: qty),
  "num[0.9]",
  "num[-0.9 (*1*)]",
  "num[0.9 +-#text(red)[0.1] e1]",
  "unit[kg m^2 / s]",
  "unit[#math.cancel[μg]]",
  "unit[_E_#sub[rec]]",
  "unit[#sym.planck Hz]",
  "qty[0.9][g]",
  "qty[27][_E_#sub[rec]]",
)

The input for numbers and units is just regular Typst content in markup mode that can be styled with the functions that are already available in Typst.
Writing the units does not require any variables or macros for the prefixes and base units.
The parser strips off the styling and stores the functions together with the number and unit content.
During the processing the numbers and units are converted to your desired output format, and the styling is applied again when the content is actually formatted.

In @styling I will go into the details of the styling and explain some of the known limitations. 
I will give a summary of the available configuration options in @configuration.
The functions ```typc num()```, ```typc unit()``` and ```typc qty()``` are then shown in @numbers, @units and @quantities respectively with many examples to highlight the capabilities of the packages.

If you have found a bug or if you have any suggestions how I could improve the package, please feel free to open an issue or a pull request on #link("https://github.com/janekfleper/typst-fancy-units").
I am also active on the Typst forum if you want to reach out to me #link("https://forum.typst.app/u/janekfleper").



#pagebreak()

= Styling <styling>

This package allows you to wrap parts of the numbers and units into styling functions. 
During the parsing the content is unwrapped until there is only the actual text left.
The styling functions are saved in a stack alongside the text in a so-called content tree.
If necessary, the text is then modified according to the format options.
During the formatting the styling functions are applied to the text again to get the desired output.

Since the body has to follow the syntax rules of markup content, there are situations where spaces are required when you are using styling functions.
There is no way to ignore a syntax error in the body, the content must always be valid before it can be parsed.
If you are calling a function in the content of a number or a unit, make sure to put a space in front of succeeding parentheses (or brackets) that are not supposed to be part of the function.
For numbers this is only relevant when you are using relative uncertainties.
With units this can be an issue whenever you are grouping units with parentheses (or brackets).


== Supported functions <styling-support-functions>

This table gives you an overview of the styling functions that are currently supported for numbers and units.
The support for quantities is equivalent to `num[]` and `unit[]` for the respective parts.
Which styling functions are actually useful is for you to decide.

#let cell-no-effect = table.cell(colspan: 1, fill: yellow.lighten(60%))[]
#let cell-not-supported = table.cell(colspan: 1, fill: red.lighten(60%))[]
#let cell-supported = it => table.cell(align: center, fill: green.lighten(83%))[#it]
#let styling-note = it => text(size: 11pt)[#it]

#table(
  columns: (2fr, 1fr, 1fr, 5fr),
  inset: 4pt,
  gutter: 2pt,
  align: left,

  table.header([function], table.cell(align: center)[`num[]`], table.cell(align: center)[`unit[]`], [Notes]), 
  table.hline(y: 0, stroke: 1pt + gray, position: bottom),
  table.vline(x: 0, stroke: 1pt + gray, position: end),

  ```typ *bold*```,
  cell-supported(num[*0.9*]),
  cell-supported(unit[*kg*]),
  [],

  ```typ _emph_```,
  cell-supported(num[_0.9_]),
  cell-supported(unit[_kg_]),
  styling-note[Support for `num[]` depends on the font],

  `text(..)[]`,
  cell-supported(num[#text(red)[0.9]]),
  cell-supported(unit[#text(red)[kg]]),
  [],

  `overline[]`,
  cell-not-supported,
  cell-supported(unit[#overline[kg]]),
  [],

  `underline[]`,
  cell-not-supported,
  cell-supported(unit[#underline[kg]]),
  [],

  `strike[]`,
  cell-not-supported,
  cell-supported(unit[#strike[kg]]),
  [],

  `sub[]`,
  cell-not-supported,
  cell-supported(unit[kg#sub[abc]]),
  styling-note[The subscript will be passed to `attach(br: )`],

  `super[]`,
  cell-not-supported,
  cell-supported(unit[#super[kg]]),
  styling-note[The superscript is treated like a separate unit],

  `math.cancel[]`,
  cell-supported(num[#math.cancel[0.9]]),
  cell-supported(unit[#math.cancel[kg]]),
  [],
  
  `math.display[]`,
  cell-no-effect,
  cell-supported(unit[#math.display[kg^2]]),
  styling-note[The parameter `cramped` has no effect],

  `math.inline[]`,
  cell-no-effect,
  cell-supported(unit(per-mode: "fraction")[#math.inline[kg^2]]),
  styling-note[Equivalent to the function `math.display[]`],

  `math.script[]`,
  cell-supported(num[#math.script[0.9]]),
  cell-supported(unit[#math.script[kg^2]]),
  [],

  `math.sscript[]`,
  cell-supported(num[#math.sscript[0.9]]),
  cell-supported(unit[#math.sscript[kg^2]]),
  [],

  `math.bold[]`,
  cell-supported(num[#math.bold[0.9]]),
  cell-supported(unit[#math.bold[kg]]),
  styling-note[Equivalent to the function ```typ *bold*```],

  `math.italic[]`,
  cell-supported(num[#math.italic[0.9]]),
  cell-supported(unit[#math.italic[kg]]),
  styling-note[Equivalent to the function ```typ _emph_```],

  `math.sans[]`,
  cell-supported(num[#math.sans[0.9]]),
  cell-supported(unit[#math.sans[kg]]),
  styling-note[Support for `num[]` depends on the font],

  `math.frac[]`,
  cell-supported(num[#math.frak[0.9]]),
  cell-supported(unit[#math.frak[kg]]),
  styling-note[Support for `num[]` depends on the font],

  `math.mono[]`,
  cell-supported(num[#math.mono[0.9]]),
  cell-supported(unit[#math.mono[kg]]),
  styling-note[Support for `num[]` depends on the font],

  `math.bb[]`,
  cell-supported(num[#math.bb[0.9]]),
  cell-supported(unit[#math.bb[kg]]),
  styling-note[Support for `num[]` depends on the font],

  `math.cal[]`,
  cell-supported(num[#math.cal[0.9]]),
  cell-supported(unit[#math.cal[kg]]),
  styling-note[Support for `num[]` depends on the font],

  `math.overline[]`,
  cell-supported(num[#math.overline[0.9]]),
  cell-supported(unit[#math.overline[kg]]),
  styling-note[Different spacing than the regular `overline[]`],

  `math.underline[]`,
  cell-supported(num[#math.underline[0.9]]),
  cell-supported(unit[#math.underline[kg]]),
  styling-note[Different spacing than the regular `underline[]`],
)


#pagebreak()

= Configuration <configuration>

The settings to configure the output format of the numbers and the units are kept in a state and will be used as the default.
This state should be set at the beginning of the document to configure the global format.
The format can always be changed for individual numbers and units by using the respective function arguments that will take precedence over the state.

#let func-fancy-units-configure = (
  name: "fancy-units-configure",
  description: "Parse, interpret and format a number\n\n",
  args: (
    decimal-separator: (
      description: [
        The symbol to separate the integer part from the decimal part.

        This only affects the output. The input must always use the decimal point `"."` as separator.

        If the separator is set to `auto`, the appropriate symbol based on the text language will be used.#footnote[According to #link("https://en.wikipedia.org/wiki/Decimal_separator#Conventions_worldwide")]
      ],
      types: ("auto", "string", "content"),
      default: "auto",
    ),
    uncertainty-mode: (
      description: [
        The output format for the (symmetric) uncertainties.

        See the parameter of `num()` in @num-parameters for the details.
      ],
      types: ("string",),
      default: "\"plus-minus\"",
    ),
    unit-separator: (
      description: [
        The separator between units.

        See the parameter of `unit()` in @unit-parameters for the details.
      ],
      types: ("content",),
      default: "h(0.2em)",
    ),
    per-mode: (
      description: [
        The output format for units with negative exponents.

        See the parameter of `unit()` in @unit-parameters for the details.
      ],
      types: ("string",),
      default: "\"power\"",
    ),
    quantity-separator: (
      description: [
        The separator between the number and the unit.

        See the parameter of `qty()` in @qty-parameters for the details.
      ],
      types: ("content",),
      default: "h(0.2em)",
    ),
  ),
  return-types: none,
)
#my-tidy.show-function(func-fancy-units-configure, my-tidy.style-args)



= Numbers <numbers>

A number consisting of a value, uncertainties and an exponent.

The value component is required to have a valid number, whereas the uncertainties and the exponent are optional components.
The parsing is only successful if everything in the number can be matched.
Even if just one of the components has an invalid format, an error will be raised.

#my-tidy.show-example-table(
  scope: (num: num, unit: unit),
  "num[0.9]",
  "num[0.9e1]",
  "num[-0.9 +-0.1 e1]",
)


== Parameters <num-parameters>

#let func-num = (
  name: "num",
  description: "Parse and format a number",
  args: (
    decimal-separator: (
      description: [
        The symbol to separate the integer part from the decimal part.

        By default the separator stored in the `fancy-units-state` will be used, see @configuration for the details.
      ],
      types: ("auto", "string", "content"),
      default: "auto",
    ),
    uncertainty-mode: (
      description: [
        The output format for the (symmetric) uncertainties.

        Symmetric uncertainties can be converted to the other format.
        Asymmetric uncertainties will ignore this option and automatically use the output format `"plus-minus"`.
        See the examples in @num-examples to understand how the conversion between the input format and the output format works.

        By default the format stored in the ```typc fancy-units-state``` will be used, see @configuration for the details.
      ],
      types: ("auto", "string"),
      values: (
        plus-minus: (
          type: "string",
          details: [The (absolute) uncertainties are preceded by #sym.plus.minus.],
          alias: ("+-", "pm"),
        ),
        parentheses: (
          type: "string",
          details: [The (relative) uncertainties are wrapped in parentheses $()$.],
          alias: ("()",),
        ),
        conserve: (
          type: "string",
          details: "The input format of the uncertainties will be conserved (if possible).",
        ),
      ),
      default: "auto"
    ),
    body: (
      description: [
        The actual number to be parsed and formatted.

        The number must contain a value, while the uncertainties and the exponent are optional. The uncertainties can be either symmetric or asymmetric and absolute or relative to the value.

        #block[
          #h(1em)
          #my-tidy.show-component("value", padding: 1pt)
          ```typ +-```
          #my-tidy.show-component("uncertainty", padding: 1pt)
          ```typ e```
          #my-tidy.show-component("exponent", padding: 1pt)
          #h(1em) or #h(1em)
          #my-tidy.show-component("value", padding: 1pt)
          ```typ (```
          #my-tidy.show-component("uncertainty", padding: 1pt)
          ```typ )e```
          #my-tidy.show-component("exponent", padding: 1pt)
        ]

        The value can either be an integer or a floating point number.

        The exponent is prefixed by an `e` or `E` and must always be at the end of the number.
        It can either be an integer or a floating point number.

        There is no limit to the number of uncertainties, the parser will try to interpret everything after the value (and before the exponent) as uncertainties.
        If an uncertainty is prefixed by ```raw +-```, it is interpreted as an _absolute_ uncertainty.
        Absolute uncertainties can either be an integer or a floating point number. \

        An uncertainty wrapped in parentheses `()` will be interpreted _relative_ to the value.
        Relative uncertainties must always be an integer.
        A floating point number will result in an error due to an invalid number format.
      ],
      types: ("content",),
      tags: ("Required", "Positional"),
    ),
  ),
  return-types: ("content",),
)
#my-tidy.show-function(func-num, my-tidy.style-args)


== Examples <num-examples>

=== ```typc uncertainty-mode``` <num-examples-uncertainty-mode>

As explained earlier in @num-parameters the ```typc uncertainty-mode``` only affects the output of the numbers.
The input will always be parsed without taking the ```typc uncertainty-mode``` into account.
Spaces around the signs ```none +``` and ```none -```, the parentheses `()` and the exponent characters `e` or `E` are allowed and will not affect the output.
// They should be used improve the readability of the input if possible.
For absolute uncertainties it is considered best practice to put a space before ```typ +-``` to improve the readability.
If the uncertainty is asymmetric, the space should be put before both signs. \
A space before the exponent character can be useful to highlight that the exponent affects the entire number.
This is especially true in the case of absolute uncertainties.
Since parentheses around the value and the uncertainties are not required in the number input, a space can highlight that the exponent does not belong to the (last) uncertainty. 

#my-tidy.show-example-table(
  columns: (
    (uncertainty-mode: "plus-minus"),
    (uncertainty-mode: "parentheses"),
    (uncertainty-mode: "conserve"),
  ),
  scope: (num: num, unit: unit),
  "num[0.9 +-0.1]",
  "num[0.9(1)]",
  "num[0.9 +-0.1 e1]",
  "num[0.9(1)e1]",
  "num[0.9 +-0.1 +-0.2]",
  "num[0.9(1)(2)]",
  "num[0.9 +0.1 -0.2]",
  "num[0.9(1:2)]",
  "num[0.9(1:2)e1]",
)


=== Styling <num-examples-styling>

When styling the components in a number, there are a few (syntax) rules to follow.
The styling functions are attached to the components before the number is actually parsed.
If done correctly, the styling will therefore not affect the interpretation of the number.

It is sufficient to apply the styling to the actual components.
The accompanying characters ```none +-```, `()` or `eE` do not have to be included in the styling functions.
In either case only the actual component will be styled in the output.
Styling the accompanying characters is (currently) not possible.

#my-tidy.show-example-table(
  columns: (
    (uncertainty-mode: "plus-minus"),
    (uncertainty-mode: "parentheses"),
    (uncertainty-mode: "conserve"),
  ),
  scope: (num: num, unit: unit),
  "num[#text(red)[-0.9] (1)]",
  "num[0.9 #text(red)[(1)] e1]",
  "num[0.9 *+-0.1* e1]",
  "num[-0.9 (1) #text(red)[e1]]",
  "num[0.9 +0.0 #text(red)[-0.1]]",
)



= Units <units>

A unit can be anything from a single character to a complex structure with fractions, brackets and groups.
It is not necessary to use variables for the prefixes and units, you can just write them down directly.
The parser will figure out the exponents, brackets, etc. and the unit will then be formatted accordingly.

#my-tidy.show-example-table(
  scope: (num: num, unit: unit),
  "unit[μg]",
  "unit[(m s)^2]",
  "unit[kg m/s^2]",
)


== Parameters <unit-parameters>

#let func-unit = (
  name: "unit",
  description: "Parse and format a unit",
  args: (
    decimal-separator: (
      description: [
        The symbol to separate the integer part from the decimal part in exponents.

        By default the separator stored in the `fancy-units-state` will be used, see @configuration for the details.
      ],
      types: ("auto", "string", "content"),
      default: "auto",
    ),
    unit-separator: (
      description: [
        The separator to join the units.

        After the individual units are formatted they are joined by the separator.
        The most common choice will be a small amount of horizontal space to visually separate the units.
        Other typical options are the symbols `sym.dot` [#sym.dot] or `sym.times` [#sym.times].

        By default the separator stored in the `fancy-units-state` will be used, see @configuration for the details.
      ],
      types: ("auto", "content"),
      default: "auto"
    ),
    per-mode: (
      description: [
        The output format for units with negative exponents.

        This option only affects the output format.
        The parser will not save any information about the input format.
        The `"conserve"` option therefore does not exist here.

        By default the format kept in the `fancy-units-state` will be used, see @configuration for the details.
      ],
      types: ("auto", "string"),
      values: (
        power: (
          type: "string",
          details: [The negative exponent will be applied directly, e.g. #unit(per-mode: "power")[m / s^2]],
        ),
        fraction: (
          type: "string",
          details: [An actual fraction is used, e.g. #unit(per-mode: "fraction")[m / s^2]],
        ),
        slash: (
          type: "string",
          details: [A forward slash is used to indicate a fraction, e.g. #unit(per-mode: "slash")[m / s^2]],
        )
      ),
      default: "auto"
    ),
    body: (
      description: [
        The actual unit(s) to be parsed and formatted.

        Since the body is just regular content, the usual restrictions of math input do not apply.
        You can just write down the units separated by spaces and it is not necessary to use variables for the prefixes and units.
        Unicode characters such as the prefix μ also work directly or as a hexadecimal escape sequence ```typ \u{03bc}```.

        The parser will try to match pairs of parentheses, brackets and curly brackets.
        If not all of them can be matched, an error will be raised.
        A single pair of parentheses `()` will only group the units inside.
        This is for example useful to apply an exponent to multiple units.
        If you want to actually have the parentheses in the output, you have to use two pairs `(())`.

        You can apply styling to multiple units, to a single unit or just to a part of a unit, e.g. the prefix.
        If the styling is only applied to the prefix, you have to use a colon `:` to join the prefix and the unit again.
        Otherwise the parser will not understand that the two components belong to the same unit.
      ],
      types: ("content",),
      tags: ("Required", "Positional"),
    ),
  ),
  return-types: ("content",),
)
#my-tidy.show-function(func-unit, my-tidy.style-args)


== Examples <unit-examples>

=== `per-mode` <unit-examples-per-mode>

As explained earlier in @unit-parameters the `per-mode` only affects the output of the units.
For the input format you most likely want to use a slash `/` to indicate a fraction, but it is also valid to use negative exponents.
The slash will only affect the first trailing unit, use parentheses or (curly) brackets to apply the fraction to multiple units.

#my-tidy.show-example-table(
  columns: (
    (per-mode: "power"),
    (per-mode: "fraction"),
    (per-mode: "slash"),
  ),
  scope: (unit: unit),
  "unit[m / s]",
  "unit[kg^-2]",
  "unit[kg m / s^2]",
  "unit[kg / (m s)]",
)

The `per-mode` `"slash"` can be ambiguous when a slash is followed by multiple units.
If you want to prevent this ambiguity, wrap the units in a second pair of parentheses as shown in @unit-examples-grouping.


=== Grouping <unit-examples-grouping>

You can group units with parentheses or (curly) brackets.
A single pair of parentheses will _silently_ group the units, only the second pair is actually included in the formatted output.
This replicates the behaviour of parentheses in a fraction in math mode.
Brackets and (curly) brackets are always included in the formatted output. 

Since brackets `[]` are also the macro for `content`, this can sometimes lead to unexpected behaviour.
This is just something to keep in mind if you absolutely have to use brackets in a unit.

#my-tidy.show-example-table(
  columns: (
    (per-mode: "power"),
    (per-mode: "fraction"),
    (per-mode: "slash"),
  ),
  scope: (unit: unit),
  "unit[kg / (m s)]",
  "unit[kg / ((m s))]",
  "unit[(kg m) / s]",
  "unit[[kg m] / s]",
  "unit[{kg m} / s]",
)

If you wrap a single unit in parentheses, its power will be _protected_ from the `per-mode`.
This can be useful if you are using the `"fraction"` mode and you want to prevent nested fractions since they can be difficult to read.
In the `"slash"` mode nesting is not possible anyway and protecting individual units will not have any effect on the output.
If you already have the `per-mode` set to `"power"`, the behaviour of protected units can be a bit weird since the multiple powers will be attached one by one.

#my-tidy.show-example-table(
  columns: (
    (per-mode: "power"),
    (per-mode: "fraction"),
    (per-mode: "slash"),
  ),
  scope: (unit: unit),
  "unit[kg / (m^-1 s)]",
  "unit[kg / ((m^-1) s)]",
)

=== Styling and Joining <unit-examples-styling-and-joining>

You can apply styling to (mulitple) units or just to a part of a unit.
The styling functions are attached to the (group of) units and components inside.
E.g. if there is a fraction or an exponent in the styling function, they will also be formatted accordingly.

It is also possible to apply the styling only to the base unit or only to the exponent.
The parser will just attach an exponent to the previous unit, the separation by the styling functions is therefore not an issue.

If a unit is split up into multiple parts due to the styling, you can use a colon to join the components again.
This is useful when you want to apply styling only to the prefix or the base unit.
In addition this is also necessary to include a Typst variable in a unit.

Since the underscore character `_` is reserved for _italic_ styling you have to use the function `sub()` to add a subscript to a unit.
As for an exponent, the parser will attach the subscript to the previous unit and the formatter will use the function `math.attach()`. 
If a unit has both an exponent and a subscript, everything will therefore be formatted correctly.

#fancy-units-configure((per-mode: "fraction"))
#my-tidy.show-example-table(
  scope: (unit: unit),
  "unit[*kg* m / s]",
  "unit[_E_#sub[rec]^2]",
  "unit[#text(red)[μ]:m^2]",
  "unit[m#math.cancel[^2] / (#math.cancel[m] s)]",
)



= Quantities <quantities>

A quantity combines a number and a unit in a single function.
The parsing and formatting of the two components is completely separated.
Internally, the function `qty()` just calls the functions `num()` and `unit()` and adds a separator between the two.

#fancy-units-configure((per-mode: "power"))
#my-tidy.show-example-table(
  scope: (qty: qty),
  "qty[0.9][g]",
  "qty[6][W / kg]",
  "qty[33][G / cm]",
)


== Parameters <qty-parameters>

#let func-qty = (
  name: "qty",
  description: "Parse and format a quantity",
  args: (
    decimal-separator: (
      description: [
        The symbol to separate the integer part from the decimal part.

        See the parameter of `num()` in @num-parameters for the details.
      ],
      types: ("auto", "string", "content"),
      default: "auto",
    ),
    uncertainty-mode: (
      description: [
        The output format for the (symmetric) uncertainties.

        See the parameter of `num()` in @num-parameters for the details.
      ],
      types: ("auto", "string"),
      default: "auto"
    ),
    unit-separator: (
      description: [
        The separator to join the units.

        See the parameter of `unit()` in @unit-parameters for the details.
      ],
      types: ("auto", "content"),
      default: "auto"
    ),
    per-mode: (
      description: [
        The output format for units with negative exponents.

        See the parameter of `unit()` in @unit-parameters for the details.
      ],
      types: ("auto", "string"),
      default: "auto"
    ),
    quantity-separator: (
      description: [
        The separator to join the number and the unit.

        After the number and the unit are parsed and formatted they are joined by the separator.
        A small horizontal space is probably the only reasonable choice here.

        By default the separator stored in the `fancy-units-state` will be used, see @configuration for the details.
      ],
      types: ("auto", "content"),
      default: "auto"
    ),
    number: (
      description: [
        The number to be parsed and formatted.

        See the `body` of `num()` in @num-parameters for the details.
      ],
      types: ("content",),
      tags: ("Required", "Positional"),
    ),
    unit: (
      description: [
        The unit to be parsed and formatted.

        See the `body` of `unit()` in @unit-parameters for the details.
      ],
      types: ("content",),
      tags: ("Required", "Positional"),
    ),
  ),
  return-types: ("content",),
)
#my-tidy.show-function(func-qty, my-tidy.style-args)



== Examples <qty-examples>

=== `quantity-separator` <qty-examples-quantity-separator>

There are situations where you might want to adjust the space between the number and the unit.
If the number has an exponent or the unit is a variable wrapped in `math.emph()`, it can be nice to slightly reduce the spacing.
You are of course free to use other symbols to separate the number and the unit, but even `sym.dot` #sym.dot just does not look right.

#my-tidy.show-example-table(
  scope: (qty: qty),
  "qty(quantity-separator: h(0.1em))[0.9e-3][kg]",
  "qty(quantity-separator: h(0.2em))[0.9e-3][kg]",
  "qty(quantity-separator: h(0.1em))[27][_E_#sub[rec]]",
  "qty(quantity-separator: h(0.2em))[27][_E_#sub[rec]]",
)