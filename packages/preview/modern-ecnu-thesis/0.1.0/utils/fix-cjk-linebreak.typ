/*
 * fix-cjk-linebreak.typ
 *
 * @project: modern-ecnu-thesis
 * @author: Juntong Chen (dev@jtchen.io)
 * @created: 2025-01-12 15:12:15
 * @modified: 2025-01-12 22:12:32
 *
 * Copyright (c) 2025 Juntong Chen. All rights reserved.
 */

// 截止 Typst 0.12.0 版本，CJK 字符的换行处理还不够完善，可能会插入不必要的空格。这里提供一个 workaround。
//    详见：https://github.com/typst/typst/issues/792#issuecomment-2310139085
#let fix-cjk-linebreak(body, debug: false) = [
  // 不去除章后的字符
  #let cjk-char = "[\p{Han}，。；：！？‘’“”（）「」【】…—&&[^章节]]"
  // 没有使用 \s 来匹配空白字符的原因是为了保留全角空格。
  #let cjk-re = regex("(" + cjk-char + ")([ \\t\\r]+(" + cjk-char + ")+)+")
  #show cjk-re: it => {
    if debug {
      highlight(fill: color.red, it.text)
    } else {
      it.text.replace(regex("[ \\t\\r]+"), "")
    }
  }
  #show: rest => {
    let ends-with-cjk = it => {
      it != none and it.has("text") and it.text.ends-with(regex(cjk-char))
    }
    let last-item = none
    for item in rest.children {
      if item == [ ] and ends-with-cjk(last-item) {
        item = []
      }
      last-item = item
      item
    }
  }
  #body
]