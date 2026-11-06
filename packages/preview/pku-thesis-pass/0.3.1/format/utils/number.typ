// ============================================================
// number.typ — 中文编号与章节切换
// ============================================================

#import "counter.typ": partcounter, chaptercounter

/// 附录切换函数：在正文末尾调用，进入附录模式
/// 发射 thesis-appendix 元数据标记（用于触发参考文献渲染）
/// 并将 part 置为 3（附录部分），重置章节和标题计数器
#let appendix() = {
  metadata("thesis-appendix")
  partcounter.update(3)
  chaptercounter.update(0)
  counter(heading).update(0)
}

/// 阿拉伯数字转中文数字（如 3 → "三"）
#let chinesenumber(num) = numbering("一", num)

/// 年份转中文（如 2026 → "二〇二六"）。
#let chineseyear(year) = (
  str(year)
    .clusters()
    .map(it => ("〇", "一", "二", "三", "四", "五", "六", "七", "八", "九").at(
      int(it),
    ))
    .join("")
)

/// 判断指定位置是否处于附录部分（part >= 3）
#let in-appendix(location) = partcounter.at(location).first() >= 3

/// 中文章节编号格式化
/// - 正文部分（appendix == 0）：一级标题显示"第X章"，多级显示"X.X"
/// - 附录部分（appendix == 1）：一级显示"附录 A"，多级显示"A.X"
/// brackets: 是否为公式引用加括号（如"(1.1)"）
#let chinesenumbering(..nums, location: none, brackets: false) = context {
  let actual_loc = if location == none { here() } else { location }
  if not in-appendix(actual_loc) {
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
