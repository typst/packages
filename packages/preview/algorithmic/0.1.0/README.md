<!--
SPDX-FileCopyrightText: 2023 Jade Lovelace

SPDX-License-Identifier: MIT
-->

# typst-algorithmic

This is a package inspired by the LaTeX [`algorithmicx`][algorithmicx] package
for Typst. It's useful for writing pseudocode and typesetting it all nicely.

[algorithmicx]: https://ctan.org/pkg/algorithmicx

![screenshot of the typst-algorithmic output, showing line numbers, automatic
indentation, bolded keywords, and such](./docs/assets/demo-rendered.png)

Example:

```typst
#import "@preview/algorithmic:0.1.0"
#import algorithmic: algorithm

#algorithm({
  import algorithmic: *
  Function("Binary-Search", args: ("A", "n", "v"), {
    Cmt[Initialize the search range]
    Assign[$l$][$1$]
    Assign[$r$][$n$]
    State[]
    While(cond: $l <= r$, {
      Assign([mid], FnI[floor][$(l + r)/2$])
      If(cond: $A ["mid"] < v$, {
        Assign[$l$][$m + 1$]
      })
      ElsIf(cond: [$A ["mid"] > v$], {
        Assign[$r$][$m - 1$]
      })
      Else({
        Return[$m$]
      })
    })
    Return[*null*]
  })
})
```

This DSL is implemented using the same trick as [CeTZ] uses: a code block of
arrays gets those arrays joined together.

[CeTZ]: https://github.com/johannes-wolf/typst-canvas

Currently this library is not really customizable. Please vendor it and hack it
up as needed then file an issue for the customization option you're missing.

## Reference

#### stmt

Statement-level contexts in `algorithmic` generally accept the type `body` in
the following:

```
body = (ast|content)[] | ast | content
ast = (change_indent: int, body: body)
```

#### inline

Inline functions will generate plain content.

#### `algorithmic(..bits)`

Takes one or more lists of `ast` and creates an algorithmic block with line
numbers.

### Control flow

#### `Function`/`Procedure` (stmt)

Defined as `f(name: string|content, args: content[]?, ..body)`. Body can be one or more `body`
values.

#### `If`/`ElseIf`/`Else`/`For`/`While` (stmt)

Defined as `f(cond: string|content, ..body)`. Body can be one or more `body`
values.

Generates an indented block with the body, and the specified `cond` between the
two keywords as condition.

### Statements

#### `Assign` (stmt)

Defined as `Assign(var: content, val: content)`.

Generates `#var <- #val`.

#### `CallI` (inline), `Call` (stmt)

Defined as `f(name, args: content|content[])`.

Calls a function with the function name styled in smallcaps and the args joined by
commas.

#### `Cmt` (stmt)

Defined as `Cmt(body: content)`.

Makes a line comment.

#### `FnI` (inline), `Fn` (stmt)

Defined as `f(name, args: content|content[])`.

Calls a function with the function name styled in bold and the args joined by
commas.

#### `Ic` (inline)

Defined as `Ic(body: content) -> content`.

Makes an inline comment.

#### `Return` (stmt)

Defined as `Return(arg: content)`.

Generates `return #arg`.

#### `State` (stmt)

Defined as `State(body: content)`.

Turns any content into a line.
