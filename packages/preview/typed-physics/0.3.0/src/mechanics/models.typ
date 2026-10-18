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
// The one shared unknown a model does solve is the tension of a rope over a
// pulley joining two bodies. Those two bodies are recognized as a pair, and
// their coupled equations are solved in closed form once the rope is known to
// run along its surface and straight up from the hanging body.
//
// Recognition therefore reads the declaration graph and not the physics. The
// models below are the shapes this package solves; a situation outside them is
// named and declined rather than approximated. No figure goes through a model,
// so declining costs a reader nothing but the number.

#import "../shared/vector.typ"
#import "forces.typ"

// How far a rope's direction may deviate from the surface or from vertical and
// still count as running along it. The solver's closed form is exact only for
// that alignment, so this is a numerical tolerance, not a physical allowance.
#let rope-alignment-tolerance = 1e-6

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
  (
    id: "two-bodies-over-pulley",
    title: "two bodies joined by a rope over a pulley",
    requires: (
      "two bodies with a `mass:` joined by one rope that runs over one `pulley`: "
        + "both hang from it (an Atwood machine), or one rests on a ground or ramp "
        + "with its rope parallel to the surface while the other hangs from the pulley "
        + "on a vertical rope (a modified Atwood machine)"
    ),
    asks: ("acceleration", "tension", "normal", "friction", "regime"),
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

// ── Two bodies over a pulley ─────────────────────────────────────────────────

#let _rope-runs-over-pulley(scene, rope-name) = {
  let placed-rope = scene.connectors.find(connector => connector.name == rope-name)
  placed-rope != none and placed-rope.over != none
}

// The rope over a pulley that reaches this body, or none. A rope tied to a
// pulley without running over it is an ordinary connector and stays with
// `_shared-unknown`.
#let _pulley-rope-reaching(scene, body) = {
  let pulley-ropes = body.reached-by.filter(reaching-element => (
    reaching-element.kind == "rope"
      and _rope-runs-over-pulley(scene, reaching-element.name)
  ))
  if pulley-ropes.len() == 0 { none } else { pulley-ropes.first() }
}

// The unit direction a body's rope pulls it in. For a rope over a pulley that
// points from the body's attachment toward the wheel.
#let rope-direction-at-body(scene, body, rope-name) = {
  let attachment = body.reached-by.find(
    reaching-element => reaching-element.name == rope-name,
  )
  let placed-rope = scene.connectors.find(
    connector => connector.name == rope-name,
  )
  forces.rope-direction-leaving(placed-rope, attachment.endpoint == "start")
}

// A rope runs along a surface when its unit direction is parallel to the
// surface's tangent, which makes the cross product of the two vanish.
#let rope-runs-along-surface(scene, body, rope-name) = {
  let rope-direction = rope-direction-at-body(scene, body, rope-name)
  let misalignment-across-surface = vector.cross-product(
    rope-direction,
    body.direction,
  )
  calc.abs(misalignment-across-surface) < rope-alignment-tolerance
}

// A hanging rope runs straight up to its pulley when it has no sideways
// component and points upward.
#let rope-runs-straight-up(scene, body, rope-name) = {
  let rope-direction = rope-direction-at-body(scene, body, rope-name)
  let sideways-component = rope-direction.at(0)
  let points-up = rope-direction.at(1) > 0
  calc.abs(sideways-component) < rope-alignment-tolerance and points-up
}

