// 用户输入与固定版面槽位的共用校验。
//
// 规格列出的是可填写字段，但没有把空字符串或无限长内容定义为合法输入。
// 这里优先给出带字段语义的中文诊断，避免内部类型错误或文字覆盖其它版面元素。

#let 合法题目(值) = {
  if type(值) == str {
    值.trim() != ""
  } else if type(值) == array {
    值.len() > 0 and 值.all(行 => type(行) == str and 行.trim() != "")
  } else {
    false
  }
}

#let 合法非空身份值(值) = {
  if type(值) == str {
    值.trim() != ""
  } else if type(值) == content {
    值 != []
  } else {
    false
  }
}

#let 合法作者(值) = {
  if type(值) == array {
    值.len() > 0 and 值.all(项 => 合法非空身份值(项))
  } else {
    合法非空身份值(值)
  }
}

// 页面用全角空格连接多位作者；元数据仍保留调用方的字符串数组。
#let 作者内容(值) = if type(值) == array { 值.join("　") } else { 值 }

#let 校验必填字段(info) = {
  assert(合法题目(info.at("title", default: none)),
    message: "必填字段 `title`（题目）不能为空；请填写字符串或由非空字符串组成的题目行数组。")
  assert(合法作者(info.at("author", default: none)),
    message: "必填字段 `author`（作者姓名）不能为空；支持非空字符串、富文本或它们的非空数组。")
  assert(type(info.at("student-id", default: none)) == str
      and info.student-id.trim() != "",
    message: "必填字段 `student-id`（学号）不能为空。")
}

// 用于封面、题名页和页眉等固定单行槽位。这里测量无限宽下的自然宽度，
// 超宽时拒绝编译，避免 Typst 自动折行后越过下一条固定基线。
#let 断言单行宽度(
  body,
  max-width,
  字段,
  font,
  size,
  weight: "regular",
) = context {
  let body = if body == none { "" } else { body }
  let 宽 = measure(text(font: font, size: size, weight: weight, body)).width
  assert(宽 <= max-width,
    message: 字段 + "过长（" + str(calc.round(宽 / 1pt, digits: 2))
      + "pt），超出固定版面槽位 " + str(calc.round(max-width / 1pt, digits: 2))
      + "pt；请缩短内容或改用规格允许的显式分行。")
}

// 自动折行内容必须留在相邻固定字段之间。
#let 断言块高度(body, width, max-height, 字段) = context {
  let 高 = measure(width: width, body).height
  assert(高 <= max-height,
    message: 字段 + "折行后过高（" + str(calc.round(高 / 1pt, digits: 2))
      + "pt），会覆盖下一固定字段；可用高度为 "
      + str(calc.round(max-height / 1pt, digits: 2))
      + "pt，请缩短题目或调整显式分行。")
}

// 只重建已知的文本容器；其它元素保持原样，避免把字段误当成构造参数。
#let 去除脚注元素(body) = {
  if type(body) != content { return body }
  if body.func() == footnote { return [] }
  if body.func() == ([a] + [b]).func() {
    body.children.map(去除脚注元素).join()
  } else if body.has("child") and body.has("styles") {
    body.func()(去除脚注元素(body.child), body.styles)
  } else if body.func() in (strong, emph, link) {
    let 参数 = body.fields()
    let 内容 = 去除脚注元素(参数.remove("body"))
    if body.func() == link {
      let 目的地 = 参数.remove("dest")
      body.func()(目的地, 内容, ..参数)
    } else {
      body.func()(内容, ..参数)
    }
  } else {
    body
  }
}

// context 与公式等容器可能在排版时才产生脚注，不能仅靠静态遍历。
// 目录在独立分页段内关闭注文；这里隐藏其余动态标号并抵消定义脚注的计数。
#let 去除脚注(body) = {
  show footnote: it => {
    if type(it.body) != label { counter(footnote).update(n => n - 1) }
  }
  去除脚注元素(body)
}
