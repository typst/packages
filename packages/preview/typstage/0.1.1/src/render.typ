// Turning tracked elements into HTML.

#import "config.typ": *
#import "internal.typ": (folien-notizen, notiz-marke-ab, notiz-selektoren,
                        sprite-number)
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
    ), html.frame(block(width: inner, notiz-zeile(t, geo.scale, zahl, f.body))))
  }).join()
}

/// One sprite: the element as its own small frame, plus everything the runtime
/// needs to know about it as data attributes.
#let sprite-markup(s, n, template) = {
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
  if s.kind == "video" {
    let a = (src: s.extra.src, preload: "auto", playsinline: "")
    if s.extra.muted { a.insert("muted", "") }
    if s.extra.loop { a.insert("loop", "") }
    if s.extra.controls { a.insert("controls", "") }
    html.elem("div", attrs: attrs, html.elem("video", attrs: a, []))
  } else if s.kind == "embed" {
    let a = (frameborder: "0", sandbox: "allow-scripts allow-same-origin")
    if s.extra.url != none { a.insert("src", s.extra.url) }
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
      s.raw-frames.map(f => html.elem("div", attrs: (class: "ts-frame"),
        html.frame(block(width: s.width, height: s.height,
                         template(with-style(s, block(
                           width: s.region.width, height: s.region.height,
                           f))))))).join())
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
      let inhalt = template(with-style(s, block(
        width: s.region.width, height: s.region.height, s.body)))
      html.frame(if s.pad == 0pt {
        block(width: s.width, height: s.height, inhalt)
      } else {
        block(width: s.width + 2 * s.pad, height: s.height + 2 * s.pad,
              place(top + left, dx: s.pad, dy: s.pad, inhalt))
      })
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
