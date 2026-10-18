#import "/src/asset.typ"
#import "/src/cfg.typ"
#import "/src/checkbox.typ"
#import "/src/hacks.typ"
#import "/src/info.typ"
#import "/src/keywords.typ"
#import "/src/palette.typ": *
#import "/src/util/mod.typ": *
#import "/src/xlink.typ"

#let _shortcuts(body) = {
  (
    "->": sym.arrow,
    "=>": sym.arrow.double,
    "!=": sym.eq.not,
    "<=>": sym.arrow.l.r.double,
    "<>": sym.harpoons.rtlb,
    // can be just typed with .<shift on>.<shift off>. on Bone (https://neo-layout.org/Layouts/bone/)
    ".•.": $therefore$,
    "•.•": $because$,
  )
    .pairs()
    .fold(body, (body, (source, target)) => {
      show: hacks.only-main(source, target)
      body
    })
}

#let _numbering(body, ..args) = {
  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")

  body
}

#let _machinize(body, ..args) = {
  set page(width: auto, height: auto)
  set text(size: 1pt)

  show: _numbering

  body
}

#let _styling(body, ..args) = context {
  if cfg.render != "all" {
    return _machinize(body, ..args)
  }

  let args = args.named()
  let faded-line = move(dy: -0.25em, line(length: 100%, stroke: gamut.sample(
    15%,
  )))

  show: _numbering

  set outline.entry(fill: faded-line)
  set outline(indent: auto)

  show: body => if cfg.target == "paged" {
    set page(fill: bg, numbering: "1 / 1")
    body
  } else {
    body
  }
  set text(fill: fg, lang: args.at("lang", default: "en"))

  set rect(stroke: fg)
  set line(stroke: fg)
  set table(inset: 0.75em, stroke: (x, y) => {
    if x > 0 { (left: gamut.sample(30%)) }
    if y > 0 { (top: gamut.sample(30%)) }
  })

  set math.mat(delim: "[")
  set math.vec(delim: "[")

  show: _shortcuts

  show ref: text.with(fill: reference.same-file)
  show link: it => {
    let accent = if type(it.dest) == str {
      reference.external
    } else {
      reference.same-file
    }
    let ret = text(fill: accent, it)
    if not cfg.dev { ret = underline(ret) }
    ret
  }

  let cb = (
    fill: halcyon.bg,
    radius: 0.25em,
  )

  set raw(theme: asset.halcyon)
  show raw: text.with(fill: halcyon.fg)
  show raw.where(block: false): it => box(
    outset: (y: 0.3em),
    inset: (x: 0.25em),
    it,
    ..cb,
  )
  show raw.where(block: true): it => block(
    inset: 0.75em,
    width: 100%,
    stroke: 0.025em + gradient.linear(halcyon.bg, halcyon.fg).sample(40%),
    it,
    ..cb,
  )

  show table: align.with(center)

  body
}

#let _shared(args) = {
  let data = info.preprocess(args.named())
  let title = args.at("title", default: {
    if cfg.filename != none {
      cfg.filename.trim(".typ", repeat: false)
    } else {
      "Untitled"
    }
  })

  let subtitle = args.at("subtitle", default: none)

  (data: data, title: title, subtitle: subtitle)
}

