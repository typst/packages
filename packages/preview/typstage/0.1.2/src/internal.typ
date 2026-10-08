// The machinery behind a tracked element. Nothing here is public.
//
// Two tricks carry the whole package.
//
// *Geometry.* In HTML export `here().position()` returns `(0, 0)` everywhere,
// so Typst no longer knows where it put anything. Instead every tracked
// element paints a rectangle around itself in a signal colour, `#feHHLL00`,
// fully transparent, but recoverable in the emitted SVG as
// `<path fill="#feHHLL00">` and measurable with `getBoundingClientRect()`.
// `HHLL` is the element's running number. The browser reads back what Typst
// can no longer tell it.
//
// *Two layers.* A slide's background is an `html.frame` of the whole slide in
// which every tracked element merely holds its place with `hide()`. Each one
// additionally goes into an overlay as its own small `html.frame` and is put
// over its marker rectangle by the browser.

#import "config.typ": *

/// A counter, not a state: `state.get()` and `state.update()` at the same
/// place would be circular and never converge. A counter is made for this.
#let element-counter = counter("typstage-n")

/// Marks that may sit anywhere in a slide body, even deeply nested, because a
/// state update inside an `html.frame` is readable afterwards.
#let sprites = state("typstage-sprites", ())

/// Der Schritt, auf dem eine Anmerkung erscheinen soll -- je Folie.
///
/// Nicht der Ort der Anmerkung reist zu `track`, sondern der Schritt reist zu
/// der Stelle, an der die Anmerkung ohnehin schon steht. Geschrieben wird
/// darum nichts als eine Zeichenkette unter einem rein strukturellen
/// Schluessel `"<Elementnummer>/<Gangindex>"`: keine Abfrage, kein Zustand der
/// Folie, kein Zaehlerstand. Das ist der ganze Unterschied zu den gemessenen
/// Sackgassen, an denen dieses Dokument seine Konvergenz verlor -- dort landete
/// ein aus einer Lesung *dieser* Folie gewonnener Wert in einem
/// Sprite-Datensatz.
///
/// Und ausdruecklich *nicht* in `sprites`: `step-jetzt()` greift dort ueber die
/// Elementnummer mit `liste.at(nr - 1)` zu, und `sprite-markup(sp, i + 1)`
/// leitet `data-n` aus dem Feldindex ab. Ein eingeschobener Notiz-Datensatz
/// verschoebe beides. Die Anmerkung wird deshalb Markup und kein Datensatz.
///
/// Zurueckgesetzt je Folie, wie `sprites` und `bridge-jobs`.
#let notiz-schritte = state("typstage-notiz-schritte", (:))

/// Die Nummer, ab der die Marken der Anmerkungen liegen.
///
/// `marker(n)` fasst 16 Bit; Elementnummern je Folie liegen im zweistelligen
/// Bereich. Der Abstand haelt die Notizmarken von den Elementmarken getrennt,
/// ohne dass jemand die beiden Zaehlungen aufeinander abstimmen muesste.
#let notiz-marke-ab = 32768

#let note-state = state("typstage-note", none)
/// Die im Deck geplante Dauer der angehefteten Klassenuhr, in Minuten.
/// Wie die Notiz: eine Folie traegt hoechstens eine, und sie steht am Ende
/// als Zahl an der Folie. Was damit geschieht, entscheidet das Pult -- die
/// Zahl ist ein Vorschlag und kein Befehl.
#let clock-state = state("typstage-clock", none)
#let transition-state = state("typstage-transition", none)

/// Which output is being built.
///
/// Not `target()`: inside an `html.frame` Typst lays out for *pages*, so
/// `target()` reports "paged" there even though the file being written is
/// HTML. The presentation therefore tells its elements which output they are
/// part of, and they read it from here.
#let html-output = state("typstage-html", false)

/// Jobs for bridged elements, collected per slide. Companion packages push
/// into this; the core only hands the result to the runtime.
#let bridge-jobs = state("typstage-bridge", ())

/// Alpha 0: invisible, but Typst keeps the path in the SVG.
#let marker(n) = rgb(254, calc.div-euclid(n, 256), calc.rem(n, 256), 0%)

/// The colour of a pin marker. Like `marker`, only with 253 in the first
/// channel. That is how the runtime tells a pin apart from an element's
/// marker.
#let pin-marker(n) = rgb(253, calc.div-euclid(n, 256), calc.rem(n, 256), 0%)

/// Turn a name into a number from 0 to 65535 (FNV-1a over the bytes).
///
/// Computed on purpose rather than counted: the same name gives the same
/// number on every slide and in every run, without a list having to be kept
/// anywhere and passed along between slides. Two different names can hit the
/// same number. With a handful of pins per transformation that is unlikely,
/// and the consequence would be a wrongly paired glyph, not an error.
#let pin-index(name) = {
  let h = 2166136261
  for b in array(bytes(name)) {
    h = calc.rem(h.bit-xor(b) * 16777619, 4294967296)
  }
  calc.rem(h, 65536)
}

// ── Luft statt Tinte ─────────────────────────────────────────────────────────
//
// Ein Stück einer Zeichnung, das noch nicht an der Reihe ist, darf nicht
// fehlen. Es muss unsichtbar sein und trotzdem seinen Platz behalten, denn
// sonst rechnet cetz seinen Rahmen kleiner und lilaq seine Achse anders, und
// die Zeichnung springt bei jedem Schritt.
//
// Nachgemessen an einer cetz-Zeichnung aus drei Linien, deren dritte über die
// beiden anderen hinausragt, und an einem lilaq-Diagramm aus zwei Reihen:
//
//   weggelassen    Der Platz ist weg. cetz misst 113x85 statt 198x170; bei
//                  lilaq wandert die viewBox von 186.58 auf 189.64, weil die
//                  Achse ohne die zweite Reihe andere Beschriftungen bekommt.
//                  Genau das ist der Sprung, den niemand will.
//   stroke: none   Das Maß bleibt, aber Typst schreibt den Pfad ohne jedes
//                  Strichattribut heraus, aus 933 Bytes werden 831. Bei lilaq
//                  fallen damit die Marken der Reihe als Geometrie mit weg,
//                  141 Pfade statt 149.
//   Alpha 0        Das Maß bleibt, der Pfad bleibt vollständig, nur seine
//                  Farbe trägt 00: `stroke="#00000000"`, 935 Bytes gegen 933.
//                  Bei lilaq stehen alle 149 Pfade und die viewBox auf die
//                  Stelle genau.
//
// Alpha 0 also. Es ist dieselbe Technik, mit der `marker` seine Messfläche in
// die Ausgabe legt, nur hier auf fremde Zeichenpakete angewandt.

/// Dieselbe Sache aus Luft: sichtbar nicht mehr da, gemessen unverändert.
///
/// Was hindurchgeht, geht nur, weil es Maß hält. Eine Farbe verliert ihre
/// Deckkraft, ein Strich seinen Pinsel und sonst nichts, ein Text geht in
/// `hide`, ein Wörterbuch reicht die Frage an seine Farben weiter. Alles
/// andere -- Dicke, Strichelung, Größe -- bleibt stehen, denn daran hängt der
/// Platz.
#let durchsichtig(wert) = {
  let t = type(wert)
  if wert == none or wert == auto { wert }
  else if t == color { wert.transparentize(100%) }
  else if t == stroke {
    // Jedes Feld einzeln zurückgegeben, nicht nur die Farbe: was ein Strich
    // nicht nennt, bleibt `auto`, und `auto` holt sich seinen Wert aus dem
    // Strich, in dem er steht, statt aus dem, der hier gemeint ist. Derselbe
    // Faltungsfehler, gegen den `fester-strich` weiter unten gebaut ist.
    stroke(
      // Ein Pinsel, den es nicht gibt, wird durchsichtiges Schwarz. Welche
      // Farbe es war, spielt bei Alpha 0 keine Rolle mehr.
      paint: if wert.paint == auto { rgb(0, 0, 0, 0%) }
             else { durchsichtig(wert.paint) },
      thickness: wert.thickness, cap: wert.cap, join: wert.join,
      dash: wert.dash, miter-limit: wert.miter-limit,
    )
  } else if t == dictionary {
    // Ein Wörterbuch beschreibt einen Strich oder einen Stil. Nur was Farbe
    // trägt, wird zu Luft; ein `dash: (3pt, 3pt)` ist keine Farbe und würde
    // unter der Frage zerbrechen.
    wert.pairs().map(((k, v)) =>
      (k, if type(v) in (color, stroke, dictionary) { durchsichtig(v) } else { v })
    ).to-dict()
  } else if t == array { wert.map(durchsichtig) }
  else if t == content or t == str {
    // `hide` ist die Antwort des Pakets auf genau diese Frage, seit es das
    // Paket gibt: setzen, ohne zu zeichnen.
    hide(wert)
  } else if t == gradient or repr(t) == "tiling" {
    panic("typstage: a gradient or a tiling cannot be turned into air -- "
      + "neither has an opacity to turn down. Give the piece a colour, or ask "
      + "with from(k) and leave it out; in cetz, hide(…, bounds: true) keeps "
      + "the measure while you do.")
  } else {
    panic("typstage: from() makes colours, strokes, dictionaries and content "
      + "invisible, not " + str(t) + ". What is neither a brush nor content "
      + "carries no ink, and what carries no ink need not disappear either.")
  }
}

// ── Die Kurve, auf der ein Element sich bewegt ───────────────────────────────
//
// Jede Bewegung des Pakets lief bisher auf derselben Kurve, `cubic-bezier(.4,
// 0,.2,1)`, und die bleibt die Vorgabe. `easing:` gibt sie einem einzelnen
// Element aus der Hand: ein Ergebnis darf über sein Ziel hinausschießen und
// zurückschwingen, ein Stapel Stichpunkte darf gleichmäßig ankommen.
//
// Aufgelöst wird der Name hier und nicht in der Laufzeit, und das ist eine
// Entscheidung mit zwei Enden. Hier steht die Tabelle einmal, statt zweimal --
// einmal zum Prüfen und einmal zum Nachschlagen --, und ein Name, den es nicht
// gibt, kommt gar nicht erst im Browser an. Was ins Markup wandert, ist die
// fertige Kurve.
//
// Was hier fehlt, fehlt mit Absicht: Federn und Sprünge (`elastic`, `bounce`)
// sind keine kubischen Bézierkurven und ließen sich nur als Bildfolge
// nachbauen. Die Web Animations API kennt sie nicht, also kennt das Paket sie
// auch nicht.

/// Die benannten Kurven. Name -> was die Web Animations API dafür bekommt.
#let kurven = (
  // Die Hauskurve, ausgeschrieben. Wer sie hinschreibt, bekommt genau das,
  // was ohne `easing:` ohnehin gilt.
  "standard": "cubic-bezier(.4,0,.2,1)",
  // Was die Web Animations API von sich aus kennt, wörtlich durchgereicht.
  "linear": "linear",
  "ease": "ease",
  "ease-in": "ease-in",
  "ease-out": "ease-out",
  "ease-in-out": "ease-in-out",
  // Vier Familien, je dreimal: hinein, heraus, und beides. `in` startet
  // langsam, `out` endet langsam -- und `out` ist fast immer das, was ein
  // Auftritt will, weil das Auge dem Ende zusieht und nicht dem Anfang.
  "in-quad": "cubic-bezier(.11,0,.5,0)",
  "out-quad": "cubic-bezier(.5,1,.89,1)",
  "in-out-quad": "cubic-bezier(.45,0,.55,1)",
  "in-cubic": "cubic-bezier(.32,0,.67,0)",
  "out-cubic": "cubic-bezier(.33,1,.68,1)",
  "in-out-cubic": "cubic-bezier(.65,0,.35,1)",
  "in-expo": "cubic-bezier(.7,0,.84,0)",
  "out-expo": "cubic-bezier(.16,1,.3,1)",
  "in-out-expo": "cubic-bezier(.87,0,.13,1)",
  // Die drei, die über ihr Ziel hinausgehen. Ein Kontrollpunkt liegt außerhalb
  // von 0 bis 1, und genau das ist der Rückschwung.
  "in-back": "cubic-bezier(.36,0,.66,-.56)",
  "out-back": "cubic-bezier(.34,1.56,.64,1)",
  "in-out-back": "cubic-bezier(.68,-.6,.32,1.6)",
)

/// Die Wirkungen, unter denen ein Element kommt und geht.
///
/// Dieselbe Liste, die `EFFECT` in der Laufzeit führt. Sie steht hier ein
/// zweites Mal, damit ein Name, den es nicht gibt, schon beim Übersetzen
/// auffällt und nicht erst als stille Blende im Vortrag. Wer eine Wirkung
/// hinzufügt, fügt sie an beiden Stellen hinzu; das Prüfdeck fährt jede.
#let wirkungen = ("fade", "fade-up", "fade-down", "fade-left", "fade-right",
                  "scale", "scale-down", "blur", "rise", "none", "hold", "draw")

/// The twelve slide transitions, kept here so an unknown name is an error at
/// compile time. The runtime falls back to `fade` when it does not recognise
/// one -- silently, like `enter:` once did, and a talk is the worst place to
/// discover that a name was a typo. Whoever adds a transition adds it in both
/// places; `TRANSITION` in the runtime is the other one.
#let uebergaenge = ("none", "fade", "slide", "push", "cover", "uncover",
                    "zoom", "blur", "iris", "wipe", "flip", "cube")

/// Complain about a transition the package does not know.
#let uebergang-pruefen(spec, wo) = if spec != none and spec != auto {
  let art = if type(spec) == str { spec } else if type(spec) == dictionary {
    spec.at("kind", default: "fade")
  } else { none }
  assert(art != none, message:
    "typstage: " + wo + "(transition: " + repr(spec) + ") -- a transition is a "
    + "name, or a dictionary with `kind:` and its options.")
  assert(art in uebergaenge, message:
    "typstage: " + wo + "(transition: " + repr(art) + ") -- the package does "
    + "not know that transition. The names are: " + uebergaenge.join(", ") + ".")
}

/// Complain about an effect name the package does not know.
///
/// The runtime used to fall back to `fade` without a word. A typo then looked
/// like a working deck that simply moved differently than intended -- and
/// nobody finds that in a talk. `easing:` has answered this way since it was
/// born; now `enter:` and `exit:` do too.
#let wirkung-pruefen(name, feld, wo) = if name != none and name != auto {
  assert(type(name) == str and name in wirkungen, message:
    "typstage: " + wo + "(" + feld + ": " + repr(name) + ") -- the package "
    + "does not know that effect. The names are: " + wirkungen.join(", ") + ".")
}

/// The curve behind a name, or an error.
///
/// `auto` gives back `none`: only a departure from the default gets an
/// attribute, or every element of every deck would carry a new one.
///
/// An unknown name is an error and not a silent default. A typo would
/// otherwise hand back the house curve, and whoever wrote it would spend a
/// while wondering why the overshoot does not overshoot.
#let kurve(name, wo) = {
  if name == auto { return none }
  assert(type(name) == str and name in kurven, message:
    "typstage: " + wo + "(easing: " + repr(name) + ") -- the package does not "
    + "know that curve. The names are: " + kurven.keys().join(", ") + ". "
    + "Without one, \"standard\" applies: the curve this package moves "
    + "everything on.")
  kurven.at(name)
}

/// Plain text out of content, for speaker notes. A paragraph break becomes a
/// blank line.
///
// Warum eine Leerzeile und nicht ein Leerzeichen: die Notiz reist als
// HTML-Attribut und ist darum nur eine Zeichenkette, aber sie hat zwei Leser.
// Das Notizfeld der Sprecheransicht steht auf `white-space: pre-wrap` -- dort
// wird aus den zwei Umbrüchen die Leerzeile, die jemand geschrieben hat.
// Die Blase, die die `s`-Taste aufsteigen lässt, steht auf `normal` und
// faltet dieselben zwei Umbrüche zu einem Leerzeichen; sie bleibt eine Blase.
// Eine Zeichenkette, und jeder bekommt das Seine. Auf Papier hat das Handout
// den Absatz ohnehin immer gehabt: dort steht die Notiz als Inhalt.
//
// Gar nichts war es bisher, und das war der Fehler. Gemessen kam eine Notiz
// aus zwei Absätzen als "Erster Absatz.Zweiter Absatz." an -- ohne auch nur
// ein Leerzeichen dazwischen.
//
// Der `linebreak` bleibt draußen, und das ist Absicht: die Leerzeichen um ein
// `\` herum überleben als `space`, gemessen "Zeile eins.  Zeile zwei.". Das
// ist kein Verlust von Text, nur einer von Umbruch, und wer ihn hier
// mitnähme, nähme die beiden Leerzeichen mit in die neue Zeile.
#let plain-text(c) = {
  if type(c) == str { c } else if type(c) != content { "" } else if c.func() == text {
    c.text
  } else if c.func() == raw { c.text } else if c.has("children") {
    // `.sum(default: "")` und nicht `.join("")`: Typsts `join` gibt auf einer
    // leeren Liste `none` zurueck, nicht die leere Zeichenkette. Ein Inhalt
    // ohne Kinder -- ein leeres `[]` etwa -- liess damit jede Aufrufstelle
    // auflaufen, die danach `.trim()` ruft, und das tun fast alle. Gemessen an
    // einem Handbuchbeispiel: "type none has no method `trim`".
    c.children.map(plain-text).sum(default: "")
  } else if c.has("body") { plain-text(c.body) } else if repr(c.func()) == "space" {
    " "
  } else if repr(c.func()) == "parbreak" { "\n\n" }
  // Zwei Elemente, die Typsts Textsatz aus gewoehnlichem Markup macht und die
  // hier bisher in den leeren Zweig fielen. Gemessen: aus "am meisten -- sie
  // schauen hoch" wurde "am meisten  sie schauen hoch", mit zwei Leerzeichen
  // da, wo der Gedankenstrich stand, und aus "lie" wurde lie. Das traf jede
  // Notiz jedes Decks, in der ein -- oder ein " vorkam.
  //
  // `symbol` traegt sein Zeichen selbst. `smartquote` nicht: es weiss nur, ob
  // es ein doppeltes ist, und welche Form die Sprache verlangt, entschiede
  // erst der Satz. Die gerade Form ist hier die ehrliche -- die Notiz ist eine
  // Zeichenkette in einem Attribut und kein Satzbild.
  else if repr(c.func()) == "symbol" { c.text }
  else if repr(c.func()) == "smartquote" { if c.double { "\"" } else { "'" } }
  else { "" }
}

