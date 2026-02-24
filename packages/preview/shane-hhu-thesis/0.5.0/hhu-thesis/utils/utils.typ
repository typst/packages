#import "@preview/a2c-nums:0.0.1": int-to-cn-num
#import "@preview/cuti:0.3.0": show-cn-fakebold, fakebold
#import "@preview/i-figured:0.2.4"

#let zihao = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let ziti = (
  仿宋: ("Times New Roman", "FangSong", "STFangSong"),
  宋体: ("Times New Roman", "SimSun"),
  黑体: ("Times New Roman", "SimHei"),
  楷体: ("Times New Roman", "KaiTi"),
  代码: ("FiraCode Nerd Font", "Times New Roman", "SimSun"),
)

// content 转换为字符串
#let to-string(content) = {
  if content == none {
    none
  } else if type(content) == str {
    content
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("child") {
    to-string(content.child)
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// part-state
#let part-state = state("part")

#let fieldname(name, bold: false) = {
  set align(right + top)
  set text(font : ziti.黑体, size : zihao.小三)
  if bold {
    strong(name)
  } else {
    name
  }
}

// 下划线
#let chineseunderline(s, width: 300pt, bold: false) = {
  // 来自 pku-thesis
  let chars = s.clusters()
  let n = chars.len()
  context {
    let i = 0
    let now = ""
    let ret = ()

    while i < n {
      let c = chars.at(i)
      let nxt = now + c

      if measure(nxt).width > width or c == "\n" {
        if bold {
          ret.push(strong(now))
        } else {
          ret.push(now)
        }
        ret.push(v(-1em))
        ret.push(line(length: 100%, stroke: (thickness: 2pt)))
        if c == "\n" {
          now = ""
        } else {
          now = c
        }
      } else {
        now = nxt
      }

      i = i + 1
    }

    if now.len() > 0 {
      if bold {
        ret.push(strong(now))
      } else {
        ret.push(now)
      }
      ret.push(v(-0.9em))
      ret.push(line(length: 100%, stroke: (thickness: 0.5pt)))
    }

    ret.join()
  }
}


#let justify-words(s, width: none) = {
  assert(type(s) == str and s.clusters().len() >= 2)
  context {
    let measure-width = measure(s).width
    let expected-width = if width == none {
      0pt
    } else if type(width) in (str, content) {
      measure(width).width.to-absolute()
    } else if type(width) == length {
      width.to-absolute()
    }
    let spacing = if measure-width > expected-width {
      0pt
    } else {
      (expected-width - measure-width) / (s.clusters().len() - 1)
    }
    text(tracking: spacing, s)
  }
}

// 圆圈序号
#let number-with-circle(
  num,
) = "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿".clusters().at(
  num - 1,
  default: "®",
)

// 标题序号显示方式
#let chinese-numbering(
  ..nums,
  location: none,
  in-appendix: false,
  brackets: false,
) = context {
  if not in-appendix {
    if nums.pos().len() == 1 {
      "第" + str(nums.pos().first()) + "章"
    } else {
      numbering(
        if brackets {
          "(1.1)"
        } else {
          "1.1"
        },
        ..nums,
      )
    }
  } else {
    if nums.pos().len() == 1 {
      "附录 " + numbering("A.1", ..nums)
    } else {
      numbering(
        if brackets {
          "(A.1)"
        } else {
          "A.1"
        },
        ..nums,
      )
    }
  }
}

