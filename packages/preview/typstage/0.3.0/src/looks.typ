// Acht Themes für den Unterricht: klar, atlas, skizze, labor, kontur, leiste,
// riso und bauhaus.
//
// Sie teilen dieselben Bausteine und zeichnet jedes auf seine Art: die
// Fachfarbe, die aus dem Klassenkürzel kommt (`class: "MA-07"` gibt das Blau
// der Mathematik), die Zeile „Mathematik · Klasse 7“ über dem Titel der
// Titelfolie, das Kürzel als Marke, und die Foliennummer als gefüllte Marke in
// der Fachfarbe.
//
//   #show: presentation.with(theme: "labor", class: "MA-07")
//   #show: presentation.with(theme: themes.riso, accent: green)
//
// Wie die fünf älteren Themes sind es Dictionaries, gebaut mit `theme()`. Was
// sie von ihnen unterscheidet, sind zwei Einträge: `header` und `footer` sind
// hier Funktionen, die Kopf und Nummer ganz selbst zeichnen, und
// `subject-accent: true` lässt `presentation` die Akzentfarbe aus `class`
// nehmen. Alle Farben, die nicht fest zum Bild gehören, werden beim Zeichnen
// aus `t.accent` abgeleitet, damit `accent:`, `class:` und eine Palette sie
// erreichen.

#import "config.typ": margins
#import "themes.typ": (datum, ebenen-groesse, font-args, grund, lesbar, stapel,
                       theme, themes as grund-themes)
#import "richtung.typ": am-anfang, am-ende

// ═══════════════════════════════════════════════════════════════════════════
//  Fächer
// ═══════════════════════════════════════════════════════════════════════════

/// Fachfarben nach Kürzel. Ein unbekanntes Fach bekommt das Blau der
/// Mathematik.
#let subject-accents = (
  MA: rgb("#2f6fb5"),
  PH: rgb("#d4572a"),
  IF: rgb("#13866f"),
  CH: rgb("#8b3fa3"),
  BI: rgb("#3f8a2c"),
  NW: rgb("#0e7f8c"),
  DE: rgb("#c0392b"),
  EN: rgb("#b5176d"),
  KLS: rgb("#5b6b7f"),
)

/// Fachnamen nach Kürzel, für die Zeile über dem Titel.
#let subject-names = (
  MA: "Mathematik",
  PH: "Physik",
  IF: "Informatik",
  CH: "Chemie",
  BI: "Biologie",
  NW: "Naturwissenschaften",
  DE: "Deutsch",
  EN: "Englisch",
  KLS: "Klassenleitung",
)

/// Der Klartext eines Inhalts, oder `none`.
#let klartext(v) = {
  if v == none { return none }
  if type(v) == str { return v }
  if type(v) != content { return str(v) }
  if v.func() == [ ].func() { return " " }
  if v.has("text") { return v.text }
  if v.has("children") { return v.children.map(klartext).join(default: "") }
  if v.has("body") { return klartext(v.body) }
  none
}

/// Zerlegt ein Klassenkürzel wie `"MA-07"`, `"PH-7"` oder `"IF-11"`.
#let parse-class(class) = {
  let t = klartext(class)
  let f = if t == none { none } else { t.match(regex("^([A-Z]{2,3})-?0*(\d+)")) }
  if f == none { (subject: none, name: none, year: none) } else {
    let fach = f.captures.at(0)
    (subject: fach, name: subject-names.at(fach, default: none),
     year: int(f.captures.at(1)))
  }
}

/// „Mathematik · Klasse 7“, „Physik · Jahrgang 12“, oder `none`.
#let subject-line(class) = {
  let p = parse-class(class)
  if p.name == none { return none }
  if p.year < 5 or p.year > 13 { return p.name }
  p.name + " · " + (if p.year >= 11 { "Jahrgang " } else { "Klasse " }) + str(p.year)
}

/// Die Fachfarbe zum Klassenkürzel.
#let class-accent(class) = {
  let fach = parse-class(class).subject
  subject-accents.at(if fach == none { "MA" } else { fach }, default: subject-accents.MA)
}

// ═══════════════════════════════════════════════════════════════════════════
//  Bausteine
// ═══════════════════════════════════════════════════════════════════════════

/// Eine gefüllte Marke mit Beschriftung: Nummer, Kürzel, Seitenzahl.
#let marke(body, fill: black, size: 12pt, radius: 1.5pt, font: none,
           weight: 700, width: auto, inset: (x: 0.5em, y: 0.4em), stroke: none,
           text-fill: white) = text(size, box(
  fill: fill, stroke: stroke, radius: radius, inset: inset, width: width,
  align(center, text(fill: text-fill, weight: weight, ..font-args(font),
                     top-edge: "bounds", bottom-edge: "bounds", body))))

/// Harter, versetzter Schatten hinter einem Element natürlicher Größe.
#let schatten(body, abstand: 3pt, fill: black) = context {
  let g = measure(body)
  box(width: g.width + abstand, height: g.height + abstand, {
    place(top + left, dx: abstand, dy: abstand,
          rect(width: g.width, height: g.height, fill: fill, stroke: none))
    place(top + left, body)
  })
}

/// Die Nummer eines Abschnitts als Zahl, oder `none`.
#let abschnitt-nr(s) = {
  let n = s.at("number", default: none)
  if type(n) == array { if n.len() == 0 { none } else { n.last() } } else { n }
}

/// Autor und Datum, wie es unter dem Titel steht.
#let unterzeile(s) = [#{
  s.author
  if s.date != none [ · #datum(s.date) ]
} <ts-title-slide-byline>]

/// Der Untertitel mit seiner Marke, oder nichts.
#let untertitel(s) = [#s.subtitle <ts-title-slide-subtitle>]

/// Das Kürzel des Decks, oder `none`.
#let kuerzel(t) = t.at("class", default: none)