/// Trägt eine Folie keinen Titel? Die eine Regel für das Band, die Laufzeile,
/// das Lesezeichen und die beiden Chrome-Ebenen im HTML.
///
/// Leer ist, was nichts zeichnet: nichts, Leerraum, Marken und
/// Zustandsschreiber, beliebig in Folgen und `styled` verschachtelt. `h` und
/// `v` zählen dazu, denn `example.typ` schreibt zweimal `== #h(0pt)` für eine
/// Folie ohne Titel; ohne sie änderte sich sein HTML.
///
/// Nicht mehr, was keinen Text hat. Bis dahin entschied `plain-text`, und das
/// gibt für `$a^2$`, ein `box`, ein Bild und ein `context` "" zurück: solche
/// Titel verschwanden samt Band ohne ein Wort. Seit eine leere Überschrift
/// auch die Laufzeile nimmt, verlören sie die noch dazu.
///
/// `data-titel` im HTML bleibt bei `plain-text`: ein Attribut ist eine
/// Zeichenkette, und eine Formel hat dort keinen Namen.
#let leerer-titel(t) = {
  if t == none { return true }
  if type(t) == str { return t.trim() == "" }
  if type(t) != content { return false }
  let art = repr(t.func())
  if art in ("space", "parbreak", "linebreak", "h", "v", "state-update", "counter-update") { return true }
  if t.func() == text { return t.text.trim() == "" }
  if t.func() == metadata { return true }
  if art == "sequence" { return t.children.all(leerer-titel) }
  if art == "styled" { return leerer-titel(t.child) }
  false
}

/// Trägt dieser Titel ein Zeichen, das in einem Lesezeichen stünde?
///
/// Nicht `leerer-titel`: der sagt, ob der Titel *zeichnet*, und ein `box`, ein
/// Bild und eine Formel zeichnen. Ein Lesezeichen ist aber eine Zeichenkette,
/// und aus einem Bild holt Typst keine. Seit `leerer-titel` über das Band
/// entscheidet, hing auch das Lesezeichen daran, und `== #box(width: 20pt)`
/// bekam einen Eintrag ohne Text -- gemessen drei leere Einträge in einem Deck
/// mit einem Kasten-, einem Bild- und einem `context`-Titel. Ein leerer Eintrag
/// im Verzeichnis ist schlechter als keiner.
///
/// `plain-text` genügt hier nicht: es gibt für `$a^2$` "" zurück, während
/// Typsts eigene Auszeichnung daraus "a2" macht. Gemessen an dreizehn Titeln
/// -- Kasten mit Text, Bild mit `alt`, leeres Kästchen, `$a^2$`, `$alpha$`,
/// `#sym.star`, `raw`, `link`, `strong`, `context`, `figure`, `table`, `v` --
/// stimmt dieser Gang mit Typsts Lesezeichen in allen dreizehn überein,
/// `plain-text` in zwölf.
///
/// Der tiefe Gang von `bleed-tief`, mit `text` und `raw` als Blatt.
#let titel-hat-text(c) = {
  if type(c) == str { return c.trim() != "" }
  if type(c) != content { return false }
  if c.func() == text or c.func() == raw { return c.text.trim() != "" }
  if repr(c.func()) == "symbol" { return true }
  for (_, v) in c.fields() {
    if type(v) == content and titel-hat-text(v) { return true }
    if type(v) == array {
      for e in v { if type(e) == content and titel-hat-text(e) { return true } }
    }
  }
  false
}

/// Ist `c` die Marke eines `bleed`?
///
/// Die Marke ist *ein* Element mit Etikett, ein `box`. `+` und `join` machten
/// aus Marke und Wächter eine Folge, und die ginge in der Folge des Rumpfs
/// auf: das Etikett hinge an nichts mehr, das der Gang wiederfände.
#let ist-bleed(c) = (type(c) == content
  and c.at("label", default: none) == <typstage-bleed>)

/// Steht irgendwo in `c` eine `bleed`-Marke?
///
/// Der tiefe Gang von `fussnote-im-titel`, über `fields()`: für Titel, Notizen
/// und den Inhalt eines `bleed` selbst. Im Rumpf wird er nicht gebraucht, dort
/// meldet sich eine Marke, die niemand herausgezogen hat, beim Setzen selbst.
#let bleed-tief(c) = {
  if type(c) != content { return false }
  if ist-bleed(c) { return true }
  for (_, v) in c.fields() {
    if type(v) == content and bleed-tief(v) { return true }
    if type(v) == array {
      for e in v { if type(e) == content and bleed-tief(e) { return true } }
    }
  }
  false
}

/// A speaker note has to carry text, because nothing else reaches the speaker.
///
/// The presenter view transports the note as an HTML attribute, so it can only
/// ever be a string, and the handout prints the note only where there is text
/// in it. A note built purely out of layout therefore arrives nowhere -- and
/// used to do so without a word. Measured: `speaker-note[#fit(table)]` left
/// the handout with an empty ruled column and the presenter view saying "no
/// note". The same held for a bare `rect` or a `layout()` long before `fit`
/// existed; `fit` is only the first documented function that leads there.
#let notiz-pruefen(body) = {
  assert(plain-text(body).trim() != "", message:
    "typstage: a speaker note has to contain text. The presenter view carries "
    + "the note as plain text, and the handout prints it only where there is "
    + "text, so a note made purely of layout -- fit(), a bare rect, an image "
    + "-- would reach neither. Write the note as text. What is meant to be "
    + "seen belongs on the slide, not in the note.")
  // Eine Notiz mit Text und `bleed` käme an der Prüfung oben vorbei. Gesetzt
  // wird eine Notiz nur im Handzettel, und dort meldete sich erst der Wächter
  // der Marke -- mit einem Satz über den Rumpf der Folie, nicht über die Notiz.
  assert(not bleed-tief(body), message:
    "typstage: bleed() cannot stand in a speaker note. The note reaches the "
    + "presenter view as plain text and has no canvas to lay it over. Put "
    + "bleed() at the top of the slide body.")
}

/// Largest step number occurring in a selector.
#let max-step(at) = {
  let numbers = at.matches(regex("\d+")).map(m => int(m.text))
  if numbers.len() == 0 { 1 } else { calc.max(..numbers) }
}

/// Smallest step number a selector covers.
///
/// This is the step an element *first* stands on, and that is what
/// `info().step.number` reports inside it. Not `max-step`, which answers a
/// different question: how far the cursor has to be pushed so that whatever
/// follows carries on after this element. For `"1-2"` the two differ, 1
/// against 2, and only the 1 is the step on which the thing appears.
///
/// An open lower end (`"-3"`) and a selector without a number both mean the
/// first step.
#let min-step(at) = {
  let werte = at.split(",").map(t => t.trim()).filter(t => t != "").map(t => {
    if t.starts-with("-") { 1 } else {
      let z = t.matches(regex("\d+"))
      if z.len() == 0 { 1 } else { int(z.first().text) }
    }
  })
  if werte.len() == 0 { 1 } else { calc.max(1, calc.min(..werte)) }
}

/// Does a selector run to the end of the slide?
///
/// `"2-"` does, and so does everything an `int` or `auto` turns into. `"3"`,
/// `"2-3"` and `"2,4"` do not: they have a last step, and therefore an after.
///
/// Only what has an after can rest in a state after it. `anim(after:
/// "dimmed")` on an open selector would be a promise nothing ever redeems, so
/// it is refused rather than quietly ignored.
#let offenes-ende(sel) = sel.split(",").any(t => t.trim().ends-with("-"))

/// Steht ein Selektor auf diesem Schritt?
///
/// `min-step` und `max-step` sagen nur, wo ein Selektor anfängt und wo er
/// aufhört. Was dazwischen fehlt -- der dritte Schritt in `"2,4-"`, der zweite
/// in `"1,3"` --, sagt erst diese Frage.
///
/// Gerechnet wie `activeAt` in der Laufzeit, und zwar Teil für Teil, damit
/// Papier und Browser dieselbe Antwort geben: an Kommas getrennt, leere Teile
/// übergangen, ein Teil ohne Bindestrich genau dieser Schritt, sonst ein
/// Bereich vom ersten Bindestrich aus, dessen fehlender Anfang 1 heißt und
/// dessen fehlendes Ende das Ende der Folie. Was die Laufzeit nicht als Zahl
/// liest -- `"2-3-4"` gibt ihr `NaN` --, deckt dort keinen Schritt, und hier
/// deckt es auch keinen.
#let steht-auf(sel, s) = {
  let zahl(t) = if t.trim().match(regex("^[0-9]+$")) != none { int(t.trim()) }
  sel.split(",").map(t => t.trim()).filter(t => t != "").any(t => {
    let k = t.position("-")
    if k == none { return zahl(t) == s }
    let a = if k == 0 { 1 } else { zahl(t.slice(0, k)) }
    let rest = t.slice(k + 1)
    let b = if rest == "" { s } else { zahl(rest) }
    a != none and b != none and s >= a and s <= b
  })
}

/// Does a selector cover the first step?
///
/// Decides whether a morph is already present when the slide is entered.
/// `"1-"` and `"1,3"` do, `"2-"` and `"3"` do not.
#let ab-schritt-eins(sel) = {
  sel.split(",").any(teil => {
    let t = teil.trim()
    if t.ends-with("-") {
      let a = t.slice(0, -1).trim()
      a == "" or int(a) <= 1
    } else if t.contains("-") {
      let g = t.split("-")
      int(g.first().trim()) <= 1 and int(g.last().trim()) >= 1
    } else { int(t) == 1 }
  })
}

/// All morphs of the document: each entry is slide, name and the place where
/// that slide's sprites are read. Checked at the end: a delayed morph must not
/// share its name with one on the slide before it, or the flight there is lost.
/// The adaptive groups of a slide: name -> (start, count).
///
/// Die Punkte einer `cue`-Gruppe stehen als Funde im Dokument, nicht in
/// einem Zustand: `cue-layer` und die Prüfung am Deckende fragen danach.
///
/// Kein Zustand, weil die Nummer eines Punktes aus dem entstünde, was schon
/// eingetragen ist -- lesen und schreiben an derselben Stelle, und das
/// konvergiert nicht. Gemessen vergab der erste Aufruf beim zweiten
/// Auszeichnungslauf die 4, und der Punkt 1 verschwand. Dieselbe Lehre steht
/// eine Handvoll Zeilen weiter oben bei `element-counter`.
/// Der Schritt, auf dem eine `cue`-Gruppe beginnt -- je Folie und Name.
///
/// Nur der *erste* Aufruf einer Gruppe liest den Schrittzeiger; alle weiteren
/// rechnen von hier aus. Läse jeder Aufruf den Zeiger, hinge er am vorigen,
/// und die Kette wüchse mit jedem Schritt davor: gemessen brach Typst bei
/// drei Aufrufen hinter einem `anim` nach fünf Layoutläufen ab, und der
/// letzte Punkt blieb auf dem Schritt seines Vorgängers stehen.
///
/// Der erste Aufruf schreibt, was er gelesen hat, und liest beim nächsten
/// Lauf denselben Wert wieder -- ein fester Punkt, keine Kette.
/// Je Gruppenname `(ab: <erster Schritt>, n: <Punkte bisher>)`, und zwar für
/// *diese* Folie: geleert wird der Zustand am Anfang jeder Folie. Daran hängt,
/// dass eine cue-Gruppe zu einer Folie gehört -- ohne ein Lesen des
/// Folienzählers, das in einem gemessenen Element nicht konvergiert.
#let cue-basis = state("typstage-cue-basis", (:))

/// Welcher Schritt gerade auf Papier gesetzt wird, oder `none` für die
/// gewohnte Fassung: eine Seite je Folie, alles in seinem Endzustand.
///
/// Nur der Papierzweig liest ihn. Im Browser bewegt die Laufzeit die Schritte.
#let papier-schritt = state("typstage-papier-schritt", none)


/// Dasselbe für `stagger`, damit `stagger-layer` den Schritt eines Stückes
/// nachschlagen kann. Eingetragen wird nur, was einen Namen trägt.
///
/// Geleert wird es am Anfang jeder Folie, an denselben drei Stellen wie
/// `szene-gruppen`: eine Gruppe gehört zu einer Folie, und ein
/// `stagger-layer`, der einen Namen nur von der Folie davor nennt, meldet
/// sich, statt still auf einem fremden Schritt zu stehen.
#let stagger-gruppen = state("typstage-stagger", (:))

/// Die Szenen einer Folie: Name -> (start, stops).
///
/// `start` ist der Schritt des ersten Halts, wenn die Szene ihn mit `start:`
/// ausschreibt, und sonst der Ort ihres `context`, an dem `scene-layer` den
/// Zeiger selbst liest (siehe dort).
///
/// Dasselbe Buch wie nebenan, aus demselben Grund. `scene` traegt ein, auf
/// welchem Schritt welcher Halt steht; `scene-layer` schlaegt nach und legt
/// sich auf denselben. Wer einen Halt verschiebt, verschiebt alles mit, was
/// daran haengt, ohne dass irgendwo eine Zahl doppelt stuende.
#let szene-gruppen = state("typstage-szenen", (:))

#let morph-index = state("typstage-morphs", ())

// ── Die Kamera ───────────────────────────────────────────────────────────────
//
// Eine Kamerafahrt schreibt nichts auf die Folie. Sie ist eine Anweisung, und
// sie geht denselben Weg wie ein Auftrag an eine Einbettung: als Eintrag in
// eine Liste, die am Ende der Folie als JSON danebensteht. Ein verfolgtes
// Element waere sie nicht -- ein Sprite, das nichts zeigt, haette einen Platz
// zu halten, den es nicht braucht.

/// Die Fahrten einer Folie, in der Reihenfolge ihres Aufschreibens.
///
/// Zurueckgesetzt je Folie, wie `sprites` und `bridge-jobs`.
/// Fortlaufende Nummer für Morph-Namen, die niemand genannt hat.
///
/// `alternatives(morph: true)` und `stagger(morph: true)` geben ihren Stücken
/// denselben Morph-Namen, damit sie ineinander fliegen -- und den muss jemand
/// vergeben. Der Name muss im ganzen Deck eindeutig sein und nicht nur auf
/// seiner Folie: `flugFolie` paart über den Folienrand hinweg nach Namen, und
/// ein Name, der auf der Nachbarfolie noch einmal vorkäme, ergäbe einen Flug,
/// den niemand geschrieben hat.
///
/// Ein `counter` und kein `state`, und ohne `typstage-` im Namen: so fasst ihn
/// `sprite-klammer` (render.typ) wie die Nummer einer Abbildung. Ein Wirt --
/// `anim`, eine Kachel von `tiles` -- setzt seinen Rumpf für den Sprite ein
/// zweites Mal, hinter der Folie, und die Kopie zählte als `state` noch einmal
/// hoch: gemessen an `#anim[#alternatives(morph: true, [R], [T])]` auf zwei
/// Folien die Namen 1 und 3 und im HTML acht Meldungen, an
/// `#tiles([K], stagger(morph: true)[R][T])` auf zwei Folien neun, und die
/// zweite Folie legte R und T beide auf Schritt 6 statt auf 3 und 4 wie das
/// Papier. Als `counter` setzt die Klammer die Kopie auf den Stand des
/// Hintergrunds zurück: Namen 1 und 2, keine Meldung, R und T auf 3 und 4. Und
/// `zaehler-je-dokument` stellt ihn in jedem Dokument eines Bündels außer dem
/// ersten zurück: ein HTML-Dokument hinter dem Handzettel desselben Rumpfes,
/// von Hand mit `document()` gebaut, hieß vorher `ts-alternatives-2`, allein
/// `ts-alternatives-1`, und kommt jetzt Byte für Byte wie allein heraus.
#let auto-morph-nr = counter("ts-automorph")

#let kamera-liste = state("typstage-kamera", ())

/// Jede Fahrt des ganzen Decks, samt Folie und Zielname.
///
/// Fuer dieselbe spaete Frage, die auch den Morphs gestellt wird: zeigt jede
/// Kamera auf ein `pin`, das es auf ihrer Folie wirklich gibt? Frueher laesst
/// sich das nicht fragen. Ein `camera` darf vor seinem Ziel stehen -- eine
/// Folie liest sich von oben nach unten, die Fahrt gehoert oft an den Anfang
/// --, und was auf einer Folie steht, ist erst gesetzt, wenn sie gesetzt ist.
#let kamera-index = state("typstage-kameras", ())

/// Jedes `pin` des ganzen Decks: Folie und Name.
///
/// Der Gegenpart zu `kamera-index`. Ein Pin traegt seinen Namen sonst nirgends
/// mit sich -- `pin-marker` rechnet ihn zu einer Zahl und vergisst ihn --, und
/// eine Kamera, die ins Leere zielt, faende erst im Browser jemand.
#let pin-index-buch = state("typstage-pinnamen", ())

/// Every element that asked to rest dimmed: its slide and the last step of
/// its range. Checked at the end for the same reason the morphs are.
///
/// `anim(after: "dimmed")` refuses an open range on the spot, because a
/// selector that runs to the end of the slide plainly has no after. But a
/// *closed* range can still end with the slide -- `at: "1-2"` on a slide that
/// only ever reaches step 2 -- and then the element never dims either, and
/// nothing says so. That cannot be seen where the element is written: the
/// number of steps a slide has is only settled once the slide has been laid
/// out. So it is noted here and asked at the end, the same late question the
/// morph names are put to.
#let dim-index = state("typstage-dims", ())

/// A stroke that no longer folds into the one it is set inside.
///
/// A `stroke` keeps `auto` for whatever it does not name, and `auto` is
/// filled in from the enclosing stroke rather than from the default. That
/// matters here because the box hands its own border to a `set` rule and
/// puts the document's back inside: a deck's `#set block(stroke: red)` names
/// only the paint, so inside the box's `0.7pt + border` it came out 0.7pt red
/// instead of 1pt red. Measured on the card's colored tab, in all five
/// themes.
///
/// Every field has to be pinned, not just the thickness. Pinning only that
/// one left the same fold a row further along: `#set block(stroke: 3pt)`
/// names the thickness and leaves the paint on `auto`, and the inner edges
/// then came out in the box's border grey instead of black. Measured on a
/// deck without a single label, seven spellings affected, among them
/// `stroke: 3pt` and `stroke: (dash: "dashed")`.
#let fester-strich(v) = {
  let einer(x) = if type(x) == stroke {
    stroke(
      paint: if x.paint == auto { black } else { x.paint },
      thickness: if x.thickness == auto { 1pt } else { x.thickness },
      cap: if x.cap == auto { "butt" } else { x.cap },
      join: if x.join == auto { "miter" } else { x.join },
      dash: if x.dash == auto { none } else { x.dash },
      miter-limit: if x.miter-limit == auto { 4.0 } else { x.miter-limit },
    )
  } else { x }
  if type(v) == dictionary {
    v.pairs().map(((k, x)) => (k, einer(x))).to-dict()
  } else { einer(v) }
}

/// The block style the surrounding document has set.
///
/// `card`, `callout` and the handout frame hand their own surface to a `set`
/// rule instead of writing it as an argument, because only then can a
/// `show label(..): set block(fill: ..)` in a deck reach it. That rule would
/// otherwise run on into every block of their contents and out over the
/// rounded corners, so it is put back inside, and this is what gets put back.
///
/// Not simply `none` and `0pt`. Everything Typst reports here is *partial*,
/// and a partial value folds into the one it is set inside instead of
/// replacing it. Three shapes of that, all measured on a deck that carries no
/// label at all.
///
/// An unset `stroke` or `radius` comes back as an *empty dictionary*, and
/// setting that again changes nothing: that is how the callout's left bar
/// first ended up beside every line of its own text. It becomes `none` and
/// `0pt` by hand.
///
/// A dictionary names only the sides it was given, so `stroke: (left: green)`
/// would leave the box's own border on the other three. The missing sides and
/// corners are filled in.
///
/// And a stroke keeps `auto` for what it does not name: `stroke: red` inside
/// the card's `0.7pt + border` drew 0.7pt red instead of 1pt red. That is what
/// `fester-strich` is for.
///
/// Must be called inside a context.
#let umgebungs-block() = {
  let leer(v) = type(v) == dictionary and v.len() == 0
  let voll(v, seiten, fehlt) = if type(v) != dictionary { v } else {
    seiten.map(k => (k, v.at(k, default: fehlt))).to-dict()
  }
  (
    fill: block.fill,
    stroke: if leer(block.stroke) { none } else {
      fester-strich(voll(block.stroke, ("top", "right", "bottom", "left"), none))
    },
    radius: if leer(block.radius) { 0pt } else {
      voll(block.radius,
           ("top-left", "top-right", "bottom-left", "bottom-right"), 0pt)
    },
  )
}

