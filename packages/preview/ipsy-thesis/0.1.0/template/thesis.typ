#import "@preview/ipsy-thesis:0.1.0": *

#set raw(lang: "typ")
#show: ipsy.with(
  title: [
    Benutzeranleitung zur IPSY-Abschlussarbeitsvorlage für Typst:\
    Ein kurzer Überblick des Syntax und der generellen Benutzung
  ],
  abstract: include "chapters/zusammenfassung.typ",
  appendix: include "chapters/anhang.typ",
  thesis-type: "Leitfaden",
  reviewers: ("Prof. Dr. Micky Maus", "Dr. Tommy Secundus"),
  bibliography: bibliography("literature.bib", style: "apa", title: "Literaturverzeichnis"),
  extra-outlined: true,
  link-color: blue,
)

#outline(title: "Inhalt")
#figure-outline()
#table-outline()

/* --- Syntax für das Abkürzungsverzeichnis. --- */
/* `outlined`: Ob Teil des Inhaltsverzeichnis.    */
#abbrv-outline(outlined: true)[
  / APA: American Psychological Association
  / CSL: Citation Style Language
  / GPL: GNU General Public License
  / IPSY: Institut für Psychologie
  / $bold(p)$: Signifikanzniveau
  / SVG: Scalable Vector Graphics
]
/* --------------------------------------------- */

= Titelseite und (Standard-)Syntax

Die Titelseite wird mithilfe des `#show`-Statements in den oberen Zeilen dieser Datei ausgefüllt. Dabei gibt es einige *Parameter* mit welchen diese Vorlage den Wünschen des*der Nutzer*in angepasst werden kann. Diese können in einer beliebigen Reihenfolge angegeben werden, allerdings muss der Name des Parameters mit dabei stehen.

Jeder Parameter besitzt einen sogenannten "Standardwert", welcher benutzt wird insofern der*die Nutzer*in diesen nicht angibt, bspw. ist der Standardwert von `thesis-type` automatisch `"Bachelorarbeit"` -- sollte also diese Vorlage für eine Bachelorarbeit genutzt werden, muss dieser Wert nicht angepasst werden. Somit müssen nur die Werte angepasst werden, welche von den Standardwerten abweichen.
Siehe @tbl:args: 

#figure(
  kind: table,
  caption: [Alle potentiellen Parameter (und Standardwerte) dieser Typst-Vorlage],
  align(left, generate-documentation())
)<tbl:args>

== Unterschied zwischen `[Titel]` und `"Titel"`

Manch lesender Person ist eventuell aufgefallen, dass sowohl Argumente innerhalb eckigen Klammern -- [...] -- als auch innerhalb Anführungszeichen "..." angegeben werden können. Text innerhalb Anführungszeichen sind sog. Zeichenketten oder _Strings_, d.h. purer Text. Inhalte innerhalb der eckigen Klammern stellen _beliebigen_ Inhalt dar, oder #link("https://typst.app/docs/reference/foundations/content/")[_Content_], welchen Typst generieren kann. So kann z.B. auch ein kleiner Kreis innerhalb dieser Klammern angegeben werden -- dies ergibt natürlich nicht allzu viel Sinn innerhalb des Titels einer Arbeit #box(circle(radius: 4pt)) #box(square(size: 8pt)). 

Für das obrige `#show`-Statement sollte purer Text innerhalb Anführungszeichen genügen, die Möglichkeit besteht allerdings, z.B., den Titel auch mit beliebigen Inhalt zu füllen. Auch kann Formatierung wie *fett*, _kursiv_ oder #underline[unterstreichen] nur mit _Content_ benutzt werden.

