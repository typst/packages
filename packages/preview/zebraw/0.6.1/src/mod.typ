#import "util.typ": *
#import "indentation.typ": *
#import "html.typ": zebraw-html-clipboard-copy, zebraw-html-show, zebraw-html-show-inline, zebraw-html-styles

#let zebraw-show(
  numbering: none,
  inset: none,
  radius: none,
  background-color: none,
  highlight-color: none,
  comment-color: none,
  lang-color: none,
  comment-flag: none,
  lang: none,
  comment-font-args: none,
  lang-font-args: none,
  numbering-font-args: none,
  extend: none,
  numbering-separator: none,
  hanging-indent: none,
  indentation: none,
  highlight-lines: (),
  numbering-offset: 0,
  line-range: (0, none),
  header: none,
  footer: none,
  it,
) = context {
  set par(first-line-indent: 0em)

  // Parse all arguments with state fallbacks
  let args = parse-zebraw-args(
    numbering: numbering,
    inset: inset,
    radius: radius,
    background-color: background-color,
    highlight-color: highlight-color,
    comment-color: comment-color,
    lang-color: lang-color,
    comment-flag: comment-flag,
    lang: lang,
    comment-font-args: comment-font-args,
    lang-font-args: lang-font-args,
    numbering-font-args: numbering-font-args,
    extend: extend,
    hanging-indent: hanging-indent,
    indentation: indentation,
    numbering-separator: numbering-separator,
  )

  // Extract all necessary parameters from args dictionary
  let numbering = args.numbering
  let inset = args.inset
  let radius = args.radius
  let background-color = args.background-color
  let highlight-color = args.highlight-color
  let comment-color = args.comment-color
  let lang-color = args.lang-color
  let comment-flag = args.comment-flag
  let lang = args.lang
  let comment-font-args = args.comment-font-args
  let lang-font-args = args.lang-font-args
  let numbering-font-args = args.numbering-font-args
  let extend = args.extend
  let hanging-indent = args.hanging-indent
  let indentation = args.indentation
  let fast-preview = args.fast-preview
  let numbering-separator-enabled = args.numbering-separator

  // Calculate width for line numbering using helper function
  let numbering-width = calculate-numbering-width(numbering, it.lines.len(), numbering-offset)

  // Process highlight lines, comments, and line-specific colors
  let (highlight-nums, comments, line-colors) = parse-highlight-lines(highlight-lines)

  // Setup grid helper
  let g(..args) = grid(
    columns: (numbering-width, 1fr),
    align: (right + top, left),
    ..args,
  )

  // Determine if we should show a language tab
  let has-lang = (type(lang) == bool and lang and it.lang != none) or type(lang) != bool

  // Process lines with highlighting, numbers, and comments
  let lines = process-lines(
    numbering,
    it.lines,
    highlight-nums,
    comments,
    highlight-color,
    background-color,
    comment-color,
    comment-flag,
    comment-font-args,
    numbering-offset,
    inset,
    indentation: indentation,
    is-html: false,
    line-range: line-range,
    hanging-indent: hanging-indent,
    line-colors: line-colors, // Pass line-specific colors
  )

  // Render language tab if needed
  render-lang-tab(has-lang, lang, lang-color, lang-font-args, inset, radius, it)

  // Render the code block
  block(breakable: true, radius: radius, clip: true, fill: background-color-at-index(background-color, 0), {
    context layout(code-block-size => {
      // Calculate line heights for consistent rendering
      let last-line = if lines.len() > 2 {
        if lines.last().number == none { lines.at(-2) } else { lines.last() }
      } else {
        (
          indentation: "",
          number: 2,
          body: [\ ],
          fill: white,
          comment: none,
        )
      }

      // Create line objects with their heights pre-computed
      let lines-with-height = lines.map(line => {
        let height = measure(
          g(
            render-line(
              last-line,
              is-line-number: true,
              inset: inset,
              numbering-width: numbering-width,
              numbering-font-args: numbering-font-args,
            ),
            render-line(
              line,
              is-line-number: false,
              hanging-indent: hanging-indent,
              indentation: indentation,
              inset: inset,
              fast-preview: fast-preview,
            ),
          ),
          width: code-block-size.width,
        ).height
        (line: line, height: height)
      })

      // Create the main grid structure with header, content and footer
      g(
        // 1. Header section
        ..{
          let header-cell = create-header(
            header,
            comments,
            comment-color,
            comment-font-args,
            inset,
            radius,
            has-lang,
            extend,
            background-color,
          )
          if header-cell != none { (grid.header(repeat: false, header-cell),) } else { () }
        },

        // 2. Line numbers column
        grid(
          rows: lines-with-height.map(item => item.height),
          ..lines-with-height.map(item => render-line(
            item.line,
            is-line-number: true,
            inset: inset,
            numbering-width: numbering-width,
            numbering-font-args: numbering-font-args,
          ))
        ),

        // 3. Code lines column
        grid(
          ..if numbering-separator-enabled { (stroke: (left: gray.transparentize(34%) + 0.05em)) },
          rows: lines-with-height.map(item => item.height),
          ..lines-with-height.map(item => render-line(
            item.line,
            is-line-number: false,
            height: item.height,
            hanging-indent: hanging-indent,
            indentation: indentation,
            inset: inset,
            fast-preview: fast-preview,
          ))
        ),

        // 4. Footer section
        ..{
          let footer-cell = create-footer(
            footer,
            comments,
            comment-color,
            comment-font-args,
            inset,
            radius,
            extend,
            background-color,
            lines.len(),
          )
          if footer-cell != none { (grid.footer(repeat: false, footer-cell),) } else { () }
        },
      )
    })
  })
}

