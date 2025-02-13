#set page(height: auto)

#import "src/lib.typ": *

#show raw: set text(font: "Fira Code")

#show: zebraw-init.with(
  comment-font-args: (
    font: "Fira Code",
    ligatures: true,
  ),
  lang: false,
  copyable: true,
)

#let preview(..args, body) = [
  #show: zebraw-init.with(
    comment-font-args: (
      font: "Fira Code",
      ligatures: true,
    ),
    lang: false,
    copyable: true,
  )
  #show: zebraw
  #grid(
    ..if args.pos().len() == 0 { (columns: (1fr, 1fr)) },
    ..args,
    column-gutter: 0.5em,
    block(
      stroke: gray,
      radius: 0.25em,
      width: 100%,
      inset: 0.5em,
      {
        set text(size: 0.95em)
        body
      },
    ),
    block(
      stroke: gray,
      radius: 0.25em,
      inset: 0.5em,
      eval(body.text, mode: "markup", scope: (zebraw: zebraw, zebraw-init: zebraw-init, zebraw-themes: zebraw-themes)),
    ),
  )
]

= 🦓 Zebraw

Zebraw is a lightweight and fast package for displaying code blocks with line numbers in typst, supporting code line highlighting. The term _*Zebraw*_ is a combination of _*zebra*_ and _*raw*_, for the highlighted lines will be displayed in the code block like a zebra lines.

#outline(depth: 3)

== Starting

Import `zebraw` package by ```typ #import "@preview/zebraw:0.4.0": *``` then follow with ```typ #show: zebraw``` to start using zebraw in the simplest way. To manually display some specific code blocks in zebraw, you can use ```typ #zebraw()``` function:

#preview(````typ
```typ
#grid(
  columns: (1fr, 1fr),
  [Hello], [world!],
)
```

#zebraw(
  ```typ
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)

#show: zebraw

```typ
#grid(
  columns: (1fr, 1fr),
  [Hello], [world!],
)
```
````)

#show heading.where(level: 2): it => pagebreak() + it

== Features

=== Line Highlighting

You can highlight specific lines in the code block by passing the `highlight-lines` parameter to the `zebraw` function. The `highlight-lines` parameter can be a single line number or an array of line numbers.

#preview(````typ
#zebraw(
  // Single line number:
  highlight-lines: 2,
  ```typ
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)

#zebraw(
  // Array of line numbers:
  highlight-lines: (6, 7) + range(9, 15),
  ```typ
  = Fibonacci sequence
  The Fibonacci sequence is defined through the
  recurrence relation $F_n = F_(n-1) + F_(n-2)$.
  It can also be expressed in _closed form:_

  $ F_n = round(1 / sqrt(5) phi.alt^n), quad
    phi.alt = (1 + sqrt(5)) / 2 $

  #let count = 8
  #let nums = range(1, count + 1)
  #let fib(n) = (
    if n <= 2 { 1 }
    else { fib(n - 1) + fib(n - 2) }
  )

  The first #count numbers of the sequence are:

  #align(center, table(
    columns: count,
    ..nums.map(n => $F_#n$),
    ..nums.map(n => str(fib(n))),
  ))
  ```
)
````)

=== Comment

You can add comments to the highlighted lines by passing an array of line numbers and comments to the `highlight-lines` parameter.

#preview(````typ
#zebraw(
  highlight-lines: (
    (1, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$\
    It can also be expressed in _closed form:_ $ F_n = round(1 / sqrt(5) phi.alt^n), quad
    phi.alt = (1 + sqrt(5)) / 2 $]),
    // Passing a range of line numbers in the array should begin with `..`
    ..range(9, 14),
    (13, [The first \#count numbers of the sequence.]),
  ),
  ```typ
  = Fibonacci sequence
  #let count = 8
  #let nums = range(1, count + 1)
  #let fib(n) = (
    if n <= 2 { 1 }
    else { fib(n - 1) + fib(n - 2) }
  )

  #align(center, table(
    columns: count,
    ..nums.map(n => $F_#n$),
    ..nums.map(n => str(fib(n))),
  ))
  ```
)
````)

Comments can begin with a flag, which is `">"` by default. You can change the flag by passing the `comment-flag` parameter to the `zebraw` function:

