// Desmos-Rechner in den Folien.
//
// Der Graph gehört Desmos, die Dramaturgie der Folie -- dieselbe Aufteilung
// wie bei GeoGebra nebenan. Auch dieses Modul kennt vom Kern nur, was jedes
// Begleitpaket kennt: `embed(bridge: …)` meldet einen Rahmen als Ziel an,
// `bridge-job` schickt ihm auf einem Schritt etwas zu. Kein Sonderweg.
//
// Ein Deck ohne Rechner zahlt dafür nichts: Bootskript und Dokument stehen
// hinter `desmos()`, und was nicht gerufen wird, steht nicht in der Ausgabe.

#import "bridge.typ": bridge-job, bridge-targets
#import "media.typ": embed
#import "themes.typ": theme-state

/// Das Bootskript, beim Übersetzen gelesen -- wie das der GeoGebra-Seite eine
/// Laufzeitdatei, die wörtlich im `srcdoc` des Rahmens steht.
#let boot = read("../assets/desmos-boot.js")

/// Der Demo-Schlüssel aus Desmos' eigener Dokumentation.
///
/// Er ist ausdrücklich zum Ausprobieren gedacht, nicht für den Betrieb. Das
/// geladene Skript sagt es selbst in der Konsole: "This page is using the
/// Desmos API with a trial key suitable for prototyping, not for commercial
/// use." Einen eigenen gibt es über #link("https://www.desmos.com/my-api").
#let demo-key = "dcb31709b452b1cf9dc26972add0fda6"

/// Der Name des Rechners, für den ein Befehl gedacht ist.
///
/// `auto` heißt: der eine Rechner auf dieser Folie. Bei keinem oder mehreren
/// gibt es nichts zu erraten, und stillschweigend fallenlassen wäre die
/// schlechteste Auskunft -- also sagt es das.
///
/// Muss in einem `context` stehen.
#let resolve-target(target) = {
  if target != auto {
    return if type(target) == label { str(target) } else { target }
  }
  let found = bridge-targets()
  if found.len() == 1 { return found.first() }
  if found.len() == 0 {
    panic("typstage: no Desmos graph on this slide — put a #desmos(…) "
          + "on it, or name the target explicitly with target: \"…\".")
  }
  panic("typstage: " + str(found.len()) + " bridged elements on this slide ("
        + found.join(", ") + ") — say which one is meant, e.g. target: \""
        + found.first() + "\".")
}

