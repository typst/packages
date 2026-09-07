#import "dol-theme.typ": *

#let version = "0.1.0"

#set document(title: "dol-theme", author: "Merlin Jonathan Fischer")

#set text(
  lang: "de",
)

#set page(
  header: [
    #box(baseline: bottom, image("assets/logosColors.pdf", height: 1.5cm))
    #h(1fr)
    #box(baseline: bottom, align(right, emph({
      [Dokumentation DOL-Theme]
      v(1.5em)
    })))
  ],
  margin: (top: 4cm),
  numbering: "1",
)

#set heading(numbering: "1.")

#set raw(lang: "typst")

#let code(contents) = {
  let kwargs = contents.fields()
  let text-raw = kwargs.remove("text").replace("{version}", version)
  let contents = raw(text-raw, ..kwargs)
  block(
    stroke: 1pt + luma(140),
    inset: (left: 8pt, right: 8pt, top: 10pt, bottom: 12pt),
    width: 100%,
    breakable: false,
    radius: 5pt,
    text(10.8pt, contents)
  )
}

#set par(justify: true)

#let dol-color = rgb("#03989e")

#show strong: it => text(dol-color, it)

#show link: set text(dol-color.darken(50%))


//////////////////////////

#align(center)[
  #v(3.5em)

  #text(2em)[DOL-Theme]

  #text(1.4em)[Vorlage für Klausuraufgaben der Deutschen Linguistikolympiade (DOL)]

  #v(1em)

  #text(1em)[Version #version]

  #text(1.4em, datetime.today().display("[month repr:long] [year]"))

  #v(2em)
]

= Initialisierung<initialisation>
Um das DOL-Theme zu verwenden, importiere es zunächst und setze anschließend die Konfiguration über die `#show`-Regel `dol-theme`.

#code(
  ```
  #import "@preview/dol-theme:{version}": *
  #show: dol-theme.with(
    title: [Rätselsprache],
    author: [Jonta Ikaluk],
    points: 24,
    composition: [8+2+3+5+6]
  )
  ```
)

= Rätsel
Jedes Rätsel wird in einer eigenen typst-Datei gesetzt und mit obiger Initialisierung begonnen.

Jede Teilaufgabe wird durch `#task` eingeleitet. Die Punkte der Teilaufgaben werden als Summe `composition` in der Initialisierung angegeben.

#code(
  ```
  #task Ordne die deutschen Übersetzungen den Sätzen der Rätselsprache zu.
  ```
)

= Counter
Das DOL-Theme bietet zwei Funktionen zur Inkrementierung und Darstellung von Countern.

#grid(columns: (10fr, 1fr, 2fr), column-gutter: 15pt)[
  #code(
    ```
    #let a = counter("raetsel-a")

    #numstep(a) lipu
    #numstep(a) ni
    #numstep(a) li
    #a.update(0)
    #letstep(a) nasin
    #letstep(a) kepeken
    #letstep(a) sitelen
    ```
  )
][
  #v(1fr)
  #text(24pt)[$arrow.double$]
  #v(1fr)
][
  #set text(size: 10pt)
  #set par(leading: 6pt)
  #v(3.3em)
  1. lipu
  2. ni
  3. li
  #v(0.6em)
  A. nasin\
  B. kepeken\
  C. sitelen
]

= Tabellen
Folgende Tabellen-Designs sind für das Darstellen der Rätsel-Daten voreingestellt. Ein Tabellen-Designs wird mit ``` #show: ...-table``` für alle nachfolgenden Tabellen aktiviert. Um ein Tabellen-Design nur für eine Tabelle anzuwenden, platziere entsprechende ``` #show```-Regel und diese Tabelle in eine Klammer, um einen lokalen Skopus zu erstellen.

== matching-table

*Bei Aktivierung des DOL-Themes ist dies das voreingestellte Tabellenvormat.*

Diese Tabelle ist für solche Aufgaben, bei denen Phrasen der Rätselsprache den deutschen Entsprechungen zugeordnet werden sollen.

Hierbei wird die Rätselsprache fett, die deutschen (unsortierten) Übersetzungen kursiv linksbündig ausgedruckt. Alle Counter (Spalten 0 und 2) sind rechtsbündig.

