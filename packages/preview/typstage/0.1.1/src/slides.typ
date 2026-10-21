// Slides, sections and what belongs to a single slide.

#import "themes.typ": lesbar, theme-state
#import "internal.typ": (clock-state, deck-info, html-output, note-state, notiz-pruefen,
                        papier-zahlen,
                        uebergang-pruefen,
                        step-cursor, step-jetzt, transition-state)

/// A regular slide.
///
/// `title: none`, or a bare `==` in heading form, leaves out the title bar;
/// the body then gets the whole area.
///
/// `invert: true` sets this one slide in the palette turned around, for the
/// slide that carries a single number. The ground becomes the palette's text
/// color and the text becomes its ground; `muted`, `border` and `surface` are
/// mixed from those two; `strong` and `accent` carry over unchanged. The
/// chrome follows, so the running header, the footer and the progress bar are
/// set in the same colors as the slide under them.
///
/// Only a regular slide inverts. A title slide and a section slide are whole
/// pictures the theme draws itself, and three of the five bundled themes build
/// them from colors an inversion would not reach; neither takes the argument.
#let slide(title: none, note: none, transition: none, invert: false, ..rest) = {
  // So that all three notations work: `slide[body]` (without a title),
  // `slide([title])[body]` and `slide(none)[body]`. A single piece is the
  // body, two are title and body.
  // `..rest` would otherwise swallow any named argument without a word: a
  // deck writing `slide(titel: [X])[…]` would get a slide without a title and
  // no hint why. The same check the palette makes on its keys.
  assert(rest.named().len() == 0,
         message: "typstage: slide() does not know "
                + rest.named().keys().join(", ")
                + ". It takes title, note, transition and invert.")
  let teile = rest.pos()
  let kopf = title
  let rumpf = []
  if teile.len() == 1 {
    rumpf = teile.at(0)
  } else if teile.len() >= 2 {
    kopf = teile.at(0)
    rumpf = teile.at(1)
  }
  // Same rule as for `speaker-note`, because this is the other way of writing
  // the same thing. `none` stays legal: that is a slide without a note.
  if note != none { notiz-pruefen(note) }
  (kind: "slide", title: kopf, note: note, transition: transition,
   invert: invert, body: rumpf)
}

/// The same thing in the heading notation, written into the slide body.
///
/// ```typ
/// == Reached in 2026
/// #invert
/// #statement[74 %]
/// ```
///
/// A marker, like `#pause`, because a heading carries no arguments. Unlike
/// `#pause` it is only looked for, never split on, so the walk goes all the
/// way down: it is found in a `block`, an `align`, a table cell, a grid,
/// however deeply nested, in the heading itself, and behind `#set` and
/// `#show`. It is not found where the content is handed to a closure -- in
/// `context`, `fit`, `anim`, `card` or `alternatives` -- and there nothing
/// happens and nothing is said. Measured, those five are the whole of it;
/// `slide(invert: true)` is the form that never depends on the walk.
///
/// It prints nothing, so it may stand anywhere in the body; it inverts the
/// whole slide either way, not the part after it.
#let invert = metadata("typstage-invert")

/// A section slide.
///
/// `depth` is the level in the heading hierarchy the section stands on: `1`
/// for `=`, `2` for `==` and so on, up to one below the deck's `slide-level`.
/// In the heading notation it comes from the heading; here it is written out.
/// The five bundled themes draw a deeper section more quietly, and a theme of
/// your own reads it from `s.depth`.
#let section(title, depth: 1, transition: none) = {
  assert(type(depth) == int and depth >= 1, message:
    "typstage: section(depth: ..) is the heading level, an integer from 1 "
    + "upwards, not " + repr(depth))
  (kind: "section", title: title, depth: depth, note: none,
   transition: transition, body: none)
}

/// The title slide.
#let title-slide(title: [], subtitle: [], author: [], date: none) = (
  kind: "title", title: title, subtitle: subtitle, author: author,
  date: date, note: none, transition: none, body: none,
)

