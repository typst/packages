// Appearing, moving and staggering.

#import "internal.typ": (auto-morph-nr, cue-basis, deck-info,
                        papier-modus, papier-schritt,
                        drift-ausweg, drift-modus,
                        drift-satz, drift-toleranz, durchsichtig,
                        fit-meldung, fit-verbot, html-output, im-deck,
                        im-fit, kamera-index, kamera-liste, kurve, max-step,
                        name-of, offenes-ende, pin-index, pin-index-buch,
                        pin-marker, platz-pruefen, selector, step-cursor,
                        stagger-gruppen, szene-gruppen, track,
                        will-fuellen)

/// What `anim` does once its arguments have been checked.
///
/// Split out for `stagger`, and for one reason: `dim-freiwillig`. An element
/// written by hand with `after: "dimmed"` whose range ends with the slide is a
/// mistake -- it would rest dim on a step that never comes -- and the check at
/// the end of the document says so. A `stagger(dim: true)` produces exactly
/// that shape for its *last* point on purpose: the point being talked about
/// stays bright, and dims only if the deck goes on. So its points say they may
/// end with the slide, and the late check leaves them alone. The flag rides in
/// the sprite record rather than in `extra`, which becomes markup attributes.
#let anim-kern(body, at: auto, enter: "fade-up", exit: "fade",
               after: "hidden", duration: auto, delay: 0, easing: none,
               dim-freiwillig: false, ad: none, ad-nr: none, boden: 2,
               offen: true, vorruecken: 1) = track(
  "anim", body, at: at, dim-freiwillig: dim-freiwillig, boden: boden,
  offen: offen, vorruecken: vorruecken, extra: (
    // Membership in an adaptive group. `none` never travels into the markup,
    // so an ordinary element gains no new attribute.
    ad: ad, "ad-nr": ad-nr,
    enter: enter, exit: exit, delay: delay,
    duration: if duration == auto { none } else { duration },
    // Die fertige Kurve, nicht ihr Name: aufgelöst hat sie `kurve()` schon,
    // und `none` schreibt kein Attribut. Ein Deck ohne `easing:` sieht danach
    // aus wie eines von gestern, Byte für Byte.
    easing: easing,
    // Only the departure from the default travels into the markup. `hidden`
    // is what every sprite has always done after its range, and writing it
    // out would put a new attribute on every element of every deck.
    after: if after == "dimmed" { after } else { none },
  ))

/// Reveal content on particular steps.
///
/// `at` is a step selector. `auto`, the default, takes the next free step,
/// so consecutive `anim`s reveal one after another without any numbering.
/// Otherwise: `2` (from step two on), `"1-2"`, `(2, 4)`, `"3"`. An explicit
/// number also moves the cursor along, so a following `auto` carries on after
/// it instead of starting over.
///
/// `enter` applies in both directions: paging back plays the same effect in
/// reverse, taking the entrance back. `exit` only concerns a real departure,
/// when an element falls out of its range while moving forward.
///
/// `after` says what the element does once its range is behind it, and it has
/// two values.
///
/// - `"hidden"`, the default and what an `anim` has always done: it goes,
///   playing `exit`, and keeps the room it had.
/// - `"dimmed"`: it stays and is drawn muted, so a point remains legible
///   after the talk has moved on. Nothing moves and nothing is recoloured;
///   the element settles to 65 percent opacity, and paging back brings it up
///   again. That number is measured, and the manual says against what.
///
/// On paper `after` does nothing at all. A page shows every step at once, and
/// a point that is only quiet because the talk has moved past it has no
/// "past" on a handout. This is the same rule that already holds for
/// `"hidden"`: what leaves its range in the browser is still printed.
///
/// `after` needs a range that ends. `at: auto` and `at: 3` run to the end of
/// the slide, and an element that never leaves has no after; the package says
/// so instead of doing nothing. `at: "3"` is that one step, `at: "2-3"` a
/// range.
///
/// Under `prefers-reduced-motion: reduce` every effect keeps its opacity and
/// loses its travel, so `enter` and `exit` become a plain cross-fade of the
/// same length. `after: "dimmed"` is unaffected: it changes opacity and
/// nothing else. See the manual.
///
/// `easing` is the curve the element moves on -- for the entrance, the
/// departure and the dimming alike. `auto` is the package's own curve;
/// `"out-back"` overshoots and swings back, `"linear"` arrives at an even
/// pace. A name that does not exist is an error at compile time and not a
/// silent default.
#let anim(
  body,
  at: auto,
  enter: "fade-up",
  exit: "fade",
  after: "hidden",
  duration: auto,
  delay: 0,
  easing: auto,
) = {
  platz-pruefen(at, "at", "anim")
  assert(after in ("hidden", "dimmed"), message:
    "typstage: anim(after: ...) is \"hidden\" or \"dimmed\", not \""
    + str(after) + "\".")
  assert(after == "hidden" or (at != auto and not offenes-ende(selector(at))),
         message: "typstage: anim(after: \"dimmed\") wants a range that ends. "
    + "`at: auto` and `at: 3` run to the end of the slide, so there is no "
    + "after for the element to rest in. Write `at: \"3\"` for that one step "
    + "or `at: \"2-3\"` for a range.")
  anim-kern(body, at: at, enter: enter, exit: exit, after: after,
            duration: duration, delay: delay, easing: kurve(easing, "anim"))
}

/// Magic move: the same `name` twice, and the thing flies across.
///
/// Twice on two adjacent slides, or twice on one slide with `at:` selectors
/// that do not overlap. The runtime pairs the flights step by step as well as
/// slide by slide.
///
/// The name is a string or a label: `morph(<pythagoras>, …)`.
///
/// `duration` is 900 ms, not the duration of the presentation: a flight
/// across the slide takes more time than a simple fade-in, and in real decks
/// the default was overridden in 161 of 165 cases. `auto` falls back to the
/// presentation's duration.
///
/// `match` is `"auto"`, `"glyph"` (always per glyph) or `"block"` (always as
/// one rectangle).
///
/// Two names may be equal on the *target* slide. The runtime looks the source
/// up by name but iterates over the targets, so two targets sharing a name
/// both start from the same place and the glyph visibly splits in two.
/// `at` is almost always right as it is. A morph is present from the first
/// step on: a flight target must already be there when the slide is entered.
/// Because paging back swaps the roles, that holds for both ends.
///
/// Delaying is only worthwhile for the *first* link in a chain, for example
/// when the formula should appear together with its tile. It is allowed
/// exactly when the preceding slide carries no morph of the same name; the
/// package checks this at compile time and speaks up when it does not hold.
///
/// Under `prefers-reduced-motion: reduce` nothing flies. The slide changes the
/// way it would change without a morph. See the manual.
#let morph(name, body, at: "1-", duration: 900, match: "auto", inline: true) = {
  platz-pruefen(at, "at", "morph")
  track(
    "morph", body, at: at, inline: inline,
    // `fly`, not `duration`: this is the duration of the *flight*, and the
    // runtime used to read the same attribute for the fade-in too. A morph
    // with `at:` therefore faded in over 900ms while the card next to it
    // finished after 520ms: the same motion, visibly pulled apart.
    extra: (name: name-of(name), match: match,
            fly: if duration == auto { none } else { duration }),
  )
}

// Der Parameter `morph:` von `alternatives` verdeckt die Funktion gleichen
// Namens. Hier wird sie festgehalten, bevor das geschieht.
#let morph-fn = morph

