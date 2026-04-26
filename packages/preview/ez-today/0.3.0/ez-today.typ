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
    months = ("Ledna", "Února", "Března", "Dubna", "Května", "Června", "Července", "Srpna", "Září", "Října", "Listopadu", "Prosince")
  } else if lang == "pt" {
    months = ("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro")
  } else {
    return ""
  }

  months.at(month - 1)
}

#let today(lang: "de", format: "d. M Y", custom-months: ()) = {
  let use-custom = false;
  if custom-months.len() == 12 {
    use-custom = true;
  }
  for f in format {
    if f == "d" {
      [#datetime.today().day()]
    } else if f == "M" {
      if use-custom {
        [#custom-months.at(datetime.today().month() - 1)]
      } else {
        [#get-month(lang, datetime.today().month())]
      }
    } else if f == "m" {
      [#datetime.today().month()]
    } else if f == "Y" {
      [#datetime.today().year()]
    } else if f == "y" {
      [#datetime.today().display("[year repr:last_two]")]
    }
    else {
      f
    }
  }
}
