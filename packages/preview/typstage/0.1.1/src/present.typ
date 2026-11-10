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
      out.push((kind: "heading", depth: c.depth, body: c.body))
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
/// `==` a slide.
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
///
/// The PDF is a handout: one page per slide, every tracked element in its
/// final state. What belongs only to the motion, the notes, the slide transitions,
/// the bridge jobs, are state updates without output and fall away by themselves.
///
/// `overflow` is a checking pass over the deck, off by default. It measures
/// every slide body against the room the theme gives it and names the ones
/// that do not fit, with the earliest step on which the overrun can be on the
/// screen. Title and section slides are not measured: the theme draws them
/// with `place` and they have no body block.
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
  pages: "slide",
) = {
  // `..slides` would otherwise swallow any named argument without a word:
  // `presentation(pallete: palettes.dark)` did nothing and said nothing. The
  // same check `palette-pruefen` makes on a palette's keys.
  assert(slides.named().len() == 0, message:
    "typstage: presentation() does not know "
    + slides.named().keys().join(", ")
    + ". It takes title, subtitle, author, date, assets, theme, palette, "
    + "transition, transition-duration, duration, speaker-view, style, width, "
    + "height, margin, handout, overflow, drift, slide-level, "
    + "section-numbering and pages.")
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
    + ". It knows clock, target, tools and pen.")
  for k in speaker-view.keys() {
    assert(k in ("clock", "target", "tools", "pen"), message:
      "typstage: speaker-view has no entry \"" + k + "\". It takes clock "
      + "(the class clock), target (the planned length), tools (the drawing "
      + "bar) and pen.")
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
  // Eine Fußnote in der Überschrift bricht ab, statt still falsch zu stehen:
  // der Titel wird wiederholt, und jede Wiederholung setzt sie neu. Vor der
  // Abzweigung darunter, denn eine Titel- oder Abschnittsfolie hat keinen
  // Rumpf und käme dort nie vorbei.
  for s in all {
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
  let all = all.map(s => if s.body == none { s } else {
    // The marker is looked for in the body as it was written, before the
    // pauses cut it into runs: after that, a marker standing behind a pause
    // sits inside an `anim` wrapper and the walk would miss it. The title is
    // searched too, because in heading notation `== A slide #invert` is the
    // place the marker naturally lands, and it went unseen there.
    s + (invert: s.at("invert", default: false)
                 or hat-invert(s.body) or hat-invert(s.title),
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
                       section-numbering: section-numbering))
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
  context if target() != "html" and handout != false {
    let per = if handout == true { 2 } else { handout }
    assert(type(per) == int and per >= 1 and per <= 6,
           message: "typstage: handout takes true or 1 to 6 slides per page")
    theme-state.update(thema-hell)
    html-output.update(false)
    papier-modus.update(pages)
    drift-modus.update(drift)
    handout-body(all, facts, style, geo, thema-hell, per,
                 thema: if wechselt { thema } else { none }, overflow: overflow)
    ueberlauf-bericht(overflow)
    cue-luecken-bericht()
    drift-bericht(drift)
  } else if target() != "html" {
    set page(width: geo.width, height: geo.height, margin: 0pt)
    theme-state.update(thema-hell)
    // Said out loud, not left to the default. `bundle()` writes several
    // documents from one compilation, and a state carries on from one into the
    // next: without this the slide deck and the handout of a bundle were still
    // being built as if they were the browser's, and every tracked element
    // stayed in `hide()` and was missing from the PDF. Measured on a bundle
    // with an `anim` and an `alternatives`, and the same for the handout above.
    html-output.update(false)
    papier-modus.update(pages)
    drift-modus.update(drift)
    // `pages: "step"` setzt jede Folie so oft, wie sie Schritte hat. Wie
    // viele das sind, sagt `papier-zahlen` -- ein Zustand und keine Marke,
    // denn jede Seite einer Folie schriebe die Marke erneut, ihre Zahl wüchse
    // mit der Seitenzahl, und daran gibt Typst auf.
    //
    // Im ersten Layoutlauf ist der Zustand leer, dann steht eine Seite je
    // Folie da; im zweiten stimmt die Folge. Deshalb ein `context` um die
    // ganze Schleife.
    context {
      let zahlen = papier-zahlen.final()

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
          seiten.push((if j == 0 { slide-counter.step() } else { none })
                 + deck-info.update(facts.at(i))
                 // Nothing is revealed on paper, but the cursor counts here
                 // too, so that `info().step.total` reports the same number in
                 // both outputs. It has to start over on every slide.
                 + step-cursor.update(0)
                 // Und die Basen der cue-Gruppen, aus demselben Grund.
                 + cue-basis.update(_ => (:))
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
                 + slide-body(s, style, geo, thema(s), overflow: overflow,
                              schritt: k, nr: nr))
        }
      }
      seiten.join(pagebreak(weak: true))
    }
    ueberlauf-bericht(overflow)
    cue-luecken-bericht()
    drift-bericht(drift)
  } else {
    html-output.update(true)
    drift-modus.update(drift)
    theme-state.update(thema-hell)
    morph-index.update(())
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
        if s.kind == "slide" {
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
          html.frame(slide-chrome(geo, thema(s), fortschritt: false))
        } else { [] }))
      parts.push({
        slide-counter.step()
        deck-info.update(hier)
        element-counter.update(0)
        step-cursor.update(0)
        // Und die Basen der cue-Gruppen: daran haengt, dass eine Gruppe zu
        // einer Folie gehoert.
        cue-basis.update(_ => (:))
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
          if s.kind == "slide" {
            html.elem("div", attrs: (class: "ts-chromep"), {
              step-here.update(())
              sprite-number.update(none)
              html.frame(slide-chrome(geo, thema(s)))
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
              sprites.get().enumerate()
                .map(((i, sp)) => sprite-markup(sp, i + 1, style)).join()
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
            let meine-morphs = sprites.get()
              .filter(sp => sp.kind == "morph")
              .map(sp => (slide: here, name: sp.extra.name,
                          ab-eins: ab-schritt-eins(sp.at)))
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
        if fs != none {
          html.elem("div", attrs: (
            id: "ts-fortschritt",
            style: "height:" + str(calc.round(fs.hoehe.pt(), digits: 2)) + "pt;"
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
        let ende = query(<typstage-slide-end>).find(e => e.value == d.slide)
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
      for m in alle-morphs.filter(m => not m.ab-eins) {
        let vorher = alle-morphs.filter(v => v.slide == m.slide - 1 and v.name == m.name)
        assert(vorher.len() == 0, message:
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
        + ",\"words\":" + json.encode((
            noNote: worte.no-note,
            help: worte.help,
            helpSpeaker: worte.help-speaker,
            helpSpeakerShort: worte.help-speaker-short,
            sp: worte.sp,
          )) + "}")
    if assets == "inline" { html.elem("script", runtime-js) } else { links.js }
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
/// Verified: the counters start over for each output. The slide deck numbers
/// its slides 1, 2, 3 and does not continue counting where the HTML version
/// left off, even though Typst runs introspection across the whole bundle.
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
  if html != none {
    document(html, { show: presentation.with(..args); body })
  }
  if slides != none {
    document(slides, { show: presentation.with(..args); body })
  }
  if handout != none {
    document(handout, { show: presentation.with(handout: per-sheet, ..args); body })
  }
}
