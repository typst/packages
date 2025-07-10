= Einleitung

- Kurzbeschreibung: Wie lautet das Thema? Welche Hintergründe gibt es zu diesem Thema? Was ist schon darüber bekannt?
- Beschreibung der Leistung: Was ist das Ziel der Arbeit? Für wen hat die Arbeit Relevanz? Hinweis auf Kooperationspartner. Welche Themenstellung soll mit der Arbeit bearbeitet werden?
- Darstellung der Vorgehensweise: In welche Kapitel ist die Arbeit gegliedert? Wie ist sie aufgebaut? Was behandeln die einzelnen Kapitel (kurz)?

== Beispiele

Nutzen von Abkürzungen:

Ausgeschrieben: @api

Abgekürzt: @api

Dieser Verweis kann dann mit `@WinNT` @WinNT referenziert werden und ist dann im Literaturverzeichnis zu finden.

#figure( 
  ```typ
  == Überschrift <HeadingLabel>
  
  #figure(...) <AbbLabel>
  ```,
  caption: [Dieses Codebeispiel ist auch mit einem `label` versehen.], kind: "code", supplement: "Code"
) <KreuzverweisBeispiel>

#figure(
  table(
    inset: 10pt,
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: [Tabellen Beispiel mit Caption],
)