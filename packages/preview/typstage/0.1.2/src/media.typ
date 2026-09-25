// Video, embedded documents and Typst-drawn animation, plus what takes their
// place on paper.

#import "internal.typ": (track, fit-verbot, html-output, name-of, nackt,
                         slide-counter)
#import "config.typ": doc-word

/// The box that stands in for a moving element in the PDF.
///
/// `fallback` is arbitrary content: a CeTZ drawing, an image, a table. Left
/// out, a labelled placeholder remains. `link` goes underneath and is
/// clickable in the PDF: whoever holds the handout gets to the live thing.
///
/// Labelled `<ts-media-fallback>`. The outer block is only a container and
/// carries no surface of its own; the grey box that appears when no
/// `fallback` was given is `<ts-media-fallback-empty>` and has one.
#let fallback-box(fallback, link-target, width, height, label) = [#block(
  width: width, height: height, {
    let main = if link-target == none { 100% } else { 88% }
    if fallback != none {
      block(width: 100%, height: main, align(center + horizon, fallback))
    } else {
      set block(fill: luma(95%), stroke: 0.5pt + luma(80%), radius: 4pt)
      [#block(width: 100%, height: main,
              align(center + horizon, text(size: 0.75em, fill: luma(45%), label)))
       <ts-media-fallback-empty>]
    }
    if link-target != none {
      align(center, text(size: 0.62em, fill: luma(45%),
                         link(link-target, link-target)))
    }
  },
) <ts-media-fallback>]

// Media offsets are seconds in the original source, not step numbers.
#let media-range(start, end, loop) = {
  assert(start == none or ((type(start) == int or type(start) == float)
    and start >= 0 and start < calc.inf), message:
    "typstage: start must be a finite, non-negative number of seconds.")
  assert(end == none or ((type(end) == int or type(end) == float)
    and end > (if start == none { 0 } else { start }) and end < calc.inf), message:
    "typstage: end must be a finite number of seconds greater than start, or none.")
  assert(loop == none or type(loop) == bool, message: "typstage: loop must be true or false.")
}

/// A real HTML5 video over the slide.
///
/// Without a `poster:` the placeholder on paper is labelled
/// `<ts-media-poster>`.
///
/// `ends-at` makes the video end at a time of day rather than start at one:
/// give it `"08:15"` and the runtime reads the video's own length when the
/// slide comes up and starts it far enough in that its last frame falls on
/// that minute. A music video before the lesson thus ends as the lesson
/// begins, whenever the room was opened.
///
/// - Further away than the video is long: it waits on its first frame and
///   starts by itself when its moment comes.
/// - More than an hour away, or unreadable: the plan is dropped and the video
///   plays from the start, exactly as before.
/// - `auto` takes the time from `room: (bell: "08:15")`, so moving a lesson
///   from the first period to the third is one line and not one per video.
///
/// The time is the room's wall clock, not stage time: blacking out and coming
/// back re-computes rather than resumes, since forty seconds of black would
/// otherwise move the end by forty seconds.
#let video(
  src,
  width: 100%,
  height: 200pt,
  poster: none,
  autoplay: true,
  loop: false,
  start: 0,
  end: none,
  muted: true,
  controls: false,
  radius: 0pt,
  at: "1-",
  enter: "fade",
  ends-at: none,
) = {
  media-range(start, end, loop)
  assert(ends-at == none or ends-at == auto
         or (type(ends-at) == str and ends-at.match(regex("^[0-9]{1,2}:[0-5][0-9]$")) != none
             and int(ends-at.split(":").first()) <= 23),
    message: "typstage: video(ends-at: …) is a time of day as \"HH:MM\" on a "
      + "24-hour clock, `auto` for the deck's room.bell, or none. Not "
      + repr(ends-at))
  track(
    "video",
    box(width: width, height: height, clip: true, radius: radius,
        if poster == none {
          set rect(fill: luma(92%))
          [#rect(width: 100%, height: 100%) <ts-media-poster>]
        } else {
          { set image(width: 100%, height: 100%, fit: "cover"); poster }
        }),
    at: at,
    extra: (src: src, autoplay: autoplay, loop: loop, start: start, end: end, muted: muted,
            controls: controls, radius: radius.pt(), enter: enter,
            // `auto` reist als das WORT "auto" und nicht als der Wert: der
            // Wert fiele in `sprite-markup` still aus `extra` heraus, das
            // Attribut erschiene nie, und das Video spielte von vorn, ohne
            // dass irgendwo etwas meldet. Aufgelöst wird es drüben gegen
            // `room.bell`, denn hier ist die Präsentation nicht zu sehen.
            ends-at: if ends-at == auto { "auto" } else { ends-at }),
  )
}

/// HTML audio from a local file beside the HTML or a direct HTTP(S) media URL.
/// Playback is controlled on stage or through the presenter; PDF shows a label.
#let audio(
  src,
  width: 240pt,
  height: 32pt,
  autoplay: false,
  loop: false,
  start: 0,
  end: none,
  muted: false,
  controls: true,
  at: "1-",
  enter: "fade",
) = {
  media-range(start, end, loop)
  assert(type(src) == str and src != "", message:
    "typstage: audio() wants a file path or direct audio URL.")
  track("audio",
    fallback-box(none, none, width, height, [Audio]),
    at: at,
    extra: (src: src, autoplay: autoplay, loop: loop, start: start, end: end, muted: muted,
            controls: controls, enter: enter),
  )
}

