// lib/utils.typ - 纯工具函数
// 中文数字转换、编号格式化、文本处理等

#import "config.typ": appendixcounter, 字号

// 阿拉伯数字转中文数字
#let chinesenumber(num, standalone: false) = if num < 11 {
  ("零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十").at(num)
} else if num < 100 {
  if calc.rem(num, 10) == 0 {
    chinesenumber(calc.floor(num / 10)) + "十"
  } else if num < 20 and standalone {
    "十" + chinesenumber(calc.rem(num, 10))
  } else {
    (
      chinesenumber(calc.floor(num / 10))
        + "十"
        + chinesenumber(calc.rem(num, 10))
    )
  }
} else if num < 1000 {
  let left = chinesenumber(calc.floor(num / 100)) + "百"
  if calc.rem(num, 100) == 0 {
    left
  } else if calc.rem(num, 100) < 10 {
    left + "零" + chinesenumber(calc.rem(num, 100))
  } else {
    left + chinesenumber(calc.rem(num, 100))
  }
} else if num < 10000 {
  let left = chinesenumber(calc.floor(num / 1000)) + "千"
  if calc.rem(num, 1000) == 0 {
    left
  } else if calc.rem(num, 1000) < 10 {
    left + "零" + chinesenumber(calc.rem(num, 1000))
  } else if calc.rem(num, 1000) < 100 {
    left + "零" + chinesenumber(calc.rem(num, 1000))
  } else {
    left + chinesenumber(calc.rem(num, 1000))
  }
} else {
  panic("chinesenumber: num is too large")
}

// 年份转中文（如 2026 -> 二〇二六）
#let chineseyear(year) = (
  str(year)
    .clusters()
    .map(it => ("〇", "一", "二", "三", "四", "五", "六", "七", "八", "九").at(
      int(it),
    ))
    .join("")
)

// 根据最大宽度拆分文本为多行，返回字符串数组
// 必须在 context 中调用（因为使用了 measure）
#let split-text-by-width(text-content, max-width) = {
  let chars = if type(text-content) == str {
    text-content.clusters()
  } else {
    str(text-content).clusters()
  }
  let result = ()
  let current = ""

  for c in chars {
    if c == "\n" {
      if current.len() > 0 {
        result.push(current)
      }
      current = ""
    } else {
      let next = current + c
      if measure(next).width > max-width {
        if current.len() > 0 {
          result.push(current)
        }
        current = c
      } else {
        current = next
      }
    }
  }

  if current.len() > 0 {
    result.push(current)
  }

  result
}

// 中文章节编号格式化
#let chinesenumbering(..nums, location: none, brackets: false) = context {
  let actual_loc = if location == none { here() } else { location }
  if appendixcounter.at(actual_loc).first() < 10 {
    if nums.pos().len() == 1 {
      "第" + chinesenumber(nums.pos().first(), standalone: true) + "章"
    } else {
      numbering(if brackets { "(1.1)" } else { "1.1" }, ..nums)
    }
  } else {
    if nums.pos().len() == 1 {
      "附录 " + numbering("A.1", ..nums)
    } else {
      numbering(if brackets { "(A.1)" } else { "A.1" }, ..nums)
    }
  }
}

// 从 figure caption body 中提取文本
#let bodytotextwithtrim(a) = {
  if a.has("children") {
    let found = a.children.find(it => it.has("text") and it.text.len() > 0)
    if found != none { found } else { a }
  } else {
    a
  }
}
