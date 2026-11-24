// Which named model a situation matches, and what to say when none does.
//
// A situation reaches an answer in closed form when its unknowns can be put in
// an order where each one is determined by unknowns already found. That order
// exists whenever a body shares no unknown force with anything else that can
// move: two bodies joined by a rope share a tension, two bodies in contact
// share a pair of contact forces, and a body on a curved support carries a
// centripetal acceleration that no declaration states. Each of those couples
// equations that then have to be solved together rather than one after another.
//
// Recognition therefore reads the declaration graph and not the physics. The
// models below are the shapes this package solves; a situation outside them is
// named and declined rather than approximated. No figure goes through a model,
// so declining costs a reader nothing but the number.

// Every model this release solves, in the order a reader meets them. `asks` is
// what `solve(find:)` can request once the model matches, which is also what a
// mismatch offers in place of a guess.
#let solved-models = (
  (
    id: "single-contact-body",
    title: "a body resting on one surface",
    requires: (
      "one body with a `mass:` resting on a ground, ramp, wall, or ceiling, "
        + "carrying only the loads its own declaration states"
    ),
    asks: ("normal", "friction", "regime", "acceleration"),
  ),
  (
    id: "hanging-body",
    title: "a body hanging at rest",
    requires: (
      "one body with a `mass:` hanging from a fixed attachment, with nothing "
        + "else on the rope that holds it"
    ),
    asks: ("tension",),
  ),
)

#let model-named(model-id) = {
  let matching-models = solved-models.filter(model => model.id == model-id)
  assert(
    matching-models.len() == 1,
    message: "typed-physics: there is no model called " + repr(model-id),
  )
  matching-models.first()
}

// Surfaces whose frame is fixed by the surface itself, so a body on one of them
// is held in equilibrium across the contact. An `arc` is absent because the
// contact accelerates the body towards the centre of the curve.
#let supports-a-single-contact = ("ground", "ramp", "wall", "ceiling")

// A connector between a body and something that cannot move is what holds that
// body up rather than a joint to a second unknown, so a hanging body may have
// its rope drawn and still be balanced. One that reaches another body or runs
// over a pulley carries a single force to two places, and a body that is
// already held by a contact gains a third unknown that two force equations
// cannot find.
#let _connector-holds-up(scene, body, reaching-element) = {
  if reaching-element.kind not in ("rope", "spring") { return false }
  let far-end = reaching-element.far-end
  if far-end == none { return false }
  if far-end in scene.bodies or far-end in scene.pulleys { return false }
  body.support == none
}

// What an element joined to a body puts on it. Every one of these names an
// unknown that the body cannot be balanced without, and that balancing the body
// alone cannot find.
#let _shared-unknown-with(reaching-element) = {
  let element-kind = reaching-element.kind
  let named-element = if reaching-element.name == none { "" } else {
    " \"" + reaching-element.name + "\""
  }
  if element-kind in ("rope", "spring") {
    let reaches = if reaching-element.far-end == none { "" } else {
      " to \"" + reaching-element.far-end + "\""
    }
    return (
      "a " + element-kind + named-element + " joins it" + reaches,
      "the force that connector carries is an unknown it shares with whatever is on the other end",
    )
  }
  if element-kind == "body" {
    return (
      "body" + named-element + " rests against it",
      "two bodies in contact share a pair of contact forces that has to be found together with their motion",
    )
  }
  if element-kind == "torque" {
    return (
      "a torque turns it",
      "balancing a moment needs the line of action of the contact force, which a force balance alone does not fix",
    )
  }
  (
    "the " + element-kind + named-element + " is attached to it",
    "a rigid structure carries unknown reactions shared with everything it bears on",
  )
}

