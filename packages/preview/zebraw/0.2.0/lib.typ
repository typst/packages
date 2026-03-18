
/// Block of code with highlighted lines.
///
///
/// - highlight-lines (array): An array of line numbers to highlight, or an array of arrays with line numbers and comments.
/// - body (content): The content of the raw block.
/// - highlight-color (color): The color of the highlighted lines.
/// - inset (dictionary): The inset of the block.
/// - comment-flag (string): The comment flag.
/// - comment-font-args (dictionary): The font arguments for the comments.
/// - comment-color (color): The color of the comments.
/// -> content
#let zebraw(
  highlight-lines: (),
  body,
  highlight-color: rgb("#94e2d5").lighten(50%),
  inset: (:),
  comment-flag: ">",
  comment-font-args: (size: 8pt),
  comment-color: none,
  header: none,
  lang: true,
  footer: none,
) = {
  comment-color = if comment-color == none {
    highlight-color.lighten(50%)
  } else {
    comment-color
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
  inset = (top: 3pt, bottom: 3pt, left: 3pt, right: 3pt) + inset
  let b(..args, body) = block(
    inset: inset,
    width: 100%,
    ..args,
    body,
  )
  let g(..body) = grid(
    columns: (1em + 4pt, 1fr),
    align: (right + horizon, left),
    column-gutter: 0.7em,
    row-gutter: 0.6em,
    ..body,
  )
  show raw.where(block: true): it => {
    set par(justify: false, leading: inset.top + inset.bottom)
    block(
      fill: luma(245),
      inset: (top: 4pt, bottom: 4pt),
      radius: 4pt,
      width: 100%,
      stack(
        if header != none {
          b(
            fill: comment-color,
            context {
              g(
                columns: (auto, 1fr),
                align: (left, right),
                [
                  #h(1em)
                  #set text(..comment-font-args)
                  #text(header)
                ],
                if lang {
                  text(it.lang)
                },
              )
            },
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
                    [
                      #raw_line.text.split(regex("\S")).at(0)
                      #h(-measure(comment-flag).width)
                      #strong[#text(comment-flag, ligatures: true)]
                      #set text(..comment-font-args)
                      #text(comments.at(str(raw_line.number)))
                    ],
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
            context {
              g(
                columns: (auto, 1fr),
                align: (left, right),
                [
                  #h(1em)
                  #set text(..comment-font-args)
                  #text(footer)
                ],
              )
            },
          )
        },
      ),
    )
  }
  body
}
