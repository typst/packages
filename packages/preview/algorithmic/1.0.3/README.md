<!--
SPDX-FileCopyrightText: 2023 Jade Lovelace
SPDX-FileCopyrightText: 2025 Pascal Quach
SPDX-FileCopyrightText: 2025 Typst Community
SPDX-FileCopyrightText: 2025 Contributors to the typst-algorithmic project
SPDX-License-Identifier: MIT
-->

# typst-algorithmic

This is a package inspired by the LaTeX [`algorithmicx`][algorithmicx] package
for Typst. It's useful for writing pseudocode and typesetting it all nicely.

[algorithmicx]: https://ctan.org/pkg/algorithmicx

![screenshot of the typst-algorithmic output, showing line numbers, automatic
indentation, bolded keywords, and such](https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/docs/assets/algorithmic-demo.png)

Example:

```typst
#import "@preview/algorithmic:1.0.3"
#import algorithmic: style-algorithm, algorithm-figure
#show: style-algorithm
#algorithm-figure(
  "Binary Search",
  vstroke: .5pt + luma(200),
  {
    import algorithmic: *
    Procedure(
      "Binary-Search",
      ("A", "n", "v"),
      {
        Comment[Initialize the search range]
        Assign[$l$][$1$]
        Assign[$r$][$n$]
        LineBreak
        While(
          $l <= r$,
          {
            Assign([mid], FnInline[floor][$(l + r) / 2$])
            IfElseChain(
              $A ["mid"] < v$,
              {
                Assign[$l$][$m + 1$]
              },
              [$A ["mid"] > v$],
              {
                Assign[$r$][$m - 1$]
              },
              Return[$m$],
            )
          },
        )
        Return[*null*]
      },
    )
  }
)
```

This DSL is implemented using the same trick as [CeTZ] uses: a code block of
arrays gets those arrays joined together.

[CeTZ]: https://github.com/johannes-wolf/typst-canvas

## Reference

### Documentation

#### `algorithm(inset: 0.2em, indent: 0.5em, vstroke: 0pt + luma(200), ..bits)`

This is the main function of the package. It takes a list of arrays and
returns a typesetting of the algorithm. You can modify the inset
between lines with the `inset` parameter.

```typst
#algorithm(
  inset: 1em, // more spacing between lines
  indent: 0.5em, // indentation for the algorithm
  { // provide an array
    import algorithmic: * // import all names in the array
    Assign[$x$][$y$]
  },
  { // provide another array
    import algorithmic: *
    Assign[$y$][$x$]
  },
  { // provide a third array
    import algorithmic: *
    Assign[$z$][$x + y$]
  }
)
```
![image of the algorithm with three lines of code assigning x to y, y to x, and z to x + y. The inset is set to 1em, the indent to 0.5em](https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/algorithm/ref/1.png)

#### `algorithm-figure(title, supplement: "Algorithm", inset: 0.2em, indent: 0.5em, vstroke: 0pt + luma(200), ..bits)`

The `algorithm-figure` function is a wrapper around `algorithm` that returns a
figure element of the algorithm. It takes the same parameters as
`algorithm`, but also takes a `title` and a `supplement` parameter for the figure.

```typst
#let algorithm-figure(title, supplement: "Algorithm", inset: 0.2em, indent: 0.5em, vstroke: 0pt + luma(200), ..bits) = {
  return figure(
    supplement: supplement,
    kind: "algorithm", // the kind of figure
    caption: title,
    placement: none,
    algorithm(inset: inset, ..bits),
  )
}
```

In order to use the `algorithm-figure` function, you need to style the figure
with the `style-algorithm` show rule.

```typst
#import algorithmic: algorithm-figure, style-algorithm
#show: style-algorithm // Do not forget!
#algorithm-figure("Variable Assignment", {
  import algorithmic: *
  Assign[$x$][$y$]
})
```

`style-algorithm` provides several options to customize the appearance of the algorithm figure:

