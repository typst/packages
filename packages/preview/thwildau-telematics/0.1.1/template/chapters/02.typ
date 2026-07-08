#import "@preview/thwildau-telematics:0.1.1": (
  abbreviation, conf, define-abbreviation, define-unit, define-glossary, infocard, tables, th-color, todo, unit, glossary
)

// ---------- german ----------

= TH-Wildau Telematik Vorlage (deutsch)

Dies ist die offizielle Typst-Vorlage des Telematik Studiengangs der Technischen Hochschule Wildau. Sie hilft dir dabei, eine professionell aussehende Abschlussarbeit zu erstellen – mit minimalem Stylingaufwand und ohne tiefgehende Typst-Kenntnisse. Wenn du es bereits geschafft hast, das PDF zu rendern, das du gerade ansiehst, kannst du direkt mit dem Schreiben deiner Arbeit beginnen.
Aber diese Vorlage ist nicht leer! In den folgenden Kapiteln erfährst du genau, was sie dir bietet und wie du sie nutzt.
Viel Spaß!

== Konfiguration der Vorlage
Auf den ersten Blick mag die Anzahl der Argumente für dieses Template zwar nach einer Menge aussehen, die meisten sind jedoch recht selbsterklärend. Die komplette Konfiguration, welche für dieses Dokument verwendet wurde, kann in der `main.typ` gefunden werden. In diesem Kapitel werden die einzigen Argumente Stück für Stück erklärt, aus denen sich eine Konfiguration für das Template ergibt. Um alles zusammensetzten zu können ist grundlegendes Wissen über #link("https://typst.app/docs/reference/foundations/dictionary/")[Dictionaries] in Typst nötig.

Um das thwildau-telematics Template zu konfigurieren, muss es zuerst importiert werden.
#figure(
  caption: [Import the template],
)[
  ```typst
  #import "@preview/thwildau-telematics:0.1.1": (
    abbreviation, conf, define-abbreviation, define-unit, define-glossary, infocard, tables, th-color, todo, unit, glossary
  ) // TH-Wildau Template

  // Template Konfiguration
    #show: conf.with(
      deine Konfigurationen...
    )
  ```]

Die meisten Konfigurationsargumente hängen mit spezifischen Seiten oder Abschnitten des Templates zusammen. Diese werden in #ref(<pages-de>) erklärt. Die einzigen allgemeinen Argumente sind die Folgenden:

