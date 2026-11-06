// 部分取自 modern-nju-thesis

// 显示中文日期
#let datetime-display(date) = {
  date.display("[year] 年 [month] 月 [day] 日")
}

// 显示全中文日期
#let datetime-display-full(date) = {
  let cap-nums = "〇一二三四五六七八九".codepoints()
  str(date.year()).codepoints().map(n => cap-nums.at(n.to-unicode() - 48)).join()
  "年"
  numbering("一", date.month())
  "月"
  numbering("一", date.day())
  "日"
}

// 显示英文日期
#let datetime-en-display(date) = {
  date.display("[month repr:short] [day], [year]")
}
