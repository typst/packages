# Package IDWTET
The name `idwtet` stands for "I Don't Wanna Type Everything Twice". It provides a `typst-ex` and a `typst-ex-code` codeblock, which *shows **and** executes* typst code.

It is meant for code demonstration, e.g. when publishing a package, and provides some niceties:
- the code should always be correct in the examples: As the example code is used for the code block, but also for evaluation, there is no need to write it twice
- easy configuration with simple, uniform and good look

However, there are some limitations:
- Every code block has its own local scope and the default behaviour is that variables are not reachable from outside. A similar restriction lies on import statements. That is why, there is the `eval-scope` argument, which captures variables and simulates global variables. Additionally, a `typst` codeblock is provided for a consistent look.
- Locality can be displayed to the users by automatically wrapping code in `typst-ex-code`, but `typst-ex` does not provide such functionality. It might thus be difficult for users to understand code examples this way.
- The page width has to be defined in absolute terms. It is quite nice, for a showcase, to take the least possible space, but tracking the widths of all boxes and then setting the page width accordingly is not (yet) possible.

## Usage
Only one function is defined,
`init(body, bcolor: luma(210), inset: 5pt, border: 2pt, radius: 2pt, content-font: "linux libertine", code-font-size: 9pt, content-font-size: 11pt, code-return-box: true, wrap-code: false, eval-scope: (:), escape-bracket: "%")`,
which is supposed to be used with a show rule.

Then raw codeblocks (with `block=true`) of the languages `typst`, `typst-ex`, `typst-code` and `typst-ex-code` are modified. The main feature of this package are `typst-ex` and `typst-ex-code`. The `typst` and  `typst-code` blocks do not evaluate anything, but their design fits that of the others.

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
- `eval-scope`: A dictionary with the keys as the variable names and the values as another dictionary with keys `value` and `code`, both of these are optional. The former has the defined value, the latter the code recreate the variable, for usage in the code blocks.
- `escape-bracket`: The text to wrap a variable with, to access the `code` part of a `eval-scope` variable.

## Hiding code and replacements
There are currently two methods to change the code:
- use the `eval-scope` argument from the `init` function. There is a `code` field in the dictionaries, which enables the usage of the key escaped in `escape-bracket` to be replaced in the codeblock code half and to be removed in the codeblock result half, as the value is given via scope. Take a look at the example below, where `%ouset%` is used this way.
- use the `ENDHIDDEN` feature. When escaped in `escape-bracket`, everything above the statement is removed from the codeblock code half BUT everything (without the `ENDHIDDEN` statement) is evaluated. Take a look at the example in the examples folder.

## Example
````typst
#set page(margin: 0.5cm, width: 14cm, height: auto)
#import "@preview/idwtet:0.1.0"
#show: idwtet.init.with(eval-scope: (
  ouset: (
    value: {import "@preview/ouset:0.1.1": ouset; ouset},
    code: "#import \"@preview/ouset:0.1.1\": ouset"
  )
))

== ouset package #text(gray)[(v0.1.1)]
```typst-ex
%ouset%
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

Further examples are given in the repo example folder.