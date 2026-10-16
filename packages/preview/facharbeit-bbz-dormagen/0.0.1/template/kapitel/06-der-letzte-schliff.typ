#import "../_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "../_system/utils.typ": a3-seite
#import "../_system/einstellungen.typ"

= Der letzte Schliff

Die letzten Schritte vor der finalen Abgabe sind oft die wichtigsten. In diesem Kapitel erfahren Sie, wie Sie typische Fehler beheben, wie Sie den Anhang richtig nutzen und wie Sie Ihre Arbeit für den Druck vorbereiten.

== Der Sinn des Anhangs
In dieser Vorlage finden Sie unter `06-anhang.typ` extrem viele Beispiele (Anlage A bis X). Das ist für eine normale Facharbeit natürlich viel zu viel! Wir haben diese Anlagen nur integriert, damit Sie den Quellcode für Tabellen (SWOT, BCG-Matrix etc.) griffbereit haben und sehen, was alles möglich ist.

*Wann gehört etwas in den Anhang?*
Lagern Sie Tabellen, Diagramme oder Texte nur dann in den Anhang aus, wenn sie:
1. Den Lesefluss im Hauptteil durch ihre schiere Größe stören würden (z.~B. ein zweiseitiger Fragebogen, ein riesiger Programmcode oder eine DIN A3-große Tabelle).
2. Für das unmittelbare Verständnis des Textes nicht zwingend erforderlich sind, aber als ergänzendes Beweismaterial dienen.

Im Haupttext müssen Sie sich dann explizit darauf beziehen (z.~B. *"Die detaillierte Auswertung finden Sie in #link(<anlage-A>)[Anlage A]"*). Wenn ein Diagramm klein genug ist und direkt Ihren Argumentationsgang stützt, gehört es in den Fließtext, nicht in den Anhang!

== Hilfe, es geht nicht mehr! (Typische Fallen)
Wenn Sie nachts um 2 Uhr plötzlich eine rote Fehlermeldung erhalten und das PDF nicht mehr generiert wird, bewahren Sie Ruhe. Dies sind die häufigsten Fehlerquellen:

- *Die Klammer-Falle:* Typst reagiert allergisch auf nicht geschlossene Klammern. Wenn Sie eine eckige Klammer `[` öffnen, aber nicht schließen, bricht alles ab. (Die Fehlermeldung zeigt dann fälschlicherweise oft ans Ende des Dokuments!). Suchen Sie die letzte Stelle, an der Sie gearbeitet haben.
- *Pfade zerstört:* Wenn Sie die Datei `St_Vorlage.typ` oder `St_Individualisierungen.typ` umbenennen oder versehentlich in einen Unterordner verschieben, stimmt der interne Aufbau nicht mehr. Lassen Sie die Dateien dort, wo sie sind.
- *Literatur-Fehler:* Wenn Sie eine Quelle zitieren (z. B. `@Mueller2023`), achten Sie *exakt* auf die Groß- und Kleinschreibung! Typst findet `@mueller2023` nicht, wenn es in der `St_Facharbeit.bib` großgeschrieben ist.

== Druck, Duplex & Abgabe
Wenn Sie fertig sind, müssen Sie das Dokument für den finalen Druck vorbereiten. Gehen Sie dazu in die Datei `_system/einstellungen.typ`:
- *Duplex-Druck:* Die Vorlage ist standardmäßig auf beidseitigen Druck (Duplex) eingestellt. Die Seitenränder (Heftrand) springen dabei vollautomatisch hin und her! Wenn Sie einseitig drucken wollen, ändern Sie `#let duplex-druck = true` einfach auf `false`.
- *Farbdruck:* Das Dokument ist für Farbdruck optimiert. Sie können in `einstellungen.typ` aber auch die Akzentfarben anpassen oder beim Druck einfach "Schwarz-Weiß" im Druckmenü wählen.

*Die Wahl des richtigen Papiers:*
Für die Abgabe an der Fachschule reicht eine saubere Spiralbindung. Wenn Ihre Arbeit farbige Diagramme enthält, drucken Sie sie auf einem hochwertigen Farblaserdrucker. Verwenden Sie ein Papier mit einer Grammatur von *120~g/m²* und matter Oberfläche (Satin/Matt), z. B. "Color Copy Papier 120~g DIN A4 matt". Das sorgt für brillante Farben, verhindert, dass Text auf die Rückseite durchscheint, und verleiht Ihrer Facharbeit den perfekten, professionellen Touch!
