#import "../helpers/datum.typ": aktuelles_abi, datum_bekommen
#import "../helpers/validators.typ": _validate-deckblatt-inputs

#let render-deckblatt(
  leitfrage: "Eine sehr interessante Leitfrage über Heidelbeeren und deren Funktion in der Gesellschaft!",
  name: "Max Mustermann",
  referenzfach: "[Geschichte]",
  bezugsfach: "[Politikwissenschaft]",
  pruefer: ((name: "Frau Muster"), (name: "Herr Mann")),
  vorgelegt-am: datetime.today(),
  abgabetermin-am: datetime.today(),
  stadt: "Berlin",
  schule: "OSZ-Lise-Meitner"
) = {
  _validate-deckblatt-inputs(leitfrage, name, referenzfach, bezugsfach, pruefer, vorgelegt-am, abgabetermin-am, stadt)

  let jahr = aktuelles_abi()

  page(
    {
      v(5%)

      // Center align the description text in smallcaps
      align(center, smallcaps(text(size: 14pt)[
        #text(size: 24pt)[Schriftliche Ausarbeitung]\
        im Rahmen der 5. Prüfungskomponente des Abiturs\
        #v(1em)
        #schule \
        #jahr
      ]))

      v(1fr)
      align(center, text(size: 18pt, name))
      v(3em)
      align(center, text(size: 24pt, weight: "bold", leitfrage))
      v(3em)
      align(center, text(
        size: 12pt,
        stadt + ", " + datum_bekommen(),
      ))
      v(1fr)


      grid(
        columns: (1fr, 1fr),
        align: (center, center),
        [
          #text(weight: "bold", "Prüfungsfächer")
          #v(1mm)
          #text("Referenzfach: " + referenzfach) \
          #text("Bezugsfach: " + bezugsfach) \
        ],
        [
          #text(weight: "bold", "Prüfende")
          #v(1mm)
          #for pruefer in pruefer [
            #text(pruefer.name)\
          ]
        ],
      )
      v(3em)
      grid(
        columns: (1fr, 1fr, 1fr),
        align: (center, center),
        [],
        [
          #text(weight: "bold", "Vorgelegt am: ") #vorgelegt-am.display("[day].[month].[year repr:last_two]") \
          #text(weight: "bold", "Abgabetermin: ") #abgabetermin-am.display("[day].[month].[year repr:last_two]")
        ],
        [],
      )
      

      v(3mm)
    },
  )
  pagebreak()
  pagebreak()
}
