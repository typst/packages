// =======================================================================
// DATEI: einstellungen.typ
// ZWECK: Globale Einstellungen (State Management): Enthält alle Typst-Variablen (#let), die das Dokument steuern. Wird in test_facharbeit.typ validiert.
// =======================================================================

// cspell:disable
// ==========================================
// TECHNISCHE EINSTELLUNGEN
// ==========================================
// In dieser Datei werden die globalen Parameter für das Aussehen und
// das PDF-Format der Facharbeit definiert.
// Änderen Sie diese Werte nur, wenn Sie genau wissen, was Sie tun!

// --- Druck- & Rand-Einstellungen ---
// Soll die Arbeit beidseitig (Duplex) gedruckt werden? (true/false)
// Bei true wechseln sich die Bindungsränder (innen/außen) ab.
#let duplex-druck = true

// Option: Format der Seitennummerierung im Fließtext
//   "x" = 1 (Standard)
//   "x/y" = 1/16
//   "Seite x von y" = Seite 1 von 16
#let seitennummerierung-format = "x"

// Option: Ein feiner Rahmen um das Firmenlogo auf dem Titelblatt
#let logo-rahmen = false
#let logo-rahmen-abstand = 1pt

// Option: Position der Beschriftung bei Bildern und Tabellen (true = oberhalb, false = unterhalb)
#let bild-beschriftung-oben = false
#let tabellen-beschriftung-oben = true

// Option: Verzeichnisse mit gepunkteten Linien auffüllen?
#let verzeichnis-fuellzeichen = true
// Option: Abstand der Punkte zueinander (feinere Punkte wirken luftiger). 
#let verzeichnis-fuellzeichen-abstand = 5pt
// Option: Größe (Feinheit) der Punkte selbst. Standard ist 11pt, 8pt wirkt dezenter.
#let verzeichnis-fuellzeichen-groesse = 6pt

// Option: Soll im Literaturverzeichnis ALLE Literatur (auch unzitierte) angezeigt werden?
#let literatur-alle-anzeigen = false

// Option: Ein zusätzlicher Heftrand, der auf der linken Seite (bzw. bei Duplex innen) addiert wird.
// Mit 1cm Heftrand und 2.5cm Grundrand ergibt sich ein linker Rand von 3.5cm, was für Noto Sans 11pt eine optimale Zeilenlänge von ca. 65 Zeichen erzeugt.
#let heftrand = 1cm

// Seitenränder
#let rand-setup = if duplex-druck {
  (inside: 2.5cm + heftrand, outside: 2.5cm, top: 2.0cm, bottom: 2.0cm)
} else {
  (left: 2.5cm + heftrand, right: 2.5cm, top: 2.0cm, bottom: 2.0cm)
}

// --- Typografie ---
// WICHTIG: Die Standard-Schriftarten in dieser Vorlage ("Noto Sans" und "Noto Sans Mono") 
// sind von Google Fonts 
// https://fonts.google.com/noto/specimen/Noto+Sans und 
// https://fonts.google.com/noto/fonts?query=Noto+sans+mono. 
// Sie müssen lokal auf dem PC installiert sein, wenn Sie Typst lokal 
// nutzen (in der Typst.app sind sie bereits verfügbar).
//
// Wenn Sie "Noto Sans" nicht installieren möchten, können Sie hier Standard-Schriftarten 
// verwenden, die auf jedem Windows/Office-PC vorinstalliert sind:
//
// Empfohlene gut lesbare Sans-Serif-Schriften (Serifenlos):
// #let hauptschriftart = "Calibri"
// #let hauptschriftart = "Segoe UI"
// #let hauptschriftart = "Arial"
//
// Empfohlene elegante Serif-Schriften (mit Serifen, klassischer Facharbeits-Look):
// #let hauptschriftart = "Cambria"
// #let hauptschriftart = "Garamond"
// #let hauptschriftart = "Times New Roman"
//
// Info: Wenn hier gar nichts eingetragen wird (oder die Schrift fehlt), 
// nutzt Typst als Fallback standardmäßig die Serifen-Schrift "Linux Libertine".
#let hauptschriftart = "Noto Sans"
#let codeschriftart = "Noto Sans Mono" // Alternativ z. B. "Consolas" oder "Courier New"
#let schriftgroesse = 11pt

