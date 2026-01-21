// counter to track the number of algo elements
// used as an id when accessing:
//   _algo-comment-lists
#let _algo-id-ckey = "_algo-id"

// counter to track the number of lines in an algo element
#let _algo-line-ckey = "_algo-line"

// state value to track the current indent level in an algo element
#let _algo-indent-level = state("_algo-indent-level", 0)

// state value to track whether the current context is an algo element
#let _algo-in-algo-context = state("_algo-in-algo-context", false)

// state value for storing algo comments
// dictionary that maps algo ids (as strings) to a dictionary that maps
//   line indexes (as strings) to the comment appearing on that line
#let _algo-comment-lists = state("_algo-comment-lists", (:))

// list of default keywords that will be highlighted by strong-keywords
#let _algo-default-keywords = (
  // branch delimiters
  "if",
  "else",
  "then",

  // loop delimiters
  "while",
  "for",
  "repeat",
  "do",
  "until",

  // general delimiters
  ":",
  "end",

  // conditional expressions
  "and",
  "or",
  "not",
  "in",

  // loop conditions
  "to",
  "down",

  // misc
  "let",
  "return",
  "goto",
).map(kw => {
  // add uppercase words to list
  if kw.starts-with(regex("\w")) {
    (kw, str.from-unicode(str.to-unicode(kw.first()) - 32) + kw.slice(1))
  } else {
    (kw,)
  }
}).fold((), (acc, e) => acc + e)

// constants for measuring text height
#let _alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#let _numerals = "0123456789"
#let _special-characters = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
#let _alphanumerics = _alphabet + _numerals
#let _ascii = _alphanumerics + _special-characters


// Returns list of content values, where each element is
//   a line from the algo body
//
// Parameters:
//   body: Algorithm content.
#let _get-algo-lines(body) = {
  if not body.has("children") {
    return ()
  }

  // concatenate consecutive non-whitespace elements
  // i.e. just combine everything that definitely aren't on separate lines
  let text-and-whitespaces = {
    let joined-children = ()
    let temp = []

    for child in body.children {
      if (
        child == [ ]
        or child == linebreak()
        or child == parbreak()
      ){
        if temp != [] {
          joined-children.push(temp)
          temp = []
        }

        joined-children.push(child)
      } else {
        temp += child
      }
    }

    if temp != [] {
      joined-children.push(temp)
    }

    joined-children
  }

  // filter out non-meaningful whitespace elements
  let text-and-breaks = text-and-whitespaces.filter(
    elem => elem != [ ] and elem != parbreak()
  )

  // handling meaningful whitespace
  // make final list of empty and non-empty lines
  let lines = {
    let joined-lines = ()
    let line-parts = []
    let num-linebreaks = 0

    for elem in text-and-breaks {
      if elem == linebreak() {
        if line-parts != [] {
          joined-lines.push(line-parts)
          line-parts = []
        }

        num-linebreaks += 1

        if num-linebreaks > 1 {
          joined-lines.push([])
        }
      } else {
        line-parts += [#elem ]
        num-linebreaks = 0
      }
    }

    if line-parts != [] {
      joined-lines.push(line-parts)
    }

    joined-lines
  }

  return lines
}


// Returns list of content values, where each element is a
//   boxed clip of a line from the provided raw text
//
// Parameters:
//   raw-text: Raw text block.
//   main-text-styles: Dictionary of styling options for the source code.
//     Supports any parameter in Typst's native text function.
#let _get-code-lines(
  raw-text,
  main-text-styles,
) = {
  let line-spacing = 50pt

  let styled-raw-text = {
    set text(..main-text-styles)
    set par(leading: line-spacing)
    raw-text
  }

  let num-lines = raw-text.text.split("\n").len()

  let lines = for i in range(num-lines) {
    (style(styles => {
      let text-height = measure(
        {
          set text(..main-text-styles)
          raw(_ascii)
        },
        styles
      ).height

      let text-and-descender-height = measure(
        {
          set text(..main-text-styles)
          set text(bottom-edge: "descender")
          raw(_ascii)
        },
        styles
      ).height

      let descender-length = text-and-descender-height - text-height

      set align(start + top)
      move(
        dy: descender-length * 0.5,
        box(
          height: text-and-descender-height,
          clip: true,
          move(
            dy: -((text-height + line-spacing) * i),
            styled-raw-text
          )
        )
      )
    }), )
  }

  return lines
}