// Whether this body shares an unknown with anything else that can move, and
// what that unknown is. `touching:` is read from the body's own declaration as
// well as from its neighbour's, because either one of the pair may be the one
// that named the contact.
#let _shared-unknown(scene, body-name) = {
  let body = scene.bodies.at(body-name)
  if body.touching != none {
    return (
      "it rests against body \"" + body.touching + "\"",
      "two bodies in contact share a pair of contact forces that has to be found together with their motion",
    )
  }
  let holding-connectors = body.reached-by.filter(
    reaching-element => _connector-holds-up(scene, body, reaching-element),
  )
  if holding-connectors.len() > 1 {
    return (
      "more than one connector holds it up",
      "each one carries its own unknown force, and one balance cannot find two",
    )
  }
  for reaching-element in body.reached-by {
    if _connector-holds-up(scene, body, reaching-element) { continue }
    return _shared-unknown-with(reaching-element)
  }
  none
}

#let _matched(model-id) = (id: model-id, why-not: none)
#let _unmatched(what, why) = (id: none, why-not: (what: what, why: why))

// The model that fits this body, or the reason nothing does. Every branch
// before the match is a question the declaration answers on its own.
#let recognize-model(scene, body-name) = {
  let body = scene.bodies.at(body-name)

  if not body.solver-supported {
    return _unmatched(
      "it is a drawing-only " + body.shape,
      "no model in this release balances that shape",
    )
  }

  if body.mass == none {
    return _unmatched(
      "it has no `mass:`",
      "every model here starts from a weight",
    )
  }

  let shared-unknown = _shared-unknown(scene, body-name)
  if shared-unknown != none {
    let (what, why) = shared-unknown
    return _unmatched(what, why)
  }

  if body.support != none {
    let support-surface = scene.surfaces.at(body.support)
    if support-surface.kind == "arc" {
      return _unmatched(
        "it rests on arc \"" + support-surface.name + "\"",
        "a body on a curved support follows a circular path, so its normal force depends on a speed no declaration states",
      )
    }
    assert(
      support-surface.kind in supports-a-single-contact,
      message: (
        "typed-physics: surface \""
          + support-surface.name
          + "\" has kind "
          + repr(support-surface.kind)
          + ", which model recognition does not classify"
      ),
    )
    return _matched("single-contact-body")
  }

  if body.hangs-from != none {
    if body.hangs-from-element in scene.pulleys {
      return _unmatched(
        "it hangs from pulley \"" + body.hangs-from-element + "\"",
        "a rope over a pulley carries one tension to both of its ends, so the two sides are found together",
      )
    }
    return _matched("hanging-body")
  }

  _unmatched(
    "it is held up by nothing",
    "a body with no contact and no attachment has no force to balance its weight",
  )
}

// Whether balancing this body is a case some model handles. Drawing must never
// wait on the answer, so the views ask this first and fall back to an unsolved
// figure rather than to an error.
#let body-can-be-balanced(scene, body-name) = (
  recognize-model(scene, body-name).id != none
)

#let _model-catalogue = (
  solved-models
    .map(model => "  " + model.id + " — " + model.requires)
    .join("\n")
)

// A mismatch states the scope that was missed rather than promising to grow
// into it, and points at the views that never needed a model in the first
// place.
#let describe-mismatch(body-name, why-not) = (
  "typed-physics: no solved model matches \""
    + body-name
    + "\": "
    + why-not.what
    + ", and "
    + why-not.why
    + ".\nThis release solves:\n"
    + _model-catalogue
    + "\nscene(), fbd(), components(), forces(), and force-table() do not go "
    + "through a model and are unaffected."
)

// The model for a body, or a refusal. Callers that must produce a number go
// through this; callers that only draw ask `body-can-be-balanced` instead. The
// mismatch is described only once there is one, because a message assembled
// eagerly would be built on every successful solve.
#let require-model(scene, body-name) = {
  let recognition = recognize-model(scene, body-name)
  if recognition.id == none {
    panic(describe-mismatch(body-name, recognition.why-not))
  }
  recognition.id
}