/// Several versions of the same thing, each replacing the one before.
///
/// ```typ
/// #alternatives(
///   $ (a + b)^2 $,
///   $ (a + b)(a + b) $,
///   $ a^2 + 2 a b + b^2 $,
/// )
/// ```
///
/// `inline: true` keeps the whole thing in the running line, for versions of a
/// single word or formula.
///
/// They all stand in the same place, in a box as large as the largest of them,
/// so nothing around them jumps as they change. Each takes one step; the last
/// one stays for the rest of the slide.
///
/// `morph: true` lets the versions fly into one another instead of replacing
/// one another. They all stand in the same place, so the flight is no distance
/// at all and what you see is the glyphs rearranging themselves where they
/// stand -- which is what a rewritten formula does:
///
/// ```typ
/// #alternatives(morph: true,
///   $ (a + b)^2 $,
///   $ (a + b)(a + b) $,
///   $ a^2 + 2 a b + b^2 $,
/// )
/// ```
///
/// It works because the versions carry one name and step ranges that do not
/// overlap, and a morph flies from step to step as readily as from slide to
/// slide. A name of your own instead of `true` is allowed and is only needed
/// where the flight has to continue onto the next slide.
///
/// A morph has no entrance and no easing curve, so `enter:` and `easing:` are
/// refused rather than quietly dropped. `duration:` is read and is the time of
/// the flight.
///
/// On paper only the last one is set, in the same box, so the page keeps the
/// spacing of the slide. Printing all of them would pile them on top of one
/// another.
#let alternatives(
  ..variants,
  start: auto,
  align: top + std.start,
  enter: "fade",
  duration: auto,
  easing: auto,
  inline: false,
  morph: false,
) = {
  // `align` defaults to `std.start`, not `left`: the edge the writing begins
  // at, which is the right one in a deck that reads from the right. A deck
  // that never says `align:` gets the corner it always got. `std.`, because
  // `start` is the parameter one line up. Said here and not beside the
  // parameter: the manual's parser reads the signature character by
  // character, and a comma or colon in a comment there breaks the manual.
  // `..variants` would otherwise swallow any named argument without a word: a
  // typo in `start:` would leave the versions on the steps they happened to
  // land on, and nothing would say why.
  assert(variants.named().len() == 0,
         message: "typstage: alternatives() does not know "
                + variants.named().keys().join(", ")
                + ". It takes start, align, enter, duration, easing, inline "
                + "and morph.")
  assert(morph == false or morph == true or type(morph) == str
         or type(morph) == label, message:
    "typstage: alternatives(morph: …) is `true`, or a name of your own as a "
    + "string or a label. Not " + str(type(morph)) + ".")
  // Ein Morph blendet nicht ein, er fliegt. Wer `enter:` oder `easing:`
  // danebenschreibt, meint etwas, das es hier nicht gibt -- und stillschweigend
  // fallenzulassen, was jemand ausdrücklich hingeschrieben hat, ist die
  // Auskunft, die man am spätesten bekommt.
  assert(morph == false or (enter == "fade" and easing == auto), message:
    "typstage: alternatives(morph: …) has no entrance and no easing curve. "
    + "The versions fly into one another; `enter:` and `easing:` describe a "
    + "fade, which is what happens instead of a flight, not during one. "
    + "`duration:` is read, and it is the time of the flight.")
  let items = variants.pos()
  assert(items.len() > 0,
         message: "typstage: alternatives() wants at least one version")
  // Steps are one-based. A 0 would never hit: the first version would never
  // appear, and the last would be there from the start. This does not show
  // up as an error: the slide simply has one step fewer, and nothing says
  // why.
  assert(start == auto or (type(start) == int and start >= 1),
         message: "typstage: alternatives(start: …) counts from 1, not 0")
  // As with `morph`: `layout()` works block-wise and would break the line
  // the versions are sitting in. The wrapper must therefore lie around the
  // whole thing, not inside it.
  let shell-outer = if inline { box } else { it => it }
  // Vor dem Layout, damit die Nummer einmal je Aufruf hochzählt und nicht
  // einmal je Messdurchgang.
  if morph == true { auto-morph-nr.update(n => n + 1) }
  shell-outer(layout(available => context {
    // On paper `alternatives` never reaches `track`, it only moves the cursor,
    // so the fit check cannot be left to `track` here. Asked as an assertion
    // rather than by placing `fit-verbot`, because the paged branch below
    // leaves through a `return` and a `return` drops whatever was joined
    // before it.
    assert(im-fit.get() == 0, message: fit-meldung("alternatives"))
    // Measure twice, the larger one wins: the same trap as in `track`.
    // `height: 100%` in one version would otherwise collapse to zero, and
    // measuring only against the available height would clip any overflow.
    let natural = items.map(v => measure(v, width: available.width))
    let bounded = items.map(v => measure(v, width: available.width,
                                         height: available.height))
    let w = calc.max(..natural.map(s => s.width), ..bounded.map(s => s.width))
    let h = calc.max(..natural.map(s => s.height), ..bounded.map(s => s.height))
    let first = if start == auto { step-cursor.get().first() + 1 } else { start }
    if not html-output.get() {
      // Only the last version is set on paper, but the cursor moves as if all
      // of them stood there. Every version is one step, and
      // `info().step.total` has to report the same count in both outputs.
      return {
        // Kein eigener Vorschub mehr, wenn `track` die Schritte vergibt:
        // sonst hinge das Update am gelesenen `first` -- dieselbe Kette, die
        // im Browserzweig die Konvergenz kostete.
        if im-deck() and start != auto {
          step-cursor.update(c => calc.max(c, first + items.len() - 1))
        }
        // Jede Fassung als verfolgtes Element, wie im Browserzweig -- dann
        // entscheidet `track`, was auf dem gesetzten Schritt zu sehen ist, und
        // meldet den Halt. Selbst lesen kann `alternatives` den Schritt hier
        // nicht: die Lesung stünde in einem `layout`, und darin löst sie sich
        // erst am Dokumentende auf. Gemessen: auf allen drei Seiten der
        // Endwert. Übereinander liegen die Fassungen gefahrlos, weil die
        // unzutreffenden `hide` bekommen und nur ihren Platz behalten.
        let letzt = items.len() - 1
        block(width: w, height: h, {
          for (i, v) in items.enumerate() {
            place(align, anim-kern(
              v,
              at: if start == auto { auto } else {
                if i == letzt { str(first + i) + "-" } else { str(first + i) }
              },
              boden: 1, offen: i == letzt,
              enter: enter, duration: duration,
              easing: kurve(easing, "anim")))
          }
        })
      }
    }
    let last = items.len() - 1
    // Die Schritte von `track` vergeben lassen, statt sie aus dem gelesenen
    // Zeiger zu rechnen und hereinzureichen -- das kostet das Dokument sonst
    // seine Konvergenz, sobald eine Fassung etwas außerhalb des Flusses trägt.
    // `offen` nur für die letzte: jede andere tritt ab, wenn die nächste kommt.
    let auto-kette = start == auto and morph == false
    // Mit `morph:` traegt jede Fassung denselben Namen. Die Bereiche
    // ueberschneiden sich nicht, und damit ist jeder Schrittwechsel ein Flug
    // von der einen auf die naechste -- dieselbe Maschinerie wie ueber den
    // Folienrand hinweg, nur zwischen zwei Schritten einer Folie.
    //
    // Alle Fassungen liegen an derselben Stelle, die Flugstrecke ist also
    // null. Was man sieht, ist die Umordnung der Zeichen an Ort und Stelle --
    // fuer eine Formel, die sich umformt, genau das Richtige.
    let mname = if morph == true {
      "ts-alternatives-" + str(auto-morph-nr.get())
    } else if morph != false { name-of(morph) }
    block(width: w, height: h, {
      for (i, v) in items.enumerate() {
        // Exactly this step for all but the last, which stays: `"3"` is that
        // one step, `"3-"` is from there on.
        let at = if i == last { str(first + i) + "-" } else { str(first + i) }
        place(align, if morph == false {
          anim-kern(v, at: if auto-kette { auto } else { at },
                    boden: 1, offen: i == last,
                    enter: enter, duration: duration,
                    easing: kurve(easing, "anim"))
        } else {
          morph-fn(mname, v, at: at, duration: duration, inline: inline)
        })
      }
    })
  }))
}

/// A named piece inside a morph.
///
/// Shape matching pairs glyphs by their outline and, where that is not
/// enough, by proximity. Most of the time that is right. Where it is not,
/// because the 3 in `3x^4` is meant to become the 3 in `4 dot 3x^3` and
/// another 3 sits in between, the piece gets a name, and the pairing follows
/// that instead.
///
/// ```typ
/// #morph(<term>)[$#pin(<faktor>)[3] x^#pin(<hoch>)[4]$]
/// … and on the next slide …
/// #morph(<term>)[$#pin(<hoch>)[4] dot #pin(<faktor>)[3] x^3$]
/// ```
///
/// Matching names find each other before the shape is consulted; everything
/// else works as before. A pin with no counterpart on the other slide falls
/// back to shape matching without complaint.
///
/// The name is a string or a label.
#let pin(name, body) = {
  let n = name-of(name)
  // Der Name wird eingetragen, bevor er zur Zahl wird. `pin-marker` rechnet
  // ihn zu einem Farbwert und vergisst ihn dabei; ohne dieses Buch koennte am
  // Dokumentende niemand mehr sagen, welche Namen es auf welcher Folie gibt --
  // und eine Kamera, die auf einen Tippfehler zielt, faende erst im Browser
  // jemand. Die Eintragung zeichnet nichts und misst nichts, sie darf also
  // auch mitten in einer Formel stehen.
  context if im-deck() {
    // Erst ausrechnen, dann eintragen. Innerhalb der Funktion, die `update`
    // bekommt, ist kein Kontext mehr bekannt -- sie laeuft, wenn jemand den
    // Zustand liest, und nicht hier.
    let wo = deck-info.get().nr
    pin-index-buch.update(a => a + ((slide: wo, name: n),))
  }
  box(fill: pin-marker(pin-index(n)), body)
}

// ── Die Kamera ───────────────────────────────────────────────────────────────
//
// Typst gibt zur Uebersetzungszeit keine Geometrie heraus: `here().position()`
// liefert in der HTML-Ausgabe ueberall (0, 0), und genau deshalb arbeitet
// dieses Paket ueberhaupt mit Rechtecken in Signalfarbe. Die Laufzeit dagegen
// *muss* diese Rechtecke kennen -- sie legt ihre Sprites darueber. Eine Kamera
// kann sich daran anhaengen: sie zielt auf ein `pin`, schlaegt dessen Rechteck
// im Bild nach und rechnet sich aus, wohin sie zu fahren hat. Das Deck nennt
// einen Namen, keine Koordinate.
//
// Gefahren wird nicht die Folie, sondern ihre beiden Ebenen: der Hintergrund
// und die Sprite-Ebene darueber. Beide sind derselbe Kasten, beide bekommen
// dieselbe Verschiebung, also bleiben sie deckungsgleich -- und die Rechnung
// in `stelle()` bleibt unberuehrt, weil sie in Verhaeltnissen misst und eine
// gleichmaessige Streckung Verhaeltnisse nicht antastet. Die Folienzier, die
// Tinte und die Uebersicht liegen in eigenen Ebenen ueber der Buehne und
// fahren nicht mit; das ist keine Ruecksicht, sondern faellt aus dem Aufbau,
// den sie ohnehin schon haben.

