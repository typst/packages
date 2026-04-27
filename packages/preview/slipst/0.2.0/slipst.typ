#import "utils.typ": *

#let pause = if dictionary(std).at("html", default: none) == none {
  parbreak()
} else {
  metadata("slipst-pause")
}
#let up(label, offset: 0) = metadata((slipst-action: (up: label, offset: offset)))

#let slipst-counter = counter("slipst")

#let _should_strip(it) = {
  _is(it, parbreak) or _is(it, space)
}

#let _strip(slip) = {
  let _ = while _should_strip(slip.first(default: none)) {
    slip.remove(0)
  }
  let _ = while _should_strip(slip.last(default: none)) {
    slip.pop()
  }
  slip
}

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
  let attrs = (class: "slip", data-slip: str(slipst-counter.get().first()))

  let actions = slip
    .filter(it => it.func() == metadata)
    .map(it => it.value)
    .filter(it => type(it) == dictionary)
    .map(it => it.at("slipst-action", default: none))
    .filter(it => type(it) == dictionary)
  let up = actions.rev().find(it => it.at("up", default: none) != none)
  if type(up) == dictionary {
    let anchor = up.at("up")
    let offset = up.at("offset", default: 0)
    if type(anchor) == function {
      anchor = anchor()
    }
    let anchor = slipst-counter.at(anchor).first()
    attrs.insert("data-slip-up", str(anchor + offset))
  }

  html.elem(
    "div",
    attrs: attrs,
    html.frame(show-fn({
      block(width: width, slip.join())
    })),
  )
  slipst-counter.step()
}

#let slipst(body, width: 16cm, spacing: auto, margin: 0.5cm, show-fn: it => it) = {
  if dictionary(std).at("html", default: none) == none {
    return show-fn({
      set page(width: width + margin * 2, height: auto, margin: margin)
      body
      footnote(numbering: it => hide[it])[
        #smallcaps[Note]: This is a quick preview of the content of the presentation.
        For the full experience, please export to HTML.
      ]
    })
  }


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