// Determines tab size being used by the given text.
// Searches for the first line that starts with whitespace and
//   returns the number of spaces the line starts with. If no
//   such line is found, -1 is returned.
//
// Parameters:
//   line-strs: Array of strings, where each string is a line from the
//     provided raw text.
#let _get-code-tab-size(line-strs) = {
  for line in line-strs {
    let starting-whitespace = line.replace(regex("\t"), "")
                                  .find(regex("^ +"))

    if starting-whitespace != none {
      return starting-whitespace.len()
    }
  }

  return -1
}


// Determines the indent level at each line of the given text.
// Returns a list of integers, where the ith integer is the indent
//   level of the ith line.
//
// Parameters:
//   line-strs: Array of strings, where each string is a line from the
//     provided raw text.
//   tab-size: tab-size used by the given code
#let _get-code-indent-levels(line-strs, tab-size) = {
  line-strs.map(line => {
    let starting-whitespace = line.replace(regex("\t"), "")
                                  .find(regex("^ +"))

    if starting-whitespace == none {
      0
    } else {
      calc.floor(starting-whitespace.len() / tab-size)
    }
  })
}


// Given data about a line in an algo or code, creates the
//   indent guides that should appear on that line.
//
// Parameters:
//   stroke: Stroke for drawing indent guides.
//   offset: Horizontal offset of indent guides.
//   indent-level: The indent level on the given line.
//   indent-size: The absolute length of a single indent.
//   row-height: The absolute height of the containing row of the given line.
//   block-inset: The absolute inset of the block containing all the lines.
//     Used when determining the length of an indent guide that appears
//     on the top or bottom of the block.
//   row-gutter: The absolute gap between lines.
//     Used when determining the length of an indent guide that appears
//     next to other lines.
//   is-first-line: Whether the given line is the first line in the block.
//   is-last-line: Whether the given line is the last line in the block.
//     If so, the length of the indent guide will depend on block-inset.
#let _indent-guides(
  stroke,
  offset,
  indent-level,
  indent-size,
  row-height,
  block-inset,
  row-gutter,
  is-first-line,
  is-last-line,
) = {
  let stroke-width = stroke.thickness

  // lines are drawn relative to the top left of the bounding box for text
  // backset determines how far up the starting point should be moved
  let backset = if is-first-line {
    0pt
  } else {
    row-gutter / 2
  }

  // determine how far the line should extend
  let stroke-length = backset + row-height + (
    if is-last-line {
      calc.min(block-inset / 2, row-height / 4)
    } else {
      row-gutter / 2
    }
  )

  // draw the indent guide for each indent level on the given line
  for j in range(indent-level) {
    box(
      height: row-height,
      width: 0pt,
      align(
        start + top,
        place(
          dx: indent-size * j + stroke-width / 2 + 0.5pt + offset,
          dy: -backset,
          line(
            length: stroke-length,
            angle: 90deg,
            stroke: stroke
          )
        )
      )
    )
  }
}


// Create indent guides for a given line of an algo element.
// Given the content of the line, calculates size of the content
//   and creates indent guides of sufficient length.
//
// Parameters:
//   indent-guides: Stroke for drawing indent guides.
//   indent-guides-offset: Horizontal offset of indent guides.
//   content: The main text that appears on the given line.
//   line-index: The 0-based index of the given line.
//   num-lines: The total number of lines in the current element.
//   indent-level: The indent level at the given line.
//   indent-size: The indent size used in the current element.
//   block-inset: The inset of the current element.
//   row-gutter: The row-gutter of the current element.
//   main-text-styles: Dictionary of styling options for the algorithm steps.
//     Supports any parameter in Typst's native text function.
//   comment-styles: Dictionary of styling options for comment text.
//     Supports any parameter in Typst's native text function.
//   line-number-styles: Dictionary of styling options for the line numbers.
//     Supports any parameter in Typst's native text function.
#let _algo-indent-guides(
  indent-guides,
  indent-guides-offset,
  content,
  line-index,
  num-lines,
  indent-level,
  indent-size,
  block-inset,
  row-gutter,
  main-text-styles,
  comment-styles,
  line-number-styles,
) = { locate(loc => style(styles => {
  let id-str = str(counter(_algo-id-ckey).at(loc).at(0))
  let line-index-str = str(line-index)
  let comment-lists = _algo-comment-lists.final(loc)
  let comment-content = comment-lists.at(id-str, default: (:))
                                      .at(line-index-str, default: [])

  // heuristically determine the height of the containing table row
  let row-height = calc.max(
    // height of main content
    measure(
      {
        set text(..main-text-styles)
        _alphanumerics
        content
      },
      styles
    ).height,

    // height of comment
    measure(
      {
        set text(..comment-styles)
        comment-content
      },
      styles
    ).height,

    // height of line numbers
    measure(
      {
        set text(..line-number-styles)
        _numerals
      },
      styles
    ).height
  )

  // converting input parameters to absolute lengths
  let indent-size-abs = measure(
    rect(width: indent-size),
    styles
  ).width

  let block-inset-abs = measure(
    rect(width: block-inset),
    styles
  ).width

  let row-gutter-abs = measure(
    rect(width: row-gutter),
    styles
  ).width

  let is-first-line = line-index == 0
  let is-last-line = line-index == num-lines - 1

  // display indent guides at the current line
  _indent-guides(
    indent-guides,
    indent-guides-offset,
    indent-level,
    indent-size-abs,
    row-height,
    block-inset-abs,
    row-gutter-abs,
    is-first-line,
    is-last-line
  )
}))}