#code(
  ```
  #let a = counter("tokipona")
  #let b = counter("tokipona2")
  #show: matching-table
  #table(
    numstep(a), [mi jan pi nasin sewi], letstep(b), [Sie ist keine Angestellte.],
    numstep(a), [ona li jan pali ala], letstep(b), [Er befindet sich hier im Haus.],
    numstep(a), [sina jan pi kama sona anu seme], letstep(b), [Bist du ein Student?],
    numstep(a), [ona li lon tomo ni], letstep(b), [Ich bin ein Mönch.],
  )
  ```
)

#let a = counter("tokipona")
#let b = counter("tokipona2")
#show: matching-table
#table(
  numstep(a), [mi jan pi nasin sewi], letstep(b), [Sie ist keine Angestellte.],
  numstep(a), [ona li jan pali ala], letstep(b), [Er befindet sich hier im Haus.],
  numstep(a), [sina jan pi kama sona anu seme], letstep(b), [Bist du ein Student?],
  numstep(a), [ona li lon tomo ni], letstep(b), [Ich bin ein Mönch.],
)

== translation-table
Diese Tabelle ist für Phrasen der Rätselsprache mitsamt den zugeordneten deutschen Übersetzungen.
Die Einstellungen sind wie die der ``` matching-table```, nur ohne den zweiten Counter.

#code(
  ```
  #let a = counter("tokipona3")
  #show: translation-table
  #table(
    numstep(a), [soweli li lon tomo lipu lili], [Die Katze befindet sich im Karton.],
    numstep(a), [ni li tomo mi ala], [Das ist nicht mein Haus.],
    numstep(a), [ona li jan pi kama sona], [Er ist Student.],
  )
  ```
)

#let a = counter("tokipona3")
#show: translation-table
#table(
  numstep(a), [soweli li lon tomo lipu lili], [Die Katze befindet sich im Karton.],
  numstep(a), [ni li tomo mi ala], [Das ist nicht mein Haus.],
  numstep(a), [ona li jan pi kama sona], [Er ist Student.],
)

== number-table
Diese Tabelle verzichtet auf beide Counter und richtet die in der rechten Spalte stehenden Ziffern rechtsbündig aus.

#code(
  ```
  #show: number-table
  #table(
    [wan], [1],
    [tu wan], [3],
    [ale mute mute mute luka tu wan], [168],
    [kijetesantakalu kijetesantakalu], [$x: 6 <= x <= 36$]
  )
  ```
)

#show: number-table
#table(
  [wan], [1],
  [tu wan], [3],
  [ale mute mute mute luka tu wan], [168],
  [kijetesantakalu kijetesantakalu], [$x: 6 <= x <= 36$]
)

== booktabs-table
Diese Tabelle formatiert horizontale Linien entsprechend des _booktabs_-Stils zur Strukturierung von Regeln.

#code(
  ```
  #show: booktabs-table
  #figure(
    table(
      columns: 3,
      [Person], [Pronomen], [Verbpartikel],
      [1], [mi], table.cell(rowspan: 2, align: horizon)[$emptyset$],
      [2], [sina],
      [3], [ona], [li]
    )
  )
  ```
)

#show: booktabs-table
#figure(
  table(
    columns: 3,
    [Person], [Pronomen], [Verbpartikel],
    [1], [mi], table.cell(rowspan: 2, align: horizon)[$emptyset$],
    [2], [sina],
    [3], [ona], [li]
  )
)

== standard-table
Diese Tabelle setzt alle Parameter zurück, sodass individuelle Tabellen von Grund auf gestaltet werden können.

#code(
  ```
  #show: standard-table
  ...
  ```
)

= Lösungen
Die Lösungen eines Rätsels werden korrespondierend zu den Teilaufgaben des Rätsels in eine eigene Datei (z.~B. *`raetsel-solution.typ`*) gesetzt. Verwende hierbei dieselbe #link(<initialisation>)[Initialisierung] wie bei Rätseln, füge aber den Parameter `solution=true` hinzu. Dadurch wird die Lösung als solche formatiert.

(Der Parameter `author` kann zwar angegeben werden, wird bei Lösungen allerdings nicht angezeigt.)

#code(
  ```
  #import "@preview/dol-theme:{version}": *
  #show: dol-theme.with(
    title: [Rätselsprache],
    points: 24,
    composition: [8+2+3+5+6],
    solution: true
  )
  ```
)

Verlinke die `raetsel-solution.typ` in den Initialisierung der entsprechenden Aufgabendatei *`raetsel.typ`*. Das wird allerdings erst bei der #link(<publication>)[Veröffentlichung] verwendet.

