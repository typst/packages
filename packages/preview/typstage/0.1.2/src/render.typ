// Turning tracked elements into HTML.

#import "config.typ": *
#import "internal.typ": (folien-notizen, nackt, notiz-marke-ab,
                        notiz-selektoren, sprite-number)
#import "theme.typ": notiz-zeile, with-style

/// Die Anmerkungen einer Folie als Sprites.
///
/// Der Gegenpart zu den Schlitzen, die `slide-body` im Hintergrund stanzt:
/// dieselbe Abfrage, dieselbe Reihenfolge, dieselbe Zeilenfunktion. Der
/// Hintergrund hält den Platz und trägt die unsichtbare Marke, hier steht die
/// Tinte -- und weil `data-n` und Marke zusammenfinden, setzt die Laufzeit den
/// Sprite punktgenau in die Zeile, die für ihn freigehalten wurde.
///
/// Es gibt damit nur noch *eine* Quelle für Anmerkungen. Eine ungekettete
/// Fußnote und eine gekettete unterscheiden sich allein in einer Zeichenkette,
/// dem `data-at`: `"1-"` gegen `"3-"`. Doppelt kann nichts kommen, weil der
/// Hintergrund keine Anmerkungstinte mehr trägt; verloren gehen kann auch
/// nichts, weil ein fehlender Schritt auf `"1-"` zurückfällt.
///
/// Muss in einem `context` stehen.
#let notiz-sprites(nr, t, geo) = {
  let m = margins(geo)
  let inner = geo.width - m.left - m.right
  let fn = folien-notizen(nr)
  if fn.len() == 0 { return [] }
  let schritte = notiz-selektoren(nr)
  fn.enumerate().map(((i, f)) => {
    let s = schritte.at(i, default: (at: "1-", delay: 0, after: none))
    let zahl = counter(footnote).at(f.location()).first()
    html.elem("div", attrs: (
      class: "ts-el ts-note",
      "data-n": str(notiz-marke-ab + i),
      "data-at": s.at,
      // Eine Anmerkung blendet auf und wandert nicht: sie steht am Fuß der
      // Folie, wo ein Weg von vierzehn Punkten nur unruhig aussähe. Die
      // Verzögerung kommt dagegen mit, damit die Anmerkung eines gestaffelten
      // Punktes im selben Takt kommt wie der Punkt.
      "data-enter": "fade",
      ..if s.at("delay", default: 0) != 0 { ("data-delay": str(s.delay)) } else { (:) },
      // Nur die Abweichung von der Vorgabe reist mit, wie bei jedem Sprite:
      // ein Deck ohne `dim` sieht danach aus wie eines von gestern.
      ..if s.at("after", default: none) != none { ("data-after": s.after) } else { (:) },
    // `nackt` wie der Block der Anmerkungen in `slide-body`: dort steht der
    // Schlitz in voller Breite `inner`, und so breit muss auch der Sprite
    // setzen. Mit dem Einzug einer `set block`-Regel stand eine lange
    // Anmerkung im Browser sonst 253pt weiter rechts, auf ein Drittel ihrer
    // Breite gestaucht.
    //
    // Und in der Schriftgröße des Themes, wie der Schlitz in `slide-body`:
    // `inner` trägt einen Rand in `em`, und der zählte hier gegen die
    // Schrift des Dokuments (11pt) statt gegen die der Folie. Mit
    // `presentation.with(margin: 1em)` rechnete der Sprite so im Standardthema
    // mit zweimal 11pt Rand statt zweimal 24pt und setzte 26pt breiter als
    // sein Schlitz. Gemessen brach er eine lange Anmerkung ein Wort später
    // um, und die Laufzeit stauchte ihn hinein -- ihr Ende stand bei 1600 px
    // Bühnenbreite 10 px zu weit links.
    //
    // Und darin die Größe des Anmerkungsblocks, wie in `slide-body`: dort
    // setzt der Block `t.size * 0.62` und `notiz-zeile` noch einmal. Bei einer
    // Größe in `pt` ist das zweite Setzen ohne Wirkung, bei einer in `em`
    // zählt es mit -- mit `themes.default + (size: 1.3em)` setzte der Sprite
    // ohne diese Zeile 1,24-mal so groß wie sein Schlitz, und die Laufzeit
    // rückte ihn beim Einpassen bei 1600 px Bühnenbreite um 143 px nach
    // rechts (Fall 13 in pruefe-zier.js).
    ), html.frame({
      set text(size: t.size * geo.scale)
      block(..nackt, width: inner, {
        set text(size: t.size * 0.62 * geo.scale)
        notiz-zeile(t, geo.scale, zahl, f.body)
      })
    }))
  }).join()
}