/// Wo der Titel einer Inhaltsfolie beginnt. Bewusst näher an der Kante als
/// der Rand: der Kopf soll das Theme zeigen, nicht den Rumpf verdrängen.
#let kopf-oben = 20pt

/// Breite des Satzspiegels.
#let innen(geo) = { let m = margins(geo); geo.width - m.left - m.right }

/// Ein Theme dieser Familie: Vorgaben, die alle acht teilen.
#let schul-theme(..args) = theme(
  accent: subject-accents.MA,
  surface: white,
  progress: "none",
  // Der Kopf bringt seinen Abstand zum Rumpf schon in `band-height` mit.
  head-gap: 6pt,
  subject-accent: true,
  math-font: ("Fira Math",),
  // Der farbige Reiter einer Karte steht in der Fachfarbe, nicht in Schwarz.
  derive: p => (strong: p.accent),
  ..args,
)

// ═══════════════════════════════════════════════════════════════════════════
//  klar: Linien statt Flächen, quadratische Marken, viel Weißraum
// ═══════════════════════════════════════════════════════════════════════════

#let klar-kachel(body, t, size: 12pt) = marke(body, fill: t.accent, size: size,
  width: 1.65em, inset: (x: 0.3em, y: 0.42em))

#let klar-kopf(t, titel, geo, s) = {
  let k = geo.scale
  let m = margins(geo)
  am-anfang(top, m, dy: kopf-oben * k, block(width: innen(geo), {
    block(below: 8pt * k, titel)
    line(length: 100%, stroke: 0.9pt * k + t.border)
  }))
}

#let klar-fuss(t, d, geo) = {
  let k = geo.scale
  am-ende(bottom, margins(geo), dy: -14pt * k,
    [#klar-kachel(str(d.slide.number), t, size: 15pt * k) <ts-slide-number>])
}

#let klar-titel(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  let zeile = subject-line(kuerzel(t))
  am-anfang(top, m, dy: geo.height * 0.27, block(width: innen(geo), {
    grid(columns: (1fr, auto), column-gutter: 24pt * k,
      align: (left + bottom, right + bottom),
      stack(spacing: 14pt * k,
        if zeile != none {
          text(14pt * k, weight: 600, tracking: 0.14em, fill: t.accent, upper(zeile))
        },
        text(..font-args(t.title-font), 46pt * k, weight: 700, fill: t.ink,
             [#s.title <ts-title-slide-title>]),
      ),
      if kuerzel(t) != none {
        marke(kuerzel(t), fill: t.accent, size: 20pt * k, inset: (x: 0.6em, y: 0.45em))
      },
    )
    v(16pt * k)
    line(length: 100%, stroke: 1pt * k + t.border)
    v(16pt * k)
    text(21pt * k, fill: t.muted, untertitel(s))
  }))
  am-anfang(bottom, m, dy: -m.bottom, text(13pt * k, fill: t.muted, unterzeile(s)))
}

#let klar-abschnitt(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "section")
  let n = abschnitt-nr(s)
  am-anfang(horizon, m, block(width: innen(geo), {
    grid(columns: (auto, 1fr), column-gutter: 22pt * k, align: horizon,
      if n != none { klar-kachel(str(n), t, size: 30pt * k) }
      else { box(width: 30pt * k, height: 30pt * k, fill: t.accent) },
      text(..font-args(t.title-font), ebenen-groesse(38pt, s.at("depth", default: 1), k),
           weight: 700, fill: t.ink, [#s.title <ts-section-slide-title>]),
    )
    v(18pt * k)
    line(length: 100%, stroke: 1pt * k + t.border)
  }))
}

// ═══════════════════════════════════════════════════════════════════════════
//  atlas: Titelkarte in der Fachfarbe, runde Ecken, wie ein Schulbuch
// ═══════════════════════════════════════════════════════════════════════════

#let atlas-kachel(body, t, size: 12pt) = marke(body, fill: t.accent, size: size,
  radius: 0.35em, width: 1.75em, inset: (x: 0.3em, y: 0.45em))

/// Die Fläche in der Fachfarbe mit den beiden hellen Kreisen.
#let atlas-karte(t, breite, hoehe, k, radius: 12pt, gross: 1) = block(
  width: breite, height: hoehe, fill: t.accent, radius: radius * k, clip: true, {
    place(top + right, dx: 40pt * k * gross, dy: -60pt * k * gross,
          circle(radius: 80pt * k * gross, fill: white.transparentize(88%)))
    place(bottom + right, dx: -120pt * k * gross, dy: 30pt * k * gross,
          circle(radius: 40pt * k * gross, fill: white.transparentize(90%)))
  })

#let atlas-kopf(t, titel, geo, s) = {
  let k = geo.scale
  let m = margins(geo)
  let h = 46pt * k
  am-anfang(top, m, dy: 14pt * k, {
    atlas-karte(t, innen(geo), h, k, radius: 9pt)
    place(top + left, block(width: innen(geo), height: h, inset: (x: 20pt * k),
                            align(left + horizon, titel)))
  })
}