/// Ein Desmos-Graph auf der Folie.
///
/// - `api-key` ist Pflicht. Desmos gibt sein Skript ohne Schlüssel nicht
///   heraus -- gemessen antwortet der Server dann mit 403. Zum Ausprobieren
///   gibt es `demo-key`; wer damit vorträgt, trägt Desmos' Konsolenwarnung
///   mit sich herum und arbeitet außerhalb dessen, wofür der Schlüssel
///   gedacht ist.
/// - `expressions` ist das Startbild als Wörterbuch von `id` nach `LaTeX`.
///   Ein
///   Ausdruck mit `=` ist ein Regler, einer ohne eine Kurve; das entscheidet
///   Desmos.
/// - `bounds` ist der Ausschnitt als `(links, rechts, unten, oben)`.
#let desmos(
  ..name,
  id: "dsm",
  api-key: none,
  version: "1.11",
  expressions: (:),
  bounds: none,
  // Die Bedienfläche ist per Vorgabe weg. Eine Folie zeigt einen Graphen, kein
  // Rechnerfenster; wer die Liste will, schaltet sie an.
  expression-list: false,
  settings-menu: false,
  zoom-buttons: false,
  keypad: false,
  // Den Ausschnitt zieht die Folie, nicht die Hand -- wie bei GeoGebra. Wer im
  // Vortrag danebengreift, schöbe sonst die ganze Ebene weg.
  pan: false,
  grid: auto,
  axes: auto,
  axis-numbers: auto,
  seamless: true,
  background: auto,
  width: 100%,
  height: 330pt,
  at: "1-",
  fallback: none,
  link: none,
) = context {
  assert(name.pos().len() <= 1,
         message: "typstage: desmos() takes at most a name")
  let id = if name.pos().len() == 1 { name.pos().first() } else { id }
  let id = if type(id) == label { str(id) } else { id }
  assert(api-key != none, message:
    "typstage: desmos() needs an api-key. Desmos serves its script only with "
    + "one -- without it the request comes back 403. For trying things out "
    + "there is `demo-key`, which Desmos documents for prototyping and marks "
    + "as such in the browser console; a key of your own comes from "
    + "https://www.desmos.com/my-api.")
  assert(type(expressions) == dictionary, message:
    "typstage: desmos(expressions: …) is a dictionary of id to LaTeX, not "
    + str(type(expressions)) + ".")
  assert(bounds == none or (type(bounds) == array and bounds.len() == 4),
         message: "typstage: desmos(bounds: …) is (left, right, bottom, top).")

  let bg = if background == auto { theme-state.get().paper } else { background }

  // Die Optionsnamen sind Desmos', nicht meine. Ein Name, den es dort nicht
  // gibt, wird still verworfen -- deshalb steht hier nur, was in der API-Doku
  // von v1.11 aufgeführt ist.
  let params = (
    expressions: expression-list,
    settingsMenu: settings-menu,
    zoomButtons: zoom-buttons,
    keypad: keypad,
    lockViewport: not pan,
    border: not seamless,
  )
  // Nicht als Klammerliteral aus lauter `..`-Spreads: das liest Typst als
  // Array, nicht als Wörterbuch, und `json.encode` schriebe dann `[]` statt
  // `{}` in den Rahmen.
  let settings = (:)
  if grid != auto { settings.insert("showGrid", grid) }
  if axes != auto {
    settings.insert("showXAxis", axes)
    settings.insert("showYAxis", axes)
  }
  if axis-numbers != auto {
    settings.insert("xAxisNumbers", axis-numbers)
    settings.insert("yAxisNumbers", axis-numbers)
  }

  // Das Startbild wird im Rahmen ausgeführt, sobald der Rechner steht. Als
  // Liste gebaut und dann verbunden: ein `+` am Zeilenanfang läse Typst als
  // Vorzeichen, und die Meldung dazu ("cannot apply unary '+' to string")
  // nennt die Ursache nicht.
  let stuecke = ()
  if settings.len() > 0 {
    stuecke.push("try{calc.updateSettings(" + json.encode(settings)
                 + ");}catch(e){}")
  }
  if bounds != none {
    stuecke.push("try{calc.setMathBounds(" + json.encode((
      left: bounds.at(0), right: bounds.at(1),
      bottom: bounds.at(2), top: bounds.at(3),
    )) + ");}catch(e){}")
  }
  for (k, v) in expressions.pairs() {
    stuecke.push("try{calc.setExpression({id:" + json.encode(k) + ",latex:"
                 + json.encode(v) + "});}catch(e){}")
  }
  let bootview = stuecke.join("")

  let boot-js = boot
    .replace("__PARAMS__", json.encode(params))
    .replace("__ID__", json.encode(id))
    .replace("__BOOTVIEW__", bootview)

  let doc = (
    "<!doctype html><meta charset=\"utf-8\">"
      + "<style>html,body{margin:0;height:100%;overflow:hidden"
      + (if seamless { ";background:" + bg.to-hex() } else { "" }) + "}"
      + ".ts-fit{width:100%;height:100%}"
      // Desmos legt eine eigene Fläche unter den Graphen. Ohne das hier bliebe
      // auf einem dunklen Theme ein heller Kasten stehen -- genau der Rahmen,
      // den `seamless` wegnehmen soll.
      + (if seamless {
           ".dcg-container,.dcg-grapher{background:" + bg.to-hex() + "!important}"
         } else { "" })
      + "</style>"
      + "<div id=\"ts-dsm\" class=\"ts-fit\"></div>"
      + "<script src=\"https://www.desmos.com/api/v" + version
      + "/calculator.js?apiKey=" + api-key + "\"></script>"
      + "<script>" + boot-js + "</script>"
  )

  embed(
    html: doc,
    bridge: id,
    // Kein `zoom`, aus demselben Grund wie beim Applet nebenan: der Rahmen
    // stünde sonst in Folienpunkten und würde danach vergrößert, und was
    // darin rechnet, zählt die Vergrößerung ein zweites Mal.
    zoom: false,
    width: width, height: height, at: at,
    fallback: fallback, link: link,
    label: [Desmos graph],
  )
}

/// Ausdrücke setzen oder ändern -- ein Wörterbuch von `id` nach `LaTeX`.
///
/// Dieselbe `id` noch einmal ersetzt den Ausdruck, statt einen zweiten
/// anzulegen. So bewegt sich eine Kurve über die Schritte.
#let dsm-set(values, target: auto, at: "1-") = context bridge-job(
  resolve-target(target), ("set": values), at: at)

/// Ganze Ausdrucksobjekte durchreichen, für alles, was `dsm-set` nicht kann --
/// Farbe, Reglergrenzen und Stil in einem Zug.
#let dsm-expr(..objects, target: auto, at: "1-") = context bridge-job(
  resolve-target(target), (expr: objects.pos()), at: at)

/// Ausdrücke entfernen.
#let dsm-remove(..ids, target: auto, at: "1-") = context bridge-job(
  resolve-target(target), (rm: ids.pos()), at: at)

/// Ausdrücke zeigen.
#let dsm-show(..ids, target: auto, at: "1-") = context bridge-job(
  resolve-target(target), (vis: (ids: ids.pos(), on: true)), at: at)

