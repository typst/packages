#import "../_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "../_system/utils.typ": a3-seite

= Startklar im Browser

Da Sie Ihre Zeit lieber in das Schreiben der Facharbeit als in die Installation von Programmen investieren sollten, empfehlen wir ausdrücklich die Nutzung des offiziellen Typst Web-Editors @typstdocs2024. Er ist kostenlos, erfordert keine Installation und zeigt Ihnen live an, wie Ihr finales PDF aussieht.

== Step-by-Step in den Web-Editor
Folgen Sie dieser einfachen Anleitung, um Ihre Vorlage in den Browser zu bekommen:

1. *Account anlegen:* Öffnen Sie Ihren Webbrowser und gehen Sie auf #link("https://typst.app")[typst.app]. Klicken Sie auf "Sign up" (Registrieren) und erstellen Sie sich einen kostenlosen Account (z. B. mit Ihrer E-Mail-Adresse).
2. *Neues Projekt:* Klicken Sie auf dem Startbildschirm auf den Button `+ New Project` und wählen Sie dort `Empty Project` (Leeres Projekt). Geben Sie dem Projekt den Namen Ihrer Facharbeit.
3. *Vorlage hochladen:* Klicken Sie in der linken Seitenleiste oben auf das kleine Wolken-Symbol mit dem Pfeil nach oben ("Upload files").
   - Entpacken Sie die ZIP-Datei, die Sie von der Schule erhalten haben, auf Ihrem PC.
   - Klicken Sie im Upload-Fenster auf den Button *Pick a folder*.
   - Wählen Sie den soeben entpackten Ordner auf Ihrem PC aus und laden Sie ihn hoch.
4. *Überschreiben bestätigen:* Wenn Sie gefragt werden, ob die vorhandene `main.typ` überschrieben werden soll, klicken Sie auf `Replace` (Ersetzen) bzw. `Ja`.
5. *Live-Vorschau:* Klicken Sie links auf die Datei `St_Vorlage.typ`. Auf der rechten Seite erscheint nun nach wenigen Sekunden Ihr fertiges PDF (`St_Vorlage.pdf`). Jedes Mal, wenn Sie links einen Text ändern, aktualisiert sich die rechte Seite vollautomatisch!
6. *Finale Abgabe herunterladen:* Wenn Ihre Arbeit fertig ist, klicken Sie ganz oben rechts (über der PDF-Vorschau) auf das kleine Download-Symbol (Pfeil nach unten). Damit laden Sie sich die druckfertige PDF-Datei auf Ihren Computer herunter.

== Was bekomme ich eigentlich von der Schule?
Wenn Sie die ZIP-Datei entpacken, sehen Sie folgende Struktur. Das ist Ihr gesamtes Projekt:
- `St_Vorlage.typ`: Das ist das "Herz" Ihrer Arbeit. Hier ist die Struktur der Facharbeit bereits vorgegeben. Sie arbeiten (fast) ausschließlich in dieser Datei und füllen die Überschriften mit Ihren eigenen Texten.
- `St_Individualisierungen.typ`: Hier tragen Sie Ihren Namen, den Titel der Arbeit und Ihren Prüfer ein.
- `St_Facharbeit.bib`: Ihre Literaturdatenbank (hier tragen Sie Bücher und Internetlinks ein).
- Ordner `Abbildungen/`: Hier speichern Sie Ihre Bilder, Logos und Screenshots.
- Ordner `_system/`: *Achtung, Finger weg!* Hier liegt die programmierte Layout-Engine, die dafür sorgt, dass Ihre Arbeit den Vorgaben der Schule entspricht.

== Der Schreibprozess
Ihre Vorlage ist maximal simpel aufgebaut: Sie müssen keine eigenen Dateien anlegen oder programmieren. Öffnen Sie einfach die `St_Vorlage.typ`. Sie finden dort bereits eine vorgegebene Struktur (Einleitung, Problembeschreibung, Fazit, etc.), die Sie natürlich anpassen müssen. 

1. *Überschriften anpassen:* Ändern Sie die Platzhalter (z. B. `= [Ihre Überschrift für die Einleitung]`) einfach in Ihre eigenen Überschriften um (z. B. `= Einleitung`). 
2. *Texte schreiben:* Löschen Sie die Platzhalter-Texte und tippen Sie direkt los.
3. *Sicherheitszonen beachten:* In der Datei finden Sie gut sichtbare Ampeln (wie `// 🟢 HIER DÜRFEN SIE ÄNDERN 🟢`). Diese zeigen Ihnen genau, wo Sie schreiben sollen und welche System-Zeilen Sie stehen lassen müssen.

Sobald Sie tippen, fügt Typst die Texte wie von Zauberhand in Ihr PDF ein!

== Datensicherung (Überlebenswichtig!)
#hinweisbox(titel: "🚨 EXTREM WICHTIG: Regelmäßige Etappen-Backups!")[
  Auch wenn die Cloud-Speicherung im Web-Editor sehr zuverlässig ist: *Sie sind selbst für Ihre Daten verantwortlich!*
  
  Klicken Sie regelmäßig (mindestens nach jedem Arbeitstag oder vor größeren Umbauten) im Web-Editor oben auf das Wolken-Symbol (Export) und laden Sie sich Ihr gesamtes Projekt als ZIP-Datei herunter. 
  
  Sichern Sie diese ZIP-Dateien fortlaufend nummeriert (z. B. `Facharbeit_Backup_2026-04-12.zip`) auf einem USB-Stick oder in Ihrem eigenen Cloud-Speicher. Es gibt nichts Schlimmeres, als kurz vor der Abgabe versehentlich wichtige Dateien im Web-Editor zu löschen und kein Backup zu haben!
]
