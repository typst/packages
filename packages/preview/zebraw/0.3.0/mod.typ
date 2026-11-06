#let highlight-color-state = state("highlight-color", rgb("#94e2d5").lighten(50%))
#let inset-state = state("inset", (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em))
#let comment-color-state = state("comment-color", none)
#let comment-flag-state = state("comment-flag", ">")
#let comment-font-args-state = state("comment-font-args", (size: 0.8em))
#let lang-state = state("lang", true)

/// Initialize the `zebraw` block.
///
/// - highlight-color (color): The color of the highlighted lines.
/// - inset (dictionary): The inset of the block.
/// - comment-flag (string): The comment flag.
/// - comment-font-args (dictionary): The font arguments for the comments.
/// - comment-color (color): The color of the comments.
/// - lang (boolean): Whether to show the language of the block.
/// ->
#let zebraw-init(
  highlight-color: rgb("#94e2d5").lighten(50%),
  inset: (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em),
  comment-color: none,
  comment-flag: ">",
  comment-font-args: (size: 0.8em),
  lang: true,
  body,
) = context {
  highlight-color-state.update(highlight-color)
  inset-state.update(inset)
  comment-color-state.update(comment-color)
  comment-flag-state.update(comment-flag)
  comment-font-args-state.update(comment-font-args)
  lang-state.update(lang)
  body
}

/// Block of code with highlighted lines.
///
/// - highlight-lines (array): An array of line numbers to highlight, or an array of arrays with line numbers and comments.
/// - body (content): The content of the raw block.
/// - highlight-color (color): The color of the highlighted lines.
/// - inset (dictionary): The inset of the block.
/// - comment-flag (string): The comment flag.
/// - comment-font-args (dictionary): The font arguments for the comments.
/// - comment-color (color): The color of the comments.
/// - header (string): The header of the block.
/// - lang (boolean): Whether to show the language of the block.
/// - footer (string): The footer of the block.
/// -> content
#let zebraw(
  highlight-lines: (),
  body,
  highlight-color: none,
  inset: none,
  comment-flag: none,
  comment-font-args: none,
  comment-color: none,
  header: none,
  lang: none,
  footer: none,
) = context {
  // Parse the arguments.
  let highlight-color = if highlight-color == none {
    highlight-color-state.get()
  } else {
    highlight-color
  }
  let inset = if inset == none {
    inset-state.get()
  } else {
    inset-state.get() + inset
  }
  let comment-color = if comment-color == none {
    highlight-color-state.get().lighten(50%)
  } else {
    comment-color
  }
  let comment-flag = if comment-flag == none {
    comment-flag-state.get()
  } else {
    comment-flag
  }
  let comment-font-args = if comment-font-args == none {
    comment-font-args-state.get()
  } else {
    comment-font-args-state.get() + comment-font-args
  }
  let lang = if lang == none {
    lang-state.get()
  } else {
    lang
  }
  let comments = (:)
  let highlight-nums = ()
  for line in highlight-lines {
    if type(line) == int {
      highlight-nums.push(line)
    } else if type(line) == array {
      highlight-nums.push(line.at(0))
      comments.insert(str(line.at(0)), line.at(1))
    }
  }

  // Define block and grid.
  let b(..args, body) = block(
    inset: inset,
    width: 100%,
    ..args,
    body,
  )
  let g(..body) = grid(
    // stroke: black,
    columns: (1em + 0.4em, 1fr),
    align: (right + horizon, left),
    column-gutter: 0.7em,
    row-gutter: 0.6em,
    ..body,
  )

  /*
  zebraw treat a code block as:
  /----------------------------\
  |  | Header...        | lang |
  | 1| Line 1...               |
  | 2| Line 2...               |
  |  |     > Some comments...  |
  | 3| Line 3...               |
  |  | Footer...               |
  \----------------------------/
  basically each line is a block and the whole code block is stacked by these blocks.
  */


  show raw.where(block: true): it => {
    set par(justify: false, leading: inset.top + inset.bottom)
    block(
      fill: luma(245),
      inset: (top: inset.top, bottom: inset.bottom),
      radius: inset.left,
      width: 100%,
      stack(
        if header != none {
          b(
            fill: comment-color,
            g(
              columns: (1em + 0.4em, 1fr, auto),
              align: (left, left, right),
              [],
              [
                #text(..comment-font-args, header)
              ],
              if lang {
                text(..comment-font-args, it.lang)
              },
            ),
          )
        },
        ..it
          .lines
          .map(raw_line => if highlight-nums.contains(raw_line.number) {
            b(
              fill: highlight-color,
              {
                set text(fill: highlight-color.negate())
                g(
                  text([#raw_line.number]),
                  raw_line,
                )
              },
            )
            if comments.keys().contains(str(raw_line.number)) {
              v(0em, weak: true)
              b(
                fill: comment-color,
                context {
                  g(
                    [],
                    {
                      if comment-flag != "" {
                        g(
                          columns: (
                            measure(raw_line.text.split(regex("\S")).first()).width,
                            1fr,
                          ),
                          align: (right, left),
                          column-gutter: 0.34em,
                          {
                            strong[#text(ligatures: true, comment-flag)]
                            h(0.34em, weak: true)
                          },
                          text(..comment-font-args, comments.at(str(raw_line.number))),
                        )
                      } else {
                        text(..comment-font-args, comments.at(str(raw_line.number)))
                      }
                    },
                  )
                },
              )
            }
          } else {
            b(
              g(
                text(gray, [#raw_line.number]),
                raw_line,
              ),
            )
          })
          .flatten(),
        if footer != none {
          b(
            fill: comment-color,
            g(
              columns: (1em + 0.4em, 1fr),
              align: (left, left, right),
              [],
              text(..comment-font-args, footer),
            ),
          )
        },
      ),
    )
  }
  body
}