- `caption-style (function): strong` is applied to the algorithm's title. Normal text can be used with `caption-style: text`, or `caption-style: c => c`.
- `caption-align (alignment): start` aligns the title to the start (left for LTR, and right for RTL languages) by default
- `breakable (bool): true` controls whether or not the figure will break across pages.
- `hlines (array of 3 content): (grid.hline(), grid.hline(), grid.hline())` provides horizontal lines at the top, middle, and bottom of the algorithm figure.

An example of how to style the algorithm figure:

```typst
#show: style-algorithm.with(
  breakable: false,
  caption-align: end,
  caption-style: emph,
  hlines: (grid.hline(stroke: 2pt + red), grid.hline(stroke: 2pt + blue), grid.hline(stroke: 2pt + green)),
)
```
which will result in something like
![image of the binary search algorithm with a right-aligned and italics figure caption enclosed within a red and blue 2pt grid horizontal lines. The algorithm is finally ended with a green 2pt horizontal line](https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/style-2/ref/1.png).

#### Control flow

Algorithmic provides basic control flow statements: `If`, `While`, `For`,
`Else`, `ElseIf`, and a `IfElseChain` utility.

<!-- Table -->
<grid>
<thead>
<tr>
<th>Statement</th>
<th>Description</th>
<th>Usage</th>
<th>Example</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>If</code></td>
<td><code>If(condition: content, ..bits)</code></td>
<td>

```typst
If($x < y$, {
  Assign[$x$][$y$]
})
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/if/ref/1.png" alt="image of an if statement with condition x < y and conditional statement assign y to x" width="500"></td>
</tr>
<tr>
<td><code>ElseIf</code></td>
<td><code>ElseIf(condition: content, ..bits)</code></td>
<td>

```typst
ElseIf($x > y$, {
  Assign[$y$][$x$]
})
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/elseif/ref/1.png" alt="image of an elseif statement with condition x > y and conditional statement assign x to y" width="500"></td>
</tr>
<tr>
<td><code>Else</code></td>
<td><code>Else(..bits)</code></td>
<td>

```typst
Else({
  Return[$y$]
})
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/else/ref/1.png" alt="image of an else statement with conditional statement return y" width="500"></td>
</tr>
<tr>
<td><code>While</code></td>
<td><code>While(condition: content, ..bits)</code></td>
<td>

```typst
While($i < 10$, {
  Assign[$i$][$i + 1$]
})
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/while/ref/1.png" alt="image of a while statement with condition i < 10 and conditional statement assign i + 1 to i" width="500"></td>
</tr>
<tr>
<td><code>For</code></td>
<td><code>For(condition: content, ..bits)</code></td>
<td>

```typst
For($i <= 10$, {
  Assign[$x_i$][$i$]
})
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/for/ref/1.png" alt="image of a for loop with condition i <= 10 and conditional statement assign i to x_i" width="500"></td>
</tr>
<tr>
<td><code>IfElseChain</code></td>
<td><code>IfElseChain(..bits)</code></td>
<td>

```typst
IfElseChain( // Alternating content and bits
  $x < y$, // If: content 1 (condition)
  { // Then: bits 1
    Assign[$x$][$y$]
  },
  [$x > y$], // ElseIf: content 2 (condition)
  { // Then: bits 2
    Assign[$y$][$x$]
  },
  Return[$y$], // Else: content 3 (no more bits afterwards)
)
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/ifelsechain/ref/1.png" alt="image of an ifelsechain statement with condition x < y and conditional statement assign y to x, then condition x" width="500"></td>
</tr>
</tbody>
</grid>

#### Commands

The package provides a few commands: `Function`, `Procedure`, `Assign`,
`Return`, `Terminate` and `Break`.

<grid>
<thead>
<tr>
<th>Command</th>
<th>Description</th>
<th>Usage</th>
<th>Example</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>Function</code></td>
<td><code>Function(name, args, ..bits)</code>
<td>