*Faustregel:* Benötigt ein Argument nur Text, nutze "..." -- für Formatierung, nutze [...]. Für den normalen Fließtext deiner Arbeit, wie dieser hier, befindet sich das Dokument automatisch im "beliebiger Inhalt"-Modus (https://typst.app/docs/reference/syntax/).

== Überschriften und Unterüberschriften<sec:headings>

Überschriften werden in Typst durch "=" erzeugt. Dabei stellt die Anzahl der "=" die Tiefe, oder Level, der Überschrift dar. Ein "=" erzeugt eine "Level 1"-Überschrift, d.h. semantisch ein komplett neues Kapitel. Folglich ist "==" eine Unterüberschrift und "===" eine Unterunterüberschrift usw. Die Nummerierung geschieht automatisch.

Das Inhaltsverzeichnis listet alle Überschriften bis inklusive Level 3. Überschriften mit Level 4 können für semantische Abschnittunterteilungen verwendet werden, diese sind nicht nummeriert und Teil des Fließtexts:

==== Unterunterunterüberschrift
#lorem(20)

== Inhaltsverzeichnis, Tabellenverzeichnis und Abbildungsverzeichnis

Das Inhaltsverzeichnis wird mit dem `#outline(..)`-Befehl generiert. Dabei kann die Tiefe, oder `depth`, der aufzulistenden Abschnitte angegeben werden (Wir empfehlen es bei 3 zu belassen) und auch ein eigener Titel, dieser ist standardmäßig "Inhalt".

Ein Tabellen- und Abbildungsverzeichnis können ebenso generiert werden. Dies basiert ebenso auf dem `#outline(..)`-Befehl, allerdings inkludiert das einige Zusatzargumente, also haben wir dies abgekürzt: `#table-outline(..)` und `#figure-outline(..)`. Es wird empfohlen, spätestens ab mehr als fünf Tabellen oder Abbildungen das jeweilige Verzeichnis zu erstellen. Dabei kann für das Verzeichnis eine kürzere Tabellenüberschrift / Bildunterschrift angegeben werden, falls die eigentliche zu lang ist.

Dies kann mit der `#flex-caption()`-Funktion realisiert werden. Anstelle der eigentlichen `caption` oder Bildunterschrift, benutzt ihr dann diese Funktion, welche als ersten Parameter die lange Bildunterschrift erwartet und als zweiten Parameter eine Kurzfassung für das jeweilige Verzeichnis. Für eine beispielhafte Anwendung davon, siehe @fig:flex und der Code darüber.

== Tabellen und Abbildungen

Tabellen werden prinzipiell mit dem `#table(..)`-Befehl generiert. Bilder können mit dem `#image("pfad/zur/datei")`-Befehl eingebunden werden. Um dies nun als _Abbildung_ semantisch in die Arbeit einzubinden, werden diese mit dem `#figure(..)`-Befehl zusammen benutzt ("figure" (eng.): "Abbildung"). Die vorgeschriebene APA-Formatierung bzgl. Tabellentitel über der Tabelle und Bildüberschrift über dem Bild (inkl. Anmerkungen -- APA 7) werden euch dabei abgenommen -- siehe @fig:test und @tbl:cite.

=== Tabellen

Der folgende Typst-Code generiert eine Tabelle mit drei Spalten, welche relativ zueinander die maximale Seitenbreite einnehmen, einem Abstand zwischen Zeile und Spalte von `0.75em` (`em` ist eine relative Einheit und entspricht der aktuellen Schriftgröße) und ohne vertikale Linien. Das `caption`-Argument ist dabei die Tabellenüberschrift.#v(0.5em)

```typ
// Formatierung automatisch nach APA 7 Richtlinien.
#figure(caption: [Beispieltabelle mit arbiträren Daten])[
  #table(columns: 3 * (1fr,), stroke: (x: none), inset: 0.75em,
   [x], [y], [z],
   [x], [y], [z],
   [x], [y], [z],
  )
]
```

#figure(caption: [Beispieltabelle mit arbiträren Daten])[
  #table(columns: 3 * (1fr,), stroke: (x: none), inset: 0.75em,
   [x], [y], [z],
   [x], [y], [z],
   [x], [y], [z],
  )
]

