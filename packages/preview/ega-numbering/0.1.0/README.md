ega-numbering: A Typst package for EGA style numbering
====================================

**0.1.** This Typst package provides a referable numbering style 
like that of Éléments de géométrie algébrique (EGA): continuously numbering everything, including definitions, theorems with or without a proof, remarks, or simply some consecutive paragraphs discussing one idea.
Each numbered element can have a label to be referred to.
We believe this style is very suitable for keeping notes and sorting out the logical flow.

**0.2.** Although we use EGA to name this numbering style, the appearance of this package resembles Max Karoubi's [K-Theory (An Introduction)](https://link.springer.com/book/10.1007/978-3-540-79890-3) published by Springer. This readme file shows an example of its effect for demonstration, although implemented by hand since it is written in markdown.

## 1. Quick start

**1.1.** To use this package, import and set show rules as follows. 

```typst
#import "@preview/ega-numbering:0.1.0": *

#show: ega-rules.with(level: 1)

#num-par[
    The contents...
]
```

This will set the numbering level to 1. See below for details.

## 2. Details in behaviour

### Setting numbering levels quickly

**2.1.** You can determine whether the numbering style is
- 1, 2, 3, ...
- 1.1, 1.2, 2.1, 2.2, 2.3, ...
- 1.1.1, 1.1.2, 1.2.1, 2.1.1, ... 

These correspond to different numbering levels, being 0, 1, 2 respectively.

You can set this numbering level by the `level` argument in the `ega-rules`.


```typst
#show: ega-rules.with(level: 1)
```

The default value is 0.

**2.2.** Note that for levels >= 1 to work normally, the numbers of headings should be displayed. Which, for example, can be set with
```typst
#set heading(numbering: "1.")
```


### Weak vertical space 

**2.3.** Different numbered elements are vertically separated. One can adjust the separation by the parameters `upper` and `lower`, whose default values are both 2em.

Note that the separation is weak. That is, they are not counted repeatedly. 
For example, vertical separations between two consecutive elements are 2em by default.

**2.4. Example.** Here is an example changing the separation in `ega-rules`.

```typst
#show: ega-rules.with(
    upper: 1.5em,
    lower: 1.5em,
)
```

### Names of a numbered element

**2.5.** One can specify the name of a numbered element as follows.
```typ
#num-par([Example])[
    This is the example...
]
```
This will yield something like 2.3.

**2.6.** Although it is possible to give an element a name like "Theorem" or "Example", when referring to the element, `@label` always yields only the number. 
This is because the user may want to add other prefix or parenthesis to this number. 
Over design may cause inconvenience rather than the opposite.


## 3. Examples

**3.1.** For more examples, check this [GitHub Repo](https://github.com/itpyi/typst-ega-numbering/tree/main/examples).