#code(
  ```
  #import "@preview/dol-theme:{version}": *
  #show: dol-theme.with(
    title: [Rätselsprache],
    ...,
    solution-file: include "raetsel-solution.typ"
  )
  ```
)

= Rätsel-Set
Ein Rätsel-Set wird in einer eigenen typst-Datei (z.~B. *`dol26-1.typ`*) aus mehreren Rätseln (im selben Ordner) über die `#show`-Regel `compile-problems` kompiliert.

Setze mit den Variablen `time` und `editors` die für die Runde angesetzte Bearbeitungszeit (in Worten) und alle Namen der Redaktion. Diese werden auf der ersten Seite des Rätsel-Sets eingefügt.

#code(
  ```
  #import "@preview/dol-theme:{version}": compile-problems
  #show: compile-problems.with(
    time: [3 Stunden und 30 Minuten],
    editors: [Person 1, Person 2, Person 3, ...]
  )

  #include "problem1.typ"
  #include "problem2.typ"
  #include "problem3.typ"

  #counter(heading).update(0)

  #include "problem1-solution.typ"
  #include "problem2-solution.typ"
  #include "problem3-solution.typ"
  ```
)

== Jahr und Runde
Um das Rätselset zu erstellen, müssen jetzt noch die *globalen Variablen* *`year`* und *`round`* gesetzt werden. Das geht auf folgende drei Arten.

=== Manuelle Kompilierung<global-var>
Bei manueller Kompilierung durch die Kommandozeile können die globalen Variablen durch #raw(lang: none, "--input")-Parameter gesetzt werden.
#code(
  ```shell
  typst compile --input year=2026 --input round=1 dol26-1.typ dol26-1.pdf
  ```
)


=== Tinymist & VSCode
Bei automatischer Kompilierung durch Tinymist in VSCode können die Input-Parameter durch eine JSON-Datei für den ganzen Ordner gesetzt werden. Dazu muss im entsprechenden Ordner ein Ordner *`.vscode/`* erstellt werden und darin die Datei *`settings.json`*:
#code(
  ```json
  {
    "tinymist.typstExtraArgs": [
      "--input", "year=2026",
      "--input", "round=1",
      "dol26-1.typ"
    ]
  }
  ```
)

=== Rätselspezifisch
Die Parameter `year` und `round` können auch lokal in der #link(<initialisation>)[Initialisierung] der einzelnen Rätsel gesetzt werden. Eine globale Setzung der Variablen durch Input-Parameter überschreibt diese lokale Setzung.

#code(
  ``` #import "@preview/dol-theme:{version}": *
  #show: dol-theme.with(
    ...,
    year: 2026,
    round: 1
  )```
)

== Anonymisierung der Rätsel // in punkt davor einbetten
Für Online-Runden können Rätsel durch setzen des Parameters *`metadata=false`* anonymisiert werden. Dabei werden der Autorenname und der Rätseltitel versteckt.

Dieser Parameter kann sowohl durch #link(<global-var>)[globale Variablen] als auch in der #link(<initialisation>)[Initialisierung] gesetzt werden. Er hat keinen Effekt, wenn der Parameter `publish==true`.

#grid(columns: (1fr, 1fr), column-gutter: 1em)[
  #code(```shell ... --input metadata=false ...```)
  #v(-0.5em)
  #code(```json ..., "--input", "metadata=false", ...```)
][
  #code(
    ```
    #show: dol-theme.with(
      ...,
      metadata: false
    )
    ```
  )
]

= Veröffentlichung<publication>

Für die spätere Veröffentlichung erhalten die Rätsel ein erweitertes Layout durch die globale Variable *`publish=true`*, die wie `metadata` #link(<global-var>)[global] oder #link(<initialisation>)[lokal] gesetzt werden kann.

In der #link(<initialisation>)[Initialisierung] der Rätseldatei *`raetsel.typ`* kommen weitere Parameter hinzu. Diese werden nur im `publish`-Modus verwendet, können daher beim Setzen des Rätsels für die Klausur direkt mit angegeben werden. 

#code(
  ```
  #import "@preview/dol-theme:{version}": *
  #show: dol-theme.with(
    title: [Rätselsprache],
    ...,
    longtitle: [Grammatisches Phänomen in der Rätselsprache],
    background: [Hintergrund und Quellen ...],
    solution-file: include "raetsel-solution.typ" // <– publish=true
  )
  ```
)