// 单行公式后的段落首行缩进两字符
#let show-math-equation(eq) = {
  v(-0.4em)
  par()[#text(size:0em)[#h(0em)]]
  eq
  v(-0.4em)
  par()[#text(size:0em)[#h(0em)]]
}

// 图表后段落自动首行缩进
#let show-figure(fig) = {
  par()[#text(size:0em)[#h(0em)]]
  v(-1em)
  fig
  par()[#text(size:0em)[#h(0em)]]
  v(-1em)
}


#let show-table(caption) = {
  // 将文本转换为字符串
  let text = to-string(caption)
  for char in text {
    if char.match(regex("[A-Za-z]")) != none {
      strong(char)
    } else {
      char
    }
  }
}

// code display
#let code(
  line-spacing: 5pt,
  line-offset: 5pt,
  numbering: true,
  inset: 5pt,
  radius: 3pt,
  number-align: left,
  stroke: 1pt + luma(180),
  fill: luma(250),
  text-style: (),
  width: 100%,
  lines: auto,
  lang: none,
  lang-box: (
    gutter: 5pt,
    radius: 3pt,
    outset: 1.75pt,
    fill: rgb("#ffbfbf"),
    stroke: 1pt + rgb("#ff8a8a")
  ),
  source
) = {
  show raw.line: set text(..text-style)
  show raw: set text(..text-style)
  
  set par(justify: false, leading: line-spacing)
  
  let label-regex = regex("<((\w|_|-)+)>[ \t\r\f]*(\n|$)")

  let labels = source
    .text
    .split("\n")
    .map(line => {
      let match = line.match(label-regex)
  
      if match != none {
        match.captures.at(0)
      } else {
        none
      }
    })

  // We need to have different lines use different tables to allow for the text after the lang-box to go in its horizontal space.
  // This means we need to calculate a size for the number column. This requires AOT knowledge of the maximum number horizontal space.
  let number-style(number) = text(
    fill: stroke.paint,
    size: 1.25em,
    raw(str(number))
  )

  let unlabelled-source = source.text.replace(
    label-regex,
    "\n"
  )

  show raw.where(block: true): it => context {
    let lines = lines

    if lines == auto {
      lines = (auto, auto)
    }

    if lines.at(0) == auto {
      lines.at(0) = 1
    }

    if lines.at(1) == auto {
      lines.at(1) = it.lines.len()
    }

    lines = (lines.at(0) - 1, lines.at(1))

    let maximum-number-length = measure(number-style(lines.at(1))).width

    block(
      inset: inset,
      radius: radius,
      stroke: stroke,
      fill: fill,
      width: width,
      {
        stack(
          dir: ttb,
          spacing: line-spacing,
          ..it
            .lines
            .slice(..lines)
            .map(line => table(
              stroke: none,
              inset: 0pt,
              columns: (maximum-number-length, 1fr, auto),
              column-gutter: (line-offset, if line.number - 1 == lines.at(0) { lang-box.gutter } else { 0pt }),
              align: (number-align, left, top + right),
              if numbering {
                text(
                  fill: stroke.paint,
                  size: 1.25em,
                  raw(str(line.number))
                )
              },
              {
                let line-label = labels.at(line.number - 1)
                
                if line-label != none {
                  show figure: it => it.body
                  
                  counter(figure.where(kind: "sourcerer")).update(line.number - 1)
                  [
                    #figure(supplement: "Line", kind: "sourcerer", outlined: false, line)
                    #label(line-label)
                  ]
                } else {
                  line
                }
              },
              if line.number - 1 == lines.at(0) and lang != none {
                rect(
                  fill: lang-box.fill,
                  stroke: lang-box.stroke,
                  inset: 0pt,
                  outset: lang-box.outset,
                  radius: radius,
                  text(size: 1.25em, raw(lang))
                )
              }
            ))
            .flatten()
        )
      }
    )
  }

  raw(block: true, lang: source.lang, unlabelled-source)
  par()[#text(size:0em)[#h(0em)]]
  v(-1.2em)
}

// fit-in: Spreads out characters of a text string with flexible spacing to fit a container.
// Parameters:
// - text: The input text to spread out (string).
// Returns: A Typst content block with characters separated by flexible horizontal spacing (1fr),
// or an empty string if the input is empty.
#let fit-in(content) = {
  let chars = content.clusters()
  if chars.len() == 0 {
    return ""
  }
  let content = h(0pt)
  for i in range(chars.len()) {
    content += chars.at(i)
    if i < chars.len() - 1 {
      content += h(1fr)
    }
  }
  content += h(0pt)
  content
}

