/*
 * str.typ
 *
 * @project: modern-ecnu-thesis
 * @author: Juntong Chen (dev@jtchen.io)
 * @created: 2025-01-08 20:29:03
 * @modified: 2025-01-08 21:28:46
 *
 * Copyright (c) 2025 Juntong Chen. All rights reserved.
 */

#let is-western(unicode) = {
  // https://gist.github.com/shhider/38b43db6abe31b551384372254c5ac79
  return unicode >= 0x0041 and unicode <= 0x005A or unicode >= 0x0061 and unicode <= 0x007A or unicode >= 0x30 and unicode <= 0x39
}

// 将分行的字符串拼接成一个正常字符串。将会考虑为西文字符插入空格。
#let to-normal-str(src: "") = {
  if type(src) == str {
    src = src.split("\n")
  }
  let lines = src.enumerate().map(it => {
    let id = it.at(0)
    let line = it.at(1)
    if id > 0 {
      // 如果上一行的最后一个字符和当前行的第一个字符都是西文，则在当前行首插入空格
      if line.len() > 0 and is-western(line.codepoints().first().to-unicode()) {
        let last = src.at(id - 1)
        if last.len() > 0 and is-western(last.codepoints().last().to-unicode()) {
          line = " " + line
        }
      }
    }
    return line
  })
  return lines.join("")
}