/// Ausdrücke verbergen. Sie bleiben im Graphen und rechnen weiter mit.
#let dsm-hide(..ids, target: auto, at: "1-") = context bridge-job(
  resolve-target(target), (vis: (ids: ids.pos(), on: false)), at: at)

/// Aussehen eines Ausdrucks. Die Schlüssel sind Desmos' eigene.
#let dsm-style(
  ..ids, target: auto, at: "1-",
  color: none, line-style: none, line-width: none, line-opacity: none,
  point-style: none, point-size: none, fill: none, fill-opacity: none,
  label: none, show-label: none, drag-mode: none,
) = context bridge-job(resolve-target(target), (style: (
  ids: ids.pos(),
  ..if color != none { (color: if type(color) == str { color } else { color.to-hex() }) },
  ..if line-style != none { (lineStyle: line-style) },
  ..if line-width != none { (lineWidth: line-width) },
  ..if line-opacity != none { (lineOpacity: line-opacity) },
  ..if point-style != none { (pointStyle: point-style) },
  ..if point-size != none { (pointSize: point-size) },
  ..if fill != none { (fill: fill) },
  ..if fill-opacity != none { (fillOpacity: fill-opacity) },
  ..if label != none { (label: label) },
  ..if show-label != none { (showLabel: show-label) },
  ..if drag-mode != none { (dragMode: drag-mode) },
)), at: at)

/// Der Ausschnitt, als `(links, rechts, unten, oben)`, und die Grapheinstellungen.
#let dsm-view(target: auto, at: "1-", bounds: none, grid: none, axes: none,
              axis-numbers: none, degrees: none, polar: none) = context {
  let settings = (:)
  if grid != none { settings.insert("showGrid", grid) }
  if axes != none {
    settings.insert("showXAxis", axes)
    settings.insert("showYAxis", axes)
  }
  if axis-numbers != none {
    settings.insert("xAxisNumbers", axis-numbers)
    settings.insert("yAxisNumbers", axis-numbers)
  }
  if degrees != none { settings.insert("degreeMode", degrees) }
  if polar != none { settings.insert("polarMode", polar) }
  let inhalt = (:)
  if bounds != none { inhalt.insert("bounds", bounds) }
  if settings.len() > 0 { inhalt.insert("settings", settings) }
  bridge-job(resolve-target(target), (view: inhalt), at: at)
}

/// Desmos' eigene Regleranimation an- oder abschalten.
///
/// Sie läuft mit Desmos' Geschwindigkeit und ohne Ziel. Wer von einer Zahl zu
/// einer anderen will und dann stehenbleiben, nimmt `dsm-tween`.
#let dsm-animate(..ids, target: auto, at: "1-", playing: true,
                 min: none, max: none, step: none) = context {
  let auftrag = (ids: ids.pos(), playing: playing)
  let grenzen = (:)
  // Desmos will die Reglergrenzen als Zeichenketten. `json.encode` und nicht
  // `str`, weil `str(-5)` ein typografisches Minus liefert.
  if min != none { grenzen.insert("min", json.encode(min)) }
  if max != none { grenzen.insert("max", json.encode(max)) }
  if step != none { grenzen.insert("step", json.encode(step)) }
  if grenzen.len() > 0 { auftrag.insert("bounds", grenzen) }
  bridge-job(resolve-target(target), (anim: auftrag), at: at)
}

/// Einen Regler von einer Zahl zur anderen ziehen, in einer gegebenen Zeit.
///
/// Zwei Aufträge, wie bei `ggb-tween` nebenan, und der zweite ist der
/// wichtigere: Die Bewegung liegt auf *genau* diesem Schritt, und ab dem
/// nächsten steht der Endwert einfach da. Ohne das liefe sie auf jedem
/// weiteren Schritt der Folie noch einmal an -- gemessen sprang der Regler
/// beim Weiterblättern von 3 zurück auf 0,75 und wuchs erneut, weil ein
/// ganzzahliges `at` zu "ab diesem Schritt" wird und nicht zu "auf diesem".
///
/// Auf Papier und beim Zurückblättern steht das Ergebnis sofort da: eine
/// Bewegung, die niemand sieht, ist keine.
#let dsm-tween(name, target: auto, to: 1.0, from: none, at: 1,
               duration: 600, easing: "ease") = context {
  assert(type(at) == int,
         message: "typstage: dsm-tween() needs a step number")
  let who = resolve-target(target)
  bridge-job(who, (tween: (
    name: name, to: to, duration: duration, easing: easing,
    ..if from != none { (from: from) },
  )), at: str(at))
  bridge-job(who, ("set": ((name): name + "=" + json.encode(to))),
             at: str(at + 1) + "-")
}