Siehe https://typst.app/docs/guides/table-guide/ für einen vollständigen Guide zur Tabellenerstellung. Siehe auch https://typst.app/docs/reference/model/table/ für eine vollständige syntaktische Referenz des Typst-Tabellensyntax. Beispielsweise kann die Dicke der Linien angepasst werden.

=== Bilder (u. Ä.)

Der folgende Typst-Code erstellt eine Abbildung mit einer Bildüberschrift und dem dazugehörigen Bild. Im Idealfall sollten nur Vektorgrafiken (SVGs oder PDFs) verwendet werden, um die maximale Qualität zu gewährleisten. Auch hier kümmert sich das Template automatisch um die Formatierung und Positionierung der Bildüberschrift. Um Anmerkungen hinzuzufügen, siehe `#annotation-fig()`. Für mehrere Bilder in einer Abbildung, siehe #link("https://typst.app/docs/reference/layout/grid/")[_Grid_]. #v(0.5em)

```typ
// flex-caption(long, short) ermöglicht es eine lange Bildunterschrift
// und eine kurze für das Abbildungsverzeichnis zu generieren.

#figure(
  caption: flex-caption(
    [
      Ausprägung der abhängigen Variablen (AV) in Abhängigkeit von 
      den Stufen der unabhängigen Variablen (UV). Die Fehlerbalken 
      kennzeichnen den Standardfehler des Mittelwertes.
    ],
    [Ausprägung der abhängigen Variablen (AV).]
  ),
  image("diagram.svg")
)
```

#figure(
  caption: flex-caption(
    [Ausprägung der abhängigen Variablen (AV) in Abhängigkeit von den Stufen der unabhängigen Variablen (UV). Die Fehlerbalken kennzeichnen den Standardfehler des Mittelwertes.],
    [Ausprägung der abhängigen Variablen (AV).]
  ),
  image("diagram.svg", width: 70%)
)<fig:flex>

== Referenzieren von Abbildungen

Abbildungen können, ebenso wie Abschnitte und Literatureinträge, automatisch referenziert werden. 
Dabei kann nun eine `#figure()`  (oder Überschrift, siehe @sec:headings) mit einem _Label_ versehen werden zur späteren Referenzierung.

#annotation-fig(
  annotation: lorem(20),
  rect(),
  caption: "Ein Rechteck, hier kann alles beliebige stehen!"
)<fig:test>

