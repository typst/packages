#import "@preview/a2c-nums:0.0.1": int-to-cn-num
#import "@preview/cuti:0.2.1": show-cn-fakebold, fakebold
#import "@preview/sourcerer:0.2.1": code
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
  代码: ("New Computer Modern Mono", "Times New Roman", "SimSun"),
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

// fake-par
#let empty-par = par[#box()]
#let fake-par = context empty-par + v(-measure(empty-par + empty-par).height)

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

// TODO: 合并以下两种下划线方式
// 下划线值
#let fieldvalue(style : ziti.宋体, size : zihao.三号, value) = [
  #set align(center + horizon)
  #set text(font: style, size:size)
  #grid(
     rows: (auto, auto),
     row-gutter: 0.3em,
     [#value],
     line(length: 100%)
  )
]

// 下划线
#let term = fieldvalue.with(style : ziti.宋体, size : zihao.四号) 

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
      ret.push(line(length: 100%, stroke: (thickness: 0.7pt)))
    }

    ret.join()
  }
}

// TODO: 优化justify-words
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

// TODO: 只加粗caption的英文
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

// TODO: 设置下划线和之前的文字底部平齐

// TODO: 调整有序列表序号的位置，使其与文字平齐

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
}