```typst
Function("Add", ($a$, $b$), {
Assign[$a$][$b$]
})
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/function/ref/1.png" alt="image of a function definition with name 'Add' and arguments 'a' and 'b' with body 'return a+b'" width="500"></td>
</tr>
<tr>
<td><code>Procedure</code></td>
<td><code>Procedure(name, args, ..bits)</code>
<td>

```typst
Procedure("Add", ("a", "b"), {
Assign[$a$][$a+b$]
})
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/procedure/ref/1.png" alt="image of a procedure definition with name 'Add' and arguments 'a' and 'b' with body 'assign a+b to a'" width="500"></td>
</tr>
<tr>
<td><code>Assign</code></td>
<td><code>Assign(var, value)</code>
<td>

```typst
Assign[$x$][$y$]
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/assign/ref/1.png" alt="image of an assignment statement assigning y to x" width="500"></td>
</tr>
<tr>
<td><code>Return</code></td>
<td><code>Return(value)</code>
<td>

```typst
Return[$x$]
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/return/ref/1.png" alt="image of a return statement returning x" width="500"></td>
</tr>
<tr>
<td><code>Terminate</code></td>
<td><code>Terminate(value)</code>
<td>

```typst
Terminate[$x$]
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/terminate/ref/1.png" alt="image of a terminate statement terminating x" width="500"></td>
</tr>
<tr>
<td><code>Break</code></td>
<td><code>Break()</code>
<td>

```typst
Break()
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/break/ref/1.png" alt="image of a break statement" width="500"></td>
</tr>
</tbody>
</grid>

Users can also define their own commands using both `Call(..args)` and
`Fn(..args)` and their inline versions `CallInline` and `FnInline`.

```typst
#import "../../algorithmic.typ"
#import algorithmic: algorithm
#set page(margin: .1cm, width: 4cm, height: auto)
#algorithm({
  import algorithmic: *
  let Solve = Call.with("Solve")
  let mean = Fn.with("mean")
  Assign($x$, Solve[$A$, $b$])
  Assign($y$, mean[$x$])
})
```
![image of a custom call "Solve" given parameters "A" and "b" and a custom function "mean" given parameter "x" in the algorithmic environment. The call "Solve" is rendered in smallcaps and the function "mean" is rendered in a strong emphasis.](https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/docs/assets/custom-call-function.png)

#### Standalone lines and line breaks

You can use `Line` to create a standalone line and `LineBreak` to insert a line break.

```typst
#algorithm({
  import algorithmic: *
  Line($1+1$)
  LineBreak
})
```
![image of a standalone line with content "1+1" and a line break in the algorithmic environment](https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/line/ref/1.png)


#### Comments

There are three kinds of comments: `Comment`, `CommentInline`, and `LineComment`.

1. `Comment` is a block comment that takes up a whole line.
2. `CommentInline` is an inline comment that returns content on the same line.
3. `LineComment` places a comment on the same line as a line of code to the right.

<grid>
<thead>
<tr>
<th>Comment</th>
<th>Description</th>
<th>Usage</th>
<th>Example</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>Comment</code></td>
<td><code>Comment(content)</code></td>
<td>

```typst
Comment[This is a comment]
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/comment/ref/1.png" alt="image of a block comment with text 'This is a comment'" width="500"></td>
</tr>
<tr>
<td><code>CommentInline</code></td>
<td><code>CommentInline(content)</code></td>
<td>

```typst
CommentInline[This is a comment]
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/commentinline/ref/1.png" alt="image of an inline comment with text 'This is a comment'" width="500"></td>
</tr>
<tr>
<td><code>LineComment</code></td>
<td><code>LineComment(line, comment)</code></td>
<td>

```typst
LineComment(Assign[a][1], [Initialize $a$ to 1])
```

</td>
<td><img src="https://raw.githubusercontent.com/typst-community/typst-algorithmic/refs/tags/v1.0.3/tests/linecomment/ref/1.png" alt="image of a line comment with text 'Initialize a to 1'" width="500"></td>
</tr>
</tbody>
</grid>