#figure(
  caption: "Konfigurationsargumente",
  table(
    columns: 3,
    table.header([Name], [Standardwert], [Beschreibung]),
    [#`title`],
    [#`none`],
    [Mit diesem Wert wird der Titel der Thesis definiert. Das Feld ist verpflichtend und sollte ein string sein. Im Template wird der Titel unter anderem in der Kopfzeile der meisten Seiten, aber auch zum Beispiel auf der Titelseite verwendet.],

    [#`language`],
    [#`"de"`],
    [Setzt die #link("https://typst.app/docs/reference/text/text#parameters-lang")[Sprache] des Texts. Kann außerdem statische Textelemente des Templates #link(<translation-de>)[übersetzen].],

    [#`bibliography`],
    [#`none`],
    [Die Bibliografie versorgt das Template mit den verwendeten Quellennachweisen. In den #link("https://typst.app/docs/reference/model/bibliography/")[Docs] wird die Typst Funktion umfassend erklärt.],
  ),
)

Die komplette Konfiguration könnten dann beispielsweise so aussehen:

#figure(caption: [Full template config example])[
  ```typst
  #show: conf.with(
    // Titel der Thesis
    title: "TH-Wildau Typst Template",
    // your info
    student: (
      name: "Clara Fall",
      matrnr: "12345678",
      subject: "Praxisintegrierender Bachelor Studiengang Telematik",
      seminar-group: "T23",
      semester: "4",
    ),
    // Dein Betreuer
    supervisor: (
      name: "Frau Dr. Lieschen Müller",
      mail: "mueller@beispielag.de",
    ),
    // Angaben zum Praktikum
    internship: (
      type: "3. Betriebspraktikum",
      partner: [Beispiel AG \ Straßenweg 1 \ 12345 Musterstadt \ #link("https://beispielag.de")],
      period: "16.06.2025 bis 25.07.2025",
    ),
    // Deine Bibliographie
    bibliography: bibliography("bib.yaml"),
    // language of this document
    language: "de",
    // Generiere verschiedene vordefinierte Seiten
    misc-pages: (
      // Bibliographische Beschreibung
      bibliographic-description: (
        de: (
          title-long: "TH-Wildau Telematics Typst Template für Thesis und Praktikumsbericht",
          metadata: " ",
          keywords: "Typst, Thesis, Template, TH-Wildau, Telematik",
          goal: [Erstellung eines neue Typst Projektes mit dem TH-Wildau Telematics Template.],
          abstract: [In dieser Arbeit wird erklärt, wie das darin verwendete TH-Wildau Telematics Typst-Template konfiguriert und angewendet werden kann.],
        ),
        en: (
          title-long: "TH-Wildau Typst template for thesis and intership.",
          metadata: " ",
          keywords: "Typst, Thesis, Template, TH-Wildau, Telematics",
          goal: [Creation of a new typst project with the TH-Wildau Telematics template.],
          abstract: [This thesis aims to explain the process of installing, configuring and applying the TH-Wildau Telematics typst template.],
        ),
      ),
      // Füge Leserhinweise an
      reading-guides: [Für diese Arbeit ist grundlegendes Wissen über die Sprache Typst von Vorteil.#linebreak() For this template it is advised to first understand the basic concepts of the typst language.],
      authorship-declaration: true,
      company-confirmation: true,
      glossary: (("Telematik", "Die Kombination aus Telekommunikation und Informatik"),),
      appendix: include "chapters/appendix.typ",
    ),
  )
  ```] <conf-example-de>


=== Fehlerbehandlung
Die gegebenen Konfigurationen werden vom Template automatisch auf ihre Vollständigkeit überprüft. Sollte eine obligatorische Angabe fehlen, so gibt der Typst Compiler einen Fehler aus. Am Anfang der Ausgabe befinden sich dabei genauere Informationen dazu, was genau fehlt. Im folgenden Beispiel fehlt bei dem set `student` die Angabe `matrnr`. In der Fehlermeldung ist auch ein Beispielwert gegeben. Das Beispiel `"12345678"` zeigt dabei auch, dass die fehlende Angabe vom Datentyp `string` sein kann.

#figure(caption: [Konfigurations-Fehlerausgabe Beispiel])[
  ```typst
  error: assertion failed:
  Missing variable in configuration: student.matrnr
  For example:    student.matrnr: "12345678"
  Please add the missing definition to your configuration of the thwildau-telematics template.
     ─ @preview/thwildau-telematics:0.1.1/utils/user_input.typ:7:2
  ```]


== Seiten <pages-de>
Neben dem Styling erzeugt diese Vorlage automatisch eine Reihe zusätzlicher Seiten rund um deine Arbeit, darunter die Titelseite, verschiedene Inhaltsverzeichnisse und das Literaturverzeichnis. Einige davon sind standardmäßig aktiviert, können aber deaktiviert werden, während andere manuell hinzugefügt werden müssen.

=== Titelseite
Dieses Template bietet auch eine Titelseite, aber da je nach aktueller Regelung ein Deckblatt von der TH-Wildau vorgegeben wird, kann die Titelseite auch durch etwas anderes ersetzt werden. Das Deckblatt des Templates ist also eher für andere Belegarbeiten, welche ebenfalls in einem wissenschaftlichen Stil verfasst werden sollen.
Im folgenden Beispiel wird die Titelseite durch eine externe, einseitige PDF ersetzt.
#figure(caption: [Replace title page])[
  ```typst
    titlepage: (
      content: [
        #page(
          background: image("test.pdf", fit: "cover"),
        )[]
      ],
    )
  ```]
Das funktioniert, da `titlepage` auch direkt typst `content` als Wert akzeptiert. Dieser wird dann einfach anstelle der Titelseite eingefügt. In diesem Fall ist der gegebene `content` eine leere Seite, mit dem PDF-Deckblatt als füllenden Hintergrund.

=== Bibliographische Beschreibung
Die bibliographische Beschreibung gibt einen groben Überblick über den Inhalt deiner Thesis und dient auch der Kategorisierung selbiger. Sie kann für mehrere Sprachen generiert werden, indem einfach mehrere Sprachen mit dafür in der Konfiguration definiert werden. Jedoch ist dafür auch eine Übersetzung der statischen Textelemente der Seite nötig, wobei das Template selbst nur die Sprachen Deutsch und Englisch mitbringt. Für weitere Sprachen muss Text also #link(<translation-de>, [selbst übersetzt]) werden.
#figure(caption: [Enable _bibliographic description_ page(s)])[
  ```typst
  misc-pages: (
    bibliographic-description: (
      de: (
        title-long: "TH-Wildau Telematics Typst Template für Thesis und Praktikumsbericht",
        metadata: " ",
        keywords: "Typst, Thesis, Template, TH-Wildau, Telematik",
        goal: [Erstellung eines neue Typst Projektes mit dem TH-Wildau Telematics Template.],
        abstract: [In dieser Arbeit wird erklärt, wie das darin verwendete TH-Wildau Telematics Typst-Template konfiguriert und angewendet werden kann.],
      ),
      en: (
        title-long: "TH-Wildau Typst template for thesis and intership.",
        metadata: " ",
        keywords: "Typst, Thesis, Template, TH-Wildau, Telematics",
        goal: [Creation of a new typst project with the TH-Wildau Telematics template.],
        abstract: [This thesis aims to explain the process of installing, configuring and applying the TH-Wildau Telematics typst template.],
      ),
    ),
  )
  ```]

=== Hinweise zum Lesen der Arbeit
Mit den _Hinweisen zum Lesen der Arbeit_ kannst du deinen Lesern weiteren Kontext bieten, um deine Thesis zu verstehen.
#figure(caption: [_Hinweise zum Lesen der Arbeit_ hinzufügen])[
  ```typst
  misc-pages: (
    reading-guides: [Dein Text]
  )
  ```]

=== Bestätigung des Praxisunternehmens
Solltest du deine Thesis bei einem externen Unternehmen schreiben oder das Template für einen Praxisbelegsbericht verwenden, so wird möglicherweise auch die Bestätigung des Praxisunternehmens von deiner Arbeit gefordert.
#figure(caption: [_Bestätigung des Praxisunternehmens_ hinzufügen])[
  ```typst
  misc-pages: (
    company-confirmation: true
  )
  ```]

=== Selbstständigkeitserklärung
Um zu bestätigen, dass du der Autor deiner Thesis bist, kann die im Template enthaltene _Selbstständigkeitserklärung_ Teil deiner Arbeit sein. Je nach aktueller Regelung wird jedoch auch ein externes Formular dafür verwendet.
#figure(caption: [_Selbstständigkeitserklärung_ Hinzufügen])[
  ```typst
  misc-pages: (
    authorship-declaration: true
  )
  ```]