#let atlas-fuss(t, d, geo) = {
  let k = geo.scale
  am-ende(bottom, margins(geo), dy: -14pt * k,
    [#atlas-kachel(str(d.slide.number), t, size: 15pt * k) <ts-slide-number>])
}

#let atlas-titel(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  let h = geo.height * 0.56
  let zeile = subject-line(kuerzel(t))
  am-anfang(top, m, dy: m.top, {
    atlas-karte(t, innen(geo), h, k, radius: 14pt, gross: 1.8)
    place(top + left, block(width: innen(geo), height: h,
                            inset: (x: 30pt * k, y: 28pt * k),
      grid(columns: (1fr, auto), column-gutter: 20pt * k,
        align: (left + bottom, right + bottom), rows: 100%,
        stack(spacing: 14pt * k,
          if zeile != none {
            text(14pt * k, weight: 600, tracking: 0.1em,
                 fill: white.transparentize(15%), upper(zeile))
          },
          text(..font-args(t.title-font), 46pt * k, weight: 700, fill: white,
               [#s.title <ts-title-slide-title>]),
        ),
        if kuerzel(t) != none {
          box(fill: white, radius: 0.35em, inset: (x: 0.65em, y: 0.45em),
              text(19pt * k, weight: 700, fill: t.accent, top-edge: "cap-height",
                   bottom-edge: "baseline", kuerzel(t)))
        },
      )))
  })
  am-anfang(top, m, dy: m.top + h + 26pt * k, dx: 30pt * k,
    text(22pt * k, weight: 600, fill: t.accent, untertitel(s)))
  am-anfang(bottom, m, dy: -m.bottom, dx: 30pt * k,
    text(13pt * k, fill: t.muted, unterzeile(s)))
}

#let atlas-abschnitt(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.accent, "section")
  place(top + right, dx: 60pt * k, dy: -90pt * k,
        circle(radius: 170pt * k, fill: white.transparentize(88%)))
  place(bottom + left, dx: 260pt * k, dy: 60pt * k,
        circle(radius: 90pt * k, fill: white.transparentize(90%)))
  let n = abschnitt-nr(s)
  am-anfang(horizon, m, dx: 30pt * k, block(width: innen(geo) - 60pt * k, stack(
    spacing: 18pt * k,
    if n != none {
      box(fill: white, radius: 0.35em, inset: (x: 0.55em, y: 0.45em),
          text(20pt * k, weight: 700, fill: t.accent, top-edge: "cap-height",
               bottom-edge: "baseline", str(n)))
    },
    text(..font-args(t.title-font), ebenen-groesse(40pt, s.at("depth", default: 1), k),
         weight: 700, fill: white, [#s.title <ts-section-slide-title>]),
    box(width: 46pt * k, height: 4pt * k, fill: white, radius: 2pt * k),
  )))
}

// ═══════════════════════════════════════════════════════════════════════════
//  skizze: Handschrift, Titel auf Klebeband, Kürzel als schräger Zettel
// ═══════════════════════════════════════════════════════════════════════════

// Bewusst ohne Ersatzschrift: fehlt Playpen Sans oder SF Pro Rounded, meldet
// Typst das als Warnung ("unknown font family"), statt eine andere Schrift
// unterzuschieben, die niemand ausgesucht hat.
#let skizze-schrift = "Playpen Sans"
#let zettel-gelb = rgb("#ffe27a")

/// Klebeband mit gezackten Enden.
#let klebeband(breite, hoehe, fill, zacke: 3pt) = {
  let z = 6
  let dy = hoehe / z
  let links = range(z + 1).map(i => (if calc.even(i) { 0pt } else { zacke }, i * dy))
  let rechts = range(z + 1).rev().map(i => (breite - (if calc.even(i) { 0pt } else { zacke }), i * dy))
  polygon(fill: fill, stroke: none, ..links, ..rechts)
}

/// Die Nummer als handgezeichnet wirkender Klecks.
#let klecks(body, t, size: 12pt) = text(size, box(width: 2em, height: 2em,
  rotate(-6deg, box(width: 100%, height: 100%, fill: t.accent,
    radius: (top-left: 55%, top-right: 45%, bottom-right: 60%, bottom-left: 40%),
    align(center + horizon, rotate(6deg, text(font: skizze-schrift, 0.85em,
                                              top-edge: "bounds", bottom-edge: "bounds", weight: 700, fill: white, body)))))))

/// Ein Titel auf Klebeband, leicht schräg.
#let auf-band(inhalt, fill, k) = context {
  let g = measure(inhalt)
  box(rotate(-1deg, reflow: true, box({
    place(top + left, dx: -0.5em, dy: 0.3em,
          klebeband(g.width + 1em, g.height + 0.1em, fill, zacke: 4pt * k))
    inhalt
  })))
}

#let skizze-kopf(t, titel, geo, s) = {
  let k = geo.scale
  let m = margins(geo)
  am-anfang(top, m, dy: kopf-oben * k, dx: 8pt * k,
    block(width: innen(geo) - 16pt * k, auf-band(titel, t.accent.lighten(80%), k)))
}

