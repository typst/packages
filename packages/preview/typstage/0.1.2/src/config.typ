// Sizes, colours and the runtime files.
//
// Everything here is data: nothing in this file produces output.

/// Version of the runtime. It goes into the asset file names so a CDN can hold
/// several releases side by side and no browser serves a stale one from cache.
#let runtime-version = "0.1.2"

/// Default slide geometry. 16:9 on an A4-width canvas, so a slide and a
/// handout page carry text at the same physical size. `presentation` takes
/// `width`, `height` and `margin` to override them.
#let slide-width = 841.89pt
#let slide-height = slide-width * 9 / 16
#let slide-margin = 32pt

/// Work out the canvas from what the deck asked for.
///
/// `scale` is the heart of it: everything the theme draws, header height,
/// type sizes and rules, is given in points of the default canvas and multiplied
/// by this. A deck at half the width then looks the same, only smaller,
/// instead of carrying a header built for a canvas twice its size.
///
/// Only the *ratio* really changes the layout, and that is the point: 4:3 is
/// `height: width * 3 / 4`.
#let canvas(width: auto, height: auto, margin: auto) = {
  let w = if width == auto { slide-width } else { width }
  let k = w / slide-width
  (
    width: w,
    height: if height == auto { w * 9 / 16 } else { height },
    margin: if margin == auto { slide-margin * k } else { margin },
    scale: k,
  )
}

/// The four margins of the canvas, individually.
///
/// `margin` may be a length or a dictionary; a theme wants the four values
/// individually and should not have to take it apart every time.
#let margins(geo) = {
  let m = geo.margin
  if type(m) != dictionary { return (left: m, right: m, top: m, bottom: m) }
  let seite(name, achse) = m.at(name, default: m.at(achse, default: 0pt))
  (
    left: seite("left", "x"), right: seite("right", "x"),
    top: seite("top", "y"), bottom: seite("bottom", "y"),
  )
}

/// The default palette. Override it by wrapping the presentation in your own
/// document template. See `style` on `presentation`.
#let dark = rgb("#23303f")
#let accent = rgb("#eb5e28")
#let paper = rgb("#fafafa")
#let muted = luma(45%)

/// The two runtime files, read at compile time so there is a single source of
/// truth: whether they are inlined, linked next to the HTML or fetched from a
/// CDN, it is always this text.
#let runtime-css = read("../assets/typstage-" + runtime-version + ".css")
#let runtime-js = read("../assets/typstage-" + runtime-version + ".js")

/// The words that the runtime itself displays: the hint at `s` without
/// a note, the key help at `?`, and the labels of the speaker view.
///
/// They follow `text.lang`, so a German deck shows German words and an
/// English deck shows English ones. Anyone missing a language passes it
/// in via `words:` to `presentation`; English is the fallback.
///
/// `sp` stands for the speaker view. The keys inside it go unchanged
/// into the JSON and are read that way in the runtime code, so they carry
/// no hyphens there.
/// Defaults that become visible on the slide, in the language of the document.
///
/// The runtime has `runtime-words` for that; this here is the counterpart
/// for the Typst side, where `callout` and `embed` each carry a label. They
/// used to be fixed in English, while everything next to them followed
/// `text.lang`.
#let doc-words = (
  de: (note: [Merke], embedded: [Eingebetteter Inhalt],
       back-to-contents: [Zurück zum Verzeichnis]),
  en: (note: [Note], embedded: [Embedded content],
       back-to-contents: [Back to contents]),
  fr: (note: [À retenir], embedded: [Contenu intégré],
       back-to-contents: [Retour au sommaire]),
  // Three languages that read from the right, so a deck in one of them does
  // not carry an English tab on its callout while everything else mirrors.
  ar: (note: [ملاحظة], embedded: [محتوى مضمّن],
       back-to-contents: [العودة إلى المحتويات]),
  fa: (note: [توجه], embedded: [محتوای جاسازی‌شده],
       back-to-contents: [بازگشت به فهرست]),
  he: (note: [הערה], embedded: [תוכן מוטבע],
       back-to-contents: [חזרה לתוכן העניינים]),
)

/// Fetch one such default. Only callable in context, because `text.lang` is
/// only settled there.
#let doc-word(key) = {
  let l = doc-words.at(text.lang, default: doc-words.en)
  l.at(key, default: doc-words.en.at(key))
}