// split-and-pair-lines: Processes an array of (label, content) tuples, splitting multi-line labels and contents
// and pairing them line-by-line, padding with empty strings if uneven.
// Parameters:
// - pairs: An array of (label, content) tuples, e.g., (("ID", "123\n456"), ("Name", "John")).
// Returns: A flat array of (label, content) tuples, where each tuple represents a matched line.
// Example: (("major", "Computer Science \n and Technology")) becomes (("major", "Computer Science"), ("", "and Technology")).
#let split-and-pair-lines(pairs) = {
  let result = ()
  for pair in pairs {
    let labels = pair.at(0).split("\n")
    let contents = pair.at(1).split("\n")
    let max_lines = calc.max(labels.len(), contents.len())
    
    for i in range(max_lines) {
      result.push((
        labels.at(i, default: ""),
        contents.at(i, default: "")
      ))
    }
  }
  result
}

// create_label_content_grid: Creates a grid layout for label-content pairs, handling multi-line labels and contents.
// Each pair is split into lines and matched, with columns dynamically sized to fit the widest content.
// Parameters:
// - pairs: An array of (label, content) tuples, e.g., (("ID", "114514"), ("Grade", "2023")).
// - spacer_width: Width of the spacer column between label and content (default: 0.1em).
// - row_gutter: Vertical spacing between rows (default: 1em).
// - min_label_width: Minimum width for the label column (default: 2em).
// - min_content_width: Minimum width for the content column (default: 8em).
// - label_style: Function to style the label text (default: fit_in).
// - content_style: Function to style the content text (default: fill_in_blank).
// Returns: A grid with three columns (label, spacer, content), where column widths are dynamically adjusted.
// Panics if pairs is not an array or if any pair is not a valid (label, content) tuple.
#let label-content-grid(
  pairs,
  align: auto,
  spliter: "",
  spliter-width: 0.1em,
  row-gutter: 1em,
  min-label_width: 2em,
  min-content-width: 8em,
  label-style: (content) => [#content],
  content-style: (content) => [#content]
) = {
  // Ensure pairs is an array
  assert(type(pairs) == array, message: "pairs must be an array of (label, content) tuples")

  context {
    // Process pairs to handle multi-line labels and contents
    let processed_pairs = split-and-pair-lines(pairs)

    // Measure the width of each label and content
    let label_widths = processed_pairs.map(pair => {
      assert(type(pair) == array and pair.len() == 2, message: "Each pair must be a tuple of (label, content)")
      measure(label-style(pair.at(0))).width
    })
    let content_widths = processed_pairs.map(pair => {
      // Measure content with wrap disabled to get its full single-line width
      measure(content-style(pair.at(1))).width
    })
    
    // Convert min_label_width and min_content_width to pt
    let min_label_width_pt = measure(box(width: min-label_width)).width
    let min_content_width_pt = measure(box(width: min-content-width)).width
    let min_spliter_width_pt = measure(box(spliter)).width
    
    // Calculate maximum widths, respecting minimum defaults
    let max_label_width = calc.max(label_widths.fold(0pt, (a, b) => calc.max(a, b)), min_label_width_pt)
    let max_content_width = calc.max(content_widths.fold(0pt, (a, b) => calc.max(a, b)), min_content_width_pt)
    let max_spliter_width = calc.max(measure(box(spliter)).width, min_spliter_width_pt)
    
    // Create the grid with dynamic column widths
    grid(
      align: align,
      columns: (max_label_width, spliter-width, max_content_width),
      row-gutter: row-gutter,
      ..processed_pairs.map(pair => (
        label-style(pair.at(0)), 

        // Only the first line of labels should be followed by a spliter
        if pair.at(0) != "" {
          box(spliter)
        } else {
          box(width: 0em) // Empty box for empty labels
        },
        content-style(pair.at(1))
      )).flatten()
    )
  }
}
