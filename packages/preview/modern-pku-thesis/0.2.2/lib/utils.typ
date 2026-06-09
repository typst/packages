// lib/utils.typ - 纯工具函数
// 中文数字转换、编号格式化、文本处理等

#import "config.typ": appendixcounter, 字号

// 阿拉伯数字转中文数字
// 改为使用 Typst 原生 numbering 函数实现
#let chinesenumber(num) = numbering("一", num)

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
      "第" + chinesenumber(nums.pos().first()) + "章"
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

// 从 figure caption 中提取用于列表条目链接的显示内容。
// 输入为 str 时返回 trim 后的字符串；为 content 时先按 .body 递归解包，再若有 .children 则取第一个含非空 .text 的子节点，否则返回原 content。供 listoffigures 等用作 link 的显示文本。
#let caption-to-text(a) = {
  if type(a) == str {
    a.trim()
  } else if type(a) == content {
    if a.has("body") {
      caption-to-text(a.body)
    } else if a.has("children") {
      let found = a.children.find(it => it.has("text") and it.text.len() > 0)
      if found != none { found } else { a }
    } else {
      a
    }
  } else {
    a
  }
}
