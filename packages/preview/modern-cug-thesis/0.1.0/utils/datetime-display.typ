// 显示中文日期
#let datetime-display(date) = {
  date.display("[year] 年 [month] 月 [day] 日")
}

#let map_number = (
  "0": "〇", "1": "一", "2": "二", "3": "三", "4": "四",
  "5": "五", "6": "六", "7": "七", "8": "八", "9": "九"
)
#let map_month = (
  "1": "一", "2": "二", "3": "三", "4": "四",
  "5": "五", "6": "六", "7": "七", "8": "八", 
  "9": "九", "10": "十", "11": "十一", "12": "十二"
)

#let datetime-zh-display(date, anonymous: false) = {
  let year = (str(datetime.today().year()).clusters().map(
    (n) => if map_number.keys().contains(n) {map_number.at(n)}
  ).join(""))
  let month = (str(date.month()))
  let month = {if map_month.keys().contains(month) {
    month.replace(month, map_month.at(month))
  }}
  if anonymous {
    year = "二〇▢▢"
    month = "▢▢"
  }
  [
      #(year)年#(month)月 //\ #year;年#month;月 \ #{year;[年];month;[月]}
  ] 
}

// 显示英文日期
#let datetime-en-display(date) = {
  date.display("[month repr:short] [day], [year]")
}