#let datetime-display(date) = {
  date.display("[year]年[month padding:none]月[day padding:none]日")
}

#let datetime-display-without-day(date) = {
  date.display("[year]年[month padding:none]月")
}

#let datetime-en-display(date) = {
  let d = date.day()
  // 处理 11, 12, 13 的特殊情况
  let suffix = if d in (1, 21, 31) { [st] } else if d in (2, 22) { [nd] } else if d in (3, 23) { [rd] } else { [th] }

  date.display("[month repr:long] [day padding:none]")
  super(suffix)
  date.display(", [year]")
}

#let datetime-en-display-without-day(date) = {
  date.display("[month repr:long], [year]")
}
