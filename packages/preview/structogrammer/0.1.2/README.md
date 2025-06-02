# [structogrammer](https://gitlab.com/czarlie/structogrammer)

Draw Nassi-Shneiderman diagrams, also called structograms, in Typst.

## Basic Usage

Import with:
```typ
#import "@preview/structogrammer:0.1.2": structogram
```

You can then draw structograms, like so:
```typ
#structogram(
  width: 30em,
  title: "merge_sort(list)",
  (
    (If: "list empty", Then: (Break: "exit (return list)")),
    "left = []",
    "right = []",
    (For: "element with index i", In: "list", Do: (
      (If: "i < list.length / 2", Then: (
        "left.add(element)"
      ), Else: (
        "right.add(element)"
      ))
    )),
    "left = merge_sort(left)",
    "right = merge_sort(right)",
    (Break: "return with merge(left, right)")
  )
)
```
which yields:<br>
![The structogram specified by the code above](https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/merge-sort.svg)

If `text.lang` is set to another language, this package will try to match inserted text to it. Currently, only `"en"` and `"de"` are supported

## Advanced usage

`structogram()` takes the following named arguments:
- `columns`:        If you already allocated wide and narrow columns, `to-elements`
                    can use them. Useful for sub-specs, as you'd usually generate
                    allocations first and then do another recursive pass to fill them. <br>
                    The default, `auto` does exactly this on the highest recursion level.
- `stroke`:         The stroke to use between cells, or for control blocks.
                    Note: to avoid duplicate strokes, every cell only adds strokes to
                    its top and left side. Put the resulting cells in a container with
                    bottom and right strokes for a finished diagram. See `structogram()`. <br>
                    Default: `0.5pt + black`
- `inset`:          How much to pad each cell. <br> Default: `0.5em`
- `segment-height`: How high each row should be. <br> Default: `2em`
- `narrow-width`:   The width that narrow columns will be. Needed for diagonals in
                    conditional blocks. <br>
                    Default: 1em

A `spec` (the positional argument to `structogram()`) can be one of the following:
- `none` or an emtpy [`array`](https://typst.app/docs/reference/foundations/array/) `()`:
  An empty cell,
  taking up at least a narrow column
- a [`string`](https://typst.app/docs/reference/foundations/str/) or [`content`](https://typst.app/docs/reference/foundations/content/):
  A cell containing that string or content,
  taking up at least a wide column
- A [`dictionary`](https://typst.app/docs/reference/foundations/dictionary/):
  Control block ([see below](#control-blocks))
- An [`array`](https://typst.app/docs/reference/foundations/array/) of specs:
  The cells that each element produced,
  stacked on top of each other. Wide columns
  are aligned to wide columns of other element
  specs and narrow columns consumed as needed.

### Control blocks

Specs can contain the following control blocks, as dictionaries:
#### 1. `If`/`Then`/`Else`:

  A conditional with the following keys:

  - `If`: The condition on which to branch
  - `Then`: A diagram spec for the "yes"-branch
  - `Else`: A diagram spec for the "no"-branch

  `Then` and `Else` are both optional, but at least one must be present

  Examples: <ul>
  <li><details>
    <summary><code>(If: "debug mode", Then: ("print debug message"))</code></summary>
    <img src="https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/if-then.svg", alt="Structogram with an if-branch that prints a debug message if the condition debug mode is met">
  </details></li>
  <li><details>
    <summary><code>(If: "x > 5", Then: ("x = x - 1", "print x"), Else: "print x")</code></summary>
    <img src="https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/if-then-else.svg", alt="Structogram with an if-branch that decrements and prints x if x is smaller than 5 or else just prints x">
  </details></li>
  </ul>

  Columns: Takes up columns according to its contents next to one another,
  inserting narrow columns for empty branches

#### 2. `For`/`Do`, `For`/`To`/`Do`, `For`/`In`/`Do`, `While`/`Do`, `Do`/`While`:

  A loop, with the loop control either at the top or bottom.

  - `For`/`Do` formats the control as "For $For",
  - `For`/`To`/`Do` as "For $For to $To",
  - `For`/`In`/`Do` as "For each $For in $In",
  - `While`/`Do` and `Do`/`While` as "While $While".

  Order of specified keys matters.

  Examples:<ul>
  <li><details>
    <summary><code>(While: "true", Do: "print \"endless loop\"")</code></summary>
    <img src="https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/while-do.svg", alt="Structogram that prints &quot;endless loop&quot; forever (while condition true). This is an entry-controlled loop">
  </details></li>
  <li><details>
    <summary><code>(Do: "print \"endless loop\"", While: "true")</code></summary>
    <img src="https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/do-while.svg", alt="Structogram that does the same but with an exit-controlled loop">
  </details></li>
  <li><details>
    <summary><code>(For: "item", In: "Container", Do: "print item.name")</code></summary>
    <img src="https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/for-in.svg", alt="Structogram that iterates over each item in a container and prints the item name">
  </details></li>
  </ul>

  Columns: Inserts a narrow column left to its content.

#### 3. Method call (`Call`)

  A block indicating that a subroutine is executed here.
  Only accepts the key `Call`, which is the string name

  Example:<ul>
  <li><details>
    <summary><code>(Call: "func()")</code></summary>
    <img src="https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/call.svg", alt="Structogram that calls the &quot;func&quot; function">
  </details></li>
  </ul>

  Columns: One wide column

#### 4. Break/Return (`Break`)

  A block indicating that a subroutine is executed here.
  Only accepts the key `Break`, which is the target to break to

  Examples:<ul>
  <li><details>
    <summary><code>(Break: "")</code></summary>
    <img src="https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/break.svg", alt="Structogram that indicates interrupting the control flow">
  </details></li>
  <li><details>
    <summary><code>(Break: "to enclosing loop")</code></summary>
    <img src="https://gitlab.com/czarlie/structogrammer/-/raw/master/examples/break-to.svg", alt="Structogram that indicates interrupting the control flow, returning to the enclosing loop">
  </details></li>
  </ul>

  Columns: One wide column
