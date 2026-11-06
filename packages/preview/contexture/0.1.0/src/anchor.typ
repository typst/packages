#import "utils.typ": collect-metadata

/// Marks a location in the current document with a namespaced,
/// queryable piece of data — the one primitive every "cite this spot
/// from another document" feature in this ecosystem is built from
/// (palimpsest's `passage`, checkitoff's `check`, and any future satellite
/// that needs the same trick).
///
/// `kind` namespaces the anchor so two packages can never collide even
/// if they happen to pick the same `id` scheme — by convention, prefix
/// it with the owning package's name (`"checkitoff-item"`,
/// `"palimpsest-passage"`). `payload` is whatever data that package
/// needs back when it later resolves this anchor (`anchors`, below) —
/// entirely opaque to `contexture` itself.
///
/// Deliberately returns *only* the metadata element, not `body` — unlike
/// a full `passage()`/`check()`, which each still decide for themselves
/// how (or whether) to render their own content around it. Emitting the
/// metadata and rendering the content are two different concerns; this
/// function is only the first one.
#let anchor(kind, payload) = [#metadata((tag: "contexture-anchor", kind: kind, ..payload)) <contexture-anchor>]

/// Every anchor of the given `kind`, in document order, from anywhere in
/// the bundle — including a document other than the one this is called
/// from, which is the entire point (a satellite resolving pages from the
/// manuscript; the manuscript resolving something from a satellite; one
/// satellite resolving another). Must be called from within a `context`.
#let anchors(kind) = query(<contexture-anchor>).filter(el => el.value.kind == kind)

/// Structural counterpart to `anchors`: finds every anchor of `kind`
/// already sitting inside an in-memory content value `body` — one that
/// hasn't been (and might never be) placed into any document this
/// compile. `anchors` can't do this: `query()` only ever sees content
/// that has actually been laid out somewhere.
///
/// Exists for exactly one confirmed need so far: a satellite's
/// `side-content` (`satellite.typ`) that has to register an anchor's
/// metadata in the manuscript even when the satellite carrying that
/// anchor's *rendering* isn't built this compile — palimpsest's `letter`
/// satellite, skipped on a fast manuscript-only preview, still needs its
/// exchange anchors registered so a "no matching exchange" check
/// elsewhere doesn't false-positive. Pair with `reemit` below to actually
/// place what this finds.
#let collect-anchors(body, kind) = collect-metadata(body, "contexture-anchor").filter(v => v.kind == kind)

/// Re-emits one anchor payload previously found by `collect-anchors` —
/// registers it as a placed anchor here, without rendering whatever
/// content it was originally attached to.
#let reemit(collected) = [#metadata(collected) <contexture-anchor>]