// Option: Zitierstil (Layout der Zitate und des Literaturverzeichnisses)
// WICHTIG: Die Quellendaten trägt der Studierende IMMER in die "St_Facharbeit.bib" ein!
//
// - "_system/facharbeit.csl" = Eigener Stil für Fußnoten-Zitate (Autoren im Verzeichnis fett)
// - "ieee"                   = Bisheriger Standard mit eckigen Klammern [1] im Text
//   (Hinweis: "ieee" ist direkt in Typst eingebaut, dafür braucht es keine eigene .csl-Datei!)
// 
// So wechseln Sie den Stil (einfach die Raute # bei der gewünschten Option setzen):
// #let zitierstil = "ieee"
#let zitierstil = "_system/facharbeit.csl"

// Option: Optimierte Silbentrennung (verhindert sehr kurze Silben wie "perfek-te" am Zeilenende)
#let optimierte-silbentrennung = true
// Option: Kurze Wörter (mit exakt 5 Buchstaben wie z. B. "Geben") generell nicht trennen.
#let kurze-woerter-nicht-trennen = true

// Optischer Randausgleich (hängende Interpunktion)
#let optischer-randausgleich = true

// Vollständige Kontrolle über Umbruchverhalten (Trennkosten)
#let trennkosten = (
  hyphenation: 120%,  // Standard: 100 %; höher = seltener trennen
  runt: 250%,         // Einzelwort am Absatzende vermeiden
  widow: 100%,        // Hurenkinder verhindern (Standard)
  orphan: 100%,       // Schusterjungen verhindern (Standard)
)

// Zeilenabstand (leading) für den Fließtext. 
// Wissenschaftlicher Standard: 1,3-facher Zeilenabstand
#let zeilenabstand = 0.65em  // 0.65em zusätzlich = ca. 130 % bei 11pt
// Für Korrekturfassungen: 1,5-fach
// #let zeilenabstand = 1.0em
// Zeilenabstand innerhalb eines mehrzeiligen Eintrags in Inhalts-, Abbildungs- oder Tabellenverzeichnissen
#let verzeichnis-zeilenabstand = 0.5em
// Abstand zwischen zwei unterschiedlichen Einträgen in den Verzeichnissen
#let verzeichnis-eintragsabstand = 0.8em
// Schriftschnitt für Fettdruck (strong) im Fließtext (z. B. "bold" oder 600 für "semibold")
#let schriftgewicht-fett = 600
// Blocksatz (true) oder Flattersatz (false).
// Default ist false (Flattersatz), da der Ausgleich der Wortzwischenräume (Mikrotypografie) in Typst noch nicht perfekt ist.
#let blocksatz = false

// --- Farben & PDF-Export ---
// Entwicklermodus (true/false): Für einen Dark Mode beim Schreiben am Bildschirm.
// VOR DER ABGABE ODER DEM DRUCK UNBEDINGT AUF `false` SETZEN!
#let dev-mode = false

// --- Interne Farblogik ---
// Die folgenden Variablen reagieren automatisch auf den Schalter "dev-mode" (Entwicklermodus) von oben.
// Ist dev-mode = true, werden augenschonende, dunkle Farben gesetzt (Dark Mode).
// Ist dev-mode = false, werden die regulären Print-Farben gesetzt.

// Hintergrundfarbe der DIN-A4-Seite
#let bg-color = if dev-mode { rgb("1a1a2e") } else { rgb("ffffff") }

// Hauptfarbe für den Fließtext
#let text-color = if dev-mode { rgb("e0e0e0") } else { rgb("000000") }

// Primärfarbe für Überschriften, Linien und Rahmen (Corporate Design)
// Primärfarbe wird unten definiert

// Textfarbe innerhalb von Tabellen (meist identisch mit text-color)
#let table-text-color = if dev-mode { rgb("e0e0e0") } else { rgb("000000") }






// ═══════════════════════════════════════════════════════════════════════════
// DESIGN-SYSTEM: FARBEN & LAYOUT (für Tabellen und Diagramme)
// ═══════════════════════════════════════════════════════════════════════════

// Farben (OKLCH) werden aus den Benutzereinstellungen geladen
#import "../St_Individualisierungen.typ" as userdata
#let main-color = userdata.main-color
#let primärfarbe = if dev-mode { rgb("5b9bd5") } else { main-color }
#let accent-1 = userdata.accent-1
#let accent-2 = userdata.accent-2
#let accent-3 = userdata.accent-3
#let accent-4 = userdata.accent-4
#let accent-5 = userdata.accent-5
#let accent-6 = userdata.accent-6
#let balken-farben = (accent-1, accent-2, accent-3, accent-4, accent-5, accent-6)
#let header-bg = userdata.header-bg
#let zebra-bg = userdata.zebra-bg
#let stroke-color = userdata.accent-4
#let plot-bg = userdata.zebra-bg
#let label-color = userdata.accent-1
#let source-color = userdata.accent-2
#let data-label-bg = userdata.data-label-bg
#let color-1st = userdata.color-1st
#let color-2nd = userdata.color-2nd
#let color-3rd = userdata.color-3rd

