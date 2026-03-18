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
  // Process line range
  let (start, end, keep-offset) = if type(line-range) == array {
    (line-range.at(0) - 1, if line-range.at(1) != none { line-range.at(1) - 1 } else { none }, true)
  } else if type(line-range) == dictionary {
    (
      line-range.range.at(0) - 1,
      if line-range.range.at(1) != none { line-range.range.at(1) - 1 } else { none },
      line-range.keep-offset,
    )
  } else {
    (0, none, true)
  }

  // Slice lines according to range
  let lines = lines.slice(start, end)
  let lines-result = ()

  // Process each line
  for (x, line) in lines.enumerate() {
    // Determine indentation
    let indentation = if line.text.trim() == "" {
      // For empty lines, use indentation from previous non-comment lines
      let prev-line = if x > 0 and lines-result.last().type != "comment" {
        lines-result.last()
      } else if lines-result.len() > 1 and lines-result.at(-2).type != "comment" {
        lines-result.at(-2)
      } else {
        none
      }

      if prev-line != none and prev-line.keys().contains("indentation") {
        prev-line.indentation
      } else {
        indentation * " "
      }
    } else {
      // For non-empty lines, use the leading whitespace
      line.text.split(regex("\S")).first()
    }

    // Format body
    let body = if line.text.trim() == "" { [#indentation\ ] } else { line.body }

    // Calculate line number to display
    let display-number = if numbering == true {
      if keep-offset { line.number + numbering-offset } else { line.number + numbering-offset - start }
    } else if numbering == false {
      none
    } else if type(numbering) == array {
      numbering.map(list => {
        assert(list.len() == lines.len(), message: "numbering list length should be equal to lines length")
        list.at(line.number - 1)
      })
    }

    // Process highlighted lines
    if type(highlight-nums) == array and highlight-nums.contains(line.number) {
      // Create comment if it exists for this line
      let comment = if comments.keys().contains(str(line.number)) {
        (
          type: "comment",
          indentation: line.text.split(regex("\S")).first(),
          comment-flag: comment-flag,
          body: text(..comment-font-args, comments.at(str(line.number))),
          fill: comment-color,
        )
      } else { none }

      // Add highlighted line
      lines-result.push((
        type: "highlight",
        indentation: indentation,
        number: display-number,
        body: body,
        fill: highlight-color,
        comment: if is-html { comment } else { none },
      ))

      // Add separate comment line if needed
      if not is-html and comment != none {
        lines-result.push((
          type: "comment",
          number: none,
          body: {
            if comment-flag != "" {
              indentation
              strong(text(ligatures: true, comment.comment-flag))
              h(0.35em, weak: true)
            }
            comment.body
          },
          fill: comment-color,
        ))
      }
    } else {
      // Add normal line
      lines-result.push((
        type: "normal",
        indentation: indentation,
        number: display-number,
        body: body,
        fill: curr-background-color(background-color, line.number),
        comment: none,
      ))
    }
  }

  lines-result
}
