// Convert an int to Chinese number, for ex: 2024 become "二〇二四"
#let int-to-cn-simple-num(n) = {
  let digits = ("〇", "一", "二", "三", "四", "五", "六", "七", "八", "九")
  let s = str(n)
  let result = ""
  for c in s.codepoints() {
    result += digits.at(int(c))
  }
  return result
}

// Convert an int string to Chinese number, for ex: "2024" become "二千零二十四"
#let str-to-cn-num(s) = {
  let digits = ("零", "一", "二", "三", "四", "五", "六", "七", "八", "九")
  let units = ("", "十", "百", "千", "万", "十", "百", "千", "亿", "十", "百", "千")
  let result = ""
  let len = s.len() - 1
  let i = len
  while i >= 0 {
    result = digits.at(int(s.at(i))) + units.at(len - i) + result;
    i -= 1
  }

  for i in (0, 1, 2, 3) {
    result = result.replace("零亿", "亿")
    result = result.replace("零万", "万")
    result = result.replace("零千", "零")
    result = result.replace("零百", "零")
    result = result.replace("零十", "零")
    result = result.replace("零零", "零")
    result = result.replace("亿万", "亿")
  }
  if result.len() > 3 and result.ends-with("零") {
    result = result.trim("零")
  }
  if result.len() == 9 or result.len() == 6 {
    result = result.replace("一十", "十")
  }
  return result
}

// Convert an int to Chinese number, for ex: 2024 become "二千零二十四"
#let int-to-cn-num(n) = {
  let s = str(n)
  return str-to-cn-num(s)
}

// Convert an int string to Chinese ancient number, for ex: "2024" become "贰仟零贰拾肆"
#let str-to-cn-ancient-num(s) = {
  let digits = ("零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖")
  let units = ("", "拾", "佰", "仟", "万", "拾", "佰", "仟", "亿", "拾", "佰", "仟")
  let result = ""
  let len = s.len() - 1
  let i = len
  while i >= 0 {
    result = digits.at(int(s.at(i))) + units.at(len - i) + result;
    i -= 1
  }

  for i in (0, 1, 2, 3) {
    result = result.replace("零亿", "亿")
    result = result.replace("零万", "万")
    result = result.replace("零仟", "零")
    result = result.replace("零佰", "零")
    result = result.replace("零拾", "零")
    result = result.replace("零零", "零")
    result = result.replace("亿万", "亿")
  }
  if result.len() > 3 and result.ends-with("零") {
    result = result.trim("零")
  }
  if result.len() == 9 or result.len() == 6 {
    result = result.replace("壹拾", "拾")
  }
  return result
}

// Convert an int to Chinese ancient number, for ex: 2024 become "贰仟零贰拾肆"
#let int-to-cn-ancient-num(n) = {
  let s = str(n)
  return str-to-cn-ancient-num(s)
}

// Convert a number to Chinese currency, for ex: 1234.56 become "壹仟贰佰叁拾肆元伍角陆分"
#let num-to-cn-currency(n) = {
  let digits = ("零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖")
  let units = ("角", "分")
  let intpart = ""
  let decimal = ""
  let value = str(calc.round(n, digits: 2))
  let splits = value.split(".")
  intpart = splits.at(0)
  if splits.len() > 1 {
    decimal = splits.at(1)
  }
  let result = ""
  if decimal != none {
    for (i, c) in decimal.codepoints().enumerate() {
      if i <= 1 {
        result += digits.at(int(c)) + units.at(i)
      }
    }
  }
  result = str-to-cn-ancient-num(intpart) + "元" + result
  return result
}