// ── Zähler im Sprite ─────────────────────────────────────────────────────
//
// Ein Sprite setzt den Rumpf seines Elements ein zweites Mal, hinter dem ganzen
// Hintergrund der Folie, und jeder Zähler darin schaltete dabei noch einmal
// weiter: Abbildungen jeder Art, Gleichungen, Überschriften und die eigenen
// `counter` eines Decks. Gemessen an vier Folien mit Abbildungen, Gleichungen
// und einem eigenen Zähler hinter `#pause` und in `alternatives`: im Browser
// hießen die beiden Fassungen der `alternatives` „Figure 6“ und „Figure 7“, auf
// Papier „Figure 3“ und „Figure 4“, und die Folie danach, ohne jede Animation,
// zeigte „Figure 8“, Gleichung (4) und „Eigen 5“ statt 5, (3) und 3 -- jede
// Folie erbte, was die Sprites vor ihr zugelegt hatten.
//
// Die Abhilfe klammert jeden Sprite. Davor geht jeder Zähler, den der
// Hintergrund zwischen dem Beginn dieses Rumpfes (`fnort`) und seinem eigenen
// Ende (`ov`, der Ort der Sprite-Schicht) bewegt, um genau diesen Abstand
// zurück: der Rumpf beginnt mit dem Stand, mit dem er im Hintergrund beginnt.
// Dahinter geht er um den Abstand zwischen dem Ende des Rumpfes im Hintergrund
// (die Marke `typstage-rumpf-ende`, die `track` setzt) und `ov` wieder vor:
// so steht er vor dem nächsten Sprite, wo er vor diesem stand, und hinter der
// Schicht, wo der Hintergrund endet.
//
// Das setzt voraus, dass der Sprite seinen Rumpf so zählt wie der Hintergrund.
// Eine `show`-Regel aus dem Rumpf des Decks, die nummeriert oder zählt,
// erreicht ihn nicht, und dann nimmt die Klammer zurück, was er nicht wieder
// zulegt. Gemessen mit `show math.equation.where(block: true): set
// math.equation(numbering: "(1)")` im Rumpf: eine Gleichung zwei Folien hinter
// einem `anim` und einem `alternatives` stand im Browser bei (2), vorher bei
// (6), auf Papier bei (5). Ein hingeschriebener Stand statt des Abstands hinter
// dem Sprite hielte die Folien danach richtig, bricht aber, sobald ein Zähler
// im Hintergrund erst spät feststeht: gemessen an zwölf Folien mit je einer
// Abbildung in `anim` hinter zwei Abbildungen, die erst im vierten Lauf
// erscheinen, 23 von 25 Marken falsch und sechs Meldungen über
// `counter(figure)`, mit Abständen keine Marke falsch. Konvergieren tut dieses
// Deck in keiner Fassung; es meldet schon vorher dreimal `sprites`.
//
// Um Abstände und nicht auf Stände, aus dem Grund, den `zaehler-klammer` in
// present.typ gemessen hat: ein hingeschriebener Stand reicht jede Lesung einen
// Layoutlauf später an alle späteren Folien weiter.
//
// Und gelesen wird nur im Hintergrund, nie im Sprite. Die Sprites entstehen
// einen Lauf nach dem Hintergrund -- `track` legt seinen Datensatz ab, die
// Schicht liest ihn im nächsten Lauf --, und eine Lesung in ihnen kommt noch
// einen Lauf später. Gemessen an einer ersten Fassung, die dahinter um das
// zurückging, was der Sprite selbst zugelegt hatte, an zwei Orten im Sprite
// gelesen: schon zwei Folien mit einer Abbildung hinter `#pause` meldeten
// „did not converge“, das Deck oben ebenso. So wie hier braucht das kleine Deck
// vier Läufe wie vorher und das obere vier statt fünf, und die 17 Beispieldecks
// und das Prüfdeck kommen im HTML Byte für Byte und mit denselben Läufen heraus.
//
// Der Fußnotenzähler geht seinen eigenen Weg (siehe `fnort` unten), der
// Seitenzähler zählt in einem Sprite nichts, und die Zähler des Pakets setzt
// `sprite-markup` selbst.

