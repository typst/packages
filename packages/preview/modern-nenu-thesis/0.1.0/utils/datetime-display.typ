//! Reference: https://github.com/nju-lug/modern-nju-thesis
/// 显示中文日期（不包含日期）
/// ```examplec
/// datetime
/// .today()
/// .display("[year] 年  [month]  月")
/// ```
/// -> content
#let datetime-display-without-day(
  /// 日期
  /// -> datetime
  date,
) = {
  date.display("[year] 年  [month]  月")
}

/// 显示中文日期
/// ```examplec
/// datetime
/// .today()
/// .display("[year] 年  [month]  月 [day] 日 ")
/// ```
/// -> content
#let datetime-display(date) = {
  date.display("[year] 年 [month] 月 [day] 日 ")
}

/// 显示英文日期
/// ```examplec
/// datetime
/// .today()
/// .display("[year], [month] ")
/// ```
/// -> content
#let datetime-en-display(date) = {
  date.display("[year], [month]")
}
