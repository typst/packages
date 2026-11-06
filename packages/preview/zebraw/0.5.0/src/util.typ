#import "state.typ": *

#let tidy-highlight-lines(highlight-lines) = {
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

#let curr-background-color(background-color, idx) = {
  let res = if type(background-color) == color {
    background-color
  } else if type(background-color) == array {
    background-color.at(calc.rem(idx, background-color.len()))
  }
  res
}

#let tidy-lines(
  numbering,
  lines,
  highlight-nums,
  comments,
  highlight-color,
  background-color,
  comment-color,
  comment-flag,
  comment-font-args,
  numbering-offset,
  inset,
  indentation: 0,
  is-html: false,
  line-range: (1, none),
  hanging-indent: false,
) = {
  let lines-result = ()
  let (start, end, keep-offset) = if type(line-range) == array {
    (
      line-range.at(0) - 1,
      if line-range.at(1) != none {
        line-range.at(1) - 1
      } else { none },
      true,
    )
  } else if type(line-range) == dictionary {
    (
      line-range.range.at(0) - 1,
      if line-range.range.at(1) != none {
        line-range.range.at(1) - 1
      } else { none },
      line-range.keep-offset,
    )
  } else {
    (0, none, true)
  }
  let lines = lines.slice(start, end)
  for (x, line) in lines.enumerate() {
    let res = ()
    let indentation = if line.text.trim() == "" {
      if x > 0 and lines-result.last().keys().contains("indentation") and lines-result.last().type != "comment" {
        lines-result.last().indentation
      } else if (
        lines-result.at(-2).keys().contains("indentation") and lines-result.at(-2).type != "comment"
      ) {
        lines-result.at(-2).indentation
      }
    } else {
      line.text.split(regex("\S")).first()
    }
    let body = if line.text.trim() == "" {
      [#indentation\ ]
    } else {
      line.body
    }


    if (type(highlight-nums) == array and highlight-nums.contains(line.number)) {
      let comment = if comments.keys().contains(str(line.number)) {
        (
          type: "comment",
          indentation: line.text.split(regex("\S")).first(),
          comment-flag: comment-flag,
          body: text(..comment-font-args, comments.at(str(line.number))),
          fill: comment-color,
        )
      } else { none }

      res.push((
        type: "highlight",
        indentation: indentation,
        number: if numbering {
          if keep-offset {
            line.number + numbering-offset
          } else {
            line.number + numbering-offset - start
          }
        } else { none },
        body: body,
        fill: highlight-color,
        // if it's html, the comment will be saved in this field
        comment: if not is-html { none } else { comment },
      ))

      // otherwise, we need to push the comment as a separate line
      if not is-html and comment != none {
        res.push((
          type: "comment",
          number: none,
          body: if comment != none {
            if comment-flag != "" {
              indentation
              strong(text(ligatures: true, comment.comment-flag))
              h(0.35em, weak: true)
            }
            comment.body
          } else { "" },
          fill: comment-color,
        ))
      }
    } else {
      let fill-color = curr-background-color(background-color, line.number)
      res.push((
        type: "normal",
        indentation: indentation,
        number: if numbering {
          if keep-offset {
            line.number + numbering-offset
          } else {
            line.number + numbering-offset - start
          }
        } else { none },
        body: body,
        fill: fill-color,
        comment: none,
      ))
    }

    for item in res {
      lines-result.push(item)
    }
  }
  lines-result
}
