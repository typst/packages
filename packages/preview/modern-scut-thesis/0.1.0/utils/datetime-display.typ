// 显示中文日期
#let datetime-display(date) = {
  date.display("[year] 年 [month padding:none] 月 [day padding:none] 日")
}

// 显示中文年月（封面提交日期用）
#let datetime-ym-display(date) = {
  date.display("[year] 年 [month padding:none] 月")
}

// 显示英文日期
#let datetime-en-display(date) = {
  date.display("[month repr:short] [day], [year]")
}