/// Ein Rahmen des Pakets, den eine `set block`-Regel des Decks nicht erreicht:
/// `block(..nackt, width: …, …)` für den Rahmen selbst, `set block(..nackt)`
/// für alles darin. Und `box(..nackt, …)` für die Kästen, in denen Szene und
/// Daumenkino im Browser stehen: die nähmen sonst eine `set box`-Regel an.
///
/// Für die Kästen, die es nur in *einer* Ausgabe gibt oder in beiden an
/// verschiedener Stelle, und für die, deren Maß ohne die Regel gemessen ist.
/// Die Regel des Decks gilt dessen eigenen Blöcken, und die setzen sich in PDF
/// und HTML gleich; ein Rahmen, den nur eine Seite kennt, gab sie aber nur
/// dort weiter. Und in Typst 0.15 nehmen auch ein `rect` und ein `layout`
/// Einzug, Fläche und Rand einer `set block`-Regel an. Gemessen bei 1600 px
/// Bühnenbreite unter `#set block(inset: 8pt)` vor `presentation`: die
/// Foliennummer stand im HTML 15 px weiter links oben als im PDF, die Leiste
/// war auf Papier ein eingerückter Block von 8pt Höhe, ein Wort hinter
/// `#pause` kam im Browser auf weniger als die Hälfte verkleinert und 424 px
/// neben seinem Ort heraus, ein `anim(place(bottom + right, …))` gar nicht
/// mehr auf die Bühne. Ein `#set block(fill: …)` legte den Rahmen der Zier als
/// Fläche über die Folie, im HTML samt Rumpf.
///
/// Breite und Höhe ebenso. Unter `#set block(width: 80%)` nahm das `layout`
/// eines verfolgten Elements die 80 % selbst an, und ein Block des Decks darin
/// kam auf 80 % davon: hinter `#pause` im Browser 236 px schmaler als auf
/// Papier. Die Abstände (`spacing`, `above`, `below`) setzt `nackt` nicht
/// zurück, und für einen Block im Rumpf verschieben sie nichts. Das `layout`
/// eines `anim` steht im Browser aber als Block im Fluss und bekommt den
/// Blockabstand, wo der Rumpf auf Papier den Abstand seines Inhalts behält:
/// bei 1600 px Bühnenbreite stand ein Absatz in `anim` unter
/// `#set block(spacing: 0.8em)` im Browser 18 px höher als auf Papier, eine
/// enge Liste in `anim` direkt hinter einem Absatz schon ohne jede Regel
/// 25 px tiefer. Das ist älter als `nackt` und nicht behoben.
///
/// Was das Deck selbst setzt, bekommt seine Regel zurück: der Rumpf in
/// `track`, die Zeile einer Anmerkung, ein Block, den eine Label-Regel in die
/// Zier legt -- jeweils als `deck-block`, gelesen, wo die Regel noch gilt. Wo
/// es einen Kasten auf beiden Seiten gleich gibt, etwa den eines `card`,
/// bleibt die Regel des Decks, wie sie ist.
#let nackt = (inset: 0pt, outset: 0pt, fill: none, stroke: none, radius: 0pt,
              clip: false, width: auto, height: auto)


/// The running step cursor: the highest step handed out on this slide so far.
///
/// A counter, not a state, and that is the whole trick. Reading a state and
/// writing to it in the same place is circular and never settles; a counter is
/// built for exactly this and converges.
#let step-cursor = counter("typstage-step")

/// Den Zeiger auf den Schritt rücken, den ein Element mit `at: auto` bekommt.
///
/// `max(…, 2)` und nicht schlicht `+ 1`: Schritt eins gehört dem, was beim
/// Betreten der Folie ohnehin dasteht. Wer `auto` schreibt, will *erscheinen* --
/// und wer erscheinen will, kann nicht schon da sein. Ohne die Untergrenze fiel
/// ein `anim` am Kopf einer Folie mit dem statischen Inhalt zusammen und tat
/// nichts; dasselbe traf die erste Pause, die sich ihren Schritt mit dem Absatz
/// über ihr teilte.
///
/// Nur `auto` ist betroffen. Wer seinen Schritt ausschreibt, bekommt ihn.
/// Ein Schritt weiter. `boden` ist die kleinste Nummer, die dabei
/// herauskommen darf: 2 für alle automatischen Einblendungen und Ketten. Schritt 1 bleibt
/// dem statischen Inhalt vorbehalten; ein explizites `at` oder `start`
/// darf weiterhin auf Schritt 1 zeigen.
/// `um` ist, wie weit gerückt wird: 1 für ein Element, das einen eigenen
/// Schritt bekommt, 0 für eines, das auf dem *aktuellen* beginnt -- eine
/// `scene` etwa fängt dort an, wo der Vortrag gerade steht.
#let schritt-vorruecken(boden: 2, um: 1) = step-cursor.update(c => calc.max(c + um, boden))

/// Der Wähler `was`, beschränkt auf das Dokument, in dem gefragt wird.
///
/// `bundle()` schreibt mehrere Dokumente aus einer Übersetzung, und Typst 0.15
/// führt die Introspektion über das ganze Bündel: ein `query` sieht die Funde
/// aller Dokumente, und ein Verweis auf einen Ort in einem anderen Dokument
/// wird zu einem Verweis in dessen Datei. Gemessen an einem Deck aus einer
/// Agenda mit `contents()` und zwei Abschnitten, als Bündel aus HTML, Foliensatz
/// und Handzettel: die Einträge im Foliensatz und im Handzettel zeigten nach
/// `talk.html#typstage-slide-target-1`, der Rückverweis der Abschnittsseiten in
/// der HTML und im Foliensatz nach `handout.pdf#typstage-contents`; mit
/// `html: none` zeigten die Einträge des Handzettels in `slides.pdf`. Auf
/// dieselbe Weise stand auf Seite 1 des Foliensatzes jede Anmerkung dreimal
/// (siehe `folien-notizen`).
///
/// Das Dokument eines Ortes nennt Typst nicht: `location` hat keine Methode
/// dafür, nachgesehen mit `here().document()`. Aber `document` ist ein
/// Element mit Ort, und das letzte, das vor dem Ort beginnt, ist seines. Seine
/// Grenzen stehen vom ersten Lauf an fest, und die Abfrage kostet keinen Lauf:
/// gemessen blieb die Zahl der Layoutläufe auf allen 17 Beispieldecks in allen
/// vier Ausgaben dieselbe, ebenso in jedem Bündel aus ihnen, mit einer Seite je
/// Folie und Schritt für Schritt, mit und ohne HTML.
///
/// Außerhalb eines Bündels gibt es kein `document`-Element; dann bleibt der
/// Wähler, wie er war, und ein einzelnes Deck fragt genau wie vorher.
///
/// Muss in einem `context` stehen.
#let im-dokument(was) = {
  let davor = query(std.selector(document).before(here()))
  if davor.len() == 0 { was } else {
    std.selector(was).within(davor.last().location())
  }
}

/// Which slide we are on. Only used to scope things that a companion package
/// looks up across the whole document. A query sees every slide at once and
/// has to be able to tell them apart.
#let slide-counter = counter("typstage-slide")

#let cue-luecken-bericht() = context {
  // Hier darf gelesen werden: das läuft am Deckende und nicht in einem
  // gemessenen Element. Deshalb steht die Prüfung hier und nicht in `cue`,
  // das die Folie gar nicht kennen darf.
  //
  // Nach Folie *und* Name getrennt, denn die Ziffern beginnen auf jeder Folie
  // wieder bei 1: ohne die Folie im Schlüssel sähen zwei gleichnamige Gruppen
  // wie eine mit lauter doppelten Ziffern aus.
  //
  // Nur die Punkte des eigenen Dokuments. In `bundle(pages: "step", handout:
  // …)` sahen die Berichte der HTML und des Handzettels sonst die Schrittseiten
  // des Foliensatzes, auf denen jede Gruppe einmal je Schritt steht, und brachen
  // mit "gives a digit to two points on one slide" ab, obwohl keine Ziffer
  // doppelt vergeben war -- dieselbe Lage, die der Foliensatz selbst mit seinem
  // Verzicht auf den Bericht umgeht. Gemessen: `tour` und `vortragen` als
  // solches Bündel bauten nicht, mit oder ohne HTML, allein in allen drei
  // Ausgaben schon.
  //
  // Und nicht aus einem Sprite, wie bei `folien-notizen`. Steht eine Gruppe in
  // einem Wirt -- `anim(cue(…))`, eine Fassung von `alternatives` --, setzt
  // die Überlagerung den Rumpf des Wirts ein zweites Mal, hinter der Folie,
  // wo die Gruppe schon alle ihre Punkte hat, und die Kopie legte ihre Punkte
  // mit den Nummern dahinter noch einmal ab. Gemessen an fünf Punkten in
  // einem `anim`: im Browser "would get a point 10", auf Papier nichts.
  //
  // `state("typstage-sprite-nr")` ist `sprite-number`, das erst weiter unten
  // in dieser Datei steht.
  let gruppen = (:)
  for m in query(im-dokument(<typstage-cue-punkt>)).filter(m =>
      state("typstage-sprite-nr", none).at(m.location()) == none) {
    let folie = slide-counter.at(m.location()).first()
    let schluessel = str(folie) + "|" + m.value.name
    gruppen.insert(schluessel, gruppen.at(schluessel, default: ()) + (m.value.nr,))
  }
  for (schluessel, nrn) in gruppen {
    let name = schluessel.split("|").slice(1).join("|")
    let zu-hoch = nrn.filter(x => x > 9)
    assert(zu-hoch.len() == 0, message:
      "typstage: cue(\"" + name + "\") would get a point "
      + str(if zu-hoch.len() == 0 { 0 } else { calc.min(..zu-hoch) })
      + " on this slide, and the room calls points with the keys 1 to 9. "
      + "Split the group, or reach the rest with the pointer instead of a "
      + "digit.")
    let sortiert = nrn.sorted()
    let doppelt = sortiert.dedup()
    assert(doppelt.len() == sortiert.len(), message:
      "typstage: cue(\"" + name + "\") gives a digit to two points on one "
      + "slide. Two points cannot share one -- give the later call `nr:` a "
      + "free number.")
    let fehlen = range(1, doppelt.last() + 1).filter(x => x not in doppelt)
    assert(fehlen.len() == 0, message:
      "typstage: cue(\"" + name + "\") has no point "
      + fehlen.map(str).join(", ") + ", but has " + str(doppelt.last())
      + ". The room calls a point by its digit, and a digit with nothing "
      + "behind it does nothing at all -- the keypress becomes an ordinary "
      + "page turn. Number the points without a gap, or leave `nr:` out and "
      + "let them count on by themselves.")
  }
}

/// What the deck knows about itself, written once per slide.
///
/// The value is `(nr: int, data: dictionary)`. `data` is exactly what `info()`
/// hands out, minus the step reading; the presentation writes it here before
/// the slide is laid out, and *everything* that prints one of those numbers
/// reads it from here: the footer, the fraction, the progress bar, the running
/// header, and a deck's own `info()`. That is the point of the detour. As long
/// as there is one dictionary per slide, a hand-built footer and the built-in
/// one cannot print different numbers, because there is nothing else to count.
///
/// `nr` counts every slide, title and section slides included, and is kept out
/// of `data` on purpose: `slide.number` deliberately does *not* count those,
/// and two numbers next to each other that differ by a title slide would be a
/// trap. It is needed here only as the key under which a slide files its step
/// count.
#let deck-info = state("typstage-info", none)

/// Is a presentation being laid out right now?
///
/// Steps mean something only inside one, and only there does the cursor get
/// set back to nothing at the start of every slide. Outside, counting would
/// not merely be pointless, it would not settle: `stagger` reads the cursor
/// and hands `track` a selector built from what it read, so read and write
/// chase each other with nothing to anchor them. Measured on the manual, which
/// sets `stagger`, `alternatives` and `tiles` examples on their own on a page:
/// 0, 10, 15, 18, 21 over five runs, and Typst gives up with "did not
/// converge".
///
/// In HTML output `html-output` already draws the same line; this draws it for
/// paged output, where the counting is new.
///
/// Must be called inside a context.
#let im-deck() = deck-info.get() != none

/// Die Schrittzahl jeder Folie auf Papier, unter ihrer Nummer, geschrieben am
/// Ende von `slide-body` und gelesen von `info()`.
///
/// Die Seitenzahl unter `pages: "step"` kommt nicht mehr von hier, sondern vom
/// Zeiger an der Marke `typstage-papier-ende` (siehe `presentation`): der Weg
/// über diesen Zustand ist einen Layoutlauf länger, und mit ihm brauchte jedes
/// Beispieldeck die fünf Läufe, die Typst erlaubt. Was auf Papier nichts zeigt
/// -- eine Kamerafahrt etwa -- rückt den Zeiger dort nicht vor und bekommt
/// deshalb auch keine eigene Seite, statt zweimal identisch dazustehen.
#let papier-zahlen = state("typstage-papier-zahlen", (:))

/// `papier-zahlen`, wie das Dokument es hinterlässt, in dem gefragt wird.
///
/// `final()` ist der Stand am Ende des ganzen Bündels. Jedes Dokument trägt
/// seine Folien unter derselben Nummer ein, und es gilt, wer zuletzt schreibt:
/// gemessen an drei `document()` in einem Bündel, das erste und das zweite mit
/// `pages: "step"`, das dritte ohne. Auf Folie 2 des dritten steht kein
/// Schritt, und dem ersten fehlte darum die zweite Schrittseite seiner Folie 2,
/// dem zweiten die seiner Folie 2 ebenso -- zwei und vier Seiten statt drei und
/// fünf.
///
/// Die Seitenzahl liest die Schleife in `presentation` inzwischen an der Marke
/// `typstage-papier-ende`; gelesen wird dieser Zustand nur noch von `info()`.
/// Dort gilt dasselbe: an drei solchen Dokumenten, Folie 2 mit drei und fünf
/// Schritten im ersten und zweiten, nannte `info().step.total` mit `final()`
/// auf allen Seiten beider 1, hiermit 3 und 5.
///
/// Das Ende eines Dokuments ist der Anfang des nächsten, und dort liest der
/// Zustand, was bis dahin geschrieben war. Das letzte Dokument und ein Deck
/// außerhalb eines Bündels lesen weiter `final()`.
///
/// Muss in einem `context` stehen.
#let papier-zahlen-hier() = {
  let danach = query(std.selector(document).after(here()))
  if danach.len() == 0 { papier-zahlen.final() } else {
    papier-zahlen.at(danach.first().location())
  }
}

/// `"slide"` oder `"step"`, einmal am Anfang des Papierzweigs gesetzt.
///
/// Gebraucht von `camera`: in der Schrittfassung belegt eine Kamerafahrt auf
/// Papier keinen Schritt. Sie zeigt dort nämlich nichts -- "on paper there is
/// no camera" --, und ihre Seite stünde zweimal identisch da. Sie erst
/// belegen und die Seite dann wieder wegzunehmen ginge nicht: die Seitenzahl
/// hinge dann an einer Liste, die beim Setzen der Seiten entsteht, und das
/// Dokument liefe in eine Rückkopplung, die Typst nach fünf Läufen aufgibt.
#let papier-modus = state("typstage-papier-modus", "slide")

/// Steht ein Element mit dieser Spanne auf der Seite, die gerade gesetzt wird?
///
/// Zwei Regeln, und sie gelten nicht für dieselben Elemente.
///
/// Was *ersetzt* wird -- jede Fassung einer `alternatives` außer der letzten,
/// jede Stufe eines `build`, jeder Halt einer `scene` außer dem letzten --,
/// steht nur auf den Schritten seiner Spanne, sonst lägen die Fassungen
/// übereinander. Der Handzettel setzt keinen Schritt (`k == none`), dort steht
/// darum nur, was nicht ersetzt wird.
///
/// Alles andere hält, was `anim` verspricht: auf Papier tut `after` nichts.
/// Eine Seite je Folie zeigt alle Schritte auf einmal, also steht dort auch,
/// was im Browser seine Spanne schon wieder verlassen hat. Nur `pages: "step"`
/// blättert wie der Vortrag: was noch nicht dran ist, fehlt, und was gegangen
/// ist, ist gegangen. Was gedimmt ruht, ist nicht gegangen und bleibt.
///
/// Bis zur Schrittfassung galt das ohne Ausnahme; mit ihr kam die geschlossene
/// Spanne für alle Elemente und beschnitt auch die Seite je Folie. Gemessen an
/// `stagger(dim: true)[Eins][Zwei][Drei]`: auf Papier stand nur „Drei", ohne
/// jede Meldung, und `mosaic-manifesto` druckte eine von drei Fragen. Der
/// Handzettel dagegen druckte die Fassungen einer `alternatives` übereinander.
///
/// Eine Spanne ist nicht immer lückenlos. `anim(at: "1,3")` steht auf Schritt
/// eins, fehlt auf zwei und steht auf drei wieder -- im Browser; auf Papier
/// kannte diese Funktion nur Anfang und Ende und setzte es unter
/// `pages: "step"` auch auf die Seite von Schritt zwei. Gemessen an einer Folie
/// mit `"2,4-"`, `(1, 3)`, `"1-2,4"` (gedimmt), `"2-3,5"` und `"5"`: vier
/// Elemente standen auf drei von fünf Schrittseiten, auf denen die Laufzeit
/// sie verbirgt. Deshalb fragt die Seite jetzt `steht-auf`, dieselbe Regel wie
/// `activeAt`. Eine Lücke ist nur in der Schrittfassung eine Lücke; die Seite
/// je Folie und der Handzettel zeigen weiter alles, was nicht ersetzt wird. Und
/// sie ist auch für Gedimmtes eine: die Laufzeit dimmt erst hinter dem letzten
/// Schritt der Spanne, in der Lücke steht nichts.
///
/// `k` nimmt den Schritt von außen, statt ihn noch einmal zu lesen: gebraucht
/// vom Anmerkungsblock unter `pages: "step"`, der ihn schon gelesen hat (siehe
/// `papier-verborgen`).
#let papier-zeigt(sel, ersetzt: false, bleibt: false, k: auto) = {
  let k = if k == auto { papier-schritt.get() } else { k }
  if k == none { return not ersetzt }
  if steht-auf(sel, k) { return true }
  if k < min-step(sel) or ersetzt { return false }
  if papier-modus.get() != "step" { return true }
  bleibt and not offenes-ende(sel) and k > max-step(sel)
}