/// Move in on one detail of the slide, and back out again.
///
/// ```typ
/// #pin(<detail>, card[The measuring head])
/// …
/// #camera(<detail>)
/// ```
///
/// The camera aims at a `pin`, and at nothing else. That is the package's
/// word for a named piece of a slide, its marker is exactly the rectangle the
/// runtime already measures, and it sits wherever content sits: around a
/// card, around a cell of a table, around one subterm of a formula. Nothing
/// has to be given in coordinates, and nothing has to be counted.
///
/// `at` is a step selector, as everywhere else, and the slide is seen through
/// the camera for exactly as long as it is active. That answers the way back
/// out with the notation that is already there: `at: "3"` moves in on step
/// three and back out on step four, `at: "3-5"` holds the crop across three
/// steps, `at: 3` keeps it to the end of the slide.
///
/// `auto`, the default, is the next free step *closed*: in on it, out on the
/// one after -- and never step one, because step one is the slide as it is
/// entered, and a camera there would mean nobody ever saw the slide whole. That differs from `anim`, where `auto` runs to the end of the
/// slide, and it differs on purpose. An entrance has no natural end -- what
/// has appeared stays. A camera move has one: one always comes back out, and
/// coming back out is a keypress like any other, so it is counted like one
/// and shows up in `info().step.total`.
///
/// `margin` is how much of the slide stays around the detail, measured in the
/// unzoomed slide. The camera fits the detail plus that margin into the
/// frame; the smaller of the two directions decides, so the whole of it is
/// seen.
///
/// A detail that is already as large as the slide gives nothing to travel to,
/// and then the slide stays whole.
///
/// Two pins of the same name on one slide are framed together, and the camera
/// shows the box around both.
///
/// If two camera moves are active on the same step, the later one in the
/// source wins.
///
/// On paper there is no camera. The slide is set whole, exactly as it would
/// be without one -- but the steps are counted there too, so the handout's
/// footer names the same number as the talk.
///
/// Under `prefers-reduced-motion: reduce` the camera jumps to the crop
/// instead of travelling to it. The package's rule everywhere else too: what
/// stays is the destination, what goes is the travel.
#let camera(target, at: auto, margin: 16pt, duration: 700, easing: auto) = {
  let name = name-of(target)
  assert(type(margin) == length, message:
    "typstage: camera(margin: …) is a length -- how much of the slide stays "
    + "around the detail. Not " + str(type(margin)) + ".")
  assert(type(duration) == int and duration > 0, message:
    "typstage: camera(duration: …) is the time of the move in milliseconds "
    + "and wants a number above zero. A move of no length is a jump, and a "
    + "jump is what reduced motion asks for, not what a deck writes.")
  let takt = kurve(easing, "camera")
  context {
    assert(im-fit.get() == 0, message: fit-meldung("camera"))
    // Der naechste freie Schritt, aber nie der erste. Schritt 1 ist die Folie,
    // wie sie betreten wird; eine Fahrt darauf hiesse, dass niemand die Folie
    // je ganz gesehen hat. Dieselbe Ueberlegung, aus der `anim` bei zwei
    // beginnt. Wer es trotzdem will, schreibt `at: "1"` hin.
    let sel = if at == auto {
      str(calc.max(step-cursor.get().first() + 1, 2))
    } else { selector(at) }
    // Der Rueckweg ist ein Schritt. Ein geschlossener Bereich braucht darum
    // einen Schritt *hinter* sich, auf dem die Folie wieder ganz dasteht --
    // und der Zeiger muss ihn kennen, sonst zaehlt das Handout einen weniger
    // als der Vortrag. Ein offener Bereich hat keinen Rueckweg: dort nimmt der
    // Folienwechsel die Kamera heraus.
    let letzter = max-step(sel) + (if offenes-ende(sel) { 0 } else { 1 })
    // Ausserhalb eines Decks gibt es weder einen Zeiger noch eine Folie, nach
    // deren Nummer sich fragen liesse. `pin` daneben fragt aus demselben Grund.
    // In der Schrittfassung auf Papier belegt eine Fahrt keinen Schritt: sie
    // zeigt dort nichts, und ihre Seite stünde sonst zweimal identisch da.
    if im-deck() and not (not html-output.get() and papier-modus.get() == "step") {
      // Wie bei `scene`: rein, solange der Schritt aus dem Zähler kommt.
      // `sel` ist dann `calc.max(c + 1, 2)` und der Halt danach eins mehr --
      // beides Funktionen von `c` allein.
      if at == auto {
        step-cursor.update(c => calc.max(c, calc.max(c + 1, 2) + 1))
      } else {
        step-cursor.update(c => calc.max(c, letzter))
      }
      // Erst ausrechnen, dann eintragen: in der Funktion, die `update`
      // bekommt, ist kein Kontext mehr bekannt.
      let wo = deck-info.get().nr
      kamera-index.update(a => a + ((slide: wo, name: name),))
    }
    // Auf Papier bleibt es beim Zaehlen. Es gibt dort keine Kamera, und die
    // Folie hat vollstaendig und lesbar dazustehen.
    if html-output.get() {
      let rand = margin.to-absolute() / 1pt
      kamera-liste.update(a => a + ((
        at: sel,
        // Die Zahl, nicht der Name: `pin-marker` legt genau diese Zahl in die
        // Ausgabe, und die Laufzeit muesste den Namen sonst ein zweites Mal
        // durch dieselbe Streuung drehen. Der Name faehrt trotzdem mit --
        // eine Meldung, die nur eine Zahl nennt, hilft niemandem.
        pin: pin-index(name),
        name: name,
        margin: rand,
        duration: duration,
        easing: takt,
      ),))
    }
  }
}

/// Everything after this appears a step later.
///
/// The short form for slides that simply unfold: no `anim` around anything,
/// no step numbers.
///
/// ```typ
/// == A slide
/// First this.
/// #pause
/// Then that.
/// ```
///
/// It is read at the top level of the slide body, `#set` and `#show` rules
/// included. Inside a grid cell, a table or a figure it is not seen: there
/// the content is a field of an element, not part of the body. Reach for
/// `anim` in those places instead.
#let pause = metadata("typstage-pause")

/// Reveal one after another: a list or several blocks.
///
/// Two notations, the same function:
///
/// ```typ
/// #stagger[
///   - this first
///   - then this
/// ]
/// #stagger(card[left], card[right])
/// ```
///
/// For a list, the bullet marks are set here rather than left to `list`:
/// only this way does the mark belong to the tracked element. If it stayed
/// with the list, it would sit in the background and be there before its
/// point appears.
///
/// `start` is `auto`: the sequence continues where the slide left off.
/// `stride: 0` makes everything appear on the same step and staggers only
/// through `stagger`, in milliseconds.
///
/// `dim: true` turns the sequence into a walk: the point being discussed
/// stands there, the ones before it stay legible but muted. Every point then
/// holds exactly its own step instead of the rest of the slide, and rests at
/// `anim`'s `after: "dimmed"` from the next step on. Paging back brings each
/// one up again.
///
/// Two things follow from that and are worth knowing before reaching for it.
/// The last point dims too as soon as the slide has a further step after it,
/// because then the walk has moved on from it as well. And `stride: 0`, which
/// puts every point on one step, makes them all dim together on the next.
/// A group that is revealed in whatever order it is called out.
///
/// For points that have no order of their own: what the class names gets
/// shown, in the order it comes rather than the order it stands in. The digits
/// `1` to `9` choose; the speaker view shows which digit belongs to which
/// point.
///
/// ```typ
/// #cue("ablesen", start: 2)[
///   - positive und negative Werte
///   - tiefster und höchster Wert
///   - Abnahme und Zunahme
/// ]
/// ```
///
/// The group owns as many steps as it has points, and the order changes
/// nothing about that. Everything that hangs on the step count -- the progress
/// bar, `info().step.total`, the overflow check, the handout -- is therefore
/// untouched.
///
/// Set, the list keeps its reading order: a point not yet named holds its
/// place, so nothing jumps when it arrives later.
#let cue(name, ..items, start: auto, spacing: 0.65em, nr: auto) = context {
  assert(type(name) == str and name != "", message:
    "typstage: cue() wants a name as its first argument, so that "
    + "cue-layer() can point at the same group.")
  assert(items.named().len() == 0, message:
    "typstage: cue() does not know "
    + items.named().keys().join(", ") + ". It takes start, spacing and nr.")
  assert(im-fit.get() == 0, message: fit-meldung("cue"))
  // Eine 0 war hier schlimmer als anderswo: die Ziffer meldete Erfolg und
  // bewirkte nichts, weil der Schritt 0 der Folie in `STEPS` nicht vorkommt.
  assert(start == auto or (type(start) == int and start >= 1), message:
    "typstage: cue(start: …) counts from 1, not 0. Not " + repr(start))
  assert(nr == auto or (type(nr) == int and nr >= 1), message:
    "typstage: cue(nr: …) is the number of the first point of this call, "
    + "counting from 1. Not " + repr(nr))
  let gegeben = items.pos()
  assert(gegeben.len() > 0, message: "typstage: cue() wants something to reveal")
  // A single piece can be a list: then its items are the points. The same
  // unwrapping as in `stagger` -- a body is rarely the list itself, usually a
  // sequence in which it stands beside whitespace.
  let punkte = if gegeben.len() == 1 {
    let body = gegeben.first()
    let teile = if body.has("children") { body.children } else { (body,) }
    teile.filter(c => c.func() in (list.item, enum.item))
  } else { () }
  let stuecke = if punkte.len() > 0 { punkte.map(p => p.body) } else { gegeben }

  // ── Eine Gruppe, mehrere Aufrufe, eine Folie ────────────────────────────
  //
  // Zusammengehalten wird eine Gruppe von ihrem Namen, nicht von einem
  // einzigen Aufruf. Jeder `cue("name")[…]` steuert Punkte bei und setzt sie
  // dort, wo er steht -- freie Platzierung ist damit kein Sonderfall mehr,
  // sondern fällt weg.
  //
  // Und sie gehört zu *einer* Folie. Getragen wird das von `cue-basis`, das
  // die Folie zu Beginn leert: was hier steht, steht von dieser Folie. Kein
  // `slide-counter.get()` und kein Zähler je Name -- beides wäre ein Lesen
  // von Introspektion, und `track` misst diesen Inhalt.
  //
  // In einer Messung löst Typst eine Introspektion auf, indem es "das
  // nächstpassende Element im echten Dokument" sucht, und sobald mehr als
  // eine Folie im Deck steht, ist das nicht mehr eindeutig: gemessen an drei
  // `cue`-Aufrufen mit einer einzigen weiteren Folie dahinter meldete Typst
  // "a measured element did not stabilize" und gab nach fünf Läufen auf.
  // Nachgewiesen ist auch, dass es am Lesen liegt und nicht am Wert: mit
  // festem Folienwert und demselben Schlüssel blieb es still, mit gelesenem
  // Zähler und bloßem Namen nicht.
  //
  // `ab` ist der Schritt des ersten Punktes der Gruppe auf dieser Folie, `n`
  // wie viele Punkte sie schon hat. Beides in einem Zustand, den nur die
  // Folie zurücksetzt.
  let stand = cue-basis.get().at(name, default: none)
  let bisher = if stand == none { 0 } else { stand.n }
  let erste = if nr != auto { nr } else { bisher + 1 }
  // Nur der erste Aufruf einer Gruppe liest den Schrittzeiger. Jeder weitere
  // rechnet von der gemerkten Basis aus -- sonst hängt Aufruf n an Aufruf
  // n-1, und Typst gibt die Kette nach fünf Layoutläufen auf.
  let ab = if start != auto { start } else if stand != none {
    stand.ab + erste - 1
  } else { step-cursor.get().first() + 1 }
  // Die Schritte selbst reservieren, wie `stagger` und `alternatives` es tun.
  // Ohne das schrieb `cue` den Schrittzeiger nie: er rückte erst weiter, wenn
  // `anim-kern` ihn aus seinem `at` nachzog, und der nächste Aufruf las einen
  // Wert, der von der Auszeichnung des vorigen abhing. Gemessen bekamen drei
  // Punkte hinter einem `anim` die Schritte 3, 4, 4 statt 3, 4, 5.
  if start != auto { step-cursor.update(c => calc.max(c, ab + stuecke.len() - 1)) }
  // Fortgeschrieben wird aus den Argumenten, nicht aus dem Gelesenen. Ein
  // `n` das an `erste` hinge, hinge am gelesenen Stand -- gemessen meldete
  // Typst dann "did not converge", sobald fünf Aufrufe hinter zwei `anim`
  // standen. `s.n + len` hängt allein am vorigen Wert des Zustands.
  //
  // Ein gepinntes `nr:` zieht nach, aber aus dem Argument: nach
  // `cue("a", nr: 4)` ist der nächste freie Punkt die 5 und nicht die 2.
  //
  // Gemerkt wird auch, auf welchem Schritt jeder Punkt wirklich sitzt. Ihn aus
  // `ab + nr - 1` zurückzurechnen ginge nur, solange die Aufrufe lückenlos
  // aufeinanderfolgen: mit ausgeschriebenem `start:` tun sie das nicht, und
  // `cue-layer` landete dann neben seinem Punkt statt auf ihm -- gemessen bei
  // `start: 2` und `start: 7` auf Schritt 3 statt auf 7.
  //
  // Alles darin kommt aus den Argumenten und dem vorigen Wert des Zustands.
  // Nur der Anfangswert der allerersten Gruppe steht auf Gelesenem, und den
  // schreibt genau ein Aufruf -- ein fester Punkt, keine Kette.
  let basis = ab - erste + 1
  cue-basis.update(b => {
    let s = b.at(name, default: (ab: basis, n: 0, schritte: (:)))
    let z0 = if nr == auto { s.n + 1 } else { nr }
    let a0 = if start != auto { start } else { s.ab + z0 - 1 }
    let sch = s.schritte
    for i in range(stuecke.len()) { sch.insert(str(z0 + i), a0 + i) }
    b + ((name): (ab: s.ab, schritte: sch, n: if nr == auto {
      s.n + stuecke.len()
    } else { calc.max(s.n, nr - 1 + stuecke.len()) }))
  })
  for i in range(stuecke.len()) {
    assert(erste + i <= 9, message:
      "typstage: cue(\"" + name + "\") would get a point " + str(erste + i)
      + " on this slide, and the room calls points with the keys 1 to 9. "
      + "Split the group, or reach the rest with the pointer instead of a "
      + "digit.")
    // Was der Punkt ist, steht als Fund im Dokument -- nicht in einem
    // Zustand, den derselbe Aufruf auch liest. Die Prüfung am Deckende fragt
    // danach.
    [#metadata((name: name, nr: erste + i, schritt: ab + i))
     <typstage-cue-punkt>]
  }

  for (i, b) in stuecke.enumerate() {
    // `spacing` gilt innerhalb eines Aufrufs. Zwischen zwei Aufrufen steht
    // nichts -- dort bestimmt das Layout, wo etwas hingehört.
    if i > 0 { v(spacing, weak: true) }
    block(anim-kern(
      if punkte.len() > 0 { list(b) } else { b },
      at: if start == auto { auto } else { str(ab + i) + "-" },
      boden: 1, ad: name, ad-nr: erste + i))
  }
}