#let skizze-fuss(t, d, geo) = {
  let k = geo.scale
  am-ende(bottom, margins(geo), dy: -10pt * k,
    [#klecks(str(d.slide.number), t, size: 15pt * k) <ts-slide-number>])
}

#let skizze-titel(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  let zeile = subject-line(kuerzel(t))
  if kuerzel(t) != none {
    am-ende(top, m, dy: m.top + 6pt * k, rotate(4deg, reflow: true, box(
      fill: t.accent, inset: (x: 0.8em, top: 0.75em, bottom: 0.65em),
      text(font: skizze-schrift, 22pt * k, weight: 700, fill: white, kuerzel(t)))))
  }
  am-anfang(top, m, dy: geo.height * 0.28, dx: 10pt * k, block(width: innen(geo) * 0.8, {
    if zeile != none {
      text(font: skizze-schrift, 16pt * k, weight: 500, fill: t.accent, zeile)
      v(18pt * k)
    }
    auf-band(text(font: skizze-schrift, 44pt * k, weight: 700, fill: t.ink,
                  [#s.title <ts-title-slide-title>]), t.accent.lighten(80%), k)
    v(26pt * k)
    text(21pt * k, fill: t.muted, untertitel(s))
  }))
  am-anfang(bottom, m, dy: -m.bottom, dx: 10pt * k,
    text(font: skizze-schrift, 13pt * k, fill: t.muted, unterzeile(s)))
}

#let skizze-abschnitt(t, s, geo) = {
  let k = geo.scale
  grund(t.paper, "section")
  let n = abschnitt-nr(s)
  place(center + horizon, rotate(-2deg, box(width: geo.width * 0.6, {
    block(width: 100%, fill: zettel-gelb.lighten(45%),
          stroke: 1pt * k + zettel-gelb.darken(25%), radius: 2pt * k,
          inset: (x: 34pt * k, top: 40pt * k, bottom: 36pt * k), {
      let titel = text(font: skizze-schrift,
        ebenen-groesse(36pt, s.at("depth", default: 1), k), weight: 700,
        fill: t.ink, [#s.title <ts-section-slide-title>])
      // Klecks und Titel in einer Zeile, auf die Mitte der Versalhöhe
      // gestellt: der Titel misst von Versalhöhe bis Grundlinie (Vorgabe von
      // `text`), der Klecks ist ein Kasten, und `horizon` legt beider Mitten
      // aufeinander.
      align(center, if n == none { titel } else {
        grid(columns: 2, column-gutter: 16pt * k, align: horizon,
             klecks(str(n), t, size: 20pt * k), titel)
      })
    })
    place(top + center, dy: -12pt * k,
          klebeband(110pt * k, 24pt * k, t.accent.lighten(70%).transparentize(15%),
                    zacke: 4pt * k))
  })))
}

// ═══════════════════════════════════════════════════════════════════════════
//  labor: umrandete Leiste mit Messskala, Monospace-Marken
// ═══════════════════════════════════════════════════════════════════════════

#let labor-mono = "Fira Code"
#let labor-nacht = rgb("#1c2230")

#let labor-tag(body, t, fill: auto, size: 12pt) = marke(body,
  fill: if fill == auto { t.accent } else { fill }, size: size, font: labor-mono,
  weight: 600, inset: (x: 0.45em, y: 0.38em))

/// Die Messskala: kurze Striche, jeder fünfte länger.
#let skala(breite, k, farbe: luma(160), abstand: 8.5pt) = box(width: breite, height: 7pt * k, {
  let a = abstand * k
  for i in range(0, int(breite / a) + 1) {
    place(left + top, dx: i * a, line(start: (0pt, 0pt),
      end: (0pt, if calc.rem(i, 5) == 0 { 7pt * k } else { 3.5pt * k }),
      stroke: 0.6pt * k + farbe))
  }
})

#let labor-kopf(t, titel, geo, s) = {
  let k = geo.scale
  let m = margins(geo)
  let b = innen(geo)
  am-anfang(top, m, dy: 14pt * k, {
    block(width: b, height: 44pt * k, stroke: 1.2pt * k + labor-nacht,
          radius: 3pt * k, inset: (x: 16pt * k),
      align(left + horizon, grid(columns: (auto, 1fr), column-gutter: 0.4em,
        align: horizon,
        text(font: labor-mono, t.title-size * 0.85 * k, weight: 500, fill: t.accent, "//"),
        titel)))
  })
}

#let labor-fuss(t, d, geo) = {
  let k = geo.scale
  am-ende(bottom, margins(geo), dy: -14pt * k,
    [#labor-tag([#d.slide.number/#d.slide.total], t, size: 15pt * k) <ts-slide-number>])
}

#let labor-titel(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  let b = innen(geo)
  grund(t.paper, "title")
  let zeile = subject-line(kuerzel(t))
  am-anfang(top, m, dy: geo.height * 0.2, block(width: b, {
    block(width: b, stroke: 1.4pt * k + labor-nacht, radius: 4pt * k,
          inset: (x: 26pt * k, y: 24pt * k), grid(
      columns: (1fr, auto), column-gutter: 20pt * k,
      align: (left + horizon, right + horizon),
      stack(spacing: 16pt * k,
        if zeile != none {
          text(font: labor-mono, 14pt * k, weight: 500, tracking: 0.04em,
               fill: t.accent, upper(zeile.replace(" · ", " / ")))
        },
        text(..font-args(t.title-font), 42pt * k, weight: 600, fill: t.ink,
             [#s.title <ts-title-slide-title>]),
      ),
      if kuerzel(t) != none { labor-tag(kuerzel(t), t, size: 20pt * k) },
    ))
    v(-1pt * k)
    skala(b, k)
    v(24pt * k)
    text(21pt * k, fill: t.muted, {
      text(font: labor-mono, fill: t.accent, "// ")
      untertitel(s)
    })
  }))
  am-anfang(bottom, m, dy: -m.bottom,
    text(font: labor-mono, 12pt * k, fill: t.muted, unterzeile(s)))
}

#let labor-abschnitt(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(labor-nacht, "section")
  let n = abschnitt-nr(s)
  // Das Raster eines Datenblatts, ganz leise.
  place(top + left, rect(width: 100%, height: 100%, stroke: none,
    fill: tiling(size: (24pt * k, 24pt * k),
      place(dx: 11.4pt * k, dy: 11.4pt * k, circle(radius: 0.6pt * k, fill: white.transparentize(82%))))))
  let hell = t.accent.lighten(35%)
  am-anfang(horizon, m, block(width: innen(geo), stack(spacing: 16pt * k,
    text(font: labor-mono, 18pt * k, weight: 500, fill: hell,
         if n != none { "// " + (if n < 10 { "0" } else { "" }) + str(n) } else { "//" }),
    text(..font-args(t.title-font), ebenen-groesse(40pt, s.at("depth", default: 1), k),
         weight: 600, fill: white, [#s.title <ts-section-slide-title>]),
  )))
  am-anfang(bottom, m, dy: -m.bottom - 24pt * k,
    skala(innen(geo), k, farbe: white.transparentize(55%)))
}

// ═══════════════════════════════════════════════════════════════════════════
//  kontur: dicke Rahmen, harte Schatten, fette Versalien
// ═══════════════════════════════════════════════════════════════════════════

#let kontur-tinte = luma(15)

/// Versalien mit echtem ẞ.
#let versal(body) = {
  let p = klartext(body)
  if p != none and p != "" { upper(p.replace("ß", "ẞ")) } else { upper(body) }
}

#let kontur-kachel(body, t, size: 12pt) = schatten(
  marke(body, fill: t.accent, size: size, radius: 0pt, font: t.title-font,
        stroke: 1.4pt * (size / 12pt) + kontur-tinte, width: 1.75em,
        inset: (x: 0.3em, y: 0.42em)),
  abstand: 3pt * (size / 12pt), fill: kontur-tinte)

#let kontur-kopf(t, titel, geo, s) = {
  let k = geo.scale
  let m = margins(geo)
  am-anfang(top, m, dy: kopf-oben * k, block(width: innen(geo), {
    block(below: 7pt * k, upper(titel))
    line(length: 100%, stroke: 3.5pt * k + kontur-tinte)
  }))
}