#preview(````typ
#zebraw(
  highlight-lines: (
    // Comments can only be passed when highlight-lines is an array, so at the end of the single element array, a comma is needed.
    (6, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ),
  comment-flag: "~~>",
  ```typ
  = Fibonacci sequence
  #let count = 8
  #let nums = range(1, count + 1)
  #let fib(n) = (
    if n <= 2 { 1 }
    else { fib(n - 1) + fib(n - 2) }
  )

  #align(center, table(
    columns: count,
    ..nums.map(n => $F_#n$),
    ..nums.map(n => str(fib(n))),
  ))
  ```
)
````)

To disable the flag feature, pass `""` to the `comment-flag` parameter (the indentation of the comment will be disabled as well):

#preview(````typ
#zebraw(
  highlight-lines: (
    (6, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ),
  comment-flag: "",
  ```typ
  = Fibonacci sequence
  #let count = 8
  #let nums = range(1, count + 1)
  #let fib(n) = (
    if n <= 2 { 1 }
    else { fib(n - 1) + fib(n - 2) }
  )

  #align(center, table(
    columns: count,
    ..nums.map(n => $F_#n$),
    ..nums.map(n => str(fib(n))),
  ))
  ```
)
````)

=== Header and Footer

Usually, the comments passing by a dictionary of line numbers and comments are used to add a header or footer to the code block:

#preview(````typ
#zebraw(
  highlight-lines: (
    (header: [*Fibonacci sequence*]),
    ..range(8, 13),
    // Numbers can be passed as a string in the dictionary, but it's too ugly.
    ("12": [The first \#count numbers of the sequence.]),
    (footer: [The fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ),
  ```typ
  #let count = 8
  #let nums = range(1, count + 1)
  #let fib(n) = (
    if n <= 2 { 1 }
    else { fib(n - 1) + fib(n - 2) }
  )

  #align(center, table(
    columns: count,
    ..nums.map(n => $F_#n$),
    ..nums.map(n => str(fib(n))),
  ))
  ```
)
````)

Or you can use `header` and `footer` parameters to add a header or footer to the code block:

#preview(````typ
#zebraw(
  highlight-lines: (
    ..range(8, 13),
    (12, [The first \#count numbers of the sequence.]),
  ),
  header: [*Fibonacci sequence*],
  ```typ
  #let count = 8
  #let nums = range(1, count + 1)
  #let fib(n) = (
    if n <= 2 { 1 }
    else { fib(n - 1) + fib(n - 2) }
  )

  #align(center, table(
    columns: count,
    ..nums.map(n => $F_#n$),
    ..nums.map(n => str(fib(n))),
  ))
  ```,
  footer: [The fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$],
)
````)

=== Language Tab

If `lang` is set to `true`, then there will be a language tab on the top right corner of the code block:

#preview(````typ
#zebraw(
  lang: true,
  ```typst
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)
````)

=== Copyable

If `copyable` is set to `true`, line numbers will not be copied when copying exported code.

#preview(````typ
#zebraw(
  copyable: true,
  ```typst
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)
````)

For comparison:

#grid(
  columns: 2,
  align: center,
  row-gutter: .5em,
  column-gutter: .5em,
  grid.header([`copyable: false`], [`copyable: true`]),
  image("assets/copyable-false.png"), image("assets/copyable-true.png"),
)

However when a code block is `copyable`, it won't be able to cross page. Only line numbers will be excluded for being selected.

=== Theme

PRs are welcome!

#preview(````typ
#show: zebraw-init.with(..zebraw-themes.zebra, lang: false)
#show: zebraw

```rust
pub fn fibonacci_reccursive(n: i32) -> u64 {
    if n < 0 {
        panic!("{} is negative!", n);
    }
    match n {
        0 => panic!("zero is not a right argument to fibonacci_reccursive()!"),
        1 | 2 => 1,
        3 => 2,
        _ => fibonacci_reccursive(n - 1) + fibonacci_reccursive(n - 2),
    }
}
```
````)

#preview(````typ
#show: zebraw-init.with(..zebraw-themes.zebra-reverse, lang: false)
#show: zebraw

