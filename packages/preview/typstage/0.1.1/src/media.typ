// Video, embedded documents and Typst-drawn animation, plus what takes their
// place on paper.

#import "internal.typ": (track, fit-verbot, html-output, im-deck, name-of,
                         schritt-vorruecken, slide-counter)
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

/// A real HTML5 video over the slide.
///
/// Without a `poster:` the placeholder on paper is labelled
/// `<ts-media-poster>`.
#let video(
  src,
  width: 100%,
  height: 200pt,
  poster: none,
  autoplay: true,
  loop: false,
  muted: true,
  controls: false,
  radius: 0pt,
  at: "1-",
  enter: "fade",
) = track(
  "video",
  box(width: width, height: height, clip: true, radius: radius,
      if poster == none {
        set rect(fill: luma(92%))
        [#rect(width: 100%, height: 100%) <ts-media-poster>]
      } else {
        { set image(width: 100%, height: 100%, fit: "cover"); poster }
      }),
  at: at,
  extra: (src: src, autoplay: autoplay, loop: loop, muted: muted,
          controls: controls, radius: radius.pt(), enter: enter),
)

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
) = {
  // Announced for the whole document, not just for what comes after it: a
  // companion package resolving `target: auto` has to find an applet that is
  // written *below* its own commands as well.
  let bridge = if bridge == none { none } else { name-of(bridge) }
  // On paper `embed` never reaches `track`, it only draws its stand-in and
  // moves the cursor, so the fit check cannot be left to `track` here.
  fit-verbot("embed")
  if bridge != none {
    context [#metadata((
      slide: slide-counter.get().first(), name: bridge,
    ))<typstage-bridge-target>]
  }
  context if not html-output.get() {
  // The step counting of `track` does not run on paper, so the one case that
  // consumes a step is done here: `info().step.total` has to report the same
  // number in both outputs.
  if at == auto and im-deck() { schritt-vorruecken() }
  fallback-box(fallback, if link != none { link } else { url }, width, height,
               if label == auto { doc-word("embedded") } else { label })
} else {
  track(
    "embed",
    box(width: width, height: height, fill: luma(92%)),
    at: at,
    extra: (url: url, doc: grundstil(html, zoom, style), enter: enter,
            bridge: bridge, zoom: zoom),
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
  // As in `embed`: on paper this never reaches `track`.
  fit-verbot("flipbook")
  context if not html-output.get() {
  // On paper a single frame has to do. `still` picks which one.
  // The step counting of `track` does not run here, so the one case that
  // consumes a step is done by hand, as in `embed`.
  if at == auto and im-deck() { schritt-vorruecken() }
  block(width: width, height: height,
        if still == auto { render(0.0) } else { still })
} else {
  track(
    "flipbook",
    box(width: width, height: height, clip: true, render(0.0)),
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
    raw-frames: range(frames).map(i => box(
      width: width, height: height, clip: true,
      render(if frames <= 1 { 0.0 }
             else if loop and not pingpong { i / frames }
             else { i / (frames - 1) }),
    )),
  )
}
}
