# Typst Vorlage HAK Imst

## Schnellstart

1. VS Code installieren.
2. vscode Extension **myriad-dreamin.tinymist** installieren
4. "Diplomarbeit Vorlage.typ" anpassen -> hier kann zwischen HAK und Kolleg umgeschaltet werden (siehe Kommentare in Datei)
5. in typst_parts/content.typ schreiben beginnen

## Inhaltliche Vorgaben

1. In jedem Kapitel ist der Verantwortliche mit "#set_responsible([Max Mustermann])" zu kennzeichnen

## Tipps

- Die Vorlage ist so aufgebaut, dass du auch alles erst ohne Vorlage in typst schreiben kannst und nachher die Inhalte in "typst_parts/content.typ" einfügst.
- Ein Klick auf eine Zeile in der Vorschau springt zur entsprechenden Zeile im Code.

## In VS Code mit Dev Container öffnen

Diese Variante ist nicht unbedingt notwendig, da typst auch rein mit der vscode Extension **myriad-dreamin.tinymist** funktioniert (siehe o oben). Allerdings ist es eine gute Möglichkeit, um die benötigten Tools und Abhängigkeiten automatisch zu installieren und zu verwalten. Außerdem ist im Container alles so eingerichtet, dass auch der KI Agent problemlos kompilieren kann. Zusätzlich ist pandoc installiert, um die Dokumente auch in andere Formate exportieren zu können.

1. VS Code installieren.
2. Die Erweiterung **Dev Containers** installieren.
3. Diesen Ordner in VS Code öffnen: `Typst Vorlage HAK Imst`.
4. Wenn VS Code fragt, **Reopen in Container** auswählen.
5. Falls nötig, die Erweiterung **Tinymist** installieren.