/// The steps the content being laid out right now stands inside, innermost
/// last. Empty outside any tracked element.
///
/// A stack, and pushed and popped with `update(fn)` rather than saved with a
/// `get()` and put back. That is the whole reason it is a stack, and it was
/// paid for: with a `get()`, the value *written* depended on a value *read*,
/// and Typst settles such a chain at one link per layout run. On a slide with
/// four tracked elements the chain ran past the five runs Typst allows, and it
/// said so: "did not converge", with the reading coming out 1, 1, 1, 1, 3 and
/// only the run after that saying 4. An update that is a function of the
/// previous value needs no read, so the whole stack settles in one run.
///
/// It says nothing about a sprite: there `sprite-number` answers, because the
/// step of a sprite would take a layout run too long to travel through a state
/// of its own.
#let step-here = state("typstage-step-here", ())

/// The step the content being laid out right now first stands on.
///
/// 1 outside any tracked element, and inside one the first step of its
/// selector. Must be called inside a context.
/// Which sprite is being laid out, by its element number, or `none`.
///
/// Set outright by `sprite-markup`, and the *number* is the point: it is the
/// running index of the element, which settles as soon as the background frame
/// has run. Its step does not, because the step comes off the cursor, and a
/// cursor-reading group such as `tiles` or `stagger` between two reveals makes
/// that a chain several layout runs long. Handing the step itself through a
/// state put one more run on top of that chain, and Typst allows five:
/// measured on `anim`, `tiles`, `anim` with an `info()` inside, the reading
/// came out 1, 1, 1, 1, 3 and settled on 4 only afterwards, with "did not
/// converge" to go with it. Reading the step out of `sprites` here instead of
/// carrying it in costs nothing and lands in one run.
#let sprite-number = state("typstage-sprite-nr", none)

/// The step the content being laid out right now first stands on.
///
/// Three cases, in this order. Inside a tracked element the stack says it.
/// Inside a sprite, whose body is the same content laid out a second time, the
/// element's own entry in `sprites` says it, and that still holds after a
/// nested element has come and gone. Anywhere else, content stands from the
/// first step.
///
/// Must be called inside a context.
#let step-jetzt() = {
  let stapel = step-here.get()
  if stapel.len() > 0 { return calc.max(1, stapel.last()) }
  let nr = sprite-number.get()
  if nr == none { return 1 }
  let liste = sprites.get()
  if nr >= 1 and nr <= liste.len() { calc.max(1, liste.at(nr - 1).step) } else { 1 }
}

/// A name, however it was written.
///
/// Names identify things across slides: a morph that flies, a frame that
/// receives jobs. `<pythagoras>` reads better than `"pythagoras"` and Typst
/// colours it as what it is, so both are allowed everywhere a name is taken.
#let name-of(value) = {
  if type(value) == label { str(value) }
  else if type(value) == str { value }
  else {
    panic("typstage: a name is a string or a label, not " + str(type(value)))
  }
}

/// Bring a step selector into the one form the runtime understands.
///
/// - `2` → `"2-"`, from step two on. By far the common case: of 242 selectors
///   in the real decks, 239 were open ranges.
/// - `(1, 3)` → `"1,3"`
/// - `"2-"`, `"1-2"`, `"2,4"`, `"-2"`, `"3"` stay as they are.
///
/// `auto` is *not* resolved here. It needs the cursor and hence a context.
#let platz-pruefen(at, feld, wo) = if at != auto {
  let heil = if type(at) == int { at >= 1 } else if type(at) == array {
    at.len() > 0 and at.all(x => (type(x) == int and x >= 1)
                                 or (type(x) == str and x.trim() != ""))
  } else if type(at) == str {
    // Erlaubt ist, was `data-at` in der Laufzeit lesen kann: Zahlen, Bereiche
    // mit einem Bindestrich, beides mit Komma gereiht. Mindestens eine Zahl
    // muss darin stehen, und keine davon darf null sein -- gezaehlt wird ab 1.
    let zahlen = at.matches(regex("\\d+")).map(m => int(m.text))
    (at.matches(regex("^[0-9,\\-\\s]+$")).len() == 1
     and zahlen.len() > 0
     and zahlen.all(z => z >= 1))
  } else { false }
  assert(heil, message:
    "typstage: " + wo + "(" + feld + ": " + repr(at) + ") -- a place is a whole "
    + "number from 1 upwards, a list of them, or a range like \"2-\", "
    + "\"1-3\" or \"2,4\". Steps are counted from 1, so 0 is never a place. "
    + "An unreadable one used to make the element vanish for the whole slide "
    + "without a word.")
  // Eine umgedrehte Spanne ist lesbar und trotzdem keine. `"4-2"` deckt im
  // Browser keinen Schritt (`activeAt` will s >= 4 und s <= 2) und auf Papier
  // ebenso wenig (`steht-auf`, dieselbe Rechnung) -- aber wie weit sie reicht,
  // sagen beide verschieden: `endeBei` liest die 2, `max-step` die 4.
  // Gemessen an `anim(at: "4-2")` neben `anim(at: 2)`: die Folie bekam vier
  // Schritte, die letzten drei gleich; die Seite je Folie und der Handzettel
  // druckten das Element, das der Vortrag nie zeigt, die Schrittseiten nicht.
  // Mit `after: "dimmed"` rechnen die Funktionen der Laufzeit es auf Schritt 3
  // und 4 gedimmt, ohne dass es je voll dagestanden hätte, und die
  // Schrittseiten lassen es weiter weg. Welche Lesart gemeint war, weiß nur,
  // wer es geschrieben hat.
  //
  // Geprüft wird Teil für Teil wie in `steht-auf`, auch in einer Liste, die
  // `selector` genauso an Kommas zusammenfügt. Kein Teil des Pakets baut selbst
  // eine umgedrehte, die hier ankäme: nur `anim` und `morph` fragen hier, und
  // aus dem Paket ruft sie nur noch `#pause`, mit `auto`
  // (`alternatives(morph: …)` geht inzwischen selbst an `track`).
  // Was `build`, `cue`, `stagger` und `auto-auswahl` bauen, geht an `track`
  // direkt und steigt ohnehin: `build(at:)` verlangt steigende Zahlen, und
  // `auto-auswahl` schreibt `"von-bis"` nur, wenn `bis > von`.
  let teile = if type(at) == array { at.map(x => str(x)) } else { (str(at),) }
  let verkehrt = teile.join(",").split(",").map(t => t.trim()).find(t => {
    let g = t.match(regex("^(\\d+)\\s*-\\s*(\\d+)$"))
    g != none and int(g.captures.at(0)) > int(g.captures.at(1))
  })
  // Die Meldung entsteht nur, wenn es eine gibt: die Argumente von `assert`
  // werden auch dann ausgewertet, wenn alles stimmt, und `str(none)` bricht ab.
  if verkehrt != none {
    let (bis, von) = verkehrt.split("-").map(t => t.trim())
    assert(false, message:
      "typstage: " + wo + "(" + feld + ": " + repr(at) + ") -- the range \""
      + verkehrt + "\" runs backwards. A range is written from its first step "
      + "to its last: \"" + von + "-" + bis + "\" for steps " + von + " to "
      + bis + ". A backwards one used to cover no step in the browser, while "
      + "the page for the slide printed the element anyway.")
  }
}

#let selector(at) = {
  if type(at) == int { str(at) + "-" }
  else if type(at) == array {
    at.map(x => if type(x) == int { str(x) } else { x }).join(",")
  } else { at }
}

/// A tracked element: holds its place in the background, paints its marker and
/// registers itself for the overlay.
///
/// In paged output none of this applies. There is no overlay and there are no
/// steps, so the element simply stands where Typst puts it.
/// `width` decides how wide the tracked element becomes.
///
/// - `auto`: as wide as its content. Right for inline things: a morphing
///   glyph should not claim the whole line.
/// - a length: that width. Block elements default to the full available
///   width, because that is what a block *is*: without it an `align(center,
///   …)` inside `anim` has no room to centre in and silently stays left.
/// Does the body carry an `fr` spacer at its top level?
///
/// `fr` means "share of what is left over", and what is left over is
/// distributed by the parent among the siblings. A tracked element, though,
/// is measured on its own, and `measure` does not see the siblings.
/// Therefore an `fr` that applies *to the element itself* cannot be resolved
/// here as a matter of principle; an `fr` further inside (say
/// `grid(rows: (1fr, 1fr))`) is not affected by this, because it distributes
/// the grid among itself.
#let fr-teile(body) = {
  let teile = if body == none { () }
              else if body.has("children") { body.children } else { (body,) }
  teile.filter(c => c.func() in (v, h) and type(c.amount) == fraction)
}

// ── Ein Maß aus Rundungsstaub ist keines ───────────────────────────────────
//
// Eine senkrechte `line` misst nicht null breit, sondern 4,898587e-15 pt: der
// Kosinus von 90° ist in Gleitkomma nicht sauber null, und `measure` reicht
// den Staub durch. Gedruckt sieht man ihn nie -- `repr()` sagt brav `0pt` --,
// aber ein Vergleich auf `== 0pt` sagt nein, und daran hängt weiter unten, ob
// ein Element ohne Fläche Luft um seine Marke bekommt.
//
// Ohne Luft bekam die Marke Breite null, die Hülle im Browser `width: 0%`,
// und ein Ansichtsfenster der Breite null skaliert seinen Inhalt unter
// `xMidYMid meet` auf null. Die Linie stand im PDF und fehlte im Browser --
// still, denn es klagte niemand. Gemessen an vier Fällen nebeneinander: die
// waagerechte Linie (Höhe exakt 0pt) bekam ihre Luft, die um 90° gedrehte
// nicht, und nur die gedrehte verschwand.
//
// Die Schwelle ist ein Hundertstel Punkt. Was dünner ist als das, trägt keine
// Fläche, die ein Sprite füllen könnte; was dicker ist, hat eine und braucht
// die Luft nicht.
#let ohne-mass(l) = l < 0.01pt

/// Does the body consist *only* of such spacers (and empty space)?
#let nur-fr(body) = {
  let teile = if body == none { () }
              else if body.has("children") { body.children } else { (body,) }
  let leer = [ ].func()
  teile.len() > 0 and teile.all(c =>
    (c.func() in (v, h) and type(c.amount) == fraction)
    or c.func() in (leer, parbreak))
}

/// Does the body want to fill the offered width?
///
/// The difference cannot be measured: `measure(align(center, rect(80pt)),
/// width: 400pt)` returns 80pt, not 400. A block equation does the same.
/// Both need the full space regardless, or the `align` has no room to
/// center in and the equation has no middle.
///
/// So this does not measure, it looks. A few levels deep, since
/// `text(…)[$ x $]` wraps the equation in a `styled` with `child`, and a
/// paragraph in a `sequence` with `children`: the top level rarely holds
/// what matters.
///
/// Two things depend on this: whether a tracked element in an `auto` grid
/// column pulls the whole width to itself (and thereby pushes the `1fr`
/// neighbour column to zero), and whether frame and region must be the same
/// width so the body does not land next to its marker.
#let will-fuellen(body, tiefe: 4) = {
  if body == none or tiefe <= 0 { return false }
  let f = body.func()
  if f == align { return true }
  if f == math.equation and body.at("block", default: false) { return true }
  if body.has("child") { return will-fuellen(body.child, tiefe: tiefe - 1) }
  if body.has("children") {
    return body.children.any(c => will-fuellen(c, tiefe: tiefe - 1))
  }
  false
}

// ── Fitting content into the room it has ─────────────────────────────────────
//
// The geometry below is adapted from mosaic's `fit`, which adapted Touying
// 0.7.4's `fit-to-width` and `fit-to-height`; Touying credits the fitting work
// to Andreas Kröpelin (Polylux PR #91) and to ntjess. All three are under the
// MIT license, as is this package.

/// How many `fit` blocks the content being laid out sits inside.
///
/// A count, not a yes or no, so a fit inside a fit puts the outer one back
/// when it is done. Updated as a function of the previous value and never read
/// and written back, for the reason spelled out at `step-here`.
#let im-fit = state("typstage-in-fit", 0)

/// A length no fitter can work with.
///
/// Under `measure` a region is reported as unbounded, and a fit inside a
/// container that has no height of its own gets nothing. Both would drive the
/// factor to infinity or to zero, so both mean "leave the body alone".
#let unloesbar(l) = (
  float.is-infinite(l.pt()) or float.is-nan(l.pt()) or l <= 0pt
)

/// A `width` or `height` argument against the region that hosts it.
///
/// `auto` is the whole region. A ratio counts against it, a length is itself,
/// and a length is measured rather than read, because `2em` only becomes
/// points where the text size is known. Must be called inside a context.
#let fit-mass(wert, ganz) = {
  if wert == auto { ganz }
  else if type(wert) == ratio { ganz * wert }
  else if type(wert) == relative { ganz * wert.ratio + measure(v(wert.length)).height }
  else if type(wert) == length { measure(v(wert)).height }
  else {
    panic("typstage: fit() takes auto, a length or a ratio for width and "
          + "height, not " + str(type(wert)))
  }
}

/// Content that exactly fills its place measures as 100%, so that is the line
/// between growing and shrinking rather than a number to turn.
///
/// The tolerance around it is a guard against rounding, not a setting. A block
/// that fits to within a fraction of a point reports a factor a hair off 100%,
/// and rescaling on that would resize something that was already right.
#let fit-toleranz = 0.05%

/// The one factor that brings a measured size into the room it has.
///
/// The smaller of the two axes wins, so the proportions are kept. An axis
/// whose measure is zero constrains nothing.
#let fit-faktor(mass, breite, hoehe) = {
  let werte = ()
  if mass.width > 0pt { werte.push(breite / mass.width) }
  if mass.height > 0pt { werte.push(hoehe / mass.height) }
  if werte.len() == 0 { 100% } else { calc.min(..werte) * 100% }
}

/// Does a body carry a `pause`, however deep?
///
/// `apply-pauses` walks only the top level of a slide body, and it walks it
/// *before* anything is laid out. A `fit` holds its body inside a closure, so
/// that walk never reaches in. This one goes all the way down, because inside
/// a fit a pause is lost wherever it stands, not only at the top.
#let hat-pause(c) = {
  if type(c) != content { return false }
  if c.func() == metadata { return c.value == "typstage-pause" }
  if c.has("children") { return c.children.any(hat-pause) }
  if c.has("child") { return hat-pause(c.child) }
  if c.has("body") { return hat-pause(c.body) }
  false
}

/// Does the top level of a slide body carry the `invert` marker?
///
/// Deliberately the *shallow* walk, the same one `apply-pauses` does, and not
/// the one above. It runs on every slide of every deck, before anything is
/// laid out, and a full descent into every block of every slide would be paid
/// for by decks that never invert a slide. A `#set` or `#show` written above
/// the marker wraps it in a `styled`, and a marker produced by a `#for` sits
/// in a nested `sequence`; both are unpacked, so the two cases that actually
/// happen are covered. Deeper than that, the marker is not found, and the
/// slide is simply not inverted.
#let hat-invert(body) = {
  if type(body) != content { return false }
  if body.func() == metadata { return body.value == "typstage-invert" }
  if body.has("children") { return body.children.any(hat-invert) }
  if body.has("child") { return hat-invert(body.child) }
  if body.has("body") { return hat-invert(body.body) }
  false
}

/// Der Inhalt einer `bleed`-Marke: `box` > Folge > erstes Kind `metadata`.
#let bleed-inhalt(c) = c.body.children.first().value

/// Zieht die `bleed`-Marken aus der obersten Ebene eines Folienrumpfs.
///
/// Der flache Gang von `pause-tokens`: in Folgen und in `styled` hinein, und
/// der Stil reist mit, damit ein `#set` oder `#show` über dem `bleed` auch
/// dessen Inhalt erreicht. Tiefer nicht. Eine Marke in einem `block`, einem
/// `grid`, einem `anim` wird nicht gefunden und meldet sich beim Setzen selbst.
///
/// Zurück kommt
/// - `rumpf`: der Rumpf ohne die Marken, ohne Fund das Original. `presentation`
///   übernimmt ihn nur bei einem Fund; eine Folie ohne `bleed` behält ihren
///   Rumpf, wie er geschrieben war. Gemessen setzten alle Beispieldecks danach
///   Seite für Seite wie zuvor, und ihr HTML kam bytegleich heraus;
/// - `funde`: die Inhalte, jeder mit dem Stil seines Orts;
/// - `vor`: was vor dem ersten Fund stand, `none`, `"pause"` oder `"inhalt"`;
/// - `inhalt`: dasselbe für den ganzen Teilbaum, für den Gang eine Ebene höher.
///
/// Still, also kein Inhalt davor, sind Leerraum, leerer Text, Zustands- und
/// Zählerschreiber und Marken außer `#pause`. Damit dürfen `#set`- und
/// `#show`-Regeln, `#invert`, `#transition`, `#speaker-note` und `#class-clock`
/// über dem `bleed` stehen; die letzten drei sind Zustandsschreiber. Ein `#v`
/// davor ist dagegen Inhalt: es nimmt dem Rumpf Platz.
#let bleed-teilen(c, restyle: x => x) = {
  if type(c) != content { return (rumpf: c, funde: (), vor: none, inhalt: none) }
  if ist-bleed(c) {
    return (rumpf: [], funde: (restyle(bleed-inhalt(c)),), vor: none, inhalt: none)
  }
  let art = repr(c.func())
  if art == "sequence" and c.has("children") {
    let teile = ()
    let funde = ()
    let vor = none
    let erstes = none
    for k in c.children {
      let t = bleed-teilen(k, restyle: restyle)
      if t.funde.len() > 0 and funde.len() == 0 {
        vor = if erstes != none { erstes } else { t.vor }
      }
      if erstes == none { erstes = t.inhalt }
      funde += t.funde
      teile.push(t.rumpf)
    }
    if funde.len() == 0 { return (rumpf: c, funde: (), vor: none, inhalt: erstes) }
    return (rumpf: teile.join(), funde: funde, vor: vor, inhalt: erstes)
  }
  if art == "styled" and c.has("child") {
    let maker = c.func()
    let st = c.styles
    let t = bleed-teilen(c.child, restyle: x => restyle(maker(x, st)))
    if t.funde.len() == 0 { return (rumpf: c, funde: (), vor: none, inhalt: t.inhalt) }
    return (rumpf: maker(t.rumpf, st), funde: t.funde, vor: t.vor, inhalt: t.inhalt)
  }
  let still = (art in ("space", "parbreak", "linebreak", "state-update", "counter-update")
    or (c.func() == text and c.text.trim() == "")
    or (c.func() == metadata and c.value != "typstage-pause"))
  let inhalt = if still { none } else if c.func() == metadata { "pause" } else { "inhalt" }
  (rumpf: c, funde: (), vor: none, inhalt: inhalt)
}

