#import "draw/group.typ": render-end as grp-render-end
#import "draw/sync.typ": render-end as sync-render-end
#import "utils.typ": get-group-span, is-elmt
#import "/src/participant.typ": _exists as par-exists, _par
#import "/src/sequence.typ": _seq

#let flatten-group(elmts, i) = {
  let group = elmts.at(i)
  elmts.at(i) = group
  return (
    elmts.slice(0, i + 1) +
    group.elmts +
    ((
      type: "grp-end",
      draw: grp-render-end,
      start-i: i
    ),) +
    elmts.slice(i+1)
  )
}

#let flatten-sync(elmts, i) = {
  let sync = elmts.at(i)
  elmts.at(i) = sync
  let start = sync
  start.remove("elmts")
  return (
    elmts.slice(0, i) +
    (start,) +
    sync.elmts +
    ((
      type: "sync-end",
      draw: sync-render-end,
      elmts: sync.elmts
    ),) +
    elmts.slice(i + 1)
  )
}

#let update-group-children(elmts, i) = {
  let elmts = elmts
  let group-end = elmts.at(i)
  
  elmts.at(group-end.start-i).elmts = elmts.slice(group-end.start-i + 1, i)
  return elmts
}

#let convert-return(elmts, i, activation-history) = {
  if activation-history.len() == 0 {
    panic("Cannot return if no lifeline is activated")
  }
  let elmts = elmts
  let activation-history = activation-history
  let ret = elmts.at(i)
  let seq = activation-history.pop()
  elmts.at(i) = _seq(
    seq.p2, seq.p1,
    comment: ret.comment,
    disable-src: true,
    dashed: true
  ).first()
  return (elmts, activation-history)
}

#let unwrap-containers(elmts) = {
  let elmts = elmts
  let i = 0
  let activation-history = ()

  // Flatten groups + convert returns
  while i < elmts.len() {
    let elmt = elmts.at(i)
    if not is-elmt(elmt) {
      i += 1
      continue
    }

    if elmt.type == "grp" {
      elmts = flatten-group(elmts, i)
    
    } else if elmt.type == "sync" {
      elmts = flatten-sync(elmts, i)

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
      (elmts, activation-history) = convert-return(elmts, i, activation-history)
    }
    i += 1
  }

  return (elmts, activation-history)
}


#let prepare-seq-participants(ctx, seq) = {
  let ctx = ctx
  if not par-exists(ctx.participants, seq.p1) {
    ctx.participants.push(_par(seq.p1).first())
  }
  if not par-exists(ctx.participants, seq.p2) {
    ctx.participants.push(_par(
      seq.p2,
      from-start: not seq.create-dst
    ).first())
  
  } else if seq.create-dst {
    let i = ctx.participants.position(p => p.name == seq.p2)
    ctx.participants.at(i).from-start = false
  }

  let p1 = seq.p1
  let p2 = seq.p2
  if seq.p1 == "?" {
    p1 = "?" + seq.p2
  }
  if seq.p2 == "?" {
    p2 = seq.p1 + "?"
  }
  ctx.linked.push(p1)
  ctx.linked.push(p2)
  ctx.last-seq = (
    seq: seq,
    i: ctx.i,
    p1: p1,
    p2: p2
  )
  return ctx
}

#let prepare-note-participants(ctx, note) = {
  let ctx = ctx
  let note = note
  note.insert(
    "linked",
    note.pos == none and note.side != "across"
  )
  let names = ctx.participants.map(p => p.name)
  if note.pos == none and note.side != "across" {
    let i1 = names.position(n => n == ctx.last-seq.p1)
    let i2 = names.position(n => n == ctx.last-seq.p2)
    let pars = (
      (i1, ctx.last-seq.p1),
      (i2, ctx.last-seq.p2)
    ).sorted(key: p => p.first())

    if note.side == "left" {
      note.pos = pars.first().last()
    } else if note.side == "right" {
      note.pos = pars.last().last()
    }

    let seq = ctx.elmts.at(ctx.last-seq.i)
    seq.linked-notes.push(note)
    ctx.elmts.at(ctx.last-seq.i) = seq
  }
  if note.aligned {
    let n = ctx.last-note.note
    n.aligned-with = note
    ctx.elmts.at(ctx.last-note.i) = n
  }

  if note.side in ("left", "right") {
    let i = names.position(n => n == note.pos)
    let pos2 = note.pos
    if note.side == "left" {
      if i <= 0 or note.allow-overlap {
        ctx.linked.push("[")
        pos2 = "["
      } else {
        pos2 = names.at(i - 1)
      }
    } else if note.side == "right" {
      if i >= names.len() - 1 or note.allow-overlap {
        ctx.linked.push("]")
        pos2 = "]"
      } else {
        pos2 = names.at(i + 1)
      }
    }
    note.insert("pos2", pos2)
  }

  let pars = none
  if type(note.pos) == str {
    pars = (note.pos,)
  } else if type(note.pos) == array {
    pars = note.pos
  }
  if pars != none {
    for par in pars {
      if not par-exists(ctx.participants, par) {
        participants.push(_par(par).first())
      }
    }
  }

  ctx.elmts.at(ctx.i) = note

  ctx.last-note = (
    note: note,
    i: ctx.i
  )

  return ctx
}

