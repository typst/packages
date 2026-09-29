// The visible chrome of a slide.
//
// Not a Touying theme: header, footer, section slide and title slide are built
// by hand here. The default theme resembles Metropolis but is not the same
// thing.
//
// What is written here is only *how* things are drawn: *what* is drawn is
// said by the theme (see `themes.typ`). Every number below is either a
// measure from the theme or a point value on the default canvas, scaled
// along with `k`.
//
// Every shape drawn here carries a label, so a deck can restyle it with an
// ordinary `show` rule instead of forking the theme. One rule of thumb keeps
// those labels usable, and it was learned the hard way from Typst's
// precedence: a label goes *inside* the `text(..)` or the `set rect(..)` that
// gives the shape its default look, never around it. An explicit constructor
// argument beats a `set` rule, so `[#text(fill: x)[..] <l>]` could never be
// recolored, while `text(fill: x, [#.. <l>])` can. Measured on four minimal
// cases, and it holds for `rect` and `block` the same way.
//
// Nesting two labels is fine. `[#gruppe <aussen>]` around a group that
// already carries a label attaches to the enclosing group, not to the same
// element, so both rules run and the inner one wins wherever they set the
// same property. Only two labels on the *same* element collide, and Typst
// says so: "content labelled multiple times", and the last one is used.

#import "config.typ": *
#import "internal.typ": (cue-basis, deck-info, folien-notizen, html-output,
                        marker, note-state, notiz-marke-ab,
                        papier-schritt,
                        papier-zahlen,
                        plain-text, slide-counter, sprite-number, step-cursor,
                        step-here, ueberlauf-pruefen, umgebungs-block)
#import "slides.typ": info
#import "themes.typ": font-args, sichtbar, theme-state
#import "richtung.typ": am-anfang, am-ende

/// The body of one slide, background included.
///
/// The same block serves both outputs: in HTML it becomes the background layer
/// under the overlay, on paper it is the page.
///
/// `t` is the theme: all colors, fonts and measures come from there, and
/// it draws the title slide and the section slide itself.
/// Footer and progress: everything that looks the same on every slide and
/// differs only in the counter reading.
///
/// Deliberately stands on its own: in the browser it is *not* drawn into
/// the slide, but laid over it as its own layer. Otherwise the bar would
/// travel out along with the slide on a transition, while the next one
/// comes in: you would see two bars cross instead of one grow. In the PDF
/// there is no transition, so there both belong on the page.
/// How tall the header builds in the book style. Needed in two places:
/// `slide-chrome` draws it, `slide-body` has to place the title below it.
#let lauf-hoehe(t, k) = if t.header == "run" { 27pt * k } else { 0pt }

/// Eine Anmerkungszeile: die Nummer, ein Zwischenraum, der Text.
///
/// Steht hier, weil sie zweimal gesetzt wird und beide Male gleich hoch
/// ausfallen muss: einmal als Schlitz im Hintergrund der Folie, wo sie den
/// Platz hält, und einmal als Sprite in der Überlagerung, wo sie die Tinte
/// trägt. Der Sprite steht in seinem eigenen Rahmen und kennt die `set`-Regeln
/// der Folie nicht -- derselbe Grund, aus dem `with-style` existiert --, also
/// steht die ganze Typografie hier ausdrücklich da.
///
/// Der `style`-Haken des Decks wird ausdrücklich *nicht* angewandt: der
/// Anmerkungsblock im Hintergrund wendet ihn heute auch nicht an, er umschließt
/// nur `s.body`. Täte ihn nur eine der beiden Seiten, liefen Schlitz und Sprite
/// in der Höhe auseinander und das SVG würde verzerrt.
#let notiz-zeile(t, k, zahl, koerper) = {
  set text(..font-args(t.font), size: t.size * 0.62 * k, fill: t.muted)
  set par(leading: 0.5em, spacing: 0.35em)
  // Bekannte Grenze, hier notiert, weil sie an dieser Zeile hängt: Blockinhalt
  // mit eigener Ausrichtung im Rumpf einer Fußnote -- eine abgesetzte Formel,
  // eine `figure`, ein `align(center)` -- steht im Browser mittig und auf
  // Papier am Anfang der Zeile. Gemessen an `#footnote[#align(center)[MITTIG]]`
  // in einem Deck: im PDF bei x = 32 von 841, im Browser in der Folienmitte.
  //
  // Woran das Papier sich festhält, habe ich nicht auflösen können: dieselbe
  // Verschachtelung für sich nachgebaut -- `place(bottom + left, dx, dy,
  // block(width: inner, block(width: 100%, …)))` -- zentriert auch auf Papier,
  // und weder `set align(start)` noch ein `box` um den Rumpf bringt beide
  // Seiten zusammen (das `box` nimmt einer langen Anmerkung den Umbruch).
  // Eine Fußnote trägt Text; wer eine Formel in eine Anmerkung setzt, bekommt
  // sie in beiden Ausgaben zu sehen, nur nicht an derselben Stelle.
  [#super[#zahl]#h(0.35em)#koerper]
}

