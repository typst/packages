#import "state.typ": _deixis-omission-policy, deixis-system, _deixis-registry

// Omission is a creation policy, not a visual style. Attachments and occurrences
// follow their original even when declared before it or in a different scope.
#let _deixis-check-omit(value) = {
  assert(value == none or (type(value) == dictionary and value.keys() == ("series",)
    and type(value.series) == array and value.series.all(s => type(s) == str)),
    message: "deixis: omit must be none or (series: (\"todo\", ...)).")
}
#let _deixis-omit-series(series) = {
  let value = _deixis-omission-policy.get().last()
  value != none and series in value.series
}
#let _deixis-omitted(id) = {
  query(<deixis-omitted>).any(it => it.value.id != none and (
    if type(id) == location { it.value.id == id }
    else { type(it.value.id) != location and str(it.value.id) == str(id) }
  ))
}
#let _deixis-check-omitted(id) = {
  assert(not _deixis-omitted(id), message: "deixis: Annotation " + repr(id)
    + " is omitted by deixis-set(omit: ...); remove its reference or include its series.")
}
#let _deixis-validate-omissions() = {
  let ids = _deixis-registry(deixis-system.final()).id-index
  for it in query(<deixis-omitted>) {
    if it.value.id == none or type(it.value.id) == location { continue }
    assert(type(it.value.id) in (str, label) and str(it.value.id).len() > 0,
      message: "deixis: A note ID must be a nonempty string or label.")
    let key = str(it.value.id)
    assert(key not in ids, message: "deixis: Duplicate note ID " + repr(key)
      + "; an omitted annotation still reserves its authored ID.")
    ids.insert(key, true)
  }
}

// Native outlines replay heading/caption bodies. A replayed annotation must
// show only its marked passage: registering again would renumber later notes,
// duplicate bodies, or reject a named original. Without a replay rule (or no
// setup at all) the labelled sequence renders its live content unchanged.
#let _deixis-omission-decision(policy) = {
  if policy.of != none { _deixis-omitted(policy.of) }
  else {
    let id = policy.at("id", default: none)
    let saved = if id == none { none } else {
      query(<deixis-creation-decision>).find(it => (
        if type(id) == location { it.value.id == id }
        else { type(it.value.id) != location and str(it.value.id) == str(id) }))
    }
    if saved == none { _deixis-omit-series(policy.series) } else { saved.value.omitted }
  }
}
#let _deixis-live-omission-evidence(it) = [#metadata(it.value)<deixis-omitted>]
#let _deixis-live-omission(it) = context {
  let policy = it.value
  if _deixis-omission-decision(policy) {
    if policy.of == none {
      policy.evidence
    }
    policy.passage
  } else { policy.live }
}
#let _deixis-replayable(passage, live, id: none, of: none, series: auto) = {
  // Keep the live fallback working without setup, including its missing-setup
  // diagnostic. The labelled outer sequence still lets outlines replay plainly.
  show metadata.where(label: <deixis-omission>): _deixis-live-omission
  let output = if series == auto and of == none { live } else {
    let evidence = [#metadata((id: id, series: series))<deixis-omission-evidence>]
    [#metadata((passage: passage, live: live, id: id, of: of, series: series, evidence: evidence))<deixis-omission>]
  }
  [#[#metadata(passage)<deixis-replay-passage>#output]<deixis-replay>]
}
#let _deixis-replay-passage(it) = {
  let found = it.at("children", default: ()).find(child => (
    child.func() == metadata and child.at("label", default: none) == <deixis-replay-passage>))
  if found != none { found.value }
}
#let _deixis-replay(body) = {
  show <deixis-replay>: _deixis-replay-passage
  body
}

// Registration is semantic content, separate from the deferred painted mark.
// Keeping the passage inspectable also preserves nested declaration order.
// One element only: surrounding markup whitespace would print before the mark.
#let _deixis-declaration(id, body, passage: none) = [#metadata((id: id, body: body, passage: passage))<deixis-declaration>]
#let _deixis-live-declaration(it) = it.value.body

