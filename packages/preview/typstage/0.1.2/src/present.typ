// Building the deck: the same source into two targets.

#import "config.typ": *
#import "internal.typ": *
#import "slides.typ": *
#import "theme.typ": (fortschritt-stil, handout-body, slide-body,
                     slide-chrome)
#import "themes.typ": mit-palette, theme-state, themes
#import "palettes.typ": palette-pruefen
#import "render.typ": *
#import "elements.typ": anim, pause
#import "richtung.typ": von-rechts

/// Flatten a body into content pieces and pause markers.
///
/// `#set` in markup wraps everything after it, so a pause following one sits
/// *inside* that wrapper. Without descending into it not a single pause would
/// be found, and it would fail silently, which is the worst way to fail.
///
/// The style is carried along and put back around each piece: as a style rule
/// that changes nothing about the layout, unlike wrapping in `anim`, which
/// would tear a list apart.
#let pause-tokens(body, restyle) = {
  let parts = if body.has("children") { body.children } else { (body,) }
  let out = ()
  for c in parts {
    let kind = repr(c.func())
    if c.func() == metadata and c.value == "typstage-pause" {
      out.push("pause")
    } else if kind == "styled" and c.has("child") {
      let maker = c.func()
      let inner = c.styles
      out += pause-tokens(c.child, x => restyle(maker(x, inner)))
    } else if kind == "sequence" and c.has("children") {
      out += pause-tokens(c, restyle)
    } else {
      out.push(restyle(c))
    }
  }
  out
}

/// Turn the pauses in a slide body into steps.
///
/// The first run stands from the start and stays untracked; every further run
/// becomes an `anim` on its own step. Written out as a number, not `auto`, so
/// a `stagger` further down carries on after the last pause.
///
/// Every run becomes a block. A pause begins a new one, like a blank line.
/// That is not cosmetic: in the browser a tracked element is a block anyway,
/// while on paper it would flow on in the same paragraph. The same source has
/// to set the same way in both, so both are told to.
#let apply-pauses(body) = {
  if body == none { return body }
  let tokens = pause-tokens(body, x => x)
  // Nothing to do, and then the body is handed back untouched rather than
  // reassembled from its pieces.
  if not tokens.contains("pause") { return body }
  let runs = ()
  let current = ()
  for t in tokens {
    if t == "pause" { runs.push(current.join()); current = () }
    else { current.push(t) }
  }
  runs.push(current.join())
  // The first run stands unwrapped, every further run gets a wrapper.
  //
  // The wrapper is needed for the tracked runs: `anim` measures its content,
  // and a paragraph without a width shrinks to its ink. An `align(center, …)`
  // inside it would then have no room to center in and would stay flush
  // left, even though without the pause it sits centered. `width: 100%`
  // gives it the room back.
  //
  // The first run does not need this, since it sits unwrapped in the slide
  // body, which is as wide as the slide anyway. And it must not have it: a
  // `v(1fr)` inside it would then resolve against the *automatic* height of
  // this wrapper instead of against the slide, eat the whole body and push
  // everything after the first pause out of the slide. Silently: measured on
  // a sample with four slides, the PDF was missing every paragraph after the
  // first pause as soon as a `v(1fr)` appeared anywhere.
  //
  // Verified that the wrapper carries no weight here: all six example decks
  // give the same page count and the same text before and after, and a
  // sample with `align(center)` before a pause still centers unchanged.
  let out = runs.first()
  for (i, run) in runs.slice(1).enumerate() {
    out += anim(block(width: 100%, run), at: auto)
  }
  out
}

/// Whether a run of content between two headings holds nothing a reader would
/// miss.
///
/// Not the same question as "is the run empty". Between two headings the
/// markup always leaves a `space` and a `parbreak` behind, so every deck has
/// such runs and counting elements would call them all content. Counting
/// characters would not do either: an image loses as much as a sentence while
/// carrying no text at all.
///
/// Asked on the pieces as they were written, before `wrap` puts a `styled`
/// back around them. After that every run is one `styled` element, and a
/// `#set` anywhere in the deck would make even the empty ones look like
/// content.
#let stiller-lauf(teile) = teile.all(c => {
  let f = repr(c.func())
  (f in ("space", "parbreak", "linebreak")
   or (c.func() == text and c.text.trim() == ""))
})

/// Die Ebene einer Überschrift im Rumpf, so wie sie dasteht.
///
/// `==` schreibt `depth: 2` ins Element, ein Funktionsaufruf dagegen nur, was
/// er ausdrücklich nennt. `#heading(level: 3)[…]` trägt `level` und keine
/// `depth`, `#heading[…]` keins von beiden, und ein bloßes `c.depth` brach an
/// beiden das Übersetzen ab: gemessen mit "field \"depth\" in heading is not
/// known at this point" und einem Zeigefinger in diese Datei, in allen vier
/// Ausgaben und unter `bundle`, mit und ohne `set heading(numbering: …)`. Die
/// Vorgabe, die Typst dort einsetzt, steht erst beim Setzen fest, und hier
/// wird noch nicht gesetzt.
///
/// Gelesen wird darum, was Typst selbst liest: ein ausdrückliches `level`
/// zuerst, sonst `depth`, sonst die Vorgabe 1. `#heading(level: 3)[…]` zählt
/// damit wie `===`, `#heading[…]` wie `=`. Ein Deck in Auszeichnung ändert das
/// nicht, denn `==` setzt nie ein `level`. Ein `offset` bleibt außen vor, wie
/// er es für `==` schon immer bleibt.
#let ueberschrift-tiefe(c) = {
  let ebene = c.at("level", default: auto)
  if type(ebene) == int { ebene } else { c.at("depth", default: 1) }
}

/// Split a document body at its headings into slides.
///
/// Two things make this harder than walking `body.children`.
///
/// *Rules wrap the rest of the document.* A `#set` or `#show` written after
/// the presentation's own show rule puts everything following it into a
/// `styled` element. The headings then sit one level deeper and the slides
/// vanish without a word. So `styled` is unpacked here and put back around
/// each *run* of content between two headings. Around each run, not around
/// each node: consecutive list items have to stay siblings inside the same
/// `styled`, or a three-point list falls apart into three one-point lists.
///
/// *Generated headings sit in a sequence.* Headings produced by a `#for` end
/// up in a nested `sequence`, which is unpacked the same way.
///
/// The one thing that cannot be carried across: a heading *inside* a `styled`
/// loses those styles, because it leaves the run. A `#set heading` after the
/// show rule therefore does not reach slide titles.
#let split-body(body, wrap) = {
  // Nur eine echte Sequenz wird zerlegt. `table`, `grid`, `list`, `enum` und
  // `stack` führen ebenfalls ein `children`-Feld, und wer die aufbricht,
  // verteilt eine Tabelle in ihre nackten Zellen: Striche fort, sieben Zeilen
  // zu einem Fließabsatz verklebt. Erwischt hat es nur den Weg durch
  // `styled` -- `text(fill: …, table(…))` reicht die Tabelle selbst als
  // `child` herunter, während ein Inhaltsblock eine Sequenz dazwischenlegt
  // und ein `box` gar nicht erst zerlegt wird. Die Schleife unten kennt die
  // Regel seit jeher; diese Zeile hatte sie vergessen.
  //
  // Eine Überschrift kann ohnehin nur im Fluss stehen, also in einer Sequenz.
  // Es gibt darum keinen Rumpf, der hier zerlegt werden müsste und keine ist.
  let parts = if repr(body.func()) == "sequence" and body.has("children") {
    body.children
  } else { (body,) }
  let out = ()
  let run = ()
  for c in parts {
    let f = repr(c.func())
    let boundary = c.func() == heading or (f == "styled" and c.has("child")) or (
      f == "sequence" and c.has("children"))
    // A run of ordinary content ends at every boundary and is wrapped as one
    // piece. Typst closures cannot write to variables outside themselves, so
    // this is spelled out rather than put in a `flush()`.
    if boundary and run.len() > 0 {
      out.push((kind: "content", body: wrap(run.join()), still: stiller-lauf(run)))
      run = ()
    }
    if c.func() == heading {
      out.push((kind: "heading", depth: ueberschrift-tiefe(c), body: c.body))
    } else if f == "styled" and c.has("child") {
      let maker = c.func()
      let inner = c.styles
      out += split-body(c.child, x => wrap(maker(x, inner)))
    } else if f == "sequence" and c.has("children") {
      out += split-body(c, wrap)
    } else {
      run.push(c)
    }
  }
  if run.len() > 0 {
    out.push((kind: "content", body: wrap(run.join()), still: stiller-lauf(run)))
  }
  out
}

/// Turn the tokens of a body into the deck's list of slides.
///
/// `slide-level` is the one rule: a heading *above* it opens a section slide,
/// a heading at it or below it opens a slide. At the default of 2 that is
/// character for character the old rule, `=` becomes a section and everything
/// else a slide.
///
/// Deliberately not Touying's rule, where only `depth == slide-level` makes a
/// slide and anything deeper stays content inside it. That reading would pull
/// every `===` of an existing deck into the body of the `==` above it, and
/// the deck would lose slides without saying so.
#let slides-from-body(body, title, subtitle, author, date, slide-level) = {
  let out = ()
  if title != none {
    out.push(title-slide(title: title, subtitle: subtitle,
                         author: author, date: date))
  }
  let open = none
  let davor = none
  let marken = split-body(body, x => x)
  // Whether this body is a deck in the heading notation at all. A body
  // without a single heading is not one, and the content in it has not been
  // lost behind a heading, it never had a slide to go to. That happens for
  // real: a deck whose own show rule sits above this one hands its whole
  // output down here, and refusing it would refuse a construction that loses
  // nothing.
  let mit-ueberschrift = marken.any(t => t.kind == "heading")
  for tok in marken {
    if tok.kind == "heading" {
      if open != none { out.push(open); open = none }
      if tok.depth < slide-level {
        out.push(section(tok.body, depth: tok.depth))
        davor = tok.body
      } else {
        open = (kind: "slide", title: tok.body, note: none,
                transition: none, body: [])
      }
    } else if open != none {
      open.body = open.body + tok.body
      // Zwei Bedingungen, und die zweite fängt den häufigsten Fall überhaupt:
      // ein Rumpf ganz ohne Überschrift, in dem jemand einfach losgeschrieben
      // hat. `mit-ueberschrift` allein ließ den durch -- gemessen verschwand
      // dort ein ganzer Absatz spurlos, während die Titelfolie stehenblieb,
      // also genau der Verlust, gegen den diese Prüfung gebaut ist.
      //
      // Warum die Einschränkung trotzdem nötig ist: das Handbuch stapelt an
      // vier Stellen mehrere `#show: presentation.with(…)`, um Alternativen zu
      // zeigen. Der äußere bekommt dann die Ausgabe des inneren als Rumpf, und
      // die ist ein `context()` ohne einen einzigen Buchstaben. Text ist also
      // das Merkmal, das den Schreibfehler von der gestapelten Vorführung
      // trennt -- gemessen an beiden.
    } else if not tok.still and (mit-ueberschrift
                                 or plain-text(tok.body).trim() != "") {
      // Content that belongs to no slide, and said out loud rather than
      // dropped. It used to fall out of the deck without a word: the deck
      // compiled, the slide count was right, and the paragraph was simply
      // gone. With more than one structure level there are more headings it
      // can fall behind, so the silence would get cheaper to run into.
      // `let` statt eines `if` mitten im Ausdruck: in einem Codeblock ist eine
      // Zeile, die mit `+` beginnt, ein unäres Plus und keine Verkettung.
      // Genau daran ist diese Meldung nie erschienen -- das Übersetzen brach
      // ab, aber mit "cannot apply unary '+' to string" und einem Zeigefinger
      // in den Paketcode.
      let wo = if davor == none {
        "content before the first heading of the deck belongs to no slide. In the heading notation a slide begins with its heading, and here none has begun yet."
      } else {
        "content between the heading \"" + plain-text(davor) + "\" and the next one belongs to no slide. A section slide is a whole picture the theme draws and has no body to hold it."
      }
      panic("typstage: " + wo
        + " Put the content under a slide heading, which at this deck's "
        + "slide-level means a heading of depth " + str(slide-level)
        + " or deeper, or take it out.")
    }
  }
  if open != none { out.push(open) }
  out
}

// ── Zähler unter `pages: "step"` ────────────────────────────────────────
//
// Unter `pages: "step"` setzt `presentation` denselben Folienrumpf einmal je
// Schritt, und jede dieser Seiten schaltete die Zähler darin von neuem weiter:
// Abbildungen jeder Art, Gleichungen, Überschriften und die eigenen `counter`
// eines Decks. Gemessen an einer dreiteiligen `alternatives` aus drei
// Abbildungen, hinter einer Folie mit zwei Abbildungen und `#pause`: auf ihren
// drei Schrittseiten hießen sie „Figure 3“, „Figure 7“ und „Figure 11“, auf
// der Seite je Folie steht die letzte als „Figure 4“. Und jede Folie danach
// erbte den Vorsprung. In `tour` mit einer Abbildung, einer Gleichung und
// einem eigenen Zähler auf jeder Folie trugen unter `pages: "step"` 276 von
// 279 Nummern einen anderen Stand als auf der Seite je Folie.
//
// Die Abhilfe klammert den Rumpf jeder Schrittseite nach der ersten. Davor
// geht jeder Zähler, den die erste Seite bewegt, um genau das zurück, was die
// erste Seite ihm zugelegt hat; so beginnt der Rumpf, wo er auf der ersten
// Seite beginnt, und endet, wo er dort endet.
//
// Um den Abstand und nicht auf den Stand, und das ist gemessen: eine Fassung,
// die den Stand an der Marke las und hinschrieb (`c.update(c.at(von))`), gab
// jeden gelesenen Stand an alle späteren Folien weiter, und zwar einen
// Layoutlauf später. Im einzelnen Deck fiel das nicht auf, weil die Stände
// schon im ersten Lauf stimmen. In `bundle(pages: "step")` aber zählt das
// HTML-Dokument davor dieselben Gleichungen, und seine Zahl setzt sich erst
// über mehrere Läufe: zwei Folien mit je einer nummerierten Gleichung vor und
// hinter einem `#pause` meldeten „did not converge“, und bei zwölf Folien lief
// die Nummerierung von (39) zurück auf (27). Ein Abstand hängt nur an der
// eigenen Folie, und `update` mit einer Funktion liest nichts; dieselben Decks
// setzen sich ohne Meldung.
//
// Nach dem Rumpf kommt eines nach: das Lesezeichen der Folie, eine verborgene
// Überschrift, steht nur auf der ersten Seite (`erste-seite` in theme.typ),
// und ist sie nummeriert -- ein `set heading(numbering: …)` vor der Vorlage
// erreicht sie --, steckt ihr Schritt im Abstand. Die weiteren Seiten holen
// ihn nach. Ohne das stand die erste Überschrift der Folie danach in der
// Probe von pruefe-schrittseiten.py auf 2.0.2 statt 2.2.1.
//
// Der Fußnotenzähler und der Folienzähler gehen ihren eigenen, älteren Weg
// (unten in `presentation`), die übrigen Zähler des Pakets setzt die Seite
// selbst zurück, und der Seitenzähler zählt Blätter und bleibt, wie er ist.

