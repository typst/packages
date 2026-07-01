#import "utils.typ": get-group-span, fit-canvas
#import "renderer.typ": render
#import "participant.typ" as participant: _par, PAR-SPECIALS
#import "sequence.typ": _seq

#let _gap(size: 20) = {
  return ((
    type: "gap",
    size: size
  ),)
}

#let _evt(participant, event) = {
  return ((
    type: "evt",
    participant: participant,
    event: event,
    lifeline-style: auto
  ),)
}

#let _col(p1, p2, width: auto, margin: 0, min-width: 0, max-width: none) = {
  return ((
    type: "col",
    p1: p1,
    p2: p2,
    width: width,
    margin: margin,
    min-width: min-width,
    max-width: max-width
  ),)
}

#let diagram(elements, width: auto) = {
  if elements == none {
    return
  }
  
  let participants = ()
  let elmts = elements
  let i = 0

  let activation-history = ()

  // Flatten groups + convert returns
  while i < elmts.len() {
    let elmt = elmts.at(i)
    if elmt.type == "grp" {
      let grp-elmts = elmt.elmts
      elmt.elmts = elmt.elmts.map(e => {
        if e.type == "seq" {
          if e.p1 == "?" {
            e.p1 = "?" + e.p2
          } else if e.p2 == "?" {
            e.p2 = e.p1 + "?"
          }
        }
        e
      })
      elmts.at(i) = elmt
      elmts = (
        elmts.slice(0, i + 1) +
        grp-elmts +
        ((
          type: "grp-end"
        ),) +
        elmts.slice(i+1)
      )
    } else if elmt.type == "seq" {
      if elmt.enable-dst {
        activation-history.push(elmt)
      }
    } else if elmt.type == "evt" {
      if elmt.event == "enable" {
        for elmt2 in elmts.slice(0, i).rev() {
          if elmt2.type == "seq" {
            activation-history.push(elmt2)
            break
          }
        }
      }
    } else if elmt.type == "ret" {
      if activation-history.len() == 0 {
        panic("Cannot return if no lifeline is activated")
      }
      let seq = activation-history.pop()
      elmts.at(i) = _seq(
        seq.p2, seq.p1,
        comment: elmt.comment,
        disable-src: true,
        dashed: true
      ).first()
    }
    i += 1
  }

  // List participants
  let linked = ()
  let last-seq = none
  let last-note = none
  for (i, elmt) in elmts.enumerate() {
    if elmt.type == "par" {
      participants.push(elmt)
    } else if elmt.type == "seq" {
      if not participant._exists(participants, elmt.p1) {
        participants.push(_par(elmt.p1).first())
      }
      if not participant._exists(participants, elmt.p2) {
        let par = _par(elmt.p2, from-start: not elmt.create-dst).first()
        participants.push(par)
      
      } else if elmt.create-dst {
        let i = participants.position(p => p.name == elmt.p2)
        participants.at(i).from-start = false
      }

      let p1 = elmt.p1
      let p2 = elmt.p2
      if elmt.p1 == "?" {
        p1 = "?" + elmt.p2
      }
      if elmt.p2 == "?" {
        p2 = elmt.p1 + "?"
      }
      linked.push(p1)
      linked.push(p2)
      last-seq = (
        elmt: elmt,
        i: i,
        p1: p1,
        p2: p2
      )
    } else if elmt.type == "note" {
      elmt.insert("linked", elmt.pos == none and elmt.side != "across")
      if elmt.pos == none and elmt.side != "across" {
        let names = participants.map(p => p.name)
        let i1 = names.position(n => n == last-seq.p1)
        let i2 = names.position(n => n == last-seq.p2)
        let pars = ((i1, last-seq.p1), (i2, last-seq.p2)).sorted(key: p => p.first())
        if elmt.side == "left" {
          elmt.pos = pars.first().last()
        } else if elmt.side == "right" {
          elmt.pos = pars.last().last()
        }

        let seq = last-seq.elmt
        seq.insert("linked-note", elmt)
        elmts.at(last-seq.i) = seq
      }
      if elmt.aligned {
        let n = last-note.elmt
        n.aligned-with = elmt
        elmts.at(last-note.i) = n
      }
      elmts.at(i) = elmt
      if elmt.side == "left" {
        linked.push("[")
      } else if elmt.side == "right" {
        linked.push("]")
      }

      let pars = none
      if type(elmt.pos) == str {
        pars = (elmt.pos,)
      } else if type(elmt.pos) == array {
        pars = elmt.pos
      }
      if pars != none {
        for par in pars {
          if not participant._exists(participants, par) {
            participants.push(_par(par).first())
          }
        }
      }

      last-note = (
        elmt: elmt,
        i: i
      )
    } else if elmt.type == "evt" {
      let par = elmt.participant
      if not participant._exists(participants, par) {
        let p = _par(par, from-start: elmt.event != "create").first()
        participants.push(p)
      
      } else if elmt.event == "create" {
        let i = participants.position(p => p.name == par)
        participants.at(i).from-start = false
      }
    }
  }
  linked = linked.dedup()

  let pars = participants
  participants = ()
  
  if "[" in linked {
    participants.push(_par("[", invisible: true).first())
  }
  
  for (i, p) in pars.enumerate() {
    let before = _par("?" + p.name, invisible: true).first()
    let after = _par(p.name + "?", invisible: true).first()
    
    if before.name in linked {
      if participants.len() == 0 or not participants.last().name.ends-with("?") {
        participants.push(before)
      } else {
        participants.insert(-1, before)
      }
    }

    participants.push(p)

    if after.name in linked {
      participants.push(after)
    }
  }
  if "]" in linked {
    participants.push(_par("]", invisible: true).first())
  }

  // Add index to participant
  for (i, p) in participants.enumerate() {
    p.insert("i", i)
    participants.at(i) = p
  }

  // Compute groups spans (horizontal)
  for (i, elmt) in elmts.enumerate() {
    if elmt.type == "grp" or elmt.type == "alt" {
      let (min-i, max-i) = get-group-span(participants, elmt)
      elmts.at(i).insert("min-i", min-i)
      elmts.at(i).insert("max-i", max-i)
    } else if elmt.type == "seq" {
      if elmt.p1 == "?" {
        elmts.at(i).p1 = "?" + elmt.p2
      } else if elmt.p2 == "?" {
        elmts.at(i).p2 = elmt.p1 + "?"
      }
    }
  }

  let canvas = render(participants, elmts)
  fit-canvas(canvas, width: width)
}

#let from-plantuml(code) = {
  let code = code.text
}