/// How this slide comes in, otherwise the presentation's setting applies.
///
/// - `"none"`: hard cut.
/// - `"fade"`: cross-fade, nothing moves.
/// - `"slide"`, `"push"`, `"cover"`, `"uncover"`: sliding; `from` says where
///   the new slide comes from: `"right"` (default), `"left"`, `"top"`,
///   `"bottom"`. `push` shoves the old one out, `cover` lies down on top,
///   `uncover` pulls the old one away.
/// - `"zoom"`: `direction: "in"` (default) grows the new one towards you,
///   `"out"` lets it step back from the front.
/// - `"blur"`: blurred across.
/// - `"iris"`, `"wipe"`: an aperture. `direction: "open"` (default) opens the
///   new slide out, `"close"` shuts the old one over it. For the wipe, `from`
///   additionally says which edge it starts at.
/// - `"flip"`, `"cube"`: rotation in space; `axis: "y"` (default) turns about
///   the vertical, `"x"` about the horizontal.
///
/// Backwards each one runs as a true reversal. If a morph meets the slide it
/// cross-fades regardless: the movement is then carried by the morph.
///
/// Under `prefers-reduced-motion: reduce` every kind but `"none"` becomes the
/// cross-fade, over the same duration. See the manual.
#let transition(kind, ..spec) = {
  // Positionsargumente wurden hier wortlos verworfen: `#transition("slide",
  // "links")` uebersetzte und tat nichts. Alle Geschwister sagen es.
  assert(spec.pos().len() == 0, message:
    "typstage: transition() takes the name and then named options, for "
    + "example `#transition(\"slide\", direction: \"left\")`.")
  uebergang-pruefen(kind, "transition")
  transition-state.update((kind: kind) + spec.named())
}

/// What the deck knows about itself, read from inside a slide.
///
/// ```typ
/// #context {
///   let deck = info()
///   [#deck.section.title #h(1fr) #deck.slide.number/#deck.slide.total]
/// }
/// ```
///
/// It is the same reading the built-in chrome does. Every number the package
/// prints on a slide, the footer, the fraction, the length of the progress bar
/// and the running header, comes out of this function and out of no second
/// count, so a hand-built footer and the built-in one cannot disagree.
///
/// What comes back, as a dictionary:
///
/// - `title`, `subtitle`, `author`, `date`: the deck's own particulars, as
///   `presentation` or a `title-slide` received them.
/// - `slide.number`, `slide.total`: this slide and how many there are.
///   Counted the way the footer counts, so title and section slides are not
///   in it.
/// - `slide.numbered`: whether this slide is one of the counted ones. It is
///   `false` on a title slide and on a section slide, and `number` then holds
///   the last slide counted before it, 0 on a cover that opens the deck. A
///   footer can therefore leave its counter slot clear instead of printing a
///   zero into it.
/// - `step.number`, `step.total`: this deck counts in steps as well as in
///   slides, which no footer can guess at. `number` is the step the calling
///   content itself stands on: 1 in the body of a slide, and inside an
///   `anim`, a `stagger` or an `alternatives` the step of that reveal, its
///   first one where it covers several. On paper a slide is one page in its
///   final state, so `number` is `total` there.
/// - `section.number`, `section.total`, `section.title`: which section the
///   slide belongs to, how many the deck has, and its title. The section is
///   always the level directly above the slide, so at the default
///   `slide-level: 2` this is the `=` heading and nothing about it has
///   changed. Before the first such heading, `number` is `0` and `title` is
///   `none`. A deck at `slide-level: 1` has no structure level at all, and
///   then all three read `0`, `0` and `none`.
/// - `levels`: one entry per structure level, from the outermost inwards, so
///   `levels.last()` is the same section as above and `levels.first()` the
///   outermost part. Empty at `slide-level: 1`. Each entry carries
///   `depth` (1 for `=`, 2 for `==`), `title` (`none` while no section of
///   that level is running), `number` and `total` (counted across the whole
///   deck, the way `section` counts), and `index` and `count` (counted among
///   the siblings under the same parent, which is what Beamer prints as
///   `1.2`). `number` never goes back, so it also reads as progress; `title`,
///   `index` and `count` clear when the level above them moves on.
/// - `outline`: the whole structure of the deck, one entry per section slide
///   in the order they come, each with `depth`, `title`, `number` (the same
///   count as in `levels`) and `here`, which is `true` only on that section
///   slide itself. Comparing an entry's `number` with
///   `levels.at(entry.depth - 1).number` says whether it is past, running or
///   still to come, and that is how a progressive agenda is built.
///
/// Only in a context. *Before* any presentation has run there is nothing to
/// read and this stops with a message rather than handing out zeros. *After*
/// one it does not: whoever passes the slides as arguments and writes an
/// `info()` below the call still gets the last slide's numbers. Clearing the
/// deck's own record at the end would close that, and it was measured: a slide
/// carrying one reveal beside a `tiles` went from no layout warning to three
/// "did not converge" ones. A corner nobody stands in is not worth that, and in
/// the show-rule notation nothing comes after the deck anyway.
#let info() = {
  let stand = deck-info.get()
  assert(stand != none, message:
    "typstage: info() reads what the deck knows about itself and therefore "
    + "works only inside a presentation.")
  // A footer stands inside the slide whose step count it wants, and that count
  // is only settled once the slide has been laid out. So the count is fetched
  // from the far end: `slide-body` leaves a mark there carrying the slide's
  // number, and the cursor is read at that mark. The same forward reference as
  // "page 3 of 12", and read straight off the counter rather than passed
  // through a state, which would cost one layout run too many.
  let gesamt = if not html-output.get() {
    // Auf Papier aus dem Zustand: dort gibt es die Marke nicht, weil eine
    // Folie mehrere Seiten setzen kann.
    papier-zahlen.final().at(str(stand.nr), default: 1)
  } else {
    let ende = query(<typstage-slide-end>).find(e => e.value == stand.nr)
    if ende == none { 1 } else {
      calc.max(1, step-cursor.at(ende.location()).first())
    }
  }
  stand.data + (step: (
    // Paged output has no current step. Every page shows the slide in its
    // final state, everything at once, so the step shown is the last one.
    number: if html-output.get() { step-jetzt() } else { gesamt },
    total: gesamt,
  ))
}