/// Wie viele Fußnoten stehen im Rumpf dieses verfolgten Elements?
///
/// Derselbe flache Gang wie `hat-invert` nebenan, nur mit `footnote` als Blatt.
/// Er sieht genau die Fußnoten, deren *innerste* Aufdeckkette dieses Element
/// ist: eine weitere Kette darin -- `stagger`, `anim`, `alternatives` -- ist an
/// dieser Stelle ein blankes `context`, und in einen Verschluss sieht kein Gang
/// hinein. Gemessen: `fields()` eines solchen Elements ist leer, der Gang
/// findet null Fußnoten darin. Genau das wird gebraucht, denn die innere Kette
/// zählt ihre eigenen selbst.
///
/// Eine Fußnote, die erst ein `context` beim Satz erzeugt, bleibt unsichtbar.
/// Sie bekommt dann keinen Schritt, und ohne Schritt gilt die Vorgabe `"1-"` --
/// also genau das Verhalten von heute. Der einzig mögliche Fehlschlag ist
/// "es bleibt, wie es war", nie "die Anmerkung ist weg".
#let notiz-zahl(body) = {
  if type(body) != content { return 0 }
  if body.func() == footnote { return 1 }
  if body.has("children") {
    return body.children.fold(0, (s, c) => s + notiz-zahl(c))
  }
  if body.has("child") { return notiz-zahl(body.child) }
  if body.has("body") { return notiz-zahl(body.body) }
  0
}

/// Die Fußnoten einer Folie, so wie ihre Anmerkungen am Fuß stehen.
///
/// Gefragt wird die Abfrage und nicht der Rumpf: ein Gang durch den Inhalt
/// *vor* dem Setzen findet eine Fußnote nur dort, wo sie geschrieben steht, und
/// eine Aufdeckkette gibt ein `context` zurück.
///
/// Zugeordnet wird über `deck-info` am Ort der Fußnote und nicht über die
/// Seitenzahl: im Handout stehen mehrere Folien auf einer Seite. Die Seite
/// kommt trotzdem dazu, wo es sie gibt -- `pages: "step"` setzt dieselbe Folie
/// mehrfach, und ohne sie stünden die Anmerkungen dreifach untereinander.
///
/// Und nicht aus einem Sprite: der Rumpf eines verfolgten Elements wird in der
/// Überlagerung ein zweites Mal gesetzt, seine Fußnoten kämen sonst doppelt.
///
/// Und nur aus dem eigenen Dokument (`im-dokument`). Folie und Seite zählen in
/// jedem Dokument eines Bündels von vorn, und im Browser meldet jeder Ort
/// Seite 1. Gemessen an zwei Folien mit je einer Fußnote als Bündel aus HTML,
/// Foliensatz und Handzettel: auf Seite 1 des Foliensatzes stand die Anmerkung
/// dreimal, im Handzettel die der ersten Folie dreimal und die der zweiten
/// zweimal, in der HTML ebenso.
///
/// Muss in einem `context` stehen.
#let folien-notizen(nr, seite: none) = query(im-dokument(footnote)).filter(f => {
  let ort = f.location()
  (deck-info.at(ort).nr == nr
   and (seite == none or ort.page() == seite)
   and sprite-number.at(ort) == none)
})

/// Die Spanne einer Anmerkung, deren Fußnote in mehreren Ketten steckt.
///
/// `eigen` ist der Eintrag der innersten Kette, `meine` die Nummern aller
/// Sprites, in denen die Fußnote steht, `liste` ist `sprites.get()`.
///
/// Die innerste Kette allein genügt nicht. In der Laufzeit ist nichts
/// sichtbarer als das, worin es steckt (`zustand`): ein Sprite wird von seinem
/// Wirt gedeckelt, die Kette hinauf. Eine Anmerkung hat keinen Wirt -- ihre
/// Marke steht im Fuß der Folie und nicht in einem Sprite --, also deckelte sie
/// niemand. Gemessen im Browser an `alternatives([Aussen eins #anim(at: "1-")
/// [innen#footnote[n-innen]]], [Aussen zwei#footnote[n-zwei]])`: auf Schritt
/// zwei beide Sprites der ersten Fassung bei Deckkraft 0, die Anmerkung
/// „n-innen" mit `data-at="1-"` bei 1. Ebenso eine Fußnote in einem `stagger`
/// in einer Fassung. Die Schrittseite blendete sie richtig aus, weil dort jede
/// Kette ihre eigene Marke an die Fußnote hängt (`papier-verborgen`).
///
/// Gerechnet wird darum, was die Laufzeit für die Marke rechnet: je Schritt der
/// Zustand jeder Kette wie in `eigenerZustand` -- 2 steht, 1 ruht gedimmt, 0
/// fort --, ein fehlendes `after` vom Wirt geerbt wie in `erbt`, und davon das
/// Minimum. Hinter der höchsten Zahl aller Selektoren ändert sich keine Kette
/// mehr, dort endet die Rechnung.
///
/// Das Ergebnis muss wieder ein `data-at` mit höchstens `after: "dimmed"` sein,
/// und nicht jedes Minimum ist eines: gedimmt ruhen kann eine Anmerkung nur
/// hinter ihrer Spanne und bis zum Ende der Folie. Ein gedimmtes Stück in einer
/// Fassung, die danach geht -- `alternatives([#stagger(dim: true)[A][B]], [C])`
/// --, ruht erst und geht dann. Dann bekommt die Anmerkung die Schritte, auf
/// denen ihre Marke zu sehen ist, ohne Dimmen: sie steht, solange die Marke
/// steht, in voller Stärke, wie auf der Schrittseite, wo nichts gedimmt wird.
/// Kein Schritt zeigt damit eine Anmerkung ohne Marke oder eine Marke ohne
/// Anmerkung.
///
/// Alle Zahlen des Ergebnisses sind Anfänge und Enden von Teilen der Selektoren
/// der Ketten, und die stehen auf derselben Folie: die Schrittzahl, die die
/// Laufzeit aus allen `data-at` einer Folie abliest, bleibt dieselbe. Wo das
/// Minimum der innersten Kette gleicht, bleibt `eigen` Zeichen für Zeichen.
///
/// Gelesen wird nichts Neues: `sprites.get()` liest die Überlagerung ohnehin,
/// an derselben Stelle.
#let notiz-kette(eigen, meine, liste) = {
  let innen = calc.max(..meine)
  let ketten = ()
  for n in meine.sorted().dedup() {
    let sp = liste.at(n - 1, default: none)
    if sp == none { return eigen }
    // Die Bilder einer `scene` oder eines `flipbook` setzen den Fußnotenzähler
    // nicht auf den Stand des Hintergrunds (`sprite-markup`), ihre Fußnoten
    // zählen in der Überlagerung einfach weiter -- und tragen damit die Nummern
    // von Fußnoten *hinter* ihnen. Eine solche Nummer sagt also nicht, dass die
    // Fußnote im Bild steckt, und als äußere Kette zählt ein Bild darum nicht;
    // es bleibt beim Schritt der innersten Kette wie bisher. Gemessen an
    // `anim(at: "1")[Eins#footnote[…]]`, einer Szene mit Fußnote und `start: 3`,
    // dann `anim(at: "1")[Zwei#footnote[…]]`: ohne diese Zeile bekam die
    // Anmerkung zu „Zwei" `data-at="0"` und stand nie.
    if sp.raw-frames != none and n != innen { continue }
    let after = sp.extra.at("after", default: none)
    let wirt = if ketten.len() > 0 { ketten.last() }
    let erbt = if after == none and wirt != none and wirt.at == sp.at {
      wirt.after
    } else { after }
    ketten.push((at: sp.at, after: after, dim: erbt == "dimmed"))
  }
  if ketten.len() < 2 { return eigen }
  let stand(at, dim, s) = if steht-auf(at, s) { 2 } else if (
    dim and not offenes-ende(at) and s > max-step(at)) { 1 } else { 0 }
  let bis = calc.max(max-step(eigen.at), ..ketten.map(k => max-step(k.at))) + 1
  let schritte = range(1, bis + 1)
  let soll = schritte.map(s => calc.min(..ketten.map(k => stand(k.at, k.dim, s))))
  let ist = schritte.map(s => stand(eigen.at, eigen.after == "dimmed", s))
  if soll == ist { return eigen }
  // Die Schritte, auf denen `gilt` zutrifft, als Selektor. Ein Lauf bis `bis`
  // bleibt offen, denn dahinter ändert sich nichts mehr.
  let spanne(gilt) = {
    let teile = ()
    let von = none
    for s in schritte {
      if gilt(soll.at(s - 1)) {
        if von == none { von = s }
        if s == bis { teile.push(str(von) + "-") }
      } else if von != none {
        teile.push(if von == s - 1 { str(von) } else { str(von) + "-" + str(s - 1) })
        von = none
      }
    }
    // „Nie": `activeAt` liest `"0"` als Schritt null, und den gibt es nicht.
    if teile.len() == 0 { "0" } else { teile.join(",") }
  }
  let letzter = schritte.filter(s => soll.at(s - 1) == 2).at(-1, default: 0)
  let ruht = soll.last() == 1 and schritte.all(s => {
    let z = soll.at(s - 1)
    z == 2 or z == (if s > letzter { 1 } else { 0 })
  })
  if soll.all(z => z != 1) {
    (at: spanne(z => z == 2), delay: eigen.delay, after: none)
  } else if ruht {
    (at: spanne(z => z == 2), delay: eigen.delay, after: "dimmed")
  } else {
    (at: spanne(z => z >= 1), delay: eigen.delay, after: none)
  }
}

/// Zu jeder Anmerkung dieser Folie der Schritt, ab dem sie stehen soll.
///
/// Der Schlüssel `(n, j)` ist auf beiden Seiten ohne Absprache herstellbar.
/// `track` nimmt seine eigene Elementnummer und den Index seines Gangs. Hier
/// steht die Frage andersherum: zu jeder Hintergrund-Fußnote die Menge der
/// `sprite-number` ihrer Sprite-Kopien -- erkannt an ihrer Nummer, denn der
/// Sprite setzt den Fußnotenzähler auf den Stand des Hintergrunds --, davon das
/// Maximum, und das ist die innerste Kette. Der Rang unter den Fußnoten
/// derselben innersten Kette ist `j`.
///
/// Was keinen Eintrag findet, steht ab Schritt eins: eine Fußnote im freien
/// Fluss, und ebenso eine, die kein Gang gesehen hat. Das ist das Verhalten
/// von heute.
///
/// Muss in einem `context` stehen.
#let notiz-selektoren(nr) = {
  // Aus dem eigenen Dokument, wie `folien-notizen` darunter.
  let kopien = query(im-dokument(footnote)).filter(f => {
    let ort = f.location()
    deck-info.at(ort).nr == nr and sprite-number.at(ort) != none
  }).map(f => (zahl: counter(footnote).at(f.location()).first(),
               n: sprite-number.at(f.location())))
  let buch = notiz-schritte.get()
  let rang = (:)
  let raus = ()
  for f in folien-notizen(nr) {
    let zahl = counter(footnote).at(f.location()).first()
    let meine = kopien.filter(k => k.zahl == zahl).map(k => k.n)
    let vorgabe = (at: "1-", delay: 0, after: none)
    if meine.len() == 0 {
      raus.push(vorgabe)
    } else {
      let kette = str(calc.max(..meine))
      let j = rang.at(kette, default: 0)
      rang.insert(kette, j + 1)
      let eigen = buch.at(kette + "/" + str(j), default: vorgabe)
      // In mehr als einer Kette deckeln die äußeren mit (`notiz-kette`).
      raus.push(if meine.dedup().len() < 2 { eigen } else {
        notiz-kette(eigen, meine, sprites.get())
      })
    }
  }
  raus
}

/// Steckt eine Fußnote in einer Überschrift?
///
/// Sie darf dort nicht stehen, und das ist keine Geschmacksfrage. Der Titel
/// einer Folie wird wiederholt: als laufender Kopf über den Folien des
/// Abschnitts, im Verzeichnis, in der Sprecheransicht. Jede Wiederholung setzt
/// die Fußnote *neu* -- gemessen trug eine Folie danach die Anmerkung ihres
/// Abschnittstitels statt der eigenen, und ihre eigene Marke rutschte von 1
/// auf 2. Im Rumpf steht der Titel genau einmal, dort geht es.
///
/// Ein tiefer Gang, weil eine Überschrift `emph`, `strong` oder Mathematik
/// tragen kann; über `fields()`, weil der Inhalt je nach Element an
/// `children`, an `body` oder an `child` hängt. Titel sind kurz, das kostet
/// nichts.
#let fussnote-im-titel(c) = {
  if type(c) != content { return false }
  if c.func() == footnote { return true }
  for (_, v) in c.fields() {
    if type(v) == content and fussnote-im-titel(v) { return true }
    if type(v) == array {
      for e in v { if type(e) == content and fussnote-im-titel(e) { return true } }
    }
  }
  false
}

}

/// What a fit says when something inside it may not be there.
///
/// Named, because the same sentence has to come out of nine functions and out
/// of the pause check, and a reader who meets it twice should not have to
/// wonder whether the two are the same rule.
///
/// Both halves of it were measured. A pause inside a fit is never found: the
/// presentation looks for it by walking the slide body, and a fitted block is
/// a closure it cannot walk into. On a slide carrying two pauses that took the
/// step count from three down to one, and nothing said so. And a measured
/// block has no height to reckon against: the width is the one a wrapping fit
/// hands in, but the height comes back unbounded, and that is the axis on
/// which a tracked element resolves `height: 100%` and `1fr` and reserves the
/// room for its marker. Measured: an `anim` inside a fit was not scaled at
/// all and ran off the bottom of the slide.
///
/// It is deliberately not said that every announced thing would vanish.
/// `speaker-note` and `bridge-job` were measured *inside* a fit and both come
/// through -- a `measure` commits no state, so they are recorded exactly once.
/// They are therefore allowed. Only what settles geometry is refused.
#let fit-meldung(was) = (
  "typstage: " + was + " cannot stand inside fit(). A fitted block has to be "
  + "measured, and two things do not survive that. A pause is found by "
  + "walking the slide body, which cannot reach into a measured block, so its "
  + "steps fall away without a word: measured, three steps became one. And a "
  + "measured block has no height to reckon against, so a reveal there "
  + "settles its own height and the room its marker reserves against nothing: "
  + "measured, an anim inside a fit was not scaled at all and ran off the "
  + "slide. Put the " + was + " outside the fit(), or fit what stands inside "
  + "the reveal instead of fitting around it."
)

/// Refuse a thing that only works because the presentation can walk the slide.
///
/// Placed, not assigned: it is a context and has to reach the document to be
/// evaluated at all.
#let fit-verbot(was) = context {
  assert(im-fit.get() == 0, message: fit-meldung(was))
}

// ── The check that a slide fits into its body ───────────────────────────
//
// mosaic measures every cell on every frame; here the unit is the slide body,
// the one block `slide-body` places the deck's content into. Header band,
// title line, footer and progress are drawn beside it with `place` and are not
// part of it, so the check asks exactly the question a deck can act on: does
// what I wrote fit into the room I was given?
//
// Why it is worth more here than in a package that only makes pages: a slide
// of ours goes into an SVG frame of fixed size and is scaled in the browser.
// What sticks out is cut away or drawn into the neighbourhood, depending on
// the frame, and either way it is first seen at the projector. A page one
// leafs through shows it.

/// How far a body may stick out before it is reported.
///
/// Not a setting but a guard against rounding: a body that fills its room to
/// the last point comes back a fraction over it, and that must not turn into a
/// message. Measured across the 63 slides of the six example decks, the fullest
/// body stops 20.83pt short of its room and the next one 35.13pt, so nothing
/// real comes anywhere near this line.
#let ueberlauf-toleranz = 0.5pt

/// One record, and the only thing this check leaves behind.
///
/// Typst gives a package no warning channel, so a finding is filed as
/// queryable metadata and nothing is printed on its own. `overflow: "error"`
/// reads the records back at the end of the document and stops with all of
/// them at once; a tool reads them with
///
/// ```sh
/// typst eval --target html --features html --in deck.typ \
///   'query(<typstage-overflow>).map(e => e.value)'
/// ```
///
/// The numbers travel as plain numbers in points, not as lengths, so that the
/// query can write them as JSON.
#let ueberlauf-satz(nr, schritt, hoch, raum) = [#metadata((
  slide: nr,
  step: schritt,
  height: calc.round(hoch.pt(), digits: 2),
  room: calc.round(raum.pt(), digits: 2),
  over: calc.round((hoch - raum).pt(), digits: 2),
)) <typstage-overflow>]

/// The step from which an overflow is provably on the screen.
///
/// The layout of a slide does not move as the deck is paged through: every
/// tracked element holds its full room with `hide()` from the first step on,
/// and `alternatives` sets its versions on top of each other in a box as large
/// as the largest. So the body is exactly as tall on step one as on step five,
/// and "does it fit" is a question about the slide. What changes with the step
/// is only what is *drawn*: an `anim` that hangs over the bottom edge is
/// invisible until its step, and only then is there something to see.
///
/// So the step is read off the room the overflow needs, not off a second
/// layout. Everything that only comes in after step k is invisible there and
/// together it is `later` tall. If the body sticks out further than that, then
/// even with all of it taken away something would still be hanging over the
/// edge, and that something is visible on step k. The smallest k for which
/// that holds is the answer, and step one is the answer whenever the slide
/// carries no reveal at all.
///
/// It is a lower bound, not an exact answer, and the message says so with "at
/// the earliest". `later` adds up the heights of the reveals and nothing else,
/// so every gap between them -- block spacing, a `v()`, the space between
/// paragraphs -- counts in the body's height and in no reveal. Measured: a
/// 350pt box, a `v(100pt)` and an `anim(at: 4)` below it are reported from
/// step 1, while the overrun is only on the screen from step 4. Two effects
/// push the other way and do not cancel it: a nested reveal is counted twice,
/// once in its own right and once inside the element around it. Where the
/// thing that overruns is itself a reveal and nothing empty stands above it,
/// the step is exact -- measured, `anim(at: 3)` is reported from step 3.
/// The slide is named correctly either way, and that is the part to act on.
///
/// It cannot be done by measuring the same body once per step, and that was
/// tried first. Introspection inside a `measure` of content that also stands
/// in the document is resolved at the *document's* copy, not where the
/// measurement is written: with a state set to 4 in front of it, a measurement
/// of such a block read 0 and returned the layout of the real one, in HTML and
/// on paper alike. So a check cannot tell the elements of a body that they are
/// being measured for step 3.
#let ueberlauf-schritt(liste, ueber) = {
  let spaeter(k) = liste.filter(sp => sp.step > k)
    .fold(0pt, (summe, sp) => summe + sp.height)
  let stufen = ((1,) + liste.map(sp => sp.step)).dedup().sorted()
  let treffer = stufen.find(k => ueber > spaeter(k))
  // `spaeter` is 0 at the last step, so there is always one. Named all the
  // same, because a `find` that comes back empty must not become a panic in a
  // check that is meant to help.
  if treffer == none { calc.max(1, ..stufen) } else { treffer }
}

