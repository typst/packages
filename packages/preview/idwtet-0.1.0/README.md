# Package IDWTET
The name `idwtet` stands for "I Don't Wanna Type Everything Twice". It provides a `typst-ex` and a `typst-ex-code` codeblock, which *shows **and** executes* typst code.

It is meant for code demonstration, e.g. when publishing a package, and provides some niceties:
- the code should always be correct in the examples: As the example code is used for the code block, but also for evaluation, there is no need to write it twice
- easy configuration with simple, uniform and good look

However, there are some limitations:
- Every code block has its own local scope, hence variables are not reachable from outside. While it is easier to reason, to not have examples use global variable, you can obviously define them yourself in global scope and then access them from the code blocks. Therefore, a `typst` codeblock is provided for a consistent look.
- Locality can be displayed to the users by automatically wrapping code in `typst-ex-code`, but `typst-ex` does not provide such functionality. It might thus be difficult for users to understand code examples this way.
- Typst does not allow `eval` to access outside variables nor does it allow to access files through it. Hence, all code inside should be self-contained. However, depending on what typst allows in later version, you could then:
  - If being able to access globals through eval without specification,type the text inside the code block, *BUT* it will be ignored. Just do the imports, probably with `*`, globally.
  - Does allow for eval to access everything, then a update to a new version of this package, if available.
  - ..., maybe a later version of this package can help. One could in the end, pass all code to the eval, but then only display the relevant one.
- The page width has to be defined in absolute terms. It is quite nice, for a showcase, to take the least possible space, but tracking the widths of all boxes and then setting the page width accordingly is not (yet) possible.

## Usage
Only one function is defined,
`init(body, bcolor: luma(210), inset: 5pt, border: 2pt, radius: 2pt, content-font: "linux libertine", code-font-size: 9pt, content-font-size: 11pt, code-return-box: true, wrap-code: false)`,
which is supposed to be used with a show rule. Then raw codeblocks (with `block=true`) of the languages `typst`, `typst-ex`, `typst-code` and `typst-ex-code` are modified. The main feature of this package are `typst-ex` and `typst-ex-code`.

The parameters of `init` are:
- `body`: for usage with show rule, hence the whole document.
- `bcolor`: the background- (and border-) color of the blocks
- `inset`: inset param of code and content blocks, should be ≥ 2pt
- `border`: border thickness
- `radius`: block radius
- `content-font`: The font used in the previewed content / result.
- `code-font-size`: The fontsize used in the code blocks.
- `content-font-size`: The fontsize used in the preview content / result.
- `code-return-box`: If to show the code return type on `typst-ex-code` blocks.
- `wrap-code`: If to wrap the code in `#{` and `}`, to symbolize local scope.

## Example
````typst
#set page(margin: 0.5cm, width: 14cm, height: auto)
#import "@preview/idwtet:0.1.0"
#show: idwtet.init

== ouset package #text(gray)[(v0.1.1)]
```typst-ex
#import "@preview/ouset:0.1.1": ouset
$
"Expression 1" ouset(&, <==>, "Theorem 1") "Expression 2"\
               ouset(&, ==>,, "Theorem 7") "Expression 3"
$
```
Or something like
```typst-ex-code
let a = range(10)
a
```
````