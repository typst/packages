#import "../util.typ": insert-blank-page

#let create-page(
  supervisors-incl-ac-degree,
  sponsors,
) = [
  = Präambel
  Die Inhalte dieser Diplomarbeit entsprechen § 7(1) und § 24 der Verordnung des
  Bundesministers für Bildung über die abschließenden Prüfungen in den berufsbildenden
  mittleren und höheren Schulen (Prüfungsordnung BMHS) vom 30.5.2012 (BGBl. Nr.
  II 177/2012) in der derzeit geltenden Fassung.
  #v(2em)
  #strong[Liste der betreuenden Lehrer:] \
  #for supervisor in supervisors-incl-ac-degree [
    #supervisor \
  ]
  #v(2em)
  #strong[Liste der Kooperationspartner:] \
  #for sponsor in sponsors [
    #sponsor \
  ]
]