/// Something that appears together with one point of an adaptive group.
///
/// A drawing layer, a picture, a sentence beside it: it shares the step with
/// its point and therefore travels with it, without having to be linked.
///
/// ```typ
/// #cue-layer("ablesen", 1, schicht-vorzeichen)
/// ```
///
/// The group has to stand *before* its layers in the source, because a layer
/// looks up which step its point was given. Standing after them, the package
/// says so rather than quietly doing nothing.
#let cue-layer(name, number, body, enter: "fade") = context {
  // Gefragt wird dieselbe Basis, die `cue` führt -- kein `query` und kein
  // Folienzähler. Beides wäre ein Lesen von Introspektion in einem gemessenen
  // Element und brächte das Dokument um seine Konvergenz. Und weil die Folie
  // diesen Zustand zu Beginn leert, meint `number` immer den Punkt *dieser*
  // Folie: eine gleichnamige Gruppe von vorhin steht nicht mehr darin.
  assert(type(number) == int and number >= 1, message:
    "typstage: cue-layer() wants the number of a point, counting from 1. "
    + "Not " + repr(number))
  let stand = cue-basis.get().at(name, default: none)
  assert(stand != none, message:
    "typstage: cue-layer(\"" + name + "\") finds no group of that name on "
    + "this slide. A cue() group has to stand before its layers in the "
    + "source, because a layer sits on the step its point was given -- and a "
    + "group belongs to one slide, so a name from the slide before does not "
    + "reach here.")
  let da = stand.schritte.keys().map(int).sorted()
  assert(number in da, message:
    "typstage: cue-layer(\"" + name + "\", " + str(number) + ") -- that "
    + "point is not declared. The group has the point"
    + (if da.len() == 1 { " " } else { "s " }) + da.map(str).join(", ")
    + "; a layer can only follow a point that already stands.")
  // Der gemerkte Schritt des Punktes, nicht `ab + number - 1`: mit
  // ausgeschriebenem `start:` liegen die Punkte nicht lückenlos hintereinander.
  anim-kern(body, at: str(stand.schritte.at(str(number))) + "-",
            ad: name, ad-nr: number, enter: enter)
}