// What gets prepended to every embedded document so it behaves like a
// part of the slide instead of a web page in a hole.
//
// Two lines, without which `height: 100%` in the document reaches into
// nothing: a percentage measure needs a height on the parent, and `body`
// has none by default. The frame then ends up as tall as its content and
// sticks to the top of the box, leaving the rest of the given height
// empty.
//
// And the font size: in a zoomed frame, a CSS pixel is exactly one point
// of the slide, the runtime's zoom takes care of that. So the base font
// carries the same number as the deck's, and everything inside sized in
// `em` grows with the slides. Without zoom, the frame spans real screen
// pixels: then the same number would be arbitrary, and it stays at the
// browser's.
//
// Everything sits *before* the document, so that its own `<style>` wins.
#let grundstil(doc, zoom, an) = {
  if doc == none or not an { return doc }
  let regeln = (
    "html,body{height:100%;margin:0}",
    "body{background:transparent}",
  )
  if zoom {
    let farbe = if type(text.fill) == color { text.fill.to-hex() } else { "inherit" }
    // `text.font` is sometimes a string, sometimes a list: both occur.
    let familien = if type(text.font) == str { (text.font,) } else { text.font }
    let stapel = familien.map(f => "\"" + f + "\"") + ("system-ui", "sans-serif")
    regeln.push("body{font-family:" + stapel.join(",")
                + ";font-size:" + str(calc.round(text.size.pt(), digits: 2)) + "px"
                + ";line-height:1.4;color:" + farbe + "}")
  }
  "<style>" + regeln.join("") + "</style>" + doc
}

/// Arbitrary web content in a sandboxed frame.
///
/// `bridge` names the element so step jobs can be sent to it: that is how
/// `geogebra` drives its applet, and how a companion package of your own would
/// drive anything else, without the core knowing what is inside.
///
/// `fallback` and `link` only take effect in paged output; in the browser the
/// embedded document itself stands there.
///
/// `style` gives a document passed as `html` the deck's basic style: it fills
/// the frame, is transparent, and carries the running text size. Switched off,
/// the frame is a blank browser page again.
#let embed(
  url: none,
  html: none,
  width: 100%,
  height: 200pt,
  at: "1-",
  enter: "fade",
  bridge: none,
  zoom: true,
  style: true,
  fallback: none,
  link: none,
  label: auto,
  start: none,
  end: none,
  loop: none,
) = {
  media-range(start, end, loop)
  if start != none or end != none or loop != none {
    assert(html == none and type(url) == str and url.match(regex(
      "^https://(www\\.)?(youtube\\.com|youtube-nocookie\\.com)/embed/[A-Za-z0-9_-]{11}([?#].*)?$")) != none,
      message: "typstage: embed start/end/loop are supported for YouTube embed URLs only.")
  }
  // Announced for the whole document, not just for what comes after it: a
  // companion package resolving `target: auto` has to find an applet that is
  // written *below* its own commands as well.
  let bridge = if bridge == none { none } else { name-of(bridge) }
  // Die Fit-Prüfung stand hier, weil `embed` auf Papier nie bei `track`
  // ankam; jetzt fragt `track` auch dort, und diese bleibt als die erste.
  fit-verbot("embed")
  if bridge != none {
    context [#metadata((
      slide: slide-counter.get().first(), name: bridge,
    ))<typstage-bridge-target>]
  }
  context if not html-output.get() {
  // Auf Papier derselbe Trichter wie im Browser, nur mit dem Platzhalter als
  // Rumpf: `track` zählt die Schritte und entscheidet, ob der Platzhalter auf
  // der gesetzten Seite steht.
  //
  // Vorher zeichnete dieser Zweig den Platzhalter selbst und zählte von Hand,
  // und zwar nur `at: auto`. Ein ausgeschriebenes `at` hinter Schritt eins
  // fehlte darum in der Schrittzahl (`embed(at: "2,4-")` allein: im Browser
  // vier Schritte, auf Papier einer), und unter `pages: "step"` stand der
  // Platzhalter auf jeder Seite der Folie, auch dort, wo der Browser nichts
  // zeigt. Gemessen an `anim[VOR]` und `embed(at: auto)` dahinter: im Browser
  // ab Schritt drei, auf Papier schon auf den Seiten eins und zwei; ein
  // `embed(at: "1")` stand noch auf den Seiten zwei bis vier. Ein `video`
  // daneben ging immer durch `track` und stand richtig.
  //
  // Bei `at: "1-"`, dem Vorgabewert, zählt `track` nichts und zeigt den
  // Platzhalter auf jeder Seite, wie bisher.
  track("embed", fallback-box(fallback, if link != none { link } else { url },
                              width, height,
                              if label == auto { doc-word("embedded") } else { label }),
        at: at)
} else {
  track(
    "embed",
    box(width: width, height: height, fill: luma(92%)),
    at: at,
    extra: (url: url, doc: grundstil(html, zoom, style), enter: enter,
            bridge: bridge, zoom: zoom, start: start, end: end, loop: loop),
  )
}
}