/// How the deck is cut, section by section.
///
/// `info()` says where you are; this says how the whole thing is divided. One
/// entry per section, in the order they come, each with the slides beneath it:
///
/// ```typ
/// #context for a in deck-outline() {
///   [#a.number. #a.title -- slides #a.first to #a.last (#a.count)]
/// }
/// ```
///
/// `first`, `last` and `count` are transitive: a depth-1 section counts the
/// slides of its sub-sections too. A section with no slides under it has
/// `none` for `first` and `last`, and 0 for `count`.
///
/// Read straight off the state every slide already carries. No `query`, no
/// second walk over the document, and the same answer in both outputs.
#let deck-outline() = {
  let stand = deck-info.get()
  assert(stand != none, message:
    "typstage: deck-outline() reads how the deck is cut and therefore works "
    + "only inside a presentation.")
  stand.data.at("structure", default: ())
}

/// A linked contents list for the deck.
///
/// The target is a location rather than a page dictionary, so PDF readers can
/// change pages without changing the reader's zoom. In HTML the runtime maps
/// the generated internal target to the containing slide.
/// `number` replaces the complete number cell and receives one outline entry.
/// `title` replaces the complete linked title cell and receives the entry and
/// its destination location. Both default to the built-in rendering.
/// Set `number: none` to hide the number cell completely.
/// Text styling is controlled by these two renderers as a whole.
/// `layout: "1x1"` keeps one directory item per row; `layout: "1x2"` places
/// directory items in two balanced columns; `layout: "1x2-fill"` fills the
/// first column by available space before flowing into the second.
/// `from` and `to` select an inclusive, one-based range of directory entries;
/// `to: auto` selects through the final entry.
///
/// ```typ
/// #contents(
///   number: entry => [#strong[#entry.number.]],
///   title: (entry, destination) => link(destination)[#entry.title],
/// )
/// ```
#let contents(
  layout: "1x1",
  columns: (auto, 1fr),
  row-gutter: 20pt,
  column-gutter: 16pt,
  from: 1,
  to: auto,
  number: auto,
  title: auto,
  indent: auto,
  highlight: false,
) = context {
  assert(layout in ("1x1", "1x2", "1x2-fill"), message:
    "typstage: contents(layout: ...) expects \"1x1\", \"1x2\" or "
    + "\"1x2-fill\", not "
    + repr(layout))
  assert(type(from) == int and from >= 1, message:
    "typstage: contents(from: ...) expects a positive entry number, not "
    + repr(from))
  assert(to == auto or (type(to) == int and to >= from), message:
    "typstage: contents(to: ...) expects auto or an entry number >= from, not "
    + repr(to))
  assert(indent == auto or indent == none or type(indent) == length, message:
    "typstage: contents(indent: ...) is how far a deeper level steps in: a "
    + "length, `auto` for the default, or `none` to set every level flush. "
    + "Not " + repr(indent))
  assert(type(highlight) == bool, message:
    "typstage: contents(highlight: ...) is true or false -- whether the "
    + "entries say where the talk stands. Not " + repr(highlight))
  let all-entries = deck-outline()
  let last = if to == auto { all-entries.len() } else { to }
  let entries = all-entries.enumerate()
    .filter(((index, entry)) => index + 1 >= from and index + 1 <= last)
    .map(((index, entry)) => entry)
  // Die Farben kommen aus dem Theme, nicht aus `config.typ`. Dort stehen die
  // Konstanten der Vorgabe -- ein Verzeichnis, das sie liest, trägt auf
  // `themes.night` orangene Kreise, während der Akzent des Themes cyan ist,
  // und Titel in #23303f auf fast schwarzem Grund. Gemessen an einem Deck in
  // beiden Themes: unter `default` fiel es nicht auf, weil dessen Akzent
  // zufällig genau diese Konstante ist.
  //
  // `lesbar` wählt die Schrift auf dem Akzent so, wie es der Kontrastvertrag
  // von jedem anderen Baustein des Pakets verlangt.
  let t = theme-state.get()
  // ── Wo der Vortrag gerade steht ─────────────────────────────────────────
  //
  // `levels` nennt je Ebene den laufenden Abschnitt; die Nummer eines Eintrags
  // damit verglichen sagt, ob er vorbei ist, läuft oder noch kommt. So ist das
  // Datenmodell entworfen -- `contents()` hat es bisher nur nicht genutzt.
  // Jeder Eintrag bekommt das als `when` mit, auch die eigenen
  // Renderfunktionen: wer die Hervorhebung anders will, baut sie sich daraus.
  let ebenen = info().levels
  let wann = eintrag => {
    if eintrag.depth > ebenen.len() { return "coming" }
    let hier = ebenen.at(eintrag.depth - 1).number
    if eintrag.number < hier { "past" }
    else if eintrag.number == hier { "running" }
    else { "coming" }
  }
  let schritt = if indent == auto { 1.4em } else if indent == none { 0pt }
                else { indent }
  // Gedämpft, was nicht läuft -- und nur wenn `highlight` an ist. Sonst sieht
  // ein Verzeichnis aus wie bisher.
  let blass = farbe => farbe.transparentize(55%)
  let number-render = if number == auto {
    // Kein Kreis. Eine Ziffer in einer gefüllten Ellipse ist eine Form, die
    // nichts sagt -- sie war zudem weiß auf Orange, was den Kontrastvertrag
    // des Pakets (4,5) mit rund 3,0 verfehlt. Die naheliegende Rettung, die
    // Ziffer dunkel zu setzen, liest sich auf Orange kaum besser.
    //
    // Also typografisch statt dekorativ: die Zahl in der ersten Farbe, die
    // auf dem Papier trägt, tabellarische Ziffern, damit zwei- und
    // einstellige Nummern untereinander stehen.
    entry => text(
      fill: {
        let f = lesbar(t.paper, t.accent, t.strong, t.ink)
        if highlight and entry.when != "running" { blass(f) } else { f }
      },
      weight: "medium",
      features: (tnum: 1),
    )[#entry.number.]
  } else if number == none { entry => [] }
  else { number }
  let title-render = if title == auto {
    (entry, destination) => link(destination)[
      #text(fill: if highlight and entry.when != "running" { blass(t.ink) }
                  else { t.ink },
            weight: if highlight and entry.when == "running" { "medium" }
                    else { "regular" })[#entry.title]
    ]
  } else { title }
  let gesetzt = roh => {
    let entry = roh + (when: wann(roh))
    let destination = query(<typstage-slide-target>)
      .find(slide => slide.value == entry.target + 1)
      .location()
    if number == none {
      grid(
        columns: (1fr,),
        title-render(entry, destination),
      )
    } else {
      grid(
        columns: columns,
        column-gutter: column-gutter,
        number-render(entry),
        title-render(entry, destination),
      )
    }
  }
  let item = roh => {
    let einzug = schritt * (roh.depth - 1)
    if einzug == 0pt { gesetzt(roh) } else { pad(left: einzug, gesetzt(roh)) }
  }
  let column-major = {
    let rows = calc.div-euclid(entries.len() + 1, 2)
    let ordered = ()
    for i in range(rows) {
      ordered.push(entries.at(i))
      let second = i + rows
      if second < entries.len() { ordered.push(entries.at(second)) }
    }
    ordered
  }
  let flow = entries.map(entry => block(below: row-gutter, item(entry))).join()
  [
    #metadata(none) <typstage-contents>
    #if layout == "1x2-fill" {
      std.columns(2, gutter: column-gutter)[#flow]
    } else if layout == "1x2" {
      grid(
        columns: (1fr, 1fr),
        row-gutter: row-gutter,
        column-gutter: column-gutter,
        ..column-major.map(item),
      )
    } else {
      grid(
        columns: (1fr,),
        row-gutter: row-gutter,
        ..entries.map(item),
      )
    }
  ]
}

/// A note for the presenter view, which `n` opens in a second window.
///
/// The note has to carry text: the presenter view transports it as a string,
/// so a note made purely of layout would arrive nowhere. That is refused with
/// a message rather than silently dropped.
#let speaker-note(body) = {
  notiz-pruefen(body)
  note-state.update(body)
}

/// Plans a class clock for this slide: how many minutes the work on it is
/// meant to take.
///
/// It starts nothing. `Shift+T` in the presenter view offers the number, the
/// speaker confirms or changes it, and only then does the clock run -- the
/// deck knows how long the task was meant to take, the room decides how long
/// it actually gets. A slide carries at most one; a second call replaces the
/// first, like a second `speaker-note`.
#let class-clock(minutes) = {
  assert(type(minutes) == int or type(minutes) == float,
         message: "class-clock() wants a number of minutes, got "
                  + str(type(minutes)))
  assert(minutes >= 1,
         message: "class-clock() wants at least one minute, got "
                  + str(minutes))
  clock-state.update(calc.round(minutes))
}
