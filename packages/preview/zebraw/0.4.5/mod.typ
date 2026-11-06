#import "utils.typ": *

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
  /// The offset of line numbers. The first line number will be `numbering-offset + 1`.
  /// Defaults to `0`.
  /// -> int
  numbering-offset: 0,
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
  let args = parse-zebraw-args(
    inset,
    background-color,
    highlight-color,
    comment-color,
    lang-color,
    comment-flag,
    lang,
    comment-font-args,
    lang-font-args,
    extend,
  )
  // Continue with remaining zebraw-specific logic:
  let inset = args.inset
  let background-color = args.background-color
  let highlight-color = args.highlight-color
  let comment-color = args.comment-color
  let lang-color = args.lang-color
  let comment-flag = args.comment-flag
  let lang = args.lang
  let comment-font-args = args.comment-font-args
  let lang-font-args = args.lang-font-args
  let extend = args.extend


  show raw.where(block: true): it => {
    let numbering-width = calc.max(calc.ceil(calc.log(it.lines.len() + numbering-offset)), 8 / 3) * .75em + 0.1em
    let (highlight-nums, comments) = tidy-highlight-lines(highlight-lines)
    // Define block and grid.
    let b(..args, body) = box(
      width: 100%,
      inset: inset,
      ..args,
      body,
    )
    let g(..args) = grid(
      columns: (numbering-width, 1fr),
      align: (right + top, left),
      ..args,
    )
    let has-lang = (type(lang) == bool and lang and it.lang != none) or type(lang) != bool
    // Language tab.
    if has-lang {
      // (lang == true and it.lang != none) or (lang == string | content)
      v(-.34em)
      align(
        right,
        block(
          sticky: true,
          inset: 0.34em,
          outset: (bottom: inset.left),
          radius: (top: inset.left),
          fill: lang-color,
          text(
            bottom-edge: "bounds",
            ..lang-font-args,
            if type(lang) == bool {
              it.lang
            } else {
              lang
            },
          ),
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
      {
        let line-render(line, num: false) = grid.cell(
          fill: line.fill,
          block(
            width: 100%,
            inset: inset,
            if num {
              [#(line.number)]
            } else {
              line.body
            },
          ),
        )
        let lines = tidy-lines(
          it.lines,
          highlight-nums,
          comments,
          highlight-color,
          background-color,
          comment-color,
          comment-flag,
          comment-font-args,
          numbering-offset,
          is-html: false,
        )
        context layout(code-block-size => {
          let last-line = if lines.last().number == none { lines.at(-2) } else { lines.last() }
          let heights = lines.map(line => (
            measure(g(line-render(last-line, num: true), line-render(line)), width: code-block-size.width).height
          ))
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
                        if not has-lang {
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
            grid(rows: heights, ..lines.map(line => line-render(line, num: true))),
            // Code lines.
            grid(rows: heights, ..lines.map(line => line-render(line))),
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
        })
      },
    )
  }


  body
}
