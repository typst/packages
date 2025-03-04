#let background-color-state = state("zebraw-background-color", luma(245))
#let highlight-color-state = state("zebraw-highlight-color", rgb("#94e2d5").lighten(70%))
#let inset-state = state("zebraw-inset", (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em))
#let comment-color-state = state("zebraw-comment-color", none)
#let lang-color-state = state("zebraw-lang-color", none)
#let comment-flag-state = state("zebraw-comment-flag", ">")
#let comment-font-args-state = state("zebraw-comment-font-args", (:))
#let lang-state = state("zebraw-lang", true)
#let lang-font-args-state = state("zebraw-lang-font-args", (:))
#let extend-state = state("zebraw-extend", true)
#let block-args-state = state("zebraw-block-args", (:))
#let grid-args-state = state("zebraw-grid-args", (:))

/// Initialize the `zebraw` block in global.
/// -> content
#let zebraw-init(
  /// The inset of each line.
  /// -> dictionary
  inset: (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em),
  /// The background color of the block and normal lines.
  /// -> color | array
  background-color: luma(245),
  /// The background color of the highlighted lines.
  /// -> color
  highlight-color: rgb("#94e2d5").lighten(70%),
  /// The background color of the comments. When it's set to `none`, it will be rendered in a lightened `highlight-color`.
  /// -> color
  comment-color: none,
  /// The background color of the language tab. The color is set to `none` at default and it will be rendered in comments’ color.
  /// -> color
  lang-color: none,
  /// The flag at the beginning of comments.
  /// -> string | content
  comment-flag: ">",
  /// Whether to show the language tab, or a string or content of custom language name to display.
  /// -> boolean | string | content
  lang: true,
  /// The arguments passed to comments' font.
  /// -> dictionary
  comment-font-args: (:),
  /// The arguments passed to the language tab's font.
  /// -> dictionary
  lang-font-args: (:),
  /// Whether to extend the vertical spacing.
  /// -> boolean
  extend: true,
  /// The body
  /// -> content
  body,
) = context {
  inset-state.update(inset)

  background-color-state.update(background-color)
  highlight-color-state.update(highlight-color)
  comment-color-state.update(comment-color)
  lang-color-state.update(lang-color)

  comment-flag-state.update(comment-flag)
  lang-state.update(lang)

  comment-font-args-state.update(comment-font-args)
  lang-font-args-state.update(lang-font-args)

  extend-state.update(extend)

  body
}