/// Several things, one after another, one step apart.
///
/// ```typ
/// #stagger[
///   - The first point
///   - The second
///   - And the third
/// ]
/// ```
///
/// A bullet list is taken apart at its items; anything else is taken as it
/// comes, one piece per argument. Where a list would be wrong -- three cards
/// side by side, say -- hand the pieces over instead:
///
/// ```typ
/// #stagger(card[One], card[Two], card[Three])
/// ```
///
/// `start` is the step the first piece stands on, `auto` the next free one.
/// `stride` is how many steps lie between two pieces: `2` leaves one out,
/// and `0` puts them all on the same step, staggered only by `stagger`, which
/// is the delay in milliseconds between one piece and the next. The two
/// belong together -- with `stride: 0` and `stagger: 60` a list arrives as a
/// wave rather than as a sequence of keypresses.
///
/// `dim` leaves the pieces already shown standing, dimmed, instead of at full
/// strength. `spacing` is the gap between them, `enter`, `duration` and
/// `easing` are handed on to every piece unchanged.
///
/// `morph: true` lets each piece fly out of the one before it. Every piece
/// stays where it is once it has arrived, so at a step change the piece set
/// last is the source and the new one the target: the new line grows out of
/// the line above while the line above stays put. That is a chain of
/// transformations, line by line, on a single slide:
///
/// ```typ
/// #stagger(morph: true, spacing: 14pt,
///   $ x^2 + 6 x + 2 = 0 $,
///   $ (x + 3)^2 - 7 = 0 $,
///   $ x = -3 plus.minus sqrt(7) $,
/// )
/// ```
///
/// A morph has no entrance, no easing curve and no dimmed rest, so `enter:`,
/// `easing:` and `dim:` are refused rather than quietly dropped. `duration:`
/// is read and is the time of the flight.
#let stagger(
  ..items,
  start: auto,
  stride: 1,
  enter: "fade-up",
  duration: auto,
  easing: auto,
  stagger: 60,
  spacing: 0.65em,
  dim: false,
  morph: false,
  name: none,
) = {
  // Vor dem `context`, nicht darin. Ein `update` im selben Kontextblock ist
  // für das `get()` daneben noch nicht geschehen -- gemessen: der erste Aufruf
  // hieß dann `ts-stagger-0`.
  if morph == true { auto-morph-nr.update(n => n + 1) }
  context {
  // Asked here rather than left to the `anim`s below, so the message names the
  // function the deck actually wrote. An assertion, not a placed `fit-verbot`,
  // because the list branch below leaves through a `return`.
  assert(im-fit.get() == 0, message: fit-meldung("stagger"))
  // Wie bei `alternatives`: Schritte werden ab 1 gezaehlt. Eine 0 nahm der
  // Staffelung einen Takt -- die ersten beiden Punkte standen dann zugleich da,
  // und nichts sagte es.
  assert(start == auto or (type(start) == int and start >= 1), message:
    "typstage: stagger(start: …) counts from 1, not 0. Not " + repr(start))
  // Null ist erlaubt und dokumentiert: alle Punkte auf einem Schritt, gestaffelt
  // nur ueber `stagger`. Negativ ist es nie.
  assert(type(stride) == int and stride >= 0, message:
    "typstage: stagger(stride: …) is how many steps lie between two items, a "
    + "whole number from 0 upwards; 0 puts them all on the same step. Not "
    + repr(stride))
  // ── Die Schritte von `track` vergeben lassen ───────────────────────────
  //
  // Ein aus dem gelesenen Schrittzeiger *berechnetes* `at` bringt die Messung
  // um ihre Konvergenz, sobald der Körper etwas außerhalb des Flusses trägt --
  // gemessen an drei Aufrufen mit einem `place(dx: …)` darin: neun Meldungen
  // „a measured element did not stabilize". `anim` entgeht dem, weil `track`
  // bei `at: auto` erst rein vorrückt und den Stand dann in seinem *eigenen*
  // context liest; der Wert entsteht dort, wo er gebraucht wird, statt von
  // außen hereingereicht zu werden.
  //
  // Genau diesen Weg nimmt eine Kette aus lauter Einzelschritten jetzt auch:
  // je Stück ein `at: auto`, und `track` zählt weiter. Gemessen kommt dabei
  // dieselbe Schrittfolge heraus wie vorher, nur ohne die Meldungen.
  //
  // Nur für den Fall, der ohne den absoluten Anfang auskommt: `stride: 1`
  // (sonst liegen Lücken dazwischen, die `track` nicht kennt), kein `dim`
  // (das setzt einen einzelnen Schritt statt einer offenen Spanne), kein
  // `morph` und kein Name (beide tragen den Anfang weiter).
  let auto-kette = (start == auto and stride == 1 and not dim
                    and morph == false and name == none)
  let start = if start != auto { start } else if auto-kette { 0 } else {
    step-cursor.get().first() + 1 }
  // `..items` would otherwise swallow any named argument without a word: a
  // typo in `stride:` would stagger on the default and say nothing.
  assert(items.named().len() == 0,
         message: "typstage: stagger() does not know "
                + items.named().keys().join(", ")
                + ". It takes start, stride, enter, duration, easing, "
                + "stagger, spacing, dim, morph and name.")
  assert(morph == false or morph == true or type(morph) == str
         or type(morph) == label, message:
    "typstage: stagger(morph: …) is `true`, or a name of your own as a string "
    + "or a label. Not " + str(type(morph)) + ".")
  // Ein Morph fliegt, er blendet nicht ein und er ruht nicht gedimmt.
  assert(morph == false or (enter == "fade-up" and easing == auto and not dim),
         message:
    "typstage: stagger(morph: …) has no entrance, no easing curve and no "
    + "dimmed rest. The pieces fly into one another instead of appearing, and "
    + "each one stays -- that is what the flight comes out of. `duration:` is "
    + "read, and it is the time of the flight.")
  let gegeben = items.pos()
  assert(gegeben.len() > 0, message: "typstage: stagger() wants something to stagger")

  // A single piece can be a list: then its items are staggered. Anything
  // else is the pieces themselves.
  let punkte = if gegeben.len() == 1 {
    let body = gegeben.first()
    let parts = if body.has("children") { body.children } else { (body,) }
    parts.filter(c => c.func() in (list.item, enum.item))
  } else { () }

  // Where a point rests. Without `dim` it stays for the rest of the slide, so
  // its range stays open; with `dim` it holds its own step and dims after it.
  // Both selectors carry the same highest number, so the slide keeps its step
  // count either way.
  let bereich(n) = if dim { str(n) } else { str(n) + "-" }
  let ruhe = if dim { "dimmed" } else { "hidden" }
  // Einmal geprüft und einmal aufgelöst, nicht je Punkt: die Meldung nennt
  // sonst dieselbe Kurve so oft, wie die Liste Punkte hat.
  let takt = kurve(easing, "stagger")
  // Mit `morph:` tragen alle Stücke denselben Namen, und jedes bleibt von
  // seinem Schritt an stehen. Beim Schrittwechsel ist das zuletzt gesetzte
  // Stück die Quelle und das neue das Ziel: die neue Zeile wächst aus der
  // darüber, während die darüber stehen bleibt. Das ist die Umformungskette,
  // Zeile für Zeile, auf einer einzigen Folie.
  let mname = if morph == true {
    "ts-stagger-" + str(auto-morph-nr.get())
  } else if morph != false { name-of(morph) }
  // Der Gruppenname, unter dem `stagger-layer` diese Staffelung findet.
  // `name:` sagt ihn ausdrücklich; wer schon `morph: "…"` geschrieben hat, hat
  // ihn damit gesagt, und ein zweites Mal wäre er nur Abschrift.
  let gname = if name != none { name-of(name) }
              else if morph != false and morph != true { name-of(morph) }

  if punkte.len() == 0 {
    // No list: the pieces in order, each as its own block.
    if gname != none {
      stagger-gruppen.update(g => g + ((gname): (
        start: start, anzahl: gegeben.len(), stride: stride)))
    }
    for (i, b) in gegeben.enumerate() {
      block(if morph == false {
        anim-kern(b, at: if auto-kette { auto } else { bereich(start + i * stride) },
                  boden: 1, after: ruhe,
                  dim-freiwillig: dim, enter: enter, duration: duration,
                  easing: takt, delay: i * stagger)
      } else {
        morph-fn(mname, b, at: bereich(start + i * stride), duration: duration,
                 inline: false)
      })
    }
    // Kein `return`: es verließe die Funktion und nicht nur den Kontextblock,
    // und der Zähler oben stünde dann ohne seinen Rumpf da.
  } else {

  if gname != none {
    stagger-gruppen.update(g => g + ((gname): (
      start: start, anzahl: punkte.len(), stride: stride)))
  }
  let numbered = punkte.at(0).func() == enum.item
  let marks = punkte.enumerate().map(((i, p)) => {
    if numbered { [#(i + 1).] } else { [•] }
  })
  // One shared column width so the texts line up.
  let column = calc.max(..marks.map(m => measure(m).width.pt())) * 1pt

  for (i, p) in punkte.enumerate() {
    if i > 0 { v(spacing, weak: true) }
    let stueck = if morph == false { anim-kern } else {
      (koerper, at: none, ..rest) => morph-fn(mname, koerper, at: at,
                                              duration: duration, inline: false)
    }
    stueck(
      grid(
        columns: (column, 1fr),
        column-gutter: 0.5em,
        // Vertical alignment stated explicitly: an `auto` alignment would
        // inherit that of the surrounding grid, and `side-by-side` prescribes
        // `horizon`. The mark would then sit next to the middle of a
        // two-line item instead of next to its first line.
        //
        // `end` and `start`, not `right` and `left`. In a deck that reads
        // from the right the grid lays the mark column out on the right, and
        // there the mark has to hug the text from the other side, and the
        // text has to begin at the right. With the sides named outright the
        // marks stood on the right and the lines still ran from the left.
        align: (end + top, std.start + top),
        marks.at(i), p.body,
      ),
      at: if auto-kette { auto } else { bereich(start + i * stride) },
      boden: 1, after: ruhe, dim-freiwillig: dim,
      enter: enter, duration: duration, easing: takt, delay: i * stagger,
    )
  }
  }
  }
}

/// Something that belongs to one particular piece of a `stagger`.
///
/// A note in the margin, an annotation on a line of a calculation, a second
/// drawing: it shares the step with its piece and therefore travels with it,
/// without having to be counted.
///
/// ```typ
/// #stagger(morph: "rewrite", ..lines)
///
/// #stagger-layer("rewrite", 2)[$| -2$]
/// ```
///
/// The group needs a name for that -- `name:` says it, and a `morph:` written
/// as a name says it too, because then it is already there.
///
/// The stagger has to stand *before* its layers in the source, because a layer
/// looks up which step its piece was given. Standing after them, the package
/// says so rather than quietly doing nothing.
///
/// A layer stays from its piece to the end of the slide, as `cue-layer` and
/// `scene-layer` do. And it stays out of a `morph: true` flight: the layer is
/// its own element and carries no morph name, so what flies is the piece and
/// the annotation merely appears beside it -- which is what an annotation
/// should do.
#let stagger-layer(name, number, body, enter: "fade") = context {
  let g = stagger-gruppen.get()
  assert(name-of(name) in g, message:
    "typstage: stagger-layer(\"" + name-of(name) + "\") finds no group of "
    + "that name. A stagger() has to carry `name:` (or a `morph:` written as a "
    + "name) and has to stand before its layers in the source, because a layer "
    + "looks up which step its piece was given.")
  let e = g.at(name-of(name))
  assert(number >= 1 and number <= e.anzahl, message:
    "typstage: stagger-layer(\"" + name-of(name) + "\", " + str(number)
    + ") -- that group has " + str(e.anzahl) + " piece"
    + (if e.anzahl == 1 { "" } else { "s" }) + ", so the number is out of range.")
  anim(body, at: str(e.start + (number - 1) * e.stride) + "-", enter: enter)
}


// ── Eine Zeichnung, die wächst ───────────────────────────────────────────────
//
// Eine cetz-Zeichnung oder ein lilaq-Diagramm ist ein Stück, nicht viele:
// Typst reicht den fertigen Satz heraus, und was darin eine Linie und was eine
// Datenreihe war, ist von außen nicht mehr zu greifen. Ein `anim` um ein Stück
// der Zeichnung gibt es also nicht.
//
// Was es gibt, ist die Zeichnung selbst, so oft man sie haben will. `build`
// ruft sie einmal je Schritt und legt die Fassungen übereinander: auf Stufe
// k steht die Zeichnung so, wie sie nach k Schritten aussieht. Sichtbar ist
// immer genau eine Stufe.
//
// Zwei Fragen entscheiden, ob das trägt, und beide sind nachgemessen.
//
// *Springt das Bild?* Nein, weil kein Stück je wirklich fehlt: was noch nicht
// dran ist, steht als Luft da (siehe `durchsichtig` in `internal.typ`). Alle
// Stufen messen deshalb auf die Stelle genau gleich, und der Block, in dem
// sie liegen, hat ohnehin eine feste Größe.
//
// *Warum eine Stufe und nicht alle übereinander?* Weil sich gemalte Tinte
// addiert. Drei Stufen desselben lilaq-Diagramms gegen eines: 3.7 Prozent
// der Bildpunkte weichen um mehr als 8 von 255 ab, die größte Abweichung 99 --
// Achsen, Beschriftung und der halbdurchsichtige Kasten der Legende werden
// dreimal gemalt und dadurch fetter. Mit disjunkten Stufen, in denen nur
// das eigene Stück steht, ist es nicht besser: dieselbe Messung ergab 3.5
// Prozent und eine größte Abweichung von 243, denn die Achsen gehören zu
// keinem Stück und stehen deshalb auf jeder Stufe. Eine Stufe auf einmal
// ist die einzige Anordnung, die genau das Bild ergibt, das dastünde, wenn man
// die Zeichnung einmal setzte.
//
// Der Preis dafür wäre der Übergang: zwei fast gleiche Bilder, die einander
// ablösen, blenden sich gegenseitig aus. Dagegen steht `exit: "hold"` in der
// Laufzeit -- die abtretende Stufe bleibt stehen, bis die neue da ist, und
// geht dann ohne Bewegung.
//
// Rückwärts gilt dasselbe spiegelverkehrt, und die Laufzeit weiß, in welche
// Richtung geblättert wird (`back` in `goto`). Dort kommt die *kleinere*
// Stufe herein und liegt vollständig unter der größeren, die noch abtritt:
// sie hat nichts zu blenden, sie ist einfach da. Was verschwindet, ist allein
// die Tinte, die die größere mehr hat. Gemessen an drei gestapelten Flächen,
// Bild für Bild angehalten und abgelichtet: die geteilte Tinte sank vorher
// auf 0,7522 und steht jetzt in beide Richtungen bei 1,0000. Mit
// `enter: "draw"` von Hand gestapelt war die Senke tiefer -- 0,4348 --, weil
// die Feder rückwärts über Tinte fuhr, die schon lag; auch das ist damit weg.

/// A drawing or a diagram that comes into being step by step.
///
/// A CeTZ canvas and a lilaq diagram are one piece, not many: Typst hands out
/// the finished setting, and what was a line and what was a data series in it
/// cannot be reached from outside any more. So there is no `anim` around a
/// part of a drawing. What there is, is the drawing itself, as often as one
/// wants it.
///
/// `draw` is called once per step and is handed a question. The examples
/// call it `from`, because it says exactly what `at:` says elsewhere; the name
/// is the deck's own, since it is the lambda's parameter.
///
/// - `from(k, value)` gives `value` back once the k-th piece is due, and
///   otherwise the same thing made of air: a colour with alpha 0, a stroke
///   with a transparent brush, a text in `hide`. The piece is therefore never
///   really missing, and every stage measures the same to the point.
/// - `from(k)` says the same as a boolean, for everything that cannot be
///   recoloured. In CeTZ that is where `hide(…, bounds: true)` belongs.
///
/// Whatever carries no number stands there from the start.
///
/// ```typ
/// #build(from => cetz.canvas({
///   import cetz.draw: *
///   line((0,0), (4,0))                        // there from the start
///   line((4,0), (4,3), stroke: from(2, black))  // from step 2
///   content((2,3.4), from(3, [hypotenuse]))     // from step 3
/// }), steps: 3)
/// ```
///
/// `steps` is the number of stages and hence the number of steps the
/// drawing takes on the slide. It is said and not guessed: what `draw`
/// does with its question is nobody's business from outside.
///
/// `start` is `auto`: the drawing begins on the next free step and pushes the
/// cursor along by `steps`, the way `stagger` and `alternatives` do. A
/// number sets the first step itself.
///
/// `at` is for a drawing whose stages do *not* come one click after another.
/// It names, per stage, the step it first stands on, and each stage then holds
/// until the next one is due:
///
/// ```typ
/// #build(from => diagram(from), at: (1, 9))
/// ```
///
/// Two stages, the second from step 9 on. Whatever happens on the slide in
/// between -- a camera move, a verdict, a second diagram -- costs nothing
/// here. Without `at` the same picture needs `steps: 9`, and stages 1 to 8 are
/// pixel for pixel the same drawing and are all typeset regardless. Measured
/// on a slide carrying three diagrams that are discussed one after another:
/// 22 sprites against 10, and the file 3.45 MB against 2.98 MB.
///
/// The list's length is the number of stages, so `steps` and `start` have
/// nothing left to say and are refused rather than quietly ignored.
///
/// `from` keeps counting *stages* and not steps: `from(2, …)` is "from the
/// second picture on", and where that picture stands is said by `at` alone.
/// It could not be otherwise: under `start: auto` nobody knows while writing
/// which step the drawing will land on.
///
/// Exactly one stage is drawn at a time, and that is not a saving but the only
/// arrangement that yields the picture that would stand there if the drawing
/// were set once. Ink adds up: three layers of the same lilaq diagram against
/// one, and 3.7 percent of the pixels differ by more than 8 of 255, the
/// largest deviation 99 -- axes, labels and the half-transparent box of the
/// legend get painted three times and grow fatter by it.
///
/// On paper only the last stage is set, in a block of the same size: a page
/// shows every step at once, and stacked stages would be overprint. The
/// cursor still runs there, so that `info().step.total` names the same number
/// in both outputs.
///
/// Under `prefers-reduced-motion: reduce` nothing changes: the stages fade,
/// they do not travel, and what would fall away is a motion that is not there.
#let build(draw, steps: auto, start: auto, at: auto, enter: "fade",
           duration: auto, easing: auto) = {
  assert(type(draw) == function, message:
    "typstage: build() wants a function that paints the drawing as its first "
    + "argument, not a finished drawing. It is called once per stage and is "
    + "handed the question from(k) while it paints.")
  // Streng steigend, und das ist keine Pedanterie: eine Stufe hält bis zur
  // nächsten, zwei gleiche Zahlen ergäben also eine Stufe ohne einen einzigen
  // Schritt, und eine fallende eine, die unter ihrer Vorgängerin läge. Beides
  // sähe man dem Deck nicht an, man sähe nur ein Bild, das nie kommt.
  assert(at == auto or (type(at) == array and at.len() >= 1
    and at.all(x => type(x) == int and x >= 1)
    and range(1, at.len()).all(i => at.at(i) > at.at(i - 1))), message:
    "typstage: build(at: …) is one step number per stage, rising: at: (1, 4, 9) "
    + "puts three stages on steps 1, 4 and 9, and each holds until the next one "
    + "is due. Steps count from 1. Not " + repr(at))
  // Wortlos das eine über das andere zu stellen wäre die Auskunft, die man am
  // spätesten bekommt: die Zeichnung stünde woanders, und im Quelltext stünde
  // die Zahl, die es nicht war.
  assert(at == auto or steps == auto, message:
    "typstage: build(at: …) already says how many stages there are, one per "
    + "entry. steps: says it a second time and would have to agree. Drop it.")
  assert(at == auto or start == auto, message:
    "typstage: build(at: …) already says where the first stage stands, in its "
    + "first entry. Drop start.")
  // Die Vorgabe steht hier und nicht in der Signatur, damit `steps: auto` von
  // "nicht gesagt" zu unterscheiden ist und die Prüfung darüber greifen kann.
  // Ein Deck ohne beides bekommt die 2 wie eh und je.
  let steps = if at != auto { at.len() } else if steps == auto { 2 } else { steps }
  assert(type(steps) == int and steps >= 1, message:
    "typstage: build(steps: …) is the number of stages and counts from 1. "
    + "A 0 would mean a drawing without a single stage.")
  assert(start == auto or (type(start) == int and start >= 1), message:
    "typstage: build(start: …) counts from 1, not from 0. On step 0 the first "
    + "stage would never stand there.")
  // Eine Stufe, die sich selbst zeichnete, zeichnete jedes Mal die ganze
  // Zeichnung noch einmal -- auch die Striche, die schon auf der Stufe davor
  // standen. Und sie täte es über der abtretenden Stufe, die absichtlich
  // stehenbleibt (`exit: "hold"`): die Tinte läge längst da, die Feder führe
  // unsichtbar darüber. Rückwärts ist es dieselbe Vergeblichkeit von der
  // anderen Seite -- dort steht die hereinkommende Stufe sofort da, unter der
  // abtretenden, und eine Feder liefe gar nicht erst los. Das Gegenteil
  // dessen, was `draw` verspricht, also lieber ein Wort als ein stummes
  // Nichts.
  assert(enter != "draw", message:
    "typstage: enter: \"draw\" is at odds with what this function does. Every "
    + "stage is the *whole* drawing, and it would arrive on top of the "
    + "previous one, which stays put until the new one is there -- the pen "
    + "would travel over ink that is already down. Paging back it is the same "
    + "futility mirrored: there the arriving stage is simply set, underneath "
    + "the one still leaving, and no pen runs at all. To have the strokes "
    + "drawn one after another, hand them over one at a time: "
    + "stagger(enter: \"draw\", stride: 1, axes, curve). For a drawing that "
    + "grows in stages, leave the fade as it is.")
  let takt = kurve(easing, "build")
  layout(available => context {
    // Wie bei `alternatives`: die Prüfung steht hier und nicht in `track`,
    // weil der Papierzweig weiter unten über ein `return` hinausgeht und ein
    // `return` alles fallen lässt, was vorher zusammengefügt wurde.
    assert(im-fit.get() == 0, message: fit-meldung("build"))
    // Die Frage, die eine Stufe ihrem Zeichner reicht. Ein Argument heißt
    // fragen, zwei heißen einfärben; das spart dem Deck zwei Namen für
    // dieselbe Auskunft.
    let frage(k) = (nr, ..wert) => {
      assert(type(nr) == int and nr >= 1 and nr <= steps, message:
        "typstage: from(" + repr(nr) + ") -- this drawing has " + str(steps)
        + " stage" + (if steps == 1 { "" } else { "s" }) + ", so the number "
        + "lies outside it. A piece behind the last stage would never come.")
      assert(wert.named().len() == 0 and wert.pos().len() <= 1, message:
        "typstage: from() takes the number of the stage and at most one thing "
        + "that is to appear on it.")
      if wert.pos().len() == 0 { return k >= nr }
      if k >= nr { wert.pos().first() } else { durchsichtig(wert.pos().first()) }
    }
    let stufen = range(1, steps + 1).map(k => draw(frage(k)))
    // Zweimal gemessen, die größere zählt: dieselbe Falle wie in `track` und
    // in `alternatives`. Ein `height: 100%` in einer Stufe fiele ohne
    // Höhenbezug auf 0pt zusammen, und eine Messung allein gegen die Höhe
    // schnitte ab, was übersteht.
    let frei = stufen.map(s => measure(s, width: available.width))
    let gedeckelt = stufen.map(s => measure(s, width: available.width,
                                            height: available.height))
    // Was sich selbst mittig setzt, misst sich trotzdem so schmal wie seine
    // Tinte -- `measure(align(center, x), width: 400pt)` gibt die Breite von
    // `x` zurück und nicht 400pt. Ein Block von dieser Breite nähme dem `align`
    // genau den Platz weg, in dem es zentrieren wollte, und die Zeichnung
    // stünde links, obwohl im Quelltext `center` steht. `track` kennt diese
    // Falle und weicht ihr mit `will-fuellen` aus; hier muss dasselbe gelten,
    // sonst verhielte sich `build(align(center, …))` anders als
    // `anim(align(center, …))`. Gemessen: die Stufen lagen bei 3,80 Prozent
    // der Bühne statt bei 44,61.
    let fuellt = stufen.any(will-fuellen)
    let breite = if fuellt { available.width } else {
      calc.max(..frei.map(m => m.width), ..gedeckelt.map(m => m.width))
    }
    let hoehe = calc.max(..frei.map(m => m.height), ..gedeckelt.map(m => m.height))
    let erster = if at != auto { at.first() }
                 else if start == auto { step-cursor.get().first() + 1 }
                 else { start }
    if not html-output.get() {
      // Nur die letzte Stufe, und der Zähler läuft trotzdem. Genau wie
      // `alternatives`: auf Papier steht die Zeichnung fertig da.
      return {
        // Kein eigener Vorschub, wenn `track` die Schritte vergibt.
        if im-deck() and not (at == auto and start == auto) {
          step-cursor.update(c => calc.max(c,
            if at != auto { at.last() } else { erster + steps - 1 }))
        }
        // Ohne `place`, anders als im Zweig darunter: hier steht nur eine
        // Stufe, es ist also nichts zu stapeln, und `place` nähme einem
        // `align` in der Stufe den Platz, in dem es ausrichten wollte.
        // Gemessen an `place(top + left, align(center, rect))` in einem Block
        // voller Breite: die Tinte lag bei x = 39 statt bei x = 312.
        // Jede Stufe als verfolgtes Element, wie im Browserzweig: `track`
        // entscheidet, welche auf dem gesetzten Schritt steht, und meldet den
        // Halt. Selbst lesen kann `build` den Schritt hier nicht -- die Lesung
        // stünde in einem `layout` und löste sich erst am Dokumentende auf.
        let letzt = steps - 1
        let stufen-von(i) = if at != auto { at.at(i) } else { erster + i }
        block(width: breite, height: hoehe, {
          for (i, st) in stufen.enumerate() {
            let bereich = if i == letzt { str(stufen-von(i)) + "-" } else {
              str(stufen-von(i)) + "-" + str(stufen-von(i + 1) - 1)
            }
            place(top + std.start, anim-kern(
              st,
              at: if at == auto and start == auto { auto } else { bereich },
              boden: 1, offen: i == letzt,
              enter: enter, exit: "hold", duration: duration, easing: takt))
          }
        })
      }
    }
    let letzte = steps - 1
    // Wie bei `alternatives`: die Schritte von `track` vergeben lassen, statt
    // sie aus dem gelesenen Zeiger zu rechnen und hereinzureichen. Nur wenn
    // die Stufen lückenlos aufeinanderfolgen -- ein ausgeschriebenes `at:`
    // nennt eigene Nummern mit Lücken dazwischen, die `track` nicht kennt.
    let auto-kette = at == auto and start == auto
    block(width: breite, height: hoehe, {
      for (i, s) in stufen.enumerate() {
        // Jede Stufe hält genau ihren Schritt, die letzte den Rest der Folie.
        // Eine Stufe, die bliebe, läge unter der nächsten und würde ein
        // zweites Mal gemalt.
        let bereich = if at != auto {
          // Von ihrem eigenen Schritt bis kurz vor den der nächsten Stufe.
          // Ohne `at` ist dieser Bereich genau einen Schritt lang, und dann
          // steht dort die Zahl allein -- Byte für Byte das Deck von gestern.
          if i == letzte { str(at.at(i)) + "-" }
          else { str(at.at(i)) + "-" + str(at.at(i + 1) - 1) }
        } else if i == letzte { str(erster + i) + "-" } else { str(erster + i) }
        place(top + std.start, anim-kern(
          s, at: if auto-kette { auto } else { bereich },
          boden: 1, offen: i == letzte,
          enter: enter, exit: "hold", duration: duration, easing: takt))
      }
    })
  })
}


