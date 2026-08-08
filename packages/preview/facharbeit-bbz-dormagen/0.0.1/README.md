# Typst Facharbeitsvorlage - BBZ Dormagen

Herzlichen Glückwunsch, Sie haben die offizielle Vorlage für Ihre Abschlussarbeit (bzw. Facharbeit) heruntergeladen. Diese Vorlage nimmt Ihnen die gesamte Arbeit für das Layout, die Formatierung, das Inhaltsverzeichnis und das Literaturverzeichnis ab, damit Sie sich zu 100 % auf Ihren Inhalt konzentrieren können.

## Los geht's (Die ersten 5 Minuten)

Da wir die **Typst Web App** nutzen, müssen Sie nichts auf Ihrem PC installieren. Folgen Sie einfach diesen Schritten:

1. **Einloggen:** Gehen Sie auf [typst.app](https://typst.app/) und loggen Sie sich ein (oder erstellen Sie einen kostenlosen Account).
2. **Vorlage hochladen / erstellen:** Erstellen Sie ein neues Projekt aus dieser Vorlage. 
3. **Ihren Namen eintragen:** Öffnen Sie als Erstes die Datei `99-Individualisierungen.typ` auf der linken Seite. Tragen Sie dort Ihren Namen, Ihr Thema und das Abgabedatum ein. Das Dokument aktualisiert sofort das Deckblatt und alle Kopfzeilen!

## Wie schreibe ich?

Alle Ihre Texte schreiben Sie in die Dateien im Ordner `kapitel/`. 
- Wenn Sie ein Kapitel nicht benötigen (zum Beispiel den Anhang), können Sie die Datei `06-anhang.typ` links im Dateibaum einfach löschen.
- **WICHTIG:** Wenn Sie eine Datei löschen, müssen Sie auch in der Datei `main.typ` die entsprechende `#include`-Zeile löschen oder auskommentieren, ansonsten gibt es eine Fehlermeldung ("File not found")!
- Wenn Sie ein neues Kapitel anlegen wollen, erstellen Sie einfach eine `.typ` Datei im `kapitel/`-Ordner und binden diese in der `main.typ` per `#include "kapitel/neues_kapitel.typ"` ein.

## Bilder einfügen
Sie können Bilder per Drag & Drop in den Typst-Editor hochladen (z. B. in den Ordner `Abbildungen/`). 
In der Datei `makros.typ` haben wir für Sie Befehle vorbereitet, die Ihnen viel Arbeit abnehmen:
- `#bild("Dateiname.jpg", "Beschreibung", "Quelle")`
- `#hinweisbox[Dein Text]`
- `#einfache-tabelle(spalten, inhalt)`

## Literatur zitieren
Schauen Sie sich die Datei `facharbeit.bib` an. Dort finden Sie Muster für Bücher, Internetseiten und Studien. Kopieren Sie diese Muster, passen Sie Autor und Jahr an und verweisen Sie im Text einfach mit `@autorJahr` darauf. **Achtung:** Verstecken Sie niemals ein `@Zitat` innerhalb einer manuellen `#footnote[...]`, das führt zu einer Endlosschleife im Programm! Die Vorlage macht Zitate automatisch zu Fußnoten.

Viel Erfolg bei Ihrer Facharbeit!