/// Measure one slide body against the room it was given.
///
/// Two measurements, and both are needed. The one that decides *whether* there
/// is an overflow is taken inside the real room, because content that lays
/// itself out against the room it gets only settles when it has one: two
/// balanced `columns` measure 338.16pt inside their room and 366.94pt without
/// it, and reporting the second would be inventing an overflow that is not on
/// the slide. The one that says *by how much* is taken without a height,
/// because a measurement with one is capped at it: the same body that
/// saturates the room at 364.61pt is 395.71pt when asked freely, and the
/// difference is exactly what the capped number hides.
///
/// So a body is reported only where the capped measurement fills the room to
/// the last point, and the free one is then read for the amount.
///
/// Only the height. `measure` caps the width it reports at the width it is
/// given as well, and there is no way around that one: a table of 516.14pt
/// measured inside 200pt reports 200pt, so a body that is too wide cannot be
/// told from one that fills its column. `fit` is the answer to that case.
///
/// What still reads low, and is therefore missed: a `height: 100%` inside the
/// body measures 0, a `1fr` collapses, and anything that draws outside its own
/// layout box -- `scale`, `move`, `place` with an offset -- is invisible to a
/// measurement altogether. What still reads high, and is therefore over-
/// reported: trailing spacing, a `v()` at the end of a body, which takes room
/// in the measurement but draws nothing.
#let ueberlauf-pruefen(nr, rumpf, breite, raum, schritte: true, randlos: false) = context {
  // Does it fit at all? Anything that comes back short of the room has
  // settled inside it and is done with.
  if measure(rumpf, width: breite, height: raum).height < raum - ueberlauf-toleranz {
    return
  }
  let hoch = measure(rumpf, width: breite).height
  if hoch - raum <= ueberlauf-toleranz { return }
  // On paper every step stands on the page at once, so there is no step to
  // name and 0 says so.
  let liste = sprites.get()
  if schritte and randlos {
    // Ein `bleed` wird vor dem Rumpf gesetzt, seine Sprites stehen also vorn
    // in der Liste -- und nehmen dem Rumpf keinen Punkt Platz. Mitgezählt
    // verschöben sie den Schritt: gemessen an einem `bleed` mit
    // `anim(at: 2, rect(height: 400pt))` über einem Rumpf, der ab Schritt 1
    // überläuft, hieß es "ab Schritt 2". Gelesen wird die Marke hinter dem
    // `bleed` nur hier, wo ein Überlauf schon feststeht, und das Ergebnis geht
    // in den Bericht und nicht in den Satz.
    let ende = query(std.selector(<typstage-bleed-ende>).before(here()))
    if ende.len() > 0 { liste = liste.slice(sprites.at(ende.last().location()).len()) }
  }
  let schritt = if schritte { ueberlauf-schritt(liste, hoch - raum) } else { 0 }
  ueberlauf-satz(nr, schritt, hoch, raum)
}

/// Read the records back and stop with all of them at once.
///
/// At the end of the deck, not at the first finding: whoever runs the check
/// before a talk wants the list, not one place at a time with a compile run
/// between them.
///
/// Deduplicated, because a `bundle()` writes several outputs from one source
/// and a slide would otherwise be named once per output.
#let ueberlauf-bericht(modus) = if modus != "error" { [] } else { context {
  let roh = query(<typstage-overflow>).map(e => e.value)
  // One line per slide, not one per record. A `bundle()` writes several
  // outputs from one source, so the same slide is measured once per output
  // and `dedup` does not join those records: they differ in `step`, because
  // paged output has none. Without this a bundle reported one overrunning
  // slide as "2 slides run over", and with a step-dependent height as three.
  // The richest record of each slide is kept, so a step survives where one
  // was found.
  let funde = roh.map(f => f.slide).dedup().sorted().map(nr =>
    roh.filter(f => f.slide == nr).sorted(key: f => f.step).last())
  let zeile(f) = ("  slide " + str(f.slide)
    + (if f.step > 0 { ", from step " + str(f.step) + " at the earliest" } else { "" })
    + ": " + str(f.over) + "pt too tall, "
    + str(f.height) + "pt of content in " + str(f.room) + "pt of room")
  assert(funde.len() == 0, message:
    "typstage: " + str(funde.len())
    + (if funde.len() == 1 { " slide runs" } else { " slides run" })
    + " over the room the body has. A slide is a frame of fixed size: in the "
    + "browser what sticks out is cut away or drawn beside the slide, on "
    + "paper it stands over the edge. Neither is seen while writing.\n"
    + funde.map(zeile).join("\n")
    + "\nShorten the slide, split it, or put the block that does not fit into "
    + "fit(). overflow: \"record\" files the same records for querying and "
    + "carries on instead of stopping.")
} }

// ── The check that a scene's frames are all the same size ──────────────
//
// A CeTZ canvas is as large as what it holds. Change the content across the
// stops of a `scene` and every frame comes out a different size, so the
// drawing sits somewhere else inside the box each time and the whole picture
// travels while only one point should move.
//
// The package cannot put that right. It hands `draw` a value and gets a
// finished setting back; `measure` answers with a size and not with where the
// ink lies inside it, so there is no offset to compute and nothing to shift.
// What it can do is notice, and that is worth doing on its own: whoever does
// not measure finds out at the projector.

/// How far two frames may differ before it is reported.
///
/// Not a setting but a guard against arithmetic. The frames of a scene are
/// laid out from values that were interpolated, `a + (b - a) * u`, and the
/// last bit of a float does not always land on the same point. Measured over
/// the eight example decks and the check deck, every scene that is meant to
/// stand still came out to the point: the largest spread among frames of one
/// scene was 0pt. Anything a projector could show is orders of magnitude
/// above this line.
#let drift-toleranz = 0.05pt

/// Whether scenes measure themselves, and what happens with what they find.
///
/// Written once by `presentation`, before the slides are laid out, and read by
/// every `scene`. `"none"` switches the measuring off as well, not only the
/// report: a check nobody wants should not be paid for either.
#let drift-modus = state("typstage-drift", "error")

/// One record, and the only thing this check leaves behind.
///
/// The same arrangement the overflow check uses, and for the same reason:
/// Typst gives a package no warning channel, so a finding is filed as
/// queryable metadata and nothing is printed on its own. A tool reads them
/// with
///
/// ```sh
/// typst eval --target html --features html --in deck.typ \
///   'query(<typstage-drift>).map(e => e.value)'
/// ```
///
/// The numbers travel as plain numbers in points so the query can write them
/// as JSON.
#let drift-satz(nr, schritt, bilder, lagen, breit, hoch) = [#metadata((
  slide: nr,
  step: schritt,
  frames: bilder,
  sizes: lagen,
  width: calc.round(breit.pt(), digits: 2),
  height: calc.round(hoch.pt(), digits: 2),
)) <typstage-drift>]

/// The way out, in the words the manual uses for it.
///
/// Written once and used twice: a scene on `steady: true` stops where it
/// stands and says this, and the report at the end of the deck says it after
/// its list. Two wordings for one remedy would be one wording too many.
#let drift-ausweg = (
  "The way out lies in the drawing: give it a fixed extent and keep what "
  + "moves inside it. In CeTZ that is a rect with a transparent stroke, the "
  + "same air ab() works with: rect((-4.4, -0.8), (4.4, 4.6), "
  + "stroke: rgb(0, 0, 0, 0)). Whatever still reaches beyond it has to be "
  + "clipped, or it pulls the canvas open again. Where the frames are meant "
  + "to differ -- a rectangle that grows, a number that counts up -- "
  + "scene(steady: false) says so and takes that scene out of the check."
)

/// What one finding reads like, in one line.
#let drift-zeile(f) = ("  slide " + str(f.slide) + ", from step " + str(f.step)
  + ": " + str(f.frames) + " frames in " + str(f.sizes) + " different sizes, "
  + "up to " + str(f.width) + "pt apart across and " + str(f.height)
  + "pt down")

/// Read the records back and stop with all of them at once.
///
/// At the end of the deck, not at the first finding, and deduplicated per
/// scene: the same reasoning as `ueberlauf-bericht`, where a `bundle()` writes
/// several outputs from one source and would otherwise name a scene once per
/// output.
#let drift-bericht(modus) = if modus != "error" { [] } else { context {
  let roh = query(<typstage-drift>).map(e => e.value)
  let funde = roh.dedup()
  assert(funde.len() == 0, message:
    "typstage: " + str(funde.len())
    + (if funde.len() == 1 { " scene draws frames" } else { " scenes draw frames" })
    + " of different sizes. A drawing is as large as what it holds, a CeTZ "
    + "canvas above all, so a frame wider than its neighbour puts the drawing "
    + "somewhere else inside the box: paging through it, the whole picture "
    + "travels while only one point should move. The package can see this and "
    + "cannot correct it -- measure answers with a size, never with where the "
    + "ink lies inside it.\n"
    + funde.map(drift-zeile).join("\n")
    + "\n" + drift-ausweg
    + " drift: \"record\" files the same records for querying and carries on "
    + "instead of stopping; drift: \"none\" does not measure at all.")
} }

// ── Eine Fassung hält, bis die nächste kommt ─────────────────────────────────
//
// Ein Element mit `at: auto` und `offen: false` -- jede Fassung einer
// `alternatives` außer der letzten, jede Stufe eines `build`, jeder Halt einer
// `scene`, jedes Stück eines `stagger(dim: true)` -- stand bisher auf genau
// dem Schritt, den der Zeiger ihm gab. Das stimmt, solange der Rumpf selbst
// nichts aufdeckt. Trägt er eine eigene Kette, vergibt die ihre Schritte
// *hinter* diesem einen, und dort ist das Element schon wieder gegangen: die
// Laufzeit deckelt ein inneres Element mit seinem Wirt, `hide` auf Papier tut
// dasselbe. Gemessen an `alternatives([Eins], alternatives([A], [B]),
// [Drei])` unter `pages: "step"`: fünf Seiten, auf der zweiten bis vierten
// nichts, „A" und „B" auf keiner; im Browser `data-at` 2, 3 und `4-`, und auf
// den Schritten 3 und 4 war nichts zu sehen.
//
// Die Spanne reicht darum bis vor den Schritt, den das nächste Stück bekommt.
// Das ist der Zeigerstand am Ende des eigenen Rumpfes: das nächste Stück rückt
// von dort aus um eins weiter. Ohne Kette im Rumpf ist das der eigene Schritt,
// und dann steht die Zahl allein da -- Byte für Byte die Spanne von vorher.

/// Die Marke hinter dem Rumpf, an der `auto-auswahl` den Zeiger abliest.
///
/// Sie trägt den Ort des `context`, der sie setzt, und nichts sonst. Daran
/// findet ein Element seine eigene: eine Fassung mit einer Kette darin hat die
/// Marken ihrer inneren Fassungen *vor* der eigenen, und unter `pages: "step"`
/// steht dieselbe Folie mehrmals da. Ein Ort folgt dem Bau des Dokuments und
/// keiner Lesung.
///
/// Gesucht wird nur *innerhalb* dieses `context` (`within`), nicht hinter ihm
/// (`after`). Die eigene Marke steht darin, zuletzt, hinter denen der inneren
/// Elemente. Hinter ihm stehen dagegen die Marken aller folgenden Folien und
/// Seiten, und jedes Element mit geschlossener Spanne holte sie alle einmal je
/// Lauf ab -- das wächst mit dem Quadrat des Decks. Gemessen an 80 Folien mit
/// je einem vierteiligen `stagger(dim: true)` und einer dreiteiligen
/// `alternatives` unter `pages: "step"`: 7,0 s ohne Marke, 39,4 s mit `after`,
/// 8,5 s mit `within`.
///
/// Ohne Leerzeichen vor dem Label: `[#metadata(1) <x>]` ergibt gemessen
/// `sequence(metadata(value: 1), [ ])`, also ein Leerzeichen im Fluss neben dem
/// Rumpf, das dort nichts zu suchen hat.
#let spannen-marke() = [#metadata(here())<typstage-spannen-ende>]

/// Der Bereich eines Elements mit `at: auto`, als Zeichenkette für `data-at`.
///
/// Offen vom Zeigerstand hier bis zum Folienende, oder geschlossen bis zum
/// Zeigerstand an der eigenen `spannen-marke`. Die Lesung steht im `context`
/// des Elements und nicht im Aufruf -- dieselbe Lehre wie bei einem `at` als
/// Funktion: ein `context`, der einen gelesenen Wert als Argument mitträgt,
/// bekommt in jedem Lauf, in dem die Lesung noch wechselt, eine neue
/// Identität.
///
/// Und sie fließt nicht in den Satz zurück, an dem sie hängt. Der Zeiger rückt
/// bei `at: auto` ohne die Spanne vor, also hängt auch die Schrittzahl der
/// Folie -- und unter `pages: "step"` ihre Seitenzahl -- nicht an ihr. Was sie
/// bestimmt, ist auf Papier `hide` oder nicht, im Browser `data-at`. Im ersten
/// Lauf kennt die Abfrage keine Marke, dann bleibt es bei einem Schritt wie
/// bisher. Gemessen: die Zahl der Layoutläufe blieb auf allen 17 Beispieldecks
/// in allen vier Ausgaben dieselbe (Schrittfassung 5, Seite je Folie 4,
/// Handzettel 3 oder 4, HTML 4 oder 5), ebenso auf einem Deck aus 40 Folien
/// mit doppelt verschachtelten Fassungen, einer Fußnote in einer inneren
/// Fassung und `cue`-Schichten daneben.
///
/// `std.selector`, weil `selector` in dieser Datei die Umformung der
/// Schrittwahl ist. Muss in einem `context` stehen, hinter `zaehlen`.
///
/// `ort` ist der Ort des `context` von `track`, wenn nicht dort gefragt wird:
/// der Anmerkungsblock stellt dieselbe Frage für eine Fußnote im Rumpf (siehe
/// `papier-spanne`).
#let auto-auswahl(offen, ort: none) = {
  let von = if ort == none { step-cursor.get() } else { step-cursor.at(ort) }
  let von = von.first()
  if offen { return str(von) + "-" }
  let hier = if ort == none { here() } else { ort }
  let marke = query(std.selector(<typstage-spannen-ende>).within(hier))
    .rev().find(m => m.value == hier)
  let bis = if marke == none { von } else {
    calc.max(von, step-cursor.at(marke.location()).first())
  }
  if bis > von { str(von) + "-" + str(bis) } else { str(von) }
}

/// Die Spanne eines verfolgten Elements auf Papier, als ganzer Selektor -- mit
/// seinen Lücken, wie `papier-zeigt` ihn braucht.
///
/// Steht einmal da, weil zwei Stellen sie brauchen und dasselbe herausbekommen
/// müssen: `track` für den Rumpf und der Anmerkungsblock unter
/// `pages: "step"` für die Anmerkungen darin (siehe `papier-kette`).
///
/// `ort: none` liest im umgebenden `context`, so wie `track` immer gelesen
/// hat. Mit einem Ort liest sie *dort* -- am `context` von `track` --, und
/// dieselbe Lesung am selben Ort gibt im selben Lauf denselben Wert. Ein `at`
/// als Funktion bekommt den Ort deshalb mitgereicht; die drei Schichten lesen
/// damit `.at(ort)` statt `.get()`.
#let papier-spanne(at, offen, ort: none) = {
  let at = if type(at) == function { at(ort) } else { at }
  if at == auto { auto-auswahl(offen, ort: ort) } else { selector(at) }
}

/// Eine Fußnote im Rumpf eines verfolgten Elements, auf Papier: sie selbst,
/// und davor eine Marke mit den Zutaten der Entscheidung, ob dieses Element
/// auf dem gesetzten Schritt steht.
///
/// Gebraucht vom Anmerkungsblock jeder Papierfassung (`papier-verborgen`).
/// Eine Fußnote in verborgenem Inhalt bleibt ein Fund für `query(footnote)` und
/// zählt weiter -- das muss sie, sonst trüge die nächste Marke eine andere
/// Nummer als im Browser --, aber ihre Anmerkung gehört noch nicht an den Fuß
/// der Seite. Gemessen an `alternatives([Fassung eins#footnote[note-eins]],
/// [Fassung zwei#footnote[note-zwei]])`: auf der Seite von Schritt 1 stand oben
/// nur „Fassung eins", unten aber beide Anmerkungen.
///
/// Warum die *Zutaten* reisen und nicht die Entscheidung. Der erste Entwurf
/// zählte im Papierzweig einen Zustand hoch, solange ein Element verborgen
/// blieb, und der Anmerkungsblock las ihn am Ort der Fußnote. Das ist ein Lauf
/// mehr, als der Rumpf braucht: die Entscheidung fällt aus Lesungen des vorigen
/// Laufs, und wer sie liest, liest sie noch einen Lauf später. Die Entscheidung
/// einer Schicht auf einer neuen Schrittseite steht aber schon heute erst im
/// fünften Lauf fest. Gemessen: `scene` mit `scene-layer` und Fußnote,
/// dahinter eine weitere Folie -- "value of `state("typstage-papier-verdeckt")`
/// did not converge", beobachtet 0, 0, 0, 0, 1 und am Ende 0, und die
/// Anmerkung fehlte auch auf den Seiten, auf denen die Schicht schon stand.
/// Ebenso bei `cue-layer`, sobald die Folie danach Schritte hat.
///
/// Die Marke trägt nur, was ohne jede Lesung feststeht: den Ort der Fußnote,
/// den Ort des `context` in `track` -- ein Ort folgt dem Bau des Dokuments, wie
/// `fnort` im Sprite-Datensatz --, das `at`, wie es übergeben wurde, und drei
/// Wahrheitswerte. `papier-verborgen` rechnet daraus mit `papier-spanne` und
/// `papier-zeigt` dasselbe wie `track`, liest am Ort von `track` und hat damit
/// im selben Lauf dieselbe Antwort wie der Rumpf.
///
/// Eine Marke je Fußnote und nicht zwei Zustandsmarken um den Rumpf. Die lagen
/// in jedem verfolgten Element im Fluss, auch wo keine Fußnote steht, und das
/// blieb nicht folgenlos: gemessen wichen in fünf der siebzehn Beispieldecks,
/// keines mit einer Fußnote, einzelne Seiten ab -- auf der nachgesehenen
/// (`anziehen`, Seite 8) der PDF-Inhaltsstrom gleich, im Bild eine Textzeile
/// mit Punkten, die um eine Stufe von 255 abwichen. Mit der Regel bleibt ein
/// Deck ohne Fußnote, wie es war. Und keine Zustandsmarke um die Fußnote: die
/// Fußnote hat ihren Ort *vor* dem, was eine `show`-Regel aus ihr macht, und
/// eine dort geschobene Marke gilt an diesem Ort noch nicht -- gemessen an
/// einem Dokument aus einer Fußnote: der Zustand an ihrem Ort war die leere
/// Liste. Den Ort nennt die Marke deshalb selbst.
///
/// Eine innere Kette setzt ihre eigene Regel dazu; beide greifen, und vor der
/// Fußnote stehen dann beide Marken.
#let papier-kette(it, satz) = {
  [#metadata((fussnote: it.location(), ..satz)) <typstage-papier-kette>]
  it
}

