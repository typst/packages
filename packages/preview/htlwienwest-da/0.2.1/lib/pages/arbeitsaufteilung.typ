#let arbeitsaufteilung(aufteilungen: ()) = [

= Arbeitsaufteilung


#{
  set heading(outlined: false)
  set heading(numbering: none)
    
  table(
    columns: (auto, auto),
    [*Person*], [*Folgende Punkte der Diplomarbeit wurden inklusive aller Unterpunkte von folgenden Personen verfasst:*],
    ..for (p, a) in aufteilungen {
      (p, a)
    }
  )
}

]