/// Animation drawn by Typst, frame by frame.
///
/// `render` receives `t` running from 0.0 to 1.0. Every frame is rendered by
/// Typst: CeTZ, Fletcher, equations, anything Typst can do. The frames sit in
/// the file as SVG and stay sharp at any size.
///
/// Under `prefers-reduced-motion: reduce` it does not play. It stands on its
/// last frame without `loop` and without `pingpong`, and on frame zero
/// otherwise. See the manual.
#let flipbook(
  render,
  frames: 24,
  fps: 30,
  width: 200pt,
  height: 150pt,
  loop: true,
  pingpong: false,
  at: "1-",
  enter: "fade",
  still: auto,
) = {
  // Wie in `embed`: die Prüfung stammt aus der Zeit, als dieser Zweig auf
  // Papier nicht bei `track` ankam.
  fit-verbot("flipbook")
  context if not html-output.get() {
  // On paper a single frame has to do. `still` picks which one.
  // Und es geht durch `track`, wie in `embed` und aus demselben Grund: nur
  // dort zählt ein ausgeschriebenes `at` hinter Schritt eins mit, und nur dort
  // fehlt das Bild unter `pages: "step"` auf den Seiten, auf denen der Browser
  // es nicht zeigt.
  //
  // `nackt`, wie der Kasten einer Szene, hier und im Browserzweig: dort steht
  // eine `box`, hier ein `block`, und jeder nahm nur die Regel seiner eigenen
  // Art an. Unter `#set block(inset: 8pt)` stand das Bild auf Papier um den
  // Einzug weiter rechts und tiefer als im Browser, unter `#set box(inset:
  // 8pt)` im Browser weiter als auf Papier, und `#set box(fill: …, stroke: …)`
  // zog nur im Browser einen Kasten darum.
  track("flipbook", block(..nackt, width: width, height: height,
                          if still == auto { render(0.0) } else { still }),
        at: at)
} else {
  track(
    "flipbook",
    box(..nackt, width: width, height: height, clip: true, render(0.0)),
    at: at,
    extra: (fps: fps, loop: loop, pingpong: pingpong, enter: enter),
    // How `t` is distributed over the frames depends on the playback mode:
    //
    // In plain looping, `t = 1` is the same state as `t = 0`: a motion
    // that closes on itself is back at the start after one full round.
    // The last frame would thus be a copy of the first, and in the loop
    // the same frame would sit for two frames' worth of time. Measured on
    // the traveling meander: frame 0 and frame 29 were pixel-identical,
    // frame 28 deviated by 7%. Hence `i / frames`: the last frame lies
    // just *before* the round closes.
    //
    // With `pingpong`, on the other hand, `t = 1` is the turning point and
    // belongs to the sequence, as it does for a single playthrough, where
    // it is the end state.
    raw-frames: range(frames).map(i => box(..nackt,
      width: width, height: height, clip: true,
      render(if frames <= 1 { 0.0 }
             else if loop and not pingpong { i / frames }
             else { i / (frames - 1) }),
    )),
  )
}
}