// Create indent guides for a given line of a code element.
// Given the content of the line, calculates size of the content
//   and creates indent guides of sufficient length.
//
// Parameters:
//   indent-guides: Stroke for drawing indent guides.
//   indent-guides-offset: Horizontal offset of indent guides.
//   content: The main content that appears on the given line.
//   line-index: The 0-based index of the given line.
//   num-lines: The total number of lines in the current element.
//   indent-level: The indent level at the given line.
//   tab-size: Amount of spaces that should be considered an indent.
//   block-inset: The inset of the current element.
//   row-gutter: The row-gutter of the current element.
//   main-text-styles: Dictionary of styling options for the source code.
//     Supports any parameter in Typst's native text function.
//   line-number-styles: Dictionary of styling options for the line numbers.
//     Supports any parameter in Typst's native text function.
#let _code-indent-guides(
  indent-guides,
  indent-guides-offset,
  content,
  line-index,
  num-lines,
  indent-level,
  tab-size,
  block-inset,
  row-gutter,
  main-text-styles,
  line-number-styles,
) = { style(styles => {
  // heuristically determine the height of the line
  let row-height = calc.max(
    // height of content
    measure(
      content,
      styles
    ).height,

    // height of raw text
    measure(
      {
        set text(..main-text-styles)
        raw(_ascii)
      },
      styles
    ).height,

    // height of line numbers
    measure(
      {
        set text(..line-number-styles)
        _numerals
      },
      styles
    ).height
  )

  let indent-size = measure(
    {
      set text(..main-text-styles)
      raw("a" * tab-size)
    },
    styles
  ).width

  // converting input parameters to absolute lengths
  let block-inset-abs = measure(
    rect(width: block-inset),
    styles
  ).width

  let row-gutter-abs = measure(
    rect(width: row-gutter),
    styles
  ).width

  let is-first-line = line-index == 0
  let is-last-line = line-index == num-lines - 1

  // display indent guides at the current line
  _indent-guides(
    indent-guides,
    indent-guides-offset,
    indent-level,
    indent-size,
    row-height,
    block-inset-abs,
    row-gutter-abs,
    is-first-line,
    is-last-line
  )
})}


// Asserts that the current context is an algo element.
// Returns the provided message if the assertion fails.
#let _assert-in-algo(message) = {
  _algo-in-algo-context.display(is-in-algo => {
    assert(is-in-algo, message: message)
  })
}


// Increases indent in an algo element.
// All uses of #i within a line will be
//   applied to the next line.
#let i = {
  _assert-in-algo("algo: cannot use #i outside an algo element")
  _algo-indent-level.update(n => n + 1)
}


// Decreases indent in an algo element.
// All uses of #d within a line will be
//   applied to the next line.
#let d = {
  _assert-in-algo("algo: cannot use #d outside an algo element")

  _algo-indent-level.display(n => {
    assert(n - 1 >= 0, message: "algo: dedented too much")
  })

  _algo-indent-level.update(n => n - 1)
}


// Adds a comment to a line in an algo body.
//
// Parameters:
//   body: Comment content.
#let comment(body) = {
  _assert-in-algo("algo: cannot use #comment outside an algo element")

  locate(loc => {
    let id-str = str(counter(_algo-id-ckey).at(loc).at(0))
    let line-index-str = str(counter(_algo-line-ckey).at(loc).at(0))

    _algo-comment-lists.update(comment-lists => {
      let comments = comment-lists.at(id-str, default: (:))
      let ongoing-comment = comments.at(line-index-str, default: [])
      let comment-content = ongoing-comment + body
      comments.insert(line-index-str, comment-content)
      comment-lists.insert(id-str, comments)
      comment-lists
    })
  })
}