// Das Element, das `counter(...).update` und `.step` ins Dokument legen. Es
// lässt sich abfragen, und sein Schlüssel sagt, welcher Zähler bewegt wurde --
// der einzige Weg an die eigenen Zähler eines Decks, deren Namen hier niemand
// kennt.
#let zaehler-aenderung = counter("typstage-slide").step().func()

/// Die Zähler eines Dokuments auf null, wo es in einem Bündel nicht das erste
/// ist.
///
/// Typst 0.15 zählt in einem Bündel durch alle Dokumente hindurch; nur die
/// Seiten zählen je Dokument von vorn. Gemessen an zwei Folien mit je einer
/// nummerierten Gleichung und einer Abbildung als `bundle(handout: …)`: im
/// Foliensatz „(3)“ und „Figure 3“, im Handzettel „(5)“ und „Figure 5“, allein
/// „(1)“ und „Figure 1“. Und drei `document()` mit je einer Folie aus drei
/// Abbildungen, zwei davon unter `pages: "step"`: das zweite zählte „Figure 4“
/// bis „Figure 6“, das dritte „Figure 7“ bis „Figure 9“. Das Handbuch
/// verspricht, dass die Zähler je Ausgabe neu anfangen.
///
/// Welche Zähler, weiß nur das Dokument: die eigenen eines Decks kennt hier
/// niemand beim Namen. Gefragt wird deshalb wie in `zaehler-klammer` nach
/// Abbildungen, Gleichungen, Überschriften und `counter`-Änderungen -- und nur
/// im Dokument selbst, nicht in denen davor. Gemessen: nach den früheren
/// Dokumenten gefragt, gab `tour` als Bündel aus HTML, Foliensatz und
/// Handzettel eine Warnung mehr ("query for elements matching
/// `counter-update.before(..)` did not stabilize"). Die HTML davor konvergiert
/// in diesem Bündel nicht (siehe den Kommentar in `bundle`), und ihre Sprites
/// tragen Zähleränderungen, die von Lauf zu Lauf wechseln. Im eigenen Dokument steht
/// dieselbe Menge von Zählern, denn `bundle()` setzt überall denselben Rumpf.
///
/// Auf null und nicht auf einen gelesenen Stand: `update(0)` liest nichts,
/// und was die Abfrage liefert, bewegt nur die Menge der Zähler, nicht ihre
/// Werte. Das erste Dokument und ein Deck außerhalb eines Bündels bekommen
/// nichts; dort stehen alle Zähler ohnehin auf null. Die Seitenzahl bleibt, die
/// zählt Typst selbst je Dokument.
#let zaehler-je-dokument() = context {
  let davor = query(std.selector(document).before(here()))
  if davor.len() < 2 { return }
  let dok = davor.last().location()
  let darin(was) = query(std.selector(was).within(dok))
  let zaehler = darin(figure).map(f => f.counter)
  if darin(math.equation).len() > 0 { zaehler.push(counter(math.equation)) }
  if darin(heading).len() > 0 { zaehler.push(counter(heading)) }
  for u in darin(zaehler-aenderung) {
    let c = counter(u.key)
    if c != counter(page) { zaehler.push(c) }
  }
  for c in zaehler.dedup() { c.update(0) }
}

