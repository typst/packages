#import "../_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "../_system/utils.typ": a3-seite

= Quellen, Verzeichnisse und Grafiken

Das wissenschaftliche Arbeiten erfordert präzise Quellenangaben und anschauliche Grafiken. Typst nimmt Ihnen bei all diesen Elementen einen Großteil der Formatierungsarbeit ab und generiert die Verzeichnisse für Sie vollautomatisch!

== Das Literaturverzeichnis (BibTeX)
In dieser Vorlage haben wir das Literaturverzeichnis so eingestellt, dass automatisch Fußnoten erzeugt werden, wenn Sie eine Quelle zitieren!

Typst nutzt für das Literaturverzeichnis eine sogenannte `.bib`-Datei (BibTeX). Das ist eine einfache Textdatei namens `St_Facharbeit.bib`, in der alle Ihre Literaturquellen in einem speziellen Format untereinander stehen.

*Wie zitiere ich verschiedene Quellarten?*
Wenn Sie in die Datei `St_Facharbeit.bib` schauen, sehen Sie verschiedene Blöcke. Jeder Block beginnt mit einem `@` gefolgt von der Art der Quelle. Das Wort danach (z. B. `oelfke2023`) ist der *Schlüssel* (Key). Wenn Sie diesen Schlüssel mit einem `@` aufrufen, weiß Typst, was gemeint ist:

1. *Fachbücher (`@book`)*:
```typst
Wie bereits festgestellt wurde, ist das Transportwesen (insbesondere bei KEP-Diensten sowie FTL- und LTL-Verkehren) im Wandel @oelfke2023[S. 14 f].
```
Typst erstellt nun völlig automatisch die Fußnote unten auf der Seite (probieren Sie es aus: @oelfke2023[S. 14 f]) und trägt das vollständige Buch hinten in das alphabetische Literaturverzeichnis ein. Auch Standardwerke wie @gleissner2021 oder @wittenbrink2019[S. 45] werden so kinderleicht zitiert.

#hinweisbox(titel: "Seitenangabenvarianten in Fußnoten")[
  Sie können in den eckigen Klammern beliebige Seitenangaben hinterlegen. Gängige Varianten sind z. B.:
  - `[S. 7]` für eine einzelne Seite
  - `[S. 7f]` für Seite 7 und die folgende (ohne Abkürzungspunkt)
  - `[S. 7ff]` für Seite 7 und die folgenden Seiten (ohne Abkürzungspunkt)
  - `[S. 7--11]` für einen Seitenbereich (nutzen Sie zwei Bindestriche `--` für einen bis-Strich)
]

2. *Fachzeitschriften (`@article`)*:
```typst
Aktuelle Entwicklungen aus der Logistik-Fachpresse @dvz2024[S. 14].
```
Ergebnis: Aktuelle Entwicklungen aus der Logistik-Fachpresse @dvz2024[S. 14]. Auch englischsprachige Journale lassen sich problemlos einbinden @ijpdlm2020[S. 10].

3. *Internetquellen (`@online`)*:
```typst
Die Trends für 2024 zeigen eine starke Automatisierung (etwa durch MDE-Geräte im Lager oder bei 3PL-Dienstleistern) @bvl2024.
```
Ergebnis: Die Trends für 2024 zeigen eine starke Automatisierung (etwa durch MDE-Geräte im Lager oder bei 3PL-Dienstleistern) @bvl2024. Beachten Sie, dass bei Online-Quellen in der `.bib`-Datei das Zugriffsdatum (`urldate`) zwingend angegeben werden muss (z. B. Statistiken des Bundesamtes @destatis2023).

4. *Graue Literatur / Studien (`@report`)*:
```typst
Die Zukunftsstudie des Fraunhofer-Instituts @iml2022[S. 3] belegt dies.
```
Ergebnis: Die Zukunftsstudie des Fraunhofer-Instituts @iml2022[S. 3] belegt dies. Auch interne Controlling-Berichte des Ausbildungsbetriebs können so referenziert werden @controlling2024[S. 12--15].

#hinweisbox(titel: "Tipp für Internetquellen und Zeitschriften")[
  Schauen Sie sich die Datei `St_Facharbeit.bib` in dieser Vorlage an. Dort finden Sie bereits fertige Muster-Einträge für alle Quellarten. Kopieren Sie diese Muster einfach für Ihre eigenen Quellen und tauschen Sie Titel, Autor und Jahr aus!
]

Sollen zusätzliche, rein erklärende Fußnoten *ohne* direkten Literaturverweis eingefügt werden, verwenden Sie den Befehl `#footnote[Ihre Erklärung hier.]`. 

#hinweisbox(titel: "Achtung: Verschachtelte Fußnoten vermeiden")[
  Da unser Zitationsstil (`facharbeit.csl`) automatisch Fußnoten für Zitate generiert, dürfen Sie *niemals* ein Literatur-Zitat innerhalb einer manuellen Fußnote verstecken (also NICHT: `#footnote[@mueller2023]`). Das würde eine Fußnote in einer Fußnote erzeugen und zum sofortigen Absturz des Dokuments führen! Schreiben Sie das Zitat einfach direkt in den Text (`@mueller2023`).
]

== Bilder und Grafiken einbinden
Für die Einbindung von Abbildungen (wie Fotos von Firmengebäuden oder Screenshots) empfiehlt sich die Nutzung des bereitgestellten Makros `#bild(pfad, beschreibung, quelle, Breite: 80%)`. Dieses stellt sicher, dass alle Bilder einheitlich formatiert werden und automatisch im Abbildungsverzeichnis erscheinen.

#bild("../Abbildungen/LogoNEU.jpg", alt: "Das Logo des BBZ Dormagen", "Logo des BBZ Dormagen", quelle: "PR-Material der Schule", Breite: "30 %")

```typst
// Beispiel für den Einbau eines Bildes
#bild(
  "Abbildungen/LogoNEU.svg",
  alt: "Das Logo des BBZ Dormagen",
  "PR-Abteilung der Schule",
  Breite: "30 %",
)
```

Laden Sie Ihre Bilddateien (egal ob `.jpg`, `.png` oder `.svg`) am besten gesammelt in den Ordner `Abbildungen/` hoch, damit Ihr Projekt aufgeräumt bleibt.
