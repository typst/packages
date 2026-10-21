// =======================================================================
// DATEI: validation.typ
// ZWECK: Strikte Schema-Validierung für Einstellungen und Userdata.
// =======================================================================

#let validate-einstellungen(einstellungen, userdata) = {
  // --- USERDATA VALIDIERUNG ---
  assert(type(userdata.mit-sperrvermerk) == bool, message: "userdata.mit-sperrvermerk muss vom Typ 'bool' (true/false) sein.")
  assert(type(userdata.mit-zweitkorrektur) == bool, message: "userdata.mit-zweitkorrektur muss vom Typ 'bool' (true/false) sein.")
  assert(type(userdata.klammern-um-roemische-seiten) == bool, message: "userdata.klammern-um-roemische-seiten muss vom Typ 'bool' sein.")
  assert(type(userdata.pdf-titel) == str, message: "userdata.pdf-titel muss ein String sein.")
  assert(type(userdata.vorname) == str, message: "userdata.vorname muss ein String sein.")
  assert(type(userdata.nachname) == str, message: "userdata.nachname muss ein String sein.")

  // --- EINSTELLUNGEN VALIDIERUNG ---
  assert(type(einstellungen.duplex-druck) == bool, message: "einstellungen.duplex-druck muss vom Typ 'bool' (true/false) sein.")
  assert(type(einstellungen.dev-mode) == bool, message: "einstellungen.dev-mode muss vom Typ 'bool' (true/false) sein.")
  assert(type(einstellungen.bg-color) == color, message: "einstellungen.bg-color muss ein Farbwert (z.B. rgb, oklch) sein.")
  assert(type(einstellungen.text-color) == color, message: "einstellungen.text-color muss ein Farbwert sein.")
  assert(type(einstellungen.primärfarbe) == color, message: "einstellungen.primärfarbe muss ein Farbwert sein.")
  
  assert(type(einstellungen.table-inset) == dictionary, message: "einstellungen.table-inset muss ein Dictionary (z.B. (x: 5pt, y: 5pt)) sein.")
  assert(type(einstellungen.show-vertical-lines) == bool, message: "einstellungen.show-vertical-lines muss vom Typ 'bool' sein.")
  assert(type(einstellungen.show-outer-lines) == bool, message: "einstellungen.show-outer-lines muss vom Typ 'bool' sein.")
  
  assert(type(einstellungen.schriftgroesse) == length, message: "einstellungen.schriftgroesse muss eine Längenangabe (z.B. 11pt) sein.")
  
  assert(einstellungen.quellen-formatierung == "normal" or einstellungen.quellen-formatierung == "italic", message: "einstellungen.quellen-formatierung muss 'normal' oder 'italic' sein.")
}