#let box-rand-breite = userdata.box-rand-breite
#let box-rand-farbe = userdata.box-rand-farbe
// Linien
#let show-vertical-lines = false
#let show-outer-lines = false
#let axis-width = 0.8pt
#let grid-width = 0.3pt
#let data-line-width = 1.0pt
#let bar-stroke = 0.5pt

// Captions
#let caption-size = userdata.caption-size
#let quellen-size = userdata.quellen-size
#let table-caption-position = top
#let chart-caption-position = bottom
#let caption-supplement-weight = "regular"
#let caption-body-weight = "bold"
// Wo soll die Quellenangabe platziert werden?
// "auto": Wissenschaftlicher Standard (Tabellen: unten, Bilder: unter der Caption)
// "bottom": Immer ganz unten unter dem Inhalt
// "caption": Immer direkt unter der Überschrift
#let source-position = "auto" 
// Abstand zwischen Tabelle/Bild und der Quellenangabe (wenn source-position != "caption")
#let source-spacing = 0.5em
// Sollen die Quellenangaben auch in den Verzeichnissen (Abbildungsverzeichnis, etc.) auftauchen?
#let source-in-outline = false
#let quellen-formatierung = "italic" // "normal" oder "italic"

// Tabellen-Layout
#let table-alignment = center
#let table-width = auto
#let table-inset = (x: 5pt, y: 4pt)

// Diagramm-Layout
#let chart-width = 14cm
#let chart-height = 8cm
#let plot-margin = (left: 12mm, bottom: 10mm, top: 5mm, right: 5mm)
#let auto-a3 = true
#let a3-landscape = true

// Typografie (Diagramme)
#let axis-label-size = 8.5pt
#let axis-title-size = 9pt
#let data-label-size = 8pt
#let legend-size = 8.5pt

// Barrierefreiheit & Druck
#let large-print = false
#let sw-patterns = true
#let ampel-symbole = true

// NWA-Daten
#let gewichtungen = (
  (kriterium: "Kraftstoffeffizienz", gew: 30),
  (kriterium: "Anschaffungspreis", gew: 25),
  (kriterium: "Wartung & Service-Netz", gew: 20),
  (kriterium: "Fahrerkomfort & Assistenz", gew: 15),
  (kriterium: "Telematik-Integration", gew: 10),
)
#let bewertung-a = (8, 7, 9, 8, 7)
#let bewertung-b = (9, 6, 8, 9, 8)
#let bewertung-c = (7, 8, 7, 7, 9)

// Kompatibilitäts-Aliase (051-anhang.typ nutzt Unterstriche)
#let bewertung_a = bewertung-a
#let bewertung_b = bewertung-b
#let bewertung_c = bewertung-c

// ── eEPK / ARIS-Formfarben (oklch; werden im SVG per .to-hex() gewandelt) ───
#let eepk-ev-fill   = userdata.eepk-ev-fill
#let eepk-ev-stroke = userdata.eepk-ev-stroke
#let eepk-fn-fill   = userdata.eepk-fn-fill
#let eepk-fn-stroke = userdata.eepk-fn-stroke
#let eepk-org-fill  = userdata.eepk-org-fill
#let eepk-org-stroke= userdata.eepk-org-stroke
#let eepk-sys-fill  = userdata.eepk-sys-fill
#let eepk-sys-stroke= userdata.eepk-sys-stroke
#let eepk-xor-fill  = userdata.eepk-xor-fill     // Verknüpfungsoperator (OR, AND, XOR) Füllung
#let eepk-xor-stroke= userdata.eepk-xor-stroke   // Verknüpfungsoperator (OR, AND, XOR) Rand
#let eepk-edge      = userdata.eepk-edge

// ── DRUCK-MODUS (Buchdruck-Massstab) ───────────────────────────────────────
//   false = Farbauflage (themes.default)
//   true  = Schwarzweiss-Buchauflage (themes.print, Graustufen + Gitter)
// Ein einziger Schalter fuer alle primaviz-Diagramme.
#let print-mode = false

// ── DIAGRAMM-MINDESTSCHRIFT (Buchdruck: Texte/Ziffern immer lesbar) ────────
// Untergrenze fuer Achsen, Ziffern, Legende in ALLEN Diagrammen.
// Verlag gibt z. B. "mindestens 8pt" vor -> hier eine Zahl aendern.
#let diagramm-schrift = 9pt