// ── Eine Zeichnung, die sich bewegt ──────────────────────────────────────────
//
// `build` darüber legt Stufen übereinander: die Zeichnung wächst, Stück für
// Stück, und was noch nicht dran ist, steht als Luft da. `scene` ist die
// andere Hälfte derselben Idee. Hier kommt nichts hinzu -- hier ändert sich
// eine *Größe*, und das Bild hängt daran.
//
// Das ist der ValueTracker aus manim, ins Schrittmodell eines Vortrags
// übersetzt, und die Übersetzung dreht ihn um. Dort ändert sich die Zahl zur
// Laufzeit und das Bild folgt ihr; hier zeichnet Typst zur Übersetzungszeit,
// und eine Zahl kann nur an Schritten wechseln. Also sagt das Deck, an welchen
// Werten der Vortrag hält, Typst rendert jeden Halt und die Bilder dazwischen,
// und ein Tastendruck zieht das Bild von Halt zu Halt.
//
// Dass `stops` die Werte selbst nennt und nicht 0 bis 1, ist der ganze
// Unterschied zu `flipbook` und der Grund, warum `scene` den Tracker ablöst:
// `x => tangent-at(f, x)` mit `stops: (-3, 0, 1.5, 3)` steht da, wo in manim
// vier `tracker.animate.set_value(…)` stünden, und die Zahlen sind dieselben.
//
// Was der Übersetzung verlorengeht: in manim können sich mehrere Tracker
// unabhängig voneinander bewegen. Hier bewegt sich alles gemeinsam von Halt zu
// Halt -- ein Tupel als Haltwert gibt mehrere Größen zugleich, aber sie teilen
// sich den Weg. Das Handbuch sagt es.
//
// Der Preis steht ebenfalls im Handbuch, und zwar zweimal: roh und gepackt.
// Jedes Bild ist ein echtes Typst-Layout und liegt als eigener SVG-Baum in der
// Datei. Die rohe Zahl allein gibt ein falsches Bild, weil die Bäume einander
// so ähnlich sind, dass gzip fast alles davon wegnimmt.

