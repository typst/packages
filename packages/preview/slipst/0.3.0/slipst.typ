#import "utils.typ": *

#let pause = if dictionary(std).at("html", default: none) == none {
  parbreak()
} else {
  metadata("slipst-pause")
}
#let up(label, offset: 0, dy: 0) = metadata((slipst-action: (up: label, offset: offset, dy: dy)))
#let alter(num) = metadata((slipst-action: (alter: num)))

#let preview-mode = state("preview-mode", false)
#let slipst-counter = counter("slipst")
#let slipst-alter-counter = counter("slipst-alter")

#let uncover(ranges, cover: hide, raw: false, body) = {
  let inner = () => {
    if preview-mode.get() {
      return body
    }

    let ranges = _parse_ranges(ranges)
    let alter-idx = slipst-alter-counter.get().first()
    let should-show = _is_in_ranges(alter-idx, ranges)
    if should-show {
      body
    } else {
      cover(body)
    }
  }
  if raw {
    inner()
  } else {
    context inner()
  }
}

#let only = uncover.with(cover: it => none)

#let _cut(it) = {
  let (slips, remainder) = it.children.fold((slips: (), remainder: ()), (acc, it) => {
    let (slips, remainder) = acc
    if it.func() == metadata and it.value == "slipst-pause" {
      (slips + (remainder,), (it,))
    } else {
      (slips, remainder + (it,))
    }
  })
  let slips = slips + (remainder,)
  let slips = slips.map(_strip).filter(slip => slip.len() > 0)
  slips
}

#let _slip(slip, width: auto, show-fn: it => it) = context {
  let slip-idx = slipst-counter.get().first()
  let attrs = (class: "slip", data-slip: str(slip-idx))

  let actions = slip
    .filter(it => it.func() == metadata)
    .map(it => it.value)
    .filter(it => type(it) == dictionary)
    .map(it => it.at("slipst-action", default: none))
    .filter(it => type(it) == dictionary)
  let up = actions.rev().find(it => it.at("up", default: none) != none)
  let alter = actions.rev().find(it => it.at("alter", default: none) != none)
  let alter-num = if type(alter) == dictionary {
    alter.at("alter", default: 1)
  } else {
    1
  }
  attrs.insert("data-slip-alter-num", str(alter-num))

  if type(up) == dictionary {
    let anchor = up.at("up")

    let offset = up.at("offset", default: 0)
    assert(type(offset) == int, message: "Offset must be a number")

    let dy = up.at("dy", default: 0)
    assert(type(dy) == length or dy == 0, message: "dy must be a length")

    if type(anchor) == function {
      anchor = anchor()
    }
    let anchor = slipst-counter.at(anchor).first()
    attrs.insert("data-slip-up", str(anchor + offset))
    if dy != 0 {
      attrs.insert("data-slip-dy", str(dy.to-absolute().cm()))
    }
  }

  for alter-idx in range(1, alter-num + 1) {
    let attrs-local = (
      "data-slip-alter-idx": str(alter-idx),
      "style": "grid-row: " + str(slip-idx) + "; grid-column: 1;",
      ..attrs,
    )
    html.elem(
      "div",
      attrs: attrs-local,
      html.frame(show-fn({
        slipst-alter-counter.update(alter-idx)
        block(width: width, slip.join())
      })),
    )
  }
  slipst-counter.step()
}

#let slipst(body, width: 16cm, spacing: auto, margin: 0.5cm, handout: false, show-fn: it => it) = {
  if dictionary(std).at("html", default: none) == none {
    return context show-fn({
      set page(width: width + margin * 2, height: auto, margin: margin)
      let size = measure(body)
      preview-mode.update(true)
      body
      if not handout {
        footnote(numbering: it => hide[it])[
          #smallcaps[Note]: This is a quick preview of the content of the presentation.
          For the full experience, please export to HTML.
          (Estimated size: #(calc.ceil(size.height.cm() / width.cm() * 9 / 16)) screens.)
        ]
      }
    })
  }

  preview-mode.update(false)
  counter("slipst").update(1)

  fmap(body, it => context {
    let spacing = if spacing == auto {
      par.spacing
    } else {
      spacing
    }
    let variables = (
      "--slip-width": width.to-absolute().cm(),
      "--slip-spacing": spacing.to-absolute().cm(),
      "--slip-margin": margin.to-absolute().cm(),
    )
    html.html(style: variables.pairs().map(((k, v)) => k + ": " + str(v)).join("; "), {
      html.meta(charset: "utf-8")
      html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      html.head({
        html.style(read("slipst.css"))
        html.script(read("slipst.js"), type: "module")
      })
      html.body(html.main(html.div(
        id: "container",
        {
          for slip in _cut(it) {
            _slip(slip, width: width, show-fn: show-fn)
          }
        },
      )))
    })
  })
}
