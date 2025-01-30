#import "../utils/style.typ": 字体, 字号

// 判断是否为英文字符
#let isAlpha = (c) => {
  return c >= "a" and c <= "z" or c >= "A" and c <= "Z"
}

// 判断是否为数字字符
#let isDigit = (c) => {
  return c >= "0" and c <= "9"
}

// 化学式显示
#let ca = (s) => {
  set text(font: "Libertinus Serif")  // 设置化学式字体
  let res = []            // 存储结果的数组
  let f = false           // 标记是否为上标
  let p = false           // 标记是否为元素符号的开始
  for c in s {            // 遍历字符串中的每个字符
    if c == " " {
      f = false
      res += [#h(0.5em)]  // 遇到空格则重置上标标记，并在结果中插入空白占位
      continue
    } else if c == "^" {
      f = true            // '^' 用于标记之后字符为上标显示
      continue
    }

    if not p {            // 如果还没有识别到元素符号的开始
      if isAlpha(c) {
        p = true          // 碰到字母时认为开始输入元素符号
      } else {
        res += [#c]       // 若非字母，则直接添加该字符到结果中
        continue
      }
    }

    // 若 f 为 true，表示当前字符应以上标形式显示
    if f {
      res += [#super[#c]]
    } else {
      // 当不需要上标时，对字符进行进一步判断和处理
      if c == "<" {
        res += [$arrow.b$]  // 将 '<' 转换为特定箭头符号
      } else if c == ">" {
        res += [$arrow.t$]  // 将 '>' 转换为特定箭头符号
      } else if c == "." {
        res += [$dot$]      // '.' 转换为点号
      } else if c == "+" or c == "-" {
        res += [#super[#c]]  // 电荷符号以上标形式显示
      } else if isDigit(c) {
        res += [#sub[#c]]   // 数字用下标显示
      } else if not isAlpha(c) and not isDigit(c) {
        res += [#text(font: 字体.宋体)[#c]]  // 非字母和数字字符，使用宋体
      } else {
        res += [#c]       // 普通字母直接添加
      }
    }
  }
  res // 返回处理后的结果数组
}

// 化学方程式显示
#let cb = (s, a: none, b: none) => {
  let ss = s.split(" ")   // 将字符串按空格分割
  let sym = $=$           // 默认符号为 '='
  if "->" in s {
    sym = $arrow.r.long$  // 若出现 '->' 则用长箭头表示
  } else if "<=>" in s {
    sym = $harpoons.rtlb$ // 若出现 '<=>' 则用双向箭头表示
  }
  let res = []
  for sa in ss {
    if sa == "=" or sa == "->" or sa == "<=>" {
      // 对方程式的连接符号进行特殊处理
      if a != none and b != none {
        res += [$#sym^(#text(font: 字体.宋体)[#a])_(#text(font: 字体.宋体)[#b])$]
      } else if a != none {
        res += [$#sym^scripts(#text(font: 字体.宋体)[#a])$]
      } else {
        res += [$#sym$]    // 没有额外标记时，直接添加符号
      }
    } else {
      res += [#ca(sa)]   // 使用 ca 函数处理一般的化学式部分
    }
  }
  res // 返回最终结果
}