/// Was vor und nach dem Rumpf einer Schrittseite steht, damit alle Seiten einer
/// Folie dieselben Nummern tragen wie ihre erste.
///
/// Die erste Seite (`j == 0`) bekommt zwei Marken mit der Foliennummer. Jede
/// weitere Seite stellt davor jeden Zähler, der zwischen den Marken bewegt
/// wird, um den Abstand zwischen ihnen zurück, und holt danach den Schritt des
/// Lesezeichens nach, das nur die erste Seite trägt.
#let zaehler-klammer(nr, j) = {
  if j == 0 {
    return ([#metadata(nr) <typstage-zaehler-anfang>],
            [#metadata(nr) <typstage-zaehler-ende>])
  }
  // Die Marken des eigenen Dokuments. Mehrere `document()` mit
  // `pages: "step"` in einem Bündel tragen dieselben Foliennummern, und
  // `first()` fand sonst die Marken des ersten Dokuments. Gemessen an zwei
  // Dokumenten, deren Folie 2 eine Abbildung und zwei Abbildungen vor einem
  // `#pause` trägt: die zweite Schrittseite des zweiten nahm den Abstand des
  // ersten zurück und zählte „Figure 2“ und „Figure 3“, die Folie danach
  // „Figure 4“ statt „Figure 3“.
  let marken() = {
    let anfang = query(im-dokument(<typstage-zaehler-anfang>)).filter(m => m.value == nr)
    let ende = query(im-dokument(<typstage-zaehler-ende>)).filter(m => m.value == nr)
    if anfang.len() == 0 or ende.len() == 0 { return none }
    (von: anfang.first().location(), bis: ende.first().location())
  }
  let zurueck = context {
    let m = marken()
    if m == none { return }
    let dazwischen(was) = query(std.selector(was).after(m.von).before(m.bis))
    let zaehler = dazwischen(figure).map(f => f.counter)
    if dazwischen(math.equation).len() > 0 { zaehler.push(counter(math.equation)) }
    if dazwischen(heading).len() > 0 { zaehler.push(counter(heading)) }
    for u in dazwischen(zaehler-aenderung) {
      if type(u.key) == str and u.key.starts-with("typstage-") { continue }
      let c = counter(u.key)
      if c not in (counter(page), counter(footnote)) { zaehler.push(c) }
    }
    // `dedup`: ein Zähler, den eine Abbildung *und* ein `update` bewegt, darf
    // nur einmal zurück, sonst stünde er um den Abstand zu tief.
    for c in zaehler.dedup() {
      let a = c.at(m.von)
      let e = c.at(m.bis)
      if a == e { continue }
      // Je Ebene, und das Ergebnis hat so viele Ebenen wie der Stand davor:
      // `step(level: 2)` hängt eine an, `step()` nimmt sie wieder weg, und
      // beides muss zurück. Die Kappung bei null ist Vorsicht: ein Stand unter
      // null bricht die Übersetzung ab („number must be at least zero“), und
      // in einem Lauf, in dem Abstand und laufender Stand noch nicht
      // zueinander passen, könnte einer entstehen.
      let d = range(calc.max(a.len(), e.len())).map(i =>
        e.at(i, default: 0) - a.at(i, default: 0))
      let ebenen = a.len()
      c.update((..n) => range(ebenen).map(i =>
        calc.max(0, n.pos().at(i, default: 0) - d.at(i, default: 0))))
    }
  }
  let nachholen = context {
    let m = marken()
    if m == none { return }
    // Das Lesezeichen erkennt man an beidem zugleich: Überschriften im Rumpf
    // setzt `slide-body` auf `bookmarked: false`.
    let lesezeichen = heading.where(bookmarked: true, outlined: false)
    for h in query(lesezeichen.after(m.von).before(m.bis)) {
      if h.numbering != none { counter(heading).step(level: h.level) }
    }
  }
  (zurueck, nachholen)
}

/// Build the deck.
///
/// Two notations, the same output. Either the slides as arguments:
///
/// ```typ
/// #presentation(title-slide(title: [Title]), section[Part], slide([First])[…])
/// ```
///
/// … or as a show rule, and then the headings separate the slides:
///
/// ```typ
/// #show: presentation.with(title: [Title], transition: "slide")
/// = A section
/// == A slide
/// Content …
/// ```
///
/// Two targets, one source:
///
/// ```bash
/// typst compile deck.typ deck.html --format html --features html
/// typst compile deck.typ deck.pdf
/// ```
///
/// `slide-level:` is where the deck is cut. A heading *above* it becomes a
/// section slide, a heading at it or below it becomes a slide. The default is
/// 2, and that is the rule this package always had: `=` opens a section,
/// `==` a slide. A heading written as a call counts by its level the same
/// way: `heading(level: 3)[…]` as `===`, `heading[…]` as `=`.
///
/// `section-numbering:` puts a prefix on section slide titles. It takes a
/// numbering pattern such as `"1."`, a function that receives the section
/// number, or `none`.
///
/// `none` is the default, and deliberately: a deck that says nothing about
/// numbering keeps the titles it had. Switching it on by default would have
/// renumbered every deck already written -- measured on `gliedern`, "Where we
/// are going" became "1. Where we are going" without anyone asking.
///
/// `section-back:` is the link back to the contents at the foot of a section
/// slide. `auto` is the word in the deck's language, `none` leaves it out
/// everywhere, content or a string words it differently, and a function gets
/// one dictionary -- `location` of the contents slide, `word`, `contents`
/// with its printed slide `number`, and `section` with `number`, `title`,
/// `depth` and `parents` -- and returns content, or `none` to drop the link
/// on that one slide. The theme keeps the place and the link; the value is
/// the body, so a `text` of your own inside wins over the accent.
///
/// ```typ
/// #show: presentation.with(section-back: [Back to the agenda])
/// ```
///
/// ```typ
/// #show: presentation.with(title: [Analysis], slide-level: 3)
/// = Part I
/// == Sequences
/// === What a sequence is
/// A map from the naturals.
/// ```
///
/// `= Part I` and `== Sequences` each become a section slide, `===` becomes
/// the slide. Both transition slides come for free: a section heading *is* the
/// transition slide here, so there is nothing to switch on and no hook to
/// write. `slide-level: 1` makes every heading a slide and leaves the deck
/// without any structure level.
///
/// A deeper level is drawn more quietly by all five bundled themes, smaller
/// and with the titles it hangs under set above it. A theme of its own reads
/// `s.depth` and `s.parents` off the section record and may ignore both, and
/// then every level looks alike.
///
/// What the deck knows about its structure is in `info()`: `section` is
/// unchanged and always means the level directly above the slide, `levels`
/// has one entry per structure level, and `outline` is the whole thing.
///
/// `theme:` determines the whole look: colors, typeface, title bar,
/// footer, progress, title and section slide. Bundled are `themes.default`
/// (the default), `themes.lesson`, `themes.night`, `themes.plain` and
/// `themes.editorial`; each of them can be varied with
/// `themes.night + (accent: blue)`. The `style` hook stays untouched by this
/// and sits further *inside*: whatever is set there overrides the theme.
///
/// `palette:` changes the colors and leaves the design alone. It is a
/// dictionary over the eight color entries and it overwrites *partially*, so
/// `palette: (accent: blue)` moves the accent and nothing else. Five are
/// bundled, `palettes.light`, `palettes.mono`, `palettes.textbook`,
/// `palettes.parchment` and `palettes.dark`, and each of them composes with
/// each theme:
///
/// ```typ
/// #show: presentation.with(theme: themes.lesson, palette: palettes.dark)
/// ```
///
/// Two colors of a theme are not palette entries: `title-fill` and
/// `rule-fill`. All five bundled themes let them follow, either as a function
/// of the palette or as `none`, which means the accent and follows with it. A
/// theme of your own that names a fixed color there keeps it under every
/// palette, which is deliberate.
///
/// Both changed type with this: reading `themes.X.title-fill` used to give a
/// color and now gives a function, and `rule-fill` gives `none` where it gave
/// the accent. Writing them, `themes.X + (title-fill: red)`, is unchanged.
///
/// `speaker-view` says what the presenter view shows. Everything is on unless
/// switched off, so a deck that says nothing gets the whole thing:
///
/// ```typ
/// #show: presentation.with(speaker-view: (
///   clock: false,                       // no class clock
///   target: false,                      // no planned length
///   pen: (colors: (red, green, blue)),  // the drawing bar's colours
/// ))
/// ```
///
/// A tile that is switched off takes its keys with it: with `clock: false`,
/// `t` and `⇧t` do nothing and no longer stand in the key bar. A view that
/// advertises a key which does nothing is worse than one that is missing it.
/// `tools: false` removes the drawing bar the same way.
/// `shortcuts: false` starts with the keyboard bar hidden. `h` or its `?`
/// button toggles it during a talk; the choice is remembered for this session.
/// Media controls show play/pause and a timeline. `k` toggles playback,
/// `j`/`l` seek ten seconds; `Shift+L` switches the presenter's light theme.
///
/// `room` is the counterpart: what reaches the hall, as opposed to what only
/// the speaker sees. It knows `clock` (how coarsely the class clock reads,
/// and whether the digit keys start it), `sounds` (a key, a sound file),
/// `bell` (the time the lesson begins, which `video(ends-at: auto)` counts
/// towards) and `pointer` (the dot the speaker view guides across the slide):
///
/// ```typ
/// #show: presentation.with(room: (
///   clock: (step: 5),                            // the clock reads in fives
///   pointer: (color: rgb("#00c853"), size: 4%),  // colour, share of the width
/// ))
/// ```
///
/// `pointer: false` takes the dot away again; embedded frames stay operable
/// either way, they are the pointer mode's other half. The dot defaults to
/// the accent at 2.2% of the slide width, and `size` is a ratio between 0.8%
/// and 6%. Its colour need not contrast with anything: a light ring and a
/// dark one around the core carry that, whichever ground it lands on.
///
/// The PDF is a handout: one page per slide, every tracked element in its
/// final state. What belongs only to the motion, the notes, the slide transitions,
/// the bridge jobs, are state updates without output and fall away by themselves.
///
/// `overflow` is a checking pass over the deck, off by default. It measures
/// every slide body against the room the theme gives it and names the ones
/// that do not fit, with the earliest step on which the overrun can be on the
/// screen. Title and section slides are not measured: the theme draws them
/// with `place` and they have no body block. Nor is the PDF under
/// `pages: "step"`: every step page sets the same body as the one page per
/// slide, and measuring it there cost convergence for decks that look
/// something up in their body. Nor is a handout that is given `pages: "step"`,
/// which is what `bundle()` does: it measured against the step pages beside
/// it. The HTML still measures, and names the step too.
///
/// - `"none"`: nothing is measured. The default.
/// - `"error"`: the whole deck is built, and it then stops with *every* place
///   at once rather than the first.
/// - `"record"`: it carries on and files a record per finding instead, for a
///   tool to read. The deck has to be on `"record"` for this; on `"error"`
///   the command below stops with the error too:
///
/// ```sh
/// typst eval --target html --features html --in deck.typ \
///   'query(<typstage-overflow>).map(e => e.value)'
/// ```
///
/// The same setting can be raised from the command line, so a build script
/// can measure a deck without editing it:
///
/// ```sh
/// typst compile --features html --format html \
///   --input typstage-overflow=error deck.typ deck.html
/// ```
///
/// The input raises, it never lowers. Of the two the stricter one wins,
/// `"none"` < `"record"` < `"error"`, so a run cannot switch off a check the
/// deck asked for.
///
/// It is not meant to stay on while writing. Measured over the six example
/// decks: in HTML it costs noticeably more time, between 1.2 and 1.5 times
/// depending on the deck and on how the process start is accounted for. On
/// paper it costs a few milliseconds per deck, small but repeatable: there the
/// check runs without the step arithmetic.
///
/// Why a deck of slides needs this more than a document does: a slide goes
/// into an SVG frame of fixed size and is scaled in the browser, so what
/// sticks out is cut away or drawn beside the slide. A page one leafs through
/// shows an overrun; a talk one clicks through shows it at the projector.
///
/// `drift` is the second check, and unlike `overflow` it is on. Every `scene`
/// measures its frames, and a scene whose frames come out different sizes is
/// named: a CeTZ canvas is as large as what it holds, so a wider frame puts
/// the drawing somewhere else inside its box and paging through it the whole
/// picture travels while only one point should move.
///
/// - `"error"`, the default: the deck is built and then stops with every
///   scene at once. `scene(steady: false)` says the frames of that one scene
///   are meant to differ and takes it out of the check.
/// - `"record"`: it carries on and leaves a record per finding, for a tool to
///   read, the same way `overflow: "record"` does:
///
/// ```sh
/// typst eval --target html --features html --in deck.typ \
///   'query(<typstage-drift>).map(e => e.value)'
/// ```
///
/// - `"none"`: the frames are not measured at all.
///
/// On by default where `overflow` is not, and for two reasons. Only decks
/// that use `scene` pay for it at all -- measured on a scene of 28 CeTZ
/// frames, 434 ms without and 536 ms with, so about 100 ms for that scene --
/// where `overflow` measures every slide of every deck and costs 1.2 to 1.5
/// times the whole compilation. And what it finds is invisible while writing:
/// every frame on its own looks right, and only paging through shows the
/// drawing travelling. Only the browser branch measures. On paper a scene is
/// one still image, and a still image does not travel.
#let presentation(
  ..slides,
  title: none,
  subtitle: [],
  author: [],
  date: none,
  assets: "inline",
  theme: themes.default,
  palette: (:),
  transition: "slide",
  speaker-view: (:),
  room: (:),
  transition-duration: 420,
  duration: 520,
  style: it => it,
  width: auto,
  height: auto,
  margin: auto,
  handout: false,
  overflow: "none",
  drift: "error",
  slide-level: 2,
  section-numbering: none,
  section-back: auto,
  pages: "slide",
) = {
  // `..slides` would otherwise swallow any named argument without a word:
  // `presentation(pallete: palettes.dark)` did nothing and said nothing. The
  // same check `palette-pruefen` makes on a palette's keys.
  assert(slides.named().len() == 0, message:
    "typstage: presentation() does not know "
    + slides.named().keys().join(", ")
    + ". It takes title, subtitle, author, date, assets, theme, palette, "
    + "transition, transition-duration, duration, speaker-view, room, style, "
    + "width, height, margin, handout, overflow, drift, slide-level, "
    + "section-numbering, section-back and pages.")
  assert(pages in ("slide", "step"), message:
    "typstage: pages is \"slide\" -- one page per slide, every tracked "
    + "element in its final state -- or \"step\": one page per step, so the "
    + "PDF unfolds the way the talk does. Not " + repr(pages))
  assert(type(slide-level) == int and slide-level >= 1, message:
    "typstage: slide-level is the heading depth at which a heading becomes a "
    + "slide, an integer from 1 upwards; 2 is the default. Not "
    + repr(slide-level))
  assert(section-numbering == none or type(section-numbering) == str
         or type(section-numbering) == function, message:
    "typstage: section-numbering is a numbering pattern, none or a function "
    + "receiving the section number. Not " + repr(section-numbering))
  // Ein Symbol bekommt hier kein `repr`. Gemessen an `section-back:
  // sym.arrow.l`: die Meldung wuchs beim PDF-Bau auf 65 Zeilen und 1945
  // Zeichen (beim HTML-Bau samt dessen Warnung auf 70 und 2195), weil
  // `repr` eines Symbols die ganze Variantenliste druckt -- der lesbare Satz
  // steht dann in Zeile 1 und ertrinkt. Nur hier, und nur weil ein Pfeil bei
  // genau diesem Parameter die naheliegende falsche Eingabe ist: ein
  // Rueckverweis heisst in vielen Decks schlicht "←". Die uebrigen
  // Zusicherungen behalten die Hausform `repr`.
  let rueck-repr = if type(section-back) == symbol {
    "a symbol. Wrap it in content: section-back: [#sym.arrow.l]"
  } else { repr(section-back) }
  assert(section-back == auto or section-back == none
         or type(section-back) in (content, str)
         or type(section-back) == function, message:
    "typstage: section-back is the link back to the contents at the foot of "
    + "a section slide: auto for the word in the deck's language, none for "
    + "no link at all, content or a string to word it differently, or a "
    + "function taking one dictionary -- location, word, contents, section "
    + "-- and returning content, or none to leave this one out. Not "
    + rueck-repr)
  assert(overflow in ("none", "error", "record"), message:
    "typstage: overflow is \"none\" (the default), \"error\" or \"record\", "
    + "not " + repr(overflow))
  // Von außen anschaltbar. Der Melder ist per Vorgabe aus, weil er den Bau um
  // das 1,2- bis 1,5-fache verteuert -- und genau deshalb lief er über die
  // Beispieldecks nie. Gemessen an einer Folie, die 33 Punkte unter die Bühne
  // ragte: der Decklauf meldete "ok", denn er prüft nur, *dass* der Melder
  // noch meldet, nicht die Decks selbst.
  //
  //   typst compile --input typstage-overflow=error deck.typ deck.html
  //
  // Die Eingabe hebt an, sie senkt nie ab. Es gilt der strengere der beiden
  // Werte, "none" < "record" < "error". Sonst könnte ein Lauf ein Deck, das
  // den Melder selbst auf "error" gestellt hat, im Vorbeigehen stumm schalten
  // -- und ausgerechnet die Probe wäre der Weg, eine Prüfung abzustellen.
  let strenge = ("none": 0, "record": 1, "error": 2)
  let von-aussen = sys.inputs.at("typstage-overflow", default: "none")
  assert(von-aussen in strenge, message:
    "typstage: --input typstage-overflow= is \"none\", \"error\" or "
    + "\"record\", not " + repr(von-aussen))
  let overflow = if strenge.at(von-aussen) > strenge.at(overflow) {
    von-aussen
  } else { overflow }
  assert(drift in ("none", "error", "record"), message:
    "typstage: drift is \"error\" (the default), \"record\" or \"none\", not "
    + repr(drift))
  // Beide Zeiten gehen in die Konfiguration, die die Laufzeit als erstes
  // liest. Eine negative oder eine Nicht-Zahl kaeme dort als kaputtes JSON an
  // und truege die ganze Datei zu Grabe, ohne ein Wort. Lieber hier ein Satz.
  assert(type(duration) == int and duration >= 0, message:
    "typstage: duration is the planned length of the talk in minutes, a "
    + "whole number from 0 upwards; 0 turns the pace off. Not "
    + repr(duration))
  // `theme: "lesson"` statt `theme: themes.lesson` ist der wahrscheinlichste
  // Anfaengerfehler des Pakets, und er endete bisher mit "expected integer,
  // found string" aus dem Inneren von `themes.typ`.
  assert(type(theme) == dictionary, message:
    "typstage: theme takes a theme, not " + str(type(theme)) + ". The bundled "
    + "ones live in `themes`: themes.default, themes.editorial, themes.lesson, "
    + "themes.night, themes.plain -- written without quotes.")
  // Was die Sprecheransicht zeigen soll. Ein Deck, das keine Klassenuhr
  // braucht, soll ihre Kachel nicht sehen -- sie nimmt Platz, der der Notiz
  // fehlt. Vorgabe ist ueberall `true`: wer nichts sagt, bekommt alles.
  assert(type(speaker-view) == dictionary, message:
    "typstage: speaker-view takes a dictionary, not " + str(type(speaker-view))
    + ". It knows clock, target, tools, shortcuts and pen.")
  for k in speaker-view.keys() {
    assert(k in ("clock", "target", "tools", "shortcuts", "pen"), message:
      "typstage: speaker-view has no entry \"" + k + "\". It takes clock "
      + "(the class clock), target (the planned length), tools (the drawing "
      + "bar), shortcuts (the keyboard help) and pen.")
    if k != "pen" {
      assert(type(speaker-view.at(k)) == bool, message:
        "typstage: speaker-view." + k + " is true or false, not "
        + repr(speaker-view.at(k)))
    }
  }
  if "pen" in speaker-view {
    let stift = speaker-view.pen
    assert(type(stift) == dictionary and stift.keys().all(k => k == "colors"),
      message: "typstage: speaker-view.pen takes a dictionary with `colors`, "
        + "a list of colours for the drawing bar. Not " + repr(stift))
    if "colors" in stift {
      assert(type(stift.colors) == array and stift.colors.len() > 0
             and stift.colors.all(f => type(f) == color), message:
        "typstage: speaker-view.pen.colors is a non-empty list of colours, "
        + "written as colours and not as strings. Not " + repr(stift.colors))
    }
  }
  // Was der Saal sieht und hoert. Das Gegenstueck zu `speaker-view`: dort
  // steht, was nur der Vortragende sieht, hier, was im Raum ankommt. Der Name
  // ist keine Erfindung -- die Hilfezeile nennt diese Gruppe seit je "Saal:".
  assert(type(room) == dictionary, message:
    "typstage: room takes a dictionary, not " + str(type(room))
    + ". It knows clock, sounds, bell and pointer.")
  for k in room.keys() {
    assert(k in ("clock", "sounds", "bell", "pointer"), message:
      "typstage: room has no entry \"" + k + "\". It takes clock (how the "
      + "class clock reads in the hall, and whether the digit keys start it), "
      + "sounds (a key, a sound file), bell (when the lesson begins) and "
      + "pointer (the dot the speaker view guides across the slide).")
  }
  // Der Zeigepunkt. `false` schaltet ihn ab; ein Woerterbuch stellt ihn.
  // Die Bedienung eingebetteter Rahmen haengt nicht daran -- der Zeigermodus
  // kann beides, und wer den Punkt nicht will, will den Rahmen vielleicht
  // trotzdem bedienen.
  if "pointer" in room {
    let z = room.pointer
    assert(type(z) == bool or type(z) == dictionary, message:
      "typstage: room.pointer is false (no dot in the hall), true, or a "
      + "dictionary with color and size. Not " + repr(z))
    if type(z) == dictionary {
      for k in z.keys() {
        assert(k in ("color", "size"), message:
          "typstage: room.pointer has no entry \"" + k + "\". It takes color "
          + "and size (a ratio of the slide width).")
      }
      if "color" in z {
        assert(type(z.color) == color, message:
          "typstage: room.pointer.color is a colour, written as a colour and "
          + "not as a string. Not " + repr(z.color))
      }
      if "size" in z {
        // Als Anteil der Folienbreite und nicht in Punkten: die Buehne ist im
        // Sprecherfenster gemessen 622 und im Saal 1600 Bildpunkte breit, und
        // der Punkt soll auf der Folie dieselbe Groesse haben. Die Schranken
        // sind gemessen: unter 0,8% sind im Saal die beiden Ringe, die den
        // Kontrast tragen, duenner als ein Bildpunkt -- bei 0,8% von 1600
        // misst jeder 0,9 --, ueber 6% verdeckt er eine ganze Zeile.
        assert(type(z.size) == ratio and z.size >= 0.8% and z.size <= 6%,
          message: "typstage: room.pointer.size is a ratio of the slide "
            + "width between 0.8% and 6%. Not " + repr(z.size))
      }
    }
  }
  if "bell" in room {
    assert(type(room.bell) == str
           and room.bell.match(regex("^[0-9]{1,2}:[0-5][0-9]$")) != none
           and int(room.bell.split(":").first()) <= 23,
      message: "typstage: room.bell is the time the lesson begins, as "
        + "\"HH:MM\" on a 24-hour clock. A `video(ends-at: auto)` ends on it. "
        + "Not " + repr(room.bell))
  }
  if "clock" in room {
    let uhr = room.clock
    assert(type(uhr) == dictionary, message:
      "typstage: room.clock takes a dictionary with step, digits and sound, not "
      + repr(uhr) + ". To hide the clock entirely, speaker-view: (clock: false).")
    for k in uhr.keys() {
      assert(k in ("step", "digits", "sound"), message:
        "typstage: room.clock has no entry \"" + k + "\". It takes step (how "
        + "coarsely the clock reads), digits (whether 1 to 9 start it), "
        + "and sound (a file path or direct audio URL, or none).")
    }
    if "sound" in uhr {
      assert(uhr.sound == none or (type(uhr.sound) == str and uhr.sound != ""
             and not uhr.sound.contains("<")), message:
        "typstage: room.clock.sound is a file path, direct audio URL, or none.")
    }
    if "step" in uhr {
      let s = uhr.step
      assert(type(s) == int or type(s) == duration, message:
        "typstage: room.clock.step is a number of seconds or a duration, not "
        + repr(s) + ". Write 5 or duration(seconds: 5).")
      let sek = if type(s) == duration { s.seconds() } else { s }
      // Der Schritt muss 60 teilen. Sonst stimmt die Zahl schon im Augenblick
      // des Starts nicht: eine `class-clock(1)` staende bei einem Schritt von
      // 7 Sekunden sofort auf 00:56, und das liest sich wie ein Fehler der Uhr
      // und nicht wie einer der Einstellung.
      assert(type(sek) == int and sek >= 1 and sek <= 60 and calc.rem(60, sek) == 0,
        message: "typstage: room.clock.step has to divide 60 evenly -- 1, 2, "
        + "3, 4, 5, 6, 10, 12, 15, 20, 30 or 60 seconds. Not " + repr(s))
    }
    if "digits" in uhr {
      assert(type(uhr.digits) == bool, message:
        "typstage: room.clock.digits is true or false, not " + repr(uhr.digits))
    }
  }
  if "sounds" in room {
    let toene = room.sounds
    assert(type(toene) == dictionary, message:
      "typstage: room.sounds takes a dictionary of key to sound file, like "
      + "(a: \"airhorn.mp3\"). Not " + repr(toene))
    // Die Liste steht hier und wird nicht aus der Laufzeit abgeschrieben: die
    // Tastentabelle der Bruecke kennt `d` und `l` nicht, obwohl beide belegt
    // sind, und wer von dort abschreibt, gibt Zieldauer und hell/dunkel weg.
    let frei = ("a", "g", "i", "p", "q", "s", "u", "v", "w", "y")
    for (taste, datei) in toene.pairs() {
      assert(taste in frei, message:
        "typstage: room.sounds cannot use \"" + taste + "\" -- the runtime "
        + "already has that key, or it is not a single letter. Free are "
        + frei.join(", ") + ".")
      assert(type(datei) == str and datei != "", message:
        "typstage: room.sounds." + taste + " is the name of a sound file that "
        + "travels beside the HTML, like \"airhorn.mp3\". Not " + repr(datei))
      // Eine Zeichenkette aus dem Deck landet in einem Skriptzusammenhang.
      assert(not datei.contains("<"), message:
        "typstage: room.sounds." + taste + " may not contain \"<\".")
    }
  }
  uebergang-pruefen(transition, "presentation")
  assert(type(transition-duration) == int and transition-duration >= 0,
    message: "typstage: transition-duration is how long a slide change takes "
    + "in milliseconds, a whole number from 0 upwards; 0 switches without an "
    + "animation. Not " + repr(transition-duration))
  // 16:9 on an A4-width canvas unless told otherwise. 4:3 is
  // `width: 800pt, height: 600pt`; everything the theme draws scales along.
  // Der Name der Registerkarte, und zugleich der Titel im PDF. Ohne ihn hiess
  // jedes Deck im Browser nach seinem Dateipfad, obwohl `title:` laengst
  // uebergeben war, und das PDF trug ueberhaupt keinen. Typst hebt ein
  // `title`-Element aus dem Rumpf *nicht* in den Kopf -- `set document` tut es.
  set document(title: title) if title != none

  // Typsts Fußnotenapparat stillgelegt, weil er auf einer Folie nicht gehen
  // kann. Er setzt seine Einträge an den Fuß des *Inhaltsbereichs*; eine
  // Folie ist aber ein Block in genau Seitenhöhe und lässt dort nichts übrig.
  // Gemessen an einem Deck aus drei Folien mit einer Fußnote: vier Seiten
  // statt drei, und der Anmerkungstext stand allein auf einer Geisterseite
  // *vor* der Folie, die ihn nennt. Im HTML war er auf keiner Folie zu sehen.
  //
  // Die Marke im Text bleibt -- die zeichnet das Element selbst, und sie
  // stimmt. Nur der Eintrag verschwindet, und die Abstände dazu müssen mit,
  // sonst hält die Seite weiter Platz für etwas, das nicht mehr da ist:
  // gemessen blieb es ohne sie bei vier Seiten.
  //
  // Gesetzt wird die Anmerkung stattdessen von `slide-body`, das die Fußnoten
  // seiner Folie abfragt und sie unter den Rumpf stellt.
  set footnote.entry(separator: none, clearance: 0pt, gap: 0pt, indent: 0pt)
  show footnote.entry: none

  let geo = canvas(width: width, height: height, margin: margin)
  let given = slides.pos()
  // A single piece of content means: this is the body of a show rule, and that
  // gets split at its headings.
  let all = if given.len() == 1 and type(given.at(0)) == content {
    slides-from-body(given.at(0), title, subtitle, author, date, slide-level)
  } else {
    // The title belongs to the deck, not to one of the two notations. Whoever
    // hands slides as arguments used to lose it without a word.
    let rest = given.flatten()
    if title != none and rest.all(s => s.kind != "title") {
      let head = title-slide(title: title, subtitle: subtitle,
                             author: author, date: date)
      (head,) + rest
    } else { rest }
  }
  // Wo eine Folie steht, für die Meldungen um `bleed`: ihr Titel, sonst ihre
  // Nummer. Eine Zeile im Deck kann keine davon nennen, die Marke ist dort
  // längst ein Wert.
  let wo(i) = {
    let s = all.at(i)
    let name = plain-text(s.at("title", default: none)).trim()
    // Die Art vor dem Namen. Ohne sie hieß eine Abschnittsfolie mit Titel hier
    // "the slide \"Abschnitt\"", und wer das las, suchte nach einem `==`, das
    // es nicht gibt -- während dieselbe Stelle ohne Titel schon immer richtig
    // "a section slide" sagte.
    let art = if s.kind == "section" { "the section slide " }
              else if s.kind == "title" { "the title slide " }
              else { "the slide " }
    if name != "" { art + "\"" + name + "\"" }
    else if s.kind == "slide" {
      "slide " + str(all.slice(0, i + 1).filter(x => x.kind == "slide").len())
    } else if s.kind == "section" { "a section slide" } else { "the title slide" }
  }
  // Eine Fußnote in der Überschrift bricht ab, statt still falsch zu stehen:
  // der Titel wird wiederholt, und jede Wiederholung setzt sie neu. Vor der
  // Abzweigung darunter, denn eine Titel- oder Abschnittsfolie hat keinen
  // Rumpf und käme dort nie vorbei.
  //
  // Ein `bleed` im Titel ebenso, und aus demselben Grund hier: auch
  // `section(bleed(…))` und `presentation(title: bleed(…))` sind Titel. Gesetzt
  // meldete sich erst der Wächter der Marke, und der spricht vom Rumpf.
  for (i, s) in all.enumerate() {
    if bleed-tief(s.at("title", default: none)) {
      panic("typstage: bleed() cannot stand in a title, and it does on "
            + wo(i) + ". A title is drawn in its band and repeated in the "
            + "running header, the contents and the speaker view, and a layer "
            + "the size of the canvas fits none of them. Put bleed() at the top "
            + "of the slide body, directly below the heading.")
    }
    if fussnote-im-titel(s.at("title", default: none)) {
      panic("typstage: a footnote in a slide title cannot work. The title is "
            + "repeated -- as a running head above the slides of its section, "
            + "in the contents, in the speaker view -- and every repetition "
            + "sets the footnote again, so the slides after it carry the wrong "
            + "note and their own numbering shifts. Put the footnote into the "
            + "slide body instead. The title in question reads: "
            + plain-text(s.title))
    }
  }
  let all = all.enumerate().map(((i, s)) => if s.body == none { s } else {
    // `bleed` kommt aus dem Rumpf, bevor die Pausen ihn schneiden: danach
    // stünde eine Marke hinter einer Pause in einem `anim` und wäre für den
    // flachen Gang verloren. Nur bei einem Fund bekommt die Folie einen neuen
    // Rumpf und den Schlüssel `bleed`; jede andere bleibt, wie sie war.
    //
    // Umsortiert wird nichts. Ein `bleed` weiter unten, hinter einer Pause
    // oder zweimal bricht ab: es wird zuerst gesetzt, und still nach vorn
    // geholt folgten die Schritte, die Fußnotenzahlen und die Stapelung der
    // Sprites einer anderen Reihenfolge als der Quelle.
    let geteilt = bleed-teilen(s.body)
    let randlos = geteilt.funde.at(0, default: none)
    if geteilt.funde.len() > 1 {
      panic("typstage: " + wo(i) + " holds " + str(geteilt.funde.len())
            + " bleed() calls, and a slide has one canvas. Put everything that "
            + "goes edge to edge into a single bleed().")
    }
    if geteilt.vor == "pause" {
      panic("typstage: bleed() on " + wo(i) + " stands behind a #pause. It is "
            + "the layer right above the slide's ground and stands from the first "
            + "step, so the pause would be ignored without a word. Move bleed() "
            + "above the first #pause; to bring a part of it in later, wrap that "
            + "part in anim() inside the bleed().")
    }
    if geteilt.vor == "inhalt" {
      panic("typstage: bleed() on " + wo(i) + " comes after other content. It "
            + "is laid out first, right above the slide's ground, and the rest of "
            + "the slide lies on top of it -- written further down, the steps, "
            + "the footnote numbers and the stacking would follow another order "
            + "than the source. Move it to the top of the slide body; #set and "
            + "#show rules, #invert, #transition, #speaker-note and #class-clock "
            + "may stand above it.")
    }
    if randlos != none and hat-pause(randlos) {
      panic("typstage: a #pause inside bleed() on " + wo(i) + " does nothing. "
            + "The pauses of a slide are cut from its body, and bleed() is taken "
            + "out of the body before that. Wrap the part that comes in later in "
            + "anim() instead.")
    }
    if randlos != none and bleed-tief(randlos) {
      panic("typstage: bleed() inside bleed() on " + wo(i) + ". The outer one "
            + "already covers the canvas; drop the inner call.")
    }
    let s = if randlos == none { s } else { s + (body: geteilt.rumpf, bleed: randlos) }
    // The marker is looked for in the body as it was written, before the
    // pauses cut it into runs: after that, a marker standing behind a pause
    // sits inside an `anim` wrapper and the walk would miss it. The title is
    // searched too, because in heading notation `== A slide #invert` is the
    // place the marker naturally lands, and it went unseen there.
    s + (invert: s.at("invert", default: false)
                 or hat-invert(s.body) or hat-invert(s.title)
                 or (randlos != none and hat-invert(randlos)),
         body: apply-pauses(s.body))
  })
  let total = all.filter(s => s.kind == "slide").len()

  // ── The structure above the slides ──────────────────────────────────────
  //
  // One level per heading depth above `slide-level`. At the default of 2
  // that is exactly the depth 1, one level, and every count below comes out
  // the way it always did.
  //
  // The bound is the deeper of the two: what `slide-level` allows, and what
  // the deck actually hands over. The second half is for the argument
  // notation, where `section(.., depth: 2)` is legal whatever `slide-level`
  // says, and where a level that exists but is not counted would leave the
  // running header empty on a slide that plainly has a section.
  let tiefe-max = calc.max(slide-level - 1, 0,
    ..all.filter(s => s.kind == "section").map(s => s.at("depth", default: 1)))
  let tiefen = range(1, tiefe-max + 1)

  // First pass over the section slides: each one learns which titles it hangs
  // under, and which group of siblings it stands in. A group is a run of
  // sections of the same depth under the same parent, and it is what turns
  // "the fourth section of the deck" into Beamer's "the second of this part".
  //
  // A heading closes everything that stood open below it. Without that, a
  // slide under a fresh `= Part II` would still report the last `==` of part
  // one as its section, and it would report it in the same breath as the new
  // part. Typst closures cannot write to variables outside themselves, so the
  // walk is spelled out rather than put in a `map`.
  let abschnitte = ()
  let offen-titel = tiefen.map(_ => none)
  let offen-nr = tiefen.map(_ => -1)
  for (i, s) in all.enumerate() {
    if s.kind != "section" { continue }
    let d = s.at("depth", default: 1)
    abschnitte.push((
      nr: i,
      depth: d,
      title: s.title,
      parents: offen-titel.slice(0, d - 1).filter(x => x != none),
      // The chain of open ancestors names the group; the depth has to come
      // along, or a `==` and a `===` under the same part would share one.
      gruppe: repr(offen-nr.slice(0, d - 1)) + "|" + str(d),
    ))
    offen-titel = offen-titel.enumerate().map(((j, x)) =>
      if j == d - 1 { s.title } else if j > d - 1 { none } else { x })
    offen-nr = offen-nr.enumerate().map(((j, x)) =>
      if j == d - 1 { i } else if j > d - 1 { -1 } else { x })
  }
  // How large each group is, and how many sections each level has in the
  // whole deck. Both are wanted *before* the walk below, since `count` and
  // `total` are the sizes of something the slide is standing in the middle
  // of.
  let gruppen-groesse = (:)
  for a in abschnitte {
    gruppen-groesse.insert(a.gruppe, gruppen-groesse.at(a.gruppe, default: 0) + 1)
  }
  let tiefen-total = tiefen.map(d => abschnitte.filter(a => a.depth == d).len())
  // Second pass: the finished level entry for each section slide.
  let ebenen-satz = ()
  let nummern = tiefen.map(_ => 0)
  let laufend = (:)
  for a in abschnitte {
    nummern.at(a.depth - 1) += 1
    laufend.insert(a.gruppe, laufend.at(a.gruppe, default: 0) + 1)
    ebenen-satz.push((
      depth: a.depth,
      number: nummern.at(a.depth - 1),
      total: tiefen-total.at(a.depth - 1),
      index: laufend.at(a.gruppe),
      count: gruppen-groesse.at(a.gruppe),
      title: a.title,
    ))
  }
  // The whole structure, in the order it comes. The same list the counting
  // above ran on, only reduced to what a deck may read. No `query`, no second
  // walk over the document.
  let gliederung = abschnitte.enumerate().map(((j, a)) => (
    depth: a.depth, number: ebenen-satz.at(j).number, title: a.title,
  ))
  // Dasselbe noch einmal, aber mit dem Stück Deck, das zu jedem Abschnitt
  // gehört. `gliederung` sagt, wie das Deck gegliedert ist; das hier sagt, wo
  // die Schnitte liegen -- und das ist, was eine Navigationsleiste braucht und
  // was `info()` bisher schuldig blieb. Wer es nachbauen wollte, müsste an
  // `state("typstage-info")` heran, also an ein Internum.
  //
  // Gezählt wird transitiv: unter einen Abschnitt der Tiefe 1 fallen auch die
  // Folien seiner Unterabschnitte. Eine Leiste, die nur die eigenen zählte,
  // zeigte für jede Oberüberschrift eine Null.
  //
  // Eine reine Rechnung über `all`, ohne `query` und ohne zweiten Gang durch
  // das Dokument -- sie zeichnet nichts und kann deshalb auch nichts
  // verschieben.
  let schnitte = {
    let raus = ()
    let k = 0
    for (i, s) in all.enumerate() {
      if s.kind != "section" { continue }
      let tiefe = abschnitte.at(k).depth
      let erste = none
      let letzte = none
      let wieviele = 0
      let n = 0
      let m = 0
      // Die Folien vor diesem Abschnitt zählen, um bei seiner ersten die
      // richtige Nummer zu haben.
      for (j, t) in all.enumerate() {
        if j >= i { break }
        if t.kind == "slide" { n += 1 }
      }
      let tieferK = k
      for (j, t) in all.enumerate() {
        if j <= i { continue }
        // Ein Abschnitt derselben oder einer flacheren Tiefe beendet den Lauf.
        if t.kind == "section" {
          tieferK += 1
          if abschnitte.at(tieferK).depth <= tiefe { break }
          continue
        }
        if t.kind == "slide" {
          m += 1
          wieviele += 1
          if erste == none { erste = n + m }
          letzte = n + m
        }
      }
      raus.push((depth: tiefe, number: ebenen-satz.at(k).number,
             title: abschnitte.at(k).title,
             target: abschnitte.at(k).nr,
                 first: erste, last: letzte, count: wieviele))
      k += 1
    }
    raus
  }
  // What a section slide hands its theme: its depth, and the titles above it.
  // Both go on the record itself rather than into a new theme key, so a theme
  // that ignores them draws every level alike instead of failing.
  let all = {
    let k = 0
    let raus = ()
    for s in all {
      if s.kind != "section" { raus.push(s) } else {
        raus.push(s + (depth: abschnitte.at(k).depth,
                       parents: abschnitte.at(k).parents,
                       number: ebenen-satz.at(k).number,
                       section-numbering: section-numbering,
                       section-back: section-back))
        k += 1
      }
    }
    raus
  }

  // The theme with the palette laid over it, once for the deck and once
  // turned around. Both are worked out here rather than per slide: they are
  // the same two dictionaries on every slide, and the inverted one is only
  // ever reached for by a slide that asked for it.
  //
  // Both are built from the theme as it came in, not the inverted one from
  // the merged one. `mit-palette` resolves `title-fill` and `rule-fill` into
  // colors, so a theme that has already been through it no longer carries the
  // functions the inversion has to ask again.
  let palette = palette-pruefen(palette)
  let thema-hell = mit-palette(theme, palette)
  let thema-dunkel = mit-palette(theme, palette, invert: true)
  let thema(s) = if s.at("invert", default: false) { thema-dunkel } else { thema-hell }
  // Whether any slide inverts at all. A deck without one writes the theme
  // into its state exactly once, as before; only a deck that inverts pays for
  // an update per slide, and there it is needed, since a `card` reads its
  // tints out of that state and has to see the slide it stands on.
  let wechselt = all.any(s => s.at("invert", default: false))

  // Everything the deck knows about itself, one entry per slide, counted here
  // and nowhere else. All three outputs read from this list, and so does a
  // deck's own `info()`; that there is exactly one list is the whole reason a
  // hand-built footer cannot disagree with the built-in one.
  //
  // `nr` counts every slide, title and section slides included, and stays out
  // of the public dictionary: it is only the key under which a slide files its
  // step count. `slide.number` deliberately counts differently.
  let daten = {
    let kopf = all.find(s => s.kind == "title")
    if kopf != none {
      (title: kopf.title, subtitle: kopf.subtitle,
       author: kopf.author, date: kopf.date)
    } else {
      (title: title, subtitle: subtitle, author: author, date: date)
    }
  }
  let facts = ()
  let gezaehlt = 0
  let gesehen = 0
  // The outline as every slide sees it that is not itself a section slide.
  // Built once, not once per slide.
  let gliederung-still = gliederung.map(e => e + (here: false))
  // The reading of every level before the first section slide: nothing is
  // running, nothing has been counted, and the deck already knows how many
  // there will be.
  let ebenen = tiefen.map(d => (depth: d, number: 0, total: tiefen-total.at(d - 1),
                                index: 0, count: 0, title: none))
  for (i, s) in all.enumerate() {
    if s.kind == "slide" { gezaehlt += 1 }
    if s.kind == "section" {
      let e = ebenen-satz.at(gesehen)
      gesehen += 1
      // The level itself takes its new entry; everything below it is
      // cleared, because no section of that depth is running under the new
      // parent yet. `number` is the one thing that stays: it counts across
      // the deck and never goes back, so it also reads as progress.
      ebenen = ebenen.enumerate().map(((j, x)) =>
        if j == e.depth - 1 { e }
        else if j > e.depth - 1 { x + (index: 0, count: 0, title: none) }
        else { x })
    }
    facts.push((
      nr: i + 1,
      data: daten + (
        slide: (number: gezaehlt, total: total, numbered: s.kind == "slide"),
        // The section stays what it always was: the level directly above the
        // slide. At `slide-level: 2` that is the only level there is.
        // A deck without any structure level reads as one before its first
        // section, which is the answer this already gave there.
        section: if ebenen.len() > 0 {
          let innen = ebenen.last()
          (number: innen.number, total: innen.total, title: innen.title)
        } else { (number: 0, total: 0, title: none) },
        levels: ebenen,
        structure: schnitte,
        // `here` marks the one entry that *is* this slide, and only a section
        // slide can be one. Every other slide gets the list built once above.
        outline: if s.kind == "section" {
          gliederung.enumerate().map(((m, e)) => e + (here: m == gesehen - 1))
        } else { gliederung-still },
      ),
    ))
  }

  // The branch has to enclose the *whole* build, not just the output: in
  // paged mode the module `html` does not even exist, so an `html.elem` in the
  // dead branch would already be an error.
  // Der Vermerk am Deckende, für alle drei Zweige. Ohne ihn behielte
  // `deck-info` hinter dem Deck den Stand der letzten Folie, und was danach im
  // Dokument steht, läse ihn: ein `#bleed` hinter der schließenden Klammer von
  // `presentation` meldete sich mit "on slide 13" statt "outside the deck".
  //
  // Ein Vermerk und kein `none`: `info()` gibt hinter dem Deck weiter die
  // Zahlen der letzten Folie aus, wie sein Docstring es zusagt, und alles, was
  // `deck-info` liest, liest es unverändert weiter. Gelöscht wurde der Stand
  // hier einmal, und das kostete die Konvergenz (siehe `info()`).
  //
  // Er steht in jedem Zweig zuletzt, hinter allen Berichten, die selbst noch
  // lesen.
  let deck-ende = deck-info.update(
    x => if x == none { none } else { (..x, nach-deck: true) })
  context if target() != "html" and handout != false {
    let per = if handout == true { 2 } else { handout }
    assert(type(per) == int and per >= 1 and per <= 6,
           message: "typstage: handout takes true or 1 to 6 slides per page")
    theme-state.update(thema-hell)
    html-output.update(false)
    zaehler-je-dokument()
    papier-modus.update(pages)
    drift-modus.update(drift)
    // Auch der Handzettel misst unter `pages: "step"` nicht, und das gilt dem
    // Bündel. `bundle()` reicht `pages` an alle Ausgaben weiter, und die
    // Messung löst ihre Lesungen am nächstgelegenen gleichen Element des
    // *ganzen* Bündels auf -- auch an den Schrittseiten des Foliensatzes
    // daneben, die sich einen Lauf länger bewegen. Der Foliensatz selbst misst
    // dort nicht mehr (siehe den Zweig darunter), der Handzettel brach die
    // Konvergenz trotzdem. Gemessen mit `--input typstage-overflow=record`:
    // `geogebra` als Foliensatz mit Schritten und Handzettel in einem Bündel 3,
    // `geogebra-sprecher` 5 Warnungen, das kleinste Deck aus dem Zweig darunter
    // als `bundle(pages: "step", handout: …)` 3, mit oder ohne HTML; danach
    // keine. Die Einstellung `pages` des Handzettels selbst ist dabei nicht
    // schuld: mit `pages: "slide"` nur für ihn blieben es 3.
    //
    // Unterscheiden, ob ein Bündel ihn setzt, kann dieser Zweig nicht. Allein
    // wirkt `pages` im Handzettel aber nur auf die Schrittzahl einer
    // Kamerafahrt, er setzt keinen Schritt; hingeschrieben wird es dort also
    // über `bundle()`. Weiter misst im Bündel die HTML, sofern es eine hat.
    let ueberlauf-handzettel = if pages == "step" { "none" } else { overflow }
    handout-body(all, facts, style, geo, thema-hell, per,
                 thema: if wechselt { thema } else { none },
                 overflow: ueberlauf-handzettel)
    ueberlauf-bericht(ueberlauf-handzettel)
    cue-luecken-bericht()
    drift-bericht(drift)
    deck-ende
  } else if target() != "html" {
    // `flipped: false` ausdrücklich. Ein `#set page(flipped: true)` vor
    // `presentation` vertauschte sonst Breite und Höhe: die Seite stand
    // hochkant, 473,56 x 841,89pt, und die rechte Hälfte jeder Folie samt
    // Foliennummer lag außerhalb des Blattes, während der Browser, der die
    // Bühne aus `geo` zieht, alles zeigte.
    set page(width: geo.width, height: geo.height, margin: 0pt, flipped: false)
    theme-state.update(thema-hell)
    // Said out loud, not left to the default. `bundle()` writes several
    // documents from one compilation, and a state carries on from one into the
    // next: without this the slide deck and the handout of a bundle were still
    // being built as if they were the browser's, and every tracked element
    // stayed in `hide()` and was missing from the PDF. Measured on a bundle
    // with an `anim` and an `alternatives`, and the same for the handout above.
    html-output.update(false)
    zaehler-je-dokument()
    papier-modus.update(pages)
    drift-modus.update(drift)
    // Unter `pages: "step"` misst dieser Zweig den Überlauf nicht.
    //
    // Die Prüfung misst den Folienrumpf mit `measure`, und was darin etwas
    // nachschlägt, löst Typst am nächstgelegenen gleichen Element des
    // wirklichen Dokuments auf, nach dem Stand des *vorigen* Laufs. Solange
    // sich ein solches Element noch ändert, zieht die Messung einen Lauf später
    // nach. Die Schrittfassung kostet ihrerseits einen Lauf: die Seiten ab dem
    // zweiten Schritt entstehen erst im zweiten, und was dort liest, liest erst
    // im dritten an seinem Ort. Beides zusammen ist für ein Deck, das im Rumpf
    // etwas nachschlägt, ein Lauf zu viel. Gemessen mit
    // `--input typstage-overflow=record` und `pages: "step"`: `geogebra` 2,
    // `geogebra-sprecher` 3 und `tour` 3 Warnungen ("did not converge", "a
    // measured element did not stabilize", auf das `measure` der Prüfung
    // gezeigt), dieselben Decks mit einer Seite je Folie, als Handzettel oder
    // ohne Prüfung keine. Das kleinste Deck: zwei Folien mit je einem
    // `embed(bridge: …)`, einem `ggb-set` und einer `alternatives`.
    //
    // Nur auf der ersten Seite einer Folie zu messen genügt nicht, auch das
    // gemessen, am selben Deck und an den dreien: dieselben Warnungen. Der
    // Rückstand gehört der Messung selbst, nicht der Zahl der Seiten, auf denen
    // sie steht.
    //
    // Verloren geht nichts, was diese Seiten zeigen könnten. Ein Stück, das
    // noch nicht dran ist, behält seinen Platz (`hide` in `track`), jede
    // Schrittseite setzt also denselben Rumpf wie die eine Seite je Folie, und
    // einen Schritt nennt Papier ohnehin nicht. Gemessen an einer Folie mit
    // einem `anim` auf Schritt 3, das über den Rand ragt: eine Seite je Folie
    // legte einen Fund ab, die Schrittfassung denselben dreimal mit denselben
    // Zahlen. Weiter messen die Browserfassung, die dazu den Schritt nennt, die
    // Seite je Folie und der Handzettel.
    let ueberlauf-papier = if pages == "step" { "none" } else { overflow }
    // `pages: "step"` setzt jede Folie so oft, wie sie Schritte hat. Wie viele
    // das sind, liest die Schleife am Zeiger selbst ab: an der Marke
    // `typstage-papier-ende`, die hinter dem Rumpf der *ersten* Seite jeder
    // Folie steht (unten). Nur dort, denn stünde sie auf jeder Seite, wüchse
    // ihre Zahl mit der Seitenzahl. Und sie trägt die Nummer als Argument,
    // nicht aus einer Lesung: ihr Inhalt steht vom ersten Lauf an fest, und ihr
    // Ort bleibt derselbe, wenn davor Seiten hinzukommen.
    //
    // Vorher kam die Zahl aus `papier-zahlen.final()`, und das war ein Glied zu
    // viel. `slide-body` schreibt den Zustand aus dem Zeiger, den es liest; im
    // ersten Lauf ist `deck-info` leer und es schreibt nichts, im zweiten
    // schreibt es den Zeiger des ersten, und `final()` sieht ihn im dritten.
    // Erst dort vervielfachten sich die Seiten, im vierten lasen die neuen an
    // ihrem Ort, und der fünfte bestätigte. Fünf ist das Maximum. Gemessen mit
    // `typst compile --timings` (gezählt `iter (n)`): jedes der siebzehn
    // Beispieldecks brauchte unter `pages: "step"` genau fünf Läufe, schon zwei
    // Folien mit einem `anim` auf der ersten, und eine Lesung mehr kippte es:
    // mit einem `#context anim[#info().slide.number]` vor diesem `anim` meldete
    // Typst "did not converge", zwei Werte stimmten erst im Endstand. Jetzt
    // keine Meldung, in fünf Läufen. Mit der Marke vervielfachen sich die
    // Seiten im zweiten Lauf, nachgesehen mit einer Sonde, die je Lauf die
    // Seitenzahl ablegt: zwei Folien, eine mit `anim`, in den Läufen eins bis
    // drei vorher 2, 2 und 3 Seiten, jetzt 2, 3 und 3. Alle siebzehn Decks
    // brauchen nun unter `pages: "step"` vier Läufe und als Seite je Folie drei
    // statt vier (`tour` bleibt bei vier), mit Bild und Text jeder Seite wie
    // vorher.
    //
    // Gesucht wird nur hinter diesem `context`. Zwei `presentation` in einem
    // Dokument nummerieren ihre Folien beide ab 1, und mit dem Zustand bekam
    // jede die Zahl der letzten: gemessen an einer ersten Folie mit zwei `anim`
    // und einer zweiten ohne, als zwei Aufrufe, eine Seite statt drei. Jetzt
    // drei und eine.
    //
    // Dasselbe gilt in einem Bündel: die Dokumente danach tragen dieselben
    // Foliennummern, aber ihre Marken stehen hinter denen dieses Dokuments, und
    // gezählt wird die erste. Gemessen gegen `im-dokument` (Marken nur des
    // eigenen Dokuments, ohne `.after`), das zwei Aufrufe in einem Dokument
    // wieder zusammenwarf (sechs Seiten statt vier), und gegen beides
    // zugleich: drei `document()` mit zwei Schrittfassungen, `bundle(pages:
    // "step", handout: …)` und die siebzehn Beispieldecks als Bündel, mit
    // einer Seite je Folie wie Schritt für Schritt, gaben mit `.after` allein
    // dieselben Seiten in denselben Läufen, jede Ausgabe gleich der allein
    // gebauten.
    //
    // `papier-zahlen` bleibt, `info()` liest es auf Papier. Der Handzettel hat
    // diese Schleife nicht und deshalb auch keine Marke.
    context {
      let zahlen = (:)
      for m in query(std.selector(<typstage-papier-ende>).after(here())) {
        let schluessel = str(m.value)
        // Die erste Marke mit dieser Nummer gehört zu diesem Aufruf.
        if schluessel not in zahlen {
          zahlen.insert(schluessel,
            calc.max(1, step-cursor.at(m.location()).first()))
        }
      }

      let seiten = ()
      for (i, s) in all.enumerate() {
        let nr = facts.at(i).nr
        // Eine Folie, eine Seite: gesetzt wird der *letzte* Schritt, und das
        // ist genau der Endzustand, den das Handbuch verspricht -- eine
        // `alternatives` zeigt ihre letzte Fassung, ein `build` seine letzte
        // Stufe. Mit `none` stünden alle Fassungen übereinander.
        let n = zahlen.at(str(nr), default: 1)
        // Jeder Schritt eine Seite -- bis auf die, die eine Kamerafahrt für
        // sich belegt: auf Papier gibt es keine Kamera, ihre Seite stünde also
        // zweimal identisch da. Schritt 1 bleibt immer, das ist die Folie, wie
        // sie aufschlägt.
        let schritte = if pages != "step" { (n,) } else { range(1, n + 1) }
        for (j, k) in schritte.enumerate() {
          // Der Folienzähler nur auf der ersten Seite einer Folie: die
          // weiteren Seiten sind dieselbe Folie, nicht die nächste.
          // Eine Seite, die eine Kamerafahrt für sich belegt, bleibt leer --
          // auf Papier gibt es keine Kamera, sie stünde also zweimal identisch
          // da. Zwei schwache Umbrüche um nichts fallen zusammen, die Seite
          // entsteht gar nicht erst.
          //
          // Entschieden wird das *in* der Seite und nicht an der Seitenzahl:
          // hinge die Zahl der Seiten an der Kameraliste, liefe das Dokument
          // in eine Rückkopplung und konvergierte nicht.
          //
          // Unter `pages: "step"` klammert `zaehler-klammer` den Rumpf, damit
          // die Zähler darin auf jeder Seite einer Folie dieselben Nummern
          // geben. Nur dort: eine Seite je Folie und der Handzettel setzen jede
          // Folie einmal und bekommen nichts davon.
          let (zaehler-vor, zaehler-nach) = if pages == "step" {
            zaehler-klammer(nr, j)
          } else { (none, none) }
          // Und die Labels: ab der zweiten Seite einer Folie steht ein
          // Element, auf das ein Verweis zeigen kann, ohne sein Label, sonst
          // fände der Verweis es einmal je Schritt und bräche ab. Hier der
          // Rumpf selbst; was ein aufdeckendes Element in sich trägt, nimmt
          // `track` (siehe `ohne-verweislabel` in internal.typ).
          //
          // Der Inhalt eines `bleed` wird auf jeder Seite der Folie neu gesetzt
          // wie der Rumpf und braucht dasselbe: gemessen brach eine Abbildung
          // mit Label darin sonst mit "label `<abb>` occurs multiple times" ab.
          let s = if j == 0 or s.at("body", default: none) == none { s } else {
            s + (body: ohne-verweislabel(s.body)) + (
              if "bleed" in s { (bleed: ohne-verweislabel(s.bleed)) } else { (:) })
          }
          seiten.push((if j == 0 { slide-counter.step() } else { none })
                 + zaehler-vor
                 + deck-info.update(facts.at(i))
                 // Nothing is revealed on paper, but the cursor counts here
                 // too, so that `info().step.total` reports the same number in
                 // both outputs. It has to start over on every slide.
                 + step-cursor.update(0)
                 // Und die Basen der cue-Gruppen, aus demselben Grund.
                 + cue-basis.update(_ => (:))
                 + (if j == 0 { szene-gruppen.update(_ => (:)) })
                 // Das Buch der benannten `stagger`, aus demselben Grund wie
                 // die Szenen: eine Gruppe gehört zu *einer* Folie. Ohne das
                 // fand ein `stagger-layer` auf der nächsten Folie das Buch
                 // einer gleichnamigen Staffelung von hier und stellte sich
                 // still auf deren Schritt.
                 + (if j == 0 { stagger-gruppen.update(_ => (:)) })
                 + step-here.update(())
                 + sprite-number.update(none)
                 // Die Fußnoten zählen je Folie und nicht durch das Deck: auf
                 // einer Folie steht die Anmerkung neben ihrer Marke, und eine
                 // 17 neben der ersten Anmerkung einer Folie liest niemand als
                 // Verweis. Der Zähler wird deshalb je *Seite* zurückgesetzt,
                 // nicht je Folie -- bei `pages: "step"` setzt dieselbe Folie
                 // mehrere Seiten, und ohne den Rücksetzer stiegen ihre Marken
                 // von Seite zu Seite weiter.
                 + counter(footnote).update(0)
                 + (if wechselt { theme-state.update(thema(s)) } else { none })
                 + slide-body(s, style, geo, thema(s),
                              overflow: ueberlauf-papier,
                              schritt: k, nr: nr,
                              // Abschnitte auf ihrer Ebene, Folien eine
                              // darunter, die Titelfolie ganz oben. So
                              // haengen die Folien im Verzeichnis unter dem
                              // Abschnitt, zu dem sie gehoeren.
                              buchtiefe: if s.kind == "section" {
                                s.at("depth", default: 1)
                              } else if s.kind == "title" { 1 } else {
                                facts.at(i).data.at("levels", default: ()).len() + 1
                              })
                 + zaehler-nach
                 // Die Marke, an der die Schleife oben die Schrittzahl
                 // abliest: hinter dem ganzen Rumpf und damit hinter jedem
                 // Vorschub des Zeigers, und nur auf der ersten Seite.
                 + (if j == 0 { [#metadata(nr)<typstage-papier-ende>] }))
        }
      }
      seiten.join(pagebreak(weak: true))
    }
    ueberlauf-bericht(ueberlauf-papier)
    // Nicht unter `pages: "step"`. Dort setzt dieselbe Folie eine Seite je
    // Schritt, und jede Seite legt die Punkte ihrer cue-Gruppen erneut als Fund
    // ab -- der Folienzaehler steht nur auf der ersten Seite weiter, also
    // tragen alle Seiten einer Folie denselben Schluessel. Die Pruefung zaehlt
    // nach Folie und sah jede Ziffer so oft, wie die Folie Schritte hat: sie
    // meldete "gives a digit to two points on one slide", obwohl keine Ziffer
    // doppelt vergeben war. Gemessen brach damit jedes Deck ab, dessen
    // cue-Gruppe auf einer Folie mit mehr als einem Schritt steht -- darunter
    // zwei der mitgelieferten Beispiele.
    //
    // Und ihr `query` zaehlt Funde, deren Zahl an der Seitenzahl haengt, die
    // ihrerseits an den Schritten dieser Folie haengt. Dieselbe Rueckkopplung,
    // an der Typst nach fuenf Laeufen aufgibt.
    //
    // Verloren geht nichts, was hier zu holen waere: die Pruefung gilt dem
    // Saal -- eine Ziffer, hinter der kein Punkt steht, ruft im Vortrag nichts
    // auf --, und den fahren der Browserzweig und die gewoehnliche
    // Papierfassung, die beide weiter pruefen.
    if pages != "step" { cue-luecken-bericht() }
    drift-bericht(drift)
    deck-ende
  } else {
    html-output.update(true)
    zaehler-je-dokument()
    drift-modus.update(drift)
    theme-state.update(thema-hell)
    morph-index.update(())
    // Die drei anderen Bücher, die erst die Prüfungen am Deckende lesen, leert
    // die HTML ebenso. In einem Bündel stünde sonst darin, was die Dokumente
    // davor eingetragen haben. Gemessen an zwei HTML-Dokumenten per
    // `document()`: ein `camera(<ziel>)` im zweiten, dessen `pin` nur im
    // ersten stand, ging ohne die Meldung durch, die dasselbe Deck allein
    // abbricht; und ein gültiges `anim(at: "1-2", after: "dimmed")` im ersten
    // brach im zweiten ab, sobald dessen Marken im eigenen Dokument gesucht
    // werden (`im-dokument`), denn dort hat Folie 1 nur einen Schritt.
    dim-index.update(())
    kamera-index.update(())
    pin-index-buch.update(())
    let parts = ()
    let chrome-teile = ()
    for (i, s) in all.enumerate() {
      let hier = facts.at(i)
      let here = hier.data.slide.number
      // Footer and progress come as their own layer above the stage, not
      // into the slide. Otherwise they would leave along with it on
      // transition, while the next one's comes in: two bars would be seen
      // crossing instead of one growing. Title and section slides carry
      // none; their entry stays empty so the count matches the slides.
      //
      // This layer is written out at the *end* of the document, long after
      // the slides. What the chrome reads therefore has to be put back in
      // front of each of its frames, or all of them would draw the numbers of
      // the last slide.
      // Der Anteil dieser Folie am Ganzen, damit die Laufzeit die Leiste
      // ziehen kann, statt zwei fertige Bilder überzublenden.
      //
      // Auch Titel- und Abschnittsfolien tragen ihn, obwohl sie nicht
      // mitzählen. `slide.number` ist dort die letzte gezählte Folie davor --
      // also genau der Stand, der bis hierher erreicht ist, und auf dem
      // Deckblatt die Null. Die Leiste einfach stehenzulassen war falsch: wer
      // von Folie acht auf die Abschnittsfolie davor zurückgeht, sähe sonst
      // weiter den Stand von acht. Gemeldet aus einem echten Deck.
      let anteil = if hier.data.slide.total > 0 {
        str(here / hier.data.slide.total)
      }
      chrome-teile.push(html.elem("div",
        attrs: (class: "ts-chrome", ..if anteil != none { ("data-anteil": anteil) }),
        // Eine Folie mit `bleed` bekommt einen leeren Eintrag wie eine
        // Abschnittsfolie, aber mit ihrem Anteil: die Laufzeit nimmt die Leiste
        // an einem Eintrag ohne Kinder weg und führt ihren Stand trotzdem nach,
        // und die Einträge passen weiter nach Index zu den Folien.
        if s.kind == "slide" and "bleed" not in s {
          // The step is said out loud as well, even though the chrome prints
          // no step: chrome stands inside no reveal, so its step is the first
          // one. Without it the reading would hang off whatever the last
          // sprite of the last slide left standing, and that lengthens the
          // chain of things Typst has to settle for no gain. Measured on a
          // `bundle()`, where the chain then ran past five attempts and Typst
          // said "document did not converge".
          deck-info.update(hier)
          step-here.update(())
          sprite-number.update(none)
          html.frame(slide-chrome(geo, thema(s), fortschritt: false,
                                  laufzeile: not leerer-titel(s.title)))
        } else { [] }))
      parts.push({
        slide-counter.step()
        deck-info.update(hier)
        element-counter.update(0)
        step-cursor.update(0)
        // Und die Basen der cue-Gruppen: daran haengt, dass eine Gruppe zu
        // einer Folie gehoert.
        cue-basis.update(_ => (:))
        szene-gruppen.update(_ => (:))
        // Ebenso das Buch der benannten `stagger`. Ohne diese Zeile fand ein
        // `stagger-layer`, der einen Namen nur von der Folie davor nennt,
        // dessen Buch: statt der Meldung stand die Schicht auf einem fremden
        // Schritt, und mit einem `#pause` vor jener Staffelung konvergierte
        // das Dokument nicht mehr -- gemessen vier Meldungen,
        // `state("typstage-sprites")` dreimal darunter.
        stagger-gruppen.update(_ => (:))
        step-here.update(())
        sprite-number.update(none)
        sprites.update(())
        // Neben `sprites`, aus demselben Grund: was `track` über die
        // Anmerkungen dieser Folie aufschreibt, gehört zu dieser Folie.
        notiz-schritte.update(_ => (:))
        bridge-jobs.update(())
        kamera-liste.update(())
        note-state.update(s.note)
        clock-state.update(none)
        transition-state.update(s.at("transition", default: none))
        // Only a deck that inverts somewhere writes this per slide. A `card`
        // and a `callout` read their tints out of this state and would
        // otherwise light the slide they stand on as if it were not inverted.
        if wechselt { theme-state.update(thema(s)) }
        // Order is everything here: the frame has to come BEFORE the `context`
        // that reads the sprite list. Otherwise nothing that only registers
        // while the frame is laid out would be entered any more.
        // Der Titel reist als Attribut mit. Die Uebersicht (Taste `o`) hatte
        // bis dahin nur Bilder und keine Namen: auf einem Deck mit dreissig
        // Folien sucht man darin, statt zu finden. Das Standbild allein sagt
        // zu wenig, gerade wenn zwei Folien einander aehnlich sehen.
        //
        // `plain-text` und nicht der Inhalt: ein Attribut ist eine
        // Zeichenkette. Was an Auszeichnung darin steckt, faellt weg -- fuer
        // eine Zeile unter einem Standbild ist das gerade recht.
        let name = if s.at("title", default: none) != none {
          plain-text(s.title).trim()
        } else { "" }
        html.elem("section", attrs: (class: "ts-slide")
                    + (if name != "" { (data-titel: name) } else { (:) }), {
          html.elem("div", attrs: (class: "ts-bg"), {
            counter(footnote).update(0)
            html.frame(slide-body(s, style, geo, thema(s), chrome: false,
                                  overflow: overflow, nr: hier.nr))
          })
          // Second chrome, only for the browser's own print view. There each
          // slide stands on its own page, there is no transition. And the
          // layer above the stage cannot travel along there, because the
          // slides stand one below another. On screen this one stays
          // hidden.
          //
          // Keins auf einer Folie mit `bleed`, wie auf der Bühne.
          if s.kind == "slide" and "bleed" not in s {
            html.elem("div", attrs: (class: "ts-chromep"), {
              step-here.update(())
              sprite-number.update(none)
              html.frame(slide-chrome(geo, thema(s),
                                      laufzeile: not leerer-titel(s.title)))
            })
          }
          context {
            let tr = transition-state.get()
            let note = plain-text(note-state.get()).trim()
            let geplante-uhr = clock-state.get()
            html.elem("div", attrs: (class: "ts-ov")
              + (if tr != none {
                   ("data-transition": if type(tr) == str { tr } else { json.encode(tr) })
                 } else { (:) })
              + (if note != "" { ("data-note": note) } else { (:) })
              + (if geplante-uhr != none { ("data-clock": str(geplante-uhr)) }
                 else { (:) }),
              // `ov`: der Ort dieser Schicht ist das Ende des Hintergrunds, an
              // dem die Sprites ihre Zähler ausrichten. `std.here()`, weil
              // `here` oben die Nummer der Folie ist.
              sprites.get().enumerate()
                .map(((i, sp)) => sprite-markup(sp, i + 1, style,
                                                ov: std.here())).join()
              // Direkt hinter der Sprite-Schleife und aus derselben Abfrage,
              // aus der `slide-body` seine Schlitze gestanzt hat. Nur eine
              // Folie mit einem Rumpf hat einen Fuß: eine Titel- oder
              // Abschnittsfolie zeichnet das Theme selbst und stanzt nichts,
              // ein Sprite fände dort keine Marke.
              + (if s.kind != "title" and s.kind != "section" {
                  notiz-sprites(hier.nr, thema(s), geo)
                } else { [] }))
            // For the check at the end of the document, note which morphs
            // sit on this slide and whether they stand from step one.
            // Evaluate first, then record: inside the update function
            // `sprites.get()` would be outside any context and Typst aborts.
            //
            // Ein Eintrag je Name und nicht je Morph, und ohne den Schritt:
            // nur Folie, Name und der Ort dieses `context`. Die Schritte liest
            // erst die Prüfung am Deckende, dort an diesem Ort (`sprites.at`),
            // und eine Lesung dort fließt in nichts, was gesetzt wird.
            //
            // Im Zustand hing der Wert am Schritt jedes einzelnen Morphs. Die
            // Fassungen von `alternatives(morph:)` und die Stücke von
            // `stagger(morph:)` holen ihren Schritt bei `at: auto` aus dem
            // Zeiger, und dort, wo er noch nicht feststeht, lasen alle drei
            // Fassungen einer Folie ohne Schritt davor einige Läufe lang "3",
            // "3" und "3-" statt "1", "2" und "3-". Je Morph kippte damit der
            // erste Eintrag von `false` auf `true`, einen Lauf nach allen
            // anderen: gemessen im gewöhnlichen `bundle()` mit nichts als
            // `alternatives(morph: true, …)` zwei Meldungen "value of
            // `state("typstage-morphs")` did not converge", mit einem Namen
            // ebenso, mit `stagger(morph: true)` schon vorher.
            //
            // Ein Eintrag je Name mit der Frage "stehen *alle* ab Schritt
            // eins" hielt das Bündel still, weil die zweite Fassung nie auf
            // Schritt eins steht, nahm der Prüfung aber die andere Frage, die
            // sie für eine Kette braucht: "steht *einer* ab Schritt eins". Mit
            // beiden gemessen: eine Kette über den Folienrand
            // (`stagger(morph: "k")` auf zwei Folien, ebenso mit
            // `alternatives`) und das Handbuchbeispiel `morph(<sq>, at: "1")`
            // mit `morph(<sq>, at: "2-")` brachen ab, "starts after step one".
            // Beide Fragen als Werte im Zustand ("einer" kippt wie vorher je
            // Morph) gaben im Bündel wieder die zwei Meldungen, bei
            // `alternatives(morph: true)`, benannt, mit `pages: "step"`, mit
            // Text davor und als zweite Folie. Mit dem Ort: alle diese
            // Bündel still, die Ketten übersetzen, die Handbuchfolie auch, und
            // ein verzögerter Morph ohne ersten (`#anim[Davor]` vor der Kette,
            // `morph` hinter einer Abschnittsfolie) bricht weiter ab.
            let morphs = sprites.get().filter(sp => sp.kind == "morph")
            let meine-morphs = morphs.map(sp => sp.extra.name).dedup()
              .map(n => (slide: here, name: n, ort: std.here()))
            morph-index.update(a => a + meine-morphs)
            // The same for every element that wants to rest dimmed. Its
            // range is closed -- `anim` insists on that -- but a closed range
            // can still end with the slide, and then there is no step left to
            // be dim on.
            // `hier.nr`, nicht `here`: die Marke am Folienende trägt `nr`,
            // und das zählt jeden Eintrag mit, auch Titel- und
            // Abschnittsfolien. `here` ist die Nummer unter den Inhaltsfolien
            // allein. Sobald ein Deck eine Titelfolie hat, laufen die beiden
            // auseinander, und der Test unten befragte die falsche Folie nach
            // ihrer Schrittzahl -- gemessen wurde ein gültiges Deck
            // abgewiesen, sobald man ihm einen Titel gab.
            let meine-dims = sprites.get()
              .filter(sp => sp.extra.at("after", default: none) == "dimmed"
                            and not sp.at("dim-freiwillig", default: false))
              .map(sp => (slide: hier.nr, nummer: here, bis: max-step(sp.at)))
            dim-index.update(a => a + meine-dims)
            html.elem("script", attrs: (class: "ts-bridge", type: "application/json"),
                      json.encode(bridge-jobs.get()))
            // Die Fahrten dieser Folie. Ein eigenes Skript und nicht das der
            // Bruecke daneben: eine Kamerafahrt geht keine Bruecke.
            //
            // Und nur, wenn es welche gibt. Die Bruecke schreibt ihr leeres
            // `[]` auf jede Folie, weil sie es immer schon tat; eine neue
            // Marke auf jeder Folie jedes Decks waere dagegen eine Aenderung
            // an Decks, die von einer Kamera nichts wissen wollen. So sieht
            // ein Deck ohne Kamera aus wie eines von gestern, Byte fuer Byte.
            if kamera-liste.get().len() > 0 {
              html.elem("script", attrs: (class: "ts-camera", type: "application/json"),
                        json.encode(kamera-liste.get()))
            }
          }
        })
      })
    }

    let links = asset-links(assets)
    if assets == "inline" { html.elem("style", runtime-css) } else { links.css }
    html.elem("div", attrs: (id: "ts-stage"), {
      parts.join()
      html.elem("div", attrs: (id: "ts-chrome"), chrome-teile.join())
      // Die Leiste selbst: ein Element für das ganze Deck, das seine Breite
      // ändert. Das Theme sagt Farbe, Höhe und Lage; ob es überhaupt eine
      // gibt, entscheidet es ebenfalls -- `fortschritt-stil` gibt `none`
      // zurück, wo kein Balken gezeichnet wird, und dann steht hier nichts.
      {
        // Ein Deck ohne eine einzige Folie gibt es: das Handbuch zeigt
        // `presentation()` an drei Stellen mit leerem Rumpf. `all.first()`
        // warf dort "array is empty" und hielt den ganzen Bau an.
        let fs = if all.len() > 0 { fortschritt-stil(geo, thema(all.first())) }
        // Die Höhe als Anteil der Bühne, nicht in `pt`. `fs.hoehe` ist in
        // Punkten der *Folie* gemessen, und ein Folienpunkt ist im Browser so
        // groß, wie die Bühne es gerade macht; ein CSS-`pt` dagegen ist immer
        // 4/3 Pixel. Die Leiste stand darum als einziges Stück Zier fest da,
        // während alles um sie mitwuchs: bei 1600 px Bühnenbreite 3,33 px hoch
        // statt der 4,75 px, die das PDF in derselben Breite zeigt, bei
        // 1920 px 3,33 statt 5,7, am Telefon dreimal so dick wie auf Papier.
        // Mit Prozent der Bühnenhöhe (`#ts-stage` trägt sie ausdrücklich, aus
        // `fit()`) steht sie in jedem Fenster im Verhältnis des PDF.
        if fs != none {
          html.elem("div", attrs: (
            id: "ts-fortschritt",
            style: "height:"
                 + str(calc.round(fs.hoehe / geo.height * 100, digits: 4)) + "%;"
                 + "background:" + fs.farbe.to-hex() + ";"
                 + (if fs.oben { "top:0" } else { "bottom:0" })
                 // Grows from the edge the writing starts at. The stylesheet
                 // pins the origin to the left; a deck that reads from the
                 // right moves it here, inline, where it beats the sheet.
                 + (if von-rechts() { ";transform-origin:100% 50%" } else { "" }),
          ), [])
        }
      }
      html.elem("div", attrs: (id: "ts-fly"), [])
      // The ink layer, empty. Like the chrome layer it sits above the stage
      // and does not travel along on a slide change: what gets drawn on the
      // slide does not belong to the slide. It is filled at runtime, from
      // the speaker view.
      html.elem("div", attrs: (id: "ts-ink"), [])
    })
    // Die Vollbilduhr. Leer und ausserhalb der Buehne, weil sie die Buehne
    // nicht zeigt, sondern ersetzt -- wie `b schwarz`, nur dass hier etwas
    // an ihre Stelle tritt. Die Laufzeit fuellt die beiden Kaesten; auf
    // Papier steht die Schicht nicht (siehe `@media print`).
    html.elem("div", attrs: (id: "ts-clock"), {
      html.elem("div", attrs: (class: "ts-clock-word"), [])
      html.elem("div", attrs: (class: "ts-clock-num"), [])
    })
    // Die Klänge. Sie stehen im Chrom und nicht in einer Folie, und zwar aus
    // drei Gründen: durch `track` wäre ein Ton eine Marke ohne Fläche und
    // liefe in den dokumentierten Fehlerfall; auf einer Folie hinge er an
    // deren Schritten, obwohl er zu keinem gehört; und auf Papier gäbe es
    // etwas zu unterdrücken, das dort gar nicht hingehört. So ist der Ton
    // ein Gerät des Raums, wie die Uhr daneben.
    //
    // `preload="auto"`: wer die Taste drückt, will den Ton jetzt und nicht
    // nach dem Laden. Eine Airhorn-Datei ist klein.
    if room.at("clock", default: (:)).at("sound", default: none) != none {
      html.elem("audio", attrs: (
        id: "ts-clock-sound", src: room.clock.sound, preload: "auto",
      ), [])
    }
    if "sounds" in room {
      for (taste, datei) in room.sounds.pairs() {
        html.elem("audio", attrs: (
          class: "ts-sound", "data-key": taste,
          src: datei, preload: "auto",
        ), [])
      }
    }
    // A delayed morph is not yet present on the first step of its slide.
    // That is harmless as long as the slide before it does not carry a morph
    // of the same name. Otherwise the flight between the two is lost, and
    // silently: there is no error message, the formula simply appears
    // instead of flying. Hence an announcement here at compile time.
    // An element that asked to rest dimmed but whose range ends with the
    // slide never dims, and without this it would say nothing at all -- the
    // author would get exactly `at: "1-"` and no hint why.
    context {
      for d in dim-index.get() {
        // Die Marke dieses Dokuments: jedes Dokument eines Bündels trägt
        // dieselben Foliennummern.
        let ende = query(im-dokument(<typstage-slide-end>)).find(e => e.value == d.slide)
        let gesamt = if ende == none { 1 } else {
          calc.max(1, step-cursor.at(ende.location()).first())
        }
        assert(d.bis < gesamt, message:
          "typstage: anim(after: \"dimmed\") on slide " + str(d.nummer)
          + " has a range that ends with the slide: it runs to step "
          + str(d.bis) + " and the slide has " + str(gesamt)
          + ". There is no step left for the element to be dim on, so it "
          + "would behave exactly like the default and nothing would say so. "
          + "Give the slide a further step, or drop the after.")
      }
    }

    context {
      let alle-morphs = morph-index.get()
      for m in alle-morphs {
        // Die Morphs dieses Namens auf dieser Folie, am Ort gelesen, an dem
        // die Folie sie eingetragen hat (siehe `meine-morphs`).
        let eigene = sprites.at(m.ort).filter(sp => sp.kind == "morph"
                                                    and sp.extra.name == m.name)
        if eigene.all(sp => ab-schritt-eins(sp.at)) { continue }
        let vorher = alle-morphs.filter(v => v.slide == m.slide - 1 and v.name == m.name)
        // Gefragt ist der Name auf dieser Folie, nicht das einzelne Stück.
        // Eine Kette -- `stagger(morph: "k")`, `alternatives(morph: "k")` --
        // besteht aus mehreren Morphs desselben Namens, und alle bis auf das
        // erste beginnen nach Schritt eins. Steht eines davon ab Schritt eins,
        // hat der Flug über den Folienrand sein Ziel, und die späteren fliegen
        // auf ihrer Folie weiter. Gemessen brach genau der Gebrauch ab, den
        // das Handbuch für einen eigenen Namen nennt: `[$u$][$u v$]` und auf
        // der nächsten Folie `[$u v$][$u v w$]` meldete "morph(k) on slide 2
        // starts after step one", mit `alternatives` ebenso. Dass die Laufzeit
        // die späteren Stücke beim Folienwechsel nicht mitfliegen lässt,
        // regelt `flugFolie`.
        let erster-da = eigene.any(sp => ab-schritt-eins(sp.at))
        assert(erster-da or vorher.len() == 0, message:
          "typstage: morph(" + m.name + ") on slide " + str(m.slide)
          + " starts after step one, but the slide before carries a morph of "
          + "the same name. The flight between them would be lost without a "
          + "word. Either drop the `at:` here, or rename one of the two.")
      }
    }

    // Und dieselbe spaete Frage an die Kameras: zielt jede auf ein `pin`, das
    // es auf ihrer Folie wirklich gibt? Frueher laesst sie sich nicht stellen.
    // Eine Fahrt darf vor ihrem Ziel stehen -- oft gehoert sie an den Kopf der
    // Folie --, und was auf einer Folie steht, ist erst gesetzt, wenn sie
    // gesetzt ist. Ohne die Frage faende ein Tippfehler im Namen erst im
    // Browser jemand, und dort als eine Kamera, die schlicht stehenbleibt.
    context {
      let pins = pin-index-buch.get()
      for k in kamera-index.get() {
        assert(pins.any(p => p.slide == k.slide and p.name == k.name), message:
          "typstage: camera(" + k.name + ") on slide " + str(k.slide)
          + " finds no pin of that name on its own slide. A camera aims at a "
          + "pin() and looks its rectangle up while the talk runs, so the "
          + "name has to stand on the same slide: #pin(<" + k.name + ">, …). "
          + "A pin on the slide before is a different piece of paper.")
      }
    }

    // Read back at the end of the deck, not at the first finding: whoever runs
    // the check before a talk wants the whole list in one go.
    ueberlauf-bericht(overflow)
    cue-luecken-bericht()
    drift-bericht(drift)

    html.elem("div", attrs: (id: "ts-overview"), [])
    html.elem("div", attrs: (id: "ts-hint"), [])
    // The container of the speaker view, empty. The same file carries both
    // views; which one applies is decided by `#speaker` in the address, and
    // the runtime covers the stage with it.
    html.elem("div", attrs: (id: "ts-speaker"), [])
    let worte = runtime-words(text.lang)
    html.elem("script", attrs: (id: "ts-cfg", type: "application/json"),
      // `json.encode` und nicht `str`: Typsts `str(-5)` schreibt U+2212 MINUS
      // SIGN, kein ASCII-Minus. Das ist kein gueltiges JSON, und `JSON.parse`
      // steht als erste Anweisung der Laufzeit -- eine einzige negative Zahl
      // hier hat frueher die ganze Datei stumm gemacht: Folien im DOM, aber
      // kein `window.typstage`. Nachgemessen am Byte: e2 88 92.
      "{\"duration\":" + json.encode(duration)
        + ",\"transition\":" + (if type(transition) == str {
            json.encode((kind: transition))
          } else { json.encode(transition) })
        + ",\"transitionDuration\":" + json.encode(transition-duration)
        + ",\"width\":" + json.encode(geo.width.pt())
        + ",\"height\":" + json.encode(geo.height.pt())
        // Die Signalfarbe, das einzige Stueck Palette, das die Laufzeit
        // kennt. Die Ueberzeit der Vollbilduhr steht darin, und sie soll
        // dem Deck gehoeren und nicht dem Stilblatt. Immer die helle Form:
        // die Uhr steht auf Schwarz, egal was die Folie darunter tut, und
        // `invert-palette` traegt den Akzent ohnehin unveraendert weiter.
        + ",\"accent\":" + json.encode(rgb(thema-hell.accent).to-hex())
        // Was die Sprecheransicht zeigt. Farben werden hier zu Hex-Zeichen-
        // ketten: die Laufzeit kennt keine Typst-Farben, und `json.encode`
        // einer Farbe waere ein Wort, mit dem der Browser nichts anfaengt.
        + ",\"speakerView\":" + json.encode(
            speaker-view.pairs().map(((k, v)) => (
              k,
              if k == "pen" and "colors" in v {
                (colors: v.colors.map(f => rgb(f).to-hex()))
              } else { v },
            )).to-dict())
        // The runtime displays two sentences itself. Which language is
        // decided by the slide's `text.lang`, not the runtime, which does
        // not know the document. English is the fallback.
        // Was der Saal sieht. Flach und in Sekunden: die Laufzeit kennt
        // keine Typst-Dauer, und ein verschachteltes Dictionary waere dort
        // nur eine zweite Stelle, an der ein fehlender Schluessel auffangen
        // werden muesste.
        + ",\"room\":" + json.encode((
            clockStep: if "clock" in room and "step" in room.clock {
              let s = room.clock.step
              if type(s) == duration { s.seconds() } else { s }
            } else { 1 },
            clockKeys: if "clock" in room and "digits" in room.clock {
              room.clock.digits
            } else { true },
            bell: room.at("bell", default: none),
            // Der Punkt. `false` kommt als `false` an, ein Woerterbuch als
            // die zwei Zeichenketten, die das Stilblatt als eigene
            // Eigenschaften setzt -- die Laufzeit kennt weder Typst-Farben
            // noch Typst-Anteile.
            pointer: {
              let z = room.at("pointer", default: true)
              if z == false { false } else if type(z) == dictionary {
                (
                  color: if "color" in z { rgb(z.color).to-hex() } else { none },
                  size: if "size" in z { repr(z.size) } else { none },
                )
              } else { true }
            },
          ))
        + ",\"words\":" + json.encode((
            noNote: worte.no-note,
            help: worte.help,
            helpSpeaker: worte.help-speaker,
            helpSpeakerShort: worte.help-speaker-short,
            sp: worte.sp,
          )) + "}")
    if assets == "inline" { html.elem("script", runtime-js) } else { links.js }
    deck-ende
  }
}

/// All outputs in one run.
///
/// Since 0.15 Typst can write several files from one compilation. That fits
/// this package, since everything sits in one source anyway: the talk, the
/// slide deck and the handout differ only in target and in one setting.
/// Instead of compiling three times, once:
///
/// ```sh
/// typst compile --features bundle,html --format bundle talk.typ output
/// ```
///
/// ```typ
/// #bundle(
///   theme: themes.lesson,
///   title: [Completing the Square],
///   handout: "handout.pdf",
/// )[
///   = A section
///   == A slide
///   Text.
/// ]
/// ```
///
/// `html`, `slides` and `handout` are file names; `none` leaves out that
/// output. `per-sheet` is the number of slides per handout page. Everything
/// else goes to `presentation` unchanged.
///
/// Two things worth knowing. The bundle is explicitly experimental in Typst.
/// And a file that uses `bundle` can *only* be compiled with `--format
/// bundle`: `typst compile talk.typ talk.pdf` aborts with "constructing a
/// document is only supported in the bundle target". Anyone who wants both
/// writes the body into a `#let` and calls `presentation` by hand.
///
/// What the package looks up stays in its own output, even though Typst runs
/// introspection across the whole bundle. The counters start over for each
/// output -- slides, figures, equations, headings and a deck's own `counter`
/// --, and a link such as an entry of `contents()` leads into its own file.
/// Measured on all seventeen example decks as bundles, with a page per slide
/// and step by step, with and without the HTML: every page, every link and the
/// HTML byte for byte as when that output is built alone. Two things Typst
/// keeps across the whole bundle, out of the package's reach. A deck's own
/// `state` has no value to start over from and carries on from one output into
/// the next, so a running number belongs in a `counter`. And a label stands
/// once in every output: `@fig` stops the bundle with "label occurs multiple
/// times in the document" where the deck alone compiles, and an
/// `outline(target: figure)` lists the figures of all outputs, six entries for
/// two figures.
///
/// With `pages: "step"` there is one limit more. Where a reveal sits in a
/// version of `alternatives` or a stage of `build` and another slide follows --
/// `#alternatives([A], [#anim[x]])` --, the bundle warns that it does not
/// converge, and in the HTML the `x` never comes. Such a deck builds its HTML on
/// its own, with `html: none` in the bundle.
#let bundle(
  body,
  html: "talk.html",
  slides: "slides.pdf",
  handout: none,
  per-sheet: 3,
  ..args,
) = {
  assert(html != none or slides != none or handout != none,
         message: "typstage: bundle() wants at least one output")
  // Die HTML hinter den Papierfassungen, außer wenn der Foliensatz Schritt
  // für Schritt kommt. Die Ursache liegt bei Typst: `measure` sucht zu einem
  // gemessenen Element das nächste gleiche *hinter* der Messung, erkennt
  // "gleich" am Quelltext und sucht im ganzen Bündel. Was hinter einer Ausgabe
  // steht, kann ihren Messungen Gegenstücke liefern, die es allein nicht gibt.
  //
  // Mit der HTML vorn traf das die HTML: ein verfolgtes Element in einer
  // Fassung von `alternatives` oder einer Stufe von `build` mit einer Folie
  // dahinter -- `#alternatives([A], [#anim[x]])` -- gab elf Meldungen, und im
  // HTML stand x auf `data-at="0-"`, fand im Browser keine Marke und blieb
  // unsichtbar; ebenso eine `cue-layer` hinter `#pause` (auf `1-` statt `4-`).
  // Mit der HTML hinten: keine Meldung, jede Ausgabe wie allein. Die 34
  // Beispielbündel (elf `bundle()`, sechs von Hand, je mit einer Seite je
  // Folie und Schritt für Schritt): mit einer Seite je Folie keine Meldung
  // mehr, wo es vorher `theme-lesson` 4, `tour` 8 und `zeichnen` 3 waren, jede
  // Ausgabe wie allein gebaut.
  //
  // Schritt für Schritt aber wandert derselbe Fehler in den Foliensatz: mit
  // der HTML hinten wichen die Schrittseiten jener Decks von den allein
  // gebauten ab, mit drei bis vierzehn Meldungen, während die HTML stimmte.
  // Dort bleibt die HTML vorn, wie bisher; ohne Foliensatz gibt es keine
  // Schrittseiten, und die HTML geht nach hinten.
  //
  // Die HTML hinten braucht `auto-morph-nr` als Zähler, den
  // `zaehler-je-dokument` zurückstellt: als Zustand zählte er die Morphs der
  // Papierfassungen mit, und die HTML von `tour` wich im Bündel ohne Meldung
  // von der allein gebauten ab.
  let schrittseiten = (slides != none
                       and args.named().at("pages", default: none) == "step")
  if html != none and schrittseiten {
    document(html, { show: presentation.with(..args); body })
  }
  if slides != none {
    document(slides, { show: presentation.with(..args); body })
  }
  if handout != none {
    document(handout, { show: presentation.with(handout: per-sheet, ..args); body })
  }
  if html != none and not schrittseiten {
    document(html, { show: presentation.with(..args); body })
  }
}