- `longtitle`: Ein detaillierterer Titel, der im `publish`-Modus ausschließlich verwendet wird (auch für die Lizenz). Wenn nichts angegeben ist, wird `title` verwendet.
- `background`: Ein ganzer Paragraph mit Hintergrundinformationen, der den eigentlichen Aufgaben vorangestellt wird. Hier sollen auch Quellen zitiert werden.
- `solution-file`: Hier wird die entsprechende Lösungsdatei `raetsel-solution.typ` verlinkt, um sie in der gleichen Datei mit auszudrucken. Wichtig ist, dass `raetsel-solution.typ` ebenfalls `publish=true` eingestellt hat (global passiert das automatisch), und dass der Befehl `include` dem Dateinamen vorangestellt ist.


= Konfigurationen
Vollständige Liste der Argumente von `dol-theme` und `compile-problems`. Die Defaultwerte sind bei Booleans die angegebenen, überall sonst `none`.

Außerdem die internen Konfigurationen der exportierten Funktionen.

== Initialisierung (`dol-theme`)
#code(
  ```
  #import "@preview/dol-theme:{version}": *
  #show: dol-theme.with(
    title: [Rätselsprache],                             // hidden when metadata==false
    longtitle: [Grammatisches Phänomen in der Rätselsprache],           // for publish
    author: [Jonta Ikaluk],                  // hidden when metadata==false
    points: 24,                                                                 // int
    composition: [8+2+3+5+6],                               // sum should equal points
    background: [Hintergrund und Quellen ...],                          // for publish
    solution: false,                      // DEFAULT      true in raetsel-solution.typ
    solution-file: include "raetsel-solution.typ", // for publish, only in raetsel.typ
    year: 2026,                  // GLOBAL             ### These global parameters ###
    round: 1,                    // GLOBAL             ###  should be entered via  ###
    metadata: true,              // GLOBAL   DEFAULT   ### --input options during  ###
    publish: false               // GLOBAL   DEFAULT   ### compilation (see 6.1-7) ###
  )
  ```
)

== Rätsel-Set (`compile-problems`)
#code(
  ```
  #import "@preview/dol-theme:{version}": compile-problems
  #show: compile-problems.with(
    time: [3 Stunden und 30 Minuten],
    editors: [Person 1, Person 2, Person 3, ...],
    year: 2026,                  // GLOBAL                               ###  see  ###
    round: 1,                    // GLOBAL                               ### above ###
  )
  ```
)

== Counter
#code(
  ```
  #let task-counter = counter("task")
  #let task = {
    task-counter.step()
    box(width: 2em, context strong(task-counter.display("(a)")))
  }
  ```
)

#code(
  ```
  #let numstep(counter) = {
    counter.step()
    context counter.display("1.")
  }
  ```
)

#code(
  ```
  #let letstep(counter) = {
    counter.step()
    context counter.display("A.")
  }
  ```
)

== Tabellen

=== `matching-table`
#code(
  ```
  #show table.cell.where(x: 1): set text(weight: "bold")
  #show table.cell.where(x: 3): set text(style: "italic")
  #set table(
    stroke: none,
    columns: 4,
    align: (right, left, right, left),
    column-gutter: (0em, 6em, 0em),
  )
  ```
)

=== `translation-table`
#code(
  ```
  #show table.cell.where(x: 1): set text(weight: "bold")
  #show table.cell.where(x: 2): set text(style: "italic")
  #set table(
    stroke: none,
    columns: 3,
    align: (right, left, left),
    column-gutter: (0em, 2em),
  )
  ```
)

=== `number-table`
#code(
  ```
  #show table.cell.where(x: 0): set text(weight: "bold")
  #show table.cell.where(x: 1): set text(weight: "regular")
  #set table(
    stroke: none,
    columns: 2,
    align: (left, right),
    column-gutter: 2em,
  )
  ```
)

=== `booktabs-table`
#code(
  ```
  #show table.cell: set text(weight: "regular")
  #show table.cell: set text(style: "normal")
  #show table: set table(
    stroke: (x, y) => (
      top: if y == 0 { 1pt } else if y == 1 { 0.7pt } else { 0pt },
      bottom: 1pt,
    ),
  )
  #set table(
    stroke: 1pt + black,
    columns: (),
    align: auto,
    column-gutter: (),
  )
  ```
)

=== `standard-table`
#code(
  ```
  #show table.cell: set text(weight: "regular")
  #show table.cell: set text(style: "normal")
  #set table(
    stroke: 1pt + black,
    columns: (),
    align: auto,
    column-gutter: (),
  )
  ```
)