=== Glossary
Glossareinträge können direkt über die Konfiguration als verschachteltes array mit Term und Beschreibung übergeben werden, wie im Folgenden Beispiel gezeigt wird. Um jedoch auch auf den Eintrag verweisen zu können, bietet es sich an, die Einträge direkt im Fließtext zu definieren, wie in #ref(<define-glossary-de>) beschrieben.
#figure(caption: [_Glossareinträge_ definieren])[
  ```typst
  misc-pages: (
    glossary: (
      ("Telematik", "Die Kombination aus Telekommunikation und Informatik"),
    ),
  )
  ```]

=== Anhang
Der Anhang ist ein Abschnitt am Ende der Arbeit für Texte oder Abbildungen, die nicht direkt im Fließtext sein sollen. Also weniger relevante Informationen, oder Abbildungen, von denen im Text nur ein Ausschnitt verwendet wird. Auch ganzer Code oder eine Erklärung von dessen Architektur passen gut in den Anhang.
#figure(caption: [_Anhang_ anfügen])[
  ```typst
  misc-pages: (
    appendix: #include "chapters/appendix.typ"
  )
  ```]
In diesem Beispiel wird gleich ein ganzes Typst-Dokument importiert und als Anhang in die Konfig gegeben. Da der Anhang sehr umfangreich werden kann, ergibt es Sinn, ihn so auszulagern und die Konfig nicht unleserlich werden zu lassen. Im Anhang selbst sollten einzelne Einträge durch Überschriften ersten Grades Unterteilt werden, damit sie richtig automatisch durchnummeriert werden können.

== Abbildungen
Wenn du bereits mit Software wie Microsoft Word oder LaTeX wissenschaftliche Texte verfasst hast, kennst du wahrscheinlich die verschiedenen Arten von Abbildungen, die häufig benötigt werden.
Die folgenden Unterkapitel zeigen dir, welche Abbildungstypen diese Vorlage bereitstellt.
Da es bei der Arbeit mit Abbildungen oft wichtig ist, den Überblick über deren Anzahl zu behalten, um sie später in den Verzeichnissen aufzuführen, übernimmt diese Vorlage auch das automatisch für dich.
Zum Beispiel wird beim Hinzufügen einer Tabelle am Ende deines Dokuments automatisch eine Seite erzeugt, auf der alle Tabellen aufgelistet und verlinkt sind.