// Inspect content that already exists; never execute contextual callbacks or
// inspect arbitrary metadata payloads. State-dependent Deixis operations are a
// barrier: moving a mark past a reset, settings update, or body attachment would
// change its meaning. Such content keeps its normal live evaluation order.
#let _deixis-find-declarations(value) = {
  let items = ()
  let barrier = false
  let children = ()
  if type(value) == content {
    // Headings are lifecycle boundaries: native show rules commonly reset note
    // streams before their title. Keep nested originals in live order with the
    // heading and following content, even though the generated update is not
    // inspectable yet. Numeric paint hints can still be prepared across it.
    if value.func() == heading { barrier = true }
    if value.func() == metadata {
      if value.has("label") and value.label == <deixis-paint-priorities> {
        return (items: ((source: value, gates: ()),), barrier: false)
      }
      if value.has("label") and value.label == <deixis-declaration> {
        let nested = _deixis-find-declarations(value.value.passage)
        return (items: ((source: value, gates: ()),) + nested.items, barrier: nested.barrier)
      }
      if value.has("label") and value.label == <deixis-omission> {
        let policy = value.value
        let live = _deixis-find-declarations(policy.live)
        let passage = _deixis-find-declarations(policy.passage)
        // Keep both branches inspectable, hoisting only the selected branch's
        // registrations. Never publish a second omitted identity from a hoist.
        let condition = (of: policy.of, series: policy.series)
        let gated(items, omitted) = items.map(it => it + (
          gates: it.gates + ((policy: condition, omitted: omitted),)))
        // Publish named omissions at declaration time too, even when the
        // containing endnote is never printed. Later attachments need that
        // decision without executing the containing body.
        let evidence = if policy.of == none and policy.id != none {
          ((source: policy.evidence,
            gates: ((policy: condition, omitted: true),)),)
        } else { () }
        // A deferred body may paint after settings change. Its hoisted original
        // must paint with the same decision that selected its registration.
        let decisions = if policy.of == none and policy.id != none {
          (false, true).map(omitted => (
            source: [#metadata((id: policy.id, omitted: omitted))<deixis-creation-decision>],
            gates: ((policy: condition, omitted: omitted),),
          ))
        } else { () }
        return (items: decisions + evidence + gated(live.items, false) + gated(passage.items, true),
          barrier: live.barrier or passage.barrier)
      }
      return (items: (), barrier: false)
    }
    let fields = value.fields()
    if fields.at("key", default: none) in ("deixis-system", "deixis-omission-policy") {
      return (items: (), barrier: true)
    }
    children = fields.values()
  } else if type(value) == array { children = value }
  else if type(value) == dictionary { children = value.values() }
  for child in children {
    let nested = _deixis-find-declarations(child)
    items += nested.items
    barrier = barrier or nested.barrier
  }
  (items: items, barrier: barrier)
}

#let _deixis-body-declarations(body) = {
  let found = _deixis-find-declarations(body)
  // Numeric ordering hints have no state effects and can cross a registration
  // barrier. Stateful declarations keep their original live ordering there.
  let items = if found.barrier { found.items.filter(it => it.source.label == <deixis-paint-priorities>) } else { found.items }
  if items.len() == 0 { return (body: body, declarations: []) }
  let values = items.map(it => it.source.value)
  let prepared = {
    // Suppress only the exact operations moved out of this body. Declarations
    // produced later by a contextual callback retain their live registration.
    show metadata.where(label: <deixis-declaration>): it => {
      if it.value not in values { it.value.body }
    }
    show metadata.where(label: <deixis-paint-priorities>): it => {
      if it.value not in values { it }
    }
    show metadata.where(label: <deixis-omission-evidence>): it => {
      if it.value not in values { _deixis-live-omission-evidence(it) }
    }
    body
  }
  let declarations = items.map(it => {
    if it.gates.len() == 0 { it.source } else { context {
      if it.gates.all(g => _deixis-omission-decision(g.policy) == g.omitted) { it.source }
    } }
  }).join()
  (body: prepared, declarations: declarations)
}