/// Ist diese Fußnote auf dem Schritt `k` verborgen, weil eines der verfolgten
/// Elemente um sie herum dort verborgen ist? Siehe `papier-kette`.
///
/// `marken` ist `query(<typstage-papier-kette>)`, einmal je Anmerkungsblock
/// gefragt statt einmal je Fußnote. Muss in einem `context` stehen.
///
/// `k: none` ist die Seite je Folie und der Handzettel. Dort ist verborgen,
/// was ersetzt wird -- dieselbe Antwort wie `papier-zeigt` mit `none`, nur ohne
/// vorher die Spanne zu lesen, die diese Antwort nicht braucht.
#let papier-verborgen(f, marken, k) = {
  let meine = marken.filter(m => m.value.fussnote == f.location())
  if k == none { return meine.any(m => m.value.ersetzt) }
  meine.any(m => {
    let r = m.value
    not papier-zeigt(papier-spanne(r.at, r.offen, ort: r.ort),
                     ersetzt: r.ersetzt, bleibt: r.bleibt, k: k)
  })
}

// ── Labels unter `pages: "step"` ────────────────────────────────────────
//
// Unter `pages: "step"` setzt `presentation` denselben Folienrumpf einmal je
// Schritt, und ein Label im Rumpf steht damit so oft im Dokument, wie die
// Folie Schritte hat. Einen Verweis darauf lehnt Typst ab: `#figure(…) <abb>`,
// dahinter `#pause` und `Siehe @abb.` brach mit "label `<abb>` occurs multiple
// times in the document" ab, als Seite je Folie und als Handzettel nicht.
//
// Die Seiten nach der ersten setzen darum eine Abbildung, eine Gleichung und
// eine Überschrift ohne ihr Label -- die drei, auf die ein Verweis zeigen
// kann. Der Verweis findet sie genau einmal, auf der ersten Seite der Folie,
// dort, wo sie aufschlägt, und trägt dieselbe Nummer wie auf jeder
// Schrittseite: das Element ohne Label zählt weiter (siehe `zaehler-klammer`
// in present.typ). Ebenso findet ein `query(<abb>)` des Decks eines je Folie.
//
// Alle drei und nicht nur die, auf die ein Verweis zeigt. Das war der erste
// Entwurf, und er fragte `query(ref)` im `context` von `track`. Ein `ref`
// trägt aber das Element, auf das er zeigt, und das hängt daran, ob das Label
// eindeutig ist -- also an genau dem, was die Abfrage entscheidet, und das
// auf einer neuen Schrittseite erst einen Lauf später. Gemessen an einer
// `figure` in einem `anim` und `@abb` auf der Folie danach: "query for ref
// elements did not stabilize". Ohne Abfrage liest nichts hier etwas, das es
// nicht schon las.
//
// Was es kostet: ein Label ist auch der Griff einer `show`-Regel, und auf den
// späteren Seiten erreicht eine Regel auf das Label einer Abbildung, Gleichung
// oder Überschrift diese nicht mehr. Gemessen an einer Folie mit `#pause`:
// eine Bildunterschrift, rot über `show <rot>: set text(fill: red)`, ist auf
// der ersten Schrittseite rot und auf der zweiten schwarz. Eine Regel auf die
// Art (`show figure`) wirkt weiter, ebenso eine auf jedes andere Label: ein
// Wort, auf dieselbe Weise gefärbt, bleibt auf beiden Seiten rot, und keines
// der siebzehn Beispieldecks ändert sich auf irgendeiner Seite. Die Labels des
// Pakets (`ts-…`, `typstage-…`) hängen an keinem der drei und bleiben ohnehin
// überall.
//
// Warum nicht umbenennen: ein zweites Label auf demselben Element nimmt Typst
// an, meldet aber "content labelled multiple times", und das in jedem Deck,
// das es trifft. Und warum nicht eine `show`-Regel, die das Label abnimmt: das
// Element ist in dem Moment, in dem eine Regel es sieht, schon mit seinem
// Label eingetragen -- gemessen stand `#show <x>: none` vor zwei gelabelten
// Abbildungen, und `query(<x>)` fand weiter beide. Bleibt, das Element neu zu
// bauen, bevor es gesetzt wird.
//
// Das reicht so weit, wie Inhalt vor dem Setzen sichtbar ist: der Rumpf der
// Folie, und in `track` der Rumpf jedes aufdeckenden Elements -- `#pause`,
// `anim`, `alternatives`, `stagger`, `tiles` --, jeweils durch Folgen, `set`-
// und `show`-Regeln und die Blöcke der Typst-Bibliothek hindurch, die unten
// stehen; `side-by-side` gibt seine Spalten als `grid` zurück und wird mit
// erreicht, mit `equal: true` nicht mehr. In einen `context` sieht kein Gang
// hinein, und in einen Listenpunkt, eine Tabelle oder eine Form auch nicht.
// Gemessen bleibt ein Label in `card`, `callout`, `statement`, `fit`,
// `side-by-side(equal: true)`, `anim(card[…])`, `build`, in einem Punkt
// einer Liste (`- $ x $ <gl>`, auch als Punkt einer `cue`-Gruppe) und in den
// drei Schichten mehrfach, und ein Verweis darauf bricht ab wie vorher.
//
// Die Schichten (`scene-layer`, `cue-layer`, `stagger-layer`) nimmt `track`
// ausdrücklich aus. Ihr Schritt kommt aus einer Lesung und steht auf einer
// neuen Schrittseite einen Lauf später fest als bei `anim`, das Label fiele
// also noch einen Lauf später weg -- und die Klammer der Zähler fragt die
// Abbildungen, Gleichungen und Überschriften zwischen ihren Marken ab und
// sähe das Element wechseln. Gemessen an `ziehen` und `vortragen` mit einer
// gelabelten Gleichung in einer `scene-layer` bzw. `cue-layer` unter
// `pages: "step"`, ohne jeden Verweis: vorher keine Meldung, mit dem Abnehmen
// zwei ("did not converge", die Abfrage `equation.after(…).before(…)`), und
// ein Verweis darauf brach trotzdem ab. Das kleinste Deck: eine Folie mit
// `anim(at: 2)`, eine mit `scene` und `scene-layer("s", 2)[$ s $ <g>]`, eine
// mit `anim`.
//
// Gemessen an elf Beispieldecks, die in Überschriften geschrieben sind, mit
// je drei gelabelten Abbildungen in einem `anim` und einem Verweis darauf:
// vorher je drei Fehler, jetzt keiner, und vier Layoutläufe wie ohne sie. Eine
// Folie, deren einzige Kette eine gelabelte Abbildung trägt, braucht allein
// einen Lauf mehr, vier statt drei: `track` liest auf einer neuen Schrittseite
// seinen Schritt erst einen Lauf später an seinem Ort, das Label fällt dort
// also einen Lauf später weg, und wer die Abbildungen zählt, zählt noch einmal.

/// Ein Inhalt, in dem Abbildungen, Gleichungen und Überschriften ohne ihr
/// Label stehen, soweit ein Gang sie erreicht -- oder `none`, wenn er keine
/// erreicht. `none` und nicht derselbe Inhalt zum Vergleich: Typst vergleicht
/// Inhalt ohne sein Label, eine Abbildung mit und ohne `<abb>` sind gleich.
///
/// Neu gebaut wird nur, was einen Verweis tragen kann, und auf dem Weg dorthin
/// nur Behälter, deren Aufruf feststeht. Ein Behälter mit eigenem Label bleibt,
/// wie er ist: sein Label käme beim Neubau nicht mit.
#let ohne-verweislabel-neu(c) = {
  if type(c) != content { return none }
  let f = c.func()
  let art = repr(f)
  // Eine Folge von Kindern, im Aufruf `stack(..)` und `grid(..)`, in der
  // Auszeichnung `sequence`.
  let kinder-neu(kinder) = {
    let neu = kinder.map(ohne-verweislabel-neu)
    if neu.all(n => n == none) { return none }
    neu.zip(kinder).map(((n, k)) => if n == none { k } else { n })
  }
  if art == "sequence" {
    let neu = kinder-neu(c.children)
    return if neu != none { neu.join() }
  }
  if art == "styled" {
    let neu = ohne-verweislabel-neu(c.child)
    return if neu != none { f(neu, c.styles) }
  }
  let felder = c.fields()
  let label = felder.remove("label", default: none)
  if label != none {
    let name = str(label)
    if (f in (figure, math.equation, heading)
        and not name.starts-with("ts-") and not name.starts-with("typstage-")) {
      let rumpf = felder.remove("body")
      return f(rumpf, ..felder)
    }
    return none
  }
  if f in (block, box, pad, hide, grid.cell, align, place, columns) {
    if "body" not in felder { return none }
    let neu = ohne-verweislabel-neu(felder.remove("body"))
    if neu == none { return none }
    // `align` und `place` nehmen ihre Ausrichtung, `columns` seine Zahl nur
    // nach Stellung, und nur, wenn sie dasteht.
    let vorn = ()
    for n in ("alignment", "count") {
      if n in felder { vorn.push(felder.remove(n)) }
    }
    return f(..vorn, neu, ..felder)
  }
  if f in (stack, grid) and "children" in felder {
    let neu = kinder-neu(felder.remove("children"))
    return if neu != none { f(..neu, ..felder) }
  }
  none
}

/// Derselbe Gang, und was er nicht ändert, kommt unverändert zurück.
#let ohne-verweislabel(c) = {
  let neu = ohne-verweislabel-neu(c)
  if neu == none { c } else { neu }
}

/// Der Rumpf eines verfolgten Elements, wie ihn die Seite setzt, die gerade
/// entsteht: auf einer Schrittseite nach der ersten ohne die Labels, auf die
/// ein Verweis zeigen kann. Muss in einem `context` stehen.
#let schrittkopie(body) = {
  let k = papier-schritt.get()
  if k == none or k < 2 or papier-modus.get() != "step" { return body }
  ohne-verweislabel(body)
}