// Whether a rope over a pulley joins this body to a second body the pulley
// model solves. Every refusal names the geometry that broke the closed form,
// so the author can see which rule the declaration does not meet.
#let _recognize-pulley-pair(scene, body-name, pulley-rope) = {
  let body = scene.bodies.at(body-name)
  let pulley-name = pulley-rope.far-end
  let partner-name = pulley-rope.partner
  if partner-name == body-name {
    return _unmatched(
      "both ends of its rope are on \"" + body-name + "\"",
      "a rope over a pulley joins two different bodies",
    )
  }
  if partner-name not in scene.bodies {
    return _unmatched(
      "its rope runs over pulley \"" + pulley-name + "\" to something other than a body",
      "a rope over a pulley is solved only between two bodies",
    )
  }
  let partner = scene.bodies.at(partner-name)
  if (
    body.touching != none
      or partner.touching != none
      or body.reached-by.len() > 1
      or partner.reached-by.len() > 1
  ) {
    return _unmatched(
      "one of the two bodies is also tied to something besides the pulley rope",
      "the pulley pair has one tension, shared only by the two ends of its rope",
    )
  }
  if not partner.solver-supported {
    return _unmatched(
      "\"" + partner-name + "\" is a drawing-only " + partner.shape,
      "no model in this release balances that shape",
    )
  }
  if partner.mass == none {
    return _unmatched(
      "\"" + partner-name + "\" has no `mass:`",
      "every model here starts from a weight",
    )
  }

  let contact-bodies = (body, partner).filter(
    candidate => candidate.support != none,
  )
  if contact-bodies.len() > 1 {
    return _unmatched(
      "both bodies rest on surfaces",
      "this release solves a pulley pair with at most one body on a surface",
    )
  }
  let hanging-bodies = (body, partner).filter(
    candidate => candidate.support == none,
  )
  for hanging-body in hanging-bodies {
    if hanging-body.hangs-from-element != pulley-name {
      return _unmatched(
        "\"" + hanging-body.name + "\" does not hang from pulley \"" + pulley-name + "\"",
        "the pulley pair needs each hanging body to hang from the wheel its rope runs over",
      )
    }
  }
  for contact-body in contact-bodies {
    let support-surface = scene.surfaces.at(contact-body.support)
    if support-surface.kind == "arc" {
      return _unmatched(
        "it rests on arc \"" + support-surface.name + "\"",
        "a body on a curved support follows a circular path, so its normal force depends on a speed no declaration states",
      )
    }
    if support-surface.kind not in ("ground", "ramp") {
      return _unmatched(
        "it rests on " + support-surface.kind + " \"" + support-surface.name + "\"",
        "a pulley pair is solved only when its rope runs along a ground or ramp",
      )
    }
    if not rope-runs-along-surface(scene, contact-body, pulley-rope.name) {
      return _unmatched(
        "its rope leaves it at an angle to " + support-surface.kind + " \"" + support-surface.name + "\"",
        "a rope tilted away from the surface changes the normal force, and this model needs the rope to run along the surface",
      )
    }
  }
  for hanging-body in hanging-bodies {
    if not rope-runs-straight-up(scene, hanging-body, pulley-rope.name) {
      return _unmatched(
        "the rope from \"" + hanging-body.name + "\" does not run straight up to the pulley",
        "this model needs each hanging rope to be vertical, so the tension has no sideways part",
      )
    }
  }
  _matched("two-bodies-over-pulley")
}

// The parts of a recognized pulley pair that the solver works from. The
// `pulled` body is the one on the surface when there is one, and otherwise the
// body at the rope's start. Its rope is the positive direction of the pair: a
// positive net force pulls the pulled body toward its pulley.
#let pulley-pair-of(scene, body-name) = {
  let body = scene.bodies.at(body-name)
  let pulley-rope = _pulley-rope-reaching(scene, body)
  let partner = scene.bodies.at(pulley-rope.partner)
  let contact-body = if body.support != none {
    body
  } else if partner.support != none {
    partner
  } else {
    none
  }
  let pulled-body = if contact-body != none {
    contact-body
  } else if pulley-rope.endpoint == "start" {
    body
  } else {
    partner
  }
  let opposite-body = if pulled-body.name == body.name { partner } else { body }
  (
    variant: if contact-body == none { "atwood" } else { "modified-atwood" },
    pulley: pulley-rope.far-end,
    rope: pulley-rope.name,
    pulled: pulled-body.name,
    opposite: opposite-body.name,
    contact-body: if contact-body == none { none } else { contact-body.name },
    hanging-body: if contact-body == none { none } else { opposite-body.name },
    pulled-rope-direction: rope-direction-at-body(
      scene,
      pulled-body,
      pulley-rope.name,
    ),
    opposite-rope-direction: rope-direction-at-body(
      scene,
      opposite-body,
      pulley-rope.name,
    ),
  )
}

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

  let pulley-rope = _pulley-rope-reaching(scene, body)
  if pulley-rope != none {
    return _recognize-pulley-pair(scene, body-name, pulley-rope)
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
