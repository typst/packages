#let thmcounters = state("thm",
  (
    "counters": ("heading": ()),
    "latest": ()
  )
)


#let thmenv(identifier, base, base_level, fmt) = {

  return (
    body,
    base: base,
    base_level: base_level,
    ..args,
  ) => {
    if not ("number" in args.named().keys()) {
      locate(loc => {
        thmcounters.update(thmpair => {
          let counters = thmpair.at("counters")
          // Manually update heading counter
          counters.at("heading") = counter(heading).at(loc)
          if not identifier in counters.keys() {
            counters.insert(identifier, (0, ))
          }

          let tc = counters.at(identifier)
          if base != none {
            let bc = counters.at(base)

            // Pad or chop the base count
            if base_level != none {
              if bc.len() < base_level {
                bc = bc + (0,) * (base_level - bc.len())
              } else if bc.len() > base_level{
                bc = bc.slice(0, base_level)
              }
            }

            // Reset counter if the base counter has updated
            if tc.slice(0, -1) == bc {
              counters.at(identifier) = (..bc, tc.last() + 1)
            } else {
              counters.at(identifier) = (..bc, 1)
            }
          } else {
            // If we have no base counter, just count one level
            counters.at(identifier) = (tc.last() + 1,)
            let latest = counters.at(identifier)
          }

          let latest = counters.at(identifier)
          return (
            "counters": counters,
            "latest": latest
          )
        })
      })
      locate(loc => {  fmt(body, number:thmcounters.at(loc).latest, ..args) } )
    }else{
      fmt(body, ..args)
    }
  }
}

#let thmref(
  label,
  fmt: auto,
  makelink: true,
  ..body
) = {
  if fmt == auto {
    fmt = (nums, body) => {
      if body.pos().len() > 0 {
        body = body.pos().join(" ")
        return [#body #numbering("1.1", ..nums)]
      }
      return numbering("1.1", ..nums)
    }
  }

  locate(loc => {
    let elements = query(label, loc)
    let locationreps = elements.map(x => repr(x.location().position())).join(", ")
    assert(elements.len() > 0, message: "label <" + str(label) + "> does not exist in the document: referenced at " + repr(loc.position()))
    assert(elements.len() == 1, message: "label <" + str(label) + "> occurs multiple times in the document: found at " + locationreps)
    let target = elements.first().location()
    let number = thmcounters.at(target).at("latest")
    if makelink {
      return link(target, fmt(number, body))
    }
    return fmt(number, body)
  })
}



#let global_numbering=numbering

#let thmbasic = (
  identifier,
  head,
  numbering :"1.1",
  base:"heading",
  base_level: none
) => {
  let fmt = (body, name:none, title:none,number:none, numbering:numbering) => {
    if title==none {
      title=head
    }
    
    [#strong[#title  #{if numbering != none [#global_numbering(numbering, ..number)]}]#{if name != none [ (#name)]}*:*  #body \ ]
  }
  return thmenv(identifier, base, base_level, fmt)
}

/// I am quirky
#let thmbox(
  identifier,
  head,
  fill: none,
  stroke: none,
  inset: 1.2em,
  radius: 0.3em,
  breakable: false,
  padding: (top: 0.5em, bottom: 0.5em),
  namefmt: x => [(#x)],
  titlefmt: strong,
  bodyfmt: x => x,
  separator: [#h(0.1em):#h(0.2em)],
  numbering :"1.1",
  base: "heading",
  base_level: none,
) = {
  let boxfmt(name:none, number:none, title:none, body, numbering:numbering) = {
    if  name != none {
      name = [ #namefmt(name)]
    } else {
      name = []
    }
    if title==none {
    title = head
    }
    if number != none and numbering!=none {
      title += " " + global_numbering(numbering,..number)
    }
    title = titlefmt(title)
    body = bodyfmt(body)
    pad(
      ..padding,
      block(
        fill: fill,
        stroke: stroke,
        inset: inset,
        width: 100%,
        radius: radius,
        breakable: breakable,
        [#title#name#separator#body]
      )
    )
  }
  return thmenv(identifier, base, base_level, boxfmt)
}

#let thmplain = thmbox.with(
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  inset: (top: 0em, left: 1.2em, right: 1.2em),
  namefmt: name => emph([(#name)]),
  titlefmt: emph,
)