=== Tabelle
Es stehen zwei Tabellentypen zur Verfügung. Standardmäßig wird das Styling `tables.x-header` verwendet. Es enthält eine Kopfzeile am oberen Rand und wechselt anschließend zwischen zwei helleren Hintergrundfarben, um das Lesen der Zeilen zu erleichtern.

#figure(
  caption: "Alltag eines Programmierers",
  table(
    columns: 4,
    table.header([Zeit], [Dauer], [Aufgabe], [Anforderungen]),

    [9:00 Uhr], [30 Minuten], [Kaffeepause], [Kaffee, Kaffeemaschine],
    [9:30 Uhr], [30 Minuten], [E-Mails lesen], [Computer],
    [10:00 Uhr], [2 Stunden], [Code von gestern verstehen], [Gehirn (muss wach sein)],
    [12:00 Uhr], [30 Minuten], [Mittagspause], [Essen oder Mensa und Geld],
    [12:30 Uhr], [20 Minuten], [Spaziergang im Park], [Park, Schuhe],
    [12:50 Uhr], [10 Minuten], [noch eine Kaffeepause], [Kaffee, Kaffeemaschine],
    [13:00 Uhr], [4 Stunden], [Code von gestern umschreiben], [Gehirn (mit Kaffee wachhalten)],
    [17:00 Uhr], [30 Minuten], [Aufgeben und nach Hause gehen], [-],
  ),
)

Der zweite Tabellenstil kann mit `tables.xy-header*`verwendet werden. Er besitzt dasselbe Styling, hat aber zusätzlich eine Kopfzeile am Anfang der y-Achse – daher der Name `xy-header`.

#figure(
  caption: "Schiffe versenken",
  tables.xy-header(
    table(
      columns: 6,
      table.header([ ], [A], [B], [C], [D], [E]),

      [1], [🌊], [🚢], [🌊], [💥], [🌊],
      [2], [🚢], [💥], [🌊], [🌊], [🌊],
      [3], [🌊], [🌊], [🌊], [🌊], [🌊],
      [4], [🌊], [🌊], [💥], [🚢], [🚢],
      [5], [🌊], [🚢], [🌊], [🌊], [💥],
    ),
  ),
)

=== Code
Typst biete bereits die Möglichkeit, `inline` oder auch ganze Blöck von Code einzufügen. Die lässt sich auch bei alles Beispielen in diesem Dokument finden, zum Beispiel bei #ref(<conf-example-de>)

=== Info-Karte
Um Hinweise für die Leserschaft zu geben oder wichtige Texte wie Definitionen hervorzuheben, kann die *Info-Karte* verwendet werden.
Sie besteht aus einem Titel und einem Textkörper.

#infocard(
  "Beispiel: Info-Karte",
  "Dies ist eine Info-Karte. Sie kann für Beispiele, Definitionen oder allgemeine Hinweise verwendet werden.",
)

Die beiden Farben der Karte können einfach angepasst werden:

#infocard(
  "Beispiel: Info-Karte",
  "Dies ist eine Info-Karte. Sie kann für Beispiele, Definitionen oder allgemeine Hinweise verwendet werden.",
  color-dark: th-color.orange,
  color-light: th-color.paleorange,
)

=== Einheiten
Eine Einheit wie #define-unit("a", $"ms"^(-2)$, "Beschleunigung", "Vektorgröße") kann einfach definiert werden. Mit #unit("a") ist ein Verweis darauf möglich.

=== Glossar <define-glossary-de>
Mit #define-glossary("Telematik", "Die Kombination aus Telekommunikation und Informatik") kann ein Glossareintrag definiert und mit #glossary("Telematik") erneut referenziert werden.


=== Abkürzungen
Ähnlich den Einheiten können auch Abkürzungen definiert werden. Die Abkürzung #define-abbreviation("TH", "Technische Hochschule") verweißt dabei auf den dazugehörigen Eintrag im Abkürzungsverzeichnis, der automatisch erstellt wird. Wie bei der Einheit kann überall im Text erneut auf #abbreviation("TH") verwiesen werden, wobei sich bei häufigem Nutzen von Verweisen ein automatisches Ersetzen im Text oder wenigstens das Importieren der Funktion unter einem Alias, um nicht jeden mal `#abbreviation("TH")` tippen zu müssen, anbietet.