// Das Element, das `counter(...).update` und `.step` ins Dokument legen; wie
// `zaehler-aenderung` in present.typ, das von hier aus nicht zu erreichen ist.
#let sprite-zaehler-aenderung = counter("typstage-n").step().func()

/// Die Zähler, die zwischen `von` und `bis` bewegt werden -- dieselbe Auswahl
/// wie in `zaehler-klammer`. Muss in einem `context` stehen.
///
/// Eine Abfrage und nicht vier: jeder Sprite fragt zweimal, und gemessen an
/// `vortragen`, auf einem Faden übersetzt, kostete die Klammer mit vier
/// Abfragen je Aufruf 0,17 s Rechenzeit über dem Stand ohne sie, mit einer
/// 0,08 s.
#let sprite-zaehler(von, bis) = {
  let zaehler = ()
  let alle = std.selector(figure).or(math.equation).or(heading)
    .or(sprite-zaehler-aenderung).after(von).before(bis)
  for e in query(alle) {
    let f = e.func()
    if f == figure { zaehler.push(e.counter) }
    else if f == math.equation { zaehler.push(counter(math.equation)) }
    else if f == heading { zaehler.push(counter(heading)) }
    else if not (type(e.key) == str and e.key.starts-with("typstage-")) {
      let c = counter(e.key)
      if c not in (counter(page), counter(footnote)) { zaehler.push(c) }
    }
  }
  zaehler.dedup()
}

/// Um den Abstand von `von` nach `bis` weiterstellen, je Ebene, mit so vielen
/// Ebenen wie der Stand an `ziel` -- wie in `zaehler-klammer`: `step(level: 2)`
/// hängt eine an, `step()` nimmt sie wieder weg, und beides muss mit. Die
/// Kappung bei null ist dieselbe Vorsicht wie dort.
#let sprite-verschieben(c, von, bis, ziel, vorzeichen) = {
  let a = c.at(von)
  let b = c.at(bis)
  let d = range(calc.max(a.len(), b.len())).map(i =>
    vorzeichen * (b.at(i, default: 0) - a.at(i, default: 0)))
  if d.all(x => x == 0) { return }
  let ebenen = c.at(ziel).len()
  c.update((..n) => range(ebenen).map(i =>
    calc.max(0, n.pos().at(i, default: 0) + d.at(i, default: 0))))
}

/// Die Klammer um einen Sprite-Inhalt: davor zurück auf den Stand am Beginn des
/// Rumpfes im Hintergrund, dahinter wieder vor auf den Stand am Ende des
/// Hintergrunds.
///
/// Beide `context` tragen nur Orte, die vom ersten Lauf an feststehen, und
/// lesen selbst: ein mitgetragener gelesener Wert gäbe ihnen in jedem Lauf, in
/// dem die Lesung wechselt, eine neue Identität.
#let sprite-klammer(s, ov, inhalt) = {
  let fnort = s.at("fnort", default: none)
  if fnort == none or ov == none { return inhalt }
  context {
    for c in sprite-zaehler(fnort, ov) {
      sprite-verschieben(c, fnort, ov, fnort, -1)
    }
  }
  inhalt
  context {
    let zaehler = sprite-zaehler(fnort, ov)
    if zaehler.len() == 0 { return }
    // Die eigene Marke unter denen im Hintergrund dieser Folie hinter dem
    // Beginn des Rumpfes: vor ihr stehen höchstens die der Elemente, die in
    // ihm stecken.
    let marke = query(selector(<typstage-rumpf-ende>).after(fnort).before(ov))
      .find(m => m.value == fnort)
    if marke == none { return }
    for c in zaehler {
      sprite-verschieben(c, marke.location(), ov, ov, 1)
    }
  }
}

