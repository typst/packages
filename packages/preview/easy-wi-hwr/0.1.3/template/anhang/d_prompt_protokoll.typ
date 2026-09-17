// anhang/d_prompt_protokoll.typ — Beispiel: KI-Prompt-Protokoll (§3.8)
// Dokumentiert verwendete Prompts gemäß HWR-Richtlinien.
// Das KI-Verzeichnis verweist auf diesen Anhang ("Prompts: siehe Anhang X").
// Die KI-Tool-Spalte verknüpft jeden Prompt mit dem entsprechenden Eintrag im KI-Verzeichnis.

#figure(
  table(
    columns: (auto, auto, 1fr, 1fr),
    align: left,
    table.header(
      [*Nr.*], [*KI-Tool*], [*Prompt (Eingabe)*], [*Ergebnis / Verwendung*],
    ),
    [1],
    [ChatGPT 4o],
    [_„Fasse die wichtigsten Erfolgsfaktoren für ERP-Einführungen im Mittelstand zusammen, basierend auf aktueller Fachliteratur (2020–2025)."_],
    [Zusammenfassung als Ausgangspunkt für Kapitel 2.2; Inhalte wurden mit Primärquellen gegengeprüft und umformuliert.],

    [2],
    [ChatGPT 4o],
    [_„Überprüfe den folgenden Absatz auf logische Konsistenz und schlage Verbesserungen vor: [Absatz eingefügt]"_],
    [Strukturelle Umstellung eines Absatzes in Kapitel 3; Formulierung wurde eigenständig überarbeitet.],

    [3],
    [ChatGPT 4o],
    [_„Erstelle eine Python-Funktion, die CSV-Daten einliest und nach Kategorien gruppiert."_],
    [Code-Grundgerüst für das Auswertungsskript in Kapitel 4; manuell angepasst und getestet.],
  ),
  caption: [Dokumentation der verwendeten KI-Prompts (ChatGPT 4o). Die Zuordnung zum KI-Verzeichnis erfolgt über die Spalte „KI-Tool".],
)