Hier stellt, bspw., `<fig:test>` ein sog. _Label_ dar -- der Name ist beliebig wählbar, es bietet sich allerdings an Präfixe wie `tbl`, `fig` oder `sec` zu benutzen um verschiedene Arten zu unterscheiden. Die Abbildung kann nun mit @fig:test (`@fig:test`) referenziert werden; der Verweis verlinkt direkt zur Abbildung. (#emoji.warning Siehe Code! #emoji.warning)

= Erweiterter Syntax

== Mathematische Inhalte

Mathematische Gleichungen können mit Typst auch schön und semantisch korrekt formatiert und generiert werden. Dabei ist zu unterscheiden zwischen einer mathematischen Formel, welche im Fließtext auftauchen kann, z.B., "Ich habe ein Signifikanzniveau von $p <= .05$ erreicht" oder größere Blockformeln, wie:

$ sum_(i = 0)^n x^i + 3 xor sqrt(5) $<eq:1>

Dabei unterscheidet sich der Syntax nur sehr geringfügig voneinander. Für Fließtextformeln wird die entsprechende Formel innerhalb Dollar-Zeichen geschrieben, während Blockformeln auch innerhalb Dollar-Zeichen geschrieben werden aber noch zusätzlich am Anfang und am Ende mit einem Leerzeichen versehen werden. Siehe `$x = 3$` vs. `$ x = 3 $`.

Falls unklar ist, wie gewisse Symbole heißen, kann entweder hier gesucht werden: https://typst.app/docs/reference/symbols/sym/ oder das entsprechende Zeichen hier mithilfe Handschrifterkennung gezeichnet werden: https://detypify.quarticcat.com/.
Große Formeln können ebenso referenziert und nummeriert werden: Siehe @eq:1 für eine lustige Formel, welche keinen Sinn ergibt.

== Literaturmanagement und Zitationen

Typst unterstützt das bekannte BibTeX-Format zur Verwaltung der Literatur. Fast alle Journals werden einen BibTeX-Eintrag für ihre Paper oder andere Veröffentlichungen bereitstellen, welche kopiert und in eine externe Datei mit `.bib`-Endung eingefügt werden können.

Im Bibliographieteil des bereits bekannten `#show`-Statements kann dann der Pfad zu dieser Datei im `#bibliography()`-Befehl angegeben werden. Um nun einen Eintrag aus dieser Datei zu zitieren, kommt, wie zuvor, der Referenzsyntax zum Einsatz: `@paper-title`, wo `paper-title` den Namen des BibTeX-Eintrags darstellt -- siehe @martenstein und @Son2019. Dadurch füllt sich dann automatisch auch das Literaturverzeichnis. Oftmals findet man im Bereich der Psychologie statt BibTeX auch RIS-Dateien, diese können allerdings leicht umgewandelt werden (https://www.bruot.org/ris2bib/).

Standardmäßig ist der Zitierstil "APA 7" eingestellt. Typst unterstützt allerdings 1000+ andere Zitierstile, unter anderem, falls gewünscht auch ```typc "deutsche-gesellschaft-für-psychologie"``` -- das ist abhängig von den Anforderungen der betreuenden Person. Das "Citation Style Language"-Format (CSL) wird benutzt zur Gestaltung der Stile #sym.arrow #link("https://www.zotero.org/styles")[Interaktive Suche].

=== Zitatsyntax

Neben dem `@`-Syntax, welcher vielleicht für Prosatext ungeeignet ist, kann auch der vollständige `#cite(..)`-Befehl benutzt werden mit dem `form`-Parameter.
@tbl:cite zeigt nochmal den Syntax aller Zitierformen.#footnote[In den allermeisten Fällen sollte die normale und Prosaform genügen.]

Diese Tabelle implementiert auch eine der optionalen APA-Anforderungen: _Anmerkungen_ als Tabellenunterschrift. Dabei einfach, ähnlich wie bereits bekannt, `#annotation-table(..)` statt `#table(..)` benutzen mit dem zusätzlichen `annotation`-Parameter. 

#figure(caption: [Formen der Quellenagaben im Text, Typst])[
  #set par(justify: false)
  #annotation-table(
    annotation: [Kurzform für Prosa mit `p:`-Präfix. Siehe Leitfaden für sinnvolle Anmerkungen.],
    columns: 2 * (1fr,), stroke: none, inset: 0.75em, align: left,
    /* --- Tabelleninhalt beginnt hier. --- */
    table.hline(stroke: 1pt),
    table.header([Typst Syntax], [Typst Ausgabe]),
    table.hline(),
    [`@netwok2020` oder\ `#cite(<netwok2020>, form: "normal")`], [@netwok2020],
    [`@p:netwok2020` oder `#cite(<netwok2020>, form: "prose")`], [@p:netwok2020],
    `#cite(<netwok2020>, form: "author")`, cite(<netwok2020>, form: "author"),
    `#cite(<netwok2020>, form: "year")`, cite(<netwok2020>, form: "year"),
    `#cite(<netwok2020>, form: "full")`, par(justify: true, cite(<netwok2020>, form: "full")),
    table.hline(stroke: 1pt),
  )
]<tbl:cite>

=== Blockzitate

