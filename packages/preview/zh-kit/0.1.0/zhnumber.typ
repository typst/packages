#let lower-digits = ("零", "一", "二", "三", "四", "五", "六", "七", "八", "九")
#let upper-digits = ("零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖")
#let lower-units = ("", "十", "百", "千")
#let upper-units = ("", "拾", "佰", "仟")
#let lower-large-units = ("", "万", "亿", "兆")
#let upper-large-units = ("", "万", "亿", "兆")

#let num-to-chinese-internal(num, digits, units, large-units) = {
  if num == 0 { return digits.at(0) }

  let s = ""
  let unit-idx = 0
  let large-unit-idx = 0
  let need-zero = false

  while num > 0 {
    let section = calc.rem(num, 10000)
    num = calc.floor(num / 10000)

    if section == 0 {
      if large-unit-idx > 0 and s != "" and not s.starts-with(digits.at(0)) and not s.starts-with(large-units.at(large-unit-idx)) {
        // 处理 100000000 这种情况，中间的亿单位前需要零
         if large-units.at(large-unit-idx) != "" and need-zero {
          s = digits.at(0) + s
        }
      }
      s = large-units.at(large-unit-idx) + s
      large-unit-idx += 1
      need-zero = true // 如果当前段是0，下一段非0时，可能需要补零
      continue
    }

    let current-section-str = ""
    let section-unit-idx = 0
    let section-has-non-zero = false
    while section > 0 {
      let digit = calc.rem(section, 10)
      section = calc.floor(section / 10)

      if digit == 0 {
        if section-has-non-zero { // 只有在当前小节已经有非零数字时，才考虑加零
          need-zero = true
        }
      } else {
        section-has-non-zero = true
        if need-zero {
          current-section-str = digits.at(0) + current-section-str
          need-zero = false
        }
        current-section-str = digits.at(digit) + units.at(section-unit-idx) + current-section-str
      }
      section-unit-idx += 1
    }

    // 处理 "一十" 为 "十"
    if current-section-str.starts-with(digits.at(1) + units.at(1)) and current-section-str.len() >= (digits.at(1) + units.at(1)).len() {
      let rest = current-section-str.slice((digits.at(1) + units.at(1)).len())
      if rest == "" or not (digits.at(0) + "一二三四五六七八九").contains(rest.at(0)) {
         current-section-str = units.at(1) + rest
      }
    }


    if s != "" and large-units.at(large-unit-idx) != "" {
      // 如果前面有内容，并且当前节有大单位，检查是否需要补零
      // 例如 10001， "一万" + "一" -> "一万零一"
      if need-zero or (num > 0 and large-unit-idx > 0 and not s.starts-with(digits.at(0)) and not s.starts-with(large-units.at(large-unit-idx))) {
         // 确保不是 "零万" 这种
        if not current-section-str.ends-with(digits.at(0)) and large-units.at(large-unit-idx) != "" {
           s = digits.at(0) + s
        }
        need-zero = false
      }
       s = current-section-str + large-units.at(large-unit-idx) + s
    } else {
      s = current-section-str + large-units.at(large-unit-idx) + s
    }

    large-unit-idx += 1
  }
  // 移除开头的 "零" (如果整个数字是0，前面已处理)
  // 移除末尾的 "零" (除非数字本身就是0)
  if s.ends-with(digits.at(0)) and s != digits.at(0) {
    s = s.slice(0, s.len() - digits.at(0).len())
  }
  // 确保不会出现 "零万", "零亿"
  for lu in large-units.slice(1) {
    if lu != "" {
      s = s.replace(digits.at(0) + lu, lu)
    }
  }
  // 再次检查，如果替换后变成以零开头，且不是单纯的零，则移除
   if s.starts-with(digits.at(0)) and s != digits.at(0) and s.len() > digits.at(0).len() {
    s = s.slice(digits.at(0).len())
  }


  return s
}

#let int-to-lower-chinese(num) = {
  num-to-chinese-internal(num, lower-digits, lower-units, lower-large-units)
}

#let int-to-upper-chinese(num) = {
  num-to-chinese-internal(num, upper-digits, upper-units, upper-large-units)
}

// 暂时只处理整数
#let zhnumber-lower(num) = int-to-lower-chinese(num)
#let zhnumber-upper(num) = int-to-upper-chinese(num)