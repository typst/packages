# clean-barm

Dieses git Repository enthält das [Typst](https://typst.app/) Template für die Ausarbeitungen an der [Berufsakademie Rhein-Main](https://studenten.ba-rm.de/).
Das ursprüngliche Template wurde von [GolemT](https://github.com/GolemT/ba-template) erstellt, dieses Repository enthält eine vereinheitlichte und überarbeitete Version davon und soll im Typst Universe veröffentlicht werden.

Das Repository enthält derzeit Templates für die folgenden Dokumente:
- Paper (Wissenschaftliches Arbeiten)
- TPT III
- Exposé
- Bachelor Thesis

## Setup

Allgemein ist das Template mittels `typst init @preview/clean-barm` nutzbar.

Für rein lokale Setups und zur Weiterentwicklung
- Linux: `${XDG_DATA_HOME:-~/.local/share}/typst/packages/local/clean-barm/1.0.0`
- MacOS: `~/Library/Application Support/typst/packages/local/clean-barm/1.0.0`
- Windows: `%APPDATA%\typst\packages\local\clean-barm\1.0.0`

geklont und mittels `typst init @local/clean-barm:1.0.0` initialisiert werden

Alternativ dazu kann natürlich auch einfach das Repository an einen Wort der Wahl geklont oder von [als zip](https://git.thebread.dev/theBreadCompany/ba-template/archive/main.zip) heruntergeladen und extrahiert werden.

Bei der lokalen Nutzung mittels `typst` erfolgt die Kompilierung weiterhin mittels `typst w main.typ`.

Die in der main.typ hinterlegten Assets nutzen `prequery`, um die Assets nicht im Paket selbst hinterlegen zu müssen (was an der Lizenz scheitern würde). 
Entweder kann das Tool installiert werden, um mittels `prequery main.typ` die benötigten Ressourcen automatisch zu pullen, oder manuell die Bilder heruntergeladen und abgelegt werden.
*Infolge dieses Aufbaus kompiliert das erzeugte Template nicht automatisch!* Eine Fallback Option mit Erklärung ist deshalb ganz oben im Dokument hinterlegt.

### Neues Projekt in Typst anlegen

### Projektfiles auswählen

Für alle normale Semianrarbeiten der BA reicht das Template "Paper". Für Bacherlorarbeiten, Expose oder TPT III sollten die anderen Templates genutzt werden.

### Projektfiles hochladen

Solange das Paket noch nicht veröffentlicht wurde müssen alle Dateien im Ordner des Templates hochgeladen werden. Dazu kann man im Typst Projekt über den "Hochladen" Knopf alle Dateien im Explorer auswählen.

Sobald die Veröffentlichung abgeschlossen ist kann auch in der Web-App das Template instanziiert werden.

## Schreiben in Typst

### Setzen der Hauptattribute

Jede main.typ fängt mit einem Definitionsblock des Templates an. In diesem können Titel, Authoren, Abgabedatum, Modul, Bild des Deckblatts definiert werden. Zudem kann hier durch einen Bool wert gesetzt werden, ob bestimmte Blöcke im PDF generiert werden sollen. So kann man z.B. das Codeverzeichnis ausblenden wenn man keinen Code in seiner Arbeit hat. Hier eine Übersicht der Attribute:

<details>
  <summary>Thesis</summary>
   
  ```typst
  #show: Thesis.with(
    //language: "de", // Standard
    title: "Titel der Arbeit",
    author: "Max Mustermann",
    keywords: ("Thesis", "Bachelor", "..."),
    description: "Thesis über xyz",
    degreeProgram: "Angewandte Informatik",
    studyGroup: "AI-WS23_III",
    studentId: "1234567",
    contactDetails: (
      "Musterstraße 1",
      "12345 Musterstadt",
      "max.mustermann@email.com",
    ),
    academicReviewer: "Alice",
    companyReviewer: "Bob",
    submissionDate: "10.06.2026",
    universityLogo: image("../images/BA_Logo.jpg", width: auto),
    companyLogo: image("../images/DB_Logo.png", height: 3fr),
    showListOfFigures: true,
    showListOfTables: true,
    showListOfCode: true,
    acronyms: (:), // leeres Dictionary
    appendix: none,
    glossary: (:), // leeres Dictionary
    bibliography: none,
    //restrictionNotice: "" // hat internen Standardtext
    //foreword: "",
    //genderingNote: "", // hat internen Standardtext
  )
  ```
</details>

<details>
  <summary>Exposé</summary>

  ```typst
  #show: Expose.with(
    title: "Titel der Arbeit",
    author: "Max Mustermann",
    studyGroup: "AI-WS23_III",
    studentId: "123456",
    contactDetails: (
      "Musterstraße 1",
      "12345 Musterstadt",
      "max.mustermann@email.com",
    ),
    keywords: ("PDF", "Ausarbeitung"),
    dateOfColloquium: "03.12.2025"
    submissionDate: "27.11.2025",
    academicReviewer: "Alice",
    companyReviewer: "Bob",
    universityLogo: logo(width: auto),
    //modul: [Theorie-Praxis-Anwendung II],
    showListOfFigures: true,
    showListOfTables: true,
    showListOfCode: true,
    acronyms: (
      API: "Application Programming Interface",
      HTML: "Hypertext Markup Language",
    ),
    appendix: include "./anhang.typ",
    glossary: (
      "API": "Application Programming Interface",
      "Typst": "Eine Markup-Sprache für die Dokumentenerstellung",
    ),
    bibliography: bibliography(
      title: none,
      "refs.bib",
    ),
    //restrictionNotice: "" // hat internen Standardtext
    //foreword: "",
    //genderingNote: "", // hat internen Standardtext
  )
  ```
</details>

<details>
  <summary>TPT</summary>

  ```typst
  #show: TPT.with(
    title: "Titel der Arbeit",
    authors: (
      (name: "Max Mustermann", studentId: "1234567"),
    )
    studyGroup: "AI-WS23_III",
    keywords: ("PDF", "Ausarbeitung"),
    description: "",
    date: "01.01.2024",
    universityLogo: logo(width: auto),
    modul: [Theorie-Praxis-Anwendung II],
    preThesis: false, // only for TPT3
    showListOfFigures: true,
    showListOfTables: true,
    showListOfCode: true,
    acronyms: (
      API: "Application Programming Interface",
      HTML: "Hypertext Markup Language",
    ), 
    appendix: include "./anhang.typ",
    glossary: (
      "API": "Application Programming Interface",
      "Typst": "Eine Markup-Sprache für die Dokumentenerstellung",
    ),
    bibliography: bibliography(
      title: none,
      "refs.bib",
    ),
    //restrictionNotice: "" // hat internen Standardtext
    //foreword: "",
    //genderingNote: "", // hat internen Standardtext
  )
  ```
</details>

<details>
  <summary>Paper</summary>

  ```typst
  #show: Paper.with(
    title: "Titel der Arbeit",
    authors: (
      (name: "Max Mustermann", studentId: "1234567"),
    )
    studyGroup: "AI-WS23_III",
    keywords: ("PDF", "Ausarbeitung"),
    description: "",
    date: "01.01.2024",
    universityLogo: logo(width: auto),
    modul: [Theorie-Praxis-Anwendung II],
    preThesis: false, // only for TPT3
    showListOfFigures: true,
    showListOfTables: true,
    showListOfCode: true,
    acronyms: (
      API: "Application Programming Interface",
      HTML: "Hypertext Markup Language",
    ), 
    appendix: include "./anhang.typ",
    glossary: (
      "API": "Application Programming Interface",
      "Typst": "Eine Markup-Sprache für die Dokumentenerstellung",
    ),
    bibliography: bibliography(
      title: none,
      "refs.bib",
    ),
    //restrictionNotice: "" // hat internen Standardtext
    //foreword: "",
    //genderingNote: "", // hat internen Standardtext
  )
  ```

</details>

Sollte die Liste mit Akronymen oder das Glossar zu groß werden, kann auch auch im Stil des Anhangs ein separates Dokument angelegt und die entsprechenden Einträge ausgelagert werden:

<details>
  <summary>main.typ + acronyms.typ</summary>

  acronyms.typ:

  ```typst
  #let Acronyms = (
    API: "Application Programming Interface",
    HTML: "Hypertext Markup Language",
  )
  ```

  main.typ 

  ```typst 
  #import "acronyms.typ": Acronyms
  #show Thesis.show(
    ...
    acronyms: Acronyms,
    ...
  ```
</details>


### Markdown ähnlich

Schreiben in Typst hat viele ähnlichkeiten mit Markdown und unterscheidet sich nur im Syntax. Für alle groben Textformatierungen oder SChreibstyle kann enweder die obere Leiste genutzt werden oder der Typst Syntax, welche in der [Dokumentation](https://typst.app/docs) beschrieben wird. Im allgemeinen wird empfohlen bei Fragen erst in der Doku nachzuschauen und im Anschluss in Foren wie dem [Typst Reddit](https://www.reddit.com/r/typst/) oder dem [Typst Forum](https://forum.typst.app/) nach Hilfe zu fragen. Die Main.typ die mit jeder Template mitkommt zeigt ein paar Grundfunktionen:

``````typst
= Introduction

#include "/texts/subtext.typ"

== Different Objects

#acr("API") ist eine Abkürzung

#gls("API") ist eine Glossarverlinkung

#figure(
  image("images/BA_Logo.jpg", width: 100pt),
  caption: "Logo der Berufsakademie Rhein-Main"
)<Logo> //Hiermit wird ein aufrufbarer Link erstellt

#figure(
  table(columns: 2fr, row-gutter: 1)[Das ist eine Tabelle], 
  caption: "Tabellenbeispiel"
)<tabelle> //Hiermit wird ein aufrufbarer Link erstellt

#figure(
  caption: "Beispiel für Code",
  ```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
  ```
)<code>

=== Contributions <Contribution>

#comment("This is a comment")

#todo("This is a ToDo")

#lorem(40)


= Linking Text

Hier wird nochmal #acr("API") aus dem Abkürzungsverzeichnis erwähnt.

Hier wird nochmal #gls("API") aus dem Glossar erwähnt

@Logo Zeigt das Logo der BA

@tabelle zeigt ein Beispiel einer Tabelle

@code zeigt ein Code Snippet

== Zitate

Hier ist ein Zitat @nissen_softwareagenten_2006.

#cite(<nissen_softwareagenten_2006>, form: "prose")) zitiert etwas im laufenden Text.

Hier ist ein zitat mit Link auf die Fußnote #footnote()[#cite(<nissen_softwareagenten_2006>)]
``````

Diese Beispiele zeigen Grundlegenden Syntax in Typst. Überschriften werden wir in Markdown mit Symbolen angeführt, allerdings benutzt Typst =

```
= Heading 1
== Heading 2
=== Heading 3
etc...
``` 

Text wird normal ohne jegliche Änderungen geschrieben. Inhalte welche nicht Text sind oder andere Funktionalitäten haben sollen werden mit function calls geschrieben.

```
Das hier ist Text mit einem Zitat am ende #cite(@quelle).
```

So kann text grundlegend geschrieben werden und wird durch Typst automatisch formatiert.

### Grundlegende Funktions

Im folgenden werden die meist genutzten Funktionen erklärt.

#### cite

Die Zitierfunktion von Typst. Mit ihr können sämmtliche Quellen welche in der literatur.bib sind abgerufen und zitiert werden. Dafür müssen Quellen im bibTex format in die literatur.bib eingefügt werden.

Es gibt mehrere Arten zu zitieren:

```typst
#cite(@quelle)                            // Normales Zitat -> (Brooke, 1995)
#cite(@quelle, form: "prose")             // Zitat im laufenden Satz -> Brooke (1995)
#cite(@quelle, supplement: "vgl. S. 14)   // Zitat mit Seitenangabe -> (Brooke, 1995, vgl. S. 14)
```

Die Standard zitierweise ist Chicago. Es gibt viele Zitierarten zur auswahl welche im Template ausgewählt werden können. Suche dazu im template.typ die Zeile ```set cite(style: "chicaco-author-date")``` und ändere den Styl in einen von Typst akzetierten Styl um.

#### Verlinkungen

Um auf andere Textpassagen hinzuweisen und einen automatischen Link im generierten PDF zu erhalten kann man passagen verlinken:

```
Das ist Text in einem Abschnitt<abschnitt> // Erstellung des Links

Ich beziehe mich hier auf @abschnitt       // Nutzung des Links
```

In der generierten PDF wird das dann so aussehen:
```
Das ist Text in einem Abschnitt

Ich beziehe mich auf Abschnitt 2.2.2
```

#### Footnotes

Um Fußnoten einzufügen wird die Footnote Function mit dem folgenden Aufbau genutzt:

```
#footnote[content]                                       //Content beschreibt den Inhalt der Fußnote
#footnote[Diese These wird durch die Studie unterstützt] // Text als Fußnote
#footnote[#cite(@quelle)]                                // Zitat als Fußnote
```


#### Figures

Figures umschließen Bilder, Tabellen und Code Snippets. Sie werden gebraucht um die verschiedenen Verzeichnisse zu füllen. Der Grundlegende Aufbau ist wie folgt:

```
#figure(
    content,
    caption: "Unterschrift der Figure"
)
```

Content beschreibt hier Bilder, Tabellen oder Code. Inhalt welcher nicht den drei genannten Arten entspricht wird als Bild verstanden und somit ebenfalls gepflegt.

Hier finden sich Beispiele für die 3 Arten von Figure:

```typst
#figure(
  image("images/BA_Logo.jpg", width: 100pt),
  caption: "Logo der Berufsakademie Rhein-Main"
) // Beispiel für ein Bild

#figure(
  table(columns: 2fr, row-gutter: 1)[Das ist eine Tabelle], 
  caption: "Wichtige Tabelle"
) // Beispiel für eine Tabelle

#figure(
  ```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
  ```,
    caption: "Basis Code",
) // Beispiel für ein Code Snippet
```

#### acr und gls

Durch die zwei Dateien acronyms.typ und glossary.typ werden Abkürzungsverzeichnis und Glossar geführt. Wenn ein Element in einer dieser beiden Dateien angelegt ist kann es im Text erwähnt werden. So wird automatisch ein Link erstellt welcher den Leser zum jeweiligen Verzeichnis führt.

```
#acr("API")     // Link zum Abkürzungsverzeichnis
#gls("Website") //Link zum Glossar
```

Wenn Abkürzungen zum ersten Mal erwähnt werden werden sie automatisch mit der vollen ausschreibweise eingefügt:

```
#acr("MD") -> Markdown (MD)
#acr("MD") -> MD
```

#### Linebreak und Pagebreak

Falls die Formatierung des Templates erweitert werden soll (durch leerzeilen oder Seitenumbrüche) können diese durch functions eingebaut werden:

```
#linebreak()  // Fügt einen Zeilenumbruch ein
#pagebreak()  // Fügt einen Seitenumbruch ein
```

## Weitere Functions

In diesem Dokument wurden nur die Grundarten von Functions angerissen. Es gibt viele weitere und um einiges mehr an Parametern welche man den Functions übergeben kann. Für mehr eignet sich die [Dokumentation](https://typst.app/docs).