#let track(kind, body, at: "1-", extra: (:), raw-frames: none, inline: false,
           width: auto, dim-freiwillig: false, boden: 2, offen: true,
           vorruecken: 1, ersetzt: false, zaehlt: true) = {
  // Der eine Trichter, durch den jeder Auftritt und jeder Abgang muss --
  // `anim`, `stagger`, `alternatives`, `cue`, `build`, `scene`, `flipbook`,
  // `embed`, `video`, `tiles`. Deshalb steht die Prüfung hier und nicht
  // zehnmal daneben.
  wirkung-pruefen(extra.at("enter", default: none), "enter", kind)
  wirkung-pruefen(extra.at("exit", default: none), "exit", kind)
  // ── Ein `place` gibt seinen Platz nicht her ───────────────────────────────
  //
  // `place` steht außerhalb des Flusses. Gemessen ist es 0x0, und wohin es
  // seinen Inhalt wirklich setzt -- `dx`, `dy`, die Ausrichtung -- steht in
  // keinem Maß, das `measure` zurückgeben könnte. Ein verfolgtes Element *um*
  // ein `place` bekäme deshalb eine Marke am Ort des Flusses und in der Größe
  // der Luft, die ein Element ohne Fläche bekommt: gemessen 40x40 pt statt
  // null. Drei davon liefen im Browser eine Treppe hinunter, je 38 px, und
  // schoben den Text hinter sich mit, während auf Papier alle drei
  // nebeneinander standen.
  //
  // Zu retten ist der Fall, indem das `place` nach *außen* wandert und das
  // verfolgte Element nach innen -- derselbe Handgriff, zu dem die Decks
  // bisher von Hand greifen mussten. Danach steht die Marke dort, wo der
  // Inhalt steht, und der Fluss behält seine Null. Es gilt für jede Art, denn
  // hier kommen alle durch.
  //
  // Ein `float: true` wandert nicht mit. Ein Gleitobjekt sucht sich den Kopf
  // oder den Fuß der Seite, und eine Folie hat weder das eine noch das andere;
  // wohin es geriete, wüsste hier niemand. Lieber eine Meldung als eine Marke
  // an einem geratenen Ort.
  if type(body) == content and body.func() == place {
    assert(not body.at("float", default: false), message:
      "typstage: a tracked element cannot hold a floating place. "
      + "place(float: true) looks for the top or bottom of a page, and a "
      + "slide has neither, so there is no place for the marker to go. "
      + "Drop float: true, or put the place outside the "
      + kind + "().")
    let innen = track(kind, body.body, at: at, extra: extra,
                      raw-frames: raw-frames, inline: inline, width: width,
                      dim-freiwillig: dim-freiwillig, boden: boden, offen: offen,
                      vorruecken: vorruecken, ersetzt: ersetzt, zaehlt: zaehlt)
    let dx = body.at("dx", default: 0pt)
    let dy = body.at("dy", default: 0pt)
    // Eine nicht genannte Ausrichtung ist nicht dasselbe wie `auto`. Ein
    // `place(dx: 60pt, …)` ohne Ausrichtung übersetzt anstandslos; dasselbe
    // `place` mit einem hingeschriebenen `auto` bricht ab, denn `auto` gibt es
    // nur für ein Gleitobjekt. Das Feld wird darum nur weitergereicht, wenn es
    // dasteht.
    let wohin = body.at("alignment", default: none)
    return if wohin == none or wohin == auto {
      place(dx: dx, dy: dy, innen)
    } else {
      place(wohin, dx: dx, dy: dy, innen)
    }
  }
  // The `box` has to sit around the *whole* construction, not inside it:
  // `layout()` is block-level, so an inline element that only chooses a `box`
  // further in would still break the line it sits in.
  let shell-outer = if inline { box } else { it => it }
  shell-outer(context {
  // Nothing tracked may sit inside a fit, and this is where all five kinds
  // come through, so it is asked once here rather than five times outside.
  assert(im-fit.get() == 0, message: fit-meldung(kind))
  // A pure `fr` spacer is passed through instead of tracked. Measured it
  // would come out as the full remaining height and push the siblings out
  // of the slide (verified: 86% instead of 76%). Passed through, the parent
  // distributes it correctly, and there is nothing to animate in empty
  // space anyway, so nothing is lost. The step is not consumed either: it
  // would otherwise stay empty.
  if nur-fr(body) { return body }
  // Mixed content cannot be saved: the spacer belongs to the parent, the
  // rest to the element. Better a clear error than a slide where something
  // silently shifts out of place.
  assert(fr-teile(body).len() == 0, message:
    "typstage: an fr spacer inside a tracked element cannot be resolved. "
    + "fr is shared out by the parent among its siblings, and a tracked "
    + "element is measured on its own. Put the fr outside the anim/stagger, "
    + "or give the element a container with a known size.")
  // `auto` takes the next step. An explicit selector pulls the cursor up to its
  // own highest step, so whatever follows carries on after it instead of
  // starting over.
  //
  // Only reveals count. An applet, a video or a morph does not consume a step
  // (they are there from the start), and above all they must not push the
  // bullets beside them along: in a two-column slide the text next to an
  // applet belongs at step one, not behind the applet's tweens.
  //
  // „Von Anfang an da" gilt aber nur, solange das `at` beim Vorgabewert
  // bleibt. Ein Video, eine Einbettung, ein Daumenkino oder ein Morph mit
  // ausgeschriebenem `at` hinter Schritt eins -- `video(at: 2)`,
  // `embed(at: "2,4-")` -- *erscheint*, und dann zieht es den Zeiger nach wie
  // ein `anim`. Vorher tat es das nicht, und Papier und Browser zählten
  // verschieden: die Laufzeit nimmt die höchste Zahl aus jedem `data-at` der
  // Folie, der Zeiger nur die aus einem `anim`. Gemessen an einem
  // `video(at: "2,4-")` allein auf seiner Folie: im Browser vier Schritte, auf
  // Papier einer. Die Seite je Folie setzte darum Schritt eins, und das Video
  // fehlte auf ihr; unter `pages: "step"` fehlte es ganz. Im HTML hielt die
  // Prüfung am Deckende `anim(at: "2-3", after: "dimmed")` neben einem
  // `video(at: 4)` an, weil die Folie für sie nur drei Schritte hatte. Und
  // ein `anim` hinter einem `video(at: 3)` kam auf Schritt zwei, vor das
  // Video -- anders als hinter einem `anim(at: 3)`, wo das Handbuch es
  // verspricht: „Eine ausgeschriebene Zahl setzt ihn neu".
  //
  // Nur hinter eins. `"1-"` bleibt ohne Update, sonst begänne ein `stagger`
  // neben dem Applet (Boden 1) auf Schritt zwei statt auf eins -- genau das,
  // was der Absatz oben ausschließt. Und nur diese vier Arten: eine `scene`
  // zieht den Zeiger selbst nach, und ihr `at` ist bei `start: auto` aus einer
  // Lesung gerechnet; ein Update daran wäre der Kreis, den sie vermeidet.
  //
  // Einer ginge diesen Kreis: `alternatives(morph: …)` mit `start: auto`
  // reicht im Browser jeder Fassung ihr `at` aus dem gelesenen Zeiger herein,
  // als Morph (mit `track` und `at: auto` wie `stagger(morph:)` konvergierte
  // er in einer Kachel nicht, siehe dort). Er ruft
  // `track` darum mit `zaehlt: false` und rückt den Zeiger je Fassung selbst
  // vor, mit einem Update ohne Gelesenes, so wie Papier die Fassungen als
  // `anim` mit `at: auto` zählt. Vorher reservierte er seine Schritte gar
  // nicht: eine Folie mit `anim`, zwei solchen Aufrufen und einem `anim` hinter
  // jedem hatte im Browser fünf Schritte, die beiden überlappten auf Schritt
  // 4, auf Papier acht. Hing das Nachziehen hier an seinem gelesenen `at`,
  // stimmte die Zahl, aber ein `anim` und dahinter zwei `tiles` mit je einem
  // solchen Aufruf in der zweiten Kachel liefen im Browser nicht mehr
  // zusammen: acht Meldungen, vorher und jetzt keine.
  //
  // The cursor runs in *both* outputs, and that is why the accounting stands
  // above the branch below. Nothing is revealed on paper, but `info().step`
  // has to report the same count there as in the browser, and the count is
  // what the cursor holds at the end of the slide. A counter update draws
  // nothing, so the page is unchanged by it. Verified on the six example
  // decks: every PDF page pixel for pixel as before.
  //
  // Assigned to a name here, but placed further down all the same: a counter
  // only moves where its update stands in the document. Left in the `let` it
  // would join into the value instead of reaching the page.
  //
  // `zaehlt: false` bestellt das Vorrücken ab. Gebraucht von `scene-layer`:
  // eine Schicht sitzt auf einem Halt, den ihre Szene schon vergeben hat, und
  // ihr Schritt ist aus einer Lesung gerechnet. Rückte sie den Zeiger daran
  // vor, schlösse sich der Ring Zeiger -> Szene -> Schicht -> Zeiger.
  //
  // Ein `at`, das eine Funktion ist, wird erst im `context` unten aufgerufen,
  // und dort in *demselben* wie die Lesung von `papier-schritt`. Gebraucht von
  // den drei Schichten (`scene-layer`, `cue-layer`, `stagger-layer`): ihr
  // Schritt kommt aus einer Lesung. Stand er als fertige Zeichenkette im
  // Aufruf, trug ihn der `context` darunter mit, und wo die Lesung von Lauf
  // zu Lauf noch wechselte, bekam der `context` jedes Mal eine neue Identität
  // und las seinerseits erst einen Lauf später an seinem Ort. Gemessen an
  // einer Folie mit einem Schritt vor einer Szene mit Schicht, unter
  // `pages: "step"`: "did not converge", und mit der Funktion nicht mehr.
  // Vorrücken kann so ein Element nicht, der Zeiger kennt die Zahl nicht.
  //
  // Die Funktion nimmt einen Ort oder `none`. Hier ist es immer `none`: gelesen
  // wird im eigenen `context`. Einen Ort reicht nur der Anmerkungsblock unter
  // `pages: "step"` herein, der dieselbe Lesung am Ort dieses `context`
  // nachholt (siehe `papier-kette`).
  assert(type(at) != function or not zaehlt, message:
    "typstage (intern): ein `at` als Funktion braucht `zaehlt: false`.")
  let erscheint = kind in ("video", "audio", "embed", "flipbook", "morph")
  let zaehlen = if zaehlt {
    if at == auto { schritt-vorruecken(boden: boden, um: vorruecken) }
    else if kind == "anim" or (erscheint and max-step(selector(at)) > 1) {
      step-cursor.update(c => calc.max(c, max-step(selector(at))))
    }
  } else { [] }
  // On paper there is no overlay, no marker and no reveal, so the body simply
  // stands where Typst puts it. The counting above still has to reach the
  // document, hence the joined return rather than a bare one.
  //
  // One thing it does not get for free, and the HTML branch has taken care of
  // it further down all along: content that centres itself measures as narrow
  // as its own ink, so an `align(center, …)` inside a `stack` in a grid column
  // has nothing left to centre in and stays at the start edge. In the browser
  // the sprite is handed `room` for exactly that reason; here the same
  // question goes to the same function, and the answer is a block of the full
  // width. Reported from a deck whose three columns each carried a centred
  // verdict under a diagram: centred in the browser, flush left in the PDF,
  // one source. Only an `align` and a block equation reach `will-fuellen`, so
  // nothing else moves; an inline element keeps its own width, or the box
  // would break the line it sits in, and one that was given a width was never
  // asked in the first place. Measured: all seventeen example decks come out
  // of the PDF pixel for pixel as before.
  if not html-output.get() {
    // `nackt`: dieser Block ist der Bereich, den im Browser der Sprite
    // bekommt (`region`, siehe unten), und dort trägt er den Stil des Decks
    // ebenso wenig. Mit ihm stand unter `#set block(inset: 8pt)` ein
    // `anim(align(center, …))` auf Papier 8pt tiefer als im Browser.
    let leib = if not inline and width == auto and will-fuellen(body) {
      block(..nackt, width: 100%, body)
    } else { body }
    // `zaehlen` zuerst, der `context` danach: so liest er den Zeiger, nachdem
    // dieses Element ihn weitergestellt hat. Nachgemessen an einem Deck mit
    // zwei `anim` und einem dreiteiligen `stagger`: 2, 3 und 1, 2, 3.
    return zaehlen + context {
      // Der ganze Selektor und nicht nur Anfang und Ende: eine Lücke in der
      // Spanne ist auf ihrer Schrittseite eine Lücke (siehe `papier-zeigt`).
      let selected = papier-spanne(at, offen)
      let bleibt = extra.at("after", default: none) == "dimmed"
      // Die Zutaten dieser Entscheidung an jede Fußnote im Rumpf, sichtbar
      // oder nicht: die Frage stellt der Anmerkungsblock, und er stellt sie
      // selbst (siehe `papier-kette`).
      //
      // Ohne Bedingung auf die Fassung, die dafür erst `papier-modus` lesen
      // müsste. Die Marke zeichnet nichts und schiebt nichts: gemessen an
      // `tour` mit elf eingestreuten Fußnoten stehen die Seite je Folie und
      // der Handzettel Bild für Bild wie vorher da.
      let satz = (ort: here(), at: at, offen: offen, ersetzt: ersetzt,
                  bleibt: bleibt)
      show footnote: it => papier-kette(it, satz)
      // `hide` statt Weglassen: der Platz bleibt stehen, und die Seiten einer
      // Folie liegen übereinander, statt bei jedem Schritt neu umzubrechen.
      // Auf einer Schrittseite nach der ersten ohne die Labels, auf die ein
      // Verweis zeigen kann (siehe `ohne-verweislabel`). Nicht in den drei
      // Schichten, deren `at` eine Funktion ist: dort kostete es gemessen die
      // Konvergenz gültiger Decks (siehe dort).
      let leib = if type(at) == function { leib } else { schrittkopie(leib) }
      if papier-zeigt(selected, ersetzt: ersetzt, bleibt: bleibt) {
        leib
      } else { hide(leib) }
      // Hinter dem Rumpf, damit der Zeiger dort die Kette darin schon gezählt
      // hat, und außerhalb von `hide`: die Marke gehört dem Element, nicht
      // seinem Inhalt.
      if at == auto and not offen { spannen-marke() }
    }
  }
  zaehlen
  element-counter.step()
  context {
    let n = element-counter.get().first()
    // `offen: false` gibt eine geschlossene Spanne statt einer offenen -- was
    // `alternatives` für alle Fassungen außer der letzten braucht: eine
    // Fassung tritt ab, wenn die nächste kommt, sie bleibt nicht liegen. Wie
    // weit sie reicht, sagt `auto-auswahl`.
    let at = if type(at) == function { at(none) } else { at }
    // Dasselbe für einen Wert in `extra`: eine Funktion wird erst hier
    // aufgerufen, in diesem `context`, und reist nicht als fertige Zahl im
    // Aufruf mit. Gebraucht von `cue` für `ad-nr`, die Nummer eines Punktes,
    // die am Stand der Gruppe hängt -- und dieser Stand ist im Sprite eines
    // Wirts ein anderer als im Hintergrund (siehe dort).
    //
    // Nur hier und nicht im Papierzweig oben: der liest aus `extra` nur
    // `after`, und das ist nie eine Funktion.
    let extra = extra.pairs().map(((k, v)) =>
      (k, if type(v) == function { v(none) } else { v })).to-dict()
    let selected = if at == auto { auto-auswahl(offen) } else { selector(at) }
    // The step this element first stands on, and what `info().step.number`
    // reads inside its body. It travels into the sprite as well, because the
    // body is laid out a second time there, long after the cursor has run on
    // to the end of the slide.
    let erster = min-step(selected)
    // Und derselbe Schritt für die Anmerkungen, die in diesem Rumpf hängen.
    //
    // Das einzige, was dieser Entwurf `track` abverlangt: zwei ganze Zahlen und
    // eine Zeichenkette, die es schon in der Hand hält. `n` kommt aus dem
    // Elementzähler, `j` aus dem Gang über das eigene Argument, `selected` ist
    // dasselbe `at`, das nebenan ohnehin in den Datensatz geht. Keine Abfrage,
    // kein `.at()`, kein `get()` einer Folienlesung -- und darum wächst der
    // Introspektionsgraph der Folie hier um keine Kante.
    //
    // Nicht der Ort der Anmerkung reist hierher, sondern der Schritt reist zu
    // der Stelle, an der die Anmerkung ohnehin schon steht: an den Fuß der
    // Folie, wo `slide-body` ihr einen Schlitz stanzt. Eine Marke *hier* wäre
    // falsch -- ein `place(bottom + left, …)` löst gegen den nächsten Block
    // auf, und der ist in einem Listenpunkt der Punkt und nicht der Folienrumpf.
    //
    // `after` reist mit, sonst nur der Schritt. Ein `stagger(dim: true)` trägt
    // einen geschlossenen Bereich und bleibt danach gedämpft stehen -- seine
    // Marke also auch, und eine Anmerkung, die dort verschwände, liesse einen
    // Verweis ohne Anmerkung zurück. Gemessen an `dim: true`: Marke bei 0.65,
    // Anmerkung bei 0.
    let notiz-satz = (at: selected, delay: extra.at("delay", default: 0),
                      after: extra.at("after", default: none))
    for j in range(notiz-zahl(body)) {
      let schluessel = str(n) + "/" + str(j)
      notiz-schritte.update(d =>
        if d.at(schluessel, default: none) == notiz-satz { d }
        else { d + ((schluessel): notiz-satz) })
    }
    // Pushed *before* the layout, not inside the hidden block further down,
    // and that is not cosmetic: the body is measured before it is laid out,
    // and a measurement reads the state as it stands at that point in the
    // document. Verified: content whose length depends on a state measures
    // 20.23pt before the update and 112.26pt after it. Pushed any later, and
    // the marker would reserve the room for a step number the body no longer
    // prints.
    step-here.update(a => a + (erster,))
    // Alles ab hier `nackt`, und nur der Rumpf bekommt die Regel des Decks
    // zurück. `layout` ist in Typst 0.15 selbst ein Block und nimmt wie ein
    // `rect` Einzug, Fläche und Rand einer `set block`-Regel an; darin stehen
    // die Hülle, die Marke -- ein `rect` -- und der verborgene Rumpf, und
    // nichts davon gibt es auf Papier. Ohne diese Zeile stand unter `#set
    // block(inset: 8pt)` vor `presentation` alles darin 8pt versetzt, die
    // Marke kam 16pt schmaler und niedriger heraus, und die Laufzeit skalierte
    // den Sprite hinein: bei 1600 px Bühnenbreite ein Wort hinter `#pause` auf
    // weniger als die Hälfte verkleinert und 410 px neben seinem Ort. Eine
    // `#set block(fill: …)` legte eine Fläche hinter jedes verfolgte Element.
    //
    // Der Rumpf dagegen braucht die Regel: der Sprite setzt ihn später mit
    // ihr, und die Marke muss so viel Platz halten, wie er dort einnimmt. Ohne
    // sie stand ein zweiter Lauf hinter `#pause` im Browser 16pt höher als auf
    // Papier, weil der erste um seinen Einzug zu niedrig gemessen war. Gelesen
    // hier, vor dem Zurücksetzen.
    let deck-block = (inset: block.inset, outset: block.outset, fill: block.fill,
                      stroke: block.stroke, radius: block.radius, clip: block.clip,
                      width: block.width, height: block.height)
    set block(..nackt)
    layout(available => context {
      let leib = { set block(..deck-block); body }
      // Measured under the same width the element has in the background. That
      // measurement travels outward so the sprite gets exactly the same
      // layout. Otherwise a `width: 100%` inside the free frame would come to
      // nothing and boxes would lose their area.
      let room = if width == auto { available.width } else { width }
      // Measured twice, and the larger one counts. Both measurements are
      // needed, but for different reasons:
      //
      // *With* a height reference is the only thing that resolves
      // `height: 100%` and `1fr` inside the body at all. Without it there is
      // nothing for a percentage to count against, and the element collapses
      // to 0pt. Measured: in 12 of 34 tracked elements of a test deck.
      //
      // *Without* a height reference determines the **position**, not the
      // size. Overflow is drawn outside the SVG box anyway, so the
      // dimensions stay the same; but with the capped height, something
      // like `side-by-side` (defaulting to `horizon`) aligns the element on
      // the wrong middle. Measured: up to 84 percentage points of offset,
      // `lorem(200)` slid entirely off the slide.
      //
      // If the height is unbounded, the second measurement returns 0 and
      // the maximum falls back to the first.
      let natural = measure(leib, width: room)
      let bounded = measure(leib, width: room, height: available.height)
      let m = (
        width: calc.max(natural.width, bounded.width),
        height: calc.max(natural.height, bounded.height),
      )
      // What holds here has to be set again in the sprite: its own frame does
      // not know the slide's `set` rules.
      // The sprite is set in its own frame and does not know the slide's
      // `set` rules. What determines the line break and the height
      // therefore has to travel along, or it will not fill its measured
      // frame: with `#set par(leading: 2em)` the background measured 63pt,
      // the sprite came out at 37pt with default leading and stuck to the
      // top.
      //
      // The direction too. It decides where `start` lies, and a Persian
      // list came back into its frame reading from the left while the
      // slide underneath read from the right. `auto` is what an unset deck
      // reads here, and `auto` set again is no change at all.
      let style = (
        size: text.size, fill: text.fill, font: text.font,
        weight: text.weight, style: text.style, lang: text.lang,
        dir: text.dir,
        tracking: text.tracking, spacing: text.spacing,
        leading: par.leading, par-spacing: par.spacing,
        justify: par.justify, first-line-indent: par.first-line-indent,
        hanging-indent: par.hanging-indent,
        // Und ob gezählt wird. Eine Gleichung und eine Überschrift zählen nur
        // nummeriert, und ein `#set math.equation(numbering: …)` im Rumpf des
        // Decks erreicht den Sprite nicht: der Inhalt eines `alternatives`,
        // `stagger`, `build`, `cue` oder `anim` steht dort außerhalb der
        // Regel. Gemessen an sechs Folien mit je einer Gleichung darin: im
        // Browser trug keine eine Nummer, auf Papier jede. Und die
        // Klammer um jeden Sprite (`sprite-klammer` in render.typ) nimmt
        // zurück, was der Hintergrund gezählt hat -- ohne diese drei Werte ging
        // sie dort je Sprite um eins zu weit, und die Gleichung der Folie
        // danach stand bei (1) statt (10).
        numbering: (figure: figure.numbering, equation: math.equation.numbering,
                    heading: heading.numbering),
        // Und die Blockregel, wie sie am Ort des Elements galt: `deck-block`,
        // gelesen vor dem `nackt`. Die Marke misst den Rumpf mit ihr (`leib`),
        // und der Sprite muss ihn ebenso setzen. Eine Regel vor `#show:
        // presentation` erreicht ihn ohnehin, eine dahinter oder in der Folie
        // nicht: unter `#set block(inset: 8pt)` hinter der Show-Regel war der
        // Rahmen eines eigenen Blocks in `anim` im Browser 30 px zu klein und
        // sein Text 16 px nach links oben verschoben, in `alternatives` 150 px.
        block: deck-block,
      )
      // Only what *wants* to fill gets the full space. Everything else
      // stays as wide as its content, or a tracked element in an `auto`
      // grid column pulls the whole width to itself and pushes the `1fr`
      // neighbour column to zero.
      let fuellt = will-fuellen(body)
      let w = if inline or width != auto { m.width }
              else if fuellt { room }
              else { m.width }
      // An element without an area (a line measures 0pt tall, its stroke
      // sits outside the box) gets a marker without an area, and the
      // runtime skips that (`if (!r.width && !r.height) return;`). The
      // sprite would never be positioned and would stay invisible. Marker
      // and sprite therefore get breathing room on every side. It sits in
      // `place`, so it changes nothing about the flow: the line stays as
      // tall as it would without `anim`.
      //
      // The measure is estimated, not measured: the stroke width of a line
      // cannot be measured in Typst. A font's height covers any common
      // stroke width; anything thicker is a drawing and normally brings its
      // own box along.
      let luft = if ohne-mass(m.height) or ohne-mass(m.width) { text.size }
                 else { 0pt }
      // The *original* region travels along. Without it, the body sits in
      // the sprite inside a wrapper of the measured size, and a relative
      // measure resolves there a second time: `p%` becomes `p²%`. Only
      // `100%` is a fixed point, which is why this went unnoticed for a
      // long time; `height: 50%` came out as 25%, `morph` with
      // `width: 60%` as 36%.
      // The height is always the real region, so `height: 50%` resolves
      // against the correct reference. For the width it depends on whether
      // the body centers itself:
      //
      // - If it does, frame and region must be the same width. Otherwise it
      //   centers itself in the wider region and is drawn next to its
      //   marker: measured at 293pt off, exactly half the difference.
      // - If it does not, it stands to the left and so sits inside the
      //   frame; then the region may have the full width, and `width: 50%`
      //   resolves correctly instead of coming out as 25%.
      let region = (
        width: if fuellt { w } else { room },
        height: if available.height == float("inf") { auto } else { available.height },
      )
      // `dim-freiwillig` rides in the sprite record and not in `extra`, which
      // becomes `data-` attributes one for one. It is only read by the check
      // at the end of the document and has no business in the markup.
      // Der *Ort*, an dem dieser Rumpf im Hintergrund beginnt -- nicht der
      // Stand eines Zählers dort. Der Sprite setzt den Fußnotenzähler damit
      // auf denselben Wert wie der Hintergrund, und seine Marken tragen
      // dieselben Nummern.
      //
      // Ein Ort und keine Zahl, und das ist der ganze Unterschied zu einem
      // früheren Versuch, der den Zählerstand selbst in den Datensatz legte:
      // dann liest der Zustand einen Zähler, den die Überlagerung anschließend
      // aus demselben Zustand wieder setzt -- ein Kreis, der je Verschachtelung
      // ein Glied gewinnt, und Typst gibt nach fünf Anläufen auf. Gemessen:
      // "value of counter(footnote) did not converge". Ein Ort folgt dem Bau
      // des Dokuments und keinem Zählerstand; er steht vom ersten Lauf an fest.
      // Dasselbe gilt für `n` in `sprite-number.update(n)` nebenan: eine reine
      // Strukturgröße.
      let fnort = here()
      sprites.update(a => a + ((kind: kind, at: selected, extra: extra, body: body,
                                raw-frames: raw-frames, width: w,
                                height: m.height, region: region, pad: luft,
                                step: erster, style: style, fnort: fnort,
                                dim-freiwillig: dim-freiwillig),))
      // A `box` is inline and puts its baseline on the bottom edge, and with a
      // two-line list item the bullet would drop a line. Block content gets a
      // `block`.
      //
      // Die Hülle `nackt` und die Marke ohne `outset`: beide gibt es nur im
      // Browser, und die `box` eines Elements im Lauf nähme eine `set
      // box`-Regel des Decks an, die Marke als `rect` ein `set rect(outset:
      // …)`. Gemessen bei 1600 px Bühnenbreite: unter `#set box(inset: 8pt)`
      // stand ein `morph` im Lauf im Browser 16 px weiter rechts und tiefer
      // als auf Papier, unter `#set rect(outset: 8pt)` ein Lauf hinter
      // `#pause` 15 px weiter links, weil die Laufzeit den Sprite in die um
      // den `outset` größere Marke setzte.
      let shell = if inline { box } else { block }
      shell(..nackt, width: w, height: m.height, {
        place(top + left, dx: -luft, dy: -luft,
              rect(width: w + 2 * luft, height: m.height + 2 * luft,
                   fill: marker(n), stroke: none, outset: 0pt))
        // `hide` lays out but does not draw: the space is right, the content
        // is only visible in the overlay.
        // Same region as during measuring: otherwise a relative measure
        // here resolves against the wrapper instead of the real container,
        // and the marker reserves a different height than the sprite fills
        // later.
        place(top + left, hide(block(
          width: region.width,
          height: if available.height == float("inf") { auto } else { available.height },
          leib)))
      })
      // Und wo dieser Rumpf im Hintergrund endet, als Marke mit dem Ort seines
      // Beginns als Wert. Der Sprite zählt denselben Rumpf ein zweites Mal;
      // `sprite-klammer` in render.typ stellt davor auf den Stand am Beginn
      // zurück und dahinter um das vor, was der Hintergrund nach dieser Marke
      // noch zählt.
      [#metadata(fnort) <typstage-rumpf-ende>]
    })
    // The element is done, so whatever stood around it stands again. Popped,
    // never assigned back from a remembered value: see `step-here`.
    step-here.update(a => if a.len() > 0 { a.slice(0, -1) } else { a })
    // Hinter dem gesetzten Rumpf, aus demselben Grund wie im Papierzweig.
    if at == auto and not offen { spannen-marke() }
  }
  })
}
