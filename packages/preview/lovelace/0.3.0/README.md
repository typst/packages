# Lovelace
This is a package for writing pseudocode in [Typst](https://typst.app/).
It is named after the computer science pioneer
[Ada Lovelace](https://en.wikipedia.org/wiki/Ada_Lovelace) and inspired by the
[pseudo package](https://ctan.org/pkg/pseudo) for LaTeX.

![GitHub license](https://img.shields.io/github/license/andreasKroepelin/lovelace)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/andreasKroepelin/lovelace)
![GitHub Repo stars](https://img.shields.io/github/stars/andreasKroepelin/lovelace)

Pseudocode is not a programming language, it doesn't have strict syntax, so
you should be able to write it however you need to in your specific situation.
Lovelace lets you do exactly that.

Main features include:
- arbitrary keywords and syntax structures
- optional line numbering
- line labels
- lots of customisation with sensible defaults


## Usage

- [Getting started](#getting-started)
- [Lower level interface](#lower-level-interface)
- [Line numbers](#line-numbers)
- [Referencing lines](#referencing-lines)
- [Indentation guides](#indentation-guides)
- [Spacing](#spacing)
- [Decorations](#decorations)
- [Algorithm as figure](#algorithm-as-figure)
- [Customisation overview](#customisation-overview)
- [Exported functions](#exported-functions)

### Getting started

Import the package using
```typ
#import "@preview/lovelace:0.3.0": *
```

The simplest usage is via `pseudocode-list` which transforms a nested list
into pseudocode:
```typ
#pseudocode-list[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
```
resulting in:

![simple](examples/simple.svg)

As you can see, every list item becomes one line of code and nested lists become
indented blocks.
There are no special commands for common keywords and control structures, you
just use whatever you like.

Maybe in your domain very uncommon structures make more sense?
No problem!

```typ
#pseudocode-list[
  + *in parallel for each* $i = 1, ..., n$ *do*
    + fetch chunk of data $i$
    + *with probability* $exp(-epsilon_i slash k T)$ *do*
      + perform update
    + *end*
  + *end*
]
```

![custom](examples/custom.svg)

### Lower level interface

If you feel uncomfortable with abusing Typst's lists like we do here, you can
also use the `pseudocode` function directly:

```typ
#pseudocode(
  [do something],
  [do something else],
  [*while* still something to do],
  indent(
    [do even more],
    [*if* not done yet *then*],
    indent(
      [wait a bit],
      [resume working],
    ),
    [*else*],
    indent(
      [go home],
    ),
    [*end*],
  ),
  [*end*],
)
```
This is equivalent to the first example.
Note that each line is given as one content argument and you indent a block by
using the `indent` function.

This approach has the advantage that you do not rely on significant whitespace
and code formatters can automatically correctly indent your Typst code.


### Line numbers

Lovelace puts a number in front of each line by default.
If you want no numbers at all, you can set the `line-numbering` option to
`none`.
The initial example then looks like this:
```typ
#pseudocode-list(line-numbering: none)[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
```

![no-number](examples/simple-no-numbers.svg)

(You can also pass this keyword argument to `pseudocode`.)

If you do want line numbers in general but need to turn them off for specific
lines, you can use `-` items instead of `+` items in `pseudocode-list`:
```typ
#pseudocode-list[
  + normal line with a number
  - this line has no number
  + this one has a number again
]
```

![number-no-number](examples/number-no-number.svg)

It's easy to remember:
`-` items usually produce unnumbered lists and `+` items produce numbered lists!

When using the `pseudocode` function, you can achieve the same using
`no-number`:
```typ
#pseudocode(
  [normal line with a number],
  no-number[this line has no number],
  [this one has a number again],
)
```

#### More line number customisation

Other than `none`, you can assign anything listed
[here](https://typst.app/docs/reference/model/numbering/#parameters-numbering)
to `line-numbering`.

So maybe you happen to think about the Roman Empire a lot and want to reflect
that in your pseudocode?
```typ
#set text(font: "Cinzel")

#pseudocode-list(line-numbering: "I:")[
  + explore European tribes
  + *while* not all tribes conquered
    + *for each* tribe *in* unconquered tribes
      + try to conquer tribe
    + *end*
  + *end*
]
```

![roman](examples/roman.svg)


### Referencing lines

You can reference an inividual line of a pseudocode by giving it a label.
Inside `pseudocode-list`, you can use `line-label`:

```typ
#pseudocode-list[
  + #line-label(<start>) do something
  + #line-label(<important>) do something important
  + go back to @start
]

The relevance of the step in @important cannot be overstated.
```

![label](examples/label.svg)

When using `pseudocode`, you can use `with-line-label`:
```typ
#pseudocode(
  with-line-label(<start>)[do something],
  with-line-label(<important>)[do something important],
  [go back to @start],
)

The relevance of the step in @important cannot be overstated.
```
This has the same effect as the previous example.

The number shown in the reference uses the numbering scheme defined in the
`line-numbering` option (see previous section).

By default, `"Line"` is used as the supplement for referencing lines.
You can change that using the `line-number-supplement` option to `pseudocode`
or `pseudocode-list`.


### Indentation guides

By default, Lovelace puts a thin gray (`gray + 1pt`) line to the left of each
indented block, which guides the reader in understanding the indentations, just
like a code editor would.
You can customise this using the `stroke` option which takes any value that is
a valid [Typst stroke](https://typst.app/docs/reference/visualize/stroke/).
You can especially set it to `none` to have no indentation guides.

The example from the beginning becomes:
```typ
#pseudocode-list(stroke: none)[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
```

![no-stroke](examples/simple-no-stroke.svg)

#### End blocks with hooks

Some people prefer using the indentation guide to signal the end of a block
instead of writing something like "**end**" by having a small "hook" at the end.
To achieve that in Lovelace, you can make use of the `hook` option and specify
how far a line should extend to the right from the indentation guide:
```typ
#pseudocode-list(hooks: .5em)[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
]
```

![hooks](examples/hooks.svg)


### Spacing

You can control how far indented lines are shifted right by the `indentation`
option.
To change the space between lines, use the `line-gap` option.
```typ
#pseudocode-list(indentation: 3em, line-gap: 1.5em)[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
```

![spacing](examples/spacing.svg)


### Decorations

You can also add a title and/or a frame around your algorithm if you like:

#### Title

Using the `title` option, you can give your pseudocode a title (surprise!).
For example, to achieve
[CLRS style](https://en.wikipedia.org/wiki/Introduction_to_Algorithms),
you can do something like
```typ
#pseudocode-list(stroke: none, title: smallcaps[Fancy-Algorithm])[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
```

![title](examples/title.svg)

#### Booktabs

If you like wrapping your algorithm in elegant horizontal lines, you can do so
by setting the `booktabs` option to `true`.
```typ
#pseudocode-list(booktabs: true)[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
```

![booktabs](examples/booktabs.svg)

Together with the `title` option, you can produce
```typ
#pseudocode-list(booktabs: true, title: [My cool title])[
  + do something
  + do something else
  + *while* still something to do
    + do even more
    + *if* not done yet *then*
      + wait a bit
      + resume working
    + *else*
      + go home
    + *end*
  + *end*
]
```

![booktabs-title](examples/booktabs-title.svg)

By default, the outer booktab strokes are `black + 2pt`.
You can change that with the option `booktabs-stroke` to any valid
[Typst stroke](https://typst.app/docs/reference/visualize/stroke/).
The inner line will always have the same stroke as the outer ones, just with
half the thickness.



### Algorithm as figure

To make algorithms referencable and being able to float in the document,
you can use Typst's `figure` function with a custom `kind`.
```typ
#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [My cool algorithm],

  pseudocode-list[
    + do something
    + do something else
    + *while* still something to do
      + do even more
      + *if* not done yet *then*
        + wait a bit
        + resume working
      + *else*
        + go home
      + *end*
    + *end*
  ]
)
```

![figure](examples/figure.svg)

If you want to have the algorithm counter inside the title instead (see previous
section), there is the option `numbered-title`:
```typ
#figure(
  kind: "algorithm",
  supplement: [Algorithm],

  pseudocode-list(booktabs: true, numbered-title: [My cool algorithm])[
    + do something
    + do something else
    + *while* still something to do
      + do even more
      + *if* not done yet *then*
        + wait a bit
        + resume working
      + *else*
        + go home
      + *end*
    + *end*
  ]
) <cool>

See @cool for details on how to do something cool.
```

![figure-title](examples/figure-title.svg)

Note that the `numbered-title` option only makes sense when nesting your
pseudocode inside a figure with `kind: "algorithm"`, otherwise it produces
undefined results.

### Customisation overview

Both `pseudocode` and `pseudocode-list` accept the following configuration
arguments:

**option** | **type** | **default**
--- | --- | ---
[`line-numbering`](#line-numbers) | `none` or a [numbering](https://typst.app/docs/reference/model/numbering/#parameters-numbering) | `"1"`
[`line-number-supplement`](#more-line-number-customisation) | content | `"Line"`
[`stroke`](#indentation-guides) | stroke | `1pt + gray`
[`hooks`](#end-blocks-with-hooks) | length | `0pt`
[`indentation`](#spacing) | length | `1em`
[`line-gap`](#spacing) | length | `.8em`
[`booktabs`](#booktabs) | bool | `false`
[`booktabs-stroke`](#booktabs) | stroke | `2pt + black`
[`title`](#title) | content or `none` | `none`
[`numbered-title`](#algorithm-as-figure) | content or `none` | `none`

Until Typst supports user defined types, we can use the following trick when
wanting to set own default values for these options.
Say, you always want your algorithms to have colons after the line numbers,
no indentation guides and, if present, blue booktabs.
In this case, you would put the following at the top of your document:
```typ
#let my-lovelace-defaults = (
  line-numbering: "1:",
  stroke: none,
  booktabs-stroke: 2pt + blue,
)

#let pseudocode = pseudocode.with(..my-lovelace-defaults)
#let pseudocode-list = pseudocode-list.with(..my-lovelace-defaults)
```

### Exported functions

Lovelace exports the following functions:

* `pseudocode`: Typeset pseudocode with each line as an individual content
  argument, see [here](#lower-level-interface) for details.
  Has [these](#customisation-overview) optional arguments.
* `pseudocode-list`: Takes a standard Typst list and transforms it into a
  pseudocode.
  Has [these](#customisation-overview) optional arguments.
* `indent`: Inside the argument list of `pseudocode`, use `indent` to specify
  an indented block, see [here](#lower-level-interface) for details.
* `no-number`: Wrap an argument to `pseudocode` in this function to have the
  corresponding line be unnumbered, see [here](#line-numbers) for details.
* `with-line-label`: Use this function in the `pseudocode` arguments to add
  a label to a specific line, see [here](#referencing-lines) for details.
* `line-label`: When using `pseudocode-list`, you do *not* use `with-line-label`
  but insert a call to `line-label` somewhere in a line to add a label, see
  [here](#referencing-lines) for details.


