// Deckblatt des Berichtshefts.
#import "@preview/azubinachweis:0.1.1": deckblatt

#show: deckblatt.with(
  heft-nr: "1",
  name: "Max Mustermann",
  geburtsdatum: "01.01.2005",
  adresse: "Musterstraße 1, 12345 Musterstadt",
  beruf: "Musterberuf",
  fachrichtung: "Musterschwerpunkt",
  betrieb: "Musterbetrieb GmbH, Musterstadt",
  ausbilder: "Erika Musterfrau",
  ausbildungsjahr: "1. Ausbildungsjahr",
  beginn: "01.09.2026",
  ende: "31.08.2029",
  unterschriften: ("Auszubildender", "Ausbilder"),
)
