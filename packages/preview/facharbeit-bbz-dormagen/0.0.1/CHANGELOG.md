# CHANGELOG

Alle nennenswerten Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt hält sich an [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.0.1] - 2026-08-01 (Initial Release)

Dieses Release markiert die erste offizielle Bereitstellung der Facharbeitsvorlage auf Typst Universe. Es bietet ein vollständig automatisiertes, auf DTP-Standards optimiertes Layout für akademische Arbeiten sowie eine hochentwickelte Entwickler-Infrastruktur.

### Hinzugefügt (Added)

**Typografie & Layout**
- **DTP-Standard Inhaltsverzeichnis:** Vollständige Kontrolle über das Inhalts- und Abbildungsverzeichnis inklusive Unterdrückung von Silbentrennung zur Vermeidung von optischen Überlappungen mit Seitenzahlen.
- **Zentrale OKLCH-Farbarchitektur:** Ein kohärentes Farbsystem (basierend auf OKLCH) für alle Komponenten und Diagramme inklusive präventivem Gamut-Clipping-Schutz bei hellen Farbverläufen.
- **Smarte Mikrotypografie:** Automatische Regex-Ersetzung von problematischen Zeilenumbrüchen (z. B. geschützte Leerzeichen nach Abkürzungen wie *z. B.*, korrekte Halbgeviertstriche bei Zahlenbereichen).
- **Verhinderung von Schusterjungen/Hurenkindern:** Manueller Block-Zusammenhalt (`breakable: false`) als robuster Workaround, bis native Widow-Control in Typst zur Verfügung steht.
- **Nativer Fußnoten-Zitierstil:** Integration der `facharbeit.csl` (BibLaTeX) mit vollständiger Unterstützung für Sammelwerke und Lexika (`editor`-Feld).

**Architektur & Usability**
- **Top-Down-Injection Architektur:** Saubere Trennung der Template-Kernengine (`_system/`) von den Anwenderkapiteln (`kapitel/`).
- **Single Source of Truth:** Zentrale Steuerung aller Metadaten und Einstellungen über die Endanwender-Datei `99-Individualisierungen.typ` inklusive einer Entwickler-Übersichtsseite (`uebersicht.typ`).
- **Benutzerdefinierte API-Makros:** Einfache, markdown-ähnliche Makros für Studierende (`#hinweisbox`, `#einfache-tabelle`, `#bild`), um das Schreiben komplexer Elemente zu trivialisieren.
- **Barrierefreiheit (Accessibility):** Automatisches Schreiben detaillierter PDF-Metadaten (Autor, Thema, Stichwörter) sowie Unterstützung für `alt`-Texte bei Abbildungen.

**CI/CD & Qualitätssicherung (BDT-Testsuite)**
- **8-Stufige Testpipeline:** Vollständige Abdeckung durch PowerShell- und Python-Skripte (`bauen.ps1`), um Struktur, Zitationen, Metadaten und Warnungen vor jedem Build zu validieren.
- **Visuelles Regression-Testing:** Automatisierter "Golden Master"-Abgleich auf Pixelebene (via PyMuPDF) zur Verhinderung von unbeabsichtigten Layout-Regressionen.
- **Anti-Tamper-Schutz:** Sicherheits-Tests (String-Längen-Validierung), um zu verhindern, dass Studierende Systemdateien verändern.
- **Plagiat-Export:** Automatisiertes Skript (`Export-Plaintext.ps1`) zum Extrahieren des Rohtextes aus dem finalen PDF für Turnitin und PlagScan.

---

> **Hinweis für Entwickler & KIs:** Zukünftige Updates an diesem Projekt (Neue Features, Bugfixes, Architektur-Änderungen) müssen kontinuierlich in diese `CHANGELOG.md` eingepflegt werden.
