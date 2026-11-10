///! Plot-level scale bindings.
///!
///! Map aesthetic names to scale specs built with \@scale-continuous,
///! \@scale-viridis-d, and friends, then feed the result to \@plot via
///! the `scales:` parameter. Keying by aesthetic mirrors \@guides: a later entry
///! for the same aesthetic overrides an earlier one.

#import "utils/errors.typ": fail, fail-enum
#import "aes-keys.typ": AES-KEYS
#import "scale/bind.typ": bind-scale

/// Bind scale specifications to aesthetics.
///
/// Accepts named arguments where each key is an aesthetic (e.g., `x`, `colour`, `fill`) and each value is a scale spec from a `scale-*` constructor, or `auto` to keep the default scale. The resulting dictionary threads into the plot spec and is honoured by scale training. When two entries target the same aesthetic the later one wins, matching `guides`.
///
/// - args: Named scale specs keyed by aesthetic name.
///   - x: a scale spec for the `x` aesthetic, or `auto` for the default.
///   - y: a scale spec for the `y` aesthetic, or `auto` for the default.
///   - colour: a scale spec for the `colour` aesthetic, or `auto` for the default.
///   - fill: a scale spec for the `fill` aesthetic, or `auto` for the default.
///   - size: a scale spec for the `size` aesthetic, or `auto` for the default.
///   - alpha: a scale spec for the `alpha` aesthetic, or `auto` for the default.
///   - linewidth: a scale spec for the `linewidth` aesthetic, or `auto` for the default.
///   - stroke: a scale spec for the `stroke` aesthetic, or `auto` for the default.
///   - shape: a scale spec for the `shape` aesthetic, or `auto` for the default.
///   - linetype: a scale spec for the `linetype` aesthetic, or `auto` for the default.
///
/// Returns: Dictionary mapping aesthetic name to scale spec.
///
/// See also: `plot`, `guides`.
///
/// Pin the x domain and colour the points with a discrete viridis palette in one keyed call.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   scales: scales(
///     x: scale-continuous(limits: (0, 4)),
///     colour: scale-viridis-d(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scales(..args) = {
  if args.pos().len() != 0 {
    fail(
      "scales",
      "expects named arguments keyed by aesthetic; got "
        + str(args.pos().len())
        + " positional value(s)",
      hint: "Key each scale by aesthetic, e.g. scales(x: scale-continuous()).",
    )
  }
  let out = (:)
  for (k, v) in args.named() {
    if not AES-KEYS.contains(k) {
      fail-enum(
        "scales",
        "aesthetic",
        k,
        AES-KEYS,
        hint: "Key each scale by a known aesthetic name.",
      )
    }
    if v == auto or v == none { continue }
    if (
      type(v) != dictionary
        or v.at("kind", default: none) != "scale"
        or (
          "name" not in v
        )
    ) {
      fail(
        "scales",
        "value for '"
          + k
          + "' must be a scale spec (e.g. scale-continuous,"
          + " scale-viridis-d) or `auto` for the default; got "
          + repr(v),
      )
    }
    out.insert(k, bind-scale(k, v))
  }
  out
}
