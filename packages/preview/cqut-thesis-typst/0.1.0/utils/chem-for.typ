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
  set text(font: "Libertinus Serif")
  let res = []        // 存储结果的数组
  let f = false       // 标记是否为上标
  let p = false       // 标记是否为元素符号的开始
  for c in s {        // 遍历字符串中的每个字符
    if c == " " {     // 如果是空格
      f = false       // 重置上标标记
    } else if c == "^" { // 如果是上标符号
      f = true        // 设置上标标记为真
      continue        // 跳过当前循环
    }
    if not p {        // 如果尚未检测到元素符号
      if isAlpha(c) { // 如果是字母
        p = true      // 设置元素符号标记为真
      } else {
        res += [#c]   // 直接添加字符到结果
        continue      // 跳过当前循环
      }
    }
    if f {            // 如果是上标
      res += [#super[#c]] // 添加上标字符
    } else {
      // 处理其他字符
      if c == "<" {
        res += [$arrow.b$]     // 添加左箭头
      } else if c == ">" {
        res += [$arrow.t$]     // 添加右箭头
      } else if c == "." {
        res += [$dot$]         // 添加点
      } else if c == "+" or c == "-" {
        res += [#super[#c]]    // 添加上标的加号或减号
      } else if isDigit(c) {   // 如果是数字
        res += [#sub[#c]]      // 添加下标字符
      } else {
        res += [#c]            // 直接添加字符到结果
      }
    }
  }
  res                 // 返回结果
}

// 化学方程式显示
#let cb = (s, a: none, b: none) => {
  let ss = s.split(" ")   // 将字符串按空格分割成数组
  let sym = $=$           // 默认符号为等号
  if "->" in s {
    sym = $arrow.r.long$  // 设置为右箭头
  } else if "<=>" in s {
    sym = $harpoons.rtlb$ // 设置为双向箭头
  }
  for sa in ss {          // 遍历分割后的数组
    if sa == "=" or sa == "->" or sa == "<=>" { // 如果是符号
      if a != none and b != none {
        [$#sym^(#a)_(#b)$ ]    // 添加带上下标的符号
      } else if a != none {
        [$#sym^scripts(#a)$ ]  // 添加带上标的符号
      } else {
        [$#sym$ ]              // 仅添加符号
      }
    } else {
      [#ca(sa) ]               // 处理化学式
    }
  }
}