/// Block of code with highlighted lines and comments.
///
/// -> content
#let zebraw(
  /// Lines to highlight or comments to show.
  ///
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   highlight-lines: range(3, 7),
  ///   header: [*Fibonacci sequence*],
  ///   ```typst
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```,
  ///   footer: [The fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$],
  /// )
  /// ````,
  /// scale-preview: 100%,
  /// )
  ///
  /// -> array | int
  highlight-lines: (),
  /// The header of the code block.
  ///
  /// -> string | content
  header: none,
  /// The footer of the code block.
  ///
  /// -> string | content
  footer: none,
  /// The inset of each line.
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   inset: (top: 6pt, bottom: 6pt),
  ///   ```typst
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```,
  /// )
  /// ````,
  /// scale-preview: 100%,
  /// )
  /// -> dictionary
  inset: none,
  /// The background color of the block and normal lines.
  ///
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   background-color: (luma(240), luma(245), luma(250), luma(245)),
  ///   ```typst
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```,
  /// )
  /// ````,
  /// scale-preview: 100%,
  /// )
  /// -> color | array
  background-color: none,
  /// The background color of the highlighted lines.
  ///
  /// -> color
  highlight-color: none,
  /// The background color of the comments. The color is set to `none` at default and it will be rendered in a lightened `highlight-color`.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   highlight-color: yellow.lighten(80%),
  ///   comment-color: yellow.lighten(90%),
  ///   highlight-lines: (
  ///     (1, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ///     ..range(9, 14),
  ///     (13, [The first \#count numbers of the sequence.]),
  ///   ),
  ///   ```typ
  ///   = Fibonacci sequence
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> color
  comment-color: none,
  /// The background color of the language tab. The color is set to `none` at default and it will be rendered in comments' color.
  /// #example(````typ
  /// #zebraw(
  ///   lang: true,
  ///   lang-color: eastern,
  ///   lang-font-args: (
  ///     font: "libertinus serif",
  ///     weight: "bold",
  ///     fill: white
  ///   ),
  ///   ```typst
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  /// -> color
  lang-color: none,
  /// The flag at the beginning of comments. The indentation of codes will be rendered before the flag. When the flag is set to `""`, the indentation before the flag will be disabled as well.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   comment-flag: "",
  ///   highlight-lines: (
  ///     (1, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ///     ..range(9, 14),
  ///     (13, [The first \#count numbers of the sequence.]),
  ///   ),
  ///   ```typ
  ///   = Fibonacci sequence
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> string | content
  comment-flag: none,
  /// Whether to show the language tab, or a string or content of custom language name to display.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   lang: true,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// #example(````typ
  /// #zebraw(
  ///   lang: strong[Typst],
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> boolean | string
  lang: none,
  /// The arguments passed to comments' font.
  ///
  /// -> dictionary
  comment-font-args: none,
  /// The arguments passed to the language tab's font.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   lang: true,
  ///   comment-font-args: (font: "IBM Plex Serif", style: "italic"),
  ///   lang-font-args: (font: "IBM Plex Sans", weight: "bold"),
  ///   highlight-lines: (
  ///     (1, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ///     ..range(9, 14),
  ///     (13, [The first \#count numbers of the sequence.]),
  ///   ),
  ///   ```typ
  ///   = Fibonacci sequence
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> dictionary
  lang-font-args: none,
  /// Whether to extend the vertical spacing.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   extend: false,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> boolean
  extend: none,
  /// The body.
  /// -> content
  body,
) = context {
  // Parse the arguments.
  let inset = if inset == none {
    inset-state.get()
  } else {
    inset-state.get() + inset
  }

  let background-color = if background-color == none {
    background-color-state.get()
  } else {
    background-color
  }
  let highlight-color = if highlight-color == none {
    highlight-color-state.get()
  } else {
    highlight-color
  }
  let comment-color = if comment-color == none {
    if comment-color-state.get() == none { highlight-color-state.get().lighten(50%) } else { comment-color-state.get() }
  } else {
    comment-color
  }
  let lang-color = if lang-color == none {
    if lang-color-state.get() == none { comment-color } else { lang-color-state.get() }
  } else { lang-color }

  let comment-flag = if comment-flag == none {
    comment-flag-state.get()
  } else {
    comment-flag
  }
  let lang = if lang == none {
    lang-state.get()
  } else {
    lang
  }

  let comment-font-args = if comment-font-args == none {
    comment-font-args-state.get()
  } else {
    comment-font-args-state.get() + comment-font-args
  }
  let lang-font-args = if lang-font-args == none {
    lang-font-args-state.get()
  } else {
    lang-font-args-state.get() + lang-font-args
  }

  let extend = if extend == none {
    extend-state.get()
  } else {
    extend
  }

  let (highlight-nums, comments) = {
    let nums = ()
    let comments = (:)
    let lines = if type(highlight-lines) == int {
      (highlight-lines,)
    } else if type(highlight-lines) == array {
      highlight-lines
    }
    for line in lines {
      if type(line) == int {
        nums.push(line)
      } else if type(line) == array {
        nums.push(line.first())
        comments.insert(str(line.at(0)), line.at(1))
      } else if type(line) == dictionary {
        if not (line.keys().contains("header") or line.keys().contains("footer")) {
          nums.push(int(line.keys().first()))
        }
        comments += line
      }
    }
    (nums, comments)
  }

  let curr-background-color(background-color, idx) = {
    let res = if type(background-color) == color {
      background-color
    } else if type(background-color) == array {
      background-color.at(calc.rem(idx, background-color.len()))
    }
    res
  }

  // Define block and grid.
  let b(..args, body) = box(
    width: 100%,
    inset: inset,
    ..args,
    body,
  )
  let g(..args) = grid(
    columns: (2.1em, 1fr),
    align: (right + top, left),
    ..args,
  )


  show raw.where(block: true): it => {
    // Language tab.
    if lang != false {
      v(-.34em)
      align(
        right,
        block(
          sticky: true,
          inset: 0.34em,
          outset: (bottom: inset.left),
          radius: (top: inset.left),
          fill: lang-color,
          text(bottom-edge: "bounds", ..lang-font-args, if type(lang) == bool { it.lang } else { lang }),
        ),
      )
      v(0em, weak: true)
    }

    // The code block.
    block(
      breakable: true,
      radius: inset.left,
      clip: true,
      fill: curr-background-color(background-color, 0),
      context layout(code-block-size => {
        let line-render(line, height: none, num: false) = block(
          width: 100%,
          inset: inset,
          if num {
            let lb = measure(
              g(line-render((body: [#line.number], fill: none))),
              width: code-block-size.width,
            ).height
            let cnt = calc.ceil(height / lb) - 1
            let number = (
              [#if line.keys().contains("comment") { text(fill: line.fill, [#line.number]) } else { line.number }]
                + [\ #text(fill: line.fill, [#line.number])] * cnt
            )
            let rem = (
              height - measure(g(line-render((body: number, fill: none))), width: code-block-size.width).height
            )
            (
              if line.keys().contains("comment") {
                set text(fill: line.fill)
                number
              } else {
                number
              }
                + v(rem)
            )
          } else {
            if line.body == [] { linebreak() } else { line.body }
          },
          fill: line.fill,
        )

        let get-height(line) = measure(g([], line-render(line)), width: code-block-size.width).height


        let lines = it
          .lines
          .map(line => {
            let res = ()
            if (type(highlight-nums) == array and highlight-nums.contains(line.number)) {
              // Highlight lines.
              res.push((
                number: line.number,
                body: {
                  set text(fill: highlight-color.negate().transparentize(12.5%))
                  line
                },
                fill: highlight-color,
              ))

              // Comments.
              if comments.keys().contains(str(line.number)) {
                res.push((
                  number: line.number,
                  comment: true,
                  body: {
                    if comment-flag != "" {
                      box(line.text.split(regex("\S")).first())
                      {
                        strong(text(ligatures: true, comment-flag))
                        h(0.35em, weak: true)
                      }
                      text(..comment-font-args, comments.at(str(line.number)))
                    } else {
                      text(..comment-font-args, comments.at(str(line.number)))
                    }
                  },
                  fill: comment-color,
                ))
              }
            } else {
              // Default lines.
              let fill-color = curr-background-color(background-color, line.number)
              res.push((
                number: line.number,
                body: line.body,
                fill: fill-color,
              ))
            }
            res
          })
          .flatten()

        let heights = lines
          .map(line => measure(g([], line-render(line)), width: code-block-size.width).height)
          .map(height => if height < 1em.to-absolute() { 1em.to-absolute() } else { height })

        g(
          // Header.
          ..if header != none or comments.keys().contains("header") {
            (
              grid.header(
                repeat: false,
                grid.cell(
                  align: left + top,
                  colspan: 2,
                  b(
                    inset: inset.pairs().map(((key, value)) => (key, value * 2)).to-dict(),
                    radius: {
                      if not lang {
                        (top: inset.left)
                      } else {
                        (top-left: inset.left)
                      }
                    },
                    fill: comment-color,
                    {
                      text(..comment-font-args, if header != none { header } else { comments.at("header") })
                    },
                  ),
                ),
              ),
            )
          } else if extend {
            (
              grid.header(
                repeat: true,
                grid.cell(
                  colspan: 2,
                  b(
                    fill: curr-background-color(background-color, 0),
                    inset: (:) + (top: inset.top),
                    radius: (top: inset.left),
                    [],
                  ),
                ),
              ),
            )
          },
          // Line numbers.
          stack(..lines.map(line => line-render(line, height: get-height(line), num: true))),
          // Code lines.
          stack(..lines.map(line => line-render(line, height: get-height(line)))),
          // Footer.
          ..if footer != none or comments.keys().contains("footer") {
            (
              grid.footer(
                repeat: false,
                grid.cell(
                  align: left + top,
                  colspan: 2,
                  b(
                    inset: inset.pairs().map(((key, value)) => (key, value * 2)).to-dict(),
                    radius: (bottom: inset.left),
                    fill: comment-color,
                    text(..comment-font-args, if footer != none { footer } else { comments.at("footer") }),
                  ),
                ),
              ),
            )
          } else if extend {
            (
              grid.footer(
                repeat: true,
                grid.cell(
                  colspan: 2,
                  b(
                    fill: curr-background-color(background-color, lines.len() + 1),
                    inset: (:) + (bottom: inset.bottom),
                    radius: (bottom: inset.left),
                    [],
                  ),
                ),
              ),
            )
          },
        )
      }),
    )
  }

  body
}