/// Farbe, Höhe und Lage der Fortschrittsleiste -- oder `none`, wenn das Theme
/// keine zeichnet.
///
/// Gebraucht von `present.typ`: im Browser zeichnet nicht mehr das Theme die
/// Leiste, sondern die Laufzeit, damit sie beim Folienwechsel *wächst* statt
/// überzublenden. Das Theme behält die Entscheidung, ob und wie sie aussieht;
/// hier steht nur, was die Laufzeit dafür wissen muss.
#let fortschritt-stil(geo, t) = {
  if t.progress != "bar" and t.progress != "top" { return none }
  (
    farbe: sichtbar(t.paper, t.accent, t.strong, t.ink),
    hoehe: 2.5pt * geo.scale,
    oben: t.progress == "top",
  )
}

/// `fortschritt: false` lässt die Leiste weg -- für die HTML-Ausgabe, wo die
/// Laufzeit sie selbst zieht. Auf Papier und in der Druckansicht bleibt sie,
/// wo sie war.
#let slide-chrome(geo, t, fortschritt: true) = context {
  // Every number below comes out of `info()`, and that is the point of the
  // detour: the deck may call the same function, so a hand-built footer and
  // this one read the same dictionary and cannot disagree.
  let d = info()
  let n = d.slide.number
  let total = d.slide.total
  let sect = d.section.title
  let k = geo.scale
  let m = margins(geo)
  let inner = geo.width - m.left - m.right
  block(width: geo.width, height: geo.height, {
    // Die Schrift des Themes, ausdruecklich. Auf dem Papier liegt die Zier
    // in der Seite und erbt sie von `slide-body`; im Browser ist sie eine
    // eigene Ebene ueber der Buehne und damit ausserhalb jenes Geltungs-
    // bereichs. Ohne diese Zeile fielen laufender Kopf und Foliennummer dort
    // auf Typsts Vorgabeserife zurueck -- in jedem Deck mit einer Grotesk,
    // also fast allen, und nur im HTML. Nachgemessen an `unterrichten`.
    set text(..font-args(t.font))
    // The textbook's running header: page number on the left, chapter on
    // the right, a hairline underneath. It belongs to the layer above the
    // stage, not to the slide. It stays in place while paging, as does
    // the footer, otherwise the orientation it is meant to give would
    // travel out with the slide.
    if t.header == "run" {
      let zeile = text(size: 11.5pt * k, fill: t.muted, [#{
        str(n)
        if sect != none [ #h(1fr) #sect ]
      } <ts-slide-header-text>])
      am-anfang(top, m, dy: m.top * 0.62, block(width: inner, zeile))
      place(top + left, dx: m.left, dy: m.top * 0.62 + 17pt * k, {
        set rect(fill: t.rule-fill, stroke: none)
        [#rect(width: inner, height: 0.9pt * k) <ts-slide-header-rule>]
      })
    }
    // Footer: the number, optionally with the total, and a hairline above
    // it.
    if t.footer-rule > 0pt {
      place(bottom + left, dx: m.left, dy: -(t.foot-gap + 6pt) * k, {
        set rect(fill: t.border, stroke: none)
        [#rect(width: inner, height: t.footer-rule * k) <ts-slide-footer-rule>]
      })
    }
    // Two labels, one inside the other: the footer line is what a deck
    // restyles as a whole, the number is the part it may want smaller or in
    // another color on its own. Both attach, because the outer one lands on
    // the enclosing group rather than on the same element.
    let zahl = [#[#{
      if t.footer == "fraction" { str(n) + " / " + str(total) } else { str(n) }
    } <ts-slide-number>] <ts-slide-footer>]
    if t.footer == "center" {
      place(bottom + center, dy: -13pt * k, text(size: 12pt * k, fill: t.muted, zahl))
    } else if t.footer != "none" {
      am-ende(bottom, m, dy: -13pt * k,
              text(size: 12pt * k, fill: t.muted, zahl))
    }
    // Progress: a growing bar at the bottom or top, or a marker that
    // travels along its track: even at seventy slides that still shows
    // where you are, while the bar there only grows longer very slowly.
    // The accent unless the ground has swallowed it. On the five bundled
    // themes' own grounds this is the accent, byte for byte; it is the ground
    // an inverted slide lays underneath that this answers.
    let balken = sichtbar(t.paper, t.accent, t.strong, t.ink)
    if not fortschritt and (t.progress == "bar" or t.progress == "top") {
      // Nichts: die Laufzeit zieht sie. `tick` bleibt hier, der Reiter wandert
      // ohnehin und würde als wachsender Balken falsch gelesen.
    } else if t.progress == "bar" {
      // From the edge the writing starts at, like everything else placed
      // by hand here: in a deck that reads from the right the bar grows
      // from the right.
      am-anfang(bottom, none, {
        set rect(fill: balken, stroke: none)
        [#rect(width: 100% * n / total, height: 2.5pt * k) <ts-slide-progress>]
      })
    } else if t.progress == "top" {
      am-anfang(top, none, {
        set rect(fill: balken, stroke: none)
        [#rect(width: 100% * n / total, height: 2.5pt * k) <ts-slide-progress>]
      })
    } else if t.progress == "tick" {
      // The marker must be at least as wide as its own step, otherwise it
      // jumps over gaps instead of traveling. At nine slides the step was
      // 90 points and the marker 34: between two positions there was thus
      // a gap of 56 points with nothing in it. With the factor 1.35, two
      // consecutive positions overlap, and the motion reads as traveling.
      let breite = calc.max(34pt * k, geo.width * 1.35 / total)
      // From 0 to all the way right over `total - 1` steps: the first
      // slide stands at the start of the track, the last at the end.
      // Previously the calculation ran over `n / total`, which meant the
      // marker was already advanced a bit on slide one and never reached
      // the end.
      let schritte = calc.max(1, total - 1)
      place(bottom + left, {
        // The track the marker travels on. Lightened on a light palette,
        // darkened on a dark one, as in `card` and `callout`: a track
        // lightened by 78 percent is a bright band across a dark slide.
        set rect(fill: if t.inverted { balken.darken(70%) }
                       else { balken.lighten(78%) }, stroke: none)
        [#rect(width: 100%, height: 3pt * k) <ts-slide-progress-track>]
      })
      am-anfang(bottom, none, dx: (geo.width - breite) * (n - 1) / schritte, {
        set rect(fill: balken, stroke: none)
        [#rect(width: breite, height: 3pt * k) <ts-slide-progress>]
      })
    }
  })
}

/// `schritt` ist der Schritt, der gerade gesetzt wird, oder `none` für alles
/// auf einmal. Er wird hier gesetzt und nicht von außen: gäbe man ihn nur über
/// den Zustand mit, bekämen alle Seiten einer Folie denselben Aufruf mit
/// denselben Argumenten -- und Typst gibt für gleichen Inhalt das gemerkte
/// Layout zurück, also viermal dieselbe Seite.
#let slide-body(s, style, geo, t, chrome: true, overflow: "none",
                schritt: none, nr: none) = block(
  width: geo.width, height: geo.height,
{
  papier-schritt.update(schritt)
  // A mark at the end of the slide, so that a footer inside it can ask the
  // step cursor how far it got. The mark carries the slide's running number,
  // which is what `info()` matches on.
  //
  // The reading is taken off the *counter* at this mark rather than filed into
  // a state here and read back from there, and that is not a matter of taste.
  // A cursor-reading group such as `stagger` or `tiles` builds its step
  // numbers out of what it read, so the cursor already sits at the end of a
  // chain several layout runs long; writing that value into a state puts one
  // more run on top, and Typst allows five. Measured on a slide with two such
  // groups: with the state, "did not converge" in both outputs; reading the
  // counter at this mark, the same slide behaves exactly as it did before
  // `info()` existed.
  //
  // `place`, so it takes no room in the flow. The block is exactly slide-high
  // and already full; anything joined into it after the ground rect would sit
  // in a flow that has nothing left to give.
  //
  // Machinery, not a shape, so it is named like the bridge's marker and not
  // like the `ts-` labels a deck restyles.
  // Diese Marke nur einmal je Folie: ihre Zahl darf nicht mit der Seitenzahl
  // wachsen, sonst konvergiert das Dokument nicht.
  let schritt-summe = place(top + left, context {
    // Nur einmal je Folie: `info()` fragt diese Marke ab, und ihre Zahl darf
    // nicht mit der Seitenzahl wachsen.
    // Nur im Browser. Auf Papier setzt jede Folie mehrere Seiten, und die
    // Marke käme je Seite noch einmal -- ihre Zahl wüchse mit der Seitenzahl,
    // die Seitenzahl hängt an ihr, und daran gibt Typst auf. Dort sagt
    // `papier-zahlen` dasselbe, ohne zu wachsen.
    if html-output.get() {
      [#metadata(deck-info.get().nr) <typstage-slide-end>]
    }
    // Die Halte dieser Folie und ihre Schrittzahl unter ihre Nummer schreiben.
    // Hier und nicht im Element selbst: dort kostete die Folienlesung die
    // Konvergenz.
    let nr = str(deck-info.get().nr)
    let n = calc.max(1, step-cursor.get().first())
    papier-zahlen.update(d => if d.at(nr, default: none) == n { d }
                              else { d + ((nr): n) })
  })
  // Nur auf der ersten Seite einer Folie. `contents()` fragt diese Marke ab;
  // käme sie je Seite noch einmal, wüchse ihre Zahl mit der Seitenzahl, und
  // die Seitenzahl hängt an dem, was die Folie an Schritten hat -- eine
  // Rückkopplung, die Typst nach fünf Läufen aufgibt. Gemessen an einem Deck
  // mit `contents()` und `pages: "step"`: "query for elements labelled
  // `typstage-slide-target` did not stabilize".
  //
  // Geprüft wird das Argument und nicht der Zustand: ein Vergleich, keine
  // Lesung. Der Verweis führt damit auf die erste Seite der Folie, und das ist
  // die richtige -- dort schlägt sie auf.
  // Die Nummer kommt als Argument und nicht aus `deck-info`: der Fund steht in
  // einem `place`, und platzierter Inhalt löst seinen `context` unzuverlässig
  // auf, sobald eine Folie mehrere Seiten setzt. Gemessen bei `pages: "step"`
  // fehlten dadurch Marken und andere kamen dreifach -- `contents()` fand sein
  // Ziel nicht mehr und brach ab.
  let navigations-ziel = if schritt != none and schritt != 1 { none } else {
    place(center + horizon, [#metadata(nr) <typstage-slide-target>])
  }
  // Everything below is measured on the default canvas and scaled with it, so
  // a smaller or wider slide keeps its proportions.
  let k = geo.scale
  let m = margins(geo)
  let inner = geo.width - m.left - m.right
  // Font size: on an 841pt wide canvas, Typst's default of 11pt is fine
  // print; a theme here sets around 19pt.
  //
  // Font, size and text color are set *here*, not in the `style` hook:
  // that sits further inside, and whatever is set there overrides the
  // theme.
  set text(..font-args(t.font), size: t.size * k, fill: t.ink)
  // No label around these two: their parts carry their own, and a collective
  // `ts-title-slide` would have read like `ts-slide-title` with the words
  // swapped. A theme bringing its own title slide function draws none of
  // them, and nothing warns about that.
  if s.kind == "title" {
    (t.title-slide)(t, s, geo)
  } else if s.kind == "section" {
    let title = if s.section-numbering == none { s.title } else {
      let prefix = if type(s.section-numbering) == function {
        (s.section-numbering)(s.number)
      } else {
        numbering(s.section-numbering, s.number)
      }
      [#prefix #s.title]
    }
    (t.section)(t, s + (title: title), geo)
    context {
      let targets = query(<typstage-contents>)
      if targets.len() > 0 {
        place(bottom + right, dx: -m.right, dy: -m.bottom,
          link(targets.first().location())[
            #text(size: 11pt * k, fill: t.accent)[Back to contents]
          ])
      }
    }
  } else {
    // A slide without a title gets no bar: `slide(none)[…]` or a bare
    // `==`. The body then moves up and gets the height the bar would
    // otherwise have occupied, since otherwise a titleless slide would be
    // smaller than one with a title.
    // `plain-text` used to return `none` for an empty heading rather than "";
    // it no longer does, and the `!= none` below is the belt beside the braces.
    let roh = if s.title == none { none } else { plain-text(s.title) }
    let titel = roh != none and roh.trim() != ""
    let bar = t.band-height * k
    let strich = if t.rule-size > 0pt {
      t.rule-size * k + t.title-size * 0.34 * k
    } else { 0pt }
    // How tall the head builds. With the bar, that is set in the theme;
    // without a bar, the title line's height is computed rather than
    // measured: measuring would mean setting the title twice, and the
    // spacing below absorbs the few points of difference anyway.
    let lauf = lauf-hoehe(t, k)
    let kopf = if not titel { m.top + lauf } else if t.header == "band" { bar } else {
      m.top + lauf + t.title-size * 1.35 * k + strich
    }
    let titel-text = text(
      ..font-args(t.title-font), size: t.title-size * k, weight: t.weight,
      fill: t.title-fill, tracking: t.tracking * k, [#s.title <ts-slide-title>],
    )
    {
      set rect(fill: t.paper, stroke: none)
      [#rect(width: 100%, height: 100%) <ts-slide-ground>]
    }
    if titel and t.header == "band" {
      place(top + left, {
        set rect(fill: t.strong, stroke: none)
        [#rect(width: 100%, height: bar) <ts-slide-header-band>]
      })
      am-anfang(top, m,
        block(width: inner, height: bar, align(start + horizon, titel-text)))
    } else if titel {
      // The same trap as in the callout: without `above`/`below` set, the
      // paragraph spacing would additionally sit between the title and
      // the line, and the line would slide towards the content instead
      // of the title.
      am-anfang(top, m, dy: m.top + lauf, block(width: inner, {
        block(above: 0pt, below: 0pt, titel-text)
        if t.rule-size > 0pt {
          block(above: t.title-size * 0.34 * k, below: 0pt, {
            set rect(fill: t.rule-fill, stroke: none)
            [#rect(width: 100%, height: t.rule-size * k) <ts-slide-title-rule>]
          })
        }
      }))
    }
    // `slide-chrome` draws the footer and the progress indicator. In the
    // PDF they belong on the page and are drawn along with it here; in
    // the browser they sit as their own layer above the stage, so that
    // they do not travel along on a slide transition.
    // `place`, not into the flow: `slide-chrome` returns a block at the
    // full slide height. In the flow it would push everything below it
    // away, and its `bottom` anchors would refer to itself instead of to
    // the slide.
    if chrome { place(top + left, slide-chrome(geo, t)) }

    // The room the deck's content gets, and the one measure the overflow
    // check asks against. Everything else the slide shows, the band, the
    // title, the footer, the progress, is drawn beside this block with
    // `place` and takes nothing away from it.
    //
    // Not `place(top + left, …)`, though the block fills the width and the
    // anchor makes no difference to where it lands. `place` hands its
    // alignment down into the body, and a fixed `left` there beat the
    // `start` every paragraph resolves for itself: in a deck that reads from
    // the right, every line sat on the left while the lists and columns
    // around it were already mirrored. `am-anfang` hands down `start`.
    let raum = geo.height - kopf - (t.head-gap + t.foot-gap) * k
    am-anfang(top, m, dy: kopf + t.head-gap * k,
      block(width: inner, height: raum, style(s.body)))
    // Die Anmerkungen der Folie, unter dem Rumpf und über der Fußzeile.
    //
    // Gefragt wird die Abfrage und nicht der Rumpf. Ein Gang durch den Inhalt
    // *vor* dem Setzen findet eine Fußnote nur dort, wo sie geschrieben steht:
    // `stagger` und die anderen Aufdeckketten geben ein `context` zurück, und
    // in einen Verschluss sieht kein Gang hinein. Gemessen an einem `stagger`
    // mit zwei Fußnoten fand er null davon, während beide Marken im Satz
    // standen -- ein Verweis ohne Anmerkung, also schlimmer als nichts.
    //
    // Zugeordnet wird über `deck-info` am Ort der Fußnote und nicht über die
    // Seitenzahl: im Handout stehen mehrere Folien auf einer Seite, und nach
    // Seiten gefiltert trüge jede die Anmerkungen aller.
    //
    // Die Nummer kommt aus dem Zähler am Ort der Fußnote und nicht aus der
    // Reihenfolge. Beides ergäbe hier dasselbe, aber nur das eine bleibt
    // richtig, wenn ein Deck `set footnote(numbering: ...)` sagt.
    //
    // `place` wie alles andere, was die Folie neben ihrem Rumpf zeigt: Band,
    // Titel, Fußzeile, Fortschritt. Ein Streifen, der dem Rumpf Höhe abzöge,
    // müsste gemessen werden, und eine gemessene Länge, die in die Höhe des
    // Blocks zurückläuft, ist genau die Rückkopplung, an der dieses Dokument
    // schon zweimal seine Konvergenz verloren hat. So kostet eine Anmerkung
    // den Rumpf nichts, und der Überlaufmelder misst gegen dieselbe Fläche
    // wie zuvor.
    context {
      // Nach Folie *und* Seite. Die Folie allein genügt nicht: `pages: "step"`
      // setzt dieselbe Folie mehrfach, und jede ihrer Seiten trägt dieselben
      // Fußnoten -- gemessen standen die Anmerkungen dreifach untereinander.
      // Die Seite allein genügt auch nicht, siehe das Handout oben.
      // Und nicht aus einem Sprite. Der Rumpf eines verfolgten Elements wird
      // in der Überlagerung ein zweites Mal gesetzt, und seine Fußnoten kämen
      // damit doppelt: gemessen fünf Anmerkungen für drei Fußnoten, die beiden
      // aus einem `stagger` zweimal. Auf Papier gibt es keinen Sprite, dort
      // fiel es nicht auf. Alle drei Lesungen stehen jetzt in
      // `folien-notizen`, weil die Überlagerung dieselbe Liste braucht.
      let fn = folien-notizen(nr, seite: here().page())
      // Im Browser trägt dieser Block keine Tinte mehr, nur noch Luft und
      // Marken: für jede Anmerkung einen Schlitz in Zeilengröße, den die
      // Überlagerung mit einem Sprite füllt. Der Platz steht dabei ab Schritt
      // eins, auch für eine Anmerkung, die erst auf Schritt drei sichtbar wird
      // -- der Schlitz ist `hide`, nicht Weglassen; dieselbe Entscheidung, die
      // `track` für den Rumpf trifft. So springt nichts, wenn die dritte
      // Anmerkung erscheint, und der Fuß der Folie sieht auf Papier aus wie im
      // Browser.
      //
      // Gestapelt wird dabei gar nichts von Hand: Reihenfolge, Zeilenabstand,
      // der Umbruch einer langen Anmerkung über zwei Zeilen und das Wachsen
      // des Stapels nach oben vom `bottom`-Anker aus bleiben unverändert, weil
      // es derselbe Block ist wie zuvor. Zwei Sprites können sich damit nicht
      // überlagern: ihre Marken liegen untereinander, und ein Sprite ist so
      // groß wie seine Marke.
      let im-browser = html-output.get()
      if fn.len() > 0 {
        place(bottom + left, dx: m.left, dy: -(t.foot-gap + 12pt) * k,
          block(width: inner, {
            set text(size: t.size * 0.62 * k, fill: t.muted)
            set par(leading: 0.5em, spacing: 0.35em)
            block(above: 0pt, below: 0.45em, {
              set rect(fill: t.muted, stroke: none)
              [#rect(width: 26%, height: 0.5pt * k) <ts-slide-notes-rule>]
            })
            [#block(width: 100%, {
              for (i, f) in fn.enumerate() {
                // `marker(n)` fasst 16 Bit. Eine Folie mit 32768 Anmerkungen
                // gibt es nicht, aber die Grenze soll reden statt zu
                // vertauschen.
                assert(i < notiz-marke-ab, message:
                  "typstage: a slide cannot carry more than "
                  + str(notiz-marke-ab) + " footnotes.")
                let zahl = counter(footnote).at(f.location()).first()
                let zeile = notiz-zeile(t, k, zahl, f.body)
                block(above: if i == 0 { 0pt } else { 0.35em }, below: 0pt,
                      if im-browser {
                        block(width: 100%, fill: marker(notiz-marke-ab + i),
                              hide(zeile))
                      } else { zeile })
              }
            }) <ts-slide-notes>]
          }))
      }
    }
    // `place`, like the mark above: the block is already slide-high and full,
    // and the check must not take a single point from the body it measures.
    // Only for slides. A title or a section slide is drawn by the theme with
    // `place` and has no body block to overrun.
    if overflow != "none" {
      place(top + left, context ueberlauf-pruefen(
        deck-info.get().data.slide.number, style(s.body), inner, raum,
        // The step is read off the slide's own reveals, and on paper there
        // are none: every step stands on the page at once.
        schritte: html-output.get()))
    }
  }
  // Last, because only here has the cursor seen every reveal of the slide.
  navigations-ziel + schritt-summe
})

/// A hook that wraps a document template around every body and every sprite.
/// Both have to receive the same typography: they are laid out separately.
#let with-style(s, body) = {
  set text(size: s.style.size, fill: s.style.fill, font: s.style.font,
           weight: s.style.weight, style: s.style.style, lang: s.style.lang,
           dir: s.style.at("dir", default: auto),
           tracking: s.style.at("tracking", default: 0pt),
           spacing: s.style.at("spacing", default: 100% + 0pt))
  set par(leading: s.style.at("leading", default: 0.65em),
          spacing: s.style.at("par-spacing", default: 1.2em),
          justify: s.style.at("justify", default: false),
          first-line-indent: s.style.at("first-line-indent", default: 0pt),
          hanging-indent: s.style.at("hanging-indent", default: 0pt))
  body
}

/// Slides shrunk onto paper, with room beside or below each one.
///
/// The `slide-body` above is reused unchanged and merely scaled: a handout
/// that redrew the slides could drift away from them.
///
/// Where a slide has a speaker note it stands in that room; where it has none,
/// ruled lines take its place. Both are the same thing really: the space is
/// for whatever is not on the slide itself.
#let handout-body(all, facts, style, geo, t, per-page, thema: none,
                  overflow: "none") = {
  // Which theme a single slide is set in. A slide carrying `invert` is set in
  // the turned palette on paper too, or the handout would show a different
  // slide than the talk did. `presentation` hands the function in only for a
  // deck that inverts somewhere; without it nothing per slide is written into
  // the theme state, and a deck that never inverts builds exactly as it did.
  let wechselt = thema != none
  let thema = if thema == none { s => t } else { thema }
  set page(paper: "a4", margin: (x: 1.5cm, y: 1.4cm))
  set text(size: 10pt, fill: t.strong)
  let gap = 14pt
  let column-gap = 10pt
  // A 16:9 slide beside a note column is wide and low. Up to two per upright
  // A4 that wastes most of the page, so there the notes go underneath and the
  // slide takes the full width. From three on, beside is the better use.
  let beside = per-page >= 3
  // One ruled line per pitch. Underneath a slide at least four of them stay,
  // whatever the slide's shape.
  let pitch = 17pt
  let least-room = 4 * pitch

  let lines(height) = {
    let count = calc.max(2, int(height / pitch))
    set line(stroke: 0.4pt + luma(84%))
    [#stack(dir: ttb, spacing: pitch,
            ..range(count).map(_ => line(length: 100%))) <ts-handout-lines>]
  }
  let room-for-notes(height) = context {
    let note = note-state.get()
    if note != none and plain-text(note).trim() != "" {
      text(size: 9pt, fill: luma(35%), [#note <ts-handout-note>])
    } else { lines(height) }
  }

  // Each slide with what the deck knows about it, so the count keeps running
  // across the page breaks. The counting itself happened once, in
  // `presentation`; here the entries are only paired up with their slides.
  let numbered = all.enumerate().map(((i, s)) => (slide: s, fakten: facts.at(i)))

  let sheets = ()
  let batch = ()
  for item in numbered {
    batch.push(item)
    if batch.len() == per-page { sheets.push(batch); batch = () }
  }
  if batch.len() > 0 { sheets.push(batch) }

  // One `layout` per sheet, not per row: asked again further down the page it
  // would report the *remaining* height, and every slide would come out a
  // different size.
  sheets.map(sheet => layout(room => {
    let share = (room.height - (per-page - 1) * gap) / per-page
    let note-column = calc.max(4.2cm, room.width * 0.26)
    let w = if beside {
      calc.min(room.width - note-column - column-gap,
               share * (geo.width / geo.height))
    } else {
      // The full width, unless that leaves nothing underneath: a 4:3 slide at
      // two per page is nearly as tall as its share, and the notes came out
      // with a negative height. Then the slide gives way, not the room.
      calc.min(room.width, (share - least-room - 8pt) * (geo.width / geo.height))
    }
    let h = w * (geo.height / geo.width)
    // The frame's own look travels through a `set` rule, so a label rule can
    // reach it; the shrunk slide inside gets the surrounding style put back,
    // or it would inherit the frame's stroke and radius and draw a second
    // border around itself.
    let framed(item) = context {
      let aussen = umgebungs-block()
      set block(radius: 2pt, stroke: 0.5pt + luma(72%))
      [#block(width: w, height: h, clip: true, {
        set block(fill: aussen.fill, stroke: aussen.stroke, radius: aussen.radius)
        // Anchored at the left by name. The slide keeps its full width under
        // the scaling and is wider than this frame, and a frame aligns what
        // overhangs it by `start`: in a deck that reads from the right that
        // is the right edge, the slide slid left by the overhang and the
        // frame showed nothing. The slide inside places its own parts with
        // `start` again, so nothing in it reads from the wrong side.
        align(top + left, scale(w / geo.width * 100%, origin: top + left,
              slide-body(item.slide, style, geo, thema(item.slide),
                         overflow: overflow, nr: item.fakten.nr)))
      }) <ts-handout-frame>]
    }

    let rows = sheet.map(item => {
      // Counted here too, not only in the other two branches: a companion
      // package resolves its targets per slide, and without this every applet
      // in the deck would look as if it stood on the same one.
      slide-counter.step()
      // What the deck knows about this slide, before it is laid out: the
      // shrunk slide draws its own chrome and reads the numbers from here,
      // exactly as the full-size one does.
      deck-info.update(item.fakten)
      if wechselt { theme-state.update(thema(item.slide)) }
      step-cursor.update(0)
      // Und die Basen der cue-Gruppen. Dass eine Gruppe zu *einer* Folie
      // gehoert, haengt an dieser Zeile: geleert wird hier, gelesen in `cue`,
      // und damit zaehlt jede Folie ihre Punkte von 1. Der Weg ueber den
      // Folienzaehler waere ein Lesen von Introspektion in gemessenem Inhalt
      // und braechte das Dokument um seine Konvergenz -- ein reines
      // Schreiben an dieser Stelle nicht.
      cue-basis.update(_ => (:))
      step-here.update(())
      sprite-number.update(none)
      counter(footnote).update(0)
      // The slide's own `speaker-note` may overwrite this while it is laid
      // out, which is why the note is only read afterwards.
      note-state.update(item.slide.note)
      if beside {
        grid(columns: (w, 1fr), column-gutter: column-gap, align: top,
             framed(item), room-for-notes(h))
      } else {
        framed(item)
        v(8pt, weak: true)
        // Fixed height, so every row is exactly its share of the page and the
        // rows below do not creep upwards when a note runs short.
        block(width: w, height: share - h - 8pt, room-for-notes(share - h - 8pt))
      }
    })
    // Weak, here and above: a block in a flow carries the paragraph spacing
    // on both sides, and a strong `v` does not take its place but stands
    // beside it. Measured, 8pt came out as 20pt and the gap as 26pt. The
    // arithmetic above has no slack for that -- with notes below the slide,
    // or beside a 4:3 slide, every sheet ran a hair over its page and left a
    // page behind that carried one ruled line. A weak spacing is what the
    // sum assumes: it replaces the paragraph spacing rather than adding to it.
    rows.join(v(gap, weak: true))
  })).join(pagebreak(weak: true))
}