/// One sprite: the element as its own small frame, plus everything the runtime
/// needs to know about it as data attributes.
///
/// `ov` ist der Ort der Sprite-Schicht dieser Folie, also das Ende ihres
/// Hintergrunds; ohne ihn bleiben die Zähler, wie sie sind.
#let sprite-markup(s, n, template, ov: none) = {
  let attrs = (class: "ts-el ts-" + s.kind, "data-n": str(n), "data-at": s.at)
  // Drei Schlüssel reisen als richtige Attribute weiter unten -- `srcdoc` und
  // `src` am Rahmen, `src` am Video -- und werden von der Laufzeit nie als
  // `data-` gelesen. Ohne diese Sperre schrieb die Schleife das *ganze*
  // eingebettete Dokument ein zweites Mal auf das umgebende `div`: bei einem
  // GeoGebra-Applet reiste das 14-KB-Bootskript doppelt. Nachgezählt an der
  // Laufzeit: `dataset.doc`, `dataset.url`, `dataset.src` -- null Treffer.
  let nur-attribut = ("doc", "url", "src")
  for (k, v) in s.extra {
    if v != none and v != auto and k not in nur-attribut {
      attrs.insert("data-" + k,
        if type(v) == bool { if v { "1" } else { "0" } } else { str(v) })
    }
  }
  if s.kind in ("video", "audio") {
    let a = (src: s.extra.src, preload: "auto", playsinline: "")
    if s.extra.muted { a.insert("muted", "") }
    if s.extra.loop and s.extra.start == 0 and s.extra.end == none { a.insert("loop", "") }
    if s.extra.controls { a.insert("controls", "") }
    html.elem("div", attrs: attrs, html.elem(s.kind, attrs: a, []))
  } else if s.kind == "embed" {
    let a = (frameborder: "0", sandbox: "allow-scripts allow-same-origin")
    if s.extra.url != none {
      // Delay YouTube until this embed is visible. Other URLs stay ordinary embeds.
      let youtube = s.extra.url.match(regex("^https://(www\\.)?(youtube\\.com|youtube-nocookie\\.com)/embed/[A-Za-z0-9_-]{11}([?#].*)?$")) != none and s.extra.doc == none
      if youtube {
        a.insert("data-ts-youtube", s.extra.url)
        a.insert("allow", "autoplay; encrypted-media; fullscreen; picture-in-picture")
        a.insert("referrerpolicy", "strict-origin-when-cross-origin")
        a.insert("title", "YouTube")
      } else { a.insert("src", s.extra.url) }
    }
    if s.extra.doc != none { a.insert("srcdoc", s.extra.doc) }
    // `data-zoom` und `data-bridge` schreibt die Schleife oben laengst -- beide
    // stehen in `extra`. Hier stand beides ein zweites Mal, mit demselben
    // Wert, und ein Kommentar dazu, nur der Verzicht reise mit; in `tour`
    // steht zweimal `data-zoom="1"`. Uebrig bleibt, was die Schleife nicht
    // kann: die Klasse, an der die Laufzeit den gebrueckten Rahmen findet.
    if s.extra.at("bridge", default: none) != none {
      attrs.insert("class", "ts-el ts-embed ts-bridged")
    }
    html.elem("div", attrs: attrs, html.elem("iframe", attrs: a, []))
  } else if s.kind == "flipbook" or s.kind == "scene" {
    // Ein Daumenkino und eine Szene sind im Markup dasselbe: ein Stapel
    // fertiger Bilder, von denen genau eines `data-on` trägt. Sie
    // unterscheiden sich allein darin, wer weiterschaltet -- dort die Uhr,
    // hier der Tastendruck. Deshalb steht hier ein Zweig und nicht zwei.
    html.elem("div", attrs: attrs + ("data-frames": str(s.raw-frames.len())),
      sprite-number.update(n) +
      // Jedes Bild in seiner eigenen Klammer. Im Hintergrund steht nur das
      // erste, und die Klammer nimmt an, dass jedes Bild so viel zählt wie
      // dieses. Zählt ein späteres mehr, beginnt das nächste um den Überschuss
      // weiter: gemessen an einer Szene mit drei Halten, deren Bilder ab dem
      // zweiten Halt eine zweite nummerierte Gleichung tragen, stand die erste
      // Gleichung im ersten Bild bei (1) und im letzten bei (4).
      s.raw-frames.map(f => html.elem("div", attrs: (class: "ts-frame"),
        sprite-klammer(s, ov,
          html.frame(block(..nackt, width: s.width, height: s.height,
                           template(with-style(s, block(..nackt,
                             width: s.region.width, height: s.region.height,
                             f)))))))).join())
  } else {
    html.elem("div", attrs: attrs, {
      // The counter is set to this element's own number before the content is
      // laid out a second time. Nested elements then count on exactly as they
      // did in the background. The numbering is a pre-order, its children
      // carry n+1, n+2 and so on. Only that way does the browser find the marker
      // again
      // of an element that vanished into its parent's `hide()`.
      counter("typstage-n").update(n)
      // And which element this is, so that a body printing
      // `info().step.number` reads its own step here and not the slide's last
      // one. Only the number travels; the step itself is looked up from
      // `sprites`, for the reason given at `sprite-number`.
      sprite-number.update(n)
      // Und der Fußnotenzähler auf den Stand, den er im Hintergrund an der
      // Stelle dieses Rumpfes hatte. Ohne das zählt der zweite Satz weiter,
      // und im Browser ist die sichtbare Marke die von hier: gemessen las ein
      // Deck mit drei Fußnoten, zwei davon in einem `stagger`, die Marken
      // 1, 4, 5 und die Anmerkungen darunter 1, 2, 3.
      //
      // Abgelesen wird am mitgereisten *Ort*, nicht an einer mitgereisten
      // Zahl -- siehe den Kommentar bei `fnort` in `track`.
      context {
        let o = s.at("fnort", default: none)
        if o != none { counter(footnote).update(counter(footnote).at(o).first()) }
      }
      // The measured size on the outside, since that decides the frame, and
      // the region from back then on the inside. A relative measure in the body
      // therefore resolves exactly once, and against the same reference as in
      // the background.
      // `pad` is almost always 0pt and the frame is then the same as before.
      // Only an element without area gets air, the same as its marker, because
      // otherwise its content would sit offset inside it.
      // `place(top + left, …)` as in the background, and for the same reason:
      // the region is wider than the measured frame, and a block that overhangs
      // would otherwise be centred inside it. Measured on a centred equation:
      // the box sat right, the glyphs were painted 293pt beside it, exactly
      // half the difference.
      // `align(top + left, …)` inside the region: it is wider than the measured
      // frame, and whatever Typst centres on its own, a block equation for
      // instance, ended up in the middle of it rather than where the marker
      // stands. Measured: the box sat right, the glyphs 293pt beside it,
      // exactly half the difference between region and frame. An explicit
      // `align` in the body still wins, since it sits further in.
      //
      // Alle drei Blöcke `nackt`: auf Papier steht der Rumpf ohne sie, und
      // eine `set block`-Regel des Decks setzte ihren Einzug hier zweimal um
      // den Rumpf (siehe `nackt` in internal.typ). Gemessen unter `#set
      // block(inset: 8pt)`: ein Wort hinter `#pause` stand im Browser 16pt
      // weiter rechts und tiefer als auf Papier, und ein `anim(place(bottom +
      // right, …))` war dort nicht mehr zu sehen.
      let inhalt = template(with-style(s, block(..nackt,
        width: s.region.width, height: s.region.height, s.body)))
      // In der Klammer, damit die Zähler darin mit dem Stand des Hintergrunds
      // beginnen und die Folie danach nichts erbt (siehe `sprite-klammer`).
      sprite-klammer(s, ov, html.frame(if s.pad == 0pt {
        block(..nackt, width: s.width, height: s.height, inhalt)
      } else {
        block(..nackt, width: s.width + 2 * s.pad, height: s.height + 2 * s.pad,
              place(top + left, dx: s.pad, dy: s.pad, inhalt))
      }))
    })
  }
}

/// How CSS and JavaScript get into the page.
///
/// - `"inline"`: both sit in the HTML. One file, nothing beside it, nothing
///   to fetch. This is the default.
/// - `"split"`: the HTML points at `typstage-<version>.css` and `.js` next to
///   it. Write both out from `runtime-files`.
/// - `(cdn: "https://…")`: the same file names under the given address. Then
///   nothing is created beside the HTML.
#let asset-links(assets) = {
  let base = if type(assets) == dictionary and "cdn" in assets {
    assets.cdn.trim("/") + "/"
  } else { "" }
  (
    css: html.elem("link", attrs: (rel: "stylesheet",
                                   href: base + asset-name("css"))),
    js: html.elem("script", attrs: (src: base + asset-name("js")), ""),
  )
}
