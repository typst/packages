#let to-scheme = scheme => {
  assert(type(scheme) == array, message: "scheme must be an array")
  return pron => {
    let digit = pron.match(regex("\d+"))
    if digit != none {
      let index = int(digit.text)
      assert(index < scheme.len(), message: "index " + str(index) + " out of range")
      scheme.at(index)
    } else {
      scheme.first()
    }
  }
}

#let tone(pron, conter, width: 1em, pron-size: .4em, pron-font: "jf open 粉圓 2.1", frac: .18em, debug: false) = {
  if conter == none {
    return pron
  }
  assert(width > 0em, message: "width must be greater than 0em")
  set line(length: width, stroke: rgb("ccc"))

  if debug {
    box(line())
    h(-width)
    box(move(line(), dy: -frac))
    h(-width)
    box(move(line(), dy: -frac * 2))
    h(-width)
    box(move(line(), dy: -frac * 3))
    h(-width)
    box(move(line(), dy: -frac * 4))
    h(-width)
  }

  let conter = str(conter)
  let dy = (int(conter.first()) - 1.5) * -frac
  let c = text(pron, pron-size, font: pron-font, script: "Latn")
  if debug {
    c = underline(c)
  }
  if conter.len() == 2 and conter.at(0) == conter.at(1) {
    // if the two digits are the same, use the first one
    conter = conter.at(0)
  }
  if conter.len() == 1 {
    box(move(c, dy: dy))
  } else if conter.len() == 2 {
    let diff = int(conter.at(1)) - int(conter.at(0))
    context {
      let this-width = measure(c).width
      let w = ((this-width + width) / 2).to-absolute()
      let h = (diff * .2em).to-absolute()
      let deg = calc.atan(h / w)
      box(move(rotate(-deg, c, origin: left + bottom, reflow: false), dy: dy))
    }
  } else if conter.len() == 3 {
    // find a position to split the pron

    // find the minimal width diff
    context {
      let diff-width(a, b) = {
        measure(a).width - measure(b).width
      }
      let split-position = 0
      let min-diff = diff-width("", pron)
      for i in range(1, pron.len()) {
        let diff = diff-width(pron.slice(0, i), pron.slice(i))
        if calc.abs(diff) < calc.abs(min-diff) {
          min-diff = diff
          split-position = i
        }
      }

      assert(pron.len() > 2 and split-position > 0 and split-position < pron.len(), message: "split-position must be greater than 0 and less than pron length")
      // box 1
      if split-position > 0 {
        let w1 = measure(pron.slice(0, split-position)).width
        let h1 = (int(conter.at(0)) - 1.5) * -frac
        let deg1 = calc.atan(h1.to-absolute() / w1.to-absolute())
        box(move(rotate(-deg1, c, origin: left + bottom, reflow: false), dy: dy))
      }
      // box 2
      if split-position < pron.len() {
        let w2 = measure(pron.slice(split-position)).width
        let h2 = (int(conter.at(1)) - 1.5) * -frac
        let deg2 = calc.atan(h2.to-absolute() / w2.to-absolute())
        box(move(rotate(-deg2, c, origin: left + bottom, reflow: false), dy: dy))
      }
    }
  }
}

// #let view = (s, t) => tone(s, t, width: 1.3em, pron-size: .5em, pron-font: "HarmonyOS Sans")

// #view("fan1", 55)
// #view("fan2", 35)
// #view("fan3", 33)
// #view("fan4", 11)
// #view("fan5", 13)
// #view("fan6", 22)

#let cd(
  pairs,
  scheme: none,
  dir: direction.btt,
  pron-font: none,
  pron-size: .4em,
  width: "monospace",
  pron-style: none,
  debug: false,
) = context {
  let pron-font = pron-font
  if pron-font == none {
    pron-font = text.font
  }
  set box(
    fill: if debug { rgb("#32966214") } else { rgb(0, 0, 0, 0) },
    stroke: if debug { rgb(250, 50, 0) + .6pt } else { none },
  )
  // set text(borde: if debug { rgb(50, 50, 250) + .5pt } else { none })
  let widest = auto
  if width == "monospace" {
    widest = measure("水").width
    for pair in pairs {
      if (type(pair) != array) {
        continue
      }
      let pron = pair.at(1)
      if pron != none {
        let width = (
          measure(
            text(pron, font: pron-font, size: pron-size),
          ).width
        )
        if width > widest {
          widest = width
        }
      }
    }
  } else if width != none {
    widest = width
  }

  for pair in pairs {
    if (type(pair) != array) {
      pair
      continue
    }
    let (zi, pron, ..) = pair
    if pron == none {
      zi
      continue
    }
    assert(
      pair.len() == 3 or type(scheme) == function,
      message: "Either provide the tone conter in the pair, or provide a scheme function to convert the pron to the tone conter",
    )
    let conter = if pair.len() > 2 {
      pair.at(2)
    } else {
      scheme(pron)
    }
    let s = stack(dir: dir, spacing: .3em)[
      #set align(center)
      #box(zi, width: widest)
    ][
      #set align(center)
      #if type(pron-style) == function {
        pron = pron-style(pron)
      }
      #box(width: widest, tone(
        pron,
        conter,
        width: widest,
        pron-size: pron-size,
        pron-font: pron-font,
        debug: debug,
      ))
    ]
    box(width: widest, pad(
      top: .5em,
      s,
    ))
  }
}

#let to-pairs(zh, pron) = {
  let pairs = ()
  let prons = pron.split(regex("(\s|-)+"))
  let j = 0
  let prons-len = prons.len()

  for zi in zh {
    let pron = if zi.contains(regex("\p{Han}")) and j < prons-len {
      let res = prons.at(j)
      j += 1
      res
    } else {
      none
    }
    pairs.push((
      zi,
      pron,
    ))
  }

  pairs
}


#let to-sandhi-pairs(zh, pron, zi-counter: pron => pron.matches(regex("-+")).len() + 1) = {
  let prons = pron.split(regex("\s+")) // words
  let res = ()

  for pron in prons {
    let length = zi-counter(pron)
    let result = zh.match(regex("^(\P{Han}+)?(\p{Han}{" + str(length) + "})"))
    let (prefix, ci) = result.captures
    if (prefix != none and prefix != "") {
      res.push((prefix, none))
    }
    res.push((ci, pron))
    zh = zh.slice(result.end)
  }
  if zh != "" {
    res.push((zh, none))
  }
  res
}