#let runtime-words(lang) = {
  let listen = (
    de: (no-note: "keine Notiz",
         help: "← → blättern · 1–9 Uhr · 0 Uhr aus · o Übersicht · f Vollbild · n Sprecheransicht",
         help-speaker-short: "← → blättern · b schwarz · e einfrieren · t Klassenuhr · m Stift/Zeiger · ⇧L hell/dunkel · ? alle Tasten",
         help-speaker: "Blättern: ← →|Folie · ↑ ↓|Notiz rollen · Pos1|zum Anfang · Ende|zum Schluss · o|Übersicht § Saal: b|schwarz · e|einfrieren · n|Vortrag nach vorn § Zeit: 1–9|Minuten als Uhr · 0|Uhr aus · t|Klassenuhr · ⇧t|Uhr auf der Folie · ⇧← ⇧→|eine Minute · d|Zieldauer · r|Stundenzähler zurück § Zeichnen: m|Stift/Zeiger · c|Farbe · z|Strich zurück · x|Folie löschen § Ansicht: ⇧L|hell/dunkel · h|Tastenleiste · k|Medienpause · j/l|−/+ 10 s · + −|Notizgröße · f|Vollbild · ?|alle Tasten",
         sp: (clock: "Uhrzeit",
              youtubeLoading: "YouTube wird geladen…",
              youtubeLoad: "YouTube konnte nicht geladen werden (Netzwerk / Einbettungsrechte).",
              youtubeOrigin: "Deck über HTTP(S) öffnen; YouTube benötigt einen Referer.",
              youtubeUnavailable: "Video nicht verfügbar oder Einbettung nicht erlaubt.",
              youtubeBlocked: "Play auf der Bühne anklicken, um die Wiedergabe zu erlauben.", elapsed: "verstrichen", target: "Ziel (min)",
              left: "Rest", pace: "Plan",
              note: "Notiz", next: "als Nächstes", current: "laufende Folie",
              nextStep: "nächster Schritt", nextSlide: "nächste Folie",
              end: "Ende des Vortrags", slide: "Folie", step: "Schritt",
              ahead: "vor Plan", behind: "hinter Plan", onplan: "im Plan",
              black: "schwarz", frozen: "eingefroren", pen: "Stift",
              pointer: "Zeiger", erase: "Radierer",
              tools: "Werkzeuge", undo: "zurück", clear: "löschen",
              // Die Namen der drei Gruppen in der Werkzeugkachel. Sie
              // stehen nur da, wo die Kachel quer liegt und Platz dafür
              // hat -- dann sieht sie aus wie ein Kasten der Tastenzeile.
              groupTool: "Werkzeug", groupColour: "Farbe",
              groupEdit: "berichtigen", groupView: "Ansicht",
              full: "Vollbild", pinned: "auf der Folie",
              timer: "Klassenuhr", over: "Überzeit",
              // Die Gruppe der Klangtasten in der Tastenleiste. Welche es sind,
              // wählt das Deck; der Hilfetext kann sie nicht kennen.
              sound: "Klang",
              light: "hell", dark: "dunkel",
              lost: "kein Vortragsfenster",
              // Der Griff zwischen Folie und Notiz. Was er tut, steht im
              // Namen; wie man ihn zurücksetzt, im Hinweis -- ein Doppelklick
              // ist der billigste Ausweg, aber niemand errät ihn von selbst.
              split: "Aufteilung Folie und Notiz",
              splitTip: "nach oben ziehen: mehr Notiz · Doppelklick setzt zurück",
              // Die zwei Zahlen, die zugleich Knöpfe sind: was sie tun,
              // und was sie getan haben.
              resetTip: "Stundenzähler zurücksetzen",
              resetDone: "Stundenzähler zurückgesetzt",
              clockTip: "Klassenuhr stellen oder beenden",
              clockDone: "Klassenuhr beendet",
              inkCleared: "Folie gelöscht — z holt sie zurück",
              pointerNone: "auf dieser Folie gibt es nichts zu zeigen")),
    en: (no-note: "no note",
         help: "← → page · 1–9 clock · 0 clock off · o overview · f full screen · n speaker view",
         help-speaker-short: "← → page · b black · e freeze · t class clock · m pen/pointer · ⇧L light/dark · ? all keys",
         help-speaker: "Paging: ← →|slide · ↑ ↓|scroll note · Home|to start · End|to finish · o|overview § Room: b|black · e|freeze · n|raise talk § Time: 1–9|minutes as a clock · 0|clock off · t|class clock · ⇧t|clock on the slide · ⇧← ⇧→|one minute · d|target · r|reset elapsed § Drawing: m|pen/pointer · c|colour · z|undo stroke · x|clear slide § View: ⇧L|light/dark · h|shortcut bar · k|pause media · j/l|−/+ 10 s · + −|note size · f|full screen · ?|all keys",
         sp: (clock: "clock",
              youtubeLoading: "Loading YouTube…",
              youtubeLoad: "YouTube could not load (network / embedding permissions).",
              youtubeOrigin: "Open the deck over HTTP(S); YouTube requires a Referer.",
              youtubeUnavailable: "Video unavailable or embedding not allowed.",
              youtubeBlocked: "Click Play on the stage to allow playback.", elapsed: "elapsed", target: "target (min)",
              left: "remaining", pace: "pace",
              note: "note", next: "up next", current: "current slide",
              nextStep: "next step", nextSlide: "next slide",
              end: "end of talk", slide: "slide", step: "step",
              ahead: "ahead", behind: "behind", onplan: "on plan",
              black: "black", frozen: "frozen", pen: "pen",
              pointer: "pointer", erase: "eraser",
              tools: "tools", undo: "undo", clear: "clear",
              groupTool: "tool", groupColour: "colour",
              groupEdit: "edit", groupView: "view",
              full: "full", pinned: "pinned",
              timer: "class clock", over: "over",
              sound: "sound",
              light: "light", dark: "dark",
              lost: "no talk window",
              split: "slide / note split",
              splitTip: "drag up for more note · double-click resets",
              resetTip: "reset elapsed",
              resetDone: "elapsed reset",
              clockTip: "set or stop the class clock",
              clockDone: "class clock stopped",
              inkCleared: "slide cleared — z brings it back",
              pointerNone: "nothing to point at on this slide")),
    fr: (no-note: "aucune note",
         help: "← → naviguer · 1–9 minuterie · 0 arrêter · o aperçu · f plein écran · n vue présentateur",
         help-speaker-short: "← → naviguer · b noir · e figer · t minuterie · m stylo/pointeur · ⇧L clair/sombre · ? toutes les touches",
         help-speaker: "Naviguer: ← →|diapo · ↑ ↓|défiler la note · Origine|au début · Fin|à la fin · o|aperçu § Salle: b|noir · e|figer · n|ramener l'exposé § Temps: 1–9|minutes en minuterie · 0|arrêter · t|minuterie · ⇧t|minuterie sur la diapo · ⇧← ⇧→|une minute · d|durée visée · r|remettre à zéro § Dessin: m|stylo/pointeur · c|couleur · z|annuler le trait · x|effacer la diapo § Vue: ⇧L|clair/sombre · h|raccourcis · k|pause média · j/l|−/+ 10 s · + −|taille de la note · f|plein écran · ?|toutes les touches",
         sp: (clock: "heure",
              youtubeLoading: "Chargement de YouTube…",
              youtubeLoad: "Impossible de charger YouTube (réseau / autorisation).",
              youtubeOrigin: "Ouvrir le diaporama en HTTP(S) ; YouTube exige un Referer.",
              youtubeUnavailable: "Vidéo indisponible ou intégration interdite.",
              youtubeBlocked: "Cliquer sur Play sur la scène pour autoriser la lecture.", elapsed: "écoulé", target: "durée (min)",
              left: "restant", pace: "rythme",
              note: "note", next: "ensuite", current: "diapo en cours",
              nextStep: "étape suivante", nextSlide: "diapo suivante",
              end: "fin de l'exposé", slide: "diapo", step: "étape",
              ahead: "en avance", behind: "en retard", onplan: "dans les temps",
              black: "noir", frozen: "figé", pen: "stylo",
              pointer: "pointeur", erase: "gomme",
              tools: "outils", undo: "annuler", clear: "effacer",
              groupTool: "outil", groupColour: "couleur",
              groupEdit: "corriger", groupView: "vue",
              full: "plein écran", pinned: "sur la diapo",
              timer: "minuterie", over: "dépassé",
              sound: "son",
              light: "clair", dark: "sombre",
              lost: "pas de fenêtre d'exposé",
              split: "partage diapo / note",
              splitTip: "tirer vers le haut : plus de note · double-clic pour rétablir",
              resetTip: "remettre l'écoulé à zéro",
              resetDone: "écoulé remis à zéro",
              clockTip: "régler ou arrêter la minuterie",
              clockDone: "minuterie arrêtée",
              inkCleared: "diapo effacée — z la ramène",
              pointerNone: "rien à pointer sur cette diapo")),
  )
  listen.at(lang, default: listen.en)
}

/// File name of an asset, carrying the version.
#let asset-name(extension) = "typstage-" + runtime-version + "." + extension

/// The runtime files, ready to be written next to the HTML.
///
/// Typst cannot create files. Whoever uses `assets: "split"` or a CDN writes
/// them out once. The content comes from here so the copies cannot drift.
#let runtime-files = (
  (name: asset-name("css"), content: runtime-css),
  (name: asset-name("js"), content: runtime-js),
)