#let kontur-fuss(t, d, geo) = {
  let k = geo.scale
  am-ende(bottom, margins(geo), dy: -14pt * k,
    [#kontur-kachel(str(d.slide.number), t, size: 15pt * k) <ts-slide-number>])
}

#let kontur-titel(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  let zeile = subject-line(kuerzel(t))
  am-anfang(top, m, dy: geo.height * 0.22, block(width: innen(geo), {
    grid(columns: (1fr, auto), column-gutter: 20pt * k,
      align: (left + bottom, right + bottom),
      stack(spacing: 18pt * k,
        if zeile != none {
          box(fill: kontur-tinte, inset: (x: 0.55em, y: 0.45em),
              text(13pt * k, weight: 700, tracking: 0.12em, fill: white,
                   top-edge: "cap-height", bottom-edge: "baseline", upper(zeile)))
        },
        {
          set par(leading: 0.3em)
          text(..font-args(t.title-font), 52pt * k, weight: 700, fill: kontur-tinte,
               [#versal(s.title) <ts-title-slide-title>])
        },
      ),
      if kuerzel(t) != none {
        schatten(marke(kuerzel(t), fill: t.accent, size: 20pt * k, radius: 0pt,
                       font: t.title-font, stroke: 2pt * k + kontur-tinte,
                       inset: (x: 0.6em, y: 0.5em)),
                 abstand: 5pt * k, fill: kontur-tinte)
      },
    )
    v(14pt * k)
    line(length: 100%, stroke: 5pt * k + kontur-tinte)
    v(20pt * k)
    text(22pt * k, weight: 700, fill: kontur-tinte, untertitel(s))
  }))
  am-anfang(bottom, m, dy: -m.bottom,
    text(13pt * k, weight: 700, tracking: 0.08em, fill: t.muted, upper(unterzeile(s))))
}

#let kontur-abschnitt(t, s, geo) = {
  let k = geo.scale
  grund(t.paper, "section")
  let n = abschnitt-nr(s)
  place(center + horizon, dx: -4pt * k, dy: -4pt * k, schatten(
    block(width: geo.width * 0.66, fill: t.accent, stroke: 3pt * k + kontur-tinte,
          inset: (x: 34pt * k, y: 34pt * k), {
      if n != none {
        place(top + left, dx: -34pt * k - 16pt * k, dy: -34pt * k - 18pt * k,
          schatten(marke(str(n), fill: white, text-fill: kontur-tinte, size: 24pt * k,
                         radius: 0pt, font: t.title-font, stroke: 3pt * k + kontur-tinte,
                         width: 1.8em, inset: (x: 0.3em, y: 0.42em)),
                   abstand: 5pt * k, fill: kontur-tinte))
      }
      set par(leading: 0.3em)
      text(..font-args(t.title-font), ebenen-groesse(40pt, s.at("depth", default: 1), k),
           weight: 700, fill: white, [#versal(s.title) <ts-section-slide-title>])
    }),
    abstand: 10pt * k, fill: kontur-tinte))
}

// ═══════════════════════════════════════════════════════════════════════════
//  leiste: eine Leiste an der Außenkante trägt Kürzel und Nummer
// ═══════════════════════════════════════════════════════════════════════════

#let leiste-schrift = "Montserrat"

#let rund(body, t, size: 12pt, fill: auto) = text(size, box(width: 1.85em,
  height: 1.85em, fill: if fill == auto { t.accent } else { fill }, radius: 50%,
  align(center + horizon, text(font: leiste-schrift, 0.92em, weight: 700,
                               top-edge: "bounds", bottom-edge: "bounds", fill: white, body))))

/// Die Leiste an der rechten Kante, mit Kürzel oben und Nummer unten.
#let randleiste(t, geo, nummer: none, breite: 20pt) = {
  let k = geo.scale
  place(top + right, dx: -8pt * k, dy: 10pt * k, block(width: breite * k,
    height: geo.height - 20pt * k, fill: t.accent.lighten(80%), radius: 3pt * k, {
    if kuerzel(t) != none {
      place(top + center, dy: 8pt * k, box(fill: t.accent, radius: 2pt * k,
        inset: (x: 0.3em, y: 0.5em), rotate(-90deg, reflow: true,
          text(font: leiste-schrift, 11pt * k, weight: 700, fill: white,
               top-edge: "cap-height", bottom-edge: "baseline", kuerzel(t)))))
    }
    if nummer != none {
      place(bottom + center, dy: -6pt * k, nummer)
    }
  }))
}

#let leiste-kopf(t, titel, geo, s) = {
  let k = geo.scale
  let m = margins(geo)
  am-anfang(top, m, dy: kopf-oben * k, block(width: innen(geo) - 16pt * k, {
    block(below: 8pt * k, titel)
    box(width: 74pt * k, height: 4pt * k, fill: t.accent, radius: 2pt * k)
  }))
}

