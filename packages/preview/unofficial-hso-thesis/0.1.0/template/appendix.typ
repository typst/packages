Den Abschluss der Arbeit bildet der Anhang, der bei Bedarf aus mehreren Teilen bestehen kann. Hier werden Fakten dokumentiert, die dem allgemeinen Verständnis der Arbeit dienen, aber nicht essentiell für die Darstellung sind. Dazu zählen z.B. zusätzliche Grafiken, Tabellen, technische Zeichnungen, Messprotokolle, Dokumentation von Programmen, Datenblätter, Screenshots usw.


== Übersicht verwendeter Hilfsmittel <appendix-ai-tools>

#table(
  columns: (3cm, 4cm, 1fr),
  stroke: none,
  fill: (x, y) => if y == 0 { silver } else { if calc.even(y) { white } else { luma(240) } },
  [#text(weight: "bold")[Produktname]], [#text(weight: "bold")[Bezugsquelle]], [#text(weight: "bold")[Funktionsumfang]],
  [ChatGPT 4], [openai.com], [Unterstützung bei der Strukturierung von Kapiteln und Formulierungshilfe.],
  [DeepL], [deepl.com], [Übersetzung von Fachbegriffen und Korrekturlesen.],
  [GitHub Copilot], [github.com], [Vervollständigung von Codebeispielen in Kapitel 2.],
)

== Code
```python
print("Hello World")
```
...


== Bilder
...


== Mathematische Grundlagen
...