#let prepare-evt-participants(ctx, evt) = {
  let par = evt.participant
  if not par-exists(ctx.participants, par) {
    let p = _par(
      par,
      from-start: evt.event != "create"
    ).first()
    ctx.participants.push(p)
  
  } else if evt.event == "create" {
    let i = ctx.participants.position(p => p.name == par)
    ctx.participants.at(i).from-start = false
  }
  return ctx
}

#let normalize-special-participants(elmt) = {
  if elmt.p1 == "?" {
    elmt.p1 = "?" + elmt.p2
  } else if elmt.p2 == "?" {
    elmt.p2 = elmt.p1 + "?"
  }
  return elmt
}

#let prepare-participants(elmts) = {
  let ctx = (
    linked: (),
    last-seq: none,
    last-note: none,
    participants: (),
    elmts: elmts,
    i: 0
  )

  for (i, elmt) in ctx.elmts.enumerate() {
    ctx.i = i
    if not is-elmt(elmt) {
      continue
    }

    if elmt.type == "par" {
      ctx.participants.push(elmt)

    } else if elmt.type == "seq" {
      ctx = prepare-seq-participants(ctx, elmt)
    
    } else if elmt.type == "note" {
      ctx = prepare-note-participants(ctx, elmt)
    
    } else if elmt.type == "evt" {
      ctx = prepare-evt-participants(ctx, elmt)
    }
  }
  ctx.linked = ctx.linked.dedup()

  let pars = ctx.participants
  let participants = ()
  
  if "[" in ctx.linked {
    participants.push(_par("[", invisible: true).first())
  }
  
  for (i, p) in pars.enumerate() {
    let before = _par(
      "?" + p.name,
      invisible: true
    ).first()
    let after = _par(
      p.name + "?",
      invisible: true
    ).first()
    
    if before.name in ctx.linked {
      if participants.len() == 0 or not participants.last().name.ends-with("?") {
        participants.push(before)
      } else {
        participants.insert(-1, before)
      }
    }

    participants.push(p)

    if after.name in ctx.linked {
      participants.push(after)
    }
  }
  if "]" in ctx.linked {
    participants.push(_par(
      "]",
      invisible: true
    ).first())
  }

  return (ctx.elmts, participants)
}

#let finalize-setup(elmts, participants) = {
  for (i, p) in participants.enumerate() {
    p.insert("i", i)
    participants.at(i) = p
  }

  let containers = ()

  for (i, elmt) in elmts.enumerate() {
    if not is-elmt(elmt) {
      continue
    }
    if elmt.type == "seq" {
      elmts.at(i) = normalize-special-participants(elmt)
    } else if elmt.type == "grp-end" {
      // Put back elements in group because they might have changed
      elmts = update-group-children(elmts, i)
    } else if elmt.type in ("grp", "alt") {
      containers.push(i)
    }
  }

  // Compute groups spans (horizontal)
  for i in containers {
    let elmt = elmts.at(i)
    let (min-i, max-i) = get-group-span(participants, elmt)
    elmts.at(i).insert("min-i", min-i)
    elmts.at(i).insert("max-i", max-i)
  }

  return (elmts, participants)
}

#let setup(elements) = {
  let (elmts, activation-history) = unwrap-containers(elements)
  
  let participants
  (elmts, participants) = prepare-participants(elmts)

  return finalize-setup(elmts, participants)
}