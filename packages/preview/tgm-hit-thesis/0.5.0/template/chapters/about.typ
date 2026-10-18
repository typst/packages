#import "../lib.typ": *

#let highlighted-link(..args) = {
  set text(fill: blue.darken(20%))
  link(..args)
}

= Über diese Vorlage <about>

Dieses Kapitel enthält Informationen zur Verwendung dieser Vorlage.
Es ist natürlich zur Gänze zu entfernen.
Die Informationen hier umfassen neben vorlagenspezifischen Beispielen auch solche, die sich auf Funktionen von Typst oder #highlighted-link("https://typst.app/universe/")[zur Verfügung stehenden Paketen] beziehen und für die Erstellung von Diplomarbeiten nützlich sein können.
Es lohnt sich einen Blick in `chapters/about.typ` zu werfen um zu sehen, wie die Beispiele umgesetzt wurden.

Die Diplomarbeit ist kein Aufsatz!
Auch wenn sie interessant gestaltet werden sollte, ist sie unpersönlich und im passiv zu schreiben.
Besonders wichtig sind die Quellenangaben, welche entsprechend gewählt und referenziert werden müssen.
Innerhalb dieser Vorlage existieren drei Dateien, die zu genau diesem Zweck erstellt wurden.
Die Datei `bibliography.bib` beinhaltet alle Quellenangaben und verwendete Literatur, `glossaries.typ` alle Definitionen von Begriffen und Akronymen, welche in der Arbeit selbst nicht genauer erklärt werden, `prompts.bib` alle KI-Prompts, die bei der Erstellung benutzt wurden.

Abgesehen vom Grundaufbau mit Kurzfassung/Abstract am Anfang sowie Quellen- und anderen Verzeichnissen am Schluss hängt die Gliederung von der Arbeit sowie der Aufteilung der Inhalte zwischen den Autor:innen ab.
Diese muss also individuell gewählt und mit den jeweiligen Betreuer:innen abgestimmt werden.

== Quellen

Das richtige zitieren spielt innerhalb der wissenschaftlichen Arbeit eine wichtige Rolle.
Die Verwaltung von Literatur ist bereits in Typst enthalten.
Die Dateien `bibliography.bib` und `prompts.bib` sind bereits vorgegeben, es kann aber wie in der Dokumentation beschrieben auch das _Hayagriva_-Format verwendet werden.

Als kleines Beispiel findet sich hier nun ein Zitat über Schall, aus dem ersten Physik Lehrbuch der Autoren #cite(<physik1>, form: "author").

#quote(attribution: [@physik1[S. 145]], block: true)[
  "Mechanische Longitudinalwellen werden als Schall bezeichnet.
  In einem Frequenzbereich von 16 Hz bis 20 kHz sind sie für das menschliche Ohr wahrnehmbar.
  Liegen die Frequenzen unter diesem Bereich, so bezeichnet man diese Wellen als Infraschall, darüber als Ultraschall."
]

In `bibliography.bib` ist die referenzierte Quelle folgendermaßen definiert:

#figure(
  ```bib
  @book{ physik1,
    title = {Physik 1},
    author = {Christian Schweitzer, Peter Svoboda, Lutz Trieb},
    year = {2011},
    subtitle = {Mechanik, Thermodynamik, Optik},
    edition = {7. Auflage},
    publisher = {Veritas},
    pages = {140, 145-150},
    pagetotal = {296}
  }
  ```,
  caption: [Eintrag einer Buchquelle in BibTeX],
)

Als allererstes sieht man die ID dieser Quelle, `physik1`, somit lässt sich diese mit ```typ @physik1``` referenzieren.
Eine zusätzliche Detailangabe wie etwa für die Seitenzahl ist mit ```typ @physik1[S. 145]``` möglich.
Besonders bei direkten Zitaten empfiehlt es sich auch die Seitenzahl anzugeben.


In Fließtext ist es manchmal gewünscht, eine Quelle nicht mit der Nummer im @bibliography anzugeben.
Die Angabe der Autoren über dem Zitat wurde zum Beispiel mit ```typ #cite(<physik1>, form: "author")``` generiert.

