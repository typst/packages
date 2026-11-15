# clean-htl

Schlichtes Template für Mitschriften an der HTL. Kopfzeile mit Fach, Thema,
Klasse und Datum, farbige Notizboxen und hervorgehobene Formeln.

## Neues Projekt

```sh
typst init @preview/clean-htl:0.1.0
```

Auf typst.app: _Start from template_ und `clean-htl` suchen.

Oder in ein bestehendes File:

```typst
#import "@preview/clean-htl:0.1.0": *

#show: htl-notes.with(
  title: "Thema",
  subject: "Fach",
  student: "Vorname Nachname",
  class: "1cHEL",
  teacher: "Lehrer",
  date: datetime(year: 2026, month: 9, day: 24),
)
```

Datum fix setzen, sonst ändert es sich bei jedem Kompilieren.
`date` weglassen für das heutige Datum, `teacher: none` für keinen Lehrer.

## Syntax

```typst
= Kapitel

== Unterkapitel

- Erster Punkt
- Zweiter Punkt
  - Unterpunkt
```

## Mathe

```typst
Der Widerstand $R$ wird in Ohm angegeben.

$ R = U / I $
```

Formeln als eigene Zeile bekommen einen blauen Kasten.

Bei Einheiten Klammern setzen, sonst teilt `/` nur den nächsten Teil:
`$(12 "V") / (2 "A")$`.

## Farbige Notizen

```typst
#definition[Eine Definition]
#remember[Prüfungsrelevant]
#note[Zusätzliche Erklärung]
#warning[Achtung]
#question[Offene Frage]
#example[Rechenweg]
#result[Ergebnis]
```

Eigener Titel und Farbe:

```typst
#callout(title: "Versuch", color: rgb("7a4f90"))[Eigener Hinweis]
```

Inline hervorheben:

```typst
Das ist #hl[besonders wichtig].
```

## Tabellen und Bilder

```typst
#table(
  columns: (auto, 1fr, 1fr),
  table.header([Nr.], [$U$ in V], [$I$ in mA]),
  [1], [5.0], [10.1],
  [2], [7.5], [15.0],
)

#image("schaltung.png", width: 55%)
```

Die erste Zeile einer Tabelle wird automatisch fett.
`#figure(..., caption: [...])` nur wenn eine Beschriftung oder Referenz gebraucht wird.

## Fonts

**Source Sans 3** für Text, **Noto Sans Math** für Formeln.
Fehlen sie, wird Libertinus Serif bzw. New Computer Modern Math verwendet
(beide in Typst eingebaut).

## Lizenz

MIT-0, siehe `LICENSE`.
