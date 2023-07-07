# Package IDWTET
The name `idwtet` stands for "I Don't Wanna Type Everything Twice". It provides a `typst-ex` codeblock, which *shows **and** executes* typst code.

It is meant for code demonstration, e.g. when publishing a package, and provides some niceties:
- the code should always be correct in the examples: As the example code is used for the code block, but also for evaluation, there is no need to write it twice
- easy configuration with simple, uniform and good look

However, there are some limitations:
- Every code block has its own local scope, hence variables are not reachable from outside. While it is easier to reason, to not have examples use global variable, you can obviously define them yourself in global scope and then access them from the code blocks. Therefore, a `typst` codeblock is provided for a consistent look.
- To express the locality (and because it is still impossible to evaluate non code), each code block starts in code mode and is also thus displayed as such. (A `#{` and a`}` are added accordingly.)
- Typst does not allow to access files with `eval`. You can type the text inside the code block, *BUT* it will be ignored. Just do the imports, probably with `*`, globally.
- The page width has to be defined in absolute terms. It is quite nice, for a showcase, to take the least possible space, but tracking the widths of all boxes and then setting the page width accordingly is not (yet) possible.

## Usage
Only one function is defined,
`init(body, bcolor: luma(210), inset: 5pt, border: 2pt, radius: 2pt)`,
which is supposed to be used with a show rule. Then raw codeblocks (with `block=true`) of the languages `typst` and `typst-ex` are modified. The latter is the mentioned main feature.
The parameters of `init` are:
- `body`: for usage with show rule, hence the whole document.
- `bcolor`: the background- (and border-) color of the blocks
- `inset`: inset param of inside blocks
- `border`: border thickness
- `radius`: block radius

## Example
````typst
#set page(margin: 0.5cm, width: 14cm, height: auto)
#import "@preview/idwtet:0.1.0"
#show: idwtet.init

== ouset package #text(gray)[(v0.1.1)]
```typst-ex
import "@preview/ouset:0.1.1": ouset
$
"Expression 1" ouset(&, <==>, "Theorem 1") "Expression 2"\
               ouset(&, ==>,, "Theorem 7") "Expression 3"
$
```
````