Für direkte Zitate gibt es die ```typ #quote()```-Funktion.
Das Zitat oben ist ein Block-Zitat; im Fließtext könnte ein Zitat so aussehen:
#quote(attribution: [@physik1[S. 145]])[Mechanische Longitudinalwellen werden als Schall bezeichnet.]

Nach der Verwendung einer Quelle wird diese auch im @bibliography gelistet, welches sich am Ende des Dokuments befindet.
Quellen die nicht referenziert werden, werden nicht angezeigt.
Es ist also unproblematisch, großzügig Quellen in `bibliography.bib` aufzunehmen:
besser mehr Literatur parat zu haben, als sie dann nachträglich suchen zu müssen.

Relevante Dokumentation:

- #highlighted-link("https://typst.app/docs/reference/model/bibliography/")[```typc bibliography()```] -- das eingebaute Literaturverzeichnis
- #highlighted-link("https://typst.app/docs/reference/model/cite/")[```typ @key``` bzw. ```typc cite()```]
- #highlighted-link("https://typst.app/docs/reference/model/quote/")[```typc quote()```]
- #highlighted-link("https://www.bibtex.com/g/bibtex-format/")[das BibTeX-Dateiformat]
- #highlighted-link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[das Hayagriva-Dateiformat]

== Promptverzeichnis <about:prompts>

Für Diplomarbeiten ist in Österreich ein separates @prompts vorgeschrieben: wenn in der Arbeit KI zur Erstellung von Inhalten verwendet wurde, müssen die dazu eingesetzten Prompts in einem _separaten_ Promptverzeichnis aufgeführt werden.
Diese Vorlage ist so eingerichtet, dass die Prompts in der Datei `prompts.bib` aufgeführt werden, zum Beispiel folgendermaßen:

#figure(
  ```bib
  @misc{ prompt1,
    title = {ChatGPT 4o-mini. Formuliere in sachlicher und neutraler Sprache eine Definition des Begriffs Zitierregeln},
    author = {OpenAI},
    date = {2025-03-12},
  }
  ```,
  caption: [Eintrag eines Prompts für diese Vorlage im BibTeX-Format],
) <lst:bib-prompt>

Das Referenzieren passiert genauso mit ```typ @prompt1```: @prompt1
Wie man sieht ist dieses Zitat von der gleichen Form wie ein normales, allerdings führt die Verlinkung auf das separate @prompts.

Anzumerken ist, dass Zitierregeln für KI-Prompts noch wenig verbreitet sind; @lst:bib-prompt zeigt nur eine Möglichkeit den BibTeX-Eintrag zu strukturieren, wobei die konkret verwendete Technologie im Titel verpackt wird.
Eine andere Variante ist denkbar, solange diese dann konsistent eingesetzt wird.
Es ist empfehlenswert, die Vorgangsweise mit dem bzw. der Betreuer:in abzustimmen.

== Glossar

Das @glossary enthält Erklärungen von Begriffen und Abkürzungen, die im Fließtext keinen Platz haben.
Dadurch wird sichergestellt, dass der Lesefluss für Fachkundige nicht gestört wird, die Arbeit aber trotzdem auch für ein breiteres Publikum zugänglich ist.
In der Datei `glossaries.typ` werden Begriffe -- oder in diesem Fall eine Abkürzung -- in der folgenden Form definiert:

#figure(
  ```typ
  #glossary-entry(
    "tgm",
    short: "TGM",
    long: "Technologisches Gewerbemuseum",
  )
  ```,
  caption: [Eintrag einer Abkürzung in `glossaries.typ`],
)

Verwendet werden kann dieser Glossareintrag ähnlich einer Quellenangabe durch ```typ @tgm```.
Bei der ersten Verwendung wird die Langform automatisch auch dargestellt: @tgm.
Bei weiteren Verwendungen wird dagegen nur die Kurzform angezeigt: @tgm.

Das für die Glossar-Funktion im Hintergrund verwendete _Glossarium_-Paket stellt auch weitere Funktionen zur Verfügung, die z.B. bei der Anpassung an die deutschen Fälle hilfreich sein können.
Außerdem kann so die Langform erzwungen werden:
_diese Diplomarbeit wurde im #gls("tgm", display: "Technologischen Gewerbemuseum") erstellt; "@tgm:long" wird man im Fließtext aufgrund der Struktur der deutschen Sprache wahrscheinlich selten finden._

Relevante Dokumentation:

