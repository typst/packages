#let get-month(lang, month) = {
  let months = ()

  if lang == "de" {
    months = ("Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember")
  } else if lang == "en" {
    months = ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
  } else if lang == "fr" {
    months = ("Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre")
  } else if lang == "it" {
    months = ("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre")
  } else if lang == "cs" {
    months = ("ledna", "února", "března", "dubna", "května", "června", "července", "srpna", "září", "října", "listopadu", "prosince")
  } else if lang == "cs2" {
    months = ("Leden", "Únor", "Březen", "Duben", "Květen", "Červen", "Červenec", "Srpen", "Září", "Říjen", "Listopad", "Prosinec")
  } else if lang == "pt" {
    months = ("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro")
  } else if lang == "sk" {
    months = ("Januára", "Februára", "Marca", "Apríla", "Mája", "Júna", "Júla", "Augusta", "Septembera", "Októbra", "Novembra", "Decembra")
  } else if lang == "pl" {
    months = ("Stycznia", "Lutego", "Marca", "Kwietnia", "Maja", "Czerwca", "Lipca", "Sierpnia", "Września", "Października", "Listopada", "Grudnia")
  } else {
    return ""
  }

  months.at(month - 1)
}

#let get-en-suffix(day) = {
  if day == 1 or day == 21 or day == 31 {
    return "st"
  }
  if day == 2 or day == 22 {
    return "nd"
  }
  if day == 3 or day == 23 {
    return "rd"
  }
  return "th"
}

#let today(lang: "de", format: "d. M Y", custom-months: ()) = {
  let use-custom = false
  if custom-months.len() == 12 {
    use-custom = true
  }

  // Zero-padding the month number
  let month-int = datetime.today().month()
  let month-int-string = [#month-int]
  if month-int <= 9 {
      month-int-string = [0] + month-int-string
  }

  // Zero-padding the day number
  let day-int = datetime.today().day()
  let day-int-string = [#day-int]
  if day-int <= 9 {
      day-int-string = [0] + day-int-string
  }
  
  if format == "ISO" {
    return [#datetime.today().year()-#month-int-string\-#day-int-string]
  }
  
  for f in format {
    if f == "d" {
      [#day-int]
    } else if f == "D" {
      [#day-int-string]
    } else if f == "M" {
      if use-custom {
        [#custom-months.at(month-int - 1)]
      } else {
        [#get-month(lang, month-int)]
      }
    } else if f == "n" {
      [#month-int]
    } else if f == "m" {
      [#month-int-string]
    } else if f == "Y" {
      [#datetime.today().year()]
    } else if f == "y" {
      [#datetime.today().display("[year repr:last_two]")]
    } else if f == "S" {
      [#get-en-suffix(day-int)]
    } else if f == "s" {
      [$zws^#get-en-suffix(day-int)$]
    }
    else {
      f
    }
  }
}
