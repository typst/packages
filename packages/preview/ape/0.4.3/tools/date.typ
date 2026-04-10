#let french-days = (
  "Monday": "Lundi",
  "Tuesday": "Mardi",
  "Wednesday": "Mercredi",
  "Thursday": "Jeudi",
  "Friday": "Vendredi",
  "Saturday": "Samedi",
  "Sunday": "Dimanche",
)

#let french-months = (
  "January": "Janvier",
  "February": "Février",
  "March": "Mars",
  "April": "Avril",
  "May": "Mai",
  "June": "Juin",
  "July": "Juillet",
  "August": "Août",
  "September": "Septembre",
  "October": "Octobre",
  "November": "Novembre",
  "December": "Décembre",
)

#let display-date = (lang: "fr", d: datetime.today()) => {
  if lang == "fr" {
    let txt = d.display("[weekday] [day] [month repr:long] - [year]")
    for (eng, fr) in french-days { txt = txt.replace(eng, fr) }
    for (eng, fr) in french-months { txt = txt.replace(eng, fr) }
    txt
  } else {
    d.display("[weekday], [month repr:long] [day], [year]")
  }
}