- #highlighted-link("https://typst.app/universe/package/glossarium/0.5.9/")[das Glossarium-Paket]

#set-current-authors("Arthur Dent", "Tricia McMillan")

== Autorenschaft innerhalb des Dokuments

Innerhalb der Diplomarbeit ist es notwendig, dass die individuelle Autorenschaft der einzelnen Teile nachvollzogen werden kann.
Üblich ist dafür, dass die Autoren in der Fußzeile angegeben werden. In dieser Vorlage kann aus zwei Modi gewählt werden: ```typc current-authors: "highlight"``` zeigt alle Autoren in der Fußzeile an, druckt aber die aktuellen Autoren fett; ```typc current-authors: "only"``` zeigt nur die aktuellen Autoren in der Fußzeile an.

Vor diesem Abschnitt wurden die Autoren auf _Arthur Dent_ und _Tricia McMillan_ gesetzt (siehe den Quellcode dieses Kapitels), deshalb sind diese ab dieser Seite fett gedruckt.

== Abbildungen und Gleichungen

Abbildungen, Tabellen, Codestücke und ähnlich eigenständige Inhalte werden oft verwendet, um den Fließtext zu komplementieren.
In den vorangegangenen Abschnitten wurden bereits zwei _Auflistungen_, also Codestücke, verwendet.
Abbildungen sollten normalerweise im Fließtext referenziert werden, damit die inhaltliche Relevanz explizit klar ist.
Zum Beispiel könnte mittels ```typ @lst:figure-definition``` auf den in @lst:figure-definition gezeigten Code verwiesen werden.
Die Verweise in diesem Abschnitt benutzen genau diesen Mechanismus, in der PDF-Version der Arbeit sind diese Verweise funktionierende Links.
Der Präfix `lst:` dient dabei rein der Übersicht und kann bei Präferenz ausgelassen werden.
@tbl:figure-kinds zeigt übliche/vorgeschlagene Präfixe.
In dieser Vorlage werden Abbildungen nicht durchlaufend sondern kapitelweise nummeriert.

#figure(
  ```typ
  #figure(
    image(...),
    caption: [Ein Bild],
  ) <picture>
  ```,
  placement: auto,
  caption: [Definition einer Abbildung],
) <lst:figure-definition>

#figure(
  table(
    columns: 4,
    align: (center,) * 3 + (left,),
    table.header(
      [Supplement], [Inhalt], [Präfix], [Anmerkung],
    ),
    [Abbildung], [```typ image()```], [`fig:`], [Standard-Abbildungsart für andere Inhalte],
    [Tabelle], [```typ table()```], [`tbl:`], [],
    [Auflistung], [```typ raw()```], [`lst:`], [```typ raw()``` hat auch die Spezial-Syntax ```typ `...` ``` oder  ````typ ```...``` ````],
    [Gleichung], [```typ math.equation()```], [`eqt:`], [```typ math.equation()``` hat auch die Spezial-Syntax ```typ $ ... $```],
  ),
  placement: auto,
  caption: [Arten von Abbildungen und empfohlene Präfixe],
) <tbl:figure-kinds>

Es ist in wissenschaftlichen Arbeiten auch üblich, Abbildungen zur besseren Seitennutzung zu verschieben -- normalerweise an den oberen oder unteren Rand einer Seite.
In Typst kann dazu ```typc figure(.., placement: auto)``` benutzt werden.
Die Abbildungen in diesem Abschnitt benutzen diese Funktionalität:
obwohl dieser Absatz im Quelltext nach den Abbildungen kommt, beginnt er vor ihnen, auf der vorherigen Seite.
Ob die Ergebnisse der automatischen Platzierung zufriedenstellend sind sollte für die Endversion natürlich nochmal manuell geprüft werden.

Mathematische Gleichungen werden gemäß den Konventionen ein bisschen anders dargestellt und haben in Typst außerdem eine eigene Syntax.
Die Definition von @eqt:gauss kann im Quelltext dieses Kapitels eingesehen werden:

$ integral_(-infinity)^infinity e^(-x^2) dif x = sqrt(pi) $ <eqt:gauss>

Relevante Dokumentation:

