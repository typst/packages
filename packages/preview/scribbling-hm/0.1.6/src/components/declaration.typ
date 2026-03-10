#let declaration(
  name: none,
  birth-date: none,
  study-group: none,
  semester: none,
  student-id: none,
  submission-date: none,
) = { 
  v(1fr)

  if name != none and study-group != none and semester != none and student-id != none {
    [
      #name#if birth-date != none {
        [, geb. #birth-date]
      } (#study-group, #semester)
    ]
  }

  v(1cm)

  [
    Hiermit erkläre ich, dass ich die Bachelorarbeit selbständig verfasst, noch nicht anderweitig für Prüfungszwecke vorgelegt, keine anderen als die angegebenen Quellen oder Hilfsmittel benutzt sowie wörtliche und sinngemäße Zitate als solche gekennzeichnet habe.
  ]

  v(2cm)

  [München, den #submission-date #h(1fr) #name]

  v(1cm)
}
