# TH Wildau Typst Telematics Template

## Overview

A Typst template for creating academic theses and internship reports in the course Telematics at TH Wildau. It provides structured layouts, consistent styling, and utilities for common academic elements.

---

## Configuration

The template is configured centrally via `conf.with(...)`. Required fields are validated at compile time and will produce errors if missing.

### Required fields

* `title`
* `student`
* `supervisor`

### Optional fields

* `internship`
* `bibliography`
* `language`

---

## Auto-generated Pages

The template automatically generates several standard pages:

* Title page (can be replaced by custom content or a PDF)
* Bibliographic description (multi-language)
* Reading guide
* Declaration of authorship
* Company confirmation
* Appendix support

---

## Multi-language Support

Static UI text is translated using `/utils/translations.json`.
The system is easily extendable without programming knowledge. Missing translations will result in compile errors.

---

## Tables

The template provides predefined table styles:

* `tables.x-header`
* `tables.xy-header`

Tables are automatically included in a list of tables.

---

## Figures and Code

* Native Typst figures are supported
* Automatic list of figures
* Inline and block code supported

---

## Info Cards

Info cards allow highlighting important content such as notes or definitions.
Their appearance can be customized.

---

## Units

Units can be defined and reused centrally:

* Define via `define_unit`
* Use via `unit`

---

## Abbreviations

Abbreviations can be defined and referenced:

* Define via `define_abbreviation`
* Use via `abbreviation`
* Automatic list of abbreviations

---

## TODO System

* Inline TODOs via `todo[...]`
* Optional annotations
* Automatic TODO list
* Visual highlighting in the document

---

## Bibliography

The template integrates Typst’s bibliography system and allows configurable citation styles.

---

## Example

```typst
#import "@preview/thwildau-telematics:0.1.1": *

#show: conf.with(
  title: "My Thesis",
  student: (
    name: "Max Mustermann",
    matrnr: "12345678",
  ),
  supervisor: (
    name: "Dr. Example",
  ),
)
```

---

## Notes

Designed for minimal Typst knowledge with a strong focus on automation and consistency.

---

## Contributing

Contributions and feature requests are welcome.

---

# TH Wildau Telematik Typst-Vorlage für Abschlussarbeiten

## Überblick

Eine Typst-Vorlage zur Erstellung von Abschlussarbeiten und Praxisberichten für den Studiengang Telematik an der TH Wildau. Sie bietet strukturierte Layouts, einheitliches Styling und Hilfsfunktionen für typische wissenschaftliche Inhalte.

---

## Konfiguration

Die Vorlage wird zentral über `conf.with(...)` konfiguriert. Pflichtfelder werden zur Compile-Zeit geprüft und erzeugen Fehler, falls sie fehlen.

### Pflichtfelder

* `title`
* `student`
* `supervisor`

### Optionale Felder

* `internship`
* `bibliography`
* `language`

---

## Automatisch erzeugte Seiten

Die Vorlage erzeugt automatisch mehrere Standardseiten:

* Titelseite (kann durch eigenes PDF ersetzt werden)
* Bibliographische Beschreibung (mehrsprachig)
* Lesehinweise
* Selbstständigkeitserklärung
* Firmenbestätigung
* Anhang

---

## Mehrsprachigkeit

Statische Texte werden über `/utils/translations.json` übersetzt.
Das System ist einfach ohne Programmierkenntnisse erweiterbar. Fehlende Übersetzungen führen zu Compilerfehlern.

---

## Tabellen

Die Vorlage bietet vordefinierte Tabellenstile:

* `tables.x-header`
* `tables.xy-header`

Tabellen werden automatisch in ein Tabellenverzeichnis aufgenommen.

---

## Abbildungen und Code

* Typst-Abbildungen werden unterstützt
* Automatisches Abbildungsverzeichnis
* Inline- und Block-Code möglich

---

## Info-Karten

Info-Karten ermöglichen die Hervorhebung wichtiger Inhalte wie Hinweise oder Definitionen.
Das Erscheinungsbild ist anpassbar.

---

## Einheiten

Einheiten können zentral definiert und wiederverwendet werden:

* Definition über `define_unit`
* Verwendung über `unit`

---

## Abkürzungen

Abkürzungen können definiert und referenziert werden:

* Definition über `define_abbreviation`
* Verwendung über `abbreviation`
* Automatisches Abkürzungsverzeichnis

---

## TODO-System

* Inline-TODOs über `todo[...]`
* Optionale Hinweise
* Automatisches TODO-Verzeichnis
* Visuelle Hervorhebung im Dokument

---

## Literaturverzeichnis

Die Vorlage integriert das Typst-Bibliographiesystem und ermöglicht konfigurierbare Zitierstile.

---

## Beispiel

```typst
#import "@preview/thwildau-telematics:0.1.1": *

#show: conf.with(
  title: "Meine Arbeit",
  student: (
    name: "Max Mustermann",
    matrnr: "12345678",
  ),
  supervisor: (
    name: "Dr. Beispiel",
  ),
)
```

---

## Hinweise

Für geringe Typst-Vorkenntnisse konzipiert, mit Fokus auf Automatisierung und Konsistenz.

---

## Mitwirken

Beiträge und Feature-Wünsche sind willkommen.

## Logo License
Das TH-Wildau Logo, welches von diesem Template verwendet und unter assets/TH-Wildau-Logo_rgb.png gespeichert wird, darf nach der CC BY-SA 4.0 License verwendet werden. Es wurde unter https://en.wikipedia.org/wiki/Technical_University_of_Applied_Sciences_Wildau#/media/File:TH_Wildau_Logo.png abgerufen.

# Changelog
**0.1.1**
- glossary entries, abbreviations and units can now be define multiple ways (see docs)
- bibliographic desciprtion: enhanced layout and bug fix (title language was always english)
- change title and chapter spacings