/// Ein Halt, so wie ihn `scene` versteht -- und was er nicht sein darf.
///
/// Zwischen zwei Halten wird gerechnet: `a + (b - a) * u`. Was das nicht
/// aushält, wird hier abgewiesen, einmal beim Aufschreiben und nicht bei jedem
/// der vielleicht dreißig Bilder. Ein Text oder ein Stück Inhalt lässt sich
/// nicht halbieren, und ein Halt, der es versuchte, bräche mitten im Rendern
/// mit einer Meldung, in der `scene` nicht vorkäme.
#let szene-messbar = (int, float, length, angle, ratio, relative)

/// Der Wert an der Stelle `u` zwischen zwei Halten, komponentenweise.
#let szene-zwischen(a, b, u) = if type(a) == array {
  range(a.len()).map(i => szene-zwischen(a.at(i), b.at(i), u))
} else { a + (b - a) * u }

/// Die Bilder einer Szene nachmessen, und was dabei auffällt.
///
/// Zurück kommt `none`, wenn alle Bilder auf die Toleranz genau gleich groß
/// sind, und sonst die Zahlen für die Meldung: wie viele Bilder, wie viele
/// verschiedene Lagen, und wie weit die äußersten auseinanderliegen.
///
/// Gemessen wird das *Bild*, nicht der Kasten, in dem es steht -- der ist
/// überall gleich groß, das ist sein ganzer Sinn. Und ohne Breitenbezug: ein
/// `measure` mit einem solchen deckelt jedes Bild auf genau diese Breite und
/// beantwortete die Frage, bevor sie gestellt wäre. Was sich selbst auf `100%`
/// setzt, misst dann für alle Bilder dieselben 0pt und fällt aus der Prüfung
/// heraus -- zu Recht, denn so ein Bild hat seinen festen Rahmen schon.
///
/// Muss in einem Kontext stehen.
#let szene-drift(bilder) = {
  let masse = bilder.map(b => measure(b))
  let breiten = masse.map(m => m.width)
  let hoehen = masse.map(m => m.height)
  let breit = calc.max(..breiten) - calc.min(..breiten)
  let hoch = calc.max(..hoehen) - calc.min(..hoehen)
  if breit <= drift-toleranz and hoch <= drift-toleranz { return none }
  // Wie viele *verschiedene* Lagen -- die Zahl, die beim Blättern zu sehen
  // ist. Auf den hundertstel Punkt gerundet, damit nicht das letzte Bit einer
  // Fließkommazahl zwei Lagen daraus macht.
  let lagen = masse.map(m => (calc.round(m.width.pt(), digits: 2),
                              calc.round(m.height.pt(), digits: 2))).dedup()
  (bilder: bilder.len(), lagen: lagen.len(), breit: breit, hoch: hoch)
}