// Displays an algorithm in a block element.
//
// Parameters:
//   body: Algorithm content.
//   header: Algorithm header. Overrides title and parameters.
//   title: Algorithm title. Ignored if header is not none.
//   Parameters: Array of parameters. Ignored if header is not none.
//   line-numbers: Whether to have line numbers.
//   strong-keywords: Whether to have bold keywords.
//   keywords: List of terms to receive strong emphasis if
//     strong-keywords is true.
//   comment-prefix: Content to prepend comments with.
//   indent-size: Size of line indentations.
//   indent-guides: Stroke for indent guides.
//   indent-guides-offset: Horizontal offset of indent guides.
//   row-gutter: Space between lines.
//   column-gutter: Space between line numbers and text.
//   inset: Inner padding.
//   fill: Fill color.
//   stroke: Border stroke.
//   radius: Corner radius.
//   breakable: Whether the element should be breakable across pages.
//     Warning: indent guides may look off when broken across pages.
//   block-align: Alignment of block. Use none for no alignment.
//   main-text-styles: Dictionary of styling options for the algorithm steps.
//     Supports any parameter in Typst's native text function.
//   comment-styles: Dictionary of styling options for comment text.
//     Supports any parameter in Typst's native text function.
//   line-number-styles: Dictionary of styling options for the line numbers.
//     Supports any parameter in Typst's native text function.
#let algo(
  body,
  header: none,
  title: none,
  parameters: (),
  line-numbers: true,
  strong-keywords: true,
  keywords: _algo-default-keywords,
  comment-prefix: "// ",
  indent-size: 20pt,
  indent-guides: none,
  indent-guides-offset: 0pt,
  row-gutter: 10pt,
  column-gutter: 10pt,
  inset: 10pt,
  fill: rgb(98%, 98%, 98%),
  stroke: 1pt + rgb(50%, 50%, 50%),
  radius: 0pt,
  breakable: false,
  block-align: center,
  main-text-styles: (:),
  comment-styles: ("fill": rgb(45%, 45%, 45%)),
  line-number-styles: (:),
) = {
  counter(_algo-id-ckey).step()
  counter(_algo-line-ckey).update(0)
  _algo-indent-level.update(0)
  _algo-in-algo-context.update(true)

  // convert keywords to content values
  keywords = keywords.map(e => {
    if type(e) == "string" {
      [#e]
    } else {
      e
    }
  })

  let lines = _get-algo-lines(body)

  // build text, comment lists, and indent-guides
  let algo-steps = ()

  for (i, line) in lines.enumerate() {
    let formatted-line = {
      // bold keywords
      show regex("\S+"): it => {
        if strong-keywords and it in keywords {
          strong(it)
        } else {
          it
        }
      }

      _algo-indent-level.display(indent-level => {
        if indent-guides != none {
          _algo-indent-guides(
            indent-guides,
            indent-guides-offset,
            line,
            i,
            lines.len(),
            indent-level,
            indent-size,
            inset,
            row-gutter,
            main-text-styles,
            comment-styles,
            line-number-styles
          )
        }

        box(pad(
          left: indent-size * indent-level,
          line
        ))
      })

      counter(_algo-line-ckey).step()
    }

    algo-steps.push(formatted-line)
  }

  // build algorithm header
  let algo-header = if header != none {
    header
  } else {
    set align(start)

    if title != none {
      set text(1.1em)

      if type(title) == "string" {
        underline(smallcaps(title))
      } else {
        title
      }

      if parameters.len() == 0 {
        $()$
      }
    }

    if parameters != () {
      set text(1.1em)

      $($

      for (i, param) in parameters.enumerate() {
        if type(param) == "string" {
          math.italic(param)
        } else {
          param
        }

        if i < parameters.len() - 1 {
          [, ]
        }
      }

      $)$
    }

    if title != none or parameters != () {
      [:]
    }
  }

  // build table
  let algo-table = locate(loc => {
    let id-str = str(counter(_algo-id-ckey).at(loc).at(0))
    let comment-lists = _algo-comment-lists.final(loc)
    let has-comments = comment-lists.keys().contains(id-str)

    let comment-contents = if has-comments {
      let comments = comment-lists.at(id-str)

      range(algo-steps.len()).map(i => {
        let index-str = str(i)

        if index-str in comments {
          comments.at(index-str)
        } else {
          none
        }
      })
    } else {
      none
    }

    let num-columns = 1 + int(line-numbers) + int(has-comments)

    let table-align = {
      let alignments = ()

      if line-numbers {
        alignments.push(right + horizon)
      }

      alignments.push(left + bottom)

      if has-comments {
        alignments.push(left + bottom)
      }

      (x, _) => alignments.at(x)
    }

    let table-data = ()

    for (i, line) in algo-steps.enumerate() {
      if line-numbers {
        let line-number = i + 1

        table-data.push({
          set text(..line-number-styles)
          str(line-number)
        })
      }

      table-data.push({
        set text(..main-text-styles)
        line
      })

      if has-comments {
        if comment-contents.at(i) == none {
          table-data.push([])
        } else {
          table-data.push({
            set text(..comment-styles)
            comment-prefix
            comment-contents.at(i)
          })
        }
      }
    }

    table(
      columns: num-columns,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      align: table-align,
      stroke: none,
      inset: 0pt,
      ..table-data
    )
  })

  // build block
  let algo-block = block(
    width: auto,
    height: auto,
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: inset,
    outset: 0pt,
    breakable: breakable
  )[
    #set align(start + top)
    #algo-header
    #v(weak: true, row-gutter)
    #align(left, algo-table)
  ]

  // display content
  set par(justify: false)

  if block-align != none {
    align(block-align, algo-block)
  } else {
    algo-block
  }

  _algo-in-algo-context.update(false)
}


// Displays code in a block element.
//
// Parameters:
//   body: Raw text.
//   line-numbers: Whether to have line numbers.
//   indent-guides: Stroke for indent guides.
//   indent-guides-offset: Horizontal offset of indent guides.
//   tab-size: Amount of spaces that should be considered an indent.
//     Determined automatically if unspecified.
//   row-gutter: Space between lines.
//   column-gutter: Space between line numbers and text.
//   inset: Inner padding.
//   fill: Fill color.
//   stroke: Border stroke.
//   radius: Corner radius.
//   breakable: Whether the element should be breakable across pages.
//     Warning: indent guides may look off when broken across pages.
//   block-align: Alignment of block. Use none for no alignment.
//   main-text-styles: Dictionary of styling options for the source code.
//     Supports any parameter in Typst's native text function.
//   line-number-styles: Dictionary of styling options for the line numbers.
//     Supports any parameter in Typst's native text function.
#let code(
  body,
  line-numbers: true,
  indent-guides: none,
  indent-guides-offset: 0pt,
  tab-size: auto,
  row-gutter: 10pt,
  column-gutter: 10pt,
  inset: 10pt,
  fill: rgb(98%, 98%, 98%),
  stroke: 1pt + rgb(50%, 50%, 50%),
  radius: 0pt,
  breakable: false,
  block-align: center,
  main-text-styles: (:),
  line-number-styles: (:),
) = {
  if body == [] or not body.has("children") {
    return
  }

  let raw-children = body.children.filter(e => e.func() == raw)

  assert(
    raw-children.len() > 0,
    message: "algo: must provide raw text to code"
  )

  assert(
    raw-children.len() == 1,
    message: "algo: cannot pass multiple raw text blocks to code"
  )

  let raw-text = raw-children.first()
  let line-strs = raw-text.text.split("\n")

  let lines = _get-code-lines(
    raw-text,
    main-text-styles
  )

  if tab-size == auto {
    tab-size = _get-code-tab-size(line-strs)
  }

  // no indents exist, so ignore indent-guides
  let indent-levels = if tab-size == -1 {
    indent-guides = none
    none
  } else {
    _get-code-indent-levels(line-strs, tab-size)
  }

  let table-data = ()

  for (i, line) in lines.enumerate() {
    if line-numbers {
      table-data.push({
        set text(..line-number-styles)
        str(i + 1)
      })
    }

    let content = {
      if indent-guides != none {
        _code-indent-guides(
          indent-guides,
          indent-guides-offset,
          line,
          i,
          lines.len(),
          indent-levels.at(i),
          tab-size,
          inset,
          row-gutter,
          main-text-styles,
          line-number-styles
        )
      }

      box(line)
    }

    table-data.push(content)
  }

  // build block
  let code-block = block(
    width: auto,
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: inset,
    breakable: breakable
  )[
    #set align(start + top)
    #table(
      columns: if line-numbers {2} else {1},
      inset: 0pt,
      stroke: none,
      fill: none,
      row-gutter: row-gutter,
      column-gutter: column-gutter,
      align: if line-numbers {
        (x, _) => (right+horizon, left+bottom).at(x)
      } else {
        left
      },
      ..table-data
    )
  ]

  // display content
  set par(justify: false)

  if block-align != none {
    align(block-align, code-block)
  } else {
    code-block
  }
}
