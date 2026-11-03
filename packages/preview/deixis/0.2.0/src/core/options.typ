// Producer-boundary validation. Container options are opaque values forwarded
// only to the body container, never through mark/body/connector style scoping.
#let _deixis-check-container-options(options, extra: (:)) = {
  assert(type(options) == dictionary, message: "deixis: container-args must be a dictionary.")
  assert("label" not in extra, message: "deixis: label was removed in 0.2; use id to name a note, or of to attach its body.")
  let removed = extra.keys().filter(k => k in ("link", "link-ports", "link-waypoints", "link-marks", "link-heads"))
  assert(removed.len() == 0, message: "deixis: " + removed.join(", ") + " was removed in 0.2; use connector. "
    + "A route name is shorthand, e.g. connector: \"curve\"; otherwise connector: (route: ..., ports: ..., via: ..., heads: ...). "
    + "link-marks: \"body\" becomes heads: \"stealth\"; \"both\" becomes heads: (mark: \"stealth\", body: \"stealth\").")
  assert(extra.len() == 0,
    message: "deixis: Unknown note option(s) " + repr(extra.keys())
      + ". Put native/custom container options in container-args: (...).")
  assert(options.keys().all(k => k not in ("stroke", "fill", "radius")),
    message: "deixis: Set stroke, fill, and radius as note options, outside container-args.")
}