=== Abbildung
Auch wenn dies kein spezielles Element dieser Vorlage ist, sondern direkt von Typst stammt, folgt hier eine Abbildung, um die Liste der häufig genutzten Figurentypen zu vervollständigen und das Generieren des Abblidungsverzeichnisses auszulösen.

#figure(
  image("../img/figs.png", width: 8cm),
  caption: [Fig. 1, Fig. 2 @web-fig1-fig2],
)

=== ToDo
Beim Schreiben kann es vorkommen, dass du dir selbst eine Erinnerung hinterlassen möchtest, z. B. „dieses Kapitel überarbeiten“. Oder du nutzt ein Platzhalterwort, wenn dir spontan nichts Besseres einfällt.
Das Risiko dabei ist, dass solche Stellen unbemerkt im finalen Text bleiben.
Um das zu verhindern, gibt es das *todo*-Element.
Wickle einfach #todo[beliebiger Text] in ein todo und füge optional mit #todo(info: "Hinweis")[Notiz] eine zusätzliche Bemerkung hinzu, die darüber erscheint.
Todos sind nicht nur mit einem roten Hintergrund markiert, sondern werden auch in einem eigenen Todo-Verzeichnis nach dem Haupttext aufgelistet.

=== Fußnote Fußnoten 
Obwohl eine Fußnote keine Abbildung ist, wird sie hier der Vollständigkeit halber aufgeführt. Sie kann verwendet werden, um weitere Informationen in der Fußzeile #footnote[Willkommen in der Fußzeile] anzugeben.

== Verschiedene Sprachen <translation-de>
Dieses Template hat etliche statische Textelemente. Darunter zählen zum Beispiel alle Überschriften, die nicht Teil der Arbeit selbst sind. Damit das Template trotzdem mehrere Sprachen unterstützt wurde sich hier eines programmatisch eher unkonventionellen Tricks bedient: In `/utils/translations.json` sind alle statischen Textblöcke definiert und übersetzt. Die scheint vor allem für Programmierer als eine schlechte Lösung, da die Übersetzungen den Klartext direkt als Schlüssel nutzen, anstatt eines passenden Variablennamens. Jedoch verbessert dies die Lesbarkeit des Code ungemein, da er so auch direkt den Klartext (auf Englisch) enthalten kann.
Um eine neue Sprache hinzuzufügen ist keinerlei Programmierkenntnis von nöten. Dazu können einfach in `/utils/translations.json` im Ordner, in dem das Template gespeichert ist, Übersetzungen für eine weitere Sprache in jede benötigte Zeile eingefügt werden. Danach können entweder einzelne Seite wie die Bibliographische Beschreibung, oder gleich die ganze Thesis in der Sprache verwendet werden. Wie bei der Konfiguration gibt auch die Übersetzungsfunktion entsprechende Fehler aus, wenn eine Übersetzung für die gewünschte Sprache fehlt. Darum ist es auch möglich, nur die jeweils fehlenden Zeilen zu ergänzen, anstatt alles zu Übersetzen.
Beispielsweise kann die Zeile `"Signature": {"de": "Unterschrift"}` zu `"Signature": {"de": "Unterschrift", "eo": "Subskribo"}` ergänzt werden, um übersetzung für die Sprache Esperanto verfügbar zu machen.

== Beitrag zum Template
Dieses Temaplte entstand aus Frustration mit dem Boilerplate, was sich LaTeX nennt, und auch aus Neugier für die neue Alternative Typst. Es war ursprünglich gar nicht als Template gedacht, sondern entstand im Rahmen einer Belegarbeit von mir (dem Autor), um vor der eigentlichen Arbeit zu prokrastinieren. Darum wurden features auch primär hinzugefügt, wenn sie mir (wieder der Autor) gefehlt haben. Sollte dir also ein Feature fehlen, oder solltest du sogar meine Beispiel folgen wollen, selbst das Template mit weiterem Prokrastinationscode zu verbessern, so kannst du gern jederzeit eine Nachricht schreiben oder sogar direkt eine push-request zum git-repository anfragen. Natürlich gilt dies nicht nur für den Code vom Template, sondern auch für diese Anleitung. #linebreak()
*Danke, dass du dieses Template nutzt!*
#h(10pt) - #link("mailto:carl+thtemplate@bellgardt.dev", [_Carl Heinrich Bellgardt_])