Blockzitate sollten bei direkten Zitaten ab mehr als 40 Wörtern benutzt werden. Dies geschieht mit dem `#quote(..)`-Befehl. Die Quelle muss dabei mit dem `attribution`-Parameter angegeben werden, ebenso mit `@`-Syntax, zusätzlich mit den Seiten (`@test[S. 3--4]`).

#quote(attribution: [@martenstein[S. 6]])[
  Ich finde es ein bisschen albern, wenn Leute in solchen Zusammenhängen das Wort
  „unnatürlich“ verwenden. Was, bitte schön, ist an unserem heutigen Leben denn noch
  natürlich? ... Wenn es nach der Natur ginge, dann würden wir alle mit vierzig Jahren
  [oder bereits früher] sterben. ... Natur – der schlimmste [Hervorhebung hinzugefügt]
  Feind des Menschen. Der Natur fallen mehr Menschen zum Opfer als Atomkraftwerks-
  unglücken, Rauschgift, Terror und Flugzeugabstürzen zusammengenommen. ... Bleibt
  mir bloß mit der Natur vom Leib.
]

Anlass der Kolumne war die Meldung, Facebook und Apple würden ihren Mitarbeiterinnen künftig
Social Freezing kostenlos ermöglichen. Mehrere Seiten, so wie generelle Intervalle oder Gedankeneinschübe, sollten mit einem Gedankenstrich (--, in Typst: `--`) verbunden werden. Einzelne Bindestriche finden nur Verwendung in der Silbentrennung oder Ausdrücke wie "S-Bahn" und "Ober- und Unterhaus".

=== Normale Zitate

"Immer wenn ich zum Kühlschrank gehe, was leider viel zu oft der Fall ist, denke ich über Freezing nach. Würde ich, wenn ich eine junge Frau wäre, meine Eier einfrieren lassen?" @martenstein[S. 6].

== Auflistungen

Entweder für TODOs oder für generelle Auflistungen existiert auch dedizierter Syntax, der sich automatisch um die korrekte Formatierung kümmert. Ob unnummeriert oder nummeriert (siehe @sec:list und @sec:enum), unterscheidet sich nur mit einem Zeichen: "-" und "+". 

Auflistungen können _dicht_ beieinander sein oder etwas größere Abstände voneinander haben: Dabei müssen Leerzeilen zwischen den einzelnen Einträgen erscheinen. Wir empfehlen eigentlich immer, Auflistungen mit größeren Abständen zu erstellen, da diese leichter zu lesen sind.

=== Unnummerierte Listen<sec:list>

- #lorem(10)

- #lorem(12)

  - Unterlistenelement für genauere Erläuterung.

  - Ein weiteres Unterlistenelement

=== Nummerierte Listen<sec:enum>

+ #lorem(10)

+ Aufzählung von Instruktionen, die nacheinander geschehen sollen.

  + Unterelement 2.1: genauere Erläuterung.

= Verschiedene Extras

== Aufteilung der Kapitel in Dateien

Die gesamte Arbeit in nur einer Datei zu schreiben, kann schnell unübersichtlich werden, daher empfiehlt es sich mindestens jedes Kapitel in eine eigene Datei aufzuteilen. Diese können dann mit `#include "beispiel.typ"` an der Stelle des Aufrufs direkt eingefügt werden. Somit ergibt sich meist automatisch die folgende Struktur der Hauptdatei:

#figure(caption: flex-caption([Standardaufteilung eines Typst-Dokuments. Der `include`-Befehl entspricht essentiell einfach "Copy-and-Paste" und sorgt für Ordnung.], "Standardaufteilung eines Typst-Dokuments."), kind: image)[
  ```typ
  #import "ipsy/ipsy.typ": *
  #show: ipsy.with(            // Siehe Abschnitt 1: Hier wird deine
    title: [Titel],            // Titelseite definiert.
    ..,
  )
  
  #outline(title: "Inhalt")    // Inhaltsverzeichnis                         
  #table-outline()             // Tabellenverzeichnis (bei >= 5 Tabellen)
  #figure-outline()            // Abbildungsverzeichnis (bei >= 5 Abb.)  
  
  #include "einleitung.typ"    // -> Es ist ebenso sinnvoll, eine Ordner-
  #include "hintergrund.typ"   // struktur zu erstellen für jedes Kapitel.
  #include "durchführung.typ"  // Vor allem, um Abbildungen oder Unterka-
  #include "auswertung.typ"    // pitel richtig zu organisieren.
  ...
  ```
]

