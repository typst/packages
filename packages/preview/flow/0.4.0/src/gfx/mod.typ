#import "@preview/roumnd:0.1.0"
#import "util.typ": *
#import "../palette.typ": *

// need to convert to a dict so we can access by string key
#let icons = {
  let representation = (
    // These don't have accent equivalents but are still worth including.
    A: "A",
    B: "B",
    C: "C",
    E: "E",
    F: "F",
    G: "G",
    // These have dedicated colors defined in the palette.
    empty: " ",
    urgent: "!",
    progress: ">",
    pause: ":",
    idle: "-",
    complete: "x",
    cancel: "/",
    question: "?",
    remark: "i",
    hint: "o",
    axiom: "A",
    define: "D",
    theorem: "T",
    propose: "P",
    lemma: "l",
    corollary: "C",
  )

  representation
    .pairs()
    .map(((meaning, code)) => {
      let accent = status.at(meaning, default: fg)
      let icon = _maybe-stub(roumnd.icons.at(code))

      (
        meaning,
        (
          code: code,
          accent: accent,
          render: icon.with(
            foreground: accent,
            background: bg,
          ),
          meaning: meaning,
        ),
      )
    })
    .to-dict()
}
#let icons-by-code = icons.values().map(icon => (icon.code, icon)).to-dict()

#let parallelopiped(start, end, shift: 0.5, ..args) = {
  import draw: *

  line(
    start,
    (start, "-|", end),
    (to: end, rel: (shift, 0)),
    (to: (start, "|-", end), rel: (shift, 0)),
    close: true,
    ..args,
  )
}

