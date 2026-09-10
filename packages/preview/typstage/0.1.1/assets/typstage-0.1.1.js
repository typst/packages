
(function () {
  // ── Check surface, part one: the error list ────────────────────────────────
  //
  // This stands before everything else on purpose. A collector that is hung on
  // after `load` misses exactly the errors thrown while the deck is being put
  // together, and those are the ones worth catching. `console.error` and
  // `console.warn` are wrapped too, because the runtime reports several real
  // faults that way and none of them throws.
  //
  // The list is bounded. A deck that throws inside an animation frame would
  // otherwise fill the tab with strings nobody reads.
  var FEHLER = [];
  var VERWORFEN = 0;
  function merke(art, was) {
    // Bounded, but it says so. Silently dropping everything after the
    // two-hundredth entry means a run reports the wrong errors: a flood of
    // warnings would push out the one throw that mattered, and the list would
    // look complete.
    if (FEHLER.length < 200) { FEHLER.push(art + ": " + String(was)); return; }
    VERWORFEN += 1;
    FEHLER[199] = "…and " + VERWORFEN + " more, not recorded";
  }
  // The list is reachable from here on, and not only through `typstage.pruef`
  // at the very end. A deck that dies while being built never gets that far,
  // and then this is the only place that still says why.
  window.typstageFehler = FEHLER;
  addEventListener("error", function (e) {
    merke("error", e.message
      || (e.target && (e.target.src || e.target.href || e.target.currentSrc))
      || e);
  }, true);
  addEventListener("unhandledrejection", function (e) {
    merke("promise", e.reason && e.reason.message ? e.reason.message : e.reason);
  });
  ["error", "warn"].forEach(function (k) {
    var echt = console[k];
    console[k] = function () {
      // The real call first, and the note second and guarded. Turning the
      // arguments into text can throw -- a Symbol, an object whose `toString`
      // throws, a Proxy that refuses the read -- and this wrapper sits in the
      // runtime that ships. Measured before this: `console.error(Symbol("x"))`
      // threw where it used to print, and the output never arrived. A checking
      // aid must not be able to take down the talk it is watching.
      echt.apply(console, arguments);
      try { merke(k, [].join.call(arguments, " ")); } catch (x) {
        try { merke(k, "(an argument could not be turned into text)"); }
        catch (y) {}
      }
    };
  });

  var NS = "http://www.w3.org/2000/svg";
  var B = document.getElementById("ts-stage");
  var FLY = document.getElementById("ts-fly");
  var OVERVIEW = document.getElementById("ts-overview");
  var HINT = document.getElementById("ts-hint");
  var SLIDES = [].slice.call(document.querySelectorAll(".ts-slide"));
  var CFG = JSON.parse(document.getElementById("ts-cfg").textContent);
  // Was die Sprecheransicht zeigen soll. Was nicht dasteht, ist an: ein Deck,
  // das nichts sagt, bekommt die ganze Ansicht. Der Vergleich ist ueberall
  // `=== false` und nicht `!`, damit eine fehlende Angabe nicht als Nein zaehlt.
  var SPV = CFG.speakerView || {};
  // Die eine Kurve, die dieses Paket faehrt -- als vier Zahlen, nicht als
  // Zeichenkette. Die Zeichenkette geht an die Web Animations API, die Zahlen
  // an `kurve()`: eine Szene laeuft nicht als Animation, sondern als Folge
  // fertiger Bilder, und wer das Bild waehlt, muss die Kurve selbst rechnen
  // koennen. Zwei Schreibweisen derselben Kurve waeren zwei Stellen, an denen
  // sie auseinanderlaufen kann.
  var EASE_P = [0.4, 0, 0.2, 1];
  var EASE = "cubic-bezier(" + EASE_P.join(",") + ")";

  // Der y-Wert der Kurve zur Zeit `u`, beide von 0 bis 1. Halbierungsverfahren
  // statt Newton: ein Bildindex ist ganzzahlig, da traegt die letzte
  // Nachkommastelle nichts, und ein Verfahren ohne Ableitung kann nicht
  // davonlaufen.
  function kurve(u) {
    if (!(u > 0)) return 0;
    if (u >= 1) return 1;
    var x1 = EASE_P[0], y1 = EASE_P[1], x2 = EASE_P[2], y2 = EASE_P[3];
    function b(t, p1, p2) {
      var m = 1 - t;
      return 3 * m * m * t * p1 + 3 * m * t * t * p2 + t * t * t;
    }
    var lo = 0, hi = 1, t = u;
    for (var i = 0; i < 24; i++) {
      if (b(t, x1, x2) < u) lo = t; else hi = t;
      t = (lo + hi) / 2;
    }
    return b(t, y1, y2);
  }
  var SPRECHERBOX = document.getElementById("ts-speaker");
  var INK = document.getElementById("ts-ink");

  // ── Links that point outside ──────────────────────────────────────────────
  //
  // A link on a slide leads away from the deck. Opening it in the same tab
  // would take the talk with it, and there is no way back that a speaker wants
  // to look for in front of a room.
  //
  // The anchors come out of `html.frame` and sit inside the SVG, where they
  // carry `href` as well as `xlink:href`. Both are read, because which of the
  // two Typst writes is not ours to decide.
  document.querySelectorAll("a").forEach(function (a) {
    var href = a.getAttribute("href") || a.getAttribute("xlink:href") || "";
    if (!/^https?:/i.test(href)) return;
    a.setAttribute("target", "_blank");
    a.setAttribute("rel", "noopener");
  });

  // Internal Typst links point at generated DOM ids. Resolve them to the
  // containing slide so links such as "Back to contents" work in the talk.
  document.querySelectorAll("a").forEach(function (a) {
    var href = a.getAttribute("href") || a.getAttribute("xlink:href") || "";
    if (!/^#/.test(href) || /^#slide-\d+$/.test(href)) return;
    var target = document.getElementById(href.slice(1));
    var slide = target && target.closest(".ts-slide");
    if (!slide) return;
    a.addEventListener("click", function (e) {
      var index = SLIDES.indexOf(slide);
      if (index < 0) return;
      e.preventDefault();
      for (var i = 0; i < STEPS.length; i++) {
        if (STEPS[i].slide === index) { goto(i, true); return; }
      }
    });
  });

  // ── The role, once and for good ───────────────────────────────────────────
  //
  // The same file carries two views: the talk and, with `#speaker` in the
  // address, the speaker view. Which one is meant sits in the hash, and that
  // is exactly the trap, because the hash otherwise belongs to the running
  // step: `goto` keeps writing it forward. The first `goto` would overwrite
  // `#speaker`, and the view would flip back mid-load. So the role is read
  // here once and never fetched from the hash again; in the speaker window
  // the hash is not touched at all anymore.
  var ROLLE = (location.hash.slice(1).split(/[&=]/)[0] || "").toLowerCase()
              === "speaker" ? "speaker" : "stage";
  if (ROLLE === "speaker") document.documentElement.dataset.tsRolle = "speaker";
  // Und gleich mit der Rolle das Erscheinungsbild. Hier und nicht erst beim
  // Aufbau der Ansicht: die Farben der Sprecherbox haengen samt und sonders
  // an `data-ts-licht`, und fehlte es fuer die Dauer eines Bildes, staende
  // die Ansicht einen Wimpernschlag lang farblos da. Siehe `lichtHorchen`,
  // wo begruendet steht, woran die Wahl sich richtet.
  if (ROLLE === "speaker") lichtHorchen();

  // ── Defusing duplicate SVG ids ────────────────────────────────────────────
  //
  // Typst derives the ids in an SVG from the content. The same clipped box
  // twice on one slide, once in the background and once as a sprite, or
  // simply twice, therefore produces the same `<clipPath id>` twice. In HTML
  // an id has to be unique, so `url(#...)` binds to the first occurrence: the
  // second box gets clipped against foreign dimensions and mostly disappears
  // entirely. The same hits the glyphs' `<symbol id>`.
  //
  // Only what is really duplicated gets renamed, and references are only
  // rewired within the same SVG, which is where they belong.
  (function () {
    var gesehen = Object.create(null), lauf = 0;
    document.querySelectorAll("svg").forEach(function (svg) {
      var karte = null;
      svg.querySelectorAll("[id]").forEach(function (el) {
        var alt = el.id;
        if (!gesehen[alt]) { gesehen[alt] = 1; return; }
        var neu = alt + "-ts" + (++lauf);
        el.id = neu;
        gesehen[neu] = 1;
        (karte || (karte = Object.create(null)))[alt] = neu;
      });
      if (!karte) return;
      svg.querySelectorAll("*").forEach(function (u) {
        for (var i = 0; i < u.attributes.length; i++) {
          var a = u.attributes[i], v = a.value;
          if (v.indexOf("#") < 0) continue;
          for (var alt in karte) {
            if (v === "#" + alt) { a.value = "#" + karte[alt]; break; }
            if (v === "url(#" + alt + ")") { a.value = "url(#" + karte[alt] + ")"; break; }
          }
        }
      });
    });
  })();

  // Per-slide settings live on the overlay: it sits inside a `context` and
  // therefore sees marks that were only set while laying out the body.
  function attr(f, name) {
    var o = f.querySelector(".ts-ov");
    return o ? o.dataset[name] : null;
  }

  // ── Die Fahrten je Folie ──────────────────────────────────────────────────
  // Gelesen, bevor die Schritte gezaehlt werden: eine Fahrt bringt einen
  // Schritt mit, auf dem die Folie wieder ganz dasteht.
  var KAMERAS = SLIDES.map(function (f) {
    var s = f.querySelector("script.ts-camera");
    return s ? JSON.parse(s.textContent) : [];
  });

  // ── Step list ─────────────────────────────────────────────────────────────
  // A slide's step count comes from the selectors: those of its elements
  // and those of the bridge jobs.
  var STEPS = [];
  SLIDES.forEach(function (f, i) {
    var n = 1;
    function schau(at) {
      String(at || "").replace(/\d+/g, function (z) { n = Math.max(n, +z); });
    }
    f.querySelectorAll(".ts-el").forEach(function (el) {
      schau(el.dataset.at);
      // Eine Szene ist der eine Fall, in dem der Selektor nicht alles sagt.
      // Sie steht von ihrem ersten Halt an durchgehend da -- ihr Selektor ist
      // also offen und nennt nur, ab wann --, aber sie *verbraucht* einen
      // Schritt je weiterem Halt. Ohne diese Zeile waere eine Folie, auf der
      // nichts als eine Szene steht, einen Schritt lang, und die Szene kaeme
      // nie ueber ihren ersten Halt hinaus.
      if (el.dataset.stops) schau(+el.dataset.from + +el.dataset.stops - 1);
    });
    var s = f.querySelector("script.ts-bridge");
    if (s) JSON.parse(s.textContent).forEach(function (j) { schau(j.at); });
    // Und die Kamerafahrten. Ein geschlossener Bereich braucht einen Schritt
    // *hinter* sich: den Rueckweg. Ohne ihn faehrt eine Kamera als letzte
    // Handlung der Folie hinein und kaeme nie wieder heraus -- die Folie waere
    // auf ihrem letzten Schritt zu Ende, und wer das schreibt, hat vier Zeilen
    // hoeher `at: "3"` geschrieben und nicht `at: 3`.
    KAMERAS[i].forEach(function (j) {
      schau(j.at);
      var e = endeBei(j.at);
      if (isFinite(e)) n = Math.max(n, e + 1);
    });
    f.dataset.steps = n;
    for (var k = 1; k <= n; k++) STEPS.push({ slide: i, step: k });
  });

  // ── Which deck this is ────────────────────────────────────────────────────
  //
  // Under `file://`, Chrome has *all* local files share the same origin:
  // `location.origin` is literally "file://". Anything hung off the origin
  // therefore belongs not to this deck but to every file on the disk. Two
  // places need an id that means the deck and not the origin: the memory
  // across reloads, and the handshake between the windows.
  //
  // The path tells the files apart, the count behind it tells apart two
  // states of the same file.
  var DECK = location.pathname + "|" + SLIDES.length + "." + STEPS.length;

  // ── Selektoren: "2-", "1-2", "2,4", "3" ───────────────────────────────────
  function activeAt(at, s) {
    var parts = String(at || "1-").split(",");
    for (var i = 0; i < parts.length; i++) {
      var t = parts[i].trim();
      if (!t) continue;
      var k = t.indexOf("-");
      if (k < 0) { if (+t === s) return true; continue; }
      var a = t.slice(0, k) === "" ? 1 : +t.slice(0, k);
      var b = t.slice(k + 1) === "" ? Infinity : +t.slice(k + 1);
      if (s >= a && s <= b) return true;
    }
    return false;
  }

  // The last step a selector still covers, or Infinity if it runs to the end
  // of the slide. Only a selector with a last step has an "after" for an
  // element to rest in.
  function endeBei(at) {
    var parts = String(at || "1-").split(","), e = 0;
    for (var i = 0; i < parts.length; i++) {
      var t = parts[i].trim();
      if (!t) continue;
      var k = t.indexOf("-");
      if (k < 0) { e = Math.max(e, +t); continue; }
      if (t.slice(k + 1) === "") return Infinity;
      e = Math.max(e, +t.slice(k + 1));
    }
    return e;
  }

  // ── Geometry ──────────────────────────────────────────────────────────────
  // Marks live in the background SVG. getCTM() maps them into viewBox
  // coordinates; the result is stored as ratios so any window size fits.
  // Collect every mark currently drawn in the slide: background as well as
  // sprites that already found their place.
  function marken(slide, bezug) {
    var karte = {};
    slide.querySelectorAll("path").forEach(function (p) {
      var f = (p.getAttribute("fill") || "").toLowerCase();
      if (f.length !== 9 || f.slice(0, 3) !== "#fe" || f.slice(7) !== "00") return;
      // A mark inside a sprite that has not been placed yet measures
      // nonsense. Only once the parent sits does its content count.
      var wirt = p.closest(".ts-el");
      if (wirt && !wirt.style.width) return;
      var r = p.getBoundingClientRect();
      if (!r.width && !r.height) return;
      karte[parseInt(f.slice(3, 7), 16)] = {
        x: (r.left - bezug.left) / bezug.width,
        y: (r.top - bezug.top) / bezug.height,
        w: r.width / bezug.width, h: r.height / bezug.height,
        // Who the wirt (host) is is already settled here: a marker inside a
        // sprite belongs to a nested element. The step change needs this to
        // inherit fade-in values from the parent.
        wirt: wirt ? wirt.dataset.n : null
      };
    });
    return karte;
  }

  function setzen(el, r) {
    el.style.left = (r.x * 100) + "%";
    el.style.top = (r.y * 100) + "%";
    el.style.width = (r.w * 100) + "%";
    el.style.height = (r.h * 100) + "%";
  }

  // What a nested element does not specify itself, it inherits from its wirt
  // (host), but only if both appear in the same step (same `at`). Reason:
  // sprites hang as siblings in the overlay, not nested inside one another. A
  // `translateY` on the parent therefore does not carry the child along; they
  // only stay in lockstep if they run the same motion with the same values.
  // If one diverged, say `delay: 120` on a staggered list against 0 on the
  // morph inside it, the child arrived before its own container.
  function erbt(el, feld) {
    if (el.dataset[feld] !== undefined) return el.dataset[feld];
    if (!el.dataset.parent) return undefined;
    var folie = el.closest(".ts-slide");
    if (!folie) return undefined;
    var wirt = folie.querySelector('.ts-el[data-n="' + el.dataset.parent + '"]');
    if (!wirt || wirt.dataset.at !== el.dataset.at) return undefined;
    return wirt.dataset[feld];
  }

  // ── Keys out of an embedded frame ─────────────────────────────────────────
  //
  // A frame that has been clicked holds the focus, and from then on every key
  // lands inside it. The window around it hears nothing, so the talk stops
  // paging: reported from a real desk, and in the speaker view it is worse,
  // because `m` is in there too and one cannot even switch back to the pen.
  //
  // Measured on a GeoGebra applet before deciding what to do about it. Focus
  // sits on its `canvas`, it sees all seventeen keys tried, it calls
  // `preventDefault` on none of them, and it changes nothing in the
  // construction. In this configuration, without toolbar and without an
  // algebra input, the applet has no use for the keyboard at all. So the keys
  // belong to the talk, and they are handed back to it.
  //
  // Three conditions, so this stays true for a document that does want keys:
  // it must not have taken the key already (`defaultPrevented`), the key must
  // be one the talk actually uses, and whatever was typed into must not be a
  // text field, or typing an `n` into a form would open a second window.
  //
  // Nur Tasten, auf die auch jemand hoert. Hier standen einmal `s` und `p`
  // mit; gegriffen hat sie niemand, weder im Buehnenfenster noch drueben --
  // durchsucht wurde die ganze Laufzeit, es gibt zu beiden keinen Zweig. Und
  // was hier steht, wird dem eingebetteten Dokument mit `preventDefault`
  // weggenommen: zwei Tasten, die es verlor, ohne dass sie etwas bewirkten.
  var TASTEN_DECK = {
    ArrowRight: 1, ArrowLeft: 1, ArrowUp: 1, ArrowDown: 1,
    PageDown: 1, PageUp: 1, " ": 1, Home: 1, End: 1, Escape: 1,
    o: 1, f: 1, n: 1, "?": 1,
    b: 1, e: 1, t: 1, r: 1, m: 1, c: 1, z: 1, x: 1,
    "+": 1, "=": 1, "-": 1, "_": 1
  };
  function tastenBruecke(frame) {
    // A foreign origin cannot be reached, and it will not become reachable.
    if (frame.tsTastenFremd) return;
    var d = null;
    try { d = frame.contentDocument; } catch (x) { frame.tsTastenFremd = 1; return; }
    // The document is remembered, not a yes or no. A `srcdoc` frame starts on
    // a throwaway `about:blank` and replaces it a moment later, and whoever
    // ticks himself off after the first attempt has hung his listener on the
    // document that was thrown away. Measured: in the talk window the timing
    // happened to work out, in the speaker view it did not, and there the
    // arrow key stayed dead.
    if (!frame.tsTastenLoad) {
      frame.tsTastenLoad = 1;
      frame.addEventListener("load", function () { tastenBruecke(frame); });
    }
    if (!d || frame.tsTastenDoc === d) return;
    frame.tsTastenDoc = d;
    d.addEventListener("keydown", function (e) {
      if (e.defaultPrevented) return;
      if (!TASTEN_DECK[e.key]) return;
      if (tippt(e)) return;
      // Dispatched at our own document, so both receivers see it exactly as
      // they see a key of their own. No loop: this one is not in the frame.
      document.dispatchEvent(new KeyboardEvent("keydown", {
        key: e.key, code: e.code, bubbles: true, cancelable: true,
        ctrlKey: e.ctrlKey, altKey: e.altKey,
        shiftKey: e.shiftKey, metaKey: e.metaKey
      }));
      e.preventDefault();
    });
  }

  // ── Eine Marke ohne Ausdehnung ────────────────────────────────────────────
  //
  // Das Sprite bekommt seine Huelle aus dem Rechteck der Marke. Misst dieses
  // Rechteck in einer Richtung null, so bekommt das SVG darin ein
  // Ansichtsfenster der Breite oder Hoehe null -- und ein solches skaliert
  // seinen Inhalt unter `xMidYMid meet` mit dem Faktor null. Das Element steht
  // dann vollstaendig in der Seite, mit Pfad, Farbe und Strichbreite, und ist
  // trotzdem nicht da: gemessen an einer senkrechten Trennlinie, ueber die
  // ganze Hoehe kein einziger vom Grund abweichender Bildpunkt. Auf Papier
  // stand sie.
  //
  // Das ist der eine Ausgang, den es nicht geben darf: ein Deck verliert ein
  // Element, und nichts sagt es. Zur Uebersetzungszeit ist die Frage nicht zu
  // stellen -- ob ein Inhalt Flaeche hat, weiss Typst im Dokument nicht; es
  // ist derselbe blinde Fleck, wegen dessen dieses Paket ueberhaupt mit
  // Rechtecken in Signalfarbe arbeitet. Erst hier liegt das Rechteck da und
  // laesst sich messen.
  //
  // Einmal je Element und ueber `console.warn`, wie `federKlage`: so landet
  // die Klage in derselben Liste, die `typstage.pruef.fehler()` ausreicht.
  function folieVon(el) {
    var f = el.closest(".ts-slide");
    return f ? SLIDES.indexOf(f) + 1 : 0;
  }
  function masslosKlage(el, wo) {
    if (el.dataset.masslos) return;
    el.dataset.masslos = "1";
    console.warn("typstage: the tracked element " + (el.dataset.n || "?")
      + " on slide " + folieVon(el) + " has a marker with no " + wo + ". Its "
      + "sprite is given a viewport of that extent, and a viewport of zero "
      + "scales everything inside it to nothing: the element is in the page, "
      + "with its path and its colour, and cannot be seen. On paper it "
      + "stands. Put it in a box with a size, or give the element a width.");
  }

  // Der zweite Ausgang derselben Art: eine Marke, die gar nicht gefunden wird.
  // Das Sprite bekommt dann nie einen Ort, bleibt bei `opacity: 0` liegen und
  // fehlt ebenso still. Vier Runden hat `stelle` dafuer; was danach noch offen
  // ist, findet auch in einer fuenften nichts.
  function ohneMarkeKlage(el) {
    if (el.dataset.markenlos) return;
    el.dataset.markenlos = "1";
    console.warn("typstage: the tracked element " + (el.dataset.n || "?")
      + " on slide " + folieVon(el) + " finds no marker to sit on. It is "
      + "never placed and stays invisible. Either its marker has no extent at "
      + "all, or it is nested deeper than four tracked elements, which is as "
      + "far as the placing goes.");
  }

  // In rounds: a nested element has no mark in the background, the outer
  // element's hide() swallows it, but it has one in the outer element's
  // sprite. That one has to be placed first.
  function stelle(i) {
    var svg = SLIDES[i].querySelector(".ts-bg svg");
    if (!svg) return;
    var bezug = svg.getBoundingClientRect();
    if (!bezug.width) return;
    var offen = [].slice.call(SLIDES[i].querySelectorAll(".ts-el"));
    for (var runde = 0; runde < 4 && offen.length; runde++) {
      var karte = marken(SLIDES[i], bezug);
      var rest = [];
      var skala = bezug.width / CFG.width;   // screen pixels per point
      offen.forEach(function (el) {
        var r = karte[+el.dataset.n];
        if (!r) { rest.push(el); return; }
        setzen(el, r);
        // Gestellt ist es jetzt -- aber wenn das Rechteck in einer Richtung
        // nichts misst, ist "gestellt" nur ein Wort.
        if (!r.w || !r.h) {
          masslosKlage(el, !r.w ? (!r.h ? "width and no height"
                                        : "width") : "height");
        }
        if (r.wirt) el.dataset.parent = r.wirt; else delete el.dataset.parent;
        // Corner radius in points, scaled along with the stage.
        if (el.dataset.radius && +el.dataset.radius > 0) {
          el.style.borderRadius = (+el.dataset.radius * skala) + "px";
          el.style.overflow = "hidden";
        }
        // An iframe measures in real CSS pixels and knows nothing of the
        // stage: in a large window its content would stay small inside a big
        // box. So it is given the size in slide units and then zoomed, that
        // way it always sees the same area.
        //
        // Scaled with `transform: scale()`, not `zoom`. `zoom` was the first
        // choice, for a reason that has since been measured false twice.
        //
        // It is wrong in WebKit: `zoom` on an iframe scales the element box
        // *and*, once more, the painting of the document inside it, so the
        // content lands at skala * skala instead of skala. Measured in
        // Safari 26.4 with 0.3: the guest filled 30 % of its frame instead
        // of all of it, and the speaker view -- where the stage sits in a
        // small tile and the scale is far below one -- showed every embedded
        // document far too small. Chromium paints it once, as expected.
        //
        // And the blur that spoke for `zoom` is gone: a frame at 1.71, the
        // scale of an ordinary full-screen stage, comes out as sharp under
        // `transform` as under `zoom`. Engines re-rasterise a frame under a
        // static transform.
        //
        // The price is the layout box: it now stands in slide points, not in
        // screen pixels, so it overhangs its host wherever the stage scales
        // down. The host clips it.
        var frame = el.querySelector("iframe");
        if (frame) {
          tastenBruecke(frame);
          var w = r.w * CFG.width, h = r.h * CFG.height;
          var neu = w + "px|" + h + "px|" + skala;
          if (frame.dataset.mass !== neu) {
            frame.dataset.mass = neu;
            // `zoom: false` means: span the frame in real screen pixels and
            // let the content reflow itself. That is the point of opting
            // out. Otherwise an embedded document would always show the same
            // crop, just rasterised larger.
            var ohneZoom = el.dataset.zoom === "0";
            frame.style.width = (ohneZoom ? w * skala : w) + "px";
            frame.style.height = (ohneZoom ? h * skala : h) + "px";
            frame.style.zoom = "";
            frame.style.transformOrigin = ohneZoom ? "" : "0 0";
            frame.style.transform = ohneZoom ? "" : "scale(" + skala + ")";
            // The scale noted separately: converting a pointer into the frame
            // needs it as a number, and out of `style.transform` it would
            // have to be parsed back.
            if (ohneZoom) delete frame.dataset.skala;
            else frame.dataset.skala = skala;
            el.style.overflow = "hidden";
            // An embedded app that draws has to be told, because its own
            // window need not have changed at all: where only the zoom moves,
            // the inner viewport keeps its size and no `resize` fires in
            // there. The message says "your box is new", and what to do about
            // it is the embedded document's business, not ours.
            // Both measurements, because they say different things. `w` and
            // `h` are the box in points of the slide and therefore the same
            // number in every window; `px` is the same box in screen points
            // and a different number in every window. Whoever wants to draw
            // sharply needs the second, whoever wants every window to show
            // the same thing needs the first.
            try {
              frame.contentWindow.postMessage({ typstage: 1, mass: 1,
                w: w, h: h, px: skala }, "*");
            } catch (e) {}
            // The older, direct way, for a companion package that predates
            // the message.
            try { frame.contentWindow.ggbApplet.recalculateEnvironments(); }
            catch (e) {}
          }
        }
      });
      if (rest.length === offen.length) break;
      offen = rest;
    }
    // Was nach allen Runden keine Marke gefunden hat, bekommt keine mehr.
    offen.forEach(ohneMarkeKlage);
  }

  function vermessen(i) {
    var svg = SLIDES[i].querySelector(".ts-bg svg");
    return svg ? marken(SLIDES[i], svg.getBoundingClientRect()) : {};
  }

  // ── Die Kamera ────────────────────────────────────────────────────────────
  //
  // Typst gibt zur Uebersetzungszeit keine Geometrie heraus -- `here()
  // .position()` liefert in der HTML-Ausgabe ueberall (0, 0), und genau das
  // ist der Grund, warum dieses Paket mit Rechtecken in Signalfarbe arbeitet.
  // Hier unten liegt die Sache umgekehrt: die Rechtecke *muessen* bekannt
  // sein, sonst faende kein Sprite seinen Platz. Eine Kamera haengt sich
  // daran. Sie zielt auf ein `pin`, schlaegt dessen Rechteck nach und rechnet
  // sich aus, wohin sie zu fahren hat.
  //
  // Gefahren werden zwei Ebenen der Folie: der Hintergrund und die
  // Sprite-Ebene darueber. Beide sind derselbe Kasten (`inset:0`), beide
  // bekommen dieselbe Zeichenkette, also bleiben sie deckungsgleich.
  //
  // Was *nicht* mitfaehrt, faellt aus dem Aufbau, den die Seite ohnehin hat:
  // die Folienzier, die Tinte und die Flugebene liegen als eigene Ebenen ueber
  // der Buehne und gehoeren nicht zur Folie. Fussleiste, Fortschritt und
  // laufender Kopf stehen also weiter, wo sie stehen, waehrend die Folie unter
  // ihnen groesser wird; was aus dem Bild faehrt, schneidet `#ts-stage` mit
  // seinem `overflow:hidden` ab. Der Titel dagegen faehrt mit -- er steht im
  // Rumpf der Folie und gehoert ihr.
  //
  // `stelle()` bleibt unberuehrt. Es misst jede Marke im Verhaeltnis zum
  // Kasten des Hintergrund-SVG, und eine gleichmaessige Streckung mit
  // Verschiebung laesst Verhaeltnisse in Ruhe: Zaehler und Nenner bekommen
  // denselben Faktor. Aus demselben Grund steht die Verschiebung in Prozent
  // der eigenen Kastenbreite und nie in Pixeln -- sie ueberlebt jede
  // Fenstergroesse ohne Nachrechnen, und dieselbe Zeichenkette taugt fuer das
  // Standbild der Sprechervorschau, das ein Zehntel so gross ist.

  // Das Rechteck eines Pins, in Verhaeltnissen zum Kasten der Folie. `null`,
  // wenn keiner dieses Namens gezeichnet ist.
  function kameraKasten(slide, nr) {
    var svg = slide.querySelector(".ts-bg svg");
    if (!svg) return null;
    var bezug = svg.getBoundingClientRect();
    if (!bezug.width || !bezug.height) return null;
    var l = null, o = null, r = null, u = null;
    slide.querySelectorAll("path").forEach(function (p) {
      var f = (p.getAttribute("fill") || "").toLowerCase();
      // `#fd` statt `#fe`: das ist der Unterschied zwischen einem Pin und der
      // Messflaeche eines verfolgten Elements.
      if (f.length !== 9 || f.slice(0, 3) !== "#fd" || f.slice(7) !== "00") return;
      if (parseInt(f.slice(3, 7), 16) !== nr) return;
      // Wie bei `marken`: eine Marke in einem Sprite, das noch keinen Platz
      // gefunden hat, misst Unsinn.
      var wirt = p.closest(".ts-el");
      if (wirt && !wirt.style.width) return;
      var k = p.getBoundingClientRect();
      if (!k.width && !k.height) return;
      // Zwei Pins desselben Namens auf einer Folie: die Huelle um beide. Fuer
      // einen Morph ist das der Fall, in dem sich eine Glyphe sichtbar teilt;
      // hier ist es die Antwort auf "zeig mir diese beiden".
      l = l === null ? k.left : Math.min(l, k.left);
      o = o === null ? k.top : Math.min(o, k.top);
      r = r === null ? k.right : Math.max(r, k.right);
      u = u === null ? k.bottom : Math.max(u, k.bottom);
    });
    if (l === null) return null;
    return { x: (l - bezug.left) / bezug.width, y: (o - bezug.top) / bezug.height,
             w: (r - l) / bezug.width, h: (u - o) / bezug.height };
  }

  // Einmal je Name geklagt und nicht je Schritt: wer auf einer Folie hin und
  // her blaettert, bekaeme dieselbe Zeile sonst zwanzigmal.
  var KAMERA_KLAGE = {};

  // Die Verschiebung, die das Detail mitsamt seinem Rand ins Bild rueckt --
  // oder die leere Zeichenkette, also die ganze Folie.
  function kameraFahrt(slide, k) {
    var r = kameraKasten(slide, k.pin);
    if (!r) {
      if (!KAMERA_KLAGE[k.name]) {
        KAMERA_KLAGE[k.name] = 1;
        console.warn("typstage: camera(" + k.name + ") finds no pin of that "
          + "name drawn on this slide. The slide stays whole.");
      }
      return "";
    }
    var mx = (+k.margin || 0) / CFG.width, my = (+k.margin || 0) / CFG.height;
    var x = r.x - mx, y = r.y - my, w = r.w + 2 * mx, h = r.h + 2 * my;
    if (!(w > 0) || !(h > 0)) return "";
    // Die kleinere der beiden Streckungen: nur so ist das ganze Detail zu
    // sehen und nicht seine Mitte.
    var s = Math.min(1 / w, 1 / h);
    // Ein Detail, das schon so gross ist wie die Folie, gibt nichts zu fahren.
    if (!(s > 1.0001)) return "";
    var cx = x + w / 2, cy = y + h / 2;
    return "translate(" + ((0.5 - cx * s) * 100).toFixed(4) + "%,"
         + ((0.5 - cy * s) * 100).toFixed(4) + "%) scale(" + s.toFixed(5) + ")";
  }

  // Welche Fahrt auf einem Schritt gilt. Die letzte, die ihn deckt: zwei
  // Fahrten koennen sich ueberlappen, und dann gewinnt die spaetere im
  // Quelltext -- eine Regel, die man lesen kann, statt zweier Kameras, die
  // sich stumm streiten.
  function kameraStand(i, schritt) {
    var liste = KAMERAS[i] || [], treffer = null;
    for (var k = 0; k < liste.length; k++) {
      if (activeAt(liste[k].at, schritt)) treffer = liste[k];
    }
    return treffer;
  }

  // Eine Ebene an ihren Platz. `sofort` heisst stellen statt fahren: beim
  // Betreten einer Folie und bei einem Sprung gibt es keinen Weg, den jemand
  // gesehen haette. Dasselbe gilt unter "Bewegung reduzieren" -- was dort
  // wegfaellt, ist genau der Weg, und der Ausschnitt selbst ist kein Weg,
  // sondern der Inhalt.
  //
  // Der Ausgangswert wird *gerechnet* abgelesen und nicht aus dem Stil
  // genommen: wer mitten in einer Fahrt weiterblaettert, soll von dort
  // weiterfahren und nicht an den Anfang zurueckspringen. Deshalb erst
  // `getComputedStyle`, dann abbrechen, dann neu setzen.
  function kameraZiehen(el, bis, d, takt, sofort) {
    if ((el.style.transform || "") === bis && !el.tsKam) return;
    var von = getComputedStyle(el).transform;
    if (el.tsKam) { try { el.tsKam.cancel(); } catch (e) {} el.tsKam = null; }
    el.style.transform = bis;
    if (sofort) return;
    // Nichts zu sehen, also nichts zu zeigen. Beide Seiten kommen aus
    // `getComputedStyle` und sind darum gleich geschrieben.
    if (von === getComputedStyle(el).transform) return;
    var a = el.animate([{ transform: von }, { transform: bis || "none" }],
                       { duration: d, easing: takt });
    el.tsKam = a;
    a.onfinish = function () { el.tsKam = null; try { a.cancel(); } catch (e) {} };
  }

  function kameraStellen(i, schritt, sofort) {
    var f = SLIDES[i];
    if (!f) return;
    var k = kameraStand(i, schritt);
    // Der Rueckweg gehoert der Fahrt, aus der er herausfuehrt. Sonst faehre
    // eine Kamera mit `duration: 1400` gemaechlich hinein und schnellte in der
    // Hauszeit wieder heraus.
    var w = k || f.tsKamZuletzt;
    if (k) f.tsKamZuletzt = k;
    var bis = k ? kameraFahrt(f, k) : "";
    var d = (w && +w.duration) || 700;
    var takt = (w && w.easing) || EASE;
    var still = sofort || wenigerBewegung();
    [f.querySelector(".ts-bg"), f.querySelector(".ts-ov")].forEach(function (el) {
      if (el) kameraZiehen(el, bis, d, takt, still);
    });
  }

  // ── Less motion ───────────────────────────────────────────────────────────
  //
  // `prefers-reduced-motion: reduce` is set by the person at the machine, in
  // the operating system, and the browser hands it on. It asks for less
  // motion, not for less deck: what this runtime drops is travel, and only
  // travel. Opacity stays everywhere, because a fade says "this is new"
  // without carrying anything across the screen, and that saying is the
  // whole job of an entrance.
  //
  // Read afresh at every use rather than latched at load. Someone who turns
  // the setting on during a talk gets the next step under the new rule, and
  // a flipbook already running stops within a frame; turning it off again
  // lets everything back in the same way. That costs a media-query lookup
  // per step, which is nothing, and saves a listener plus the state behind
  // it.
  var WENIGER = window.matchMedia
    ? window.matchMedia("(prefers-reduced-motion: reduce)") : null;
  function wenigerBewegung() { return !!(WENIGER && WENIGER.matches); }

  // ── Effects ───────────────────────────────────────────────────────────────
  var EFFECT = {
    "fade":       [{ opacity: 0 }, { opacity: 1 }],
    "fade-up":    [{ opacity: 0, transform: "translateY(14px)" },  { opacity: 1, transform: "none" }],
    "fade-down":  [{ opacity: 0, transform: "translateY(-14px)" }, { opacity: 1, transform: "none" }],
    "fade-left":  [{ opacity: 0, transform: "translateX(22px)" },  { opacity: 1, transform: "none" }],
    "fade-right": [{ opacity: 0, transform: "translateX(-22px)" }, { opacity: 1, transform: "none" }],
    "scale":      [{ opacity: 0, transform: "scale(.86)" },        { opacity: 1, transform: "none" }],
    "scale-down": [{ opacity: 0, transform: "scale(1.14)" },       { opacity: 1, transform: "none" }],
    "blur":       [{ opacity: 0, filter: "blur(7px)" },            { opacity: 1, filter: "blur(0px)" }],
    "rise":       [{ opacity: 0, transform: "translateY(26px) scale(.96)" }, { opacity: 1, transform: "none" }],
    "none":       [{ opacity: 1 }, { opacity: 1 }],
    // Kein Abgang, sondern ein Warten. `aufbau` legt eine Zeichnung in
    // Stufen uebereinander, eine je Schritt, und laesst immer nur eine
    // sehen. Ginge die abtretende Stufe auf dem gewohnten Weg, blendeten
    // zwei fast gleiche Bilder gegeneinander, und die Tinte, die beide
    // teilen, saenke waehrenddessen auf zwei Drittel -- das ganze Bild
    // blinkt. Also bleibt sie stehen, bis die neue da ist, und geht danach
    // ohne Bewegung: `fadeOut` faehrt von 1 nach 1 und setzt am Ende 0.
    //
    // Als Eintritt ist es dasselbe wie "none", und das ist kein Zufall: wer
    // wartet, statt zu gehen, kommt auch, ohne zu kommen. Rueckwaerts wird
    // genau das gebraucht: dort kommt die Stufe herein, die vorwaerts
    // gewartet hat, und sie kommt am besten, ohne zu kommen -- siehe `goto`.
    "hold":       [{ opacity: 1 }, { opacity: 1 }],
    // Sich selbst zeichnen. Was hier steht, ist nur die Haelfte davon: die
    // Blende, unter der die Feder laeuft. Fuer Text und gefuellte Formen ist
    // sie das Ganze -- die haben keine Kontur, die sich abfahren liesse --,
    // und unter "Bewegung reduzieren" bleibt sie fuer alle uebrig. Die andere
    // Haelfte macht `feder()` in `fadeIn` und `fadeOut`.
    "draw":       [{ opacity: 0 }, { opacity: 1 }]
  };

  // ── Ein Pfad, der sich selbst zeichnet ────────────────────────────────────
  //
  // `enter: "draw"`, manims `Create`. Ein gestrichener Pfad traegt seine
  // Laenge in sich: `stroke-dasharray` teilt ihn in einen Strich von genau
  // dieser Laenge und eine Luecke ebenso lang, und `stroke-dashoffset`
  // schiebt den Strich hinein. Bei vollem Versatz ist nichts da, bei null
  // alles -- dazwischen faehrt eine Feder den Pfad ab.
  //
  // Fuer Text geht das nicht, und zwar grundsaetzlich: Typst setzt Glyphen
  // als gefuellte Umrisse ohne Kontur, `stroke-width` ist dort 0, und einen
  // gefuellten Umriss kann man nicht entlangfahren. Text bleibt darum bei der
  // Blende, und `draw` ist beides zugleich: die Striche zeichnen sich, alles
  // uebrige blendet auf, wie es das ohne `draw` auch taete.
  //
  // Genau daraus folgt, was unter "Bewegung reduzieren" geschieht -- naemlich
  // nichts Besonderes. Die Regel des Pakets lautet: Deckkraft bleibt, Weg
  // faellt weg. Das Zeichnen *ist* der Weg; nimmt man ihn heraus, bleibt die
  // Blende stehen, die ohnehin darunter lag. `feder()` haelt dann still, und
  // das Element blendet auf wie jedes andere.
  //
  // Alle Pfade fahren *zugleich* los, und daran gibt es nichts zu drehen. Die
  // Reihenfolge im SVG ist die Malreihenfolge von Typst und keine, die das
  // Deck gewaehlt haette -- sie waere dieselbe Anmassung, die `pairs()` beim
  // Zuordnen nach Nachbarschaft ablehnt. Wer eine Reihenfolge will, sagt sie:
  // `stagger(enter: "draw", stride: 1, achse, kurve, tangente)` gibt jedem
  // Stueck seinen Schritt. Nacheinander machte ausserdem `duration` zu einer
  // Zahl, die niemand mehr lesen kann: sieben Striche zu 900ms sind 6,3
  // Sekunden.

  // Wie viele Pfade der Vortrag abgefahren hat, seit er geladen wurde.
  // Gezaehlt, wo sie entstehen, und nicht spaeter am DOM abgelesen: dieselbe
  // Lehre wie bei `FLUG`. Ein laufender Zaehler kann nicht zum falschen
  // Zeitpunkt gefragt werden.
  var FEDER = 0;

  // Steht der Knoten in einer Werkstatt statt auf der Folie? Was in `defs`,
  // `symbol`, `clipPath`, `mask` oder `pattern` liegt, wird nicht gezeichnet,
  // sondern anderswo benutzt -- ein Glyphenumriss etwa, den ein `use` an
  // dreissig Stellen holt. Wer daran drehte, drehte an allen dreissig.
  //
  // Von Hand die Kette hinauf und nicht mit `closest`: ein Typwaehler trifft
  // im SVG-Namensraum nur bei genauer Gross- und Kleinschreibung, und
  // `clipPath` gegen `clippath` ist ein Fehler, den niemand sieht.
  function inWerkstatt(n, el) {
    for (var p = n.parentNode; p && p !== el; p = p.parentNode) {
      var t = p.tagName;
      if (t === "defs" || t === "symbol" || t === "clipPath"
          || t === "mask" || t === "pattern") return true;
    }
    return false;
  }

  // Die Pfade eines Elements, die sich abfahren lassen, mit ihrer Laenge.
  function abfahrbar(el) {
    var aus = [];
    el.querySelectorAll("path").forEach(function (n) {
      if (strichBreite(n) <= 0) return;      // gefuellter Umriss, keine Kontur
      if (inWerkstatt(n, el)) return;
      // Ein Pfad, der schon gestrichelt ist, traegt sein Muster in demselben
      // Attribut. Es zu ueberschreiben hiesse, die Strichelung fuer die Dauer
      // der Zeichnung zu tilgen -- eine gestrichelte Hilfslinie waere
      // waehrend ihres Auftritts durchgezogen. Also blendet sie lieber.
      var muster = n.getAttribute("stroke-dasharray");
      if (!muster) {
        try { muster = getComputedStyle(n).strokeDasharray; } catch (e) { muster = ""; }
      }
      if (muster && muster !== "none") return;
      var laenge = 0;
      try { laenge = n.getTotalLength(); } catch (e) { laenge = 0; }
      if (!(laenge > 0)) return;
      aus.push({ node: n, laenge: laenge });
    });
    return aus;
  }

  // Was `feder` an den Pfaden hinterlassen hat, wieder wegnehmen.
  //
  // Die Feder sitzt eine Ebene unter dem Element, `getAnimations()` fragt aber
  // nur das Element selbst. Ohne dies bliebe ein unterbrochener Strich auf
  // halber Strecke stehen -- bei einem Sprung auf einen Schritt etwa, der den
  // Auftritt gar nicht spielt.
  function federWeg(el) {
    if (!el.dataset.feder) return;
    delete el.dataset.feder;
    el.querySelectorAll("[data-ts-feder]").forEach(function (n) {
      n.getAnimations().forEach(function (a) { try { a.cancel(); } catch (e) {} });
      n.style.strokeDasharray = "";
      n.style.strokeDashoffset = "";
      n.removeAttribute("data-ts-feder");
    });
  }

  // Ein Element ohne einen einzigen abfahrbaren Pfad. Es blendet dann -- aber
  // nicht stillschweigend: wer `draw` schreibt, will eine Zeichnung sehen und
  // nicht eine Blende, die zufaellig gleich aussieht.
  //
  // Zur Uebersetzungszeit ist diese Meldung nicht zu haben. Typst gibt das SVG
  // erst beim Export heraus, und im Dokument gibt es keine Frage, die "hat
  // dieser Inhalt eine Kontur" beantwortete -- es ist derselbe blinde Fleck,
  // wegen dessen das Paket ueberhaupt mit Signalfarb-Rechtecken arbeitet.
  // Erst hier steht der Pfad da und laesst sich zaehlen.
  //
  // Einmal je Element und nicht einmal je Schritt: wer sechsmal durch das Deck
  // blaettert, braucht die Klage nicht sechsmal. Sie geht ueber `console.warn`
  // und landet damit in derselben Liste, die der Prueflauf ausliest.
  function federKlage(el) {
    if (el.dataset.federKlage) return;
    el.dataset.federKlage = "1";
    var f = el.closest(".ts-slide");
    var nr = f ? SLIDES.indexOf(f) + 1 : 0;
    console.warn("typstage: enter: \"draw\" on slide " + nr + " (element "
      + (el.dataset.n || "?") + ") finds no stroked path to trace. What is "
      + "drawn is an outline, and text has none: Typst sets glyphs as filled "
      + "shapes. The element fades in instead. draw is for a drawing, the "
      + "fade is for text.");
  }

  // Die Feder ansetzen. `zurueck` heisst, sie faehrt den Pfad wieder heraus --
  // der Rueckweg des Auftritts, den `goto` beim Zurueckblaettern spielt.
  function feder(el, dur, delay, zurueck, kurve) {
    var pfade = abfahrbar(el);
    if (!pfade.length) { federKlage(el); return; }
    // Unter "Bewegung reduzieren" bleibt es bei der Blende, die ohnehin
    // daneben laeuft. Geklagt wird trotzdem: die Meldung gilt dem Deck und
    // nicht dieser Maschine, und wer die Einstellung anhat, soll dieselbe
    // Auskunft bekommen wie alle anderen.
    if (wenigerBewegung()) return;
    FEDER += pfade.length;
    el.dataset.feder = "1";
    pfade.forEach(function (p) {
      // Ein Zipfel Zugabe: `getTotalLength` misst die Geometrie, ein runder
      // Abschluss steht darueber hinaus. Ohne ihn bliebe am fertigen Strich
      // ein Haerchen offen.
      var d = p.laenge + 1;
      p.node.setAttribute("data-ts-feder", "1");
      p.node.style.strokeDasharray = d + " " + d;
      p.node.style.strokeDashoffset = zurueck ? d : 0;
      var a = p.node.animate(
        [{ strokeDashoffset: zurueck ? 0 : d },
         { strokeDashoffset: zurueck ? d : 0 }],
        { duration: dur, delay: delay, easing: kurve, fill: "both" });
      // Am Ende steht der Pfad wieder da, wie Typst ihn geschrieben hat.
      // Sichtbar waere der Unterschied nicht -- ein Strich ueber die ganze
      // Laenge sieht aus wie kein Strichmuster --, aber die Vorschau der
      // Sprecheransicht klont diesen Knoten, und was sie klont, soll das
      // Original sein.
      a.onfinish = function () {
        p.node.style.strokeDasharray = "";
        p.node.style.strokeDashoffset = "";
        p.node.removeAttribute("data-ts-feder");
        try { a.cancel(); } catch (e) {}
      };
    });
  }

  // An animation with `fill: both` pins its end value even long after it is
  // done. Whoever sets the state anew has to clear it first, otherwise it
  // wins against the value that was set.
  function clearAnims(el) {
    el.getAnimations().forEach(function (a) { try { a.cancel(); } catch (e) {} });
    federWeg(el);
  }

  // Die Kurve, auf der ein Element sich bewegt.
  //
  // Aufgeloest ist sie schon: `easing:` laesst den Namen in Typst zu einer
  // fertigen `cubic-bezier` werden, damit die Tabelle nur an einer Stelle
  // steht und ein Name, den es nicht gibt, gar nicht erst hier ankommt. Steht
  // nichts da, gilt die Hauskurve, und das ist der Fall in jedem Deck, das
  // `easing:` nie hinschreibt.
  //
  // Gilt fuer alles, was das Element selbst tut -- Auftritt, Abgang, Dimmen.
  // Nicht fuer den Folienwechsel und nicht fuer den Flug eines Morphs: der
  // eine gehoert der Folie und nicht dem Element, der andere hat zwei Enden.
  function takt(el) { return (el && erbt(el, "easing")) || EASE; }

  // The effect, with its travel taken out when less motion is asked for.
  // Every entry of the table above names an opacity in both of its two
  // states, so stripping it down to that leaves a plain fade and never an
  // empty pair. What goes with the rest is `blur`'s blur: it does not move,
  // but it is decoration on top of the fade, and the fade already carries
  // everything the effect has to say.
  function effekt(name) {
    var f = EFFECT[name] || EFFECT["fade"];
    if (!wenigerBewegung()) return f;
    return [{ opacity: f[0].opacity }, { opacity: f[1].opacity }];
  }

  function fadeIn(el, name, dur, delay) {
    clearAnims(el);
    // "none" means no effect. Animating from 1 to 1 would not merely be
    // pointless: played backwards it would keep the element visible.
    //
    // "hold" laeuft hier mit, und zwar aus demselben Grund, aus dem es als
    // Abgang ein Warten ist: wer wartet, statt zu gehen, kommt auch, ohne zu
    // kommen. `goto` ruft es beim Zurueckblaettern fuer die Stufe, die
    // hereinkommt -- sie liegt vollstaendig unter der, die noch abtritt, und
    // waere waehrend ihres ganzen Auftritts ohnehin verdeckt.
    if (name === "none" || name === "hold") { el.style.opacity = "1"; return; }
    // Die Feder faehrt unter der Blende. Beides zugleich und beide gleich
    // lang: die Striche zeichnen sich, alles ohne Kontur blendet auf.
    if (name === "draw") feder(el, dur, delay, false, takt(el));
    var f = effekt(name);
    el.style.opacity = "";
    var a = el.animate([f[0], f[1]],
      { duration: dur, delay: delay, easing: takt(el), fill: "both" });
    a.onfinish = function () { el.style.opacity = "1"; a.cancel(); };
  }

  // How far down a dimmed element goes. Not a taste, a measurement. Dimming
  // composites the ink towards the ground, so the ground decides what it
  // costs, and the value is the smallest hundredth at which body text still
  // meets the 4.5 to 1 the package's contrast contract asks of it, on
  // all five bundled palettes, upright and inverted, on the paper and on a
  // card surface. The tightest of the twenty is `parchment` on its own paper:
  // 4.57 at 0.65 and 4.44 at 0.64. The most forgiving is `mono` inverted at
  // 8.60, because opacity costs far less on a dark ground than on a light
  // one. Between full and dimmed there remain 1.94 to 3.23 to 1, so the step
  // is plainly visible everywhere. The arithmetic is `contrast()` in
  // `src/palettes.typ`.
  //
  // It holds for text in the ink colour, which is what a point is set in.
  // Dimming something already quiet, a `muted` footer or an accent-coloured
  // word, drops under the contract; the manual says so.
  var DIM = 0.65;

  function fadeOut(el, name, dur, von) {
    clearAnims(el);
    if (name === "none") { el.style.opacity = "0"; return; }
    // Ein Warten dauert so lange wie der Eintritt, den es abwartet. `goto`
    // gibt einem Abgang drei Viertel der Dauer und dem, was hereinkommt, die
    // ganze; die abtretende Stufe ginge sonst, wenn die neue erst bei drei
    // Vierteln steht, und das Bild saenke fuer den Rest des Wegs doch noch
    // ab. Als *Abgang* wird "hold" rueckwaerts nie gefragt: dort spielt
    // `goto` den Eintritt rueckwaerts, und der heisst anders. Gefragt wird es
    // rueckwaerts als Eintritt, fuer die Stufe, die hereinkommt -- siehe
    // `fadeIn`.
    if (name === "hold") dur = dur / 0.75;
    // Rueckwaerts faehrt die Feder heraus. Das ist der Rueckweg des Auftritts
    // -- `goto` ruft beim Zurueckblaettern `fadeOut` mit dem *enter*-Namen --
    // und ebenso ein `exit: "draw"`, wenn ein Element seinen Bereich verlaesst.
    if (name === "draw") feder(el, dur, 0, true, takt(el));
    var f = effekt(name);
    var ab = f[1];
    // Leaving out of the dimmed state starts where the element stands. Taken
    // from the effect's full end value it would flash back to full strength
    // for one frame before it goes.
    if (von != null && von !== 1) {
      ab = {};
      for (var k in f[1]) ab[k] = f[1][k];
      ab.opacity = von;
    }
    var a = el.animate([ab, f[0]],
      { duration: dur, easing: takt(el), fill: "both" });
    a.onfinish = function () { el.style.opacity = "0"; try { a.cancel(); } catch (e) {} };
  }

  // Between two resting opacities, with no effect and no travel. Dimming is
  // not an entrance and not a departure: the point does not move, it only
  // steps back or comes forward again.
  function fadeTo(el, von, bis, dur) {
    clearAnims(el);
    var a = el.animate([{ opacity: von }, { opacity: bis }],
      { duration: dur, easing: takt(el), fill: "both" });
    a.onfinish = function () {
      el.style.opacity = String(bis); try { a.cancel(); } catch (e) {}
    };
  }

  // The three states a sprite rests in, on the element as well as in the
  // markup: 0 not drawn, 1 drawn muted, 2 drawn. `data-on` keeps meaning
  // "is on the slide", so whatever asks that question -- a morph looking for
  // its source, the pointer looking for a frame -- finds a dimmed element
  // too, because it is on the slide.
  function ruhe(el, z) {
    if (z === 0) {
      delete el.dataset.on; delete el.dataset.dim; el.style.opacity = "0";
    } else if (z === 1) {
      el.dataset.on = "1"; el.dataset.dim = "1";
      el.style.opacity = String(DIM);
    } else {
      el.dataset.on = "1"; delete el.dataset.dim; el.style.opacity = "1";
    }
  }

  // Which of the three a sprite is in on a given step.
  function eigenerZustand(el, schritt) {
    if (activeAt(el.dataset.at, schritt)) return 2;
    // The cheap question first. Almost every selector runs to the end of the
    // slide, and then there is nothing to look up.
    if (schritt > endeBei(el.dataset.at) && erbt(el, "after") === "dimmed") return 1;
    return 0;
  }

  function wirtVon(el) {
    if (!el.dataset.parent) return null;
    var folie = el.closest(".ts-slide");
    return folie
      ? folie.querySelector('.ts-el[data-n="' + el.dataset.parent + '"]') : null;
  }

  // Nothing is more visible than what it sits inside.
  //
  // A tracked element inside another keeps its own range -- `morph`, `video`,
  // `embed` and `flipbook` all default to `at: "1-"` -- and the sprites are
  // siblings in the DOM, so the host cannot hide it by covering it. Measured
  // on a `morph` inside an `anim(at: "2-")`: on step 1 the formula stood there
  // at full strength while its own bullet was still invisible.
  //
  // The host is known: `stelle` writes `data-parent` whenever a marker was
  // found inside another element's sprite. So the state is simply capped by
  // the host's, up the whole chain. An inner element may still be *less*
  // visible than its host -- that is what its own range is for.
  function zustand(el, schritt, tiefe) {
    var z = eigenerZustand(el, schritt);
    if (z === 0 || (tiefe || 0) > 8) return z;
    var wirt = wirtVon(el);
    if (!wirt) return z;
    return Math.min(z, zustand(wirt, schritt, (tiefe || 0) + 1));
  }

  // ── Magic move ────────────────────────────────────────────────────────────
  // Typst bakes the font size into the outline: the same glyph has different
  // path data at 20pt and at 34pt, and therefore different symbol ids. For
  // pairing, the outline is normalised to its largest coordinate: what
  // remains is the shape, and the size drops out.
  var sigCache = {};
  function signatur(id) {
    if (sigCache[id] != null) return sigCache[id];
    var sym = document.getElementById(id.replace(/^#/, ""));
    var d = "";
    if (sym) sym.querySelectorAll("path").forEach(function (p) {
      d += (p.getAttribute("d") || "") + "|";
    });
    var max = 0;
    (d.match(/-?\d+(\.\d+)?/g) || []).forEach(function (z) {
      max = Math.max(max, Math.abs(+z));
    });
    var sig = max ? d.replace(/-?\d+(\.\d+)?/g, function (z) {
      return Math.round(+z / max * 1000) / 1000;
    }) : d;
    sigCache[id] = sig;
    return sig;
  }

  // Pins sit as transparent rectangles behind their content, the same
  // construction as the element marks, only with #fd instead of #fe. The
  // number inside is computed from the name, so equal names give the same
  // number.
  function pinFelder(el) {
    var felder = [];
    el.querySelectorAll("path").forEach(function (p) {
      var f = (p.getAttribute("fill") || "").toLowerCase();
      if (f.length !== 9 || f.slice(0, 3) !== "#fd" || f.slice(7) !== "00") return;
      var r = p.getBoundingClientRect();
      if (!r.width && !r.height) return;
      felder.push({ id: parseInt(f.slice(3, 7), 16), r: r });
    });
    return felder;
  }

  // A glyph's box in screen coordinates.
  //
  // Not `getBoundingClientRect()`, even though that would be the obvious
  // route: on a `<use>`, Firefox returns for it not the glyph's box but the
  // whole SVG's. Measured on an equation with 23 characters, Chrome gave
  // 25x23, 16x24, 34x34, and Firefox gave 476x43 for *every* character. Since
  // the ghost gets its size from this box, every letter there was stretched
  // to the width of the formula. That is exactly what was reported as "all
  // the letters smeared sideways".
  //
  // `getBBox()`, by contrast, agrees between both engines (16x14, 10x15,
  // 21x21), and `getScreenCTM()` converts it into screen dimensions. All four
  // corners, because a matrix can also rotate and shear. In Chrome this comes
  // out to the same pixel value as before.
  function glyphKasten(u) {
    var b, m;
    try { b = u.getBBox(); m = u.getScreenCTM(); } catch (e) { return null; }
    if (!m || !b || (!b.width && !b.height)) return null;
    var xs = [], ys = [];
    for (var i = 0; i < 4; i++) {
      var x = b.x + (i & 1 ? b.width : 0), y = b.y + (i & 2 ? b.height : 0);
      xs.push(m.a * x + m.c * y + m.e);
      ys.push(m.b * x + m.d * y + m.f);
    }
    var l = Math.min.apply(null, xs), r = Math.max.apply(null, xs);
    var o = Math.min.apply(null, ys), un = Math.max.apply(null, ys);
    return { left: l, top: o, right: r, bottom: un, width: r - l, height: un - o };
  }

  function glyphs(el) {
    var out = [], felder = pinFelder(el);
    el.querySelectorAll("use").forEach(function (u) {
      var r = glyphKasten(u);
      if (!r || r.width <= 0 || r.height <= 0) return;
      var id = u.getAttribute("xlink:href") || u.getAttribute("href") || "";
      // The glyph belongs to the pin in whose field its center lies. With
      // nested pins the smallest one wins, otherwise a pin around the whole
      // term would swallow the names of the characters inside it.
      var mx = r.left + r.width / 2, my = r.top + r.height / 2;
      var pin = null, klein = Infinity;
      for (var i = 0; i < felder.length; i++) {
        var q = felder[i].r;
        if (mx < q.left || mx > q.right || my < q.top || my > q.bottom) continue;
        var a = q.width * q.height;
        if (a < klein) { klein = a; pin = felder[i].id; }
      }
      out.push({ id: id, sig: signatur(id), r: r, node: u, pin: pin });
    });
    return out;
  }

  // First in reading order by shape, then whatever is left goes to its
  // nearest counterpart, otherwise a glyph would be dropped merely because
  // it changed places.
  function pairs(a, b) {
    var frei = b.slice(), zug = [];
    // Pins first: equal names find each other before the shape is
    // consulted. A pin without a counterpart then falls back to the shape
    // match.
    var fest = [];
    a.forEach(function (g) {
      if (g.pin === null || g.pin === undefined) return;
      for (var i = 0; i < frei.length; i++) {
        if (frei[i].pin === g.pin) {
          fest.push([g, frei[i]]);
          frei.splice(i, 1);
          return;
        }
      }
    });
    function gepinnt(g) {
      for (var i = 0; i < fest.length; i++) if (fest[i][0] === g) return fest[i][1];
      return null;
    }
    a.forEach(function (g) {
      var p = gepinnt(g);
      if (p) { zug.push([g, p]); return; }
      var t = -1;
      for (var i = 0; i < frei.length; i++) if (frei[i].sig === g.sig) { t = i; break; }
      if (t < 0) { zug.push([g, null]); return; }
      zug.push([g, frei[t]]);
      frei.splice(t, 1);
    });
    // No fallback to the nearest free character. Whoever finds no matching
    // shape fades out at its own place, and the new one fades in at its own.
    // A colon that stretches into a letter is not a flight but a smear, and
    // which character happens to sit closest spatially says nothing about
    // whether the two have anything to do with each other.
    //
    // Anyone who wants to relate two characters whose shape differs gives
    // them the same name with `pin`. That is explicit and traceable;
    // proximity is not.

    // A pin is allowed to land on the target twice: then the character
    // visibly splits into two. That is exactly what the power rule needs;
    // the exponent appears up front as a factor and at the same time stays
    // up top. So the search also covers sources that have already been
    // assigned.
    for (var i = frei.length - 1; i >= 0; i--) {
      var z = frei[i];
      if (z.pin === null || z.pin === undefined) continue;
      for (var k = 0; k < fest.length; k++) {
        if (fest[k][0].pin === z.pin) {
          zug.push([fest[k][0], z]);
          frei.splice(i, 1);
          break;
        }
      }
    }
    // `rest` are target glyphs without a source, those have to fade in.
    return { zug: zug, rest: frei };
  }

  // Lift a glyph out as its own SVG. Both the clip and the clone matrix must
  // be expressed in the source SVG's user coordinate system; getCTM() maps to
  // the viewport instead and would apply the viewBox factor a second time.
  function inBenutzer(node, svg) {
    return svg.getScreenCTM().inverse().multiply(node.getScreenCTM());
  }

  // The stroke width, provided the node strokes at all. Glyph outlines only
  // have a fill and yield 0, which is how they can be told apart.
  function strichBreite(node) {
    var st = node.getAttribute("stroke");
    if (!st || st === "none") return 0;
    return parseFloat(node.getAttribute("stroke-width")
                      || getComputedStyle(node).strokeWidth) || 0;
  }

  function kastenInBenutzer(node, svg, m) {
    var b = node.getBBox(), p = svg.createSVGPoint(), xs = [], ys = [];
    // `getBBox` measures the geometry without the stroke. A horizontal
    // radical bar is thus zero tall, and its ghost double would stay
    // invisible.
    var sw = strichBreite(node);
    if (sw > 0) {
      b = { x: b.x - sw / 2, y: b.y - sw / 2,
            width: b.width + sw, height: b.height + sw };
    }
    [[b.x, b.y], [b.x + b.width, b.y],
     [b.x, b.y + b.height], [b.x + b.width, b.y + b.height]].forEach(function (c) {
      p.x = c[0]; p.y = c[1];
      var q = p.matrixTransform(m);
      xs.push(q.x); ys.push(q.y);
    });
    var x0 = Math.min.apply(null, xs), x1 = Math.max.apply(null, xs);
    var y0 = Math.min.apply(null, ys), y1 = Math.max.apply(null, ys);
    return { x: x0, y: y0, w: x1 - x0, h: y1 - y0 };
  }

  // What is drawn and not set: radical arcs, fraction bars, equals bars,
  // frames. `glyphs()` only collects `<use>`, so not these parts, and
  // because `[data-hold]` hides the whole element, they used to vanish
  // during the flight and appear abruptly only at the end.
  function striche(el) {
    var out = [];
    el.querySelectorAll("path").forEach(function (n) {
      var sw = strichBreite(n);
      if (sw <= 0) return;              // glyph outline, not a drawn stroke
      // Measured the way the glyphs are, not with `getBoundingClientRect`.
      // Firefox counts the stroke into that box, and more generously than by
      // half its width: on the same fraction bar it reports 18.9 by 5.2 where
      // the geometry is 13.7 by 0, and Chrome reports 13.7 by 0 as well.
      // Because half a stroke width is added on each side right afterwards,
      // the ghost came out twice as tall, and `preserveAspectRatio="none"`
      // stretched the line onto it. Reported from the forum as fraction bars
      // that briefly thicken during a flight, though not in Chrome.
      var r = glyphKasten(n);
      if (!r || (r.width <= 0 && r.height <= 0)) return;
      // Widen on screen too by half the stroke width, otherwise the ghost
      // double's box would be zero in one direction.
      var c = n.getScreenCTM();
      var px = sw * (c ? Math.hypot(c.a, c.c) : 1) / 2;
      var py = sw * (c ? Math.hypot(c.b, c.d) : 1) / 2;
      out.push({ node: n, r: { left: r.left - px, top: r.top - py,
                               width: r.width + 2 * px, height: r.height + 2 * py } });
    });
    return out;
  }

  // Eine Kopie bekommt eigene Bezeichner.
  //
  // Ein Sprite traegt einen Beschnitt: `<g clip-path="url(#c…-ts40)">`, und die
  // Form dazu steht in seinem eigenen `<defs>`. Eine Kopie bringt beides
  // wortgleich mit -- und `url(#…)` loest auf das *erste* Vorkommen im
  // Dokument auf, also auf das Original. Dessen Beschnitt steht im
  // Koordinatensystem des Originals, und im Geist schnitt er alles weg.
  //
  // Gemessen am Bildflug des Greyscale-Decks: der Geist stand an der richtigen
  // Stelle, in der richtigen Groesse, mit Deckkraft 1 und einem `<image>` mit
  // gueltigem Kasten -- und malte nichts. Ein Bildvergleich mit und ohne
  // Flugebene war zeichengleich. Nahm man den Beschnitt heraus, erschien das
  // Bild. Betroffen ist jeder `match: "block"`, denn nur dort wird das ganze
  // Sprite geklont; die Glyphenkopien bauen sich ein eigenes SVG.
  var geistNr = 0;
  function eigeneIds(wurzel) {
    var karte = {};
    wurzel.querySelectorAll("[id]").forEach(function (e) {
      var alt = e.id;
      var neu = alt + "-tsg" + (++geistNr);
      karte[alt] = neu;
      e.id = neu;
    });
    var namen = Object.keys(karte);
    if (!namen.length) return;
    var felder = ["clip-path", "mask", "filter", "fill", "stroke",
                  "marker-start", "marker-mid", "marker-end"];
    wurzel.querySelectorAll("*").forEach(function (e) {
      felder.forEach(function (f) {
        var v = e.getAttribute(f);
        if (!v || v.indexOf("url(#") < 0) return;
        namen.forEach(function (alt) {
          v = v.split("url(#" + alt + ")").join("url(#" + karte[alt] + ")");
        });
        e.setAttribute(f, v);
      });
      // `use` zeigt ohne `url()` auf seine Vorlage.
      ["href", "xlink:href"].forEach(function (f) {
        var v = e.getAttribute(f);
        if (!v || v.charAt(0) !== "#") return;
        var ziel = karte[v.slice(1)];
        if (ziel) e.setAttribute(f, "#" + ziel);
      });
    });
  }

  function glyphGeist(g, stage, box) {
    var k = box || g.r;
    var w = g.node.ownerSVGElement;
    var m = inBenutzer(g.node, w);
    var vb = kastenInBenutzer(g.node, w, m);
    var d = document.createElement("div");
    d.className = "ts-ghost";
    var s = document.createElementNS(NS, "svg");
    s.setAttribute("preserveAspectRatio", "none");
    s.setAttribute("viewBox", vb.x + " " + vb.y + " " + vb.w + " " + vb.h);
    var box = document.createElementNS(NS, "g");
    box.setAttribute("transform",
      "matrix(" + m.a + "," + m.b + "," + m.c + "," + m.d + "," + m.e + "," + m.f + ")");
    var klon = g.node.cloneNode(true);
    klon.removeAttribute("transform");
    box.appendChild(klon);
    s.appendChild(box);
    d.appendChild(s);
    d.style.left = (k.left - stage.left) + "px";
    d.style.top = (k.top - stage.top) + "px";
    d.style.width = k.width + "px";
    d.style.height = k.height + "px";
    return d;
  }

  var CHROME = [].slice.call(document.querySelectorAll("#ts-chrome > .ts-chrome"));

  // ── Die Fortschrittsleiste ───────────────────────────────────────────────
  //
  // Sie liegt nicht mehr im Chrome-Bild der Folie, sondern ist ein Element für
  // das ganze Deck. Der Grund steht im CSS: zwei fertige Bilder können nur
  // überblenden, ein Element kann wachsen -- und wachsen ist, was eine
  // Fortschrittsleiste sagen soll.
  //
  // Der Anteil steht am Chrome der Folie (`data-anteil`) -- auch auf Titel-
  // und Abschnittsfolien, wo er den Stand *bis dorthin* trägt. Ohne fehlt
  // beim Zurückgehen der Weg: die Leiste zeigte dann noch den Stand der Folie,
  // die man gerade verlassen hat.
  var FORTSCHRITT = document.getElementById("ts-fortschritt");
  var FORTSCHRITT_STAND = 0;
  function fortschrittStellen(i, sofort) {
    if (!FORTSCHRITT) return;
    var c = CHROME[i];
    if (!c) return;
    // Eine Folie ohne Chrome ist eine Titel- oder Abschnittsfolie. Dort
    // zeichnet das Theme nichts an den Rand, und die Leiste hat dort ebenso
    // wenig zu suchen -- gemeldet aus einem echten Deck: sie stand plötzlich
    // unter einer Abschnittsfolie, wo nie eine war. Sie geht also mit dem
    // Chrome mit; ihr *Stand* wird trotzdem nachgeführt, damit sie beim
    // Wiederauftauchen richtig steht.
    var traegt = c.children.length > 0;
    FORTSCHRITT.style.opacity = traegt ? "1" : "0";
    var a = c.dataset.anteil;
    if (a == null || a === "") return;
    var anteil = Math.max(0, Math.min(1, parseFloat(a)));
    if (anteil === FORTSCHRITT_STAND) return;
    FORTSCHRITT_STAND = anteil;
    // Unsichtbar wird nicht gefahren: was niemand sieht, braucht keine Zeit,
    // und die Fahrt gehörte sonst der Folie danach.
    if (sofort || !traegt) {
      // Ein Sprung ist keine Fahrt. Wer über die Übersicht oder die Adresse
      // springt, soll den Stand sehen und nicht eine Leiste, die hinterherläuft.
      var alt = FORTSCHRITT.style.transition;
      FORTSCHRITT.style.transition = "none";
      FORTSCHRITT.style.transform = "scaleX(" + anteil + ")";
      // Erzwungenes Neuberechnen, sonst fasst der Browser beide Schreibvorgänge
      // zusammen und die Fahrt findet doch statt.
      void FORTSCHRITT.offsetWidth;
      FORTSCHRITT.style.transition = alt;
    } else {
      FORTSCHRITT.style.transform = "scaleX(" + anteil + ")";
    }
  }

  var flyTimers = [];
  // Elemente, die im Ruhezustand ueber dem Ziel eines Fluges stehen. Der Geist
  // liegt auf `#ts-fly`, sie liegen in der Folie -- zwei getrennte
  // Stapelkontexte, zwischen die kein z-index passt. Fuer die Dauer des Fluges
  // ziehen sie deshalb mit auf die Flugebene, hinter die Geister, und danach
  // an ihren Platz zurueck. `.ts-ov` und `#ts-fly` sind beide `inset:0` auf der
  // Buehne, die Koordinaten stimmen also weiter, und eine Web-Animation
  // ueberlebt das Umhaengen.
  var HOCH = [];          // was gerade oben haengt, mit dem Weg zurueck
  var HOCH_LAUF = 0;      // welcher Flug es hochgezogen hat
  var NACHZUEGLER = [];   // was der letzte Flug zum Hochziehen vorgemerkt hat
  var NACHZUEGLER_DAUER = 0;

  function nachzueglerZurueck() {
    for (var i = HOCH.length - 1; i >= 0; i--) {
      var h = HOCH[i];
      if (h.next && h.next.parentNode === h.parent) h.parent.insertBefore(h.el, h.next);
      else h.parent.appendChild(h.el);
    }
    HOCH = [];
  }

  // Erst *nach* den Sprites von `goto` gerufen: die Schleife dort sucht ihre
  // Elemente unter `SLIDES[i]`, und was schon oben haengt, faende sie nicht
  // mehr -- der Nachzuegler bliebe den ganzen Flug lang auf seinem alten Stand.
  function nachzueglerHoch() {
    if (!NACHZUEGLER.length) return;
    // Ort und Mass bleiben von selbst richtig: `setzen()` schreibt beides in
    // Prozent, und `#ts-fly` und `.ts-ov` sind dieselbe Flaeche. Ein Fenster,
    // das sich mitten im Flug aendert, traegt den Hochgezogenen also mit --
    // `stelle()` muss ihn dafuer nicht suchen. Einzig die Rundung stuende
    // still, denn die rechnet in Punkten; sie gibt es nur an `video()`, und
    // ein Video als Nachbar eines `morph` ist bis jetzt nirgends geprueft.
    //
    // Die Bewegungen der Geister -- vor dem Anhaengen gelesen, damit die
    // Nachzuegler nicht mit ihren eigenen darin stehen.
    var fluege = FLY.getAnimations ? FLY.getAnimations({ subtree: true }) : [];
    NACHZUEGLER.forEach(function (el) {
      if (!el.parentNode) return;
      HOCH.push({ el: el, parent: el.parentNode, next: el.nextSibling });
      FLY.appendChild(el);
    });
    NACHZUEGLER = [];

    // Zurueck, sobald der Flug wirklich zu Ende ist, und nicht erst, wenn ein
    // Zeitgeber es fuer wahrscheinlich haelt: `finished` faellt als Microtask
    // an, noch in dem Bild, in dem die letzte Bewegung steht. Ein Zeitgeber
    // mit derselben Frist kann danach kommen -- gemessen im Decklauf, der
    // nach jedem Schritt wartet, bis nichts mehr laeuft, und dann eine Folie
    // vorfand, unter der ein Sprite fehlte (`sichtbar` 3/0·1/0 statt 3/0·2/0).
    // Der Zeitgeber bleibt als Rueckfall stehen: wo gar nichts animiert wurde,
    // faellt auch kein `finished` an.
    var lauf = ++HOCH_LAUF;
    if (fluege.length) {
      Promise.all(fluege.map(function (a) {
        return a.finished.catch(function () {});
      })).then(function () {
        if (lauf === HOCH_LAUF) nachzueglerZurueck();
      });
    }
    flyTimers.push(setTimeout(function () {
      if (lauf === HOCH_LAUF) nachzueglerZurueck();
    }, NACHZUEGLER_DAUER));
  }
  // How many ghosts a talk has produced since it was loaded. Counted where
  // they are made, not read off `#ts-fly` afterwards: the layer is emptied
  // again by a timer, so whoever counts it later counts whatever the machine
  // happened to have cleaned up by then. A running total cannot be asked at
  // the wrong moment.
  var FLUG = 0;

  //
  function finishTransitionNow() {
    SLIDES.forEach(function (f) {
      if (f.mo_zeit) { clearTimeout(f.mo_zeit); f.mo_zeit = null; }
      if (f.mo_aus) { try { f.mo_aus.cancel(); } catch (e) {} f.mo_aus = null; }
      f.getAnimations().forEach(function (a) { try { a.cancel(); } catch (e) {} });
      delete f.dataset.off;
      resetStyle(f);
    });
    B.style.perspective = "";
  }

  // Die zwei Wege in einen Flug. Beide sammeln nur ein, was fliegen soll, und
  // reichen es an `fly` weiter -- was dort geschieht, ist in beiden Faellen
  // dasselbe.

  // Von Folie zu Folie: Quelle ist, was gerade steht, Ziel ist jedes `morph`
  // der Zielfolie. Welches davon dort sichtbar wird, entscheidet `stelle`
  // gleich danach; ein Ziel ohne Partner faellt in `fly` von selbst heraus.
  function flugFolie(vonFolie, nachFolie, fallback) {
    var quellen = {};
    SLIDES[vonFolie].querySelectorAll(".ts-morph").forEach(function (e) {
      if (e.dataset.on === "1") quellen[e.dataset.name] = e;
    });
    return fly(quellen, SLIDES[nachFolie].querySelectorAll(".ts-morph"),
               SLIDES[nachFolie], fallback);
  }

  // Innerhalb einer Folie, von Schritt zu Schritt. Hier steht die Zielfolie
  // schon da, `dataset.on` sagt also nur, was *jetzt* sichtbar ist -- gefragt
  // ist, was auf dem naechsten Schritt sichtbar sein wird. Dafuer gibt es
  // `zustand`, dieselbe Auskunft, die `stelle` selbst benutzt.
  //
  // Ohne das hier morphte ein Deck nur ueber Folienraender hinweg. Zwei
  // Fassungen derselben Formel auf zwei Schritten einer Folie -- der
  // haeufigste Fall ueberhaupt, und genau das, wofuer `alternatives` da ist --
  // wechselten hart. Nachgemessen: null Geister auf `#ts-fly` beim
  // Schrittwechsel, sechs beim Folienwechsel.
  function flugSchritt(folie, vonSchritt, nachSchritt, fallback) {
    var f = SLIDES[folie];
    var quellen = {}, ziele = [], bleiber = [];
    f.querySelectorAll(".ts-morph").forEach(function (e) {
      if (zustand(e, vonSchritt) > 0) {
        quellen[e.dataset.name] = e;
        // Eine Quelle, die auf dem *erreichten* Schritt ebenfalls steht, geht
        // nirgendwohin -- sie bleibt liegen, und aus ihr wächst das neue
        // Stück heraus. Das ist die Form, die `stagger(morph: true)` baut:
        // jede Zeile bleibt, die nächste fliegt aus ihr hervor. Wer sie
        // trotzdem für die Dauer des Fluges versteckt, lässt sie vor den Augen
        // des Saales verschwinden und plötzlich wieder erscheinen.
        if (zustand(e, nachSchritt) > 0) bleiber.push(e);
      }
    });
    // Ziel ist, was *neu* dazukommt, und nicht alles, was nachher dasteht.
    // Sonst bekommt in einer Kette, in der jede Zeile stehen bleibt, auch die
    // erste Zeile einen Flug zugeteilt -- gemeldet aus einem echten Deck: beim
    // zweiten Schritt morphte die zweite Zeile zugleich nach oben in die erste
    // und nach unten in die dritte. Beim Folienwechsel fällt der Unterschied
    // nicht auf, weil dort nichts von der Quellfolie stehen bleibt.
    //
    // Rückwärts heißt das: was verschwindet, fliegt nicht zurück, es geht.
    // `alternatives` fliegt auch rückwärts, denn dort kommt die vorige Fassung
    // wieder neu dazu; eine Kette, in der alles stehen bleibt, hat rückwärts
    // kein neues Stück und damit kein Ziel.
    f.querySelectorAll(".ts-morph").forEach(function (e) {
      if (zustand(e, nachSchritt) > 0 && !(zustand(e, vonSchritt) > 0)) {
        ziele.push(e);
      }
    });
    return fly(quellen, ziele, f, fallback, bleiber);
  }

  // `bleiber` sind Quellen, die auch nach dem Flug noch stehen. Beim
  // Folienwechsel gibt es die nicht -- die Quellfolie geht ja fort --, deshalb
  // ist die Liste dort leer.
  function fly(quellen, ziele, umfeld, fallback, bleiber) {
    bleiber = bleiber || [];
    // Magic move is travel and nothing but travel: the point of it is that
    // the eye follows a shape from where it stood to where it now stands.
    // Asked for less motion there is nothing left of it worth keeping, so
    // the slide change falls back to the ordinary transition. `false` says
    // "no morph happened", the same answer a slide pair without a matching
    // name gives, and it is the same route a jump already takes.
    NACHZUEGLER = [];
    NACHZUEGLER_DAUER = 0;
    if (wenigerBewegung()) return false;
    flyTimers.forEach(function (t) { clearTimeout(t); });
    flyTimers = [];
    finishTransitionNow();
    while (FLY.firstChild) FLY.removeChild(FLY.firstChild);
    document.querySelectorAll(".ts-el[data-hold]").forEach(function (e) {
      delete e.dataset.hold;
    });
    var stage = B.getBoundingClientRect();
    var any = false;

    ziele.forEach(function (dst) {
      var src = quellen[dst.dataset.name];
      // Dasselbe Element auf beiden Seiten heisst: es steht auf beiden
      // Schritten und geht nirgendwohin. Beim Folienwechsel kann das nicht
      // vorkommen, innerhalb einer Folie sehr wohl -- ein `morph` mit
      // `at: "1-"` waere sonst seine eigene Quelle und sein eigenes Ziel.
      if (!src || src === dst) return;
      any = true;
      var d = +dst.dataset.fly || +src.dataset.fly || fallback;
      var qr = src.getBoundingClientRect(), zr = dst.getBoundingClientRect();
      // From both sides, like the flight duration a line above already:
      // going backward, source and target swap roles, and reading `match`
      // only on the target would then find the default there. In
      // theme-editorial the long line carries `match: "glyph"`; going
      // backward it is the source, and the flight turned into a block push.
      //
      // `"auto"` counts here as "not chosen" and not as an answer. The value
      // sits as the default on *every* morph, so a mere `||` would never get
      // through to the source. An explicit choice on either side applies to
      // the flight between them, in both directions.
      var wie = dst.dataset.match;
      if (!wie || wie === "auto") wie = src.dataset.match || "auto";
      var qg = glyphs(src), zg = glyphs(dst);
      var perGlyph = wie !== "block" && qg.length > 0 && zg.length > 0 &&
        (wie === "glyph" || (qg.length <= 48 && zg.length <= 48));

      // Die Quelle wird für die Dauer des Fluges verborgen -- der Geist
      // übernimmt ihre Stelle. Eine Quelle, die stehen bleibt, nicht: dort
      // liegt der Geist im ersten Bild genau auf ihr, und was sich löst, ist
      // die Kopie.
      if (bleiber.indexOf(src) < 0) src.dataset.hold = "1";
      dst.dataset.hold = "1";

      // Die Bahn ist das Rechteck, das der Geist ueberstreicht: von der Quelle
      // zum Ziel. Vorgemerkt wird nur, was in Quellreihenfolge *nach* dem
      // `morph` steht -- also im Ruhezustand ohnehin darueber liegt -- und was
      // diese Bahn beruehrt. Alles andere hat der Flug nie verdeckt.
      var bahn = {
        left: Math.min(qr.left, zr.left), top: Math.min(qr.top, zr.top),
        right: Math.max(qr.right, zr.right), bottom: Math.max(qr.bottom, zr.bottom)
      };
      var danach = false;
      umfeld.querySelectorAll(".ts-el").forEach(function (el) {
        if (el === dst) { danach = true; return; }
        if (!danach || el.dataset.hold === "1") return;
        if (NACHZUEGLER.indexOf(el) >= 0) return;
        var r = el.getBoundingClientRect();
        if (r.right <= bahn.left || r.left >= bahn.right ||
            r.bottom <= bahn.top || r.top >= bahn.bottom) return;
        NACHZUEGLER.push(el);
      });
      if (d > NACHZUEGLER_DAUER) NACHZUEGLER_DAUER = d;

      var ghosts = [];
      var ueber = 0.42;
      var window = { duration: d * ueber, delay: d * (0.5 - ueber / 2),
                      easing: "linear", fill: "both" };

      var attach = function (node) {
        FLY.appendChild(node); ghosts.push(node); FLUG++;
      };

      if (perGlyph) {
        var p = pairs(qg, zg);
        p.zug.forEach(function (paar) {
          var g = paar[0], z = paar[1];
          if (!z) {
            var allein = glyphGeist(g, stage);
            attach(allein);
            allein.animate([{ opacity: 1 }, { opacity: 0 }],
              { duration: d * 0.55, easing: "ease-out", fill: "forwards" });
            return;
          }

          var zx = z.r.left - g.r.left, zy = z.r.top - g.r.top;
          var sx = z.r.width / g.r.width, sy = z.r.height / g.r.height;
          var path = [
            { transform: "translate(0,0) scale(1,1)" },
            { transform: "translate(" + zx + "px," + zy + "px) scale(" + sx + "," + sy + ")" }
          ];
          var timing = { duration: d, easing: EASE, fill: "forwards" };

          //
          var ank = glyphGeist(z, stage, g.r);
          attach(ank);
          ank.animate(path, timing);

          var ghost = glyphGeist(g, stage);
          attach(ghost);
          ghost.animate(path, timing);
          ghost.animate([{ opacity: 1 }, { opacity: 0 }], window);
        });
        p.rest.forEach(function (z) {
          var a = glyphGeist(z, stage);
          a.style.opacity = "0";
          attach(a);
          a.animate([{ opacity: 0 }, { opacity: 1 }],
            { duration: d * 0.5, delay: d * 0.5, easing: "ease-out", fill: "both" });
        });
        // Strokes take the same path as a character without a partner: the
        // old one fades out, the new one fades in. They are not paired, a
        // radical arc and an equals bar have nothing to do with each other.
        striche(src).forEach(function (n) {
          var a = glyphGeist(n, stage);
          attach(a);
          a.animate([{ opacity: 1 }, { opacity: 0 }],
            { duration: d * 0.55, easing: "ease-out", fill: "forwards" });
        });
        striche(dst).forEach(function (n) {
          var a = glyphGeist(n, stage);
          a.style.opacity = "0";
          attach(a);
          a.animate([{ opacity: 0 }, { opacity: 1 }],
            { duration: d * 0.5, delay: d * 0.5, easing: "ease-out", fill: "both" });
        });
      } else {
        var takt2 = { duration: d, easing: EASE, fill: "forwards" };
        // Each copy sits in *its own* box and is moved from there.
        //
        // Previously both sat in the source's box. For the source that is
        // correct, for the target it is not. The rule `.ts-ghost svg` forces
        // the SVG to the full width and height of the copy, so the target
        // was fitted into a foreign aspect ratio; and because an SVG keeps
        // its own ratio while doing so, air remained on two edges. The
        // anisotropic scaling afterward did not undo that. At the end of the
        // flight the drawing therefore stood in different proportions than
        // the real element that took its place a tenth of a second later.
        //
        // Measured in the editorial deck, frame by frame: from 760ms to
        // 840ms nothing moved anymore, the flight had settled. At 920ms then
        // 824 pixels jumped, 302 going backward. That is exactly the jerk
        // you see.
        //
        // Now the target sits in its own box from the start and begins
        // squeezed down onto the source's. It ends at scale(1,1) and is
        // thus pixel for pixel what stands there afterward: both directions
        // 0 instead of 824 and 302.
        var kopie = function (was, kasten) {
          var k = was.cloneNode(true);
          eigeneIds(k);
          k.className = "ts-ghost";
          k.removeAttribute("data-n");
          k.removeAttribute("data-at");
          k.removeAttribute("data-hold");
          k.style.left = (kasten.left - stage.left) + "px";
          k.style.top = (kasten.top - stage.top) + "px";
          k.style.width = kasten.width + "px";
          k.style.height = kasten.height + "px";
          return k;
        };
        // The ghosts' transform origin sits at top left (see CSS), so the
        // path is simply composed of translation and scaling.
        var hin = function (von, nach) {
          return "translate(" + (nach.left - von.left) + "px," +
                 (nach.top - von.top) + "px) scale(" +
                 (nach.width / von.width) + "," + (nach.height / von.height) + ")";
        };
        var ank2 = kopie(dst, zr);
        ank2.style.opacity = "1";
        attach(ank2);
        ank2.animate([{ transform: hin(zr, qr) },
                      { transform: "translate(0,0) scale(1,1)" }], takt2);

        var ghost = kopie(src, qr);
        ghost.style.opacity = "1";
        attach(ghost);
        ghost.animate([{ transform: "translate(0,0) scale(1,1)" },
                       { transform: hin(qr, zr) }], takt2);
        ghost.animate([{ opacity: 1 }, { opacity: 0 }], window);
      }

      flyTimers.push(setTimeout(function () {
        delete src.dataset.hold;
        delete dst.dataset.hold;
        ghosts.forEach(function (g) { g.remove(); });
      }, d));
    });
    return any;
  }

  // ── Media ─────────────────────────────────────────────────────────────────
  var ticking = [];
  function mediaOn(i) {
    SLIDES[i].querySelectorAll(".ts-video").forEach(function (w) {
      var v = w.querySelector("video");
      if (!v || w.dataset.autoplay === "0") return;
      if (v.paused) { var p = v.play(); if (p && p.catch) p.catch(function () {}); }
    });
    // Aufgenommen, aber noch nicht gestartet: `t0` bleibt leer, bis das
    // Daumenkino wirklich zu sehen ist. Wer es hier stempelte, ließe die Uhr
    // beim *Folieneintritt* loslaufen, und ein `flipbook(at: "3-")` wäre
    // abgelaufen, bevor es aufgedeckt wird -- gemessen: Bild 23 von 24 im
    // Augenblick des Aufdeckens.
    SLIDES[i].querySelectorAll(".ts-flipbook").forEach(function (fb) {
      for (var k = 0; k < ticking.length; k++) if (ticking[k].el === fb) return;
      ticking.push({ el: fb, t0: null, letztes: -1 });
    });
  }
  function mediaOff(i) {
    SLIDES[i].querySelectorAll("video").forEach(function (v) { v.pause(); });
    ticking = ticking.filter(function (t) { return !SLIDES[i].contains(t.el); });
    // Ein Zug, den niemand mehr sieht, laeuft nicht weiter. Wo die Szene beim
    // Abbruch stehenbleibt, ist gleich: der Rueckweg auf diese Folie ist ein
    // Folienwechsel und stellt sie ohnehin.
    SLIDES[i].querySelectorAll(".ts-scene").forEach(szeneAus);
  }

  // ── Szene ─────────────────────────────────────────────────────────────────
  //
  // Dieselben Bilder wie beim Daumenkino, derselbe Stapel im Markup -- nur
  // schaltet hier nicht die Uhr weiter, sondern der Tastendruck. Das Deck hat
  // Typst eine Reihe von Bildern setzen lassen, in der Halt k auf Bild
  // k * (tween + 1) liegt; ein Schritt zieht den Bildzeiger von einem Halt zum
  // naechsten und faehrt dabei dieselbe Kurve wie ein `anim` daneben.
  //
  // Warum der Takt eine echte Web-Animation ist und an `document.body` haengt,
  // steht bei `szeneZiehen`.
  var ZUEGE = [];

  // Welcher Halt auf einem Schritt gilt, und welches Bild dazu gehoert.
  function szeneHalt(el, schritt) {
    var halte = +el.dataset.stops || 1, ab = +el.dataset.from || 1;
    return Math.max(0, Math.min(halte - 1, schritt - ab));
  }
  function szeneRahmen(el, schritt) {
    return szeneHalt(el, schritt) * ((+el.dataset.tween || 0) + 1);
  }

  function szeneBild(el, i) {
    var k = el.querySelectorAll(".ts-frame");
    if (!k.length) return;
    i = Math.max(0, Math.min(k.length - 1, i));
    if (el.tsBild === i) return;
    el.tsBild = i;
    for (var j = 0; j < k.length; j++) {
      if (j === i) k[j].dataset.on = "1"; else delete k[j].dataset.on;
    }
  }

  function szeneAus(el) {
    if (!el.tsZug) return;
    try { el.tsZug.cancel(); } catch (e) {}
    el.tsZug = null;
  }

  // Die Szene an den Halt ziehen, der auf diesem Schritt gilt.
  //
  // `sofort` heisst stellen statt ziehen: beim Betreten einer Folie und bei
  // einem Sprung in den Vortrag hinein gibt es keinen Weg, den jemand gesehen
  // haette, und die Szene hat am Ziel zu stehen. Dasselbe gilt unter
  // "Bewegung reduzieren" -- was dort wegfaellt, ist genau der Weg, und die
  // Halte selbst sind kein Weg, sondern der Inhalt.
  function szeneZiehen(el, schritt, sofort) {
    var bis = szeneRahmen(el, schritt);
    var von = el.tsBild == null ? bis : el.tsBild;
    szeneAus(el);
    if (sofort || wenigerBewegung() || von === bis) { szeneBild(el, bis); return; }
    var d = +el.dataset.pull || CFG.duration;
    // Der Takt ist eine gewoehnliche Web-Animation ohne eine einzige
    // Eigenschaft darin, und sie haengt am Rumpf des Dokuments. Beides mit
    // Grund. Am Sprite selbst risse `clearAnims` sie beim naechsten Auftritt
    // mit weg. Und ein eigener Zeitgeber -- ein Zaehler in `beat` etwa -- waere
    // fuer `pruef.ruhig()` unsichtbar: ein Prueflauf maesse dann mitten im Zug
    // und haette zwei Laeufe, die sich nie einig sind. So wartet er auf den
    // Zug wie auf jede andere Bewegung, und `--tempo` greift ohne Zutun.
    var a = document.body.animate([{ offset: 0 }, { offset: 1 }],
                                  { duration: d, easing: "linear" });
    el.tsZug = a;
    ZUEGE.push({ el: el, a: a, von: von, bis: bis,
                 d: a.effect.getTiming().duration || d });
  }

  // Die laufenden Zuege, ein Bild weiter. Steht im Takt des Daumenkinos, weil
  // beide dasselbe tun: aus einer Zeit ein Bild machen.
  function szenenTakt() {
    for (var z = ZUEGE.length - 1; z >= 0; z--) {
      var g = ZUEGE[z];
      if (g.el.tsZug !== g.a) { ZUEGE.splice(z, 1); continue; }
      var lz = g.a.currentTime;
      var u = (lz == null || !(g.d > 0)) ? 1 : Math.min(1, lz / g.d);
      szeneBild(g.el, Math.round(g.von + (g.bis - g.von) * kurve(u)));
      if (u >= 1) { g.el.tsZug = null; ZUEGE.splice(z, 1); }
    }
  }

  // Vor dem ersten `goto`: jede Szene steht auf ihrem ersten Halt. Ohne das
  // traegt keines ihrer Bilder `data-on`, und eine Szene auf einer nie
  // betretenen Folie waere in der Sprechervorschau ein leerer Kasten.
  document.querySelectorAll(".ts-scene").forEach(function (el) { szeneBild(el, 0); });
  // `null` is the wall clock, a number is a pinned time in milliseconds. A
  // flipbook otherwise shows whatever frame the machine happened to reach, and
  // two runs of the same deck never agree on it.
  // ── Die Vollbilduhr ───────────────────────────────────────────────────────
  //
  // Eine Uhr, die die Klasse sieht: schwarz von Rand zu Rand, `m:ss`. Sie legt
  // sich nicht ueber die Folie, sie tritt an ihre Stelle -- der Zwilling von
  // `b schwarz`, nur mit etwas darauf.
  //
  // KEINE WEB-ANIMATION. Die billige Bauart waere ein `element.animate()` ueber
  // die ganze Dauer, nichts je Bild. Gemessen und verworfen: `pruef.ruhig()`
  // wartet auf jede laufende Animation, und ein Band ueber 300 s liess jeden
  // `ruhig(4000)` in die Frist laufen, 4143 ms statt 19. Der Decklauf ruft ihn
  // auf jedem Schritt. Umgekehrt zu `scene`, deren Takt eine Web-Animation
  // *ist*, damit `ruhig()` darauf warten kann -- und der Unterschied ist der
  // Sache nach da: eine Szene ist ein begrenzter Uebergang, auf den der Lauf
  // warten muss, eine Uhr ein Dauerzustand, auf den er nie warten darf.
  //
  // ZWEI ZEITBASEN. Buehnenzeit ist `current` aus `beat`, dieselbe, die
  // `pruef.uhr()` festnagelt; alles Gezeichnete rechnet darin, und nur deshalb
  // ist die Uhr im Prueflauf beobachtbar. Die Sprecheruhr im Kopf liest
  // `Date.now() - UHR_START` und ist es deshalb nicht. Die Wanduhr kommt hier
  // an einer einzigen Stelle vor: die Frist in `sichtMerken`, weil Buehnenzeit
  // kein Neuladen ueberlebt. Dort beruehren sie sich und sonst nirgends.
  var UHR = null;
  var UHR_LAUF = 0;          // laufende Nummer, damit ein wiederholtes
                             // `sicht` die Uhr nicht neu stempelt
  var UHR_DECKEL = 1800;     // 30 Minuten. `+2:47:13` sagt niemandem etwas.

  // Die Signalfarbe des Decks, das einzige Stueck Palette, das die Laufzeit
  // kennt. Ueber die fuenf mitgelieferten Paletten misst sie gegen Schwarz
  // zwischen 3,66 (mono) und 6,16 (light), ueberall ueber den 3,0 des Vertrags.
  if (CFG.accent) {
    document.documentElement.style.setProperty("--ts-clock-over", CFG.accent);
  }

  // Die Farbe der cue-Ziffer. Sie hing eine Zeit lang am Akzent des Decks --
  // gut gemeint, aber die Ziffer ist keine Zier: sie ist eine Marke, die man
  // im Vorbeisehen lesen koennen muss, und ein Deck darf sie nicht schlechter
  // machen. Deshalb feste Farben, und zwar die deutlichsten, die es gibt:
  // weiss auf fast schwarz, 18,08. Dazu ein weisser Ring, damit der schwarze
  // Kern auch auf einer dunklen Folie eine Kante hat -- 18,88 gegen ein
  // typisches Folienschwarz. So liest sie sich auf jedem Grund.
  var AD_FLAECHE = "#14161c", AD_SATZ = "#ffffff";

  var UHR_KNOTEN = document.getElementById("ts-clock");
  var UHR_WORT = UHR_KNOTEN && UHR_KNOTEN.querySelector(".ts-clock-word");
  var UHR_ZAHL = UHR_KNOTEN && UHR_KNOTEN.querySelector(".ts-clock-num");

  function uhrZwei(z) { return (z < 10 ? "0" : "") + z; }

  // `m:ss`, und die Vorzeichenspalte ist von Anfang an freigehalten: ein
  // Leerzeichen ist in einer Monospace so breit wie das `+`, also springen die
  // Ziffern beim Umschlag nicht seitwaerts. Erstes von drei Signalen der
  // Ueberzeit -- die anderen sind das Wort und die Farbe, und ein viertes gibt
  // es nicht: kein Blinken, kein Ton.
  function uhrText(sek, drueber, spalte) {
    var s = Math.max(0, sek);
    // Zweistellig, auch unter zehn Minuten. Sonst wechselt die Zeichenzahl
    // beim Sprung von 10:00 auf 9:59, und ein Kasten, der sich nach seinem
    // Inhalt richtet, zuckt in dem Augenblick -- in der angehefteten Uhr war
    // genau das zu sehen: die Ziffern standen nicht mittig in ihrem Rahmen.
    // Die Vollbilduhr haelt eine Spalte fuer das Vorzeichen frei: dort sind
    // die Ziffern riesig, und ein Sprung um eine Zeichenbreite faellt aus der
    // letzten Reihe auf. Die angeheftete Uhr haelt sie *nicht* frei -- ihr
    // Kasten misst sich an seinem Inhalt, und eine leere Spalte darin ist
    // nichts als eine Kante Luft auf einer Seite.
    // Die Spalte steht auf *beiden* Seiten. Nur links reserviert schiebt sie
    // die Ziffern nach rechts aus der Mitte -- die Zeile ist mittig gesetzt,
    // und das Vorzeichen zaehlt beim Zentrieren mit. Mit einer gleich breiten
    // Spalte rechts stehen die Ziffern in der Mitte der Buehne, im Lauf wie in
    // der Ueberzeit, und sie ruecken beim Umschlag um kein Haar.
    if (spalte === false) {
      return (drueber ? "+" : "") + uhrZwei(Math.floor(s / 60)) + ":"
             + uhrZwei(s % 60);
    }
    return (drueber ? "+" : " ") + uhrZwei(Math.floor(s / 60)) + ":"
           + uhrZwei(s % 60) + " ";
  }

  // Ein Bild der Uhr, in Buehnenzeit. Steht unmittelbar hinter der Zeile, die
  // die Pruefuhr einsetzt, und liest nichts als `current`.
  function uhrTakt(current) {
    if (!UHR) return;
    // Der Stempel steht in derselben Zeit, in der abgelesen wird -- derselbe
    // Griff wie beim Daumenkino. `vor` ist, was vor ihm schon verstrichen war:
    // frisch 0, nach einem Neuladen die Strecke aus der Wanduhr-Frist.
    if (UHR.t0 === null) UHR.t0 = current;
    var rest = UHR.dauer - (UHR.vor + (current - UHR.t0) / 1000);
    UHR.rest = rest;
    var drueber = rest < 0;
    // Gedeckelt bei der Dauer, hoechstens eine halbe Stunde. Danach steht sie
    // still: eine Zahl, die weiterwaechst, sagt nach einer Weile nichts mehr.
    var zeig = drueber
      ? Math.ceil(Math.min(-rest, Math.min(UHR.dauer, UHR_DECKEL)))
      : Math.floor(rest);
    var txt = uhrText(zeig, drueber,
                      UHR_KNOTEN && UHR_KNOTEN.dataset.art !== "fest");
    if (txt === UHR.letztes) return;
    UHR.letztes = txt;
    if (UHR_ZAHL) UHR_ZAHL.textContent = txt;
    // Das Wort war vorher nicht da; sein Erscheinen ist das Ereignis.
    if (UHR_WORT) UHR_WORT.textContent = drueber ? wort("over", "over") : "";
    if (drueber) document.documentElement.dataset.tsClockOver = "1";
    else delete document.documentElement.dataset.tsClockOver;
  }

  // Wechselt die Uhr die Art -- Wanduhr gegen festgenagelt --, ist der alte
  // Stempel in der neuen Zeit eine beliebige Zahl, genau wie beim Daumenkino.
  // Was verstrichen war, rettet sich nach `vor`.
  function uhrZeitwechsel() {
    if (!UHR) return;
    UHR.vor = UHR.dauer - (UHR.rest == null ? UHR.dauer : UHR.rest);
    UHR.t0 = null;
    UHR.letztes = null;
  }

  // Die Uhr stellen. `sek` ist die ganze Dauer, `vor` das davon schon
  // Gelaufene -- nur beim Wiederherstellen von null verschieden. In der
  // Sprecheransicht tut das nichts: dort liegt die Sprecherbox darueber, und
  // eine zweite grosse Uhr dahinter waere ein zweiter Ort, der stimmen muss.
  function uhrStellen(sek, lauf, vor) {
    if (ROLLE === "speaker") return;
    var d = Math.max(1, Math.round(+sek || 0));
    UHR = { dauer: d, vor: Math.max(0, +vor || 0), t0: null, rest: null,
            lauf: lauf == null ? ++UHR_LAUF : lauf, letztes: null };
    document.documentElement.dataset.tsClock = "1";
    sichtMerken();
  }
  // Wo die angeheftete Uhr steht und wie gross sie ist. Bruchteile der
  // Buehne, keine Pixel: die Buehne ist in beiden Fenstern verschieden gross,
  // und die Uhr soll in beiden an derselben Stelle der Folie stehen.
  function uhrOrt(art, x, y, s) {
    if (!UHR_KNOTEN) return;
    var fest = art === "fest";
    UHR_KNOTEN.dataset.art = fest ? "fest" : "voll";
    if (!fest) {
      UHR_KNOTEN.style.left = UHR_KNOTEN.style.top = UHR_KNOTEN.style.width = "";
      if (UHR_ZAHL) UHR_ZAHL.style.fontSize = "";
      if (UHR_WORT) UHR_WORT.style.fontSize = "";
      return;
    }
    var b = B ? B.getBoundingClientRect() : null;
    if (!b || !b.width) return;
    UHR_KNOTEN.style.left = Math.round(b.left + b.width * (+x || 0)) + "px";
    UHR_KNOTEN.style.top = Math.round(b.top + b.height * (+y || 0)) + "px";
    // Keine Breite von hier. Die Ziffern stehen in einer Schrift mit festen
    // Zeichenbreiten -- der Kasten weiss selbst, wie breit er sein muss, und
    // jede Zahl, die man ihm vorgibt, kann nur falsch sein. Vorgegeben war
    // ein Viertel der Buehne, und das war zu viel: die Ziffern standen mit
    // Luft daneben, statt in ihrem Rahmen zu sitzen.
    // Und die Ziffern messen sich an der *Buehne*, nicht am Fenster. Mit
    // `vh`/`vw` war die Uhr im Sprecherfenster viel zu gross fuer ihre kleine
    // Buehne: der Kasten folgte der Folie, die Schrift dem Fenster, und
    // dieselbe Uhr sah in beiden Fenstern verschieden aus.
    // Der Faktor greift an der Schrift und nicht an einer Breite: der Kasten
    // richtet sich nach seinen Ziffern, und die Ziffern nach der Buehne. So
    // bleibt die Uhr in beiden Fenstern gleich gross, gleich wie gross das
    // Fenster ist.
    var f = +s > 0 ? +s : 1;
    if (UHR_ZAHL) UHR_ZAHL.style.fontSize = Math.round(b.width * 0.052 * f) + "px";
    if (UHR_WORT) UHR_WORT.style.fontSize = Math.round(b.width * 0.014 * f) + "px";
  }

  function uhrAus() {
    if (!UHR) return;
    UHR = null;
    delete document.documentElement.dataset.tsClock;
    delete document.documentElement.dataset.tsClockOver;
    if (UHR_ZAHL) UHR_ZAHL.textContent = "";
    if (UHR_WORT) UHR_WORT.textContent = "";
    if (UHR_KNOTEN) delete UHR_KNOTEN.dataset.art;
    sichtMerken();
  }
  // Die Dauer nachziehen, waehrend sie laeuft: es waechst die Dauer, nicht der
  // Stempel. Absolut und nicht als Zuwachs, damit eine Nachricht, die zweimal
  // ankommt, nichts anrichtet -- die Sprecheransicht rechnet, die Buehne
  // zeichnet.
  function uhrDauer(sek) {
    if (!UHR) return;
    UHR.dauer = Math.max(1, Math.round(+sek || 0));
    UHR.letztes = null;
    sichtMerken();
  }
  // Was die Uhr zeigt. Fuer die Lagezeile drueben und fuer die Pruefflaeche.
  function uhrStand() {
    if (!UHR) return null;
    var rest = UHR.rest == null ? UHR.dauer - UHR.vor : UHR.rest;
    return { mode: "full", duration: UHR.dauer, lauf: UHR.lauf,
             remaining: Math.round(rest * 1000) / 1000,
             over: rest < 0,
             text: (UHR.letztes || uhrText(Math.floor(Math.max(0, rest)), false)).trim() };
  }

  var PRUEFUHR = null;
  function beat(current) {
    if (PRUEFUHR !== null) current = PRUEFUHR;
    uhrTakt(current);
    for (var k = 0; k < ticking.length; k++) {
      var t = ticking[k];
      var n = +t.el.dataset.frames, fps = +t.el.dataset.fps || 30;
      if (!n) continue;
      // Wann die Uhr eines Daumenkinos zu laufen beginnt: wenn es zu sehen
      // ist, nicht wenn seine Folie kommt. Ein `flipbook(at: "3-")` liegt auf
      // den ersten beiden Schritten still und faengt beim Aufdecken bei null
      // an; wird es wieder zugedeckt, faengt es beim naechsten Mal von vorn
      // an, denn wer zurueckblaettert, will es noch einmal sehen.
      //
      // Verborgen steht Bild 0 da, und das ist zweifach das richtige: es ist
      // das Bild, das Typst in den Kasten gesetzt hat, bevor irgendeine Uhr
      // lief, und es ist das Bild, das auf Papier steht.
      var sichtbar = t.el.dataset.on === "1";
      if (!sichtbar) t.t0 = null;
      else if (t.t0 === null) t.t0 = current;
      var i;
      if (t.t0 === null) {
        i = 0;
      } else if (wenigerBewegung()) {
        // Frozen on one frame. A looping flipbook is the loudest thing this
        // package can put on a slide: it runs from the moment the slide
        // comes up until the moment it goes, and it pulls the eye the whole
        // while, including while someone is talking beside it.
        //
        // Which frame it freezes on is not a matter of taste. A flipbook
        // that does not loop plays once and comes to rest on its last frame,
        // and that resting frame is its finished state; it stays the
        // finished state, only the way there falls away. One that loops or
        // ping-pongs has no rest to come to, and there frame 0 is the right
        // answer twice over: it is the frame Typst put in the box before any
        // clock started, and it is the frame the handout shows on paper.
        //
        // `pingpong` beats `loop` here, exactly as it does below.
        i = (t.el.dataset.pingpong !== "1" && t.el.dataset.loop === "0")
          ? n - 1 : 0;
      } else {
        // Der Startstempel geht immer ein, auch bei festgenagelter Uhr. Er
        // kuerzte sich sonst heraus -- und genau die Groesse, um die es geht,
        // faellt beim Messen weg: mit `t0 = 0` zeigte ein Daumenkino unter der
        // Pruefuhr auf jedem Schritt dasselbe Bild, das aufgedeckte wie das
        // verborgene, und der Prueflauf konnte den Fall nicht sehen. Ein
        // Stempel, der in derselben Zeit genommen wird, in der auch abgelesen
        // wird, macht die Rechnung wieder beobachtbar: aufgedeckt steht Bild
        // 0 da, und wer die Pruefuhr weiterstellt, sieht das Kino laufen.
        i = Math.floor((current - t.t0) / 1000 * fps);
        if (t.el.dataset.pingpong === "1") {
          var p = n > 1 ? 2 * n - 2 : 1;
          var m = i % p;
          i = m < n ? m : p - m;
        } else if (t.el.dataset.loop === "0") { i = Math.min(i, n - 1); }
        else { i = i % n; }
      }
      if (i === t.letztes) continue;
      t.letztes = i;
      var kinder = t.el.children;
      for (var j = 0; j < kinder.length; j++) {
        if (j === i) kinder[j].dataset.on = "1"; else delete kinder[j].dataset.on;
      }
    }
    szenenTakt();
    requestAnimationFrame(beat);
  }
  requestAnimationFrame(beat);

  // ── Bridge ────────────────────────────────────────────────────────────────
  var JOBS = SLIDES.map(function (f) {
    var s = f.querySelector("script.ts-bridge");
    return s ? JSON.parse(s.textContent) : [];
  });
  var bridgeReady = {};

  // Two applets on one slide sharing a name would both receive every job. That
  // happens when the second one is left unnamed and falls back to the default.
  SLIDES.forEach(function (f, i) {
    var seen = {};
    f.querySelectorAll(".ts-bridged").forEach(function (node) {
      var n = node.dataset.bridge;
      if (!n) return;
      if (seen[n]) {
        console.warn("typstage: slide " + (i + 1) + " has two bridged elements"
          + ' named "' + n + '". Both get every job, so give one its own name.');
      }
      seen[n] = 1;
    });
  });

  function drive(i, step, neu) {
    SLIDES[i].querySelectorAll(".ts-bridged").forEach(function (node) {
      var frame = node.querySelector("iframe");
      if (!frame || !frame.contentWindow || frame.dataset.live !== "1") return;
      var name = node.dataset.bridge;
      var jobs = [];
      if (neu) {
        for (var k = 1; k <= step; k++) {
          JOBS[i].forEach(function (j) {
            if (j.t === name && activeAt(j.at, k)) jobs.push(j);
          });
        }
      } else {
        JOBS[i].forEach(function (j) {
          if (j.t === name && activeAt(j.at, step)) jobs.push(j);
        });
      }
      if (!jobs.length && !neu) return;
      var key = i + "|" + step + "|" + (neu ? 1 : 0);
      if (frame.dataset.sync === key) return;
      frame.dataset.sync = key;
      frame.contentWindow.postMessage({ typstage: 1, reset: neu, jobs: jobs }, "*");
    });
  }

  function stopBridges(i) {
    SLIDES[i].querySelectorAll(".ts-bridged iframe").forEach(function (r) {
      r.dataset.sync = "";
      if (r.contentWindow) r.contentWindow.postMessage({ typstage: 1, stop: 1 }, "*");
    });
  }

  addEventListener("message", function (e) {
    var d = e.data;
    if (!d || d.typstage !== 1) return;
    if (d.failed) {
      console.warn("typstage: GeoGebra refused: " + d.failed.join(", "));
      return;
    }
    // An embedded document that can mirror itself reports what became of
    // it after a hand touched it. The speaker view passes that on to the
    // talk, which puts it into its own copy. That is the second way to
    // operate an embed from the view, and the better one wherever it is
    // available: the speaker works on a live applet in front of them
    // instead of aiming at one across the room.
    if (d.spiegel != null && d.stand) {
      if (ROLLE === "speaker") strom("spiegel", { b: d.spiegel, s: d.stand });
      return;
    }
    if (d.ready == null) return;
    var lebt = null;
    document.querySelectorAll(".ts-bridged iframe").forEach(function (r) {
      if (r.contentWindow === e.source) lebt = r;
    });
    if (!lebt) return;
    lebt.dataset.live = "1";
    var wirt = lebt.closest(".ts-el");
    wirt.dataset.bereit = "1";
    // The document says of itself whether it mirrors. Only then does the
    // style sheet hand it the pointer in the speaker view; everything else
    // is served by the route across.
    if (d.spiegel) wirt.dataset.spiegel = "1";
    var st = STEPS[current];
    if (st) drive(st.slide, st.step, true);
  });

  // ── The channel between the windows ───────────────────────────────────────
  //
  // A talk and its speaker view are two windows on the same file.
  // `window.open` sets `window.opener` in the opened window, and
  // `postMessage` carries over this handle in both directions, even from a
  // `file://` page, where `localStorage` is no good: since 68, Firefox gives
  // every local file its own origin, and then neither sees the other's
  // storage.
  //
  // Every message carries `typstage: 1` plus its own `kanal` field. The
  // `typstage` alone is not enough: the bridge to the embedded documents
  // already runs over it (`{typstage: 1, ready: 1}` and their jobs). The two
  // receivers therefore sort each other out by `kanal`: the bridge bails out
  // on `d.ready == null`, this one here on a missing `kanal`.
  //
  // Without a partner, everything here does nothing. A deck that never opens
  // a second window behaves line for line as before.
  var PARTNER = null;   // the other window, once it has checked in
  var KIND = null;      // the handle from window.open, only for finding it again
  var HOERER = Object.create(null);
  var stumm = 0;        // >0 while we are following a remote control

  // A closed window remains lying around as a handle, but it is no longer
  // any good.
  function partner() {
    if (PARTNER) { try { if (PARTNER.closed) PARTNER = null; } catch (x) {} }
    return PARTNER;
  }

  function sende(art, daten) {
    var p = partner();
    if (!p) return false;
    var m = { typstage: 1, kanal: art, deck: DECK };
    if (daten) for (var k in daten) m[k] = daten[k];
    // Under `file://` the origin is "null"; an exact target origin would
    // drop the message. Filtering happens on content instead.
    try { p.postMessage(m, "*"); } catch (x) { return false; }
    return true;
  }

  // For anything added later: a new message kind needs no change to the
  // receiver below, only a `horch("meinding", fn)`.
  function horch(art, fn) { (HOERER[art] || (HOERER[art] = [])).push(fn); }

  // ── A stream instead of individual messages ───────────────────────────────
  //
  // Some things do not arrive every few seconds but at the pace of the
  // mouse: a stroke someone draws in the speaker view is a sequence of
  // points. One message per point would be wasteful, since each one costs
  // the other side its own pass through the receiver, and with the mouse
  // held down that is hundreds.
  //
  // `strom` therefore collects and sends one bundle per frame:
  // `{kanal: art, punkte: [...]}`. The receiver on the other side gets the
  // same kind as with `sende`, just with `punkte` instead of a single value.
  // Collecting only happens when someone is actually listening; and whoever
  // collects in a hidden window gets no frame, hence the cap that sends off
  // a full bundle even without a frame if it has to.
  var STROM = null, stromTakt = 0, STROM_MAX = 128;
  function strom(art, punkt) {
    if (!partner()) return false;
    if (!STROM) STROM = Object.create(null);
    var b = STROM[art] || (STROM[art] = []);
    b.push(punkt);
    if (b.length >= STROM_MAX) { stromAus(); return true; }
    if (!stromTakt) {
      stromTakt = window.requestAnimationFrame
        ? requestAnimationFrame(stromAus) : setTimeout(stromAus, 16);
    }
    return true;
  }
  // A frame still pending while the cap has already emptied finds nothing
  // left and turns right back around. Cancelling it is not worth it.
  function stromAus() {
    stromTakt = 0;
    var s = STROM;
    STROM = null;
    if (!s) return;
    for (var art in s) sende(art, { punkte: s[art] });
  }

  // A step that comes from the other side must not be reported back:
  // otherwise the two windows would send each other the same number back
  // and forth forever. `stumm` silences `melde` for the duration of the
  // jump.
  // Frozen means: the talk accepts the remote step but does not display it.
  // It only remembers where the speaker has moved to in the meantime, and
  // catches up on thawing. Without a speaker window, `FROST` is null and
  // this line costs nothing.
  var FROST = 0, FROST_ZIEL = null;
  function fernGoto(n, instant) {
    if (typeof n !== "number" || isNaN(n) || n === current) return;
    if (FROST) { FROST_ZIEL = n; return; }
    stumm++;
    try { goto(n, instant); } finally { stumm--; }
  }

  // Every step change goes across: the talk reports where it stands, the
  // speaker view requests the step. On the talk side the request is a real
  // change with a transition; the report to the speaker view, by contrast,
  // is a jump without motion, since the stage is covered up there anyway.
  function melde(n) {
    if (stumm) return;
    sende(ROLLE === "speaker" ? "gehe" : "schritt", { n: n });
  }

  // ── Who is on the other side, and are they still the same ────────────────
  //
  // Every window gets an id when it loads. It sits in the reply to `hallo`,
  // and that is how the other side can tell whether the same window is
  // still sitting there or a freshly loaded one. That is the whole
  // difference between "the report is repeating" and "someone over there
  // reloaded", and without it the two would silently drift apart after a
  // reload of the talk window: `window.opener` survives a reload over
  // there, the handle in the opposite direction does not.
  var SITZUNG = String(Date.now()) + "." + Math.floor(Math.random() * 1e6);
  var FERN_SITZUNG = null;   // the id that last came from the other side
  var FRISCH = 1;            // this window has never synced yet
  var LETZTER_SCHLAG = Date.now();   // when anything last arrived at all
  var SICHT_GESENDET = 0;            // when this window last sent its own view command

  // The greeting, i.e. the reply to `hallo`. It repeats at the pace of the
  // heartbeat, so it is only acted on for a new id.
  //
  // Whoever just reloaded adopts the other's state; whoever was already
  // running passes its own on. That way a freshly reloaded talk window
  // finds its way back without the view losing its place, and a freshly
  // opened view shows what actually stands in the hall, instead of
  // claiming "bright and thawed" while it is black there.
  function begruessung(d) {
    // First, and on every beat: whatever the talk itself has decided holds.
    // It is the window that actually shows the view; here there is only the
    // indicator about it. If it lifts black or frost itself, this would
    // otherwise keep saying "frozen", and the keys would be backward: the
    // first press of `b` would switch off something that was not even on
    // anymore, and would freeze the talk again in the process, because both
    // values go together.
    sichtAbgleichen(d);
    if (d.sitzung === FERN_SITZUNG) return;
    var warFrisch = FRISCH;
    FERN_SITZUNG = d.sitzung;
    FRISCH = 0;
    if (warFrisch) {
      fernGoto(d.n, true);
      sichtUebernehmen(d);
      return;
    }
    // A new partner gets everything that stands here: the view, the step,
    // and the ink strokes.
    //
    // The view first, and that is not a matter of taste. A freshly loaded
    // talk window is thawed; if `gehe` came before `sicht`, it would carry
    // out the jump before freezing again, and the freeze would silently
    // break on reload. In this order the step lands in `FROST_ZIEL`, where
    // it belongs.
    //
    // Mit der Uhr als drittem Wert gilt derselbe Satz aus einem zweiten, neu
    // durchgerechneten Grund: andersherum bekaeme das frisch geladene
    // Buehnenfenster erst den Sprung -- einen sichtbaren Blick auf die Folie --
    // und danach die Uhr, die ihn wieder zudeckt. Genau das Aufblitzen, gegen
    // das `sichtErinnern` gebaut wurde, nur eine Zehntelsekunde spaeter.
    //
    // Dass dieses wiederholte Senden keine laufende Uhr zurueckwirft, liegt an
    // der Nummer des Laufs, die mitfaehrt: drueben stempelt nur eine neue neu.
    sichtSenden();
    sende("gehe", { n: current });
    if (TINTE_AN) sende("tintestand", { liste: tinteAbschrift() });
  }

  addEventListener("message", function (e) {
    var d = e.data;
    if (!d || d.typstage !== 1 || !d.kanal) return;
    // Two windows only belong together if they show the same deck. Without
    // this line, a speaker view would happily pair up with a foreign talk:
    // if someone navigates to a different deck in the same tab, the view
    // would then control something it does not even show. Checked before
    // anything else, so that the partner handle is not set either.
    if (d.deck !== DECK) return;
    // Whoever writes is the partner from now on. This carries across a
    // reload: the reloaded window checks in again, and the dead handle
    // simply gets overwritten in the process.
    if (e.source) PARTNER = e.source;
    LETZTER_SCHLAG = Date.now();
    if (d.kanal === "hallo") {
      // `uhrRest` faehrt zurueck, damit die Lagezeile drueben `Uhr 2:41` sagen
      // kann, ohne eine eigene Uhr zu fuehren: zwei Uhren auf dieselbe Pause
      // gehen frueher oder spaeter auseinander.
      var us = uhrStand();
      sende("schritt", { n: current, folien: SLIDES.length,
                         schritte: STEPS.length, rolle: ROLLE,
                         sitzung: SITZUNG,
                         schwarz: document.documentElement.dataset.tsSchwarz ? 1 : 0,
                         frost: FROST,
                         uhr: us ? us.duration : 0,
                         uhrLauf: us ? us.lauf : 0,
                         uhrRest: us ? Math.round(us.remaining) : 0 });
      // The stock only goes to a freshly loaded counterpart. Otherwise the
      // two would keep pushing the same strokes back and forth at the pace
      // of the heartbeat.
      if (d.frisch && TINTE_AN) sende("tintestand", { liste: tinteAbschrift() });
    } else if (d.kanal === "schritt") {
      // With an id it is a greeting, without one a real step change. The
      // difference matters: blindly following the greeting would mean
      // jumping every second to wherever the talk stands, and that is
      // exactly what is not wanted while frozen.
      if (d.sitzung !== undefined) begruessung(d);
      else fernGoto(d.n, true);
    } else if (d.kanal === "gehe") {
      fernGoto(d.n, false);
    }
    var hs = HOERER[d.kanal];
    if (hs) for (var i = 0; i < hs.length; i++) hs[i](d, e);
  });

  // The opened window checks in with its opener, and does so permanently.
  //
  // Once was not enough. `window.opener` survives a reload of the talk
  // window, the handle to it does not: after a reload, the talk no longer
  // knows of anyone, and because it never checks in on its own, the two
  // would stay separated forever. One message per second brings them back
  // together and costs nothing.
  function anmelden() {
    if (ROLLE !== "speaker") return false;
    var o = null;
    // First the window that opened this view itself: that is the only one
    // that exists once the talk has been closed in the meantime.
    try { if (KIND && !KIND.closed) o = KIND; } catch (x) {}
    if (!o) { try { o = window.opener; } catch (x) {} }
    if (!o) return false;
    try { if (o.closed) return false; } catch (x) {}
    PARTNER = o;
    return sende("hallo", { rolle: ROLLE, frisch: FRISCH ? 1 : 0 });
  }
  function anmeldeSchleife() {
    if (ROLLE !== "speaker") return;
    anmelden();
    setInterval(anmelden, 1000);
  }

  // The key opens the second window. Without a user gesture, `window.open`
  // would fall victim to the popup blocker; the keypress is the gesture.
  // The name in the second argument makes sure a second press hits the same
  // window instead of opening a third.
  function oeffneSprecher() {
    if (ROLLE === "speaker") {
      // The other way round: from the speaker view the key brings the talk
      // forward, instead of opening a speaker view of the speaker view.
      var o = partner();
      if (o) { try { o.focus(); } catch (x) {} return o; }
      try { if (KIND && !KIND.closed) { KIND.focus(); return KIND; } } catch (y) {}
      // If the talk is closed, the same key gets a new one. Otherwise the
      // view would page and draw into the void forever, and no one could
      // reach the hall anymore. The new window checks in, gets the running
      // step along with the strokes via the greeting, and thus stands where
      // the view stands.
      KIND = window.open(location.href.split("#")[0], "typstage-stage",
                        "width=1280,height=800");
      return KIND;
    }
    if (KIND) {
      try { if (!KIND.closed) { KIND.focus(); return KIND; } } catch (x) {}
    }
    var ziel = location.href.split("#")[0] + "#speaker";
    KIND = window.open(ziel, "typstage-speaker",
                       "width=1120,height=760,menubar=no,toolbar=no");
    return KIND;
  }

  // ── Strokes on the slide ───────────────────────────────────────────────────
  //
  // Drawing happens in the speaker view, seeing it happens in the talk: the
  // speaker has mouse and trackpad in front of them, not the canvas. So the
  // computation happens in fractions of the stage (0 to 1) instead of
  // pixels. Two windows are rarely the same size; a pixel value would sit
  // in a different spot over there, a fraction sits in the same one.
  //
  // The strokes stick to their slide. `TINTE[folie]` is the list of its
  // strokes, and the drawing layer always only holds those of the running
  // slide. Whoever pages forward and comes back finds them again.
  //
  // As long as no one has drawn, `TINTE_AN` is null and this whole section
  // does not touch anything: a deck without a speaker window notices
  // nothing of it.
  var TINTE = [], TINTE_AN = 0, TINTE_SVG = null, TINTE_FOLIE = -1;
  var RADIERT = 0;         // haelt der Radiergummi gerade gedrueckt?
  // Was `x` von einer Folie geraeumt hat. `x` war der einzige Tastendruck
  // der Ansicht, der ohne Rueckfrage etwas endgueltig wegnahm -- und `z`
  // danach half nicht, denn es nahm nur den letzten Strich zurueck, und
  // Striche gab es keine mehr. Jetzt holt `z` auf einer leeren Folie die
  // geraeumte Zeichnung zurueck. Der Korb steht in beiden Fenstern gleich:
  // beide fuehren dieselben Ereignisse aus.
  var PAPIERKORB = [];
  // Die vier Vorgabefarben der Feder. Ein Deck kann eigene setzen -- ein
  // Tafelbild in Schulfarben etwa, oder zwei statt vier, wenn die Leiste
  // schmal bleiben soll.
  var FARBEN = (SPV.pen && SPV.pen.colors && SPV.pen.colors.length)
    ? SPV.pen.colors.slice()
    : ["#eb5e28", "#ffd166", "#4cc9f0", "#f4f4f5"];
  var STRICH_PT = 3.2;    // stroke width in points of the stage, scaled with it

  function tinteListe(i) { return TINTE[i] || (TINTE[i] = []); }

  // An SVG sized to the stage. The viewBox is the slide format itself, so
  // aspect ratio and stroke width work out without further calculation, and
  // the fractions are simply multiplied by width and height.
  function tinteEbene() {
    if (TINTE_SVG && TINTE_SVG.parentNode === INK) return TINTE_SVG;
    while (INK.firstChild) INK.removeChild(INK.firstChild);
    TINTE_SVG = document.createElementNS(NS, "svg");
    TINTE_SVG.setAttribute("viewBox", "0 0 " + CFG.width + " " + CFG.height);
    INK.appendChild(TINTE_SVG);
    return TINTE_SVG;
  }

  function tintePunkte(s) {
    var out = [];
    for (var i = 0; i < s.punkte.length; i++) {
      out.push((s.punkte[i].x * CFG.width).toFixed(1) + "," +
               (s.punkte[i].y * CFG.height).toFixed(1));
    }
    return out.join(" ");
  }

  // A stroke gets its line element once and keeps it. Exactly one attribute
  // gets updated per bundle. Creating a new element per point on the
  // receiving side would undo the bundling done at the sender.
  function tinteLinie(s, svg) {
    if (s.knoten && s.knoten.parentNode === svg) return s.knoten;
    var n = document.createElementNS(NS, "polyline");
    n.setAttribute("fill", "none");
    n.setAttribute("stroke", s.farbe);
    n.setAttribute("stroke-width", STRICH_PT);
    n.setAttribute("stroke-linecap", "round");
    n.setAttribute("stroke-linejoin", "round");
    svg.appendChild(n);
    s.knoten = n;
    return n;
  }

  // The strokes of the running slide into the layer, everything else out.
  // If the right slide is already sitting there, there is nothing to do.
  function tinteStand() {
    if (!TINTE_AN || !INK || current < 0 || !STEPS[current]) return;
    var si = STEPS[current].slide;
    if (si === TINTE_FOLIE && TINTE_SVG && TINTE_SVG.parentNode === INK) return;
    TINTE_FOLIE = si;
    TINTE_SVG = null;
    var svg = tinteEbene();
    var liste = tinteListe(si);
    for (var i = 0; i < liste.length; i++) {
      liste[i].knoten = null;
      tinteLinie(liste[i], svg).setAttribute("points", tintePunkte(liste[i]));
    }
  }
  function tinteNeu() { TINTE_FOLIE = -1; tinteStand(); }

  function tinteFolie() {
    return (current >= 0 && STEPS[current]) ? STEPS[current].slide : -1;
  }

  // A single event into the stock: either a point, or a command. Both run
  // through the same stream so the order holds. A `sende` alongside the
  // stream would arrive before the still-pending bundle, and a delete would
  // overtake the points it was supposed to delete.
  function tinteNimm(ev, schmutz) {
    if (!ev) return;
    TINTE_AN = 1;
    if (ev.b === "radier") {
      var lr = TINTE[ev.s];
      if (lr) TINTE[ev.s] = lr.filter(function (x) { return x.n !== ev.n; });
      tinteNeu();
      return;
    }
    if (ev.b === "loesch") {
      if (TINTE[ev.s] && TINTE[ev.s].length) PAPIERKORB[ev.s] = TINTE[ev.s];
      TINTE[ev.s] = [];
      tinteNeu();
      return;
    }
    if (ev.b === "weg") {
      var l = TINTE[ev.s];
      if ((!l || !l.length) && PAPIERKORB[ev.s] && PAPIERKORB[ev.s].length) {
        TINTE[ev.s] = PAPIERKORB[ev.s];
        PAPIERKORB[ev.s] = null;
      } else if (l && l.length) {
        l.pop();
      }
      tinteNeu();
      return;
    }
    if (typeof ev.x !== "number" || typeof ev.y !== "number") return;
    var liste = tinteListe(ev.s);
    var s = liste[liste.length - 1];
    // The running number separates the strokes: a new number means the
    // mouse was released in between.
    if (!s || s.n !== ev.n) {
      s = { n: ev.n, farbe: ev.f || FARBEN[0], punkte: [], knoten: null };
      liste.push(s);
    }
    s.punkte.push({ x: ev.x, y: ev.y });
    if (ev.s === tinteFolie() && schmutz.indexOf(s) < 0) schmutz.push(s);
  }

  // A whole bundle at once, and only drawn afterward.
  function tinteBuendel(liste) {
    if (!INK || !liste || !liste.length) return;
    var schmutz = [];
    for (var i = 0; i < liste.length; i++) tinteNimm(liste[i], schmutz);
    tinteStand();
    var svg = tinteEbene();
    for (var k = 0; k < schmutz.length; k++) {
      tinteLinie(schmutz[k], svg).setAttribute("points", tintePunkte(schmutz[k]));
    }
  }
  // The talk listens. The speaker view gets none of it, it only sends;
  // hence there is no feedback loop.
  horch("tinte", function (d) { tinteBuendel(d.punkte); });

  // What already stands on the slides goes across once at check-in.
  // Otherwise a freshly loaded speaker view would see empty slides while
  // the strokes from before still stand in the hall, and the speaker would
  // be erasing at something they no longer have in front of them. The
  // nodes are left behind in the process: a DOM element cannot be sent.
  function tinteAbschrift() {
    var out = [];
    for (var i = 0; i < TINTE.length; i++) {
      if (!TINTE[i]) continue;
      for (var k = 0; k < TINTE[i].length; k++) {
        out.push({ s: i, n: TINTE[i][k].n, f: TINTE[i][k].farbe,
                   p: TINTE[i][k].punkte });
      }
    }
    return out;
  }
  function tinteEinlesen(liste) {
    if (!liste) return;
    TINTE = [];
    for (var i = 0; i < liste.length; i++) {
      var q = liste[i];
      tinteListe(q.s).push({ n: q.n, farbe: q.f, punkte: q.p, knoten: null });
      // The next stroke of our own must get a number not yet assigned on
      // the other side, otherwise it would grow onto a foreign one.
      if (q.n >= STRICH_NR) STRICH_NR = q.n + 1;
      TINTE_AN = 1;
    }
    tinteNeu();
  }
  horch("tintestand", function (d) { tinteEinlesen(d.liste); });

  // ── The pointer through to the embed ──────────────────────────────────────
  //
  // Drawing is one of two things one wants to do on a running slide. The
  // other is to operate what is embedded on it: turn a GeoGebra
  // construction, press a button in an embedded page. Both want the same
  // pointer, so a mode decides which of the two gets it. `m` switches.
  //
  // In pointer mode the position travels the same way the strokes do, in
  // fractions of the stage, and the talk window dispatches the matching
  // event inside its own frame at that spot. The speaker's own copy of the
  // frame gets the same event at the same fraction, so both sides see the
  // same gesture and the speaker is not operating something blind.
  //
  // This only reaches a frame this window may read into, which means an
  // `embed(html:)` and thus a `srcdoc`. A foreign address is another
  // origin, and there `postMessage` is the only way in; the embedded
  // document has to answer it itself. That is what `data-spiegel` is for
  // further down.
  var MODUS = "stift";
  var ZIEL_FERN = null;    // what took the press, so a drag stays with it

  // Which frame lies under a point of the stage. Not `elementFromPoint`:
  // in the speaker view the embeds are switched off for hit testing, and
  // there they would never be found. Rectangles hold in both windows.
  function zeigerRahmen(cx, cy) {
    var st = STEPS[current];
    if (!st || !SLIDES[st.slide]) return null;
    var treffer = null;
    SLIDES[st.slide].querySelectorAll(".ts-el iframe").forEach(function (f) {
      var el = f.closest(".ts-el");
      if (el) {
        var cs = getComputedStyle(el);
        // Something that is not on the slide yet must not catch the
        // pointer either, otherwise a click would land on a frame the hall
        // cannot even see.
        if (cs.visibility === "hidden" || +cs.opacity < 0.05) return;
      }
      var r = f.getBoundingClientRect();
      if (!r.width || !r.height) return;
      if (cx >= r.left && cx <= r.right && cy >= r.top && cy <= r.bottom) treffer = f;
    });
    return treffer;
  }

  // One event into the frame. The constructors are taken from the frame's
  // own window, so an `instanceof` inside it says yes.
  function zeigerSchuss(win, ziel, typ, ix, iy, knopf, dy, klick) {
    var basis = { bubbles: true, cancelable: true, composed: true, view: win,
                  clientX: ix, clientY: iy, screenX: ix, screenY: iy,
                  button: 0, buttons: knopf };
    if (typ === "wheel") {
      if (!win.WheelEvent) return;
      var w = {}; for (var q in basis) w[q] = basis[q];
      w.deltaY = dy; w.deltaMode = 0;
      ziel.dispatchEvent(new win.WheelEvent("wheel", w));
      return;
    }
    // First the pointer event, then the mouse event, exactly as the
    // browser does it. And as the browser does it: whoever cancels the
    // pointer event gets no mouse event afterward. Without this line, a
    // page that listens to both would handle every gesture twice.
    if (win.PointerEvent) {
      var p = {}; for (var k in basis) p[k] = basis[k];
      p.pointerId = 1; p.pointerType = "mouse"; p.isPrimary = true;
      p.width = 1; p.height = 1; p.pressure = knopf ? 0.5 : 0;
      if (!ziel.dispatchEvent(new win.PointerEvent("pointer" + typ, p))) return;
    }
    if (!win.MouseEvent) return;
    ziel.dispatchEvent(new win.MouseEvent("mouse" + typ, basis));
    // A click is only a click if press and release met the same element.
    if (typ === "up" && klick) ziel.dispatchEvent(new win.MouseEvent("click", basis));
  }

  function zeigerZustellen(ev) {
    if (!B || !ev || typeof ev.x !== "number") return;
    var r = B.getBoundingClientRect();
    if (!r.width || !r.height) return;
    var cx = r.left + ev.x * r.width, cy = r.top + ev.y * r.height;
    var f = zeigerRahmen(cx, cy);
    if (!f) { if (ev.t === "up") ZIEL_FERN = null; return; }
    var doc = null, win = null;
    try { doc = f.contentDocument; win = f.contentWindow; } catch (x) {}
    if (!doc || !win) return;
    // The frame is spanned in slide units and scaled onto the stage. Its
    // rectangle is therefore the size on screen, while inside it counts
    // unscaled. Dividing by the scale is the whole conversion. `style.zoom`
    // stays in the chain for a frame that a previous version had sized.
    var fr = f.getBoundingClientRect();
    var z = parseFloat(f.dataset.skala) || parseFloat(f.style.zoom) || 1;
    var ix = (cx - fr.left) / z, iy = (cy - fr.top) / z;
    var unten = null;
    try { unten = doc.elementFromPoint(ix, iy); } catch (y) {}
    // While the button is down, everything goes to whoever took the press,
    // even if the pointer has long since left it. That is what makes
    // dragging a point work at all.
    var ziel = (ev.t !== "down" && ZIEL_FERN && ZIEL_FERN.isConnected)
      ? ZIEL_FERN : unten;
    if (!ziel) return;
    if (ev.t === "down") ZIEL_FERN = ziel;
    zeigerSchuss(win, ziel, ev.t, ix, iy, ev.k || 0, ev.d || 0,
                 ev.t === "up" && unten === ZIEL_FERN);
    if (ev.t === "up") ZIEL_FERN = null;
  }

  function zeigerBuendel(liste) {
    if (!liste) return;
    for (var i = 0; i < liste.length; i++) zeigerZustellen(liste[i]);
  }
  // At ourselves first, then across, and through the stream so that the
  // order of press, drag and release survives the crossing.
  function zeigerSenden(ev) {
    zeigerZustellen(ev);
    strom("zeiger", ev);
  }
  horch("zeiger", function (d) { zeigerBuendel(d.punkte); });

  // The counterpart in the talk window: what came from the view goes into
  // the frame of the same name. Only on the running slide, since only that
  // one is visible, and a state for a slide long since paged past would
  // land in an applet that is reset from the base anyway on the next step.
  horch("spiegel", function (d) {
    if (ROLLE === "speaker" || !d.punkte) return;
    var st = STEPS[current];
    if (!st) return;
    for (var i = 0; i < d.punkte.length; i++) {
      var p = d.punkte[i];
      SLIDES[st.slide].querySelectorAll(".ts-bridged").forEach(function (node) {
        if (node.dataset.bridge !== p.b) return;
        var f = node.querySelector("iframe");
        if (!f || !f.contentWindow || f.dataset.live !== "1") return;
        f.contentWindow.postMessage({ typstage: 1, spiegel: 1, stand: p.s }, "*");
      });
    }
  });

  // ── Talk window: black ────────────────────────────────────────────────────
  //
  // pdfpc separates two things, and that is worth adopting: *black* makes
  // the hall dark, *freeze* leaves the picture standing while the speaker
  // already keeps paging in their own view. The first hangs off an
  // attribute on the root element and is pure presentation; the second
  // sits inside `fernGoto`, because that is where the remote step arrives.
  var gehaltene = [];
  function schwarzMedien(an) {
    var st = STEPS[current];
    if (!st) return;
    if (an) {
      gehaltene = [];
      SLIDES[st.slide].querySelectorAll("video").forEach(function (v) {
        if (!v.paused) { gehaltene.push(v); v.pause(); }
      });
      return;
    }
    // Only restart what was running before: a video the speaker had paused
    // by hand stays paused.
    gehaltene.forEach(function (v) {
      var p = v.play(); if (p && p.catch) p.catch(function () {});
    });
    gehaltene = [];
  }
  function auftauen() {
    FROST = 0;
    // On thawing, the talk catches up on what it missed.
    if (FROST_ZIEL != null) { var z = FROST_ZIEL; FROST_ZIEL = null; fernGoto(z, false); }
  }
  function sichtLoesen() {
    if (document.documentElement.dataset.tsSchwarz) {
      delete document.documentElement.dataset.tsSchwarz;
      schwarzMedien(false);
    }
    if (FROST) auftauen();
    // Und die Vollbilduhr. Sie deckt den Saal genauso zu wie schwarz, es
    // steht nur etwas darauf; ohne diese Zeile waere sie ein neuer Weg,
    // einen Saal dunkel zurueckzulassen -- und im Buehnenfenster gibt es
    // keine Taste dagegen, und es soll dort keine geben.
    uhrAus();
    sichtMerken();
  }

  // A reload of the talk window used to let the hall go bright for the
  // duration of loading, until the next heartbeat brought the black back:
  // a visible flash onto a slide no one is supposed to see. `sessionStorage`
  // belongs to exactly this one tab and survives exactly its reload,
  // nothing more is asked of it. The channel remains `postMessage`; this
  // here is only a memory across the load, and if it fails, everything is
  // as before.
  // Die Uhr kommt als dritter Wert dazu, und sie ist der einzige, der eine Zeit
  // mitbringt. Buehnenzeit ueberlebt kein Neuladen -- in der neuen Seite faengt
  // sie wieder bei null an, ein Stempel von vorher ist dort eine beliebige
  // Zahl. Gemerkt wird deshalb eine WANDUHR-FRIST, `Date.now() + rest*1000`:
  // der Augenblick, an dem die Uhr ablaufen wird. Beim Wiederherstellen wird
  // daraus eine Restdauer, mit der sich die Uhr in Buehnenzeit neu spannt. Die
  // eine Stelle, an der sich die beiden Basen beruehren.
  //
  // Unter festgenagelter Uhr ist die Frist Unsinn -- `rest` steht still,
  // `Date.now()` nicht. Hinnehmbar: ein Prueflauf laedt nicht neu, und
  // ausserhalb eines Prueflaufs ist nichts festgenagelt.
  function sichtMerken() {
    try {
      var u = "";
      if (UHR) {
        var rest = UHR.rest == null ? UHR.dauer - UHR.vor : UHR.rest;
        u = ":" + Math.round(Date.now() + rest * 1000) + "," + UHR.dauer
              + "," + UHR.lauf;
      }
      sessionStorage.setItem("ts-sicht:" + DECK,
        (document.documentElement.dataset.tsSchwarz ? "1" : "0")
          + (FROST ? "1" : "0") + u);
    } catch (x) {}
  }
  function sichtErinnern() {
    if (ROLLE === "speaker") return;
    var alt = null;
    try { alt = sessionStorage.getItem("ts-sicht:" + DECK); } catch (x) { return; }
    if (!alt || alt === "00") return;
    if (alt.charAt(0) === "1") {
      document.documentElement.dataset.tsSchwarz = "1";
      schwarzMedien(true);
    }
    if (alt.charAt(1) === "1") FROST = 1;
    // Aus der Frist wieder eine Dauer. Was das Laden gekostet hat, ist der Uhr
    // abgezogen: die Klasse draussen wartet ja auch. Abgelaufen heisst nicht
    // abgeschaltet -- sie kommt in ihrer Ueberzeit wieder.
    var st = alt.indexOf(":") > 0 ? alt.slice(alt.indexOf(":") + 1).split(",") : null;
    if (st && st.length === 3) {
      var dauer = +st[1], verstrichen = dauer - (+st[0] - Date.now()) / 1000;
      // Eine Frist jenseits des Deckels hat niemand mehr im Blick -- der
      // Rechner stand ueber Nacht. Dann bleibt die Uhr aus.
      if (isFinite(dauer) && isFinite(verstrichen)
          && verstrichen < dauer + UHR_DECKEL) {
        uhrStellen(dauer, +st[2], verstrichen);
      }
    }
    // The guard lifts that again right away if no one is there anymore: a
    // memory without a partner is exactly the case it was built for.
    wacheAn();
  }

  // A hall that stays black because the window was closed with a keypress
  // is the worst thing this view can cause: in the talk window there is no
  // key against it, and there should not be one either, because a deck
  // without a speaker view must not gain a new dependency on one. If the
  // heartbeat stays absent or the partner is gone, the talk lifts black and
  // frost on its own. The guard only runs once either one is on, and stops
  // again as soon as both are off.
  var WACHE = 0, WACHE_SCHLAG = 0;
  function wacheAn() {
    if (WACHE) return;
    WACHE_SCHLAG = Date.now();
    WACHE = setInterval(function () {
      var jetzt = Date.now();
      var eigenerVerzug = jetzt - WACHE_SCHLAG;
      WACHE_SCHLAG = jetzt;
      // `UHR` steht mit in dieser Bedingung, sonst liefe die Wache bei einer
      // blossen Vollbilduhr gar nicht erst -- und dann waere sie das einzige,
      // was einen Saal ohne Sprecherfenster zugedeckt zuruecklaesst.
      if (!FROST && !document.documentElement.dataset.tsSchwarz && !UHR) {
        clearInterval(WACHE); WACHE = 0; return;
      }
      // What is measured is the partner, not the clock. `closed` on the
      // window handle is exactly that signal: it is synchronous, it does
      // not lie, and it is one of the few properties that can be read even
      // across origin boundaries. That makes it work in the case where
      // Firefox gives every local file its own origin.
      if (!partner()) { sichtLoesen(); return; }
      // If this thread itself stalled, a stale `LETZTER_SCHLAG` says
      // nothing about the partner: its messages are then still sitting in
      // the queue and will be delivered momentarily. Whoever confuses that
      // would lift the freeze because this window itself was busy for a
      // moment. So a delayed beat of our own resets the deadline instead.
      if (eigenerVerzug > 2500) { LETZTER_SCHLAG = jetzt; return; }
      // What remains is a coarse net for the one case `closed` does not
      // know: the window stands open but meanwhile carries a different
      // page. One minute, so a mere stall does not fall into it.
      if (jetzt - LETZTER_SCHLAG > 60000) sichtLoesen();
    }, 1000);
  }

  if (ROLLE !== "speaker") horch("sicht", function (d) {
    if (d.schwarz != null) {
      if (d.schwarz) document.documentElement.dataset.tsSchwarz = "1";
      else delete document.documentElement.dataset.tsSchwarz;
      schwarzMedien(!!d.schwarz);
    }
    if (d.frost != null) {
      if (d.frost) FROST = 1; else if (FROST) auftauen();
    }
    // Der dritte Wert. `uhr` ist die ganze Dauer in Sekunden, 0 heisst aus,
    // `uhrLauf` die Nummer des Laufs. An ihr allein haengt, ob neu gestempelt
    // wird: kaeme dieselbe Nachricht ein zweites Mal, etwa weil ein Partner
    // sich neu anmeldet, spraenge die Uhr sonst mitten in der Pause auf ihren
    // Anfang. Gleicher Lauf heisst nur nachziehen. Das ist der Unterschied zu
    // `schwarz` und `frost`, die keine Zeit mitbringen.
    if (d.uhr != null) {
      if (!d.uhr) uhrAus();
      else if (!UHR || UHR.lauf !== d.uhrLauf) uhrStellen(d.uhr, d.uhrLauf, 0);
      else uhrDauer(d.uhr);
      // Art und Ort kommen bei *jedem* Schlag mit und nicht nur beim Stempeln:
      // eine Uhr, die am Pult gerade verschoben wird, soll drueben mitwandern.
      if (UHR) uhrOrt(d.uhrArt, d.uhrX, d.uhrY, d.uhrS);
    }
    if (FROST || document.documentElement.dataset.tsSchwarz || UHR) wacheAn();
    sichtMerken();
  });

  // ── Speaker view: the building blocks ─────────────────────────────────────

  // A slide's note, empty if there is none. It sits as `data-note` on the
  // overlay layer, because that was set in the context of the slide.
  function notiz(i) {
    var f = SLIDES[i];
    return (f && attr(f, "note")) || "";
  }

  // What the next keypress would do: another step on the same slide, a new
  // slide, or nothing more. `STEPS` knows this, because it holds each
  // step's slide.
  function weiter(n) {
    if (n == null) n = current;
    var hier = STEPS[n], nach = STEPS[n + 1];
    if (!nach) {
      return { art: "ende", index: n, slide: hier ? hier.slide : 0,
               step: hier ? hier.step : 1 };
    }
    return { art: (hier && nach.slide === hier.slide) ? "schritt" : "folie",
             index: n + 1, slide: nach.slide, step: nach.step };
  }

  // A slide as a still image, and specifically at a *particular* step.
  // `miniatur` cannot do that: there only the background is copied, and the
  // faded-in parts sit as sprites in the overlay layer. For the preview
  // that is the whole difference, because the question is not "what does
  // the next slide look like" but "what stands there after the next
  // keypress", and that is often the same slide with one more part.
  //
  // `stelle` first, because the sprites get their places from the marks in
  // the background. A slide that has never been on has none yet.
  // Ein geklontes SVG bringt die Namen seiner Teile mit, und im Dokument gibt
  // es sie damit zweimal. Ein `href="#..."` und ein `url(#...)` treffen dann
  // *das erste* Vorkommen -- also das Original. Gemessen auf `ziehen`: der
  // Klon der Szene stand mit 120x89 Pixeln sichtbar da, trug 19 465 Zeichen
  // Inhalt, und gemalt wurde nichts. Der Schnittpfad des Klons zeigte auf den
  // Schnittpfad der laufenden Folie, und der liegt in einem anderen
  // Koordinatensystem: alles fiel heraus.
  //
  // Also bekommen die Namen im Klon eine eigene Endung. Nur im Klon -- das
  // Original bleibt, wie es ist.
  var KLON_NR = 0;
  function namenEindeutig(wurzel) {
    var nr = ++KLON_NR, karte = {};
    wurzel.querySelectorAll("[id]").forEach(function (e) {
      var alt = e.id, neu = alt + "-k" + nr;
      karte[alt] = neu;
      e.id = neu;
    });
    if (!Object.keys(karte).length) return;
    var zeiger = ["href", "xlink:href", "clip-path", "mask", "fill", "stroke",
                  "filter", "marker-start", "marker-mid", "marker-end"];
    wurzel.querySelectorAll("*").forEach(function (e) {
      zeiger.forEach(function (a) {
        var v = e.getAttribute(a);
        if (!v) return;
        var m = /^#(.+)$/.exec(v);
        if (m && karte[m[1]]) { e.setAttribute(a, "#" + karte[m[1]]); return; }
        var u = /^url\(#(.+)\)$/.exec(v.trim());
        if (u && karte[u[1]]) e.setAttribute(a, "url(#" + karte[u[1]] + ")");
      });
    });
  }

  function schrittBild(si, schritt) {
    var f = SLIDES[si];
    var m = document.createElement("div");
    m.className = "ts-mini";
    if (!f) return m;
    stelle(si);
    var cp = f.querySelector(".ts-chromep");
    m.innerHTML = f.querySelector(".ts-bg").innerHTML + (cp ? cp.innerHTML : "");
    // Auch hier: derselbe Name zweimal im Dokument, und die Verweise des
    // Standbildes zeigen auf die laufende Folie.
    namenEindeutig(m);
    var ov = f.querySelector(".ts-ov");
    if (ov) {
      // Read off the originals, applied to the copies further down. A nested
      // element inherits `data-after` from its host, and that lookup needs the
      // slide around it, which the detached copy no longer has.
      var stufen = [];
      ov.querySelectorAll(".ts-el").forEach(function (el) {
        stufen.push(zustand(el, schritt));
      });
      var k = ov.cloneNode(true);
      namenEindeutig(k);
      // A cloned iframe would load the foreign document a second time, a
      // cloned video would play sound a second time. Neither belongs in a
      // still image.
      k.querySelectorAll("iframe,video,audio").forEach(function (x) { x.remove(); });
      // Und die Ziffern einer adaptiven Gruppe. Sie stehen als Geschwister
      // neben ihren Punkten und werden deshalb mitgeklont -- in der Vorschau
      // schweben sie dann ohne den Text, zu dem sie gehoeren. Waehlen kann man
      // dort ohnehin nicht.
      k.querySelectorAll(".ts-ad-nr").forEach(function (x) { x.remove(); });
      // Und eine Feder, die gerade faehrt. Der Klon nimmt die Strichelung als
      // Stil mit -- die Animation bleibt beim Original, ihr Ausgangswert nicht
      // --, und so stuende in einem Standbild ein Strich auf halber Strecke,
      // und zwar fuer immer: der Klon wird nie fertig, weil er nie faehrt.
      // Ein Standbild zeigt den Ruhezustand, und dort ist die Zeichnung fertig.
      k.querySelectorAll("[data-ts-feder]").forEach(function (x) {
        x.style.strokeDasharray = "";
        x.style.strokeDashoffset = "";
        x.removeAttribute("data-ts-feder");
      });
      // Und die Szenen auf den Halt, der nach dem naechsten Tastendruck gilt.
      // Der Klon traegt das Bild, das gerade im Vortrag steht; gefragt ist
      // aber, was dann dasteht. Ohne das zeigte die Vorschau eine Szene, die
      // sich nie bewegt.
      k.querySelectorAll(".ts-scene").forEach(function (el) {
        var i = szeneRahmen(el, schritt);
        var f = el.querySelectorAll(".ts-frame");
        for (var j = 0; j < f.length; j++) {
          if (j === i) f[j].dataset.on = "1"; else delete f[j].dataset.on;
        }
      });
      k.querySelectorAll(".ts-el").forEach(function (el, i) {
        el.removeAttribute("data-hold");
        // The preview answers "what stands there after the next keypress",
        // so it has to show the muted state too: otherwise a point that only
        // steps back would look to the speaker as if it had gone.
        var z = stufen[i];
        el.style.opacity = z === 2 ? "1" : (z === 1 ? String(DIM) : "0");
      });
      m.appendChild(k);
    }
    // Und die Kamera. Sie gehoert ins Standbild aus dem Grund, aus dem es
    // dieses Bild ueberhaupt gibt: gefragt ist nicht, wie die Folie aussieht,
    // sondern was nach dem naechsten Tastendruck dasteht -- und faehrt die
    // Kamera dann hinein, ist der Ausschnitt die Antwort. Gemessen wird an der
    // echten Folie, gesetzt wird auf dem Klon: die Verschiebung steht in
    // Prozent und gilt in einem Kasten von zweihundert Pixeln so wie auf der
    // Buehne.
    //
    // Der Klon *musste* ohnehin angefasst werden. `cloneNode` nimmt das
    // Stilattribut mit, also auch eine laufende Fahrt der Sprite-Ebene -- die
    // Kopie des Hintergrunds dagegen entsteht aus `innerHTML` und traegt sie
    // nicht. Ungefragt stuenden die beiden Haelften des Standbilds
    // gegeneinander verschoben.
    var kam = kameraStand(si, schritt);
    var fahrt = kam ? kameraFahrt(f, kam) : "";
    var grund = m.querySelector("svg"), ebene = m.querySelector(".ts-ov");
    if (grund) grund.style.transform = fahrt;
    if (ebene) ebene.style.transform = fahrt;
    return m;
  }

  // ── Speaker view: the view ────────────────────────────────────────────────
  //
  // It is built at runtime and not written into the file: the same file
  // carries both views, and the talk window is not supposed to notice
  // anything of this one.
  //
  // The running slide is not rebuilt. It is this window's real stage,
  // which runs along anyway; it is only moved to its place instead of
  // being covered up. That does not only save the rebuild: it thereby
  // shows the running step along with transitions, and the drawing layer
  // already sits over it without any extra work, in exactly the same
  // geometry as on the other side.
  var W = CFG.words || {};
  var SPW = W.sp || {};
  function wort(k, r) { return SPW[k] || r; }

  // So breit darf die Notizspalte hoechstens werden. Rund 34 Zeichen mal
  // sechzehn Pixel: eine Zeile, die laenger ist, findet man nach dem
  // Umbruch nicht wieder.
  var NOTIZ_BREIT = 544;

  var PLATZ = null;        // the box in the frame the stage moves to
  var LEIB = null;         // its grid, whose columns depend on the window
  var ELN = {};            // the displays, looked up once
  var gebaut = 0;
  var UHR_START = 0;       // since when counting runs, 0 = not started yet
  var ZIEL_MIN = 0;        // planned duration in minutes, 0 = no plan

  // Schwarz, Frost und die Klassenuhr ueberleben ein Neuladen, der
  // Stundenzaehler und die Zieldauer nicht -- eine Asymmetrie, die niemand
  // erklaeren kann und die eine Lehrkraft nach einem versehentlichen F5
  // ohne ihre Zeit dastehen laesst. Beides steht jetzt daneben, im selben
  // Speicher und mit demselben Schluessel je Deck.
  function standMerken() {
    if (ROLLE !== "speaker") return;
    try {
      sessionStorage.setItem("ts-pult:" + DECK, UHR_START + "," + ZIEL_MIN);
    } catch (x) {}
  }
  function standErinnern() {
    if (ROLLE !== "speaker") return;
    try {
      var t = (sessionStorage.getItem("ts-pult:" + DECK) || "").split(",");
      if (+t[0] > 0) UHR_START = +t[0];
      if (+t[1] > 0) ZIEL_MIN = Math.max(0, +t[1]);
    } catch (x) {}
  }
  // Die Vollbilduhr, von hier aus gesehen. `SAAL_SEK` ist die Dauer, die
  // drueben laeuft (0 = aus), `SAAL_NR` die laufende Nummer des Laufs, und
  // `SAAL_REST` das, was das Buehnenfenster zuletzt zurueckgemeldet hat.
  // Diese Ansicht fuehrt die Uhr nicht, sie liest sie ab: zwei Uhren, die
  // dieselbe Pause zaehlen, gehen frueher oder spaeter auseinander.
  var SAAL_SEK = 0, SAAL_NR = 0, SAAL_REST = 0;
  // Zwei Arten Uhr, und der Unterschied ist nicht die Groesse, sondern was
  // sie ueber den Saal sagt.
  //
  //   "voll" -- das Vollbild. Der Saal macht Pause, die Folie ist zugedeckt,
  //             und der naechste Tastendruck beendet beides zugleich:
  //             weiterblaettern heisst weitermachen.
  //   "fest" -- eine Uhr *auf* der Folie. Die Klasse arbeitet, die Folie mit
  //             der Aufgabe bleibt stehen, und am Pult sieht man schon
  //             einmal nach, was danach kommt. Blaettern beendet sie
  //             deshalb ausdruecklich *nicht* -- das war der teuerste
  //             offene Punkt der Bedienungspruefung.
  //
  // `SAAL_X`/`SAAL_Y` sind Bruchteile der Buehne, gemessen an der linken
  // oberen Ecke der Uhr. Bruchteile und nicht Pixel: die Buehne ist in
  // beiden Fenstern verschieden gross, und die Uhr soll in beiden an
  // derselben Stelle der *Folie* stehen.
  var SAAL_ART = "voll", SAAL_X = 0.72, SAAL_Y = 0.78;
  // Wie gross die angeheftete Uhr ist, als Vielfaches ihrer Grundgroesse.
  // Ein Faktor und keine Pixel, aus demselben Grund wie bei Ort und
  // Bruchteilen: die Buehne ist in beiden Fenstern verschieden gross.
  var SAAL_S = 1;
  var NOTIZ_PX = 21;
  var SCHWARZ = 0, EIS = 0;
  var VORSCHAU = "";
  // The running number starts randomly. After a reload of the speaker
  // view, both sides would otherwise start over at one, and the first new
  // stroke would grow onto the last old one instead of being its own. If
  // the transcript comes from the other side, the number gets bumped up
  // anyway; without a partner, chance carries it.
  var STRICH_NR = Math.floor(Math.random() * 1e6), MALT = 0, FARBE = 0, LETZT = null;
  // `OFFEN` is the held-back first point, `GESETZT` remembers whether
  // anything of the running stroke has already gone out, `DRAUSSEN` whether
  // the pointer currently stands beside the slide.
  var OFFEN = null, GESETZT = 0, DRAUSSEN = 0;
  // `ZEIGT` is the same for pointer mode: the button is down and the
  // gesture belongs to the embed.
  var ZEIGT = 0;

  function bau(tag, klasse, wohin) {
    var e = document.createElement(tag);
    if (klasse) e.className = klasse;
    if (wohin) wohin.appendChild(e);
    return e;
  }
  // Die Zeichen der Werkzeuge als Pfade und nicht als Schriftzeichen.
  // `✎`, `⌫` und `☞` sind auf jedem System anders gross, anders
  // schwer und manchmal bunt -- der Zeiger kam als Emoji heraus, der Radierer
  // als Kasten mit Kreuz. Ein Pfad ist ueberall derselbe Pfad, nimmt mit
  // `currentColor` die Farbe seines Knopfes an und laesst sich auf den halben
  // Pixel genau neben ein 11-px-Wort stellen.
  var WZ_ZEICHEN = {
    stift:  { d: ["M2.8 13.2 L4.1 9.5 L10.7 2.9 L13.1 5.3 L6.5 11.9 Z",
                  "M9.5 4.1 L11.9 6.5"] },
    zeiger: { fuell: 1,
              d: ["M4 2.4 L12.6 8.3 L8.4 8.9 L10.3 12.9 L8.5 13.7 L6.6 9.7 L4 12.3 Z"] },
    radier: { d: ["M5.9 12.4 L2.7 9.2 A1 1 0 0 1 2.7 7.8 L8.2 2.3 A1 1 0 0 1 9.6 2.3 "
                  + "L12.9 5.6 A1 1 0 0 1 12.9 7 L7.3 12.4 Z",
                  "M5.6 4.9 L10.3 9.6", "M2.9 13.7 L13.4 13.7"] },
    undo:   { d: ["M6.3 3.7 L3 7 L6.3 10.3",
                  "M3 7 L9.2 7 A3.3 3.3 0 0 1 9.2 13.6 L7.2 13.6"] },
    clear:  { d: ["M2.6 3.4 L13.4 3.4 L13.4 12.6 L2.6 12.6 Z",
                  "M6.1 6.6 L9.9 10.4", "M9.9 6.6 L6.1 10.4"] },
    sonne:  { d: ["M8 4.9 A3.1 3.1 0 1 0 8 11.1 A3.1 3.1 0 1 0 8 4.9 Z",
                  "M8 1 L8 2.5", "M8 13.5 L8 15", "M1 8 L2.5 8", "M13.5 8 L15 8",
                  "M3.1 3.1 L4.2 4.2", "M11.8 11.8 L12.9 12.9",
                  "M12.9 3.1 L11.8 4.2", "M4.2 11.8 L3.1 12.9"] },
    mond:   { fuell: 1,
              d: ["M13.1 10.4 A5.7 5.7 0 0 1 5.6 2.9 A5.9 5.9 0 1 0 13.1 10.4 Z"] }
  };
  var SVGNS = "http://www.w3.org/2000/svg";
  function wzBild(wohin, name) {
    var s = document.createElementNS(SVGNS, "svg");
    s.setAttribute("viewBox", "0 0 16 16");
    s.setAttribute("class", "ts-sp-wz-bild");
    // Das Zeichen sagt nichts, was der Name nicht schon sagt: aus dem
    // Baum genommen, damit ein Vorleser nicht zweimal dasselbe meldet.
    s.setAttribute("aria-hidden", "true");
    s.setAttribute("focusable", "false");
    var z = WZ_ZEICHEN[name];
    if (z) {
      if (z.fuell) s.setAttribute("data-fuell", "1");
      for (var i = 0; i < z.d.length; i++) {
        var pf = document.createElementNS(SVGNS, "path");
        pf.setAttribute("d", z.d[i]);
        s.appendChild(pf);
      }
    }
    if (wohin) wohin.appendChild(s);
    return s;
  }

  // Eine Kachel: Flaeche, Rand, Marke. Der Baustein, aus dem diese Ansicht
  // besteht. Was hineinkommt, entscheidet der Aufrufer -- eine Kachel weiss
  // nichts ueber ihren Inhalt, und deshalb sehen alle gleich aus.
  function kachel(wohin, klasse, name) {
    var d = bau("div", "ts-sp-kachel" + (klasse ? " " + klasse : ""), wohin);
    bau("div", "ts-sp-marke", d).textContent = name;
    return d;
  }
  // Die grosse Zahl einer Kachel. Sie traegt die Rangordnung, damit nicht
  // vier gleich laute Zahlen nebeneinander stehen und das Auge sich seinen
  // Anker selbst suchen muss.
  function haupt(k) { return bau("div", "ts-sp-gross", k); }
  // Dieselbe Zahl, aber als Knopf. Die Trefferflaeche ist die Zahl und nicht
  // die Kachel: am Pult mit zwei Fenstern ist der haeufigste Mausweg
  // ueberhaupt der Klick ins Sprecherfenster, damit die Tastatur wieder dort
  // ankommt. Gemessen lagen darauf zwei Kacheln von 239x187 Pixeln, zusammen
  // 6,2 % des Fensters, und beide taten stumm etwas Unwiederbringliches.
  // Ein Knopf sagt ausserdem, dass er einer ist: Zeiger, Umriss beim
  // Ueberfahren, Fokus, Tabreihenfolge, und hinterher ein Wort im Balken.
  function hauptKnopf(k, was, tun) {
    var b = bau("button", "ts-sp-gross ts-sp-knopf", k);
    b.type = "button";
    b.title = was;
    b.addEventListener("click", function (ev) {
      ev.stopPropagation();
      var sagen = tun();
      if (sagen) hint(sagen);
    });
    return b;
  }
  // Ein Balken am Fuss einer Kachel. Er sagt ohne Wort, wo man steht, und
  // ist damit das zweite Mittel der Rangordnung neben der Schriftgroesse.
  function balken(k) { return bau("i", "", bau("div", "ts-sp-balken", k)); }
  // A quiet value: number first, word small behind it. Read side by side
  // in one line like "12:56 remaining".
  function neben(wohin, name) {
    var sp = bau("span", "ts-sp-paar", wohin);
    var w = bau("b", "ts-sp-klein", sp);
    bau("i", "ts-sp-wort", sp).textContent = name;
    return w;
  }
  function zwei(z) { return (z < 10 ? "0" : "") + z; }
  function mmss(sek) {
    var v = sek < 0 ? "-" : "";
    sek = Math.abs(Math.round(sek));
    var h = Math.floor(sek / 3600), m = Math.floor(sek / 60) % 60;
    return v + (h ? h + ":" + zwei(m) : String(m)) + ":" + zwei(sek % 60);
  }

  // The clock runs from the first keypress, not from loading: whoever
  // opens the view early and is still talking to the hall does not want a
  // wrong number in front of them.
  function uhrAn() { if (!UHR_START) { UHR_START = Date.now(); standMerken(); } }

  // Der Zustand des Saals, ueber dem Bild des Saals: schwarz, eingefroren,
  // kein Vortragsfenster. Nach Schwere gefaerbt und nicht nach Laune --
  // `kein Vortragsfenster` heisst, dass nichts von dem, was man drueckt,
  // ankommt, und traegt als einziges die Signalfarbe. Schwarz und
  // eingefroren hat man selbst herbeigefuehrt und ist einen Tastendruck
  // weit weg.
  //
  // Die Uhr der Klasse stand bisher hier, als vierte gleich laute Pille.
  // Sie hat jetzt ihre eigene Kachel, siehe `uhrZeigen`.
  function lageZeigen() {
    if (!ELN.lage) return;
    while (ELN.lage.firstChild) ELN.lage.removeChild(ELN.lage.firstChild);
    if (GETRENNT) bau("span", "ts-sp-weg", ELN.lage).textContent =
      wort("lost", "no talk window");
    // Schwarz und eingefroren sahen einander gleich: dieselbe Farbe, dieselbe
    // Groesse, derselbe Ort, unterschieden allein durch das Wort. Und schwarz
    // -- der einzige Zustand, in dem die Klasse gar nichts sieht -- wurde auf
    // 0,061 % der Ansicht gesagt, einundfuenfzigmal leiser als die Ueberzeit.
    // Jetzt sagt es zusaetzlich die Kachel, um die es geht: sie ist die
    // Folie, und die ist gerade nicht zu sehen.
    if (SCHWARZ) bau("span", "ts-sp-dunkel", ELN.lage).textContent =
      wort("black", "black");
    if (EIS) bau("span", "ts-sp-eis", ELN.lage).textContent =
      wort("frozen", "frozen");
    if (ELN.buehne) {
      var saal = (SCHWARZ ? "schwarz " : "") + (EIS ? "eis" : "");
      if (saal.trim()) ELN.buehne.dataset.saal = saal.trim();
      else delete ELN.buehne.dataset.saal;
    }
    uhrZeigen();
  }

  // Die Kachel der Klassenuhr. Vier Zustaende, und sie sehen verschieden
  // aus, weil sie Verschiedenes bedeuten:
  //
  //   aus     -- es laeuft keine; ein Strich, kein Nullwert.
  //   laeuft  -- `m:ss`, gruen, mit einem Balken, der leerlaeuft.
  //   ueber   -- die ganze Kachel faerbt sich. Bisher blieb die Pille gruen,
  //              waehrend die Wand auf die Signalfarbe umschlug: die Klasse
  //              sah die Ueberzeit, bevor die Lehrkraft sie sah. Eine
  //              Flaeche sieht man aus dem Augenwinkel, eine Ziffer nicht.
  //   blind   -- kein Vortragsfenster. Gefuehrt wird die Uhr drueben, diese
  //              Ansicht liest sie nur ab; ohne Partner steht hinter der
  //              Zahl nichts, und dann darf keine dastehen.
  function uhrZeigen() {
    if (!ELN.saal) return;
    var lage = !SAAL_SEK ? "aus"
             : GETRENNT ? "blind"
             : SAAL_REST < 0 ? "ueber" : "laeuft";
    ELN.uhrKachel.dataset.uhr = lage;
    // Bei stehender Uhr zeigt die Wahl, was der naechste Start braechte; bei
    // laufender, was gerade laeuft.
    var artJetzt = SAAL_SEK ? SAAL_ART : FELD_ART;
    if (ELN.uhrArt) {
      for (var a in ELN.uhrArt) {
        ELN.uhrArt[a].dataset.an = a === artJetzt ? "1" : "0";
        ELN.uhrArt[a].setAttribute("aria-pressed", a === artJetzt ? "true" : "false");
      }
    }
    ELN.uhrMarke.textContent = lage === "ueber"
      ? wort("over", "over") : wort("timer", "class clock");
    ELN.saal.textContent = lage === "aus" ? "–:––"
      : lage === "blind" ? "—"
      // Eine Spalte fuer das Vorzeichen, auch wenn keines dasteht. Ohne sie
      // sprangen die Ziffern beim Umschlag in die Ueberzeit um 19 Pixel nach
      // rechts -- gemessen 64,02 gegen 83,03 Pixel. Die Vollbilduhr im Saal
      // haelt diese Spalte seit je frei; die Kachel hielt sie nicht, und
      // damit standen zwei Darstellungen derselben Zahl nach zwei Regeln.
      // U+2007 und nicht das gewoehnliche Leerzeichen: es ist so breit wie
      // eine Ziffer, und nur darauf kommt es an.
      : (lage === "ueber" ? "+" : "\u2007") + mmss(Math.abs(SAAL_REST));
    // Der Balken laeuft leer, solange sie laeuft, und fuellt sich in der
    // Ueberzeit wieder -- gedeckelt, damit er nicht ueber den Rand hinaus
    // weiterwaechst.
    var teil = !SAAL_SEK ? 0
      : SAAL_REST < 0 ? Math.min(1, -SAAL_REST / SAAL_SEK)
      : Math.max(0, Math.min(1, SAAL_REST / SAAL_SEK));
    festZeigen(lage);
    ELN.saalBalken.style.transition = wenigerBewegung() ? "none" : "";
    ELN.saalBalken.style.width = (lage === "aus" || lage === "blind"
      ? 0 : teil * 100) + "%";
  }

  // If no one on the other side answers anymore, that has to be visible.
  // Otherwise the speaker keeps paging into a canvas that has long since
  // stopped following them: the window may be closed, carry a different
  // deck, or the machine at the projector may have hung. Five seconds, so
  // that a single dropped heartbeat reports nothing.
  var GETRENNT = 0;
  function verbindungStand() {
    if (ROLLE !== "speaker") return;
    var weg = (!partner() || Date.now() - LETZTER_SCHLAG > 5000) ? 1 : 0;
    if (weg === GETRENNT) return;
    GETRENNT = weg;
    lageZeigen();
  }
  // Die angeheftete Uhr im Sprecherfenster. Sie wird hier nicht empfangen --
  // `horch("sicht")` gilt nur drueben --, sondern aus dem eigenen Stand
  // gezeichnet: das Pult weiss, was es geschickt hat. Ohne sie saehe man am
  // Pult nicht, wo die Uhr auf der Folie steht, und haette nichts zum
  // Anfassen.
  function festZeigen(lage) {
    if (ROLLE !== "speaker" || !UHR_KNOTEN) return;
    var an = SAAL_SEK && SAAL_ART === "fest" && lage !== "aus";
    if (!an) {
      delete document.documentElement.dataset.tsClock;
      delete UHR_KNOTEN.dataset.art;
      return;
    }
    document.documentElement.dataset.tsClock = "1";
    uhrOrt("fest", SAAL_X, SAAL_Y, SAAL_S);
    var drueber = SAAL_REST < 0;
    if (UHR_ZAHL) UHR_ZAHL.textContent =
      uhrText(Math.abs(Math.round(SAAL_REST)), drueber, false);
    if (UHR_WORT) UHR_WORT.textContent = drueber ? wort("over", "over") : "";
    if (drueber) document.documentElement.dataset.tsClockOver = "1";
    else delete document.documentElement.dataset.tsClockOver;
  }

  // Die angeheftete Uhr laesst sich am Pult verschieben. Sie liegt ueber der
  // Buehne, die zugleich die Zeichenflaeche ist -- deshalb haelt sie das
  // Ereignis auf: ein Zug, der auf ihr beginnt, soll sie bewegen und keinen
  // Strich ziehen. Gesendet wird waehrend des Ziehens, nicht erst am Ende:
  // wer eine Uhr aus dem Weg schiebt, will drueben sehen, wohin.
  function festZiehen() {
    if (ROLLE !== "speaker" || !UHR_KNOTEN) return;
    var greift = null;
    // ── Rand oder Mitte ───────────────────────────────────────────────────
    //
    // Ein Zug am Rand zieht die Uhr groesser oder kleiner, einer in der Mitte
    // schiebt sie. Kein sichtbarer Anfasser, sondern eine Randzone: die Uhr
    // ist ein kleiner Kasten, und vier Ecken darauf waeren mehr Beiwerk als
    // Uhr. Der Zeiger sagt, woran man ist.
    var RAND = 12;
    function amRand(ev) {
      var r = UHR_KNOTEN.getBoundingClientRect();
      return ev.clientX - r.left < RAND || r.right - ev.clientX < RAND ||
             ev.clientY - r.top < RAND || r.bottom - ev.clientY < RAND;
    }
    UHR_KNOTEN.addEventListener("pointerdown", function (ev) {
      if (UHR_KNOTEN.dataset.art !== "fest") return;
      var r = UHR_KNOTEN.getBoundingClientRect();
      if (amRand(ev)) {
        // Gemessen wird der Abstand zur Mitte, nicht zu einer Kante. Damit
        // zieht jede Kante und jede Ecke gleich, und es braucht keine
        // Fallunterscheidung, welche gegriffen wurde.
        var mx = r.left + r.width / 2, my = r.top + r.height / 2;
        var d0 = Math.hypot(ev.clientX - mx, ev.clientY - my);
        greift = { art: "groesse", d0: Math.max(8, d0), s0: SAAL_S };
      } else {
        greift = { art: "ort", dx: ev.clientX - r.left, dy: ev.clientY - r.top };
      }
      try { UHR_KNOTEN.setPointerCapture(ev.pointerId); } catch (x) {}
      ev.preventDefault();
      ev.stopPropagation();
    });
    // Ohne Zug sagt der Zeiger, was ein Zug taete.
    UHR_KNOTEN.addEventListener("pointermove", function (ev) {
      if (greift || UHR_KNOTEN.dataset.art !== "fest") return;
      UHR_KNOTEN.style.cursor = amRand(ev) ? "nwse-resize" : "grab";
    });
    UHR_KNOTEN.addEventListener("pointerleave", function () {
      UHR_KNOTEN.style.cursor = "";
    });
    UHR_KNOTEN.addEventListener("pointermove", function (ev) {
      if (!greift) return;
      if (greift.art === "groesse") {
        var b0 = B.getBoundingClientRect();
        if (!b0.width || !b0.height) return;
        var r0 = UHR_KNOTEN.getBoundingClientRect();
        var mx = r0.left + r0.width / 2, my = r0.top + r0.height / 2;
        var d = Math.hypot(ev.clientX - mx, ev.clientY - my);
        // Grenzen, damit die Uhr weder zum Punkt schrumpft noch die Folie
        // verdeckt. Nach oben zusaetzlich das, was auf die Buehne passt.
        var passt = Math.min(b0.width / Math.max(40, r0.width),
                             b0.height / Math.max(24, r0.height)) * SAAL_S;
        SAAL_S = Math.max(0.4, Math.min(Math.min(4, passt),
                                        greift.s0 * d / greift.d0));
        uhrOrt("fest", SAAL_X, SAAL_Y, SAAL_S);
        // Eine gewachsene Uhr kann ueber den Rand geraten sein. Derselbe
        // Riegel wie beim Schieben, sonst steht sie drueben halb daneben.
        var r1 = UHR_KNOTEN.getBoundingClientRect();
        SAAL_X = Math.max(0, Math.min(1 - r1.width / b0.width, SAAL_X));
        SAAL_Y = Math.max(0, Math.min(1 - r1.height / b0.height, SAAL_Y));
        uhrOrt("fest", SAAL_X, SAAL_Y, SAAL_S);
        sichtSenden();
        ev.preventDefault();
        ev.stopPropagation();
        return;
      }
      var b = B.getBoundingClientRect();
      if (!b.width || !b.height) return;
      var r = UHR_KNOTEN.getBoundingClientRect();
      // In der Buehne gehalten, ganz: eine Uhr, die halb ueber den Rand
      // haengt, steht drueben halb neben der Folie.
      var x = (ev.clientX - greift.dx - b.left) / b.width;
      var y = (ev.clientY - greift.dy - b.top) / b.height;
      SAAL_X = Math.max(0, Math.min(1 - r.width / b.width, x));
      SAAL_Y = Math.max(0, Math.min(1 - r.height / b.height, y));
      uhrOrt("fest", SAAL_X, SAAL_Y, SAAL_S);
      sichtSenden();
      ev.preventDefault();
      ev.stopPropagation();
    });
    var los = function (ev) {
      if (!greift) return;
      greift = null;
      try { UHR_KNOTEN.releasePointerCapture(ev.pointerId); } catch (x) {}
      standMerken();
      ev.stopPropagation();
    };
    UHR_KNOTEN.addEventListener("pointerup", los);
    UHR_KNOTEN.addEventListener("pointercancel", los);
  }

  function sichtSenden() {
    if (ROLLE !== "speaker") return;
    SICHT_GESENDET = Date.now();
    sende("sicht", { schwarz: SCHWARZ, frost: EIS,
                     uhr: SAAL_SEK, uhrLauf: SAAL_NR,
                     uhrArt: SAAL_ART, uhrX: SAAL_X, uhrY: SAAL_Y,
                     uhrS: SAAL_S });
    lageZeigen();
  }
  // What holds on the other side also holds here, continuously and not
  // only at the handshake. A reply sent off before our own keypress knows
  // nothing of it yet; shortly after a command of our own, our own value
  // therefore wins, and the next beat confirms it anyway.
  function sichtAbgleichen(d) {
    if (ROLLE !== "speaker" || d.schwarz == null) return;
    if (Date.now() - SICHT_GESENDET < 1500) return;
    var s = d.schwarz ? 1 : 0, f = d.frost ? 1 : 0;
    var u = +d.uhr || 0, n = +d.uhrLauf || 0, r = +d.uhrRest || 0;
    // Verglichen wird die angezeigte Sekunde und nicht der rohe Rest: sonst
    // baute die Lagezeile sich viermal je Sekunde neu auf.
    var neu = (s !== SCHWARZ || f !== EIS || u !== SAAL_SEK || n !== SAAL_NR
               || Math.round(r) !== Math.round(SAAL_REST));
    SCHWARZ = s; EIS = f; SAAL_SEK = u; SAAL_NR = n; SAAL_REST = r;
    if (neu) lageZeigen();
  }
  // What holds on the other side holds here. A freshly opened view would
  // otherwise claim "bright and thawed" while the hall is black, and the
  // first press of `b` would make it worse instead of better.
  function sichtUebernehmen(d) {
    if (ROLLE !== "speaker") return;
    SCHWARZ = d.schwarz ? 1 : 0;
    EIS = d.frost ? 1 : 0;
    // Und die Uhr, mit ihrer Nummer: ohne sie bekaeme eine frisch geladene
    // Ansicht beim ersten `sichtSenden` einen neuen Lauf, und die Pause im Saal
    // spraenge auf ihren Anfang zurueck.
    SAAL_SEK = +d.uhr || 0; SAAL_NR = +d.uhrLauf || 0; SAAL_REST = +d.uhrRest || 0;
    lageZeigen();
  }

  function tinteSenden(ev) {
    tinteBuendel([ev]);   // at ourselves first, then across
    strom("tinte", ev);
  }

  // ── Hell oder dunkel ──────────────────────────────────────────────────────
  //
  // Woran sich das Erscheinungsbild richtet, ist eine Entscheidung mit drei
  // Kandidaten, und zwei davon sind falsch.
  //
  // *Nicht am Thema des Decks.* Eine Palette sagt, wie die Wand aussieht.
  // Das Pult ist nicht die Wand: dasselbe Nachtdeck laeuft morgens um acht
  // im hellen Raum und abends im abgedunkelten, und davor sitzt beide Male
  // dieselbe Lehrkraft. Ein Deck, das seine Farben dem Pult aufzwingt, gibt
  // die falsche Antwort auf die richtige Frage. Dazu kommt: die Sprecherbox
  // ist Werkzeug und kein Vortrag. Wechselte sie mit dem Deck die Farbe,
  // muesste man sie in jeder Stunde neu lesen lernen.
  //
  // *Nicht allein an einer Taste.* Wer eine Stunde beginnt, soll nicht
  // zuerst die Beleuchtung einstellen.
  //
  // Also `prefers-color-scheme` als Vorgabe -- das einzige Signal, das dem
  // Raum, in dem der *Rechner* steht, schon folgt -- und `l` als
  // Widerspruch, wenn der Raum anders ist, als das Betriebssystem denkt.
  // (`l` wie Licht, light, lumiere: in allen drei Sprachen derselbe
  // Buchstabe, dieselbe Ueberlegung wie bei `d`. Und weit weg von den
  // teuren Nachbarschaften r-t-z und c-x.) Die Wahl haelt die Sitzung, wie
  // `ts-sicht:` es fuer den Saal tut, und ueberlebt ein Neuladen.
  //
  // Geschrieben wird immer ein ausdrueckliches `hell` oder `dunkel`, nie
  // gar nichts. Damit steht jede Farbe genau zweimal im Stilblatt und keine
  // nur einmal, und es braucht dort weder Mediaabfrage noch `:not()`.
  // Kennt der Browser die Vorliebe nicht, gilt dunkel: so sah diese Ansicht
  // immer aus, und das Klassenzimmer beim Vortrag ist abgedunkelt.
  var LICHT_HAND = "";
  function lichtStellen() {
    // Vorgabe ist dunkel, ohne die Systemeinstellung zu fragen. Ein Pult
    // steht im abgedunkelten Raum, und ein helles Fenster neben einer dunklen
    // Wand blendet. Wer es hell will, sagt es mit `l`; die Wahl haelt die
    // Sitzung.
    var hell = LICHT_HAND === "hell";
    document.documentElement.dataset.tsLicht = hell ? "hell" : "dunkel";
    lichtStand();
  }
  function lichtStand() {
    // `lichtHorchen` laeuft ganz zu Anfang, lange bevor die Ansicht gebaut
    // ist: `ELN` gibt es dann noch gar nicht. Deshalb hier beides pruefen und
    // nicht nur den Knopf -- sonst wirft der Aufbau, und die ganze Ansicht
    // bleibt leer.
    if (!ELN || !ELN.licht) return;
    var hell = document.documentElement.dataset.tsLicht === "hell";
    // Der Knopf nennt das *andere* Bild: was ein Druck bewirkt, nicht was
    // gerade gilt. Zeichen und Wort sagen dasselbe, und beide werden
    // getauscht -- ein `textContent` allein haette das Zeichen mit
    // weggewischt.
    var wo = wort(hell ? "dark" : "light", hell ? "dark" : "light");
    var sp = ELN.licht.querySelector(".ts-sp-wz-wort");
    if (sp) sp.textContent = wo; else ELN.licht.textContent = wo;
    var alt = ELN.licht.querySelector("svg");
    if (alt) ELN.licht.replaceChild(wzBild(null, hell ? "mond" : "sonne"), alt);
    ELN.licht.title = wo + "  (l)";
    ELN.licht.setAttribute("aria-label", wo);
  }
  function lichtUm() {
    LICHT_HAND = document.documentElement.dataset.tsLicht === "dunkel"
      ? "hell" : "dunkel";
    try { sessionStorage.setItem("ts-licht", LICHT_HAND); } catch (x) {}
    lichtStellen();
    hint(LICHT_HAND === "hell" ? wort("light", "light") : wort("dark", "dark"));
  }
  function lichtHorchen() {
    try { LICHT_HAND = sessionStorage.getItem("ts-licht") || ""; } catch (x) {}
    lichtStellen();
    if (!window.matchMedia) return;
    var m = window.matchMedia("(prefers-color-scheme: light)");
    // Der Rechner wechselt bei Sonnenuntergang von selbst. Solange niemand
    // widersprochen hat, folgt die Ansicht mit.
    var folgen = function () { if (!LICHT_HAND) lichtStellen(); };
    if (m.addEventListener) m.addEventListener("change", folgen);
    else if (m.addListener) m.addListener(folgen);
  }

  function sprecherAufbau() {
    if (ROLLE !== "speaker" || !SPRECHERBOX) return;

    // Der Leib traegt vier Kacheln in zwei Zeilen: oben die laufende Folie
    // und die Notiz -- was man liest --, unten die vier Zahlkacheln und der
    // naechste Schritt -- was man abliest. Eine Kopfzeile gibt es nicht
    // mehr: die fuenf Zeitwerte, die dort gleich laut nebeneinander standen,
    // haben jetzt je eine Kachel oder stehen klein unter der Zahl, zu der
    // sie gehoeren.
    LEIB = bau("div", "ts-sp-leib", SPRECHERBOX);

    // 1. Die laufende Folie. Sie ist zugleich die Zeichenflaeche: die Buehne
    //    faehrt hierher, statt nachgebaut zu werden. Ihre Kopfzeile traegt
    //    rechts den Zustand des Saals -- schwarz, eingefroren, kein
    //    Vortragsfenster. Der stand bisher in der Fusszeile, achthundert
    //    Pixel von dem Bild entfernt, ueber das er etwas aussagt.
    var kb = bau("div", "ts-sp-kachel ts-sp-buehne", LEIB);
    ELN.buehne = kb;
    var bkopf = bau("div", "ts-sp-buehnenkopf", kb);
    bau("div", "ts-sp-marke", bkopf).textContent = wort("current", "current slide");
    ELN.lage = bau("div", "ts-sp-lage", bkopf);
    PLATZ = bau("div", "ts-sp-platz", kb);

    // 2. Die Notiz. Sie bekommt die ganze zweite Spalte statt eines
    //    Streifens unter der Folie: sie ist das Einzige in dieser Ansicht,
    //    das man wirklich liest.
    var nk = kachel(LEIB, "ts-sp-notizkasten", wort("note", "note"));
    ELN.notizKasten = nk;
    ELN.notiz = bau("div", "ts-sp-notiz", nk);
    notizNachFenster();
    ELN.notiz.addEventListener("scroll", notizStand);
    // Traegt das Deck ueberhaupt Notizen? Entschieden wird das *einmal* fuer
    // das ganze Deck und nicht je Folie. Je Folie waere naeher an der Sache --
    // die Titelfolie hat selten eine Notiz --, aber eine Buehne, die bei jedem
    // Blaettern ihre Groesse wechselt, ist schlimmer als der leere Platz, den
    // sie ersetzt. Ein Deck ohne Notizen bekommt so die Notizkachel gar nicht
    // erst; gemessen waren das 25,9 % der Ansicht fuer zwei Woerter.
    var hatNotiz = false;
    for (var iN = 0; iN < SLIDES.length; iN++) if (notiz(iN)) { hatNotiz = true; break; }
    if (!hatNotiz) LEIB.dataset.notiz = "keine";

    // 3. Die Zahlkacheln.
    var uhren = bau("div", "ts-sp-uhren", LEIB);

    // Verstrichene Zeit, und klein darunter die Uhrzeit an der Wand. Ohne
    // Sekunden: am Pult ist der Sekundenzeiger nie die Frage, und eine Zahl,
    // die viermal je Sekunde zappelt, zieht den Blick, ohne ihn zu belohnen.
    // So macht es reveal.js auch.
    var kZeit = kachel(uhren, "", wort("elapsed", "elapsed"));
    // Ein Klick auf die verstrichene Zeit setzt sie zurueck -- dieselbe
    // Wirkung wie `r`.
    ELN.zeit = hauptKnopf(kZeit, wort("resetTip", "reset elapsed"), function () {
      UHR_START = 0; sprecherUhr(); standMerken();
      return wort("resetDone", "elapsed reset");
    });
    ELN.uhr = neben(bau("div", "ts-sp-neben", kZeit), wort("clock", "clock"));

    // Folie und Schritt, mit dem Fortschrittsbalken am Fuss der Kachel.
    var kOrt = kachel(uhren, "", wort("slide", "slide"));
    ELN.fort = haupt(kOrt);
    ELN.fortSchritt = neben(bau("div", "ts-sp-neben", kOrt), wort("step", "step"));
    ELN.balken = balken(kOrt);

    // Die Zieldauer. Sie ist das einzige Bedienfeld der Ansicht und sah
    // bisher aus wie eine Luecke: ein leerer 51-Pixel-Kasten mit einer
    // Marke, die niemand las. Jetzt steht sie da wie die anderen Zahlen,
    // in derselben Groesse, und `d` geht hinein. Rest und Plan stehen klein
    // darunter -- beides gibt es nur, wenn eine Dauer gesetzt ist.
    var kZiel = kachel(uhren, "", wort("target", "target (min)"));
    var inp = document.createElement("input");
    inp.type = "number"; inp.min = "0"; inp.step = "1";
    inp.className = "ts-sp-ziel"; inp.id = "ts-sp-ziel";
    inp.placeholder = "–";
    kZiel.appendChild(inp);
    inp.addEventListener("input", function () {
      ZIEL_MIN = Math.max(0, +inp.value || 0);
      standMerken();
      sprecherUhr();
    });
    // Without this way out, the field would be a trap: `tippt` keeps the
    // arrow keys from paging, and without a mouse there would be no way
    // out. Enter takes the value, Escape leaves it standing too; both give
    // the keyboard back. `stopPropagation`, so Escape does not also pop
    // open the overview on the side.
    inp.addEventListener("keydown", function (ev) {
      if (feldDurchreichen(ev, function () { inp.blur(); })) return;
      if (ev.key !== "Enter" && ev.key !== "Escape") return;
      inp.blur();
      ev.preventDefault();
      ev.stopPropagation();
    });
    ELN.ziel = inp;
    var zZeile = bau("div", "ts-sp-neben", kZiel);
    ELN.rest = neben(zZeile, wort("left", "remaining"));
    ELN.takt = neben(zZeile, wort("pace", "pace"));
    ELN.restPaar = ELN.rest.parentNode;
    ELN.taktPaar = ELN.takt.parentNode;

    // Die Uhr der Klasse. Sie bekam bisher 0,1 Prozent der Flaeche und war
    // der kleinste Text der Ansicht -- eine Pille in der Fusszeile, neben
    // `schwarz` und `eingefroren`, gleich laut wie beide. Sie ist die
    // einzige Zahl hier, auf die ausserhalb des Pults jemand wartet.
    //
    // Die Sorge, die sie dorthin gebracht hatte, war richtig: zwei grosse
    // Zahlen nebeneinander, die Verschiedenes meinen, werden verwechselt.
    // Aufgeloest wird sie hier durch Bauart und nicht durch Verstecken --
    // die Zieldauer ist ein Feld mit ganzen Minuten, das man einmal je
    // Vortrag setzt, die Klassenuhr eine laufende `m:ss` mit einem Balken,
    // der leerlaeuft. Sie sehen verschieden aus, sie ticken verschieden,
    // und sie heissen verschieden.
    var kUhr = kachel(uhren, "ts-sp-uhrkachel", wort("timer", "class clock"));
    ELN.uhrKachel = kUhr;
    ELN.uhrMarke = kUhr.firstChild;
    // Laeuft die Uhr, beendet ein Klick sie; steht sie, klappt er das
    // Minutenfeld auf. Beides wie ein zweites `t`.
    ELN.saal = hauptKnopf(kUhr, wort("clockTip", "set or stop the class clock"),
      function () {
        if (uhrSaalAus()) return wort("clockDone", "class clock stopped");
        uhrFeldAuf("voll");
        return "";
      });
    // Das Minutenfeld sass in der Fusszeile, damit es nicht neben der
    // Zieldauer stuende. Jetzt sitzt es in der Kachel, um die es geht, und
    // nimmt den Platz der Zahl ein, die es gleich setzt.
    var uf = document.createElement("input");
    uf.type = "number"; uf.min = "1"; uf.step = "1";
    uf.className = "ts-sp-uhrfeld";
    uf.style.display = "none";
    kUhr.appendChild(uf);
    uf.addEventListener("keydown", function (ev) {
      if (feldDurchreichen(ev, uhrFeldZu)) return;
      // Enter nimmt den Wert, Escape laesst ihn liegen; beide geben die
      // Tastatur zurueck. `stopPropagation`, damit Escape nicht nebenbei die
      // Uebersicht aufklappt -- derselbe Ausweg wie beim Zielfeld.
      // Ein leeres Feld ist ein Ruecktritt und keine Uhr ueber eine Minute:
      // wer die Zahl loescht und die Eingabetaste drueckt, meint nichts.
      if (ev.key === "Enter") {
        if (+uf.value > 0) uhrStarten(+uf.value, FELD_ART);
        uhrFeldZu();
      }
      else if (ev.key === "Escape") { uhrFeldZu(); }
      else return;
      ev.preventDefault();
      ev.stopPropagation();
    });
    uf.addEventListener("blur", uhrFeldZu);
    ELN.uhrFeld = uf;
    // Welche Uhr der naechste Start bringt. Man sah es der Ansicht nicht an:
    // `t` und `⇧t` starten Verschiedenes, und der Unterschied stand nirgends
    // ausser in der Tastenzeile. Jetzt steht er in der Kachel, um die es geht
    // -- als Wahl zwischen zweien, und die getroffene ist umgedreht.
    var artZeile = bau("div", "ts-sp-uhrart", kUhr);
    ELN.uhrArt = {};
    [["voll", "full"], ["fest", "pinned"]].forEach(function (a) {
      var k = bau("button", "ts-sp-art", artZeile);
      k.type = "button";
      k.textContent = wort(a[1], a[1]);
      k.dataset.art = a[0];
      k.addEventListener("click", function () {
        // Laeuft schon eine, wechselt sie die Art im Lauf -- eine Pause, die
        // man zudecken wollte und dann doch nicht, soll nicht neu beginnen.
        if (SAAL_SEK) { SAAL_ART = a[0]; sichtSenden(); uhrZeigen(); return; }
        uhrFeldAuf(a[0]);
      });
      ELN.uhrArt[a[0]] = k;
    });
    ELN.saalBalken = balken(kUhr);
    // 4. Der naechste Schritt, als fuenfte Kachel neben den vier Zahlen.
    //    Die Vorschau ist ein Blick und keine zweite Buehne; sie steht
    //    deshalb nicht mehr in einer eigenen Spalte, deren Rest leer blieb.
    var vor = kachel(LEIB, "ts-sp-naechst", "");
    ELN.vorMarke = vor.firstChild;
    ELN.vorBild = bau("div", "ts-sp-vorbild", vor);

    // ── Die Werkzeuge ───────────────────────────────────────────────────
    //
    // Neun Dinge, und sie sind nicht von einer Art. Nach ihrer Natur
    // geordnet, nicht nach der Zeile, in der sie zufaellig Platz fanden:
    //
    //   Auswahl      Stift, Zeiger, Radierer. *Genau eines gilt.*
    //   Zubehoer     Die vier Farben. Sie gehoeren dem Stift.
    //   Handlung     Zuruecknehmen, Folie loeschen. Feuern und sind vorbei.
    //   Einstellung  hell/dunkel. Sagt nichts ueber die Tinte.
    //
    // Die Ordnung nach Haeufigkeit -- erst das Zeichnen, dann das
    // Berichtigen, zuletzt das Einstellen -- bleibt die senkrechte
    // Reihenfolge. Eine Abweichung gibt es, und sie ist der Grund fuer den
    // ganzen Umbau: die drei Werkzeuge stehen jetzt *beieinander* statt auf
    // drei Zeilen verteilt. Von ihnen gilt genau eines; das ist eine
    // Auswahlgruppe, und eine Auswahlgruppe, deren Glieder man erst suchen
    // muss, ist als solche nicht zu lesen. Vorher stand der Stift in Zeile 1,
    // der Radierer zwischen zwei Handlungen in Zeile 2 und der Zeiger neben
    // einer Einstellung in Zeile 3.
    //
    // Drei gleich breite Felder heisst ausserdem: das gewaehlte kann sich
    // keinen Platz nehmen. Vorher trug es `flex:1 1 auto`, und weil
    // "gewaehlt" umgedreht war, wurde ausgerechnet der Ruhezustand -- PEN --
    // zum weissen Klotz ueber die halbe Kachel und damit zum Lautesten.
    //
    // Was *nicht* hereinkommt: Notizgroesse und Vollbild. Die Notizgroesse
    // zeigte auf ein Ding, das es nicht immer gibt -- ein Deck ohne Notizen
    // bekommt die Notizkachel gar nicht erst (siehe `hatNotiz` oben), und ein
    // Knopf, der ins Leere greift, ist schlimmer als keiner. Vollbild meint
    // das *Vortragsfenster*; ein Knopf dafuer im Sprecherfenster machte
    // gross, was ohnehin schon der Arbeitsplatz ist. Beide behalten `+`/`-`
    // und `f`: die Kachel ist der zweite Weg, nicht der erste.
    var wzTraeger = kachel(LEIB, "ts-sp-werkzeugleiste", "");
    ELN.wzTraeger = wzTraeger;
    var wzk = bau("div", "ts-sp-werkzeug", wzTraeger);
    ELN.wzKasten = wzk;
    ELN.werkzeug = {};

    // Eine Gruppe traegt ihren Namen mit, benutzt ihn aber nur dort, wo sie
    // quer liegt und Platz dafuer hat -- dann sieht sie aus wie ein Kasten
    // der Tastenzeile darunter, und das ist Absicht: beide sagen "das hier
    // gehoert zusammen, und so heisst es".
    var wzGruppe = function (klasse, name) {
      var g = bau("div", "ts-sp-wzgruppe " + klasse, wzk);
      bau("span", "ts-sp-wzgruppe-name", g).textContent = name;
      return g;
    };

    var wzKnopf = function (wohin, klasse, zeichen, schluessel, vorgabe, taste) {
      var k = bau("button", klasse, wohin);
      k.type = "button";
      wzBild(k, zeichen);
      bau("span", "ts-sp-wz-wort", k).textContent = wort(schluessel, vorgabe);
      // Der Name steht auch dann noch da, wenn die Kachel zu schmal fuer das
      // Wort ist und nur das Zeichen bleibt.
      k.title = wort(schluessel, vorgabe) + "  (" + taste + ")";
      k.setAttribute("aria-label", wort(schluessel, vorgabe));
      return k;
    };

    // 1 ── Welches Werkzeug gilt
    var tri = wzGruppe("ts-sp-triade", wort("groupTool", "tool"));
    tri.setAttribute("role", "radiogroup");
    tri.setAttribute("aria-label", wort("groupTool", "tool"));
    [["stift", "pen", "pen"], ["zeiger", "pointer", "pointer"],
     ["radier", "erase", "eraser"]].forEach(function (a) {
      var k = wzKnopf(tri, "ts-sp-wz", a[0], a[1], a[2], "m");
      k.dataset.wz = a[0];
      k.setAttribute("role", "radio");
      k.addEventListener("click", function () { modusSetzen(a[0]); });
      ELN.werkzeug[a[0]] = k;
    });
    // Innerhalb einer Auswahlgruppe fuehren die Pfeiltasten, nicht die
    // Tabtaste. Ohne das haette die Gruppe drei Tabstopps statt einem, und
    // die Pfeile taeten hier gar nichts.
    tri.addEventListener("keydown", function (ev) {
      var r = ["stift", "zeiger", "radier"], i = r.indexOf(MODUS);
      if (i < 0) return;
      var n = (ev.key === "ArrowRight" || ev.key === "ArrowDown") ? 1
            : (ev.key === "ArrowLeft" || ev.key === "ArrowUp") ? -1 : 0;
      if (!n) return;
      var z = r[(i + n + r.length) % r.length];
      modusSetzen(z);
      ELN.werkzeug[z].focus();
      ev.preventDefault();
      ev.stopPropagation();
    });

    // 2 ── Womit. Vier Plaetze in fester Reihenfolge, und die Auswahl steht
    //      als *Form*: der gewaehlte Tupfen ist hoeher als seine drei
    //      Nachbarn und traegt zusaetzlich den Halo. Auf Farbe allein waere
    //      hier kein Verlass. Gemessen liegen Gelb und Blau schon bei
    //      normalem Sehen mit 1,33 zueinander und Gelb und Weiss mit 1,31;
    //      unter Deuteranopie Orange und Blau mit 1,47, unter Protanopie
    //      Gelb und Blau mit 1,15. Kein Paar der vier ist ueber die
    //      Helligkeit zu trennen. Was bleibt, ist der Platz in der Reihe:
    //      der dritte ist immer der dritte.
    var farben = wzGruppe("ts-sp-farben", wort("groupColour", "colour"));
    farben.setAttribute("role", "radiogroup");
    farben.setAttribute("aria-label", wort("groupColour", "colour"));
    ELN.farbKasten = farben;
    ELN.tupf = [];
    FARBEN.forEach(function (f, i) {
      var t = bau("button", "ts-sp-tupf", farben);
      t.type = "button";
      t.setAttribute("role", "radio");
      // Als Eigenschaft und nicht als Hintergrund: das Stilblatt rechnet aus
      // ihr die Kante des Tupfens aus, und das geht nur, wenn die Farbe dort
      // als Wert ankommt.
      t.style.setProperty("--tupf", f);
      t.setAttribute("aria-label", wort("pen", "pen") + " " + (i + 1));
      t.title = wort("pen", "pen") + " " + (i + 1) + "  (c)";
      t.addEventListener("click", function () { farbeSetzen(i); modusSetzen("stift"); });
      ELN.tupf.push(t);
    });

    // 3 ── Was man tut. Die leisesten der Kachel: sie tragen keinen Zustand,
    //      also muessen sie auch keinen zeigen.
    var taten = wzGruppe("ts-sp-taten", wort("groupEdit", "edit"));
    ELN.taten = taten;
    wzKnopf(taten, "ts-sp-tat", "undo", "undo", "undo", "z")
      .addEventListener("click", function () {
        tinteSenden({ b: "weg", s: tinteFolie() });
      });
    wzKnopf(taten, "ts-sp-tat", "clear", "clear", "clear", "x")
      .addEventListener("click", function () {
        tinteSenden({ b: "loesch", s: tinteFolie() });
        hint(wort("inkCleared", "slide cleared — z brings it back"));
      });

    // 4 ── hell/dunkel. Das einzige der neun, das nichts ueber die Tinte
    //      sagt, sondern ueber diese Ansicht. Wo es steht, ist der
    //      Unterschied zwischen den Entwuerfen a und b; c und d geben ihm
    //      einen eigenen Kasten am Ende, getrennt durch Luft und nicht durch
    //      einen Strich -- dieselbe Sprache, mit der die Kacheln sich
    //      untereinander trennen.
    // Der Kasten heisst nach dem, was er einstellt, und nicht nach dem Knopf
    // darin: "LIGHT . LIGHT" waere dasselbe Wort zweimal. "Ansicht" ist
    // ausserdem der Name, unter dem `l` in der Tastenzeile steht -- dieselbe
    // Sache, derselbe Name, zwei Zeilen uebereinander.
    var lichtWohin = wzGruppe("ts-sp-wzlicht", wort("groupView", "view"));
    ELN.licht = wzKnopf(lichtWohin, "ts-sp-tat ts-sp-licht", "sonne",
                        "light", "light", "l");
    ELN.licht.addEventListener("click", lichtUm);
    ELN.modus = ELN.werkzeug.stift;

    var fuss = bau("div", "ts-sp-fuss", SPRECHERBOX);
    ELN.hilfe = bau("div", "ts-sp-hilfe", fuss);
    // Die ganze Tastenzeile, nicht die kurze Fassung: die Leiste ist breit
    // genug fuer alles, und eine Auswahl daraus zwingt nur dazu, sich den Rest
    // zu merken. Jede Taste steht als kleiner Kasten da -- was man drueckt,
    // sieht aus wie etwas, das man drueckt, und hebt sich damit vom Wort ab,
    // das sagt, was dabei geschieht.
    tastenzeile(ELN.hilfe, W.helpSpeaker || W.helpSpeakerShort || W.help || "");

    // ── Was das Deck abbestellt hat ─────────────────────────────────────
    //
    // Gebaut wird alles, entfernt wird danach. Der Grund ist Buchhaltung: an
    // der Uhrkachel haengen dreissig Schreibzugriffe, an der Zielkachel elf,
    // und keiner davon fragt, ob es sie gibt. Wuerde die Kachel gar nicht
    // erst entstehen, muessten alle einundvierzig eine Schranke bekommen --
    // einundvierzig Gelegenheiten, eine zu vergessen. So schreiben sie
    // weiter, nur in einen Knoten, der an keinem Dokument mehr haengt: das
    // kostet nichts und kann nicht schiefgehen.
    //
    // Die Tasten gehen mit. Eine Uhr, die man nicht sieht, aber mit ⇧T
    // starten kann, waere schlimmer als gar keine.
    if (SPV.clock === false) ELN.uhrKachel.remove();
    if (SPV.target === false && ELN.ziel) {
      var zk = ELN.ziel.closest(".ts-sp-kachel");
      if (zk) zk.remove();
    }
    if (SPV.tools === false) ELN.wzTraeger.remove();

    // The sound belongs in the hall, not at the speaker's seat: the stage
    // runs along here in full, video included. Seeing it is desired,
    // hearing it twice is not.
    document.querySelectorAll("video,audio").forEach(function (v) { v.muted = true; });

    tasten();
    zeichnen();
    festZiehen();
    farbeSetzen(0);
    modusSetzen("stift");
    // Was vor dem Neuladen dastand, steht danach wieder da -- nach dem
    // Aufbau, denn erst jetzt gibt es das Feld, in das die Zieldauer gehoert.
    standErinnern();
    if (ELN.ziel && ZIEL_MIN) ELN.ziel.value = String(ZIEL_MIN);
    gebaut = 1;
    document.documentElement.dataset.tsFertig = "1";

    // The clock runs as soon as something moves on the other side, not
    // already when the talk merely reports where it stands. This report is
    // the reply to the check-in, and the check-in repeats until it
    // arrives: so what is counted is not how often a report came in, but
    // whether it carries a different number than the previous one.
    var fern = null;
    horch("schritt", function (d) {
      if (d.sitzung !== undefined) return;   // a greeting, not a step
      if (fern !== null && fern !== d.n) uhrAn();
      fern = d.n;
    });

    setInterval(sprecherUhr, 250);
    sprecherStand();
    sprecherUhr();
    fit();
  }

  // Pen or pointer. Everything that hangs off it is one attribute on the
  // root element, so the look follows without a second place to keep in
  // step: in pointer mode the colour swatches step back, and an embed that
  // mirrors itself gets the pointer locally (see the style sheet).
  function modusSetzen(m) {
    MODUS = (m === "zeiger" || m === "radier") ? m : "stift";
    document.documentElement.dataset.tsModus = MODUS;
    // A half-drawn stroke and a held press must not survive the switch.
    MALT = 0; ZEIGT = 0; LETZT = null; OFFEN = null; GESETZT = 0;
    if (ELN.wzKasten) ELN.wzKasten.dataset.modus = MODUS;
    if (ELN.werkzeug) {
      for (var w in ELN.werkzeug) {
        var an = w === MODUS;
        ELN.werkzeug[w].dataset.an = an ? "1" : "0";
        // `aria-checked` und nicht `aria-pressed`: die drei sind eine
        // Auswahlgruppe, in der genau eines gilt, und keine drei Schalter,
        // die einzeln an und aus gehen. Der Vorleser sagt damit "1 von 3".
        ELN.werkzeug[w].setAttribute("aria-checked", an ? "true" : "false");
        // Nur das gewaehlte Feld liegt in der Tabreihenfolge; innerhalb der
        // Gruppe fuehren die Pfeiltasten. So verlangt es das Muster fuer
        // `radiogroup`, und so spart es am Pult drei Tabschritte.
        ELN.werkzeug[w].tabIndex = an ? 0 : -1;
      }
    }
    // Die Farben gehoeren zum Stift. Im Zeiger- und im Radiermodus haben sie
    // nichts zu sagen und treten zurueck. Vorher stand hier ein
    // `data-aus`, zu dem es im ganzen Stilblatt keine Regel gab: der
    // Kommentar versprach etwas, das nie geschah, und die Farben blieben in
    // jedem Modus voll da und voll bedienbar.
    if (ELN.tupf) {
      for (var t = 0; t < ELN.tupf.length; t++) {
        ELN.tupf[t].disabled = MODUS !== "stift";
      }
    }
  }
  function modusUm() {
    var neu = MODUS === "zeiger" ? "stift" : "zeiger";
    modusSetzen(neu);
    // Der Zeiger greift nur in eingebettete Dokumente hinein. Auf einer
    // Textfolie tat er bisher gar nichts und sagte es auch nicht: der
    // Schalter versprach eine Faehigkeit, die es nur auf manchen Folien
    // gibt, und das Pult zeigte nicht, auf welchen.
    if (neu === "zeiger" && current >= 0 && STEPS[current]) {
      var f = SLIDES[STEPS[current].slide];
      if (f && !f.querySelector("iframe")) {
        hint(wort("pointerNone", "nothing to point at on this slide"));
      }
    }
  }

  function farbeSetzen(i) {
    FARBE = i % FARBEN.length;
    if (!ELN.tupf) return;
    for (var k = 0; k < ELN.tupf.length; k++) {
      // `aria-pressed` neben dem Halo: die Auswahl steht damit auch dort,
      // wo niemand hinsieht, sondern zugehoert wird.
      ELN.tupf[k].setAttribute("aria-pressed", k === FARBE ? "true" : "false");
      if (k === FARBE) ELN.tupf[k].dataset.an = "1";
      else delete ELN.tupf[k].dataset.an;
    }
  }

  // As long as no one has chosen the size by hand, it follows the window:
  // 21px is right on a large screen and too big in a small window, where
  // only four lines would remain. The window also opens small and is often
  // only resized afterward. A press of + or - ends this following, because
  // from then on what the speaker wants applies.
  var NOTIZ_HAND = 0;
  function notizNachFenster() {
    if (NOTIZ_HAND || !ELN.notiz) return;
    var neu = Math.max(15, Math.min(24, Math.round(innerHeight / 34)));
    if (neu === NOTIZ_PX) return;
    NOTIZ_PX = neu;
    ELN.notiz.style.fontSize = NOTIZ_PX + "px";
  }
  function notizGroesse(d) {
    NOTIZ_HAND = 1;
    NOTIZ_PX = Math.max(12, Math.min(64, NOTIZ_PX + d));
    if (ELN.notiz) ELN.notiz.style.fontSize = NOTIZ_PX + "px";
    notizStand();
  }
  // A line that is simply cut off at the bottom edge reads as if the note
  // had ended. Hence a gradient and an arrow as soon as more is coming, and
  // two keys for scrolling: during the talk the hands are not on the mouse.
  function notizStand() {
    if (!ELN.notiz || !ELN.notizKasten) return;
    var n = ELN.notiz;
    if (n.scrollHeight - n.clientHeight - n.scrollTop > 4) {
      ELN.notizKasten.dataset.mehr = "1";
    } else {
      delete ELN.notizKasten.dataset.mehr;
    }
  }
  function notizRollen(richtung) {
    if (!ELN.notiz) return;
    ELN.notiz.scrollTop += richtung * Math.max(40, ELN.notiz.clientHeight * 0.6);
    notizStand();
  }

  // ── Die Vollbilduhr, von der Sprecheransicht aus ──────────────────────────
  //
  // Hier steht nur die Rechnung: eine Dauer und eine Nummer, beide ueber den
  // `sicht`-Kanal. Gezaehlt wird drueben, in Buehnenzeit; diese Ansicht liest
  // nur die Zahl ab, die zurueckkommt.
  function uhrStarten(min, art) {
    var m = Math.max(1, Math.round(+min || 0));
    SAAL_ART = art === "fest" ? "fest" : "voll";
    SAAL_SEK = m * 60;
    // Eine neue Nummer heisst drueben: neu stempeln. Nur hier wird sie erhoeht.
    SAAL_NR++;
    SAAL_REST = SAAL_SEK;
    sichtSenden();
  }
  function uhrSaalAus() {
    if (!SAAL_SEK) return false;
    SAAL_SEK = 0; SAAL_REST = 0;
    sichtSenden();
    return true;
  }
  // Eine Minute mehr oder weniger. Gesendet wird die neue ganze Dauer und nicht
  // der Zuwachs: eine Nachricht, die zweimal ankommt, richtet dann nichts an.
  function uhrSaalMehr(sek) {
    if (!SAAL_SEK) return false;
    SAAL_SEK = Math.max(60, SAAL_SEK + sek);
    SAAL_REST += sek;
    sichtSenden();
    return true;
  }
  // Das Minutenfeld nimmt den Platz der Zahl ein, die es gleich setzt --
  // in der Kachel, um die es geht, und nicht mehr als 51 Pixel breiter
  // Kasten in der unteren Ecke, achthundert Pixel von der Stelle entfernt,
  // an der das Auge die Zeit sucht.
  // Tasten, die dem Saal gelten und nicht dem Feld. Steht ein Zahlenfeld
  // offen, waren sie bisher verloren: gemessen blaetterte `→` nicht, `e`
  // fror nicht ein, und `b` verdunkelte nicht, sondern *loeschte still die
  // eingegebene Zahl* -- ein Zahlenfeld nimmt keinen Buchstaben an und
  // raeumt sich dabei selbst ab. Zwei Befehle verloren, null Rueckmeldung,
  // mitten in einer Stunde.
  //
  // Jetzt schliesst so eine Taste das Feld und tut danach, wofuer sie da
  // ist. Ausgefuehrt wird sie neu ausgeloest und nicht hier nachgebaut: der
  // grosse Empfaenger steigt bei `tippt(e)` aus, und `e.target` steht fest,
  // sobald das Ereignis unterwegs ist -- ein blosses `blur()` kaeme dafuer
  // zu spaet.
  // Ohne `p`, aus demselben Grund wie oben in `TASTEN_DECK`.
  var SAALTASTEN = {
    b: 1, e: 1, m: 1, x: 1, z: 1, c: 1, o: 1, f: 1, n: 1,
    ArrowLeft: 1, ArrowRight: 1, PageUp: 1, PageDown: 1, Home: 1, End: 1
  };
  function feldDurchreichen(ev, zu) {
    if (!SAALTASTEN[ev.key] || ev.metaKey || ev.ctrlKey || ev.altKey) return false;
    zu();
    ev.preventDefault();
    ev.stopPropagation();
    var k = ev.key, um = ev.shiftKey;
    setTimeout(function () {
      document.dispatchEvent(new KeyboardEvent("keydown",
        { key: k, shiftKey: um, bubbles: true, cancelable: true }));
    }, 0);
    return true;
  }

  // Was das Deck fuer die laufende Folie an Minuten vorgesehen hat, oder 0.
  // Ein Vorschlag und kein Befehl: das Feld steht mit der Zahl offen, und wer
  // eine andere will, tippt sie.
  function geplanteUhr() {
    if (current < 0 || !STEPS[current]) return 0;
    var f = SLIDES[STEPS[current].slide];
    return f ? Math.max(0, +attr(f, "clock") || 0) : 0;
  }

  var FELD_ART = "voll";      // welche Art das offene Minutenfeld startet
  function uhrFeldAuf(art) {
    if (!ELN.uhrFeld) return;
    FELD_ART = art === "fest" ? "fest" : "voll";
    ELN.uhrKachel.dataset.art = FELD_ART;
    uhrZeigen();
    var geplant = FELD_ART === "fest" ? geplanteUhr() : 0;
    if (geplant) ELN.uhrFeld.value = String(geplant);
    ELN.uhrFeld.style.display = "";
    ELN.saal.style.display = "none";
    ELN.uhrFeld.value = ELN.uhrFeld.value || "5";
    ELN.uhrFeld.focus();
    ELN.uhrFeld.select();
  }
  function uhrFeldZu() {
    if (!ELN.uhrFeld) return;
    ELN.uhrFeld.style.display = "none";
    ELN.saal.style.display = "";
    ELN.uhrFeld.blur();
  }

  // ── The speaker view's keys ───────────────────────────────────────────────
  //
  // A receiver of its own, only registered during setup: in the talk
  // window it does not exist at all. Paging, overview, and fullscreen come
  // from the shared control further up and do not appear here again.
  function tasten() {
    addEventListener("keydown", function (e) {
      if (tippt(e)) return;
      var k = e.key;
      if (k === "ArrowRight" || k === "ArrowLeft" || k === "PageDown" ||
          k === "PageUp" || k === " " || k === "Home" || k === "End") {
        // Umschalt und Pfeil verlaengern die laufende Uhr.
        //
        // Der Entwurf sah `t` gehalten dafuer vor; verworfen. Eine gehaltene
        // Buchstabentaste ist ein Zustand, den nur ein `keyup` aufhebt, und
        // beim Fensterwechsel -- am Rednerpult die haeufigste Handbewegung --
        // kommt keines mehr an. Danach staende `t` fuer immer als gedrueckt da
        // und die Pfeile blaetterten nicht mehr: der eine Tastendruck, der
        // immer sitzen muss. Umschalt faehrt im selben Ereignis mit, also gibt
        // es den Zustand nicht. Und die Geste kostet nichts: solange die Uhr
        // laeuft, ist der blosse Pfeil ohnehin vergeben, er beendet sie.
        //
        // Ausgefuehrt wird sie eine Ebene tiefer, in der gemeinsamen Steuerung:
        // beide Empfaenger haengen am selben `window`, `stopPropagation` haelt
        // den anderen also nicht auf, und die Reihenfolge der Anmeldung haengt
        // daran, wann die Ansicht aufgebaut war. Hier steht nur, was hier
        // nicht geschehen soll.
        if (e.shiftKey && SAAL_SEK
            && (k === "ArrowRight" || k === "ArrowLeft")) return;
        // Blaettern beendet die *Vollbilduhr* und deckt die Folie auf: was
        // man nach der Pause tut, ist weitermachen. Eine angeheftete Uhr
        // bleibt stehen -- sie gehoert der Klasse, die gerade arbeitet, und
        // nicht der Folie, die am Pult gerade gesucht wird.
        if (SAAL_ART !== "fest") uhrSaalAus();
        uhrAn(); return;
      }
      // Up and down are free in the shared control and scroll the note
      // here. In the talk window this receiver does not exist.
      if (k === "ArrowDown") { notizRollen(1); e.preventDefault(); return; }
      if (k === "ArrowUp") { notizRollen(-1); e.preventDefault(); return; }
      if (k === "b") { SCHWARZ = SCHWARZ ? 0 : 1; sichtSenden(); }
      // `t` wie timer. Laeuft sie, beendet derselbe Druck sie -- wie `b` und
      // `e`, nur mit einer Frage davor.
      // `⇧t` ist die angeheftete Uhr: dieselbe Frage nach den Minuten, aber
      // sie deckt den Saal nicht zu und ueberlebt das Blaettern. Der Platz
      // war seit dem Einbau der Vollbilduhr dafuer freigehalten.
      //
      // Gepruefte wird der Buchstabe und nicht `k === "t"`: mit Umschalt
      // meldet der Browser `"T"`, und ein Vergleich auf das kleine `t`
      // ginge fuer die angeheftete Uhr nie auf -- gemessen startete `⇧t`
      // das Vollbild.
      // Eine abbestellte Kachel nimmt ihre Tasten mit. Eine Uhr, die man
      // nicht sieht, aber mit ⇧T starten kann, waere schlimmer als keine.
      else if ((k === "t" || k === "T") && SPV.clock !== false) {
        if (!uhrSaalAus()) uhrFeldAuf(e.shiftKey ? "fest" : "voll");
        e.preventDefault();
      }
      else if (k === "e") { EIS = EIS ? 0 : 1; sichtSenden(); }
      // Die Zieldauer sass auf `t` und zog auf `d` um -- duration, Dauer,
      // duree, in allen drei Sprachen derselbe Buchstabe. Der gute Buchstabe
      // gehoert dem, was man oft drueckt: die Zieldauer wird einmal je Vortrag
      // gesetzt, die Klassenuhr mehrmals je Stunde.
      else if (k === "d" && SPV.target !== false) {
        if (ELN.ziel) { ELN.ziel.focus(); ELN.ziel.select(); e.preventDefault(); }
      }
      // Sagt, was es getan hat. `r` liegt auf einer Tastatur neben `t` und
      // `z`, und es loeschte den Stundenzaehler ohne ein Wort.
      else if (k === "r") {
        UHR_START = 0; sprecherUhr(); standMerken();
        hint(wort("resetDone", "elapsed reset"));
      }
      else if (k === "l") { lichtUm(); }
      else if (k === "m" && SPV.tools !== false) { modusUm(); }
      else if (k === "c" && SPV.tools !== false) { farbeSetzen(FARBE + 1); }
      else if (k === "z" && SPV.tools !== false) {
        tinteSenden({ b: "weg", s: tinteFolie() });
      }
      else if (k === "x") {
        tinteSenden({ b: "loesch", s: tinteFolie() });
        hint(wort("inkCleared", "slide cleared — z brings it back"));
      }
      else if (k === "+" || k === "=") { notizGroesse(2); }
      else if (k === "-" || k === "_") { notizGroesse(-2); }
    });
  }

  // ── Drawing ────────────────────────────────────────────────────────────────
  //
  // The pointer handlers sit on the stage itself, since it sits on top
  // here. A click does not page in this role anyway (see the control
  // handler), so the place is free.
  function zeichnen() {
    function anteil(e) {
      var r = B.getBoundingClientRect();
      if (!r.width || !r.height) return null;
      return { x: (e.clientX - r.left) / r.width,
               y: (e.clientY - r.top) / r.height };
    }
    // Jitter costs bandwidth and adds no visible picture. A fast stroke has
    // large gaps and loses nothing by it.
    function weitGenug(p) {
      if (!LETZT) return true;
      var dx = p.x - LETZT.x, dy = p.y - LETZT.y;
      return dx * dx + dy * dy > 0.000004;   // a good 0.2% of the stage width
    }
    // Nothing outside the slide into the stock. A pointer dragged past the
    // edge would otherwise yield values like 1.4 or -0.2 that no one ever
    // gets to see (`#ts-ink` clips them off) and that still travel into
    // every transcript. If it comes back, a new stroke begins instead of
    // jumping across the slide.
    function drin(p) { return p.x >= 0 && p.x <= 1 && p.y >= 0 && p.y <= 1; }
    function punkt(e) {
      var p = anteil(e);
      if (!p) return;
      if (!drin(p)) { DRAUSSEN = 1; return; }
      if (DRAUSSEN) {
        DRAUSSEN = 0; STRICH_NR++; LETZT = null; OFFEN = null; GESETZT = 0;
      }
      if (!weitGenug(p)) return;
      LETZT = p;
      // The first point waits until a second one arrives. A mere click
      // would otherwise create a stroke out of one point: `getBBox` is 0 by
      // 0, nothing is visible, and undo would then clear away this ghost
      // instead of the stroke the speaker actually meant.
      if (OFFEN) { schicke(OFFEN); OFFEN = null; }
      else if (!GESETZT) { OFFEN = p; return; }
      schicke(p);
    }
    function schicke(p) {
      GESETZT = 1;
      tinteSenden({ n: STRICH_NR, s: tinteFolie(), f: FARBEN[FARBE],
                    x: p.x, y: p.y });
    }
    // Was der Radiergummi beruehrt. Verglichen wird in Bruchteilen der
    // Buehne, denn so stehen die Punkte auch in der Tinte -- ein Mass in
    // Pixeln waere in den zwei verschieden grossen Fenstern zweierlei.
    function radiere(e) {
      var p = anteil(e);
      if (!p) return;
      var si = tinteFolie(), l = TINTE[si];
      if (!l || !l.length) return;
      var nah = 0.018, weg = null;
      for (var i = l.length - 1; i >= 0 && weg === null; i--) {
        var pt = l[i].punkte || [];
        for (var k = 0; k < pt.length; k++) {
          var dx = pt[k].x - p.x, dy = pt[k].y - p.y;
          if (dx * dx + dy * dy < nah * nah) { weg = l[i].n; break; }
        }
      }
      if (weg !== null) tinteSenden({ b: "radier", s: si, n: weg });
    }

    B.addEventListener("pointerdown", function (e) {
      if (e.button !== 0) return;
      if (MODUS === "radier") {
        RADIERT = 1;
        try { B.setPointerCapture(e.pointerId); } catch (x) {}
        radiere(e);
        e.preventDefault();
        return;
      }
      if (MODUS === "zeiger") {
        var p0 = anteil(e);
        if (!p0 || !drin(p0)) return;
        ZEIGT = 1;
        try { B.setPointerCapture(e.pointerId); } catch (x) {}
        zeigerSenden({ t: "down", x: p0.x, y: p0.y, k: 1 });
        e.preventDefault();
        return;
      }
      MALT = 1; STRICH_NR++; LETZT = null; DRAUSSEN = 0; OFFEN = null; GESETZT = 0;
      // Without capture, the stroke would end as soon as the pointer leaves
      // the stage.
      try { B.setPointerCapture(e.pointerId); } catch (x) {}
      punkt(e);
      e.preventDefault();
    });
    B.addEventListener("pointermove", function (e) {
      if (MODUS === "radier") {
        if (RADIERT) { radiere(e); e.preventDefault(); }
        return;
      }
      if (MODUS === "zeiger") {
        // Only while pressed. A hover would put a message on the wire for
        // every mouse movement across the slide, and nothing in the hall
        // would change because of it.
        if (!ZEIGT) return;
        var pm = anteil(e);
        if (!pm) return;
        zeigerSenden({ t: "move", x: pm.x, y: pm.y, k: 1 });
        e.preventDefault();
        return;
      }
      if (!MALT) return;
      // The browser coalesces fast movements into one event and keeps the
      // in-between points aside. Whoever does not pick them up gets an
      // angular line on a fast drag.
      var liste = e.getCoalescedEvents ? e.getCoalescedEvents() : null;
      if (liste && liste.length) { for (var i = 0; i < liste.length; i++) punkt(liste[i]); }
      else punkt(e);
      e.preventDefault();
    });
    function schluss(e) {
      if (MODUS === "radier") {
        RADIERT = 0;
        try { B.releasePointerCapture(e.pointerId); } catch (x) {}
        return;
      }
      if (MODUS === "zeiger") {
        if (!ZEIGT) return;
        ZEIGT = 0;
        try { B.releasePointerCapture(e.pointerId); } catch (x) {}
        var pe = anteil(e);
        if (pe) zeigerSenden({ t: "up", x: pe.x, y: pe.y, k: 0 });
        return;
      }
      if (!MALT) return;
      // A held-back first point that was never followed by a second was a
      // click and not a stroke. It is dropped.
      MALT = 0; LETZT = null; OFFEN = null; GESETZT = 0;
      try { B.releasePointerCapture(e.pointerId); } catch (x) {}
    }
    B.addEventListener("pointerup", schluss);
    B.addEventListener("pointercancel", schluss);
    // A construction is zoomed with the wheel, and that is worth carrying
    // across too. Not passive, because the page behind it must not scroll
    // along.
    B.addEventListener("wheel", function (e) {
      if (MODUS !== "zeiger") return;
      var p = anteil(e);
      if (!p || !drin(p)) return;
      if (!zeigerRahmen(e.clientX, e.clientY)) return;
      zeigerSenden({ t: "wheel", x: p.x, y: p.y, k: 0, d: e.deltaY });
      e.preventDefault();
    }, { passive: false });
  }

  // ── The clock, four times a second ────────────────────────────────────────
  function sprecherUhr() {
    if (!gebaut) return;
    verbindungStand();
    // Ohne Zieldauer gibt es weder einen Rest noch einen Plan. Statt zweimal
    // einen einsamen Punkt neben einer lauten Marke zu zeigen, verschwinden
    // beide Paare, bis eine Dauer gesetzt ist.
    // Statt zu verschwinden: dastehen und einen Strich zeigen. Wer die
    // Ansicht zum ersten Mal sieht, soll erkennen, *was* dort stehen wird --
    // ein leerer Platz sagt nichts, ein Strich neben seinem Wort alles.
    var gesetzt = ZIEL_MIN > 0 && STEPS.length > 0;
    if (ELN.restPaar) ELN.restPaar.dataset.leer = gesetzt ? "0" : "1";
    if (ELN.taktPaar) ELN.taktPaar.dataset.leer = gesetzt ? "0" : "1";
    // Ohne Sekunden. Am Pult ist der Sekundenzeiger nie die Frage -- die
    // Frage ist, wie viel Zeit noch bleibt --, und eine Zahl, die viermal
    // je Sekunde neu gezeichnet wird, zieht den Blick, ohne ihn zu
    // belohnen. reveal.js zeigt hour und minute und sonst nichts.
    var j = new Date();
    ELN.uhr.textContent = zwei(j.getHours()) + ":" + zwei(j.getMinutes());
    var v = UHR_START ? (Date.now() - UHR_START) / 1000 : 0;
    ELN.zeit.textContent = mmss(v);
    ELN.zeit.dataset.laeuft = UHR_START ? "1" : "0";
    if (ZIEL_MIN > 0 && STEPS.length > 0) {
      var plan = ZIEL_MIN * 60;
      var rest = plan - v;
      ELN.rest.textContent = mmss(rest);
      ELN.rest.dataset.lage = rest < 0 ? "zurueck" : "";
      // As long as the clock stands still, there is no plan to be ahead of
      // or behind. "ahead of plan" would then merely be a consequence of
      // the expected position being zero at zero seconds.
      if (!UHR_START) {
        ELN.takt.textContent = "\u2013:\u2013\u2013";
        ELN.takt.dataset.lage = "";
        return;
      }
      // This is how reveal.js computes it: the elapsed time relative to the
      // planned duration, plotted onto the total step count. The distance
      // between the expected and the actual step, times the time per step,
      // is the lead in seconds.
      var proSchritt = plan / STEPS.length;
      var d = ((current + 1) - v / plan * STEPS.length) * proSchritt;
      var gut = Math.abs(d) < proSchritt;
      ELN.takt.textContent = (gut ? "" : mmss(Math.abs(d)) + " ") +
        (gut ? wort("onplan", "on plan")
             : d > 0 ? wort("ahead", "ahead") : wort("behind", "behind"));
      ELN.takt.dataset.lage = gut ? "" : (d > 0 ? "vor" : "zurueck");
    } else {
      // Ein Strich in der Form, die hier stehen wird, statt eines
      // Mittelpunkts: der las sich neben seinem Wort wie ein
      // Aufzaehlungszeichen und nicht wie ein Wert, der noch fehlt.
      ELN.rest.textContent = "\u2013:\u2013\u2013";
      ELN.rest.dataset.lage = "";
      ELN.takt.textContent = "\u2013:\u2013\u2013";
      ELN.takt.dataset.lage = "";
    }
  }

  // ── After every step ──────────────────────────────────────────────────────
  function sprecherStand() {
    if (ROLLE !== "speaker" || !SPRECHERBOX || !gebaut) return;
    var st = STEPS[current] || { slide: 0, step: 1 };

    var n = notiz(st.slide);
    ELN.notiz.textContent = n || (W.noNote || "no note");
    if (n) delete ELN.notiz.dataset.leer; else ELN.notiz.dataset.leer = "1";

    ELN.fort.textContent = (st.slide + 1) + " / " + SLIDES.length;
    ELN.fortSchritt.textContent = (current + 1) + " / " + STEPS.length;
    // The bar's right edge travels across it, so with less motion asked for
    // it jumps to its new place instead of gliding there. Set here rather
    // than as a media query in the stylesheet, so one predicate answers the
    // question for the whole runtime and the two halves cannot drift apart.
    // The empty string takes the inline value away again and hands the bar
    // back to the rule in the stylesheet.
    ELN.balken.style.transition = wenigerBewegung() ? "none" : "";
    ELN.balken.style.width =
      (STEPS.length < 2 ? 100 : (current * 100 / (STEPS.length - 1))) + "%";

    // The preview costs a clone of the slide. So it is only rebuilt when it
    // is supposed to show something different than it just did.
    var w = weiter(current);
    var schluessel = w.art + "|" + w.slide + "|" + w.step;
    if (schluessel !== VORSCHAU) {
      VORSCHAU = schluessel;
      while (ELN.vorBild.firstChild) ELN.vorBild.removeChild(ELN.vorBild.firstChild);
      if (w.art === "ende") {
        ELN.vorMarke.textContent = wort("next", "next");
        var kasten = bau("div", "ts-sp-ende", ELN.vorBild);
        bau("span", "", kasten).textContent = wort("end", "end of talk");
      } else {
        // Only the number goes behind the label, not the word "slide" a
        // second time: on a slide change it would otherwise literally say
        // "next slide slide 2.1".
        ELN.vorMarke.textContent =
          (w.art === "folie" ? wort("nextSlide", "next slide")
                             : wort("nextStep", "next step"))
          // Ein Mittelpunkt und nicht drei Leerzeichen: die fasst der Browser
          // zu einem zusammen, und dann steht da "NEXT SLIDE 5.1" in einem Zug.
          + " · " + (w.slide + 1) + "." + w.step;
        ELN.vorBild.appendChild(schrittBild(w.slide, w.step));
      }
    }
    ELN.notiz.scrollTop = 0;
    notizStand();
    sprecherUhr();
  }

  // ── Anzeigen ──────────────────────────────────────────────────────────────
  var current = -1;

  function goto(n, instant) {
    // Ein Deck ohne Folien hat keinen Schritt, und `Math.max(0, -1)` machte
    // daraus trotzdem die Null: `STEPS[0]` war `undefined`, und drei Zeilen
    // spaeter starb die ganze Laufzeit an `SLIDES[dst.slide]`. Das Handbuch
    // zeigt an 22 Stellen einen `presentation`-Aufruf fuer sich allein, um
    // eine Einstellung zu erklaeren -- daraus wird eine gueltige leere Seite,
    // und die soll leer sein, nicht tot.
    if (!STEPS.length) return;
    // Ein Sprung raeumt auf, bevor er springt. `finishTransitionNow` haengt
    // sonst allein an `fly`, und `fly` laeuft bei `instant` nicht: Pos1, Ende,
    // ein Wechsel der Adresse oder Vor/Zurueck im Browser gingen daran vorbei.
    // Die alte Animation laeuft mit `fill: "both"` weiter, und sie trifft
    // unter Umstaenden genau die Folie, auf die gesprungen wurde.
    //
    // Nachgestellt, 300 ms nach einem Pos1 mitten in einem Uebergang: die
    // Zielfolie stand bei `translateX(-13.8px)` und 0,70 Deckkraft, die alte
    // lag mit 0,30 darueber, beide noch in Bewegung -- bis der Zeitgeber des
    // alten Uebergangs ablief und es an seinen Platz sprang.
    if (instant) finishTransitionNow();
    n = Math.max(0, Math.min(STEPS.length - 1, n));
    var prev = current < 0 ? null : STEPS[current];
    var dst = STEPS[n];
    var changed = !prev || prev.slide !== dst.slide;
    var back = current > n;
    current = n;

    // Vor allem anderen: was ein Flug hochgezogen hat, gehoert zurueck in
    // seine Folie, bevor irgendjemand dort wieder Elemente sucht.
    nachzueglerZurueck();

    if (changed) stelle(dst.slide);

    var hasMorph = false;
    if (changed && prev && !instant) {
      hasMorph = flugFolie(prev.slide, dst.slide, CFG.duration);
    } else if (!changed && prev && !instant && prev.step !== dst.step) {
      // Derselbe Flug, nur ohne Folienwechsel. `hasMorph` bleibt hier
      // unberuehrt: es entscheidet allein, ob der *Folien*uebergang zur Blende
      // wird, und einen Folienuebergang gibt es auf diesem Weg nicht.
      flugSchritt(dst.slide, prev.step, dst.step, CFG.duration);
    }

    if (changed && prev) {
      mediaOff(prev.slide);
      stopBridges(prev.slide);
      transition(SLIDES[prev.slide], SLIDES[dst.slide], back, instant, hasMorph);
    } else if (!prev) {
      SLIDES.forEach(function (f) { delete f.dataset.on; delete f.dataset.off; });
      SLIDES[dst.slide].dataset.on = "1";
    }

    // The chrome layer follows the slide but does not travel along with
    // it: it sits above the stage and is only faded in and out. Outside
    // the two branches above, because one applies only to the very first
    // slide and the other passes the change on to `transition`.
    CHROME.forEach(function (c, i) {
      if (i === dst.slide) c.dataset.on = "1"; else delete c.dataset.on;
    });
    // Die Leiste wandert nicht mit dem Chrome, sie wächst. `instant` ist der
    // Sprung -- Übersicht, Pos1, Ende, Adresszeile --, und ein Sprung ist
    // keine Fahrt.
    fortschrittStellen(dst.slide, instant);

    SLIDES[dst.slide].querySelectorAll(".ts-el").forEach(function (el) {
      var d = +erbt(el, "duration") || CFG.duration;
      var delay = back ? 0 : (+erbt(el, "delay") || 0);
      // Where the element stands now and where it belongs. `data-on` alone no
      // longer answers the first question: drawn muted is a third state, and
      // it has to be told apart from drawn, or paging back would find nothing
      // to bring up again.
      var war = el.dataset.on !== "1" ? 0 : (el.dataset.dim === "1" ? 1 : 2);
      var wird = zustand(el, dst.step);

      // Entering a slide or jumping into it plays no effects, so the whole run
      // is replayed as state. That is what puts a dimmed element back where it
      // belongs after a reload, after paging in from the other side, and in
      // the speaker view.
      if (instant || changed) { clearAnims(el); ruhe(el, wird); return; }
      if (wird === war) return;
      ruhe(el, wird);

      if (war === 0) {
        // Straight to full is the entrance. Straight to muted only happens on
        // a jump that skipped the whole range, and then the point has no
        // arrival to play: it simply is there, quietly.
        //
        // Rueckwaerts ist der Auftritt eines Wartenden das Spiegelbild des
        // Wartens selbst. Vorwaerts bleibt die abtretende Stufe stehen, bis
        // die neue da ist, und die geteilte Tinte steht die ganze Zeit voll
        // da. Rueckwaerts kommt die *kleinere* Stufe herein, und sie liegt
        // vollstaendig unter der groesseren, die noch abtritt: sie hat nichts
        // zu blenden, sie ist einfach da, und was verschwindet, ist allein
        // die Tinte, die die groessere mehr hat. Blendete sie stattdessen
        // auf, blendeten wieder zwei fast gleiche Bilder gegeneinander --
        // gemessen sank die geteilte Tinte dabei auf 0,7522.
        if (wird === 2) {
          fadeIn(el, back && erbt(el, "exit") === "hold"
                     ? "hold" : (erbt(el, "enter") || "fade-up"), d, delay);
        } else fadeTo(el, 0, DIM, d);
      } else if (wird === 0) {
        var von = war === 1 ? DIM : 1;
        if (back) fadeOut(el, erbt(el, "enter") || "fade-up", d, von);
        else fadeOut(el, erbt(el, "exit") || "fade", d * 0.75, von);
      } else if (wird === 1) {
        fadeTo(el, 1, DIM, d);
      } else {
        fadeTo(el, DIM, 1, d);
      }
    });

    // Die Szenen dieser Folie an den Halt ziehen, der auf diesem Schritt gilt.
    // Nach den Sprites, weil `ruhe` dort gerade die Deckkraft gesetzt hat und
    // eine Szene, die noch gar nicht da ist, nichts zu ziehen hat.
    SLIDES[dst.slide].querySelectorAll(".ts-scene").forEach(function (el) {
      szeneZiehen(el, dst.step, instant || changed);
    });

    // Und die Kamera auf den Ausschnitt, der auf diesem Schritt gilt. Nach
    // `stelle()`, weil sie die Rechtecke der Pins liest, und nach den Sprites,
    // weil ein Pin in einem Sprite erst zaehlt, wenn dieses seinen Platz hat.
    kameraStellen(dst.slide, dst.step, instant || changed);

    mediaOn(dst.slide);
    drive(dst.slide, dst.step, back || changed);
    // The running step belongs in the hash, but only in the talk window.
    // In the speaker window `#speaker` sits there, and that has to stay:
    // whoever reloads wants the speaker view back, not the talk.
    if (ROLLE !== "speaker" && location.hash !== "#" + (n + 1)) {
      history.replaceState(null, "", "#" + (n + 1));
    }
    melde(n);
    sprecherStand();
    tinteStand();
    mark();
    // Before the badges are painted: which points count as named can change
    // with the step, and the badges follow from that.
    adRueck();
    // Last, because `ruhe` above has just written an opacity onto every
    // element: a point still waiting to be called out would otherwise be
    // invisible to the speaker as well, and there is nothing to choose from
    // in an empty column.
    adSprecher();

    // Ganz zuletzt, nachdem Vorschau, Marken und Sprecheransicht oben noch
    // einmal unter der Folie gesucht haben.
    nachzueglerHoch();
  }

  function gotoHash(hash, instant) {
    var value = String(hash || "").replace(/^#/, "");
    var slide = /^slide-(\d+)$/.exec(value);
    if (slide) {
      var wanted = +slide[1];
      for (var i = 0; i < STEPS.length; i++) {
        if (STEPS[i].slide === wanted) { goto(i, instant); return; }
      }
      return;
    }
    var n = +value - 1;
    if (!isNaN(n)) goto(n, instant);
  }

  // ── Slide transitions ─────────────────────────────────────────────────────
  //

  // Where the incoming slide comes from. "right" is the default.
  function shove(from, dist) {
    if (from === "left") return { rein: "translateX(-" + dist + ")",
                                  raus: "translateX(" + dist + ")" };
    if (from === "top") return { rein: "translateY(-" + dist + ")",
                                 raus: "translateY(" + dist + ")" };
    if (from === "bottom") return { rein: "translateY(" + dist + ")",
                                    raus: "translateY(-" + dist + ")" };
    return { rein: "translateX(" + dist + ")", raus: "translateX(-" + dist + ")" };
  }

  // The closed state of a wipe, depending on the edge it starts at.
  function curtain(from) {
    if (from === "right") return "inset(0 0 0 100%)";
    if (from === "top") return "inset(0 0 100% 0)";
    if (from === "bottom") return "inset(100% 0 0 0)";
    return "inset(0 100% 0 0)";
  }

  var OFFEN = "inset(0 0 0 0)";
  var RUND_AUF = "circle(75% at 50% 50%)";
  var RUND_ZU = "circle(0% at 50% 50%)";

  var TRANSITION = {
    "none": null,

    "fade": function () { return {
      rein: [{ opacity: 1 }, { opacity: 1 }],
      raus: [{ opacity: 1 }, { opacity: 0 }], oben: "alt" }; },

    "slide": function (o) {
      var v = shove(o.from, "46px");
      return {
        rein: [{ opacity: 0, transform: v.rein }, { opacity: 1, transform: "none" }],
        raus: [{ opacity: 1, transform: "none" }, { opacity: 0, transform: v.raus }] };
    },

    "push": function (o) {
      var v = shove(o.from, "100%");
      return {
        rein: [{ transform: v.rein }, { transform: "none" }],
        raus: [{ transform: "none" }, { transform: v.raus }] };
    },

    "cover": function (o) {
      var v = shove(o.from, "100%");
      return {
        rein: [{ transform: v.rein }, { transform: "none" }],
        raus: [{ opacity: 1 }, { opacity: 1 }], oben: "neu" };
    },

    "uncover": function (o) {
      var v = shove(o.from, "100%");
      return {
        rein: [{ opacity: 1 }, { opacity: 1 }],
        raus: [{ transform: "none" }, { transform: v.raus }], oben: "alt" };
    },

    "zoom": function (o) {
      var raus = o.direction === "out";
      return {
        rein: [{ opacity: 0, transform: "scale(" + (raus ? 1.18 : 0.82) + ")" },
               { opacity: 1, transform: "none" }],
        raus: [{ opacity: 1, transform: "none" },
               { opacity: 0, transform: "scale(" + (raus ? 0.82 : 1.18) + ")" }] };
    },

    "blur": function () { return {
      rein: [{ opacity: 0, filter: "blur(16px)" }, { opacity: 1, filter: "blur(0px)" }],
      raus: [{ opacity: 1, filter: "blur(0px)" }, { opacity: 0, filter: "blur(16px)" }] }; },

    "iris": function (o) {
      if (o.direction === "close") return {
        rein: [{ opacity: 1 }, { opacity: 1 }],
        raus: [{ clipPath: RUND_AUF }, { clipPath: RUND_ZU }], oben: "alt" };
      return {
        rein: [{ clipPath: RUND_ZU }, { clipPath: RUND_AUF }],
        raus: [{ opacity: 1 }, { opacity: 1 }], oben: "neu" };
    },

    "wipe": function (o) {
      var zu = curtain(o.from);
      if (o.direction === "close") return {
        rein: [{ opacity: 1 }, { opacity: 1 }],
        raus: [{ clipPath: OFFEN }, { clipPath: zu }], oben: "alt" };
      return {
        rein: [{ clipPath: zu }, { clipPath: OFFEN }],
        raus: [{ opacity: 1 }, { opacity: 1 }], oben: "neu" };
    },

    "flip": function (o) {
      var dreh = o.axis === "x" ? "rotateX" : "rotateY";
      return {
        rein: [{ transform: dreh + "(180deg)" }, { transform: dreh + "(0deg)" }],
        raus: [{ transform: dreh + "(0deg)" }, { transform: dreh + "(-180deg)" }],
        d3: true, ruecken: true };
    },

    "cube": function (o, W, H) {
      var quer = o.axis !== "x";
      var dreh = quer ? "rotateY" : "rotateX";
      var K = quer ? W : H;
      var h = "translateZ(" + (-K / 2) + "px) ";
      var v = " translateZ(" + (K / 2) + "px)";
      return {
        rein: [{ transform: h + dreh + "(" + (quer ? 90 : -90) + "deg)" + v },
               { transform: h + dreh + "(0deg)" + v }],
        raus: [{ transform: h + dreh + "(0deg)" + v },
               { transform: h + dreh + "(" + (quer ? -90 : 90) + "deg)" + v }],
        d3: true, ruecken: true };
    }
  };

  function reverse(a) {
    return {
      rein: a.raus.slice().reverse(),
      raus: a.rein.slice().reverse(),
      oben: a.oben === "neu" ? "alt" : (a.oben === "alt" ? "neu" : a.oben),
      d3: a.d3, ruecken: a.ruecken
    };
  }

  function asSpec(x) {
    if (!x) return { kind: "fade" };
    if (typeof x === "string") {
      if (x.charAt(0) === "{") { try { return JSON.parse(x); } catch (e) {} }
      return { kind: x };
    }
    return x;
  }

  function transition(alt, neu, back, instant, hasMorph) {
    neu.dataset.on = "1";
    SLIDES.forEach(function (f) { if (f !== neu) delete f.dataset.on; });

    if (alt.mo_zeit) { clearTimeout(alt.mo_zeit); alt.mo_zeit = null; }
    if (alt.mo_aus) { try { alt.mo_aus.cancel(); } catch (e) {} alt.mo_aus = null; }
    resetStyle(alt); resetStyle(neu);
    delete alt.dataset.off;

    var later = back ? alt : neu;
    var o = asSpec(hasMorph ? "fade"
                               : (attr(later, "transition") || CFG.transition));
    var bau = TRANSITION[o.kind] === undefined ? TRANSITION["fade"] : TRANSITION[o.kind];
    // Asked for less motion, every transition becomes the cross-fade. All the
    // others move the whole slide, and a slide is the largest thing on the
    // screen: `slide` and `push` and `cover` carry it across, `zoom` grows it,
    // `flip` and `cube` turn it, `iris` and `wipe` drag an edge over it. The
    // fade keeps what a transition is actually for, which is to mark the cut
    // between one slide and the next, and it keeps it at the same length.
    // `"none"` stays untouched, because nothing is already what it does.
    if (bau && wenigerBewegung()) bau = TRANSITION["fade"];
    if (instant || !bau) return;

    var d = CFG.transitionDuration;
    var box = B.getBoundingClientRect();
    var kind = bau(o, box.width, box.height);
    if (back) kind = reverse(kind);

    if (kind.d3) {
      B.style.perspective = Math.round(box.width * 1.4) + "px";
      if (kind.ruecken) {
        alt.style.backfaceVisibility = "hidden";
        neu.style.backfaceVisibility = "hidden";
      }
    }
    if (kind.achse) {
      neu.style.transformOrigin = kind.achse.neu;
      alt.style.transformOrigin = kind.achse.alt;
    }
    neu.style.zIndex = kind.oben === "alt" ? "1" : "2";
    alt.style.zIndex = kind.oben === "alt" ? "2" : "1";

    var e = neu.animate(kind.rein, { duration: d, easing: EASE, fill: "both" });
    e.onfinish = function () { try { e.cancel(); } catch (x) {} };

    alt.dataset.off = "1";
    var a = alt.animate(kind.raus, { duration: d, easing: EASE, fill: "both" });
    alt.mo_aus = a;
    var done = function () {
      if (alt.mo_aus !== a) return;
      try { a.cancel(); } catch (x) {}
      try { e.cancel(); } catch (x) {}
      delete alt.dataset.off;
      alt.mo_aus = null;
      alt.mo_zeit = null;
      resetStyle(alt); resetStyle(neu);
      B.style.perspective = "";
    };
    a.onfinish = done;
    alt.mo_zeit = setTimeout(done, d + 80);
  }

  function resetStyle(f) {
    f.style.zIndex = "";
    f.style.transformOrigin = "";
    f.style.backfaceVisibility = "";
  }

  // ── Overview ──────────────────────────────────────────────────────────────
  //
  // A slide as a still thumbnail. Factored out because the speaker view
  // needs the same thing, there for the slide that comes next.
  //
  // Footer and progress no longer sit in `.ts-bg` but in the layer above
  // the stage. For the thumbnail, the print copy that is embedded in every
  // slide anyway is therefore taken along, otherwise the thumbnails would
  // have no page number. What the thumbnail does not show are the animated
  // parts: it always stands at the first step of its slide.
  // Der letzte Schritt einer Folie -- der einzige, auf dem alles steht, was sie
  // ueberhaupt zeigt.
  function letzterSchritt(i) {
    var s = 1;
    for (var k = 0; k < STEPS.length; k++) {
      if (STEPS[k].slide === i && STEPS[k].step > s) s = STEPS[k].step;
    }
    return s;
  }

  // Das Standbild einer Folie fuer die Uebersicht.
  //
  // Frueher stand hier eine eigene, aermere Fassung: sie kopierte `.ts-bg` und
  // sonst nichts. Ein verfolgtes Element haelt dort aber nur seinen Platz --
  // sichtbar wird es erst als Sprite in `.ts-ov` --, und so fehlte in der
  // Uebersicht alles, was `anim`, `stagger`, `morph`, `tiles` oder `scene`
  // beitragen. Auf einer Folie, die im Wesentlichen daraus besteht, blieb eine
  // fast leere Flaeche uebrig, und zwischen zwanzig fast leeren Flaechen
  // findet niemand etwas.
  //
  // `schrittBild` kann das alles laengst -- es baut die Vorschau der
  // Sprecheransicht. Gefragt wird nach dem *letzten* Schritt: die Uebersicht
  // beantwortet "was steht auf dieser Folie", nicht "wo bin ich gerade".
  function miniatur(i) {
    return schrittBild(i, letzterSchritt(i));
  }

  var minis = [];
  function buildOverview() {
    if (minis.length) return;
    SLIDES.forEach(function (f, i) {
      var fach = document.createElement("figure");
      fach.className = "ts-mini-fach";
      var m = miniatur(i);
      // Eine Huelle um die Kachel, damit die Schrittzone darueber liegen kann.
      // Nicht *in* der Kachel: beim Ueberfahren wird deren `innerHTML`
      // ersetzt, und die Zone loeschte sich damit selbst.
      var huelle = document.createElement("div");
      huelle.className = "ts-mini-huelle";
      huelle.appendChild(m);
      fach.appendChild(huelle);
      // Nummer und Titel darunter. Ohne den Namen unterscheiden sich zwei
      // aehnliche Folien im Standbild kaum, und die Nummer ist ohnehin das,
      // wonach im Vortrag gegriffen wird.
      var schild = document.createElement("figcaption");
      schild.className = "ts-mini-schild";
      var nr = document.createElement("b");
      nr.textContent = String(i + 1);
      schild.appendChild(nr);
      var titel = f && f.dataset.titel;
      if (titel) {
        var t = document.createElement("span");
        t.textContent = titel;
        schild.appendChild(t);
      }
      // ── Die Schrittleiste ─────────────────────────────────────────────
      //
      // Eine Kachel zeigt die Folie in ihrem letzten Schritt. Was davor
      // passiert, sieht man in der Uebersicht sonst nicht -- und wer eine
      // bestimmte Stelle sucht, will genau dorthin und nicht an den Anfang
      // der Folie.
      //
      // Die Zone liegt im unteren Drittel der Kachel, ein Feld je Schritt.
      // Die oberen zwei Drittel gehoeren der Folie selbst: ein Klick dort
      // geht an ihren Anfang. So braucht die Uebersicht keine zweite Zeile
      // unter dem Bild, und der Griff nach einem Schritt liegt dort, wo man
      // ohnehin hinsieht.
      //
      // Der Preis: man streift die Zone auf dem Weg zur Kachel. Deshalb ist
      // die Marke *immer* zu sehen und nicht erst beim Ueberfahren -- wer
      // an den Anfang will, sieht vorher, wohin er nicht zielen darf.
      //
      // Eine Folie mit einem Schritt bekommt keine Zone: dort gibt es nichts
      // zu waehlen, und ein Streifen, der immer voll ist, sagt nichts.
      var n = letzterSchritt(i);
      var leiste = document.createElement("div");
      leiste.className = "ts-mini-schritte";
      if (n < 2) {
        leiste.dataset.leer = "1";
      } else {
        // Die Bilder werden erst beim ersten Ueberfahren gebaut und dann
        // behalten. `schrittBild` klont die ganze Folie; das fuer jeden
        // Schritt jeder Folie im Voraus zu tun, zahlte den Preis auch dort,
        // wo niemand hinsieht.
        var bilder = [];
        for (var sN = 1; sN <= n; sN++) {
          (function (sk) {
            var feld = document.createElement("button");
            feld.type = "button";
            feld.className = "ts-mini-schritt";
            feld.dataset.schritt = String(sk);
            feld.title = sk + "/" + n;
            feld.addEventListener("mouseenter", function () {
              if (!bilder[sk]) bilder[sk] = schrittBild(i, sk);
              m.innerHTML = bilder[sk].innerHTML;
            });
            feld.addEventListener("click", function (e) {
              // Wie bei der Kachel: hier erledigt, nicht weiterreichen.
              e.stopPropagation();
              OVERVIEW.removeAttribute("data-on");
              for (var k = 0; k < STEPS.length; k++) {
                if (STEPS[k].slide === i && STEPS[k].step === sk) {
                  goto(k, true); return;
                }
              }
            });
            leiste.appendChild(feld);
          })(sN);
        }
        // Beim Verlassen der Leiste steht wieder das Bild der ganzen Folie da,
        // damit die Uebersicht nach dem Herumfahren nicht durcheinander ist.
        leiste.addEventListener("mouseleave", function () {
          if (!bilder[n]) bilder[n] = schrittBild(i, n);
          m.innerHTML = bilder[n].innerHTML;
        });
        huelle.appendChild(leiste);
      }
      fach.appendChild(schild);
      fach.addEventListener("click", function (e) {
        // Der Klick ist hier erledigt und darf nicht weiter nach oben. Sonst
        // sieht ihn auch der Blätter-Klick am Fenster -- und dessen Wache
        // ("ist die Uebersicht offen?") greift dann nicht mehr, weil die
        // Zeile darunter sie gerade geschlossen hat. Gemessen: ein Klick auf
        // eine Kachel in der rechten Haelfte landete einen Schritt zu weit,
        // einer links blaetterte zurueck und wurde nur von der Untergrenze
        // aufgehalten. Die Folie erschien kurz und wanderte weiter.
        e.stopPropagation();
        OVERVIEW.removeAttribute("data-on");
        for (var k = 0; k < STEPS.length; k++) {
          if (STEPS[k].slide === i) { goto(k, true); return; }
        }
      });
      OVERVIEW.appendChild(fach);
      minis.push(m);
    });
  }
  function mark() {
    if (!minis.length) return;
    var f = STEPS[current].slide;
    for (var i = 0; i < minis.length; i++) {
      if (i === f) minis[i].dataset.hier = "1"; else delete minis[i].dataset.hier;
    }
    // Und in der Leiste der laufenden Folie das Feld des laufenden Schritts.
    // Nur dort: zwei markierte Felder in zwei Folien saehen aus wie zwei
    // Stellen, an denen der Vortrag steht.
    var jetzt = STEPS[current].step;
    OVERVIEW.querySelectorAll(".ts-mini-schritt[data-jetzt]").forEach(function (x) {
      delete x.dataset.jetzt;
    });
    var fach = OVERVIEW.children[f];
    var feld = fach && fach.querySelector(
      '.ts-mini-schritt[data-schritt="' + jetzt + '"]');
    if (feld) feld.dataset.jetzt = "1";
  }

  // ── Scaling ────────────────────────────────────────────────────────────────
  // Wie die Kacheln sich das Fenster teilen.
  //
  // Die laufende Folie ist die Zeichenflaeche und bekommt die groesste
  // Kachel. Sie behaelt dabei ihr Seitenverhaeltnis, und daran haengen zwei
  // Formen:
  //
  //   hoch      -- Folie links, Notiz rechts, die Kachelzeile darunter.
  //                Der Regelfall, und er traegt vom breiten Schirm bis in
  //                ein flaches Fenster hinein: die Notiz steht neben der
  //                Folie und nicht unter ihr, also bleibt unter der Folie
  //                auch kein Streifen uebrig, den man fuellen muesste.
  //   hochkant  -- reicht die Hoehe fuer eine Folie ueber die volle Breite
  //                und bleibt darunter noch Platz fuer eine Notiz, die
  //                diesen Namen verdient, dann legt die Folie sich quer und
  //                die Notiz darunter. Nebeneinander waeren in einem
  //                stehenden Fenster beide unbrauchbar.
  //
  // Die dritte, alte Form (`flach`) gibt es nicht mehr. Sie war noetig,
  // solange die Notiz *unter* der Folie stand: in einem flachen Fenster
  // stand die Folie schon so hoch wie der Leib, und daneben blieb ein
  // grosses Loch. Mit der Notiz *neben* der Folie ist der flache Fall der
  // Regelfall geworden, und eine Form, die nichts mehr zu entscheiden hat,
  // ist eine Form zu viel.
  // Eine Zeile aus Tastenkappen. Die Vorlage nennt Taste und Bedeutung durch
  // einen senkrechten Strich getrennt: wo die Taste aufhoert, kann man nicht
  // raten -- "Ende zum Schluss" faengt mit einem Wort an, das selbst eine
  // Taste ist.
  function tastenzeile(wohin, text) {
    if (!wohin) return;
    while (wohin.firstChild) wohin.removeChild(wohin.firstChild);
    // Nachgemessen bei 1600 Pixeln: die Leiste hat 1572 Pixel Platz. Mit
    // Gruppennamen und Bedeutungen braucht sie 2582, ohne Namen immer noch
    // 2350 -- eine Zeile ist damit nicht zu haben, solange die Bedeutungen
    // dastehen. Nur die Kappen brauchen 856.
    //
    // Also: eine Zeile aus Kappen, nach Gruppen geordnet, und die Bedeutung
    // haengt an der Taste statt neben ihr -- als Titel beim Ueberfahren, und
    // vollstaendig hinter `?`. Eine Reihe, die man nach Form ueberfliegt,
    // statt eines Absatzes, den man liest.
    // Tasten, die zu einer abbestellten Kachel gehoeren, stehen hier nicht.
    // Eine Leiste, die `⇧t` bewirbt, waehrend die Uhr abbestellt ist,
    // erzaehlt dem Vortragenden etwas, das nicht stimmt -- und sie tut es an
    // der einen Stelle, an der er nachsieht, wenn er unsicher ist.
    //
    // Verglichen wird die Beschriftung, wie sie im Hilfetext steht: `⇧← ⇧→`
    // ist *ein* Eintrag mit zwei Tasten, nicht zwei Eintraege.
    var still = {};
    if (SPV.clock === false) {
      still["t"] = 1; still["⇧t"] = 1; still["⇧← ⇧→"] = 1;
    }
    if (SPV.target === false) still["d"] = 1;
    if (SPV.tools === false) {
      still["m"] = 1; still["c"] = 1; still["z"] = 1; still["x"] = 1;
    }
    String(text).split("\u00a7").forEach(function (roh) {
      var t = roh.trim();
      if (!t) return;
      var doppel = t.indexOf(":");
      var name = doppel > 0 ? t.slice(0, doppel).trim() : "";
      var rest = doppel > 0 ? t.slice(doppel + 1) : t;
      var g = bau("div", "ts-sp-gruppe", wohin);
      if (name) bau("span", "ts-sp-gruppe-name", g).textContent = name;
      rest.split("\u00b7").forEach(function (stueck) {
        var e = stueck.trim();
        if (!e) return;
        var teil = e.split("|");
        var tasten = teil.length > 1 ? teil[0].trim() : e;
        var wozu = teil.length > 1 ? teil.slice(1).join("|").trim() : "";
        if (still[tasten]) return;
        var pr = bau("span", "ts-sp-taste-paar", g);
        if (wozu) pr.title = tasten + " \u2014 " + wozu;
        tasten.split(/\s+/).forEach(function (k) {
          if (k) bau("kbd", "ts-sp-kappe", pr).textContent = k;
        });
      });
    });
  }

  function sprecherSpalten() {
    if (ROLLE !== "speaker" || !LEIB || !PLATZ) return;
    var r = LEIB.getBoundingClientRect();
    if (!r.width || !r.height) return;
    var v = CFG.width / CFG.height;

    // Das Raster steht jetzt im Stilblatt: Folie ueber die volle Breite,
    // darunter Notiz und Vorschau, darunter die Werkzeugzeile. Hier bleibt
    // nur, was der Browser nicht von sich aus weiss -- wie hoch die untere
    // Zeile wirklich sein will und wie viel Hoehe die Folie danach hat.
    LEIB.style.maxWidth = "";
    LEIB.style.gridTemplateColumns = "";
    LEIB.style.gridTemplateRows = "";
    // Fuenf Kacheln nebeneinander brauchen Platz, und die fuenfte ist keine
    // Zahl: sie traegt drei Reihen Knoepfe statt einer Ziffer. Bleibt fuer
    // sie weniger als ein knappes Fuenftel, bekommt sie eine eigene Zeile
    // unter den Zahlen und legt sich darin quer -- dort ist Breite im
    // Ueberfluss, waehrend in der Spalte keine mehr war. Gemessen stand die
    // Kachel bei 560 px Fenster auf 102 px, und die Farbfelder ragten 51 px
    // aus ihr heraus.
    //
    // Das steht *vor* dem Messen von `natur`, und das ist keine Kosmetik:
    // die Lage entscheidet mit, wie hoch die Kachelzeile ist -- quer belegt
    // sie eine vierte Rasterzeile. Gemessen wurde sonst die Hoehe der alten
    // Lage und der neuen zugeschrieben. Wer das Fenster schmal zog und
    // wieder breit, bekam eine 212 px hohe Zeile, wo frisch geladen 166
    // standen, und sie blieb so.
    LEIB.dataset.wz = r.width < 780 ? "schmal" : "weit";

    // Die Zahlenzeile selbst gesucht und nicht ueber eine ihrer Kacheln. Ein
    // Deck kann die Uhr abbestellen; ihre Kachel haengt dann an keinem
    // Dokument mehr, `parentNode` ist `null`, und die ganze Hoehenrechnung
    // hier fiel aus. Gemessen: das Werkzeugband ragte 29 px aus dem Fenster.
    var zeile = LEIB ? LEIB.querySelector(".ts-sp-uhren") : null;
    // Breit heisst: die Unterzeile passt neben die grosse Zahl statt darunter.
    // Untereinander verschenkt eine Kachel bei einem breiten Fenster die
    // halbe Flaeche -- die Zahl steht klein in einem grossen Kasten, und
    // rechts davon ist nichts. Nebeneinander wird die Zahl groesser und die
    // Kachel niedriger, und die Folie darueber bekommt, was die Zeile abgibt.
    if (zeile) {
      var k1 = zeile.firstElementChild;
      var breitGenug = k1 && k1.getBoundingClientRect().width >= 215;
      if (breitGenug) zeile.dataset.breit = "1"; else delete zeile.dataset.breit;
    }
    var natur = zeile ? zeile.getBoundingClientRect().height : 0;
    // Das Werkzeugband ist eine eigene Rasterzeile und will eigene Hoehe.
    // Ohne diesen Posten rechnete der Rest so, als gaebe es nur die
    // Zahlenzeile: alle Zeilen zusammen wurden hoeher als der Leib, und die
    // letzte -- das Band -- wurde auf 18 px gedrueckt, waehrend sein Inhalt
    // 64 px mass. Gemessen gleich nach dem Zuruecksetzen der Zeilen: nur
    // jetzt steht das Band auf seiner natuerlichen Hoehe. Die 10 sind der
    // Zeilenabstand des Rasters.
    var band = ELN.wzTraeger
      ? ELN.wzTraeger.getBoundingClientRect().height + 10 : 0;

    // Hochkant heisst hier nur noch: die Vorschau passt nicht mehr neben die
    // Notiz. Die Folie liegt in beiden Faellen oben und quer.
    LEIB.dataset.form = r.width < 520 ? "hochkant" : "hoch";

    // Was die Notiz bekommt: was nach Folie und Kachelzeile uebrig ist,
    // gedeckelt, damit sie in einem hohen Fenster nicht die Folie auffrisst.
    var kr = PLATZ.parentNode.getBoundingClientRect();
    var pr = PLATZ.getBoundingClientRect();
    var randX = Math.max(0, kr.width - pr.width);
    var randY = Math.max(0, kr.height - pr.height);
    var folieHoch = (r.width - randX) / v + randY;
    var uebrig = Math.max(0, r.height - natur - band - 20);
    // Die Folie nimmt hoechstens 72 Prozent -- und laesst der Zeile darunter
    // ausserdem einen Boden. Ohne den schrumpfte die Vorschau in einem
    // kleinen Sprecherfenster auf 27x15 Pixel: ein Bild, das kleiner ist als
    // seine eigene Beschriftung, sagt nichts mehr. Dass es vorher nicht
    // auffiel, lag an einem Fehler, der es zudeckte -- `vorschauBreite` stieg
    // bei zu wenig Platz aus, *ohne* die Masse von vorhin zurueckzunehmen,
    // und liess die Vorschau in ihrer alten Groesse stehen.
    folieHoch = Math.min(folieHoch, uebrig * 0.72,
                         Math.max(0, uebrig - Math.min(152, uebrig * 0.42)));
    var notizHoch = Math.max(0, uebrig - folieHoch);

    // Vier Zeilen: Folie, Notiz, Zahlen, Werkzeuge.
    LEIB.style.gridTemplateRows =
      Math.round(folieHoch) + "px " + Math.round(notizHoch) + "px auto auto";

    // Die Vorschauspalte ist so breit, wie ihr Bild bei dieser Zeilenhoehe
    // sein darf -- dann fuellt es die Kachel ganz, statt oben zu haengen und
    // darunter Luft zu lassen. Die Notiz bekommt den Rest. Gerechnet nach
    // dem Setzen der Zeilen, denn erst jetzt steht die Hoehe fest.
    var vk = ELN.vorBild ? ELN.vorBild.parentNode : null;
    if (vk) {
      var vs = getComputedStyle(vk);
      var vpX = parseFloat(vs.paddingLeft) + parseFloat(vs.paddingRight)
              + parseFloat(vs.borderLeftWidth) + parseFloat(vs.borderRightWidth);
      var vpY = parseFloat(vs.paddingTop) + parseFloat(vs.paddingBottom)
              + parseFloat(vs.borderTopWidth) + parseFloat(vs.borderBottomWidth);
      var vm = ELN.vorMarke ? ELN.vorMarke.getBoundingClientRect().height : 0;
      var bildH = Math.max(0, notizHoch - vpY - vm - 4);
      // Hoechstens die halbe Breite: eine Vorschau, die breiter ist als die
      // Notiz daneben, dreht das Verhaeltnis der beiden um.
      var spalte = Math.min(bildH * v + vpX, r.width * 0.5);
      LEIB.style.gridTemplateColumns =
        "minmax(0,1fr) " + Math.round(Math.max(120, spalte)) + "px";
    }

    vorschauBreite(v);
    notizNachFenster();
    notizStand();
  }

  // Die Vorschau ist ein Blick und keine zweite Buehne. Sie steht in einer
  // Kachel, die ihre Hoehe vorgibt; die Breite folgt daraus. Anders herum --
  // Breite vorgeben, Hoehe folgen lassen, wie bei jeder anderen Miniatur --
  // waere das Bild in einer flachen Kachel hoeher als sein Platz.
  function vorschauBreite(v) {
    if (!ELN.vorBild) return;
    var kachel = ELN.vorBild.parentNode;
    if (!kachel) return;
    // Gerechnet wird aus dem Platz, den die *Kachel* hat, und nicht aus der
    // Hoehe des Bildes: seit beide Masse von hier kommen, waere das der eigene
    // Wert von eben -- beim ersten Mal null, und dann bleibt es null.
    kachel.style.maxWidth = "";
    var st = getComputedStyle(kachel);
    var pX = parseFloat(st.paddingLeft) + parseFloat(st.paddingRight)
           + parseFloat(st.borderLeftWidth) + parseFloat(st.borderRightWidth);
    var pY = parseFloat(st.paddingTop) + parseFloat(st.paddingBottom)
           + parseFloat(st.borderTopWidth) + parseFloat(st.borderBottomWidth);
    var kr = kachel.getBoundingClientRect();
    var marke = ELN.vorMarke ? ELN.vorMarke.getBoundingClientRect().height : 0;
    var platzB = kr.width - pX;
    var platzH = kr.height - pY - marke - 4;      // 4 = margin-top des Bildes
    // Kein Platz mehr: das Bild wird zu null und nicht einfach in Ruhe
    // gelassen. Vorher stieg diese Funktion hier aus, *ohne* die Masse von
    // vorhin zurueckzunehmen -- in einem schrumpfenden Fenster blieb also
    // die alte, grosse Vorschau stehen und ragte aus ihrer Kachel. Gemessen
    // bei 640x480 um 110 px, in beiden Erscheinungsbildern, und das schon
    // vor diesem Umbau: gefunden hat es erst die neue Kachelgrenze in
    // `pult.js`, weil das Bild dabei im Fenster blieb und nur die Kachel
    // verliess.
    if (platzB < 24 || platzH < 14) {
      // Ganz weg und nicht auf null: ein Kasten von null Hoehe hat immer
      // noch ein Bild darin, und dessen Kasten steht dann quer durch die
      // halbe Ansicht -- unsichtbar, weil die Kachel abschneidet, aber
      // vorhanden. `display:none` nimmt auch den Kindern ihre Masse.
      ELN.vorBild.style.display = "none";
      return;
    }
    ELN.vorBild.style.display = "";
    // Das groesste 16:9, das in beides passt. Erst die Hoehe ausreizen, und
    // wo die Breite nicht reicht, von ihr aus zurueckrechnen -- sonst steht
    // ein zu breites Bild in einem zu schmalen Kasten und das Verhaeltnis
    // stimmt nicht mehr.
    var breit = platzH * v, hoch = platzH;
    if (breit > platzB) { breit = platzB; hoch = platzB / v; }
    ELN.vorBild.style.width = Math.round(breit) + "px";
    ELN.vorBild.style.height = Math.round(hoch) + "px";
    // Keine Hoechstbreite mehr von hier: die Spalte ist in `sprecherSpalten`
    // schon so breit gerechnet, wie das Bild bei dieser Zeilenhoehe sein darf.
    // Sie hier noch einmal zu beschneiden hiesse, das eigene Ergebnis von
    // eben zu messen -- die Kachel blieb dann auf 131 Pixeln stehen, und das
    // Bild fuellte ein Drittel ihrer Hoehe.
  }

  function fit() {
    var v = CFG.width / CFG.height;
    // Thumbnails and printed pages hold their shape with padding, which needs
    // the ratio as a number: it is not 16:9 for every deck.
    document.documentElement.style.setProperty(
      "--ts-ratio", (100 / v) + "%");
    sprecherSpalten();
    // In the speaker view the stage does not fill the window but the box
    // reserved for it in the frame. It remains the real stage while doing
    // so: the same slides, the same step, the same drawing layer.
    var r = (ROLLE === "speaker" && PLATZ) ? PLATZ.getBoundingClientRect() : null;
    if (r && (r.width < 20 || r.height < 20)) r = null;
    var raumB = r ? r.width : innerWidth, raumH = r ? r.height : innerHeight;
    var bw = Math.min(raumB, raumH * v);
    B.style.width = bw + "px";
    B.style.height = (bw / v) + "px";
    if (r) {
      B.style.left = (r.left + (r.width - bw) / 2) + "px";
      B.style.top = (r.top + (r.height - bw / v) / 2) + "px";
    }
    // Die Schranke, die die Schwesterstelle im ResizeObserver schon hat: ein
    // Deck ohne Folien hat keinen Schritt null. Das Handbuch zeigt an 22
    // Stellen einen `presentation`-Aufruf fuer sich allein, um eine
    // Einstellung zu erklaeren -- daraus wird eine gueltige, leere Seite, und
    // die darf nicht mit einem Zugriff auf `undefined` sterben.
    if (current >= 0 && STEPS[current]) stelle(STEPS[current].slide);
  }
  addEventListener("resize", fit);

  // A page that comes back from the background is not the page that went
  // away. iOS restores it from its cache without firing a `resize`, and an
  // embedded frame then stands at a scale that no longer matches the stage.
  // Reported from an iPhone and seen in both directions: once the text in
  // the frame came back too large for the slide, once the drawing in it came
  // back at a quarter of its width.
  //
  // The frame is sized in slide points and then zoomed, and the stored
  // measurement decides whether that is written again. If the browser drops
  // the scale but keeps the attribute, the stored measurement says "already
  // correct" and nothing ever repairs it. So it is thrown away here and
  // everything is placed anew.
  function neuVermessen() {
    document.querySelectorAll(".ts-el iframe").forEach(function (f) {
      delete f.dataset.mass;
    });
    fit();
    // And again afterwards. A measurement taken at the moment of the return
    // is not to be trusted: iOS reports a viewport that is still on its way,
    // and a scale computed from it would be written into the frame and stay
    // there. Reported from the phone after the first attempt at this: the
    // drawing then came back small every time instead of only sometimes.
    if (window.requestAnimationFrame) requestAnimationFrame(function () { fit(); });
    setTimeout(fit, 250);
  }

  // The measurement that really settles it. Whatever the reason the stage
  // ends up with a different box, the elements on it are placed again: a
  // rotated phone, a window dragged to another screen, a restored page whose
  // viewport arrived late. An event says *that* something happened, this says
  // *when it is over*, and only the second one can be trusted.
  //
  // No loop: this only places what sits on the stage and never writes the
  // stage's own size. Where the scale comes out the same, the stored
  // measurement stops it before anything is written at all.
  if (window.ResizeObserver) {
    try {
      new ResizeObserver(function () {
        if (current >= 0 && STEPS[current]) stelle(STEPS[current].slide);
      }).observe(B);
    } catch (x) {}
  }
  addEventListener("pageshow", neuVermessen);
  addEventListener("orientationchange", neuVermessen);
  // On `document`, not on the window: that is where the event is defined,
  // and it saves the question of whether it bubbles.
  document.addEventListener("visibilitychange", function () {
    if (!document.hidden) neuVermessen();
  });

  // ── Controls ───────────────────────────────────────────────────────────────
  var hintTimer;
  function hint(t) {
    HINT.textContent = t;
    HINT.dataset.on = "1";
    clearTimeout(hintTimer);
    hintTimer = setTimeout(function () { delete HINT.dataset.on; }, 2600);
  }
  // The speaker view has an input field for the planned duration. A space
  // key inside it is a space character, not a page turn.
  function tippt(e) {
    var t = e.target;
    if (!t || !t.tagName) return false;
    var n = t.tagName.toLowerCase();
    return n === "input" || n === "textarea" || n === "select" || !!t.isContentEditable;
  }

  // ── Adaptive groups ────────────────────────────────────────────────────────
  //
  // Points a class calls out in whatever order they come. Every member of a
  // group carries `data-ad` (its name) and `data-ad-nr` (which point it
  // belongs to); a point and everything tied to it -- a drawing layer, a
  // sentence beside it -- share one number and therefore one step. Swapping
  // the step moves them together, so no separate link is needed.
  //
  // The group owns as many steps as it has points. Which point gets which of
  // them is decided here, at the keyboard; the count never changes, and with
  // it neither the progress bar, nor `info().step.total`, nor the overflow
  // check, nor the handout.
  var AD = {};

  function adSammeln() {
    AD = {};
    // Geschluesselt nach Folie *und* Name, nicht nach Name allein. Eine Gruppe
    // gehoert zu einer Folie, und die Ziffern beginnen auf jeder Folie wieder
    // bei 1 -- zwei gleichnamige Gruppen auf zwei Folien sind zwei Gruppen mit
    // je einer 1. Unter dem blossen Namen verschmolzen sie zu einer, die dann
    // auf der falschen Folie sass und deren zweite Haelfte auf keine Taste
    // mehr hoerte.
    //
    // Die Folie kommt aus dem DOM und nicht aus der Auszeichnung: Typst darf
    // sie nicht mitliefern, weil ein gelesener Folienzaehler in einem
    // gemessenen Element das Dokument um seine Konvergenz braechte. Hier steht
    // sie ohnehin, in `SLIDES`.
    [].forEach.call(document.querySelectorAll(".ts-el[data-ad]"), function (el) {
      var si = SLIDES.findIndex(function (sec) { return sec.contains(el); });
      var name = el.dataset.ad;
      var key = si + "|" + name;
      var g = AD[key]
        || (AD[key] = { name: name, folie: si, reihen: {}, plaetze: [], folge: [] });
      var nr = +el.dataset.adNr;
      (g.reihen[nr] || (g.reihen[nr] = [])).push(el);
      // The step the point was written for. Remembered once, because
      // `data-at` is what gets rewritten below.
      if (!el.dataset.adPlatz) el.dataset.adPlatz = el.dataset.at;
    });
    Object.keys(AD).forEach(function (key) {
      var g = AD[key];
      g.plaetze = Object.keys(g.reihen)
        .map(function (nr) { return g.reihen[nr][0].dataset.adPlatz; })
        .sort(function (a, b) { return parseInt(a, 10) - parseInt(b, 10); });
      g.aus = (STEPS.length + 2) + "-";
    });
    // Nothing has been called out yet, so every point stands aside. Without
    // this the first point would simply appear on its own step, which is the
    // behaviour an adaptive group exists to replace.
    Object.keys(AD).forEach(function (key) { adStellen(key, false); });
    adSprecher();
  }

  // `malen` is false while the deck is being set up: there is no current step
  // yet, and `goto` would have nothing to go to.
  // `schluessel` ist "Folie|Name", nicht der Name: siehe `adSammeln`.
  function adStellen(schluessel, malen) {
    var g = AD[schluessel];
    if (!g) return;
    Object.keys(g.reihen).forEach(function (nr) {
      var p = g.folge.indexOf(+nr);
      var at = p >= 0 ? g.plaetze[p] : g.aus;
      g.reihen[nr].forEach(function (el) { el.dataset.at = at; });
    });
    adSprecher();
    if (malen !== false) goto(current, true);
  }

  // The digits, and only in the speaker view. A point that has not been called
  // out yet is invisible in the hall -- that is the whole idea -- but the
  // speaker has to see what there is to choose from, and which digit picks
  // it. So it stands there pale, with its number in front of it.
  //
  // Written as inline style rather than as a CSS rule, and not out of taste:
  // the stylesheet is embedded in every deck, so a rule would move the
  // typeset fingerprint the deck check keeps per platform -- and the Linux
  // value cannot be re-recorded from here.
  function adSprecher() {
    if (ROLLE !== "speaker") return;
    Object.keys(AD).forEach(function (key) {
      var g = AD[key];
      Object.keys(g.reihen).forEach(function (nr) {
        var offen = g.folge.indexOf(+nr) < 0;
        g.reihen[nr].forEach(function (el, i) {
          if (offen) {
            // Erst die laufende Ueberblendung abbrechen. Ein Punkt, der eben
            // zurueckgenommen wurde, blendet gerade aus, und ihr Abschluss
            // setzt die Deckkraft danach auf 0 -- gemessen stand genau der
            // zuletzt zurueckgenommene Punkt unsichtbar da, waehrend seine
            // Ziffer schon wieder zur Auswahl einlud.
            clearAnims(el);
            el.style.opacity = "0.3";
            el.style.visibility = "visible";
          } else {
            // Nicht auf "" zuruecksetzen: `ruhe` hat die Deckkraft eben als
            // Inline-Stil gesetzt, und ein leerer Wert faellt auf die
            // Stilvorlage zurueck, wo ein Element unsichtbar ist. Gemessen:
            // ein genannter Punkt verschwand, sobald der naechste genannt
            // wurde. Also dieselbe Entscheidung noch einmal treffen.
            var z = zustand(el, STEPS[current] ? STEPS[current].step : 1);
            el.style.opacity = z === 2 ? "1" : (z === 1 ? String(DIM) : "0");
            el.style.visibility = "";
          }
          // One badge per point, on the first member. The layer that travels
          // with it needs no second number.
          // Beside the point, not inside it. A badge inside inherits the
          // element's opacity, and a point waiting to be called stands at 0.3
          // -- measured, the digit was as pale as the text it labels and no
          // help at all. As a sibling it keeps its own strength and takes the
          // point's own left/top, which `setzen` has already written.
          // Nur das erste Mitglied raeumt auf und legt an. Lief das Aufraeumen
          // fuer jedes Mitglied, entfernte die Schicht die Marke, die ihr
          // eigener Punkt gerade angelegt hatte -- gemessen: keine einzige
          // Ziffer im Bild, obwohl jede angelegt worden war.
          if (i > 0) return;
          var eig = el.parentNode
            && el.parentNode.querySelector(':scope > .ts-ad-nr[data-fuer="' + key + "-" + nr + '"]');
          if (eig) eig.remove();
          if (!offen) return;
          var b = document.createElement("span");
          b.className = "ts-ad-nr";
          b.dataset.fuer = key + "-" + nr;
          b.textContent = nr;
          b.style.left = el.style.left;
          b.style.top = el.style.top;
          // An explicit colour, not `currentColor`: beside `color:#fff` in the
          // same declaration that resolves to white, and the badge was white
          // on white -- measured, invisible in the speaker view.
          //
          // Placed inside the element, not to its left: a point sits at the
          // left edge of its column, and anything outside is clipped away.
          var wo = "left:" + (el.style.left || "0") + ";top:" + (el.style.top || "0") + ";";
          b.style.cssText = "position:absolute;" + wo
            + "font:700 0.95em/1.5 system-ui,sans-serif;width:1.5em;"
            + "height:1.5em;border-radius:50%;text-align:center;"
            // Weiss auf fast schwarz misst 18,08 -- die Ziffer soll man
            // lesen, nicht suchen. Der Ring drumherum traegt sie auch auf
            // einer dunklen Folie: dort steht der schwarze Kern sonst auf
            // schwarzem Grund.
            + "background:" + AD_FLAECHE + ";color:" + AD_SATZ + ";opacity:1;"
            + "box-shadow:0 0 0 1.5px #ffffff,0 1px 3px #00000059;"
            // Auf den Aufzaehlungspunkt, nicht daneben: die Ziffer nimmt den
            // Platz des Punktes ein, den sie ohnehin ersetzt, und die Zeile
            // rueckt nicht.
            //
            // Sie war dabei aber zu gross: 1,55em breit bei einem Einzug von
            // 1,19em, und zwischen ihrem rechten Rand und dem ersten
            // Buchstaben blieben zwei Pixel -- gemessen bei 1600x900. Auf
            // 1,3em geschrumpft und um vierzig Prozent nach links geschoben
            // deckt sie den Punkt weiterhin ganz, laesst dem Wort zehn Pixel
            // Luft und ragt dabei nur sechs Pixel in den Rand hinein, wo bei
            // keinem der Themen etwas steht.
            + "pointer-events:none;z-index:5;transform:translate(-40%,6%)";
          if (el.parentNode) el.parentNode.appendChild(b);
        });
      });
    });
  }

  // The other window's assignment. Sent whenever a digit is pressed, so both
  // windows agree on which point took which step -- the reveal itself then
  // falls out of the ordinary step machinery.
  horch("adaptiv", function (d) {
    var g = AD[d.gruppe];
    if (!g || !d.folge) return;
    g.folge = d.folge.slice();
    // Neu zeichnen, aber stumm. Ein gewoehnliches `goto` meldet den eigenen
    // Schritt zurueck, und das ist hier der *alte* -- die Zuordnung kommt vor
    // dem Schritt an. Gemessen: die Halle meldete 4 zurueck, `fernGoto` zog
    // das Sprecherfenster von 5 auf 4, und die Fernsteuerung hinkte fortan
    // einen Schritt hinterher, waehrend die Halle richtig stand.
    stumm++;
    adFrisch = d.gruppe;
    try { adStellen(d.gruppe, true); } finally { stumm--; adFrisch = null; }
  });

  // Backwards takes reveals back, and that is not a nicety: every forward key
  // reveals a point, so without this a group is used up after one pass and
  // offers nothing on the way back -- measured, after four steps back and
  // forward the numbers were gone and every point stood.
  //
  // Before the slide means none, on it means as many as the current step
  // carries, past it means all: the deck reads the same going back as it did
  // going forward.
  // Welche Gruppe gerade eine Zuordnung von drüben bekommen hat. Die
  // Zuordnung reist vor dem Schritt, und ohne diese Ausnahme naehme
  // `adRueck` sie sofort wieder zurueck -- gemessen kam in der Halle nichts
  // mehr an, obwohl beide Nachrichten ankamen.
  var adFrisch = null;

  function adRueck() {
    if (!STEPS[current]) return;
    var si = STEPS[current].slide, schritt = STEPS[current].step;
    Object.keys(AD).forEach(function (schluessel) {
      var g = AD[schluessel];
      if (schluessel === adFrisch) return;
      var erlaubt;
      if (g.folie < 0 || si < g.folie) { erlaubt = 0; }
      else if (si > g.folie) { erlaubt = g.folge.length; }
      else {
        erlaubt = g.plaetze.filter(function (pl) {
          return parseInt(pl, 10) <= schritt;
        }).length;
      }
      if (g.folge.length > erlaubt) {
        g.folge.length = erlaubt;
        adStellen(name, false);
      }
    });
  }

  // A forward key on a slide whose group still has unnamed points takes the
  // next one in written order. That makes an adaptive group a superset of a
  // staggered list rather than a mode beside it: press only arrows and you get
  // the order as written, press a digit and you get that point, and the two
  // mix freely. Without it three keypresses in a row did nothing visible --
  // measured -- which reads as broken even though it was correct.
  function adPfeil() {
    var namen = adHier();
    if (!namen.length) return false;
    var g = AD[namen[0]];
    var offen = Object.keys(g.reihen).map(Number)
      .filter(function (n) { return g.folge.indexOf(n) < 0; })
      .sort(function (a, b) { return a - b; });
    if (!offen.length) return false;
    // Nur vorwärts, und nur wenn die Gruppe an der Reihe ist. `platz <= hier`
    // haelt sie zurueck, wenn jemand ueber den Hash oder `End` hinter sie
    // gesprungen ist -- mit dem Pfeil soll er nicht rueckwaerts hineinfallen.
    // `platz > hier + 1` haelt sie zurueck, solange vor ihr noch gewoehnliche
    // Schritte stehen: dann faellt der Tastendruck durch und `goto(current+1)`
    // blaettert einen Halt weiter, bis ihr erster Punkt der naechste Halt ist.
    //
    // Ohne die zweite Haelfte greift die Gruppe auf *jedem* Schritt davor, und
    // `adTaste` springt auf den Schritt ihres Punktes -- gemessen an einem Deck
    // mit zwei Fragen und einem Zahlenstrahl vor der Gruppe: ein Pfeil von
    // Schritt 1 landete auf 4 und verschluckte beide Halte dazwischen. Solange
    // jede Probe ihre Gruppe auf Schritt 1 beginnen liess, war der Fehler nicht
    // zu sehen, weil dort der erste Punkt zufaellig der naechste Halt ist.
    var platz = parseInt(g.plaetze[g.folge.length], 10);
    var hier = STEPS[current].step;
    if (platz <= hier || platz > hier + 1) return false;
    return adTaste(offen[0]);
  }

  // Which groups are on the slide the deck is standing on.
  // Gibt Schluessel zurueck, keine Namen -- alles, was damit weiterarbeitet,
  // greift auf `AD` zu.
  function adHier() {
    var sec = SLIDES[STEPS[current].slide];
    return Object.keys(AD).filter(function (schluessel) {
      return Object.keys(AD[schluessel].reihen).some(function (nr) {
        return AD[schluessel].reihen[nr].some(function (el) { return sec.contains(el); });
      });
    });
  }

  // A digit reveals that point of the group on this slide. Pressed again it
  // does nothing: taking a point back is what paging backwards is for.
  function adTaste(ziffer) {
    var namen = adHier();
    if (!namen.length) return false;
    var g = AD[namen[0]];
    if (!(ziffer in g.reihen)) return false;
    if (g.folge.indexOf(ziffer) >= 0) return false;
    g.folge.push(ziffer);
    adStellen(namen[0], false);
    // Und in das andere Fenster. Ohne das kennt die Halle die Zuordnung nicht:
    // sie geht auf den Schritt, den der Sprecher meldet, hat dort aber jeden
    // Punkt beiseitegestellt und zeigt nichts. Gemessen -- in der Halle blieb
    // jeder Punkt auf dem Ausweichbereich, waehrend im Sprecherfenster alles
    // richtig stand.
    sende("adaptiv", { gruppe: namen[0], folge: g.folge.slice() });
    // And go there. Naming a point and then having to press onwards would be
    // two moves for one thought; the step is the one the point just took, so
    // the count and the progress bar say the same as before.
    //
    // `data-at` counts steps *within the slide*, `goto` takes the index over
    // the whole deck. Confusing the two was measured to jump to slide one on
    // any deck with more than a single slide -- and a one-slide test deck
    // cannot tell the difference, because there the two numbers agree.
    var lokal = parseInt(g.plaetze[g.folge.length - 1], 10);
    var si = STEPS[current].slide;
    for (var k = 0; k < STEPS.length; k++) {
      if (STEPS[k].slide === si && STEPS[k].step === lokal) { goto(k, false); break; }
    }
    return true;
  }

  addEventListener("keydown", function (e) {
    if (tippt(e)) return;
    // Umschalt und Pfeil verlaengern die laufende Vollbilduhr, statt zu
    // blaettern. `uhrSaalMehr` gibt `false`, wenn keine laeuft -- im
    // Buehnenfenster nie eine, gefuehrt wird sie drueben --, und dann faellt
    // die Zeile durch: Umschalt und Pfeil blaettern wie eh und je.
    if (e.shiftKey && (e.key === "ArrowRight" || e.key === "ArrowLeft")
        && uhrSaalMehr(e.key === "ArrowRight" ? 60 : -60)) {
      e.preventDefault(); return;
    }
    if (/^[1-9]$/.test(e.key) && adTaste(+e.key)) { e.preventDefault(); return; }
    if (e.key === "ArrowRight" || e.key === "PageDown" || e.key === " ") {
      if (!adPfeil()) goto(current + 1);
      e.preventDefault();
    }
    else if (e.key === "ArrowLeft" || e.key === "PageUp") { goto(current - 1); e.preventDefault(); }
    else if (e.key === "Home") goto(0, true);
    else if (e.key === "End") goto(STEPS.length - 1, true);
    else if (e.key === "o" || e.key === "Escape") {
      buildOverview();
      if (OVERVIEW.dataset.on) OVERVIEW.removeAttribute("data-on");
      else { OVERVIEW.dataset.on = "1"; mark(); }
    } else if (e.key === "f") {
      if (document.fullscreenElement) document.exitFullscreen();
      else document.documentElement.requestFullscreen();
    } else if (e.key === "?") {
      // Im Balken als Fliesstext: die Trennzeichen der Vorlage werden zu
      // Zwischenraum, der Gruppenname bleibt stehen.
      hint(String((ROLLE === "speaker" && CFG.words.helpSpeaker)
                  || CFG.words.help).replace(/\|/g, " ").replace(/\s*\u00a7\s*/g, "   "));
    }
    // The second window. The keypress is at the same time the user
    // gesture, without which the popup blocker would swallow
    // `window.open`.
    else if (e.key === "n") { oeffneSprecher(); }
  });
  addEventListener("click", function (e) {
    // In the speaker view, `#ts-speaker` covers the stage. A click there
    // applies to whatever gets built into it and should not also page
    // forward on the side.
    if (ROLLE === "speaker") return;
    if (OVERVIEW.dataset.on) return;
    if (e.target.closest && e.target.closest(".ts-embed")) return;
    // A click on a link follows the link. Paging as well would leave the
    // talk on a different slide than the one the speaker pointed at.
    if (e.target.closest && e.target.closest("a")) return;
    goto(current + (e.clientX < innerWidth * 0.25 ? -1 : 1));
  });
  // ── Swiping ───────────────────────────────────────────────────────────────
  //
  // A phone has no arrow keys. Tapping already pages, because a tap raises a
  // click, but a swipe is the gesture people reach for there, and doing
  // nothing at all is the wrong answer.
  //
  // The direction is the natural one: the finger pushes the slide out of the
  // frame towards the left, so the next one comes in behind it. That matches
  // what the slide transition does anyway.
  //
  // In the speaker view the finger draws on the stage, so a swipe there must
  // not page. Outside the stage it may: the note and the preview are a fine
  // place to swipe on a tablet.
  var WISCH = null;

  function wischErlaubt(z) {
    if (OVERVIEW.dataset.on) return false;
    if (!z || !z.closest) return true;
    if (z.closest(".ts-embed")) return false;
    if (ROLLE === "speaker" && z.closest("#ts-stage")) return false;
    // In the speaker view almost everything has a meaning of its own, from
    // the colour swatch to the input field. A tap must not page there, a
    // swipe may; the check further down separates the two.
    return true;
  }

  addEventListener("touchstart", function (e) {
    // Zwei Finger sind ein Zoom und keine Geste von uns.
    if (e.touches.length !== 1 || !wischErlaubt(e.target)) { WISCH = null; return; }
    var t = e.touches[0];
    WISCH = { x: t.clientX, y: t.clientY, zeit: Date.now() };
  }, { passive: true });

  addEventListener("touchmove", function (e) {
    if (WISCH && e.touches.length !== 1) WISCH = null;
  }, { passive: true });

  addEventListener("touchend", function (e) {
    if (!WISCH) return;
    var t = e.changedTouches[0], a = WISCH;
    WISCH = null;
    if (!t) return;
    var dx = t.clientX - a.x, dy = t.clientY - a.y, dauer = Date.now() - a.zeit;
    // The threshold grows with the device: 48 pixels are a swipe on a
    // phone and a twitch on a large tablet.
    var genug = Math.max(48, innerWidth * 0.07);
    var wisch = dauer <= 900 && Math.abs(dx) >= genug
                && Math.abs(dx) >= Math.abs(dy) * 1.3;
    // A tap has to be handled here as well and must not be left to the
    // click.
    //
    // On an iPhone tapping did nothing at all, while the same spot paged in
    // Chrome. The reason is not ours: iOS Safari only builds a click out of
    // a touch if the element it hit strikes it as clickable, that is a link,
    // a button, a form field or something with a click listener of its own.
    // The stage is none of those, and a listener on the window therefore
    // never hears that click. An emulated phone in Chrome does not show
    // this, because Chrome always builds the click.
    var tipp = !wisch && dauer <= 500
               && Math.abs(dx) < 12 && Math.abs(dy) < 12
               && ROLLE !== "speaker";
    if (!wisch && !tipp) return;
    // `preventDefault` holds back the click a browser would otherwise build
    // afterwards out of the same touch. Without it the gesture would still
    // be right, but the click would page a second time right after.
    e.preventDefault();
    if (wisch) { goto(current + (dx < 0 ? 1 : -1)); return; }
    goto(current + (t.clientX < innerWidth * 0.25 ? -1 : 1));
  }, { passive: false });

  addEventListener("touchcancel", function () { WISCH = null; }, { passive: true });

  addEventListener("hashchange", function () {
    // In the speaker window the hash is the role, not a step number. It is
    // neither written nor read there.
    if (ROLLE === "speaker") return;
    gotoHash(location.hash, true);
  });

  fit();
  // Before the first `goto`, because the very first step already has to know
  // whether a point of an adaptive group has been called out yet -- none has,
  // so all of them stand aside until a digit says otherwise.
  adSammeln();
  // The speaker view starts at the first slide and waits for the talk to
  // tell it where it stands. The talk itself takes the number from the
  // hash, this one time and never again after that.
  if (ROLLE === "speaker") goto(0, true);
  else if (location.hash && /^#slide-\d+$/.test(location.hash)) {
    gotoHash(location.hash, true);
  } else {
    goto(Math.max(0, (+location.hash.slice(1) || 1) - 1), true);
  }
  // After the first `goto`, so `schwarzMedien` knows the slide, and still
  // before the first frame: that way the hall stays dark instead of
  // briefly flashing.
  sichtErinnern();
  sprecherAufbau();
  anmeldeSchleife();

  window.typstage = {
    goto: goto, steps: STEPS, slides: SLIDES,
    state: function () { return current; },
    geo: vermessen, build: CFG.build,

    // ── Second window ────────────────────────────────────────────────────
    // `rolle` is "stage" or "speaker" and is fixed from load time on.
    // `box` is the empty container of the speaker view, `ink` the layer
    // above the stage in the talk window where outside content may be drawn.
    rolle: ROLLE,
    box: SPRECHERBOX,
    // Die Vollbilduhr von aussen, in Sekunden. An der Tastatur haengt sie in
    // der Sprecheransicht; wer sie ohne zweites Fenster stellen will -- ein
    // Prueflauf, ein eigenes Knopfwerk neben dem Deck --, nimmt diese drei.
    clock: { start: function (sek) { uhrStellen(sek); },
             stop: uhrAus, set: uhrDauer },
    ink: INK,
    miniatur: miniatur,
    notiz: notiz,
    weiter: weiter,
    oeffneSprecher: oeffneSprecher,
    kanal: {
      sende: sende, strom: strom, horch: horch,
      partner: partner, anmelden: anmelden,
      verbunden: function () { return !!partner(); }
    },

    // ── Speaker view ────────────────────────────────────────────────────────
    // For measuring, and for anything from outside that wants at it.
    sprecher: {
      zeit: function () { return UHR_START ? (Date.now() - UHR_START) / 1000 : 0; },
      ziel: function (m) {
        if (m == null) return ZIEL_MIN;
        ZIEL_MIN = Math.max(0, +m || 0);
        if (ELN.ziel) ELN.ziel.value = ZIEL_MIN ? String(ZIEL_MIN) : "";
        sprecherUhr();
        return ZIEL_MIN;
      },
      striche: function (i) { return TINTE[i == null ? tinteFolie() : i] || []; },
      malen: tinteSenden,
      farbe: function (i) { if (i != null) farbeSetzen(i); return FARBEN[FARBE]; },
      schwarz: function () { return !!SCHWARZ; },
      frost: function () { return !!EIS; },
      eingefroren: function () { return !!FROST; },
      notizPx: function () { return NOTIZ_PX; },
      platz: function () { return PLATZ; },
      bild: schrittBild
    },

    // ── Check surface, part two: the agreed report ──────────────────────────
    //
    // A check run should not have to reach into the runtime. Everything one
    // needs sits here, behind a version number, so a script notices when it
    // meets a deck older than itself instead of quietly measuring nothing.
    //
    // There is no build switch on this. A switch would mean checking a
    // runtime that is not the one shipped, which is the one thing a check may
    // never do. Measured on the six example decks it costs under one percent
    // of the compressed page.
    pruef: {
      // Zwei, seit `ziffer`, `punkt` und `adaptiv` dazugekommen sind. Ein Lauf,
      // der eine cue-Gruppe bedienen will, muss ein Deck von gestern daran
      // erkennen koennen -- sonst misst er dort still 0/0 und nennt es heil.
      //
      // Drei, seit `clock` dazugekommen ist, aus demselben Grund: ein Lauf,
      // der die Vollbilduhr misst, faende an einem Deck von gestern schlicht
      // `undefined` vor und koennte das nicht von einer Uhr unterscheiden,
      // die nicht laeuft.
      fassung: 3,
      bau: CFG.build,
      deck: DECK,
      rolle: ROLLE,
      folien: SLIDES.length,
      schritte: STEPS.length,
      elemente: document.querySelectorAll(".ts-el").length,

      // Where the talk stands. `schritt` counts from zero like `goto`, `hash`
      // is the number in the address, which counts from one.
      stand: function () {
        var st = current >= 0 ? STEPS[current] : null;
        return {
          schritt: current, hash: current + 1,
          folie: st ? st.slide : -1, aufFolie: st ? st.step : -1,
          // Drawn and drawn-muted are counted apart. Whoever only asks "is it
          // there" does not see it when `after: "dimmed"` stops dimming.
          //
          // Twice, over two different areas, because they answer two
          // questions. Over the whole deck the numbers carry the history: a
          // slide left behind keeps its sprites drawn, so the count grows as
          // the talk walks on, and a sprite that changes on a slide nobody is
          // looking at shows up in it. Over the running slide alone they are
          // the state, and only that one can be held against a fresh jump
          // into the same step, which has no history behind it.
          sichtbar: document.querySelectorAll('.ts-el[data-on="1"]').length,
          gedimmt: document.querySelectorAll('.ts-el[data-dim="1"]').length,
          folieSichtbar: st
            ? SLIDES[st.slide].querySelectorAll('.ts-el[data-on="1"]').length : 0,
          folieGedimmt: st
            ? SLIDES[st.slide].querySelectorAll('.ts-el[data-dim="1"]').length : 0,
          flieger: FLUG,
          // Wie viele Pfade sich seit dem Laden selbst gezeichnet haben. Ein
          // laufender Zaehler, aus demselben Grund wie `flieger`: am DOM
          // abgelesen waere die Zahl davon abhaengig, wann jemand fragt.
          feder: FEDER,
          // Und die Gegenprobe im Ruhezustand: kein Pfad darf noch eine Feder
          // tragen. Bleibt eine stehen, ist ein Strich auf halber Strecke
          // eingefroren -- sichtbar waere das erst bei dem einen Deck, das den
          // Sprung genau dorthin macht.
          // Nur auf der Buehne gezaehlt und nicht im ganzen Dokument: die
          // Sprecheransicht haelt daneben ein Standbild des naechsten
          // Schritts, und ein Standbild ist kein Zustand.
          federOffen: (B || document).querySelectorAll("[data-ts-feder]").length,
          fehler: FEHLER.length
        };
      },
      fehler: function () { return FEHLER.slice(); },

      // Was die Vollbilduhr zeigt, oder `null`, wenn keine laeuft.
      //
      // `remaining` sind Sekunden und darf negativ sein -- das ist die
      // Ueberzeit. `text` ist, was an der Wand steht, ohne die freigehaltene
      // Vorzeichenspalte: `2:41` oder `+1:11`. Beide kommen aus `beat`, also
      // faellt die Uhr unter `pruef.uhr()` still und derselbe Zeitpunkt gibt in
      // zwei Laeufen dieselbe Zahl.
      clock: function () {
        var u = uhrStand();
        return u && { mode: u.mode, duration: u.duration,
                      remaining: u.remaining, over: u.over, text: u.text };
      },

      // ── Eine cue-Gruppe von aussen bedienen ──────────────────────────────
      //
      // Die Ziffern einer adaptiven Gruppe liegen an der Tastatur, und ein
      // Prueflauf hat keine Hand. `goto()` allein loest sie nicht aus: es geht
      // auf einen Schritt, aber es nennt keinen Punkt, und ein nicht genannter
      // Punkt steht auf `g.aus` -- weit hinter dem letzten Schritt des Decks.
      // Eine cue-Folie meldete deshalb im Decklauf durchgehend 0/0, und was an
      // ihr neu ist, war ungeprueft. Gemessen an examples/vortragen.typ: 13
      // seiner 44 Schritte sah der Lauf gar nicht.
      //
      // Drei Griffe, und alle drei tun genau, was die Tastatur tut.
      // `ziffer(n)` ist die Zifferntaste: sie nennt den Punkt n der Gruppe auf
      // der laufenden Folie und geht auf dessen Schritt. `punkt()` ist der
      // Pfeil: er nimmt den naechsten in geschriebener Reihenfolge. Beide
      // geben zurueck, ob etwas genannt wurde -- `false` heisst, dass hier
      // keine Gruppe steht oder der Punkt schon gefallen ist, und dann bleibt
      // dem Aufrufer das gewoehnliche Weiterblaettern.
      //
      // Zuruecknehmen steht hier nicht: das ist das Zurueckblaettern, und
      // `goto()` besorgt es von selbst (`adRueck`).
      ziffer: function (n) { return adTaste(+n); },
      punkt: function () { return adPfeil(); },

      // Was die Gruppen gerade zeigen, damit ein Lauf weiss, ob er zu bedienen
      // hat und mit welcher Ziffer. `nummern` sind alle Punkte in
      // geschriebener Reihenfolge, `folge` die schon genannten in der
      // Reihenfolge, in der sie fielen, `plaetze` die Schritte innerhalb der
      // Folie, die die Gruppe zu vergeben hat.
      adaptiv: function () {
        return Object.keys(AD).map(function (key) {
          var g = AD[key];
          return {
            name: g.name, folie: g.folie,
            nummern: Object.keys(g.reihen).map(Number)
              .sort(function (a, b) { return a - b; }),
            plaetze: g.plaetze.slice(),
            folge: g.folge.slice()
          };
        });
      },

      // Pin the wall clock, or hand it back with no argument.
      // A number or nothing. Without the check `uhr("abc")` pins the clock to
      // NaN and every flipbook shows nonsense until someone calls `uhr()`.
      // Wechselt die Uhr die Art -- Wanduhr gegen festgenagelt --, faengt
      // jedes laufende Daumenkino von vorn an. Sein Startstempel steht in der
      // Zeit, die vorher galt, und in der neuen ist er eine beliebige Zahl.
      // Das Weiterstellen einer schon festgenagelten Uhr laesst ihn stehen:
      // genau daran misst ein Prueflauf, dass das Kino ueberhaupt laeuft.
      uhr: function (ms) {
        var vorher = PRUEFUHR;
        if (ms == null) { PRUEFUHR = null; }
        else {
          var n = +ms;
          if (!isFinite(n)) { throw new TypeError("typstage: uhr() takes a number of milliseconds, or nothing"); }
          PRUEFUHR = n;
        }
        if ((vorher === null) !== (PRUEFUHR === null)) {
          ticking.forEach(function (t) { t.t0 = null; t.letztes = -1; });
          uhrZeitwechsel();
        }
        return PRUEFUHR;
      },

      // Resolves once no animation is running anymore. This is what replaces
      // a fixed wait, which is either too short on a loaded machine or wasted
      // everywhere else, and either way makes a run depend on the day.
      // Resolves with "ruhig", or with "frist" if the deadline ran out while
      // something was still moving, so a run can tell the two apart instead
      // of trusting a settled screen it never saw.
      //
      // It waits for animations and for nothing else. A change that a plain
      // `setTimeout` makes later, such as the fly layer being emptied, is not
      // covered; whoever needs that has to ask at a moment that does not
      // depend on it.
      ruhig: function (frist) {
        var ende = Date.now() + (frist == null ? 4000 : frist);
        return new Promise(function (fertig) {
          (function runde() {
            var alle = document.getAnimations ? document.getAnimations() : [];
            var laeuft = alle.filter(function (a) { return a.playState === "running"; });
            if (!laeuft.length || Date.now() > ende) {
              // Two frames after the last animation, so the styles it left
              // behind have been applied before anyone measures. With a
              // timer beside them, because a hidden tab stops handing out
              // frames altogether -- measured, the promise then never
              // settled and the caller waited for ever. A deadline that only
              // covers the loop and not the way out is no deadline.
              var raus = false;
              var fertigEinmal = function (wie) {
                if (raus) return;
                raus = true;
                fertig(wie);
              };
              setTimeout(function () { fertigEinmal("keine-bilder"); }, 250);
              requestAnimationFrame(function () {
                requestAnimationFrame(function () {
                  fertigEinmal(Date.now() > ende && laeuft.length ? "frist" : "ruhig");
                });
              });
              return;
            }
            Promise.race([
              Promise.all(laeuft.map(function (a) { return a.finished; }))
                .catch(function () {}),
              new Promise(function (r) { setTimeout(r, 120); })
            ]).then(runde);
          })();
        });
      }
    }
  };
})();
