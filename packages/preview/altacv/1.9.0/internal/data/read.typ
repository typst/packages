// `_read-cv`: the caller's CV checked, canonicalised and split into
// its column sections' entries, before anything renders. Runs after
// `_merge-options`, as some checks read the preferences.

#import "../util/checks.typ": _check-type, _check-unknown-keys, _require
#import "../util/fields.typ": _field
#import "../util/values.typ": _map-at
#import "canonical.typ": _canonical-cv, _kebab
#import "sections.typ": _cv-keys, _read-sections
#import "cv-checks.typ": _check-root

// The CV's field names as rendering reads them: kebab-case, like the
// options (#390). `_read-cv` maps them after every check, so a message
// names the field the caller wrote (`work[].startDate`). Keys that are
// data keep their spelling: `identifiers` schemes (`arXiv`) and any
// `custom` namespace but altacv's own.
#let _kebab-fields(v) = if type(v) == dictionary {
  v
    .pairs()
    .map(((k, x)) => (
      _kebab(k),
      if k == "identifiers" { x } else if k == "custom" {
        _map-at(x, "altacv", _kebab-fields)
      } else { _kebab-fields(x) },
    ))
    .to-dict()
} else if type(v) == array { v.map(_kebab-fields) } else { v }

// A bare-string `basics.image` as a `path` from `internal/`, where it
// has always resolved, so the standalone header and the template's
// mapping (`adapter/`) frame the same file. `path()` resolves from this
// file, in `internal/data/`; a root-relative `/…` reads the same here.
// An empty string or `bytes` is no image, and drops out.
#let _image-path(cv) = {
  let image = cv.basics.at("image", default: none)
  if type(image) in (str, bytes) and image.len() == 0 {
    let _ = cv.basics.remove("image")
  } else if type(image) == str {
    cv.basics.image = path(
      if image.starts-with("/") { image } else { "../" + image },
    )
  }
  cv
}

// `(cv, sections, json-resume)`: the canonical CV and each column
// section's entries, their field names kebab-case for rendering
// (`_kebab-fields`), after every check has named the fields as the
// caller wrote them; and the canonical CV as checked, in JSON Resume's
// camelCase, for the template's mapping (`adapter/json-resume.typ`),
// its sections only the entries that render, as the standalone
// renderers get them. `focus-areas` isn't a CV key, but kept whole.
#let _read-cv(cv, prefs) = {
  _check-type("cv", cv, (dictionary,), "a CV data dictionary")
  // The only required field.
  let basics = cv.at("basics", default: none)
  _require(
    "cv.basics.name",
    basics,
    type(basics) == dictionary and _field(basics, "name") != none,
    "set (a non-empty string; every other field is optional)",
  )
  // A misspelt section (`publication:`) would otherwise vanish silently.
  _check-unknown-keys(cv.keys(), _cv-keys, "CV top-level")
  let cv = _canonical-cv(cv, prefs)
  _check-root(cv, prefs)
  let cv = _image-path(cv)
  let sections = _read-sections(cv, prefs)
  (
    cv: _kebab-fields(cv),
    sections: _kebab-fields(sections),
    json-resume: cv
      + sections.pairs().filter(((key, _)) => key in cv).to-dict(),
  )
}