```rust
pub fn fibonacci_reccursive(n: i32) -> u64 {
    if n < 0 {
        panic!("{} is negative!", n);
    }
    match n {
        0 => panic!("zero is not a right argument to fibonacci_reccursive()!"),
        1 | 2 => 1,
        3 => 2,
        _ => fibonacci_reccursive(n - 1) + fibonacci_reccursive(n - 2),
    }
}
```
````)

== Customization

There are 3 ways to customize code blocks in your document:

- Manually render some specific blocks by ```typ #zebraw()``` function and passing parameters to it.
- By passing parameters to ```typ #show: zebraw.with()``` will affect every raw block after the ```typ #show``` rule, *except* blocks created manually by ```typ #zebraw()``` function.
- By passing parameters to ```typ #show: zebraw-init.with()``` will affect every raw block after the ```typ #show``` rule, *including* blocks created manually by ```typ #zebraw()``` function. By using `zebraw-init` without any parameters, the values will be reset to default.


=== Inset

Customize the inset of each line by passing a #dictionary to the `inset` parameter:

#preview(````typ
#zebraw(
  inset: (top: 6pt, bottom: 6pt),
  ```typ
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)
````)

=== Colors

Customize the background color by passing a #color or an #array of #color#[s] to the `background-color` parameter.

#preview(````typ
#zebraw(
  background-color: luma(235),
  ```typ
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```,
)

#zebraw(
  background-color: (luma(235), luma(245), luma(255)),
  ```typ
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```,
)
````)

Customize the highlight color by passing a #color to the `highlight-color` parameter:

#preview(````typ
#zebraw(
  highlight-lines: 1,
  highlight-color: blue.lighten(90%),
  ```text
  I'm so blue!
              -- George III
  ```,
)
````)

Customize the comments' background color by passing a #color to the `comment-color` parameter:

#preview(````typ
#zebraw(
  highlight-lines: (
    (2, "auto indent!"),
  ),
  comment-color: yellow.lighten(90%),
  ```text
  I'm so blue!
              -- George III
  I'm not.
              -- Hamilton
  ```,
)
````)

Customize the language tab's background color by passing a #color to the `lang-color` parameter.

#preview(````typ
#zebraw(
  lang: true,
  lang-color: teal,
  ```typst
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)
````)

=== Font

To customize the arguments of comments' font and the language tab's font, pass a dictionary to `comment-font-args` parameter and `lang-font-args` parameter.

Language tab will be rendered as comments if nothing is passed.

#preview(````typ
#zebraw(
  highlight-lines: (
    (2, "columns..."),
  ),
  lang: true,
  comment-color: white,
  comment-font-args: (
    font: "IBM Plex Sans",
    style: "italic"
  ),
  ```typst
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)
````)

#preview(````typ
#zebraw(
  highlight-lines: (
    (2, "columns..."),
  ),
  lang: true,
  lang-color: eastern,
  lang-font-args: (
    font: "libertinus serif",
    weight: "bold",
    fill: white,
  ),
  comment-font-args: (
    font: "IBM Plex Sans",
    style: "italic"
  ),
  ```typst
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)
````)

=== Extend

Extend at vertical is enabled at default. When there's header or footer it will be automatically disabled.

#preview(````typ
#zebraw(
  extend: false,
  ```typst
  #grid(
    columns: (1fr, 1fr),
    [Hello], [world!],
  )
  ```
)
````)

== Documentation

The default value of most parameters are `none` for it will use the default value in `zebraw-init`.

#import "@preview/tidy:0.4.1"
#let docs = tidy.parse-module(read("src/mod.typ"), scope: (zebraw: zebraw))
#tidy.show-module(docs, style: tidy.styles.default, sort-functions: false)

#show: zebraw-init

== Example

#zebraw(
  highlight-lines: (
    (3, [to avoid negative numbers]),
    (9, "50 => 12586269025"),
  ),
  lang: true,
  header: "Calculate Fibonacci number using reccursive function",
  ```rust
  pub fn fibonacci_reccursive(n: i32) -> u64 {
      if n < 0 {
          panic!("{} is negative!", n);
      }
      match n {
          0 => panic!("zero is not a right argument to fibonacci_reccursive()!"),
          1 | 2 => 1,
          3 => 2,
          _ => fibonacci_reccursive(n - 1) + fibonacci_reccursive(n - 2),
      }
  }
  ```,
)