Ein unauffälliger Blick nach oben verrät, dass dies schon ganz am Anfang für die Zusammenfassung verwendet wurde. Das Konzept ist also nicht neu.

== Rechtschreibprüfung

Der Typst Webeditor ist selbstständig in der Lage, eine automatische Rechtschreibprüfung, oder _Spellcheck_, durchzuführen nachdem links in den Projekteinstellungen ein Häkchen bei "Enable spellchecking" gemacht wurde.

Solltet ihr einen anderen Texteditor benutzen gibt es auch folgende externe Tools, welche euch dennoch weiterhelfen sollten: https://mentor.duden.de/ und https://languagetool.org/de. Dort könnt ihr zumindest abschnittsweise und manuell euren Text überprüfen, nicht ideal oder automatisch aber besser als gar nicht.

== Eigene Funktionen

Falls ihr programmiertechnisch versiert seid, könnt ihr natürlich auch eigene Funktionen mit der Skriptsprache von Typst erstellen. Ein simples Beispiel wäre eine `#todo[xyz]`-Funktion, welche, z.B., ein gelbes Rechteck mit schwarzer Umrandung generiert inkl. dem Präfix: "*TODO:*" und dem Textparameter innerhalb der eckigen Klammern darauffolgend in _kursiv._

Damit spart ihr euch repetitive Schreibarbeit und habt einen auffälligen Reminder, welcher sich nicht in die finale Version einschleicht. Der Code dafür könnte folgendermaßen aussehen:

#figure(kind: image, caption: [Funktionsdefinition eines eigenen TODO-Befehls.])[
  ```typ 
  #let todo(txt) = rect(stroke: 0.5pt, fill: yellow)[*TODO:* #emph(txt)]
  ```
]

Der Aufruf kann dann wie folgt geschehen: `#todo[Füge passendes Diagramm hinzu!]` und erzeugt folgendes Resultat:

#let todo(txt) = rect(stroke: 0.5pt, fill: yellow)[*TODO:* #emph(txt)]
#todo[Füge passendes Diagramm hinzu!]

== Anhangserstellung

Einen Anhang kannst du mit der Funktion `#appendix(titel, lbl: none)[...]` erstellen. Wir empfehlen dies ausdrücklich in einer externen Datei, welche dann, wie in @tbl:args dargestellt, als optionaler Parameter eingebunden werden kann. Der Anhang benötigt einen Titel und optional ein _Label_, so dass im Text auf diesen verwiesen werden kann.

#figure(caption: "Anhangserstellung. Idealerweise in einer Extradatei.", kind: image)[
  ```typ
  #begin-appendix
  #appendix("Titel", lbl: <appendix>)[
    #figure(..)
    #figure(..)
    #figure(..)
  ]
  ```
]<fig:app-creation>

Zwischen den eckigen Klammern kann dann ganz normaler _Content_, bzw. die Anhangsabbildung, eingefügt werden, siehe @fig:app-creation. Der Befehl `#begin-appendix` ist notwendig um die Nummerierung der Überschriften zurückzusetzen, damit diese wieder von vorne anfangen zu zählen, so dass dort ein "A" und, bspw., kein "D" steht als Nummerierung. Abbildungen innerhalb des Anhangs sind ebenso mit _Labels_ referenzierbar und besitzen nun einen Präfix zur korrekten Zuordnung:
_"Siehe @app und @app:image, @app:image2 und @app:image3 (oder sogar: @app:tbl)."_


