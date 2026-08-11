// 显示中文日期
#let datetime-display(date) = {
  date.display("[year] 年 [month] 月 [day] 日")
}

// 本科生封面页中的日期显示
#let datetime-display-bachelor(date) = {
  date.display("[year] 年 [month] 月")
}

// 显示英文日期
#let datetime-en-display(date) = {
  date.display("[month repr:short] [day], [year]")
}