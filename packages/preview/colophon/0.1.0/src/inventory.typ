#import "words.typ": extract-text

/// One row per figure/table found in the manuscript span `start`..`end`
/// (see `instrument.typ`) -- unlike `words.typ`, this walks the
/// *composed* document via `query()`, not the pre-layout body: a
/// figure's own fields (`caption`, `supplement`, `counter`) aren't
/// touched by citation resolution the way inline prose is, so there's
/// no equivalent reason to avoid `query()` here, and only `query()`
/// gives the figure's real, laid-out page and resolved number in the
/// first place.
///
/// `selector(figure).after(start).before(end)` -- not a bare
/// `query(figure)` -- scopes the search to just the manuscript
/// document, for the same reason `report.typ`'s own page-count lookup
/// does: an unscoped query also matches `audit.pdf`'s own content, and
/// any other `contexture`-based satellite's, once more than one is
/// listed under `documents:`.
///
/// A labelled figure's own `item` is rendered via `ref(label)` --
/// *not* reconstructed by hand from `it.counter.at(it.location())` and
/// `it.supplement`, tried first and found wrong against a real
/// template: `@preview/unequivocal-ams`'s own `theorem` environment
/// numbers by section ("Theorem 0.1", "1.1", ...), and its own figure
/// counter's raw value turned out to reset with it, so two different
/// theorems both read back `1` from `it.counter.at(...)` -- a real,
/// silent wrong-number bug, not merely an untidy one, found only by
/// testing against an actual template with its own numbering scheme
/// rather than the default one every earlier test used. `ref(label)`
/// sidesteps the whole problem: it's the exact mechanism that already
/// prints the right, real number inside the manuscript itself, however
/// exotic the scheme, so asking it to do the same work here instead of
/// re-deriving it is both less code and strictly more correct. An
/// unlabelled figure has no `ref` to lean on, so it still falls back to
/// the manual `supplement`/`counter` reconstruction -- accurate for the
/// common, simple case every such figure in this package's own tests
/// uses, just not guaranteed to hold for every possible custom scheme
/// the way a labelled figure's `ref(...)` is.
#let figure-inventory(start, end) = {
  query(selector(figure).after(start).before(end)).map(it => {
    let lbl = it.fields().at("label", default: none)
    let item = if lbl != none {
      ref(lbl)
    } else {
      let number = it.counter.at(it.location()).at(0)
      let kind-label = if it.supplement != none { it.supplement } else { [#it.kind] }
      [#kind-label #number]
    }
    let caption-text = if it.caption != none {
      extract-text(it.caption.body)
    } else {
      none
    }
    (
      item: item,
      caption: caption-text,
      page: it.location().page(),
    )
  })
}
