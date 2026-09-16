# Discount
Prepend a counter by the current heading number.
Works everywhere where you can customize a numbering, including correct references.
You don't need to manually reset the counter at headings.
This package will be retired, once [#1896](https://github.com/typst/typst/issues/1896) and [#2652](https://github.com/typst/typst/issues/2652) are resolved.

## Example
```typ
#import "@preview/discount:0.1.0": heading-subnumbering

#set heading(numbering: "1.1")
#set math.equation(supplement: none, numbering: heading-subnumbering(math.equation, 1, "(1.1)"))

= Math
$ a^2 + b^2 = c^2$ // equation number: (1.0.1)
$ a^2 + b^2 = c^2$ // equation number: (1.0.2)

== More More
$ a^2 + b^2 = c^2$ // equation number: (1.1.1)

= Something else
$ a^2 + b^2 = c^2$ // equation number: (2.0.1)

```
## Arguments
The required arguments are
+ Counter identifier (e.g. `math.equation` or `figure.where(kind: table)`)
+ Levels of heading number to include
+ Numbering pattern

## Heading numbering changes in the document
You can include a `"H"` in the numbering pattern to mark the position where the heading number should be inserted _using its own numbering_.

```typ
#set heading(numbering: "1.1")
#set math.equation(supplement: none, numbering: heading-subnumbering(math.equation, 1, "(H.1.1)"))

= Intro
$ E = m c^2 $// equation number: (1.1)

#counter(heading).update(0)
#set heading(numbering: "A")
= Appendix
$ E^2 = c^2 p^2 + m^2 c^4 $// equation number: (A.1)
```
The `heading-keyword` (`"H"`) and the `separator` inserted between heading number and element number can be changed by passing the respective keyword.


## More complete example setup
```typ
#set heading(numbering: "1.1")

#set math.equation(supplement: none, numbering: heading-subnumbering(math.equation, 1, "(H.1.1)"))
#set figure(numbering: heading-subnumbering(figure, 1, "H.1.1"))
#show figure.where(kind: table): set figure(numbering: heading-subnumbering(figure.where(kind: table), 1, "H.1.1"))
#show figure.where(kind: image): set figure(numbering: heading-subnumbering(figure.where(kind: image), 1, "H.1.1"))
```

## Difference to similar packages
- [headcount](https://typst.app/universe/package/headcount): 
	- `+` You don't need to reset counters at headings manually.
	- `-` You have to pass the counter identifier to the numbering function.
- [rich-counters](https://typst.app/universe/package/rich-counters): Uses native counters.