#import "../lib.typ": *

#let highlighted-link(..args) = {
  set text(fill: blue.darken(20%))
  link(..args)
}

= Vorwort <preface>

Die Diplomarbeit ist kein Aufsatz! Auch wenn sie interessant gestaltet werden sollte, ist sie unpersönlich und im passiv zu schreiben. Besonders sind die Quellenangaben, welche entsprechend gewählt und referenziert werden müssen. Innerhalb dieser Vorlage existieren zwei Dateien, die zu genau diesem Zweck erstellt wurden. Die Datei `bibliography.bib` beinhaltet alle Quellenangaben und verwendete Literatur, `glossaries.typ` alle Definitionen von Begriffen und Akronymen, welche in der Arbeit selbst nicht genauer erklärt werden.

Während der Großteil dieser Vorlage nur die Struktur einer typischen Diplomarbeit vorzeigt enthält das Vorwort Informationen zur Verwendung der Vorlage. Es ist natürlich zur Gänze zu ersetzen. Die Informationen hier umfassen neben vorlagenspezifischen Beispielen auch solche, die sich auf Funktionen von Typst oder #highlighted-link("https://typst.app/universe/")[zur Verfügung stehenden Paketen] beziehen und für die Erstellung von Diplomarbeiten nützlich sein können. Es lohnt sich einen Blick in `chapters/vorwort.typ` zu werfen um zu sehen, wie die Beispiele umgesetzt wurden.

== Quellen

Das richtige zitieren spielt innerhalb der wissenschaftlichen Arbeit eine wichtige Rolle. Die Verwaltung von Literatur ist bereits in Typst enthalten. Die Datei `bibliography.bib` ist bereits vorgegeben, es kann aber wie in der Dokumentation beschrieben auch das _Hayagriva_-Format verwendet werden.

Als kleines Beispiel findet sich hier nun ein Zitat über Schall, aus dem ersten Phsyik Lehrbuch der Autoren Schweitzer, Svoboda und Trieb.

#quote(attribution: [@physik1[S. 145]], block: true)[
  "Mechanische Longitudinalwellen werden als Schall bezeichnet. In einem Frequenzbereich von 16 Hz bis 20 kHz sind sie für das menschliche Ohr wahrnehmbar. Liegen die Frequenzen unter diesem Bereich, so bezeichnet man diese Wellen als Infraschall, darüber als Ultraschall."
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

Als allererstes sieht man die ID dieser Quelle, `physik1`, damit lässt sich diese entweder mit ```typ @physik1``` referenzieren, oder mit einer zusätzlichen Detailangabe wie etwa für die Seitenzahl: #box[```typ @physik1[S. 145]```]. Besonders bei direkten Zitaten empfiehlt es sich auch die Seitenzahl anzugeben.

Nach der Verwendung einer Quelle wird diese auch im @bibliography gelistet, welche sich am Ende des Dokuments befindet. Quellen die nicht referenziert werden, werden nicht angezeigt. Es ist also unproblematisch, großzügig Quellen in `bibliography.bib` aufzunehmen: besser mehr Literatur parat zu haben, als sie dann nachträglich suchen zu müssen.

Relevante Dokumentation:

- #highlighted-link("https://typst.app/docs/reference/model/bibliography/")[```typc bibliography()```]
- #highlighted-link("https://typst.app/docs/reference/model/cite/")[```typ @key``` bzw. ```typc cite()```]
- #highlighted-link("https://www.bibtex.com/g/bibtex-format/")[das BibTeX-Dateiformat]
- #highlighted-link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[das Hayagriva-Dateiformat]

== Glossar

Das @glossary enthält Erklärungen von Begriffen und Abkürzen, die im Fließtext keinen Platz haben. Dadurch wird sichergestellt, dass der Lesefluss für Fachkundige nicht gestört wird, die Arbeit aber trotzdem auch für ein breiteres Publikum zugänglich ist. In der Datei `glossaries.typ` werden Begriffe -- oder in diesem Fall eine Abkürzung -- in der folgenden Form definiert:

#figure(
  ```typ
  #glossary-entry(
    "ac:tgm",
    short: "TGM",
    long: "Technologisches Gewerbemuseum",
  )
  ```,
  caption: [Eintrag einer Abkürzung in `glossaries.typ`],
)

Verwendet werden kann dieser Glossareintrag ähnlich einer Quellenangabe durch ```typ @ac:tgm```. Bei der ersten Verwendung wird die Langform automatisch auch dargestellt: @ac:tgm. Bei weiteren Verwendungen wird dagegen nur die Kurzform angezeigt: @ac:tgm.

Das für die Glossar-Funktion im Hintergrund verwendete _Glossarium_-Paket stellt auch weitere Funktionen zur Verfügung, die z.B. bei der Anpassung an die deutschen Fälle hilfreich sein können. Außerdem kann so die Langform erzwungen werden: _diese Diplomarbeit wurde im #gls("ac:tgm", display: "Technologischen Gewerbemuseum") erstellt; "#gls("ac:tgm", long: true)" wird man im Fließtext aufgrund der Struktur der deutschen Sprache wahrscheinlich selten finden._

Relevante Dokumentation:

- #highlighted-link("https://typst.app/universe/package/glossarium/0.4.1/")[das Glossarium-Paket]

== Abbildungen und Gleichungen

Abbildungen, Tabellen, Codestücke und ähnlich eigenständige Inhalte werden oft verwendet, um den Fließtext zu komplementieren. In den vorangegangenen Abschnitten wurden bereits zwei _Auflistungen_, also Codestücke, verwendet. Abbildungen sollten normalerweise im Fließtext referenziert werden, damit die inhaltliche Relevanz explizit klar ist. Zum Beispiel könnte mittels ```typ @fig:picture``` auf die in @lst:figure-definition gezeigte Abbildung verwiesen werden. Die Verweise in diesem Abschnitt benutzen genau diesen Mechanismus, in der PDF-Version der Arbeit sind diese Verweise funktionierende Links. Der Präfix `fig:` wurde dabei durch das _i-figured_-Paket eingefügt und anhand die Art des Inhalts bestimmt, siehe @tbl:figure-kinds. Dieses Paket bewirkt auch, dass Abbildungen nicht durchlaufend nummeriert sind, sondern kapitelweise.

#figure(
  ```typ
  #figure(
    image(...),
    caption: [Ein Bild],
  ) <picture>
  ```,
  placement: auto,
  caption: [Definition einer Abbildung],
) <figure-definition>

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
  caption: [Arten von Abbildungen und deren Präfixe in _i-figured_],
) <figure-kinds>

Es ist in wissenschaftlichen Arbeiten auch üblich, Abbildungen zur besseren Seitennutzung zu verschieben -- normalerweise an den oberen oder unteren Rand einer Seite. In Typst kann dazu ```typc figure(.., placement: auto)``` benutzt werden. Die Abbildungen in diesem Abschnitt benutzen diese Funktionalität: obwohl dieser Absatz im Quelltext nach den Abbildungen kommt, beginnt er vor ihnen und endet erst auf der nächsten Seite, danach. Ob die Ergebnisse der automatischen Platzierung zufriedenstellend sind sollte für die Endversion natürlich nochmal manuell geprüft werden.

Mathematische Gleichungen werden gemäß den Konventionen ein bisschen anders dargestellt und haben in Typst außerdem eine eigene Syntax. Die Definition von @eqt:pythagoras kann im Quelltext des Vorworts eingesehen werden:

$ a^2 + b^2 = c^2 $ <pythagoras>

Relevante Dokumentation:

- #highlighted-link("https://typst.app/docs/reference/model/figure/")[```typc figure()```]
- #highlighted-link("https://typst.app/docs/reference/foundations/label/")[```typ <...>``` bzw. ```typc label()```]
- #highlighted-link("https://typst.app/docs/reference/model/table/")[```typc table()```]
- #highlighted-link("https://typst.app/docs/reference/text/raw/")[````typ ```...``` ```` bzw. ```typc raw()```]
- #highlighted-link("https://typst.app/docs/reference/math/equation/")[```typ $ ... $``` bzw. ```typc math.equation()```]
- #highlighted-link("https://typst.app/universe/package/i-figured/0.2.4/")[das i-figured-Paket]

== Interne Verweise <internal-references>

Neben Referenzen auf Quellen, Abbildungen und Glossar-Einträge kann die ```typ @key```-Syntax auch verwendet werden, um auf Kapitel und Abschnitte zu referenzieren. Da dieses Kapitel mit dem Label ```typ <preface>``` versehen ist lässt sich zum Beispiel mit ```typ @preface``` leicht ein Verweis einfügen: @preface. Gleichermaßen funktioniert ein Verweis auf @internal-references, in dem dieser Text steht. Im PDF sind auch diese Verweise Links.

Einige Teile der Diplomarbeit sind durch die Vorlage mit Labels versehen und können damit wenn nötig referenziert werden:
- @declaration
- #text(lang: "de")[@abstract-de]
- #text(lang: "en")[@abstract-en]
- @contents
- @bibliography
- (#l10n.list-of-figures -- kein Link da in der Vorlage keine "normalen" Abbildungen sind) // @list-of-figures
- @list-of-tables
- @list-of-listings
- @glossary
Da diese Überschriften keine Nummerierung haben, werden Referenzen zu ihnen mit dem vollen Namen dargestellt.
