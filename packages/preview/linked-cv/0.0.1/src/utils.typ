#let parse-date(date-str) = {
  let parts = date-str.split("-")
  (int(parts.at(0)), int(parts.at(1)))
}

#let time-in-company(..args) = {
  let start-month = 0
  let start-year = 0
  let end-month = 0
  let end-year = 0

  let positional = args.pos()

  let start = parse-date(positional.at(0))
  start-month = start.at(0)
  start-year = start.at(1)

  if positional.at(1) == "current" {
    let today = datetime.today()
    end-month = today.month()
    end-year = today.year()
  } else {
    let end = parse-date(positional.at(1))
    end-month = end.at(0)
    end-year = end.at(1)
  }

  let start-days = start-year * 365 + start-month * 30
  let end-days = end-year * 365 + end-month * 30
  let diff-days = calc.abs(end-days - start-days)

  let years = calc.floor(diff-days / 365)
  let remaining = calc.rem(diff-days, 365)
  let months = calc.floor(remaining / 30)

  let result = ""
  if years > 0 {
    result = result + str(years)
    if years > 1 {
      result = result + " yrs "
    } else {
      result = result + " yr "
    }
  }
  if months > 0 {
    result = result + str(months)
    if months > 1 {
      result = result + " mos"
    } else {
      result = result + " mo"
    }
  }

  result
}

#let time-interval(start, end) = {
  start + " to " + end
}

#let year-month(month, year) = {
  let month-str = str(month)
  if month < 10 {
    month-str = "0" + month-str
  }
  month-str + "--" + str(year)
}

#let roman(n) = {
  let values = (
    (1000, "M"),
    (900, "CM"),
    (500, "D"),
    (400, "CD"),
    (100, "C"),
    (90, "XC"),
    (50, "L"),
    (40, "XL"),
    (10, "X"),
    (9, "IX"),
    (5, "V"),
    (4, "IV"),
    (1, "I"),
  )

  let result = ""
  let num = n

  for (value, numeral) in values {
    while num >= value {
      result = result + numeral
      num = num - value
    }
  }

  result
}
