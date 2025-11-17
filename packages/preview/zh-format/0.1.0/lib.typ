// ===========================
// 格式化工具库
// ===========================


// 粗体处理逻辑
#let setup-bold(body) = {
  show text.where(weight: "bold").or(strong): it => {
      show regex("[\p{script=Han}！-･〇-〰—]+"): cn => {
        set text(weight: "regular")
        context {
          set text(stroke: 0.02857em + text.fill)
          cn
        }
      }
      it
  }
  body
}

// 下划线处理逻辑
#let setup-underline(body) = {
  show underline: it => context {
    let line_width = measure(it.body).width
    box[
      #it.body
      #place(
        bottom + left,
        dy: 0.15em,
        line(length: line_width, stroke: 0.05em)
      )
    ]
  }
  body
}

// 自定义下划线函数(#u)：
// width 参数为必填命名参数，指定固定宽度，内容自动居中
// 使用: #u(width: )[]
#let u(width: none, offset: 0.2em, body) = {
  assert(width != none, message: "参数 width 是必填的")
  context {
    let line_width = width

    box(width: line_width)[
      #align(center, body)
      #place(
        bottom + left,
        dy: offset,
        line(length: line_width, stroke: 0.05em)
      )
    ]
  }
}

// 中文检测
#let has-chinese(content) = {
  let text-content = if type(content) == str {
    content
  } else if content.has("text") {
    content.text
  } else if content.has("body") {
    return has-chinese(content.body)
  } else if content.has("children") {
    return content.children.any(has-chinese)
  } else {
    return false
  }
  if type(text-content) == str {
    text-content.codepoints().any(c => {
      let code = str.to-unicode(c)
      code >= 0x4E00 and code <= 0x9FFF
    })
  } else {
    false
  }
}

// 斜体处理逻辑：
// - 英文：使用原生 italic
// - 空格：保持原样
// - 其他（中文、数字、符号等）：使用 skew(-18deg)倾斜
#let setup-emph(body) = {
  show emph: it => {
    let process-content(content) = {
      if type(content) == str {
        let pattern = regex("( +)|([a-zA-Z]+)|([^ a-zA-Z]+)")
        let matches = content.matches(pattern)

        matches.map(m => {
          let str = m.text
          let first-char = str.at(0)
          if first-char >= "A" and first-char <= "Z" or first-char >= "a" and first-char <= "z" {
            box(inset: 0pt, outset: 0pt, text(style: "italic")[#str])
          } else if first-char == " " {
            box(inset: 0pt, outset: 0pt, str)
          } else {
            box(skew(ax: -18deg)[#str])
          }
        }).join()
      } else if content.has("text") {
        process-content(content.text)
      } else if content.has("body") {
        process-content(content.body)
      } else if content.has("children") {
        content.children.map(process-content).join()
      } else {
        let repr-str = repr(content)
        if repr-str == "[ ]" {
          box(inset: 0pt, outset: 0pt, content)
        } else {
          content
        }
      }
    }

    if has-chinese(it.body) {
      process-content(it.body)
    } else {
      it
    }
  }
  body
}

// 统一格式化函数
#let zh-format(body) = {
  show: setup-bold
  show: setup-underline
  show: setup-emph
  body
}