- #highlighted-link("https://typst.app/docs/reference/model/figure/")[```typc figure()```]
- #highlighted-link("https://typst.app/docs/reference/foundations/label/")[```typ <...>``` bzw. ```typc label()```]
- #highlighted-link("https://typst.app/docs/reference/model/table/")[```typc table()```]
- #highlighted-link("https://typst.app/docs/reference/text/raw/")[````typ ```...``` ```` bzw. ```typc raw()```]
- #highlighted-link("https://typst.app/docs/reference/math/equation/")[```typ $ ... $``` bzw. ```typc math.equation()```]

== Interne Verweise <internal-references>

Neben Referenzen auf Quellen, Abbildungen und Glossar-Einträge kann die ```typ @key```-Syntax auch verwendet werden, um auf Kapitel und Abschnitte zu referenzieren.
Da dieses Kapitel mit dem Label ```typ <about>``` versehen ist lässt sich zum Beispiel mit ```typ @about``` leicht ein Verweis einfügen: @about.
Gleichermaßen funktioniert ein Verweis auf @internal-references, in dem dieser Text steht.
Im PDF sind auch diese Verweise Links.

Einige Teile der Diplomarbeit sind durch die Vorlage mit Labels versehen und können damit wenn nötig referenziert werden:

- @declaration
- #text(lang: "de")[@abstract-de]
- #text(lang: "en")[@abstract-en]
- @contents
- @bibliography
- @prompts
- (#l10n.list-of-figures -- kein Link da in der Vorlage keine "normalen" Abbildungen sind) // @list-of-figures
- @list-of-tables
- @list-of-listings
- @glossary

Da diese Überschriften keine Nummerierung haben, werden Referenzen zu ihnen mit dem vollen Namen dargestellt.

== Unterstützung erhalten <support>

#block(sticky: true)[
  Für diesen Abschnitt wechsle ich bewusst in die persönliche Form.
  Die Informationen in diesem Kapitel sind ein Startpunkt zur Erstellung einer Diplomarbeit, aber sicher lässt sie Fragen offen.
  Zum Glück gibt es einige Wege und Anlaufstellen, wo du Hilfestellungen finden kannst:
]

- Für einen allgemeinen Einstieg in Typst gibt es die Typst-Dokumentation.
  Das #highlighted-link("https://typst.app/docs/tutorial/")[Tutorial] behandelt grundlegend das Schreiben und Gestalten -- wobei die Vorlage beim Gestalten schon einiges vorgibt.
  Die #highlighted-link("https://typst.app/docs/reference/")[Referenz] beinhaltet die API-Dokumentation und listet somit alle verfügbaren Funktionen und Optionen auf.

- Bei konkreten Problemen mit Typst sind der #highlighted-link("https://discord.gg/2uDybryKPe")[Discord-Server] und das #highlighted-link("https://forum.typst.app/")[Forum] die primären Anlaufstellen.
  Beide sind sehr aktiv, je nach Komplexität der Fragen bekommst du hier Antworten oft in wenigen Minuten oder zumindest Stunden.
  Beachte beim Posten bitte die jeweiligen Community- und Postingregeln.

  Bei einfacheren Fragen sind natürlich auch Chatbots eine Option, obwohl manche immer noch Markdown-, LateX- und Typst-Syntax vermischen.

- Fragen spezifisch zu dieser Vorlage kannst du auch auf beiden Plattformen stellen.
  Zusätzlich ist dann ein #highlighted-link("https://github.com/TGM-HIT/typst-diploma-thesis/issues")[Github Issue] eine option -- gerade dann wenn es darum geht, vorgegebene Features der Vorlage anzupassen.
  Sollte ein neues oder geändertes Feature notwendig sein setze ich dieses gerne um; melde das aber früh genug, damit sich Umgesetzung und Veröffentlichung vor der Diplomarbeitsabgabe ausgehen.
  Pull Requests sind natürlich auch gerne gesehen.

- Für TGM-Schüler:innen bin ich auch persönlich oder per Email erreichbar.
  Meine Email-Adresse und mein Stundenplan sollten leicht zu finden sein.

Ich hoffe, dass diese Vorlage dir und deinem Team beim Schreiben der Diplomarbeit gute Dienste leistet.
Ich freue mich über eure Erfahrungsberichte, hoffentlich kann ich die Vorlage so noch weiter verbessern.

-- Clemens Koza