/// Block of code with highlighted lines and comments.
///
/// -> content
#let zebraw(
  /// Whether to show the line numbers.
  ///
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   numbering: false,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///    )
  ///   ```
  ///  )
  /// ````,
  /// scale-preview: 100%,
  /// )
  /// -> boolean
  numbering: none,
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
  ///   ```typ
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
  /// The radius of the code block corners.
  ///
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   radius: 10pt,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%,
  /// )
  /// -> length
  radius: none,
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
  /// -> boolean | string | content
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
  /// The arguments passed to the line numbers' font.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   numbering-font-args: (fill: blue),
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
  numbering-font-args: none,
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
  /// Whether to show the numbering separator line.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   numbering-separator: true,
  ///   ```typ
  ///   #grid(
  ///      columns: (1fr, 1fr),
  ///      [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> boolean
  numbering-separator: none,
  /// Whether to show the hanging indent.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   hanging-indent: true,
  ///   ```typ
  ///   This is a short line.
  ///     Do a deer, a female deer. Ray, a drop of golden sun. Me, a name I call myself. Far, a long, long way to run. Sew, a needle pulling thread. La, a note to follow sew. Tea, a drink with jam and bread. That will bring us back to do, oh, oh, oh.
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> boolean
  hanging-indent: none,
  /// The amount of indentation, used to draw indentation lines.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   indentation: 2,
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
  /// -> int
  indentation: none,
  /// Line range to show. Accepts an array of 2 integers [a, b) or a dictionary with keys named `range` and `keep-offset`. Defaults to [1, none). (none means the last line). Noticed that the line numbers are 1-based.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   line-range: (2, 4),
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
  ///   line-range: (range: (2, 4), keep-offset: false),
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
  /// -> array | dictionary
  line-range: (1, none),
  /// (Only for HTML) The width of the code block.
  /// -> length | relative
  block-width: 42em,
  /// (Only for HTML) Whether to wrap the code lines.
  /// -> boolean
  wrap: true,
  /// (Only for HTML) Whether to show the copy button.
  /// -> boolean
  copy-button: true,
  /// The body.
  /// -> content
  body,
) = context {
  if dictionary(std).keys().contains("html") and std.target() == "html" {
    if counter("zebraw-html-styles").get() == (0,) {
      panic("HTML export requires zebraw-init. Add `#show: zebraw-init` at the beginning of your document.")
    }
    show raw: it => {
      show underline: html.elem.with("span", attrs: (class: "underline"))
      it
    }
    show raw.where(block: false): zebraw-html-show-inline.with(
      numbering: numbering,
      inset: inset,
      radius: radius,
      background-color: background-color,
      highlight-color: highlight-color,
      comment-color: comment-color,
      lang-color: lang-color,
      comment-flag: comment-flag,
      lang: lang,
      comment-font-args: comment-font-args,
      lang-font-args: lang-font-args,
      numbering-font-args: numbering-font-args,
      extend: extend,
      hanging-indent: hanging-indent,
      indentation: indentation,
      highlight-lines: highlight-lines,
      numbering-offset: numbering-offset,
      header: header,
      footer: footer,
      line-range: line-range,
      wrap: wrap,
      block-width: block-width,
      numbering-separator: numbering-separator,
      copy-button: copy-button,
    )
    show raw.where(block: true): zebraw-html-show.with(
      numbering: numbering,
      inset: inset,
      radius: radius,
      background-color: background-color,
      highlight-color: highlight-color,
      comment-color: comment-color,
      lang-color: lang-color,
      comment-flag: comment-flag,
      lang: lang,
      comment-font-args: comment-font-args,
      lang-font-args: lang-font-args,
      numbering-font-args: numbering-font-args,
      extend: extend,
      hanging-indent: hanging-indent,
      indentation: indentation,
      highlight-lines: highlight-lines,
      numbering-offset: numbering-offset,
      header: header,
      footer: footer,
      line-range: line-range,
      wrap: wrap,
      block-width: block-width,
      numbering-separator: numbering-separator,
      copy-button: copy-button,
    )

    body
  } else {
    show raw.where(block: true): zebraw-show.with(
      numbering: numbering,
      inset: inset,
      radius: radius,
      background-color: background-color,
      highlight-color: highlight-color,
      comment-color: comment-color,
      lang-color: lang-color,
      comment-flag: comment-flag,
      lang: lang,
      comment-font-args: comment-font-args,
      lang-font-args: lang-font-args,
      numbering-font-args: numbering-font-args,
      extend: extend,
      hanging-indent: hanging-indent,
      indentation: indentation,
      highlight-lines: highlight-lines,
      numbering-offset: numbering-offset,
      line-range: line-range,
      header: header,
      footer: footer,
      numbering-separator: numbering-separator,
    )

    body
  }
}