#let leiste-fuss(t, d, geo) = randleiste(t, geo,
  nummer: [#rund(str(d.slide.number), t, size: 12pt * geo.scale) <ts-slide-number>])

#let leiste-titel(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  randleiste(t, geo, breite: 34pt)
  let zeile = subject-line(kuerzel(t))
  am-anfang(top, m, dy: geo.height * 0.27, block(width: innen(geo) - 40pt * k, stack(
    spacing: 18pt * k,
    if zeile != none {
      text(font: leiste-schrift, 13pt * k, weight: 700, tracking: 0.16em,
           fill: t.accent, upper(zeile))
    },
    {
      set par(leading: 0.4em)
      text(..font-args(t.title-font), 46pt * k, weight: 700, fill: t.ink,
           [#s.title <ts-title-slide-title>])
    },
    box(width: 110pt * k, height: 5pt * k, fill: t.accent, radius: 2.5pt * k),
    text(21pt * k, fill: t.muted, untertitel(s)),
  )))
  am-anfang(bottom, m, dy: -m.bottom, text(13pt * k, fill: t.muted, unterzeile(s)))
}

#let leiste-abschnitt(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.accent.lighten(92%), "section")
  randleiste(t, geo)
  let n = abschnitt-nr(s)
  am-anfang(horizon, m, block(width: innen(geo) - 40pt * k, grid(
    columns: (auto, 1fr), column-gutter: 22pt * k, align: horizon,
    if n != none { rund(str(n), t, size: 26pt * k) }
    else { box(width: 22pt * k, height: 22pt * k, fill: t.accent, radius: 50%) },
    text(..font-args(t.title-font), ebenen-groesse(38pt, s.at("depth", default: 1), k),
         weight: 700, fill: t.ink, [#s.title <ts-section-slide-title>]),
  )))
}

// ═══════════════════════════════════════════════════════════════════════════
//  riso: Zweifarbdruck, Fachfarbe plus Pink, Rasterpunkte
// ═══════════════════════════════════════════════════════════════════════════

#let riso-pink = rgb("#ff4f9a")

#let raster(fill, abstand: 6pt, radius: 1.15pt) = tiling(size: (abstand, abstand),
  place(dx: abstand / 2 - radius, dy: abstand / 2 - radius, circle(radius: radius, fill: fill)))

/// Zwei Druckfarben übereinander, die zweite leicht verrutscht. `zeichne`
/// bekommt eine Farbe und gibt den Inhalt in ihr zurück; die obere Lage ist
/// `oben` (mit der Marke), die untere entsteht aus `zeichne`.
#let doppelt(oben, zeichne, k) = box({
  place(top + left, dx: 2.6pt * k, dy: 2.2pt * k, zeichne(riso-pink.transparentize(45%)))
  oben
})

#let riso-marke(body, t, size: 12pt) = text(size, box(
  width: 1.75em + 4.5pt * (size / 12pt), height: 1.75em + 4.5pt * (size / 12pt), {
    let d = 4.5pt * (size / 12pt)
    place(top + left, dx: d, dy: d, rect(width: 1.75em, height: 1.75em, radius: 0.3em,
      fill: raster(riso-pink, abstand: 3pt * (size / 12pt), radius: 0.9pt * (size / 12pt))))
    place(top + left, box(width: 1.75em, height: 1.75em, fill: t.accent, radius: 0.3em,
      align(center + horizon, text(font: t.title-font, 0.9em, weight: 700,
                                   top-edge: "bounds", bottom-edge: "bounds", fill: white, body))))
  }))

#let riso-kopf(t, titel, geo, s) = {
  let k = geo.scale
  let m = margins(geo)
  let unten(c) = text(..font-args(t.title-font), size: t.title-size * k,
                      weight: t.weight, fill: c, s.title)
  am-anfang(top, m, dy: kopf-oben * k, block(width: innen(geo), doppelt(titel, unten, k)))
}

#let riso-fuss(t, d, geo) = {
  let k = geo.scale
  am-ende(bottom, margins(geo), dy: -10pt * k,
    [#riso-marke(str(d.slide.number), t, size: 15pt * k) <ts-slide-number>])
}

#let riso-titel(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  // Ein Rasterkreis in Pink, ein voller in der Fachfarbe, leicht verrutscht.
  place(top + right, dx: -40pt * k, dy: 30pt * k, {
    circle(radius: 95pt * k, fill: raster(riso-pink, abstand: 7pt * k, radius: 1.6pt * k))
    place(top + left, dx: 50pt * k, dy: 46pt * k,
          circle(radius: 70pt * k, fill: t.accent.transparentize(20%)))
  })
  let zeile = subject-line(kuerzel(t))
  let gross(c, body) = text(..font-args(t.title-font), 50pt * k, weight: 700, fill: c, body)
  am-anfang(top, m, dy: geo.height * 0.3, block(width: innen(geo) * 0.72, {
    if zeile != none {
      text(14pt * k, weight: 700, tracking: 0.14em, fill: riso-pink.darken(25%), upper(zeile))
      v(16pt * k)
    }
    set par(leading: 0.35em)
    doppelt(gross(t.accent.darken(8%), [#s.title <ts-title-slide-title>]),
            c => gross(c, s.title), k)
    v(14pt * k)
    rect(width: 100%, height: 12pt * k, stroke: none,
         fill: raster(riso-pink.transparentize(30%), abstand: 6pt * k, radius: 1.15pt * k))
    v(16pt * k)
    text(22pt * k, fill: t.ink, untertitel(s))
  }))
  if kuerzel(t) != none {
    let d = 5pt * k
    let form(fill, tf) = marke(kuerzel(t), fill: fill, text-fill: tf, size: 19pt * k,
      radius: 0.3em, font: t.title-font, inset: (x: 0.6em, y: 0.5em))
    am-ende(bottom, m, dy: -m.bottom - d, box({
      place(top + left, dx: d, dy: d, form(raster(riso-pink, abstand: 3.4pt * k,
                                                   radius: 1pt * k), rgb(0, 0, 0, 0)))
      form(t.accent, white)
    }))
  }
  am-anfang(bottom, m, dy: -m.bottom, text(13pt * k, fill: t.muted, unterzeile(s)))
}

#let riso-abschnitt(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "section")
  place(top + left, rect(width: 100%, height: 100%, stroke: none,
    fill: raster(riso-pink.transparentize(65%), abstand: 9pt * k, radius: 1.6pt * k)))
  let n = abschnitt-nr(s)
  let gross(c, body) = text(..font-args(t.title-font),
    ebenen-groesse(42pt, s.at("depth", default: 1), k), weight: 700, fill: c, body)
  am-anfang(horizon, m, dx: 20pt * k, box(fill: t.paper, inset: (x: 26pt * k, y: 22pt * k), {
    if n != none {
      riso-marke(str(n), t, size: 18pt * k)
      v(2pt * k)
    }
    doppelt(gross(t.accent.darken(8%), [#s.title <ts-section-slide-title>]),
            c => gross(c, s.title), k)
  }))
}

// ═══════════════════════════════════════════════════════════════════════════
//  bauhaus: Kreis, Quadrat, Dreieck
// ═══════════════════════════════════════════════════════════════════════════

#let bauhaus-grau = luma(70)

/// Die Form wechselt mit der Nummer: 1 Kreis, 2 Quadrat, 3 Dreieck, 4 Kreis …
/// Die Ziffern stehen in Futura: die Eins der Gill Sans ist von einem I kaum
/// zu unterscheiden.
#let form(n, body, t, size: 12pt) = text(size, box(width: 1.9em, height: 1.9em, {
  let f = calc.rem(n - 1, 3)
  if f == 0 { place(circle(radius: 0.95em, fill: t.accent)) }
  else if f == 1 { place(dx: 0.1em, dy: 0.1em, rect(width: 1.7em, height: 1.7em, fill: t.accent)) }
  else { place(polygon(fill: t.accent, (0.95em, -0.35em), (2.25em, 1.95em), (-0.35em, 1.95em))) }
  place(center + horizon, dy: if f == 2 { 0.38em } else { 0em },
        text(font: "Futura", 0.9em, weight: 700, top-edge: "bounds", bottom-edge: "bounds", fill: white, body))
}))

