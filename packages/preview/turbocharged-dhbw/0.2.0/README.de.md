🇩🇪 Deutsch | [🇬🇧 English](README.md)

# turbocharged-dhbw

Inoffizielles Layout für Praxisberichte, Projektarbeiten und Abschlussarbeiten an der DHBW (Duale Hochschule Baden-Württemberg), angelehnt an die verbreitete DHBW-LaTeX-Vorlage. Lässt sich auch für andere Hochschulen anpassen.

Dieses Paket steht in keiner Verbindung zur DHBW.

## Benutzung

Projekt aus der Vorlage erzeugen:

```bash
typst init @preview/turbocharged-dhbw:0.2.0 mein-bericht
cd mein-bericht
typst watch main.typ
```

Oder in ein bestehendes Projekt importieren:

```typst
#import "@preview/turbocharged-dhbw:0.2.0": report

#show: report.with(
  author: "Jane Doe",
  title: "Kaffeeverbrauch im Homeoffice",
  document-type: "Praxisbericht",
  program: "Informatik",
  student-id: "1234567",
  course: "TINF25B1",
  city: "Karlsruhe",
  submission-date: "01.10.2026",
  confidential: false,
)

= Einleitung
Dein Text.
```

Mehrere Verfasser teilen sich Ort und Datum. Jede Person bekommt eine eigene Unterschriftszeile in der Ehrenwörtlichen Erklärung. Auf dem Deckblatt stehen die Namen kommagetrennt.

```typst
author: ("Jane Doe", "John Smith"),
```

`lang` ist standardmäßig `"de"`. Mit `lang: "en"` kommen die englischen Texte.

## Parameter

Übergabe an `report.with(...)`. Nur `title`, `program` und `document-type` brauchen einen echten Wert, der Rest hat Defaults.

| Parameter | Default | Beschreibung |
| --- | --- | --- |
| `author` | — | Name, oder ein Array von Namen. |
| `title` | — | Titel auf dem Deckblatt. |
| `document-type` | — | Zum Beispiel `Praxisbericht`, `Projektarbeit`, `Studienarbeit`, `Bachelorarbeit`. |
| `program` | — | Studiengang. |
| `module` | `none` | Modul oder Prüfungsnummer. |
| `submission-date` | `none` | Abgabedatum, so wie es gedruckt werden soll. |
| `duration` | `none` | Bearbeitungszeitraum. |
| `student-id` | `none` | Matrikelnummer, oder ein Array. Jede Nummer bekommt eine eigene Zeile auf dem Deckblatt. |
| `course` | `none` | Kurs, zum Beispiel `TINF25B1`, oder ein Array. Jeder Kurs bekommt eine eigene Zeile auf dem Deckblatt. |
| `city` | `none` | Standort des Betriebs. Steht auch in der Erklärung. |
| `company-name` | `none` | Ausbildungsbetrieb. |
| `company-logo` | `none` | Firmenlogo, als `image("pfad/zum/logo.png")`. |
| `company-supervisor` | `none` | Betreuer im Betrieb. |
| `university` | DHBW Karlsruhe | Hochschulname auf dem Deckblatt. |
| `university-logo` | DHBW-Logo | Hochschul-Logo. Ohne Angabe wird das mitgelieferte DHBW-Logo verwendet. |
| `university-supervisor` | `none` | Betreuer an der Hochschule. |
| `confidential` | `true` | Sperrvermerk einfügen. |
| `confidential-text` | `none` | Eigener Text für den Sperrvermerk. |
| `show-declaration` | `true` | Ehrenwörtliche Erklärung einfügen. |
| `show-ai-declaration` | `auto` | Hängt den KI-Satz an die Erklärung. `auto` ergänzt ihn, sobald `ai-tools` gesetzt ist. `false` schaltet ihn ab. |
| `declaration-title` | `none` | Eigene Überschrift der Erklärung. |
| `declaration-text` | `none` | Eigener Text der Erklärung. |
| `abstract-content` | `none` | Abstract, üblicherweise `include "content/abstract.typ"`. |
| `acronyms` | `()` | Dictionary oder `yaml("abk.yml")` für das Abkürzungsverzeichnis. |
| `bibliography-content` | `none` | Ein `bibliography(...)`-Aufruf. |
| `appendix-content` | `none` | Anhang, üblicherweise `include "content/anhang.typ"`. |
| `ai-tools` | `none` | Dictionary oder `yaml("ai.yml")`. Wird als Tabelle im Anhang ausgegeben. |
| `cover-page` | `none` | Ersetzt das generierte Deckblatt. |
| `lang` | `"de"` | `"de"` oder `"en"`. |

Außerdem exportiert: `code` für nummerierte Listings, `small-todo` (ein kleineres `dashy-todo`), `ai-tools-table`, `ai-acknowledgement` und `source`. `#source[...]` ohne Leerzeichen davor. Steht in derselben Zeile und fehlt im Abbildungsverzeichnis. Eigene Arbeit: `#source[eigene Darstellung]` wird zu `(eigene Darstellung)`. Eine Zitation `#source[@key]` bleibt die Zitation, nicht `([1])`. Abgewandelt: `#source[in Anlehnung an @key]`.

`ai-tools` und `ai-tools-table` nicht gleichzeitig nutzen, sonst erscheint die Tabelle doppelt.
