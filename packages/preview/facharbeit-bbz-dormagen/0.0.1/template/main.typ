// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MAIN.TYP – Hauptdokument der Facharbeit                                 ║
// ║                                                                          ║
// ║  Struktur:                                                               ║
// ║  1. Imports                                                              ║
// ║  2. Globale Set-Regeln (Seite, Text, Absatz)                             ║
// ║  3. Typografische Korrekturen (ausgelagert)                              ║
// ║  4. Heading- & Figure-Formatierung                                       ║
// ║  5. Titelblatt                                                           ║
// ║  6. Verzeichnisse                                                        ║
// ║  7. Hauptteil (Kapitel)                                                  ║
// ║  8. Literaturverzeichnis                                                 ║
// ║  9. Anhang                                                               ║
// ║  10. Eigenständigkeitserklärung                                          ║
// ╚══════════════════════════════════════════════════════════════════════════╝


// ═══════════════════════════════════════════════════════════════════════════
// 1. IMPORTS (Reihenfolge NICHT ändern!)
// ═══════════════════════════════════════════════════════════════════════════

#import "_system/template.typ": facharbeit
#import "St_Individualisierungen.typ" as userdata
#import "_system/einstellungen.typ" as einstellungen
#import "_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "_system/utils.typ": a3-seite

#show: facharbeit.with(userdata: userdata, einstellungen: einstellungen)

#[] <start-hauptteil>



// ═══════════════════════════════════════════════════════════════════════════
// 1. IMPORTS
// ═══════════════════════════════════════════════════════════════════════════
// WICHTIG: Wenn Sie eine der Kapitel-Dateien im Ordner löschen (weil Sie sie nicht brauchen),
// müssen Sie auch die entsprechende Zeile hier auskommentieren (// davor setzen) oder löschen!
// Andernfalls bricht das Dokument beim Erstellen mit "File not found" ab.
#include "kapitel/01-motivation-und-zielsetzung.typ"
#include "kapitel/02-startklar-im-browser.typ"
#include "kapitel/03-formatierung-im-fliesstext.typ"
#include "kapitel/04-quellen-und-grafiken.typ"
#include "kapitel/05-tabellen-diagramme-ki.typ"
#include "kapitel/06-der-letzte-schliff.typ"


// ═══════════════════════════════════════════════════════════════════════════
// 9. LITERATURVERZEICHNIS
// ═══════════════════════════════════════════════════════════════════════════

<ende-hauptteil>
#if einstellungen.duplex-druck { pagebreak(to: "odd") } else { pagebreak() }
#show bibliography: set par(hanging-indent: 1.5em)
#bibliography("St_Facharbeit.bib", title: "Literaturverzeichnis", style: einstellungen.zitierstil, full: einstellungen.literatur-alle-anzeigen)


// ═══════════════════════════════════════════════════════════════════════════
// 10. ANHANG
// ═══════════════════════════════════════════════════════════════════════════

// WICHTIG: Wenn Sie keinen Anhang benötigen und die Datei löschen,
// entfernen Sie bitte auch diese Zeile.
#include "kapitel/06-anhang.typ"



// ═══════════════════════════════════════════════════════════════════════════
// 11. EIGENSTÄNDIGKEITSERKLÄRUNG
// ═══════════════════════════════════════════════════════════════════════════

#if einstellungen.duplex-druck { pagebreak(to: "odd") } else { pagebreak() }
<start-selbsterklaerung>
#heading(numbering: none, outlined: false)[Eigenständigkeitserklärung]
#v(1em)
Ich erkläre hiermit, dass ich die vorliegende Arbeit selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe.

#v(4cm)
Dormagen, #userdata.abgabedatum

#v(2cm)
#line(length: 8cm, stroke: 0.5pt)
#text(size: 10pt)[Unterschrift (#userdata.vorname #userdata.nachname)]
