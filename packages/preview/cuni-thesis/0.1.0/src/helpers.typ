//Helper functions for text scaling, syntax borrowed from LaTeX
#let tiny(body) = text(0.5em, body)
#let small(body) = text(0.9em, body)
#let large(body) = text(1.2em, body)
#let Large(body) = text(1.44em, body)
#let LARGE(body) = text(1.73em, body)
#let huge(body) = text(2.07em, body)

//Helper function that translates and formates long month notation into czech language

#let datetime_today_translated() = {
  let months-in-czech = ("ledna", "února", "března", "dubna", "května", "června", "července", "srpna", "září", "října", "listopadu", "prosince")

  let translated-month(dt_month) = months-in-czech.at(dt_month.month() - 1)

  let dt_today = datetime.today()
  [#dt_today.day(). #translated-month(dt_today)]
  }