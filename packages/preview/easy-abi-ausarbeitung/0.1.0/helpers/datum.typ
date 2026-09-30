#let aktuelles_abi() = {
  let current_year = str(datetime.today().year())
  " Abitur " + current_year
}

#let datum_bekommen() = {
  let monate = (".Januar ", ".Februar ", ".März ", ".April ", ".Mai ", ".Juni ", ".Juli ", ".August ", ".September ", ".Oktober ", ".November ", ".Dezember ")
  let translate(dt) = monate.at(dt.month() - 1)
  let today = datetime.today()
  str(today.day()) + translate(today) + str(today.year())
}