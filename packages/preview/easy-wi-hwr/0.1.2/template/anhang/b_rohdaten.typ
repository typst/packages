// anhang/b_rohdaten.typ
//
// Beispiel: Tabelle als Anhang-Inhalt.
// Ersetze diese Tabelle durch deine eigenen Daten.

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, center),
    table.header(
      [*Frage*],
      [*Antwort-Kategorie*],
      [*Nennungen*],
    ),
    [F1: Wichtigstes Digitalisierungsziel?],  [Prozessautomatisierung],   [12],
    [],                                        [Kostensenkung],            [8],
    [],                                        [Neue Geschäftsmodelle],    [5],
    [F2: Größte Barriere?],                   [Fehlendes Fachpersonal],    [14],
    [],                                        [Unklare Strategie],         [7],
    [],                                        [Budget],                    [4],
  ),
  caption: [Ergebnisse der Unternehmensumfrage (n = 25)],
)
