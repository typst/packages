#let resolve-term(term, info, dict) = if term == auto {
  let date = info.at("date", default: info.at("_date", default: datetime.today()))
  assert.eq(type(date), datetime, message: "When using 'auto' for 'term', 'date' must be of type 'datetime' or 'none'.")
  // if month between 4 and 9 then it's summer term, else it's winter term
  let month = date.month()
  let year = date.year()
  if month >= 4 and month <= 9 {
    dict.summer_term + " " + str(year)
  } else {
    dict.winter_term
    if month < 4 {
      year = year - 1
    }
    " " + str(year) + "/" + str(year + 1)
  }
} else {
  term
}