/// A drawing as a function of a value, with stops for the talk.
///
/// ```typ
/// #scene(
///   x => tangent-at(f, x),
///   stops: (-3, 0, 1.5, 3),   // four stops, three steps
///   tween: 8,                 // frames between two stops
/// )
/// ```
///
/// This is manim's `ValueTracker` turned around. There a number changes while
/// the film runs and the picture follows it; here Typst draws at compile time
/// and a number can only change at a step. So the deck writes a function from
/// a value to a picture and says at which values the talk stops. Typst renders
/// every stop and the frames in between, and a keypress pulls the picture from
/// one stop to the next.
///
/// `stops` are the values themselves, not 0.0 to 1.0 -- that is the whole
/// difference to `flipbook`. The scene takes `stops.len() - 1` steps: the
/// first stop is there as soon as the scene appears, every further one costs a
/// keypress.
///
/// A stop may be a tuple, and then the drawing function takes that many
/// arguments: `(a, b) => …` with `stops: ((1, 1), (1, 3), (2, 3))`. What is
/// lost against manim is that there several trackers may move independently;
/// here everything travels from stop to stop together.
///
/// `tween` is the number of frames *between* two stops. With `tween: 0` the
/// scene jumps from stop to stop and shows nothing in between.
///
/// `duration` is the time one pull from stop to stop takes, not the time of
/// the entrance -- the same separation `morph` draws, and for the same reason:
/// one is a journey, the other a fade.
///
/// The scene stands in a box of a fixed size and every frame is clipped to it.
/// The scene stands in a box of a fixed size and every frame is clipped to
/// it. Unlike `build` the frames are *not* laid out on top of one another:
/// they are drawings of different values and may legitimately come out
/// different sizes, so one shared frame is the only arrangement in which the
/// box itself does not jump.
///
/// The frames are measured all the same, and `steady` says what that
/// measurement is for. A CeTZ canvas is as large as what it holds, so a frame
/// wider than its neighbour puts the drawing somewhere else inside the box,
/// and paging through it the whole picture travels while only one point
/// should move. The package can see that and cannot correct it: `measure`
/// answers with a size, never with where the ink lies inside it.
///
/// - `auto`, the default: the frames are measured and a finding is filed as a
///   record. `presentation(drift: …)` decides what happens with the records --
///   `"error"`, the default, stops at the end of the deck with all of them at
///   once.
/// - `false`: the frames are meant to differ -- a rectangle that grows, a
///   number that counts up -- and this scene is taken out of the check. It is
///   not measured at all.
/// - `true`: this scene has to stand still, and it stops where it stands if it
///   does not, whatever the deck says.
///
/// Measuring costs one more layout per frame, and a frame is a whole layout.
/// Measured on a scene of 28 frames -- four stops, eight frames between each
/// pair, a CeTZ drawing of axes with ticks, a parabola of 61 points, a
/// tangent, a dashed slope triangle and two labels: 434 ms without the
/// measuring and 536 ms with it, so about 100 ms for the scene and 3.6 ms per
/// frame. Only the browser branch pays it. On paper a scene is one still
/// image, and a still image does not travel.
///
/// On paper the last stop is set, as with `alternatives`; `still` overrides
/// that. The step cursor still runs there, so `info().step.total` names the
/// same number in both outputs.
///
/// Under `prefers-reduced-motion: reduce` the frames in between fall away and
/// the scene jumps from stop to stop. That is the package's rule everywhere
/// else too: what stays is the destination, what goes is the travel.
#let scene(
  ..parts,
  stops: (),
  tween: 8,
  start: auto,
  width: 100%,
  height: 190pt,
  duration: auto,
  enter: "fade",
  still: auto,
  steady: auto,
) = {
  // `..parts` would otherwise swallow any named argument without a word: a
  // typo in `tween:` would leave the scene on the default and say nothing.
  assert(parts.named().len() == 0, message:
    "typstage: scene() does not know " + parts.named().keys().join(", ")
    + ". It takes stops, tween, start, width, height, duration, enter, still "
    + "and steady.")
  let gegeben = parts.pos()
  assert(gegeben.len() in (1, 2), message:
    "typstage: scene() takes the function that draws the picture, and before "
    + "it, optionally, a name under which scene-layer() finds it again.")
  let name = if gegeben.len() == 2 { name-of(gegeben.first()) } else { none }
  let zeichnen = gegeben.last()
  assert(type(zeichnen) == function, message:
    "typstage: scene() takes a function from a value to the picture as its "
    + "drawer, not a finished drawing. It is called once for every stop and "
    + "every frame in between.")
  assert(type(stops) == array and stops.len() >= 2, message:
    "typstage: scene(stops: …) are the values at which the talk stops, and it "
    + "wants at least two of them. With a single one nothing moves, and anim() "
    + "is enough for that.")
  assert(type(tween) == int and tween >= 0, message:
    "typstage: scene(tween: …) is the number of frames between two stops and "
    + "counts from 0. With 0 the scene jumps from stop to stop.")
  assert(start == auto or (type(start) == int and start >= 1), message:
    "typstage: scene(start: …) counts from 1, not 0. On step 0 the first stop "
    + "would never stand.")
  assert(steady == auto or type(steady) == bool, message:
    "typstage: scene(steady: …) is auto (the default), true or false, not "
    + repr(steady) + ". auto measures the frames and files what it finds, "
    + "false says they are meant to differ, true insists that they do not.")
  // Jeder Halt einmal angesehen, bevor irgendein Bild entsteht. Sonst bräche
  // die Rechnung `a + (b - a) * u` irgendwo im dreißigsten Zwischenbild, mit
  // einer Meldung, in der weder `scene` noch `stops` vorkäme.
  let breit = type(stops.first()) == array
  let wieviele(n) = if n == 1 { "one value" } else { str(n) + " values" }
  for (i, w) in stops.enumerate() {
    let stellen = if type(w) == array { w } else { (w,) }
    assert(breit == (type(w) == array)
             and stellen.len() == (if breit { stops.first().len() } else { 1 }),
      message:
      "typstage: scene(stops: …) -- stop " + str(i + 1) + " names "
      + wieviele(stellen.len()) + ", the first one "
      + wieviele(if breit { stops.first().len() } else { 1 })
      + ". Between two stops the arithmetic runs value by value, so there "
      + "have to be equally many of them everywhere.")
    for g in stellen {
      assert(type(g) in szene-messbar, message:
        "typstage: scene(stops: …) -- stop " + str(i + 1) + " carries "
        + str(type(g)) + ". Between two stops there is arithmetic, so only "
        + "what can be halved belongs there: a number, a length, an angle, a "
        + "ratio. What cannot be halved belongs in the drawer, not in the "
        + "stop.")
    }
  }

  // Die Bilder. Halt k liegt auf Bild k * (tween + 1); dazwischen liegen die
  // `tween` Zwischenbilder der Strecke, gleichmäßig über den *Wert* verteilt.
  // Die Kurve, mit der ein Zug darüberfährt, sitzt in der Laufzeit und nicht
  // hier: sonst wäre sie in die Datei gebacken und ein anderer Rhythmus hieße
  // neu übersetzen.
  let werte = ()
  for k in range(stops.len() - 1) {
    let a = stops.at(k)
    let b = stops.at(k + 1)
    for j in range(tween + 1) {
      werte.push(szene-zwischen(a, b, j / (tween + 1)))
    }
  }
  werte.push(stops.last())
  let male(w) = if breit { zeichnen(..w) } else { zeichnen(w) }

  // Wie bei `flipbook` und `embed`: auf Papier kommt das hier nie bei `track`
  // an, die Fit-Prüfung kann also nicht dort stehen bleiben.
  fit-verbot("scene")
  context {
    // Der erste Halt steht da, sobald die Szene erscheint -- er kostet keinen
    // eigenen Schritt, wie bei `morph` und anders als bei `anim`. Steht die
    // Szene am Kopf ihrer Folie, ist das Schritt 1. Erst die weiteren Halte
    // kosten je einen.
    let erster = if start == auto {
      calc.max(1, step-cursor.get().first())
    } else { start }
    // Halt k steht auf Schritt `erster + k`. Der erste kostet nichts -- er
    // steht schon da --, jeder weitere einen Tastendruck; zusammen sind das
    // `stops.len() - 1` Schritte.
    let letzter = erster + stops.len() - 1
    // Der Vorschub rein, nicht aus dem Gelesenen: `erster` ist
    // `calc.max(1, c)`, also ist `letzter` eine Funktion von `c` allein. Ein
    // Update, das an einem gelesenen Zählerstand hängt, kostet das Dokument
    // seine Konvergenz, sobald die Zeichnung etwas außerhalb des Flusses
    // trägt -- gemessen zehn Meldungen bei drei Szenen, null mit dieser
    // Zeile. Bei ausgeschriebenem `start:` hängt `letzter` am Argument und
    // nicht am Zähler; dort bleibt es, wie es war.
    if im-deck() and (html-output.get() or start != auto) {
      if start == auto {
        step-cursor.update(c => calc.max(c, calc.max(1, c) + stops.len() - 1))
      } else {
        step-cursor.update(c => calc.max(c, letzter))
      }
    }
    // Eingetragen, damit `scene-layer` die Schritte wiederfindet.
    if name != none {
      szene-gruppen.update(g => g + ((name): (start: erster, stops: stops.len())))
    }
    if not html-output.get() {
      // Auf Papier ein Standbild, und zwar der letzte Halt: eine Seite zeigt
      // alle Schritte auf einmal, und das ist der Zustand, in dem die Szene
      // die Folie verlässt. Genau wie `alternatives`.
      // Eine Szene vergibt einen Schritt je Halt. Auf Papier steht jeder Halt
      // als eigenes verfolgtes Element da -- `track` zeigt den, der gerade an
      // der Reihe ist. Ein ausgeschriebenes `still` ersetzt die ganze Szene und
      // hat keine Schritte.
      if still != auto {
        block(width: width, height: height, still)
      } else {
        block(width: width, height: height, {
          for i in range(stops.len()) {
            place(top + left, anim-kern(
              male(stops.at(i)),
              at: if start == auto { auto } else {
                if i == stops.len() - 1 { str(erster + i) + "-" }
                else { str(erster + i) }
              },
              // Die Szene beginnt auf dem *aktuellen* Schritt, nicht auf dem
              // nächsten -- deshalb rückt der erste Halt nicht vor.
              boden: 1, vorruecken: if i == 0 { 0 } else { 1 },
              offen: i == stops.len() - 1,
              enter: enter))
          }
        })
      }
    } else {
      // Einmal gemalt, nicht zweimal: das Standbild der Folie ist dasselbe
      // Bild wie das erste der Reihe, und ein Bild ist ein ganzes Layout.
      let bilder = werte.map(male)
      // Ob überhaupt gemessen wird. `false` heißt: die Bilder dürfen
      // verschieden groß sein, dann ist auch die Messung für nichts. `true`
      // heißt: diese Szene muss stillstehen, und zwar unabhängig davon, was
      // das Deck insgesamt mit den Befunden anfängt.
      let modus = drift-modus.get()
      let messen = if steady == auto { modus != "none" } else { steady }
      let befund = if messen { szene-drift(bilder) } else { none }
      // Der Befund geht als Satz ins Dokument, wie beim Überlauf: Typst hat
      // keinen Kanal für eine Warnung, also wird abgelegt und am Ende des
      // Decks auf einmal berichtet. Nur `steady: true` hält sofort an -- wer
      // das schreibt, hat sich festgelegt und will es hier wissen, nicht am
      // Ende.
      if befund != none {
        assert(steady != true, message:
          "typstage: scene(steady: true) -- this scene draws its "
          + str(befund.bilder) + " frames in " + str(befund.lagen)
          + " different sizes, up to " + str(calc.round(befund.breit.pt(), digits: 2))
          + "pt apart across and " + str(calc.round(befund.hoch.pt(), digits: 2))
          + "pt down. A drawing is as large as what it holds, a CeTZ canvas "
          + "above all, so it sits somewhere else inside the box on every "
          + "frame and the whole picture travels while only one point should "
          + "move. "
          + drift-ausweg)
        drift-satz(if im-deck() { deck-info.get().data.slide.number } else { 0 },
                   erster, befund.bilder, befund.lagen, befund.breit, befund.hoch)
      }
      track(
        "scene",
        box(width: width, height: height, clip: true, bilder.first()),
        at: str(erster) + "-",
        extra: (
          stops: stops.len(), tween: tween, from: erster, enter: enter,
          // `pull`, nicht `duration`: das ist die Dauer des *Wegs* von Halt zu
          // Halt, nicht die der Blende, mit der die Szene auftritt. Dieselbe
          // Trennung, die `morph` mit `fly` zieht, und aus demselben Grund --
          // beide unter einem Namen laufen zu lassen zieht dieselbe Bewegung
          // sichtbar auseinander.
          pull: if duration == auto { none } else { duration },
        ),
        raw-frames: bilder.map(b => box(
          width: width, height: height, clip: true, b,
        )),
      )
    }
  }
}

/// Something that belongs to one particular stop of a scene.
///
/// A sentence beside it, a formula, a second drawing: it shares the step with
/// its stop and therefore travels with it, without having to be linked.
///
/// ```typ
/// #scene("derivative", x => tangent-at(f, x), stops: (-3, 0, 3))
///
/// #scene-layer("derivative", 2)[At the vertex the slope is zero.]
/// ```
///
/// The scene has to stand *before* its layers in the source, because a layer
/// looks up which step its stop was given. Standing after them, the package
/// says so rather than quietly doing nothing.
///
/// A layer stays from its stop to the end of the slide, as `cue-layer`
/// does: what was said at a stop goes on holding afterwards.
#let scene-layer(name, nr, body, enter: "fade") = context {
  let g = szene-gruppen.get()
  assert(name in g, message:
    "typstage: scene-layer(\"" + name + "\") finds no scene of that name. A "
    + "scene() has to stand before its layers in the source, because a layer "
    + "looks up which step its stop was given.")
  let e = g.at(name)
  assert(type(nr) == int and nr >= 1 and nr <= e.stops, message:
    "typstage: scene-layer(\"" + name + "\", " + str(nr) + ") -- that scene "
    + "has " + str(e.stops) + " stop" + (if e.stops == 1 { "" } else { "s" })
    + ", so the number is out of range.")
  anim-kern(body, at: str(e.start + nr - 1) + "-", enter: enter)
}