/// Das Signet: Kreis, Quadrat, Dreieck.
#let signet(t, g) = box(width: g, height: g, {
  place(top + left, circle(radius: g * 0.32, fill: t.accent))
  place(bottom + left, dx: g * 0.07, rect(width: g * 0.4, height: g * 0.4, fill: bauhaus-grau))
  place(bottom + right, polygon(fill: t.accent.lighten(45%),
    (g * 0.23, 0pt), (g * 0.47, g * 0.41), (0pt, g * 0.41)))
})

#let bauhaus-linie(k) = (t) => grid(columns: (35%, 1fr), align: horizon,
  line(length: 100%, stroke: 5pt * k + t.accent),
  line(length: 100%, stroke: 1.2pt * k + bauhaus-grau))

#let bauhaus-kopf(t, titel, geo, s) = {
  let k = geo.scale
  let m = margins(geo)
  am-anfang(top, m, dy: 16pt * k, block(width: innen(geo), {
    block(below: 8pt * k, grid(columns: (auto, 1fr), column-gutter: 12pt * k,
      align: left + bottom, signet(t, 28pt * k), titel))
    bauhaus-linie(k)(t)
  }))
}

#let bauhaus-fuss(t, d, geo) = {
  let k = geo.scale
  am-ende(bottom, margins(geo), dy: -12pt * k,
    [#form(d.slide.number, str(d.slide.number), t, size: 14pt * k) <ts-slide-number>])
}

#let bauhaus-titel(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  // Die Komposition rechts: ein großer Kreis, ein Quadrat, ein Dreieck.
  place(top + right, dx: -m.right, dy: 54pt * k, box(width: 250pt * k, height: 300pt * k, {
    place(top + right, circle(radius: 105pt * k, fill: t.accent))
    place(bottom + left, dx: 10pt * k, rect(width: 120pt * k, height: 120pt * k, fill: bauhaus-grau))
    place(bottom + right, dx: -6pt * k, polygon(fill: t.accent.lighten(45%),
      (60pt * k, 0pt), (120pt * k, 104pt * k), (0pt, 104pt * k)))
  }))
  let zeile = subject-line(kuerzel(t))
  am-anfang(top, m, dy: geo.height * 0.17, block(width: innen(geo) * 0.62, {
    if zeile != none {
      text(14pt * k, weight: 600, tracking: 0.16em, fill: t.accent, upper(zeile))
      v(16pt * k)
    }
    set par(leading: 0.35em)
    text(..font-args(t.title-font), 48pt * k, weight: 700, fill: t.ink,
         [#s.title <ts-title-slide-title>])
    v(16pt * k)
    bauhaus-linie(k)(t)
    v(16pt * k)
    text(22pt * k, fill: t.muted, untertitel(s))
  }))
  if kuerzel(t) != none {
    am-ende(bottom, m, dy: -m.bottom, marke(kuerzel(t), fill: t.accent,
      size: 15pt * k, radius: 0pt, inset: (x: 0.6em, y: 0.5em)))
  }
  am-anfang(bottom, m, dy: -m.bottom, text(13pt * k, fill: t.muted, unterzeile(s)))
}

#let bauhaus-abschnitt(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "section")
  let r = 210pt * k
  place(top + left, box(width: r, height: r, clip: true,
    place(dx: -r, dy: -r, circle(radius: r, fill: t.accent))))
  place(bottom + right, dx: -50pt * k, dy: -46pt * k,
        rect(width: 70pt * k, height: 70pt * k, fill: bauhaus-grau))
  place(bottom + right, dx: -140pt * k, dy: -46pt * k,
        polygon(fill: t.accent.lighten(45%), (30pt * k, 0pt), (60pt * k, 52pt * k), (0pt, 52pt * k)))
  let n = abschnitt-nr(s)
  am-anfang(horizon, m, dx: 220pt * k, block(width: innen(geo) - 230pt * k, stack(
    spacing: 18pt * k,
    if n != none { form(n, str(n), t, size: 22pt * k) },
    text(..font-args(t.title-font), ebenen-groesse(40pt, s.at("depth", default: 1), k),
         weight: 700, fill: t.ink, [#s.title <ts-section-slide-title>]),
  )))
}

// ═══════════════════════════════════════════════════════════════════════════
//  Die acht
// ═══════════════════════════════════════════════════════════════════════════

/// Die acht Unterrichts-Themes. Jedes nimmt seine Akzentfarbe aus dem
/// Klassenkürzel, das `presentation(class: ..)` bekommt, oder aus
/// `presentation(accent: ..)`.
#let schul-themes = (
  // Sparsam und modern: Linien statt Flächen, viel Weißraum, quadratische Marken.
  klar: schul-theme(
    paper: white, ink: luma(30), strong: luma(30), muted: luma(105),
    border: luma(212),
    font: ("Avenir Next",), size: 21pt, title-size: 29pt, weight: 700,
    header: klar-kopf, band-height: 20pt + 29pt * 1.1 + 8pt + 1pt + 18pt,
    title-fill: p => p.ink, footer: klar-fuss, box: "bar",
    title-slide: klar-titel, section: klar-abschnitt,
  ),
  // Farbig wie ein modernes Schulbuch: Titelkarte in der Fachfarbe, runde Ecken.
  atlas: schul-theme(
    paper: white, ink: luma(30), strong: luma(30), muted: luma(105),
    surface: luma(247), border: luma(222),
    font: ("Myriad Pro",), size: 22pt, title-size: 28pt, weight: 700,
    header: atlas-kopf, band-height: 14pt + 46pt + 18pt,
    title-fill: p => lesbar(p.accent, white, p.paper, p.ink), footer: atlas-fuss,
    title-slide: atlas-titel, section: atlas-abschnitt,
  ),
  // Verspielt für die Unterstufe: Handschrift, Klebeband, Zettel.
  skizze: schul-theme(
    paper: rgb("#fffdf8"), ink: luma(35), strong: luma(35), muted: luma(100),
    surface: rgb("#fffdf8"), border: luma(215),
    font: ("SF Pro Rounded",), title-font: (skizze-schrift,), size: 21pt,
    title-size: 29pt, weight: 700,
    header: skizze-kopf, band-height: 20pt + 29pt * 1.2 + 18pt,
    title-fill: p => p.ink, footer: skizze-fuss, box: "label",
    title-slide: skizze-titel, section: skizze-abschnitt,
  ),
  // Technisch für MINT und Informatik: Leiste mit Messskala, Monospace-Marken.
  labor: schul-theme(
    paper: white, ink: luma(25), strong: labor-nacht, muted: luma(105),
    border: luma(200),
    font: ("Fira Sans",), size: 20pt, title-size: 26pt, weight: 600,
    header: labor-kopf, band-height: 14pt + 44pt + 18pt,
    title-fill: p => p.ink, footer: labor-fuss, box: "label",
    title-slide: labor-titel, section: labor-abschnitt,
  ),
  // Plakativ: dicke Rahmen, harte Schatten, fette Futura in Versalien.
  kontur: schul-theme(
    paper: white, ink: kontur-tinte, strong: kontur-tinte, muted: luma(90),
    border: kontur-tinte,
    font: ("Helvetica Neue",), title-font: ("Futura",), size: 21pt,
    title-size: 30pt, weight: 700, tracking: 0.3pt,
    header: kontur-kopf, band-height: 20pt + 30pt * 1.0 + 7pt + 4pt + 18pt,
    title-fill: p => p.ink, footer: kontur-fuss, derive: none,
    title-slide: kontur-titel, section: kontur-abschnitt,
  ),
  // Kennung am Rand: eine Leiste an der Außenkante trägt Kürzel und Nummer.
  leiste: schul-theme(
    paper: white, ink: luma(30), strong: luma(30), muted: luma(105),
    border: luma(215),
    font: ("Lato",), title-font: (leiste-schrift,), size: 21pt, title-size: 28pt,
    weight: 700,
    header: leiste-kopf, band-height: 20pt + 28pt * 1.1 + 8pt + 4pt + 18pt,
    title-fill: p => p.ink, footer: leiste-fuss,
    title-slide: leiste-titel, section: leiste-abschnitt,
  ),
  // Wie im Zweifarbdruck: Fachfarbe plus Pink, Rasterpunkte, Slab-Schrift.
  riso: schul-theme(
    paper: rgb("#fdfaf4"), ink: luma(25), strong: luma(25), muted: luma(100),
    surface: rgb("#fdfaf4"), border: luma(215),
    font: ("PT Sans",), title-font: ("Rockwell",), size: 22pt, title-size: 30pt,
    weight: 700,
    header: riso-kopf, band-height: 20pt + 30pt * 1.1 + 18pt,
    title-fill: p => p.accent.darken(8%), footer: riso-fuss,
    title-slide: riso-titel, section: riso-abschnitt,
  ),
  // Geometrisch: Kreis, Quadrat und Dreieck als Signet und Nummern.
  bauhaus: schul-theme(
    paper: white, ink: luma(25), strong: luma(25), muted: luma(100),
    border: luma(210),
    font: ("Gill Sans",), size: 23pt, title-size: 30pt, weight: 700,
    header: bauhaus-kopf, band-height: 16pt + 28pt + 8pt + 5pt + 18pt,
    title-fill: p => p.ink, footer: bauhaus-fuss,
    title-slide: bauhaus-titel, section: bauhaus-abschnitt,
  ),
)

/// Alle Themes des Pakets: die fünf älteren und die acht für den Unterricht.
#let themes = grund-themes + schul-themes
