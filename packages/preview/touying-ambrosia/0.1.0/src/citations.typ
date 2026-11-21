#import "touying.typ": utils
#import "assets.typ"
#import "utils/metadata.typ": is-kind
#import "utils/visibility.typ": hiding-cover, is-covered as _is-covered

// Rendering decisions use visible, queryable footnotes.
#let footcite-once = state("ambrosia-footcite-once", true)
#let footcite-marker = state("ambrosia-footcite-marker", "author-year")
#let _compact-style = assets.read-asset(assets.asset-paths.citation-style)
#let marker-modes = ("author-year", "number", "local", "key")
#let _footcite-label-prefix = "ambrosia-footcite:"

// Native refs synthesize cite elements too. Explicit styles still take priority.
#let apply-inline-citation-style(marker: "author-year", body) = {
  set cite(style: _compact-style) if marker == "author-year"
  body
}

#let _data(note) = {
  if note.func() == footnote and is-kind(note.body, "ambrosia-citation") { note.body.value } else { none }
}

#let _slide-at(loc) = {
  let markers = query(selector(<touying-metadata>).before(loc, inclusive: true))
    .filter(it => is-kind(it, "touying-new-slide"))
  if markers.len() > 0 { markers.last().location() } else { none }
}

#let _scope-id(scope) = {
  if scope != none { return "scope:" + scope }
  // Unscoped keys retain the package's once-per-presentation semantics.
  // Give separate bibliographies an explicit scope when they reuse a key.
  "default"
}

#let _notes(data, loc) = {
  let source = _scope-id(data.scope)
  query(footnote).filter(note => {
    let other = _data(note)
    (other != none and not _is-covered(note) and other.key == data.key
      and _scope-id(other.scope) == source)
  })
}

#let _scoped-cite(data, form: "normal", style: auto, supplement: none) = {
  let citation = cite(data.key, form: form, style: style, supplement: supplement)
  if data.scope != none {
    [#citation#std.label("ambrosia-citation-scope:" + data.scope)]
  } else { citation }
}

#let _is-primary(note) = {
  if _is-covered(note) { return false }
  let data = _data(note)
  let notes = _notes(data, note.location())
  let first = notes.first()
  let first-on-page = notes.find(other => other.location().page() == note.location().page())
  ((not footcite-once.get() or _slide-at(note.location()) == _slide-at(first.location()))
    and first-on-page.location() == note.location())
}

#let _mode(data) = {
  let marker = if data.marker == auto { footcite-marker.get() } else { data.marker }
  if type(marker) == content { "custom" } else { marker }
}

#let _identity(data) = (_scope-id(data.scope), data.key)
#let _reference-number(data) = {
  let identities = query(footnote).filter(note => _data(note) != none and not _is-covered(note))
    .map(note => _identity(_data(note))).dedup()
  identities.enumerate().find(((index, identity)) => identity == _identity(data)).first() + 1
}

#let _marker-content(data, note, raised: true) = {
  let mode = _mode(data)
  if mode == "local" {
    let content = std.numbering(data.numbering, ..counter(footnote).at(note.location()))
    if raised { super(content) } else { content }
  } else if mode == "number" {
    [\[#std.numbering(data.numbering, _reference-number(data))\]]
  } else if mode == "author-year" {
    // Keep the footnote's introspection tag separate from the locatable cite.
    box(_scoped-cite(data, style: _compact-style, supplement: data.supplement))
  } else if mode == "key" {
    [\[#if data.scope != none { data.scope + ":" }#str(data.key)\]]
  } else {
    [\[#data.marker\]]
  }
}

#let _marker(data, note) = {
  let entry = query(footnote.entry).find(it => it.note.location() == note.location())
  let destination = if entry == none { note.location() } else { entry.location() }
  // CSL's own links target the bibliography; markers should target the actual
  // full footnote entry, including when it lives on an earlier slide.
  show link: it => if it.dest == destination { it } else { link(destination, it.body) }
  link(destination, _marker-content(data, note))
}

#let _canonical(note) = {
  if _is-primary(note) { return note }
  let notes = _notes(_data(note), note.location())
  if footcite-once.get() { notes.first() }
  else { notes.find(other => other.location().page() == note.location().page()) }
}

#let _render-note(note) = context {
  let data = _data(note)
  if _is-covered(note) {
    counter(footnote).update(n => n - 1)
    return
  }
  let primary = _is-primary(note)
  if _mode(data) != "local" or not primary {
    counter(footnote).update(n => n - 1)
  }
  if primary { _marker(data, note) } else {
    let target = _canonical(note)
    _marker(if data.marker == auto { _data(target) } else { data }, target)
  }
}

/// Cite a work with a full reference at the foot of its first cited slide.
/// The theme controls repetition and the default marker. Unscoped keys use
/// Typst's normal bibliography routing; scopes distinguish reused keys.
/// -> content
#let footcite(
  /// Bibliography entry label, for example `<knuth84>`.
  /// -> label
  key,
  /// CSL style for the optional additional inline citation.
  /// -> str | bytes
  cite-style: "apa",
  /// CSL style of the full footnote entry.
  /// -> str | bytes
  foot-style: "apa",
  /// Locator or other citation supplement.
  /// -> content | none
  supplement: none,
  /// Local/reference-number pattern. Explicit numbering selects local mode unless marker is set.
  /// -> auto | str | function
  numbering: auto,
  /// Optional label for referring to this footnote elsewhere.
  /// -> auto | str | label
  label: auto,
  /// Named bibliography scope; register the list with the same scope.
  /// -> none | str
  scope: none,
  /// Theme default, author-year, number, local, key, or custom content.
  /// -> auto | str | content
  marker: auto,
  /// Add an ordinary inline citation too. Auto does so only in local mode.
  /// -> auto | bool
  inline: auto,
  /// Native citation form for the optional inline citation.
  /// -> str
  form: "normal",
) = {
  assert(scope == none or type(scope) == str, message: "Citation scope must be a string or none.")
  assert(marker == auto or marker in marker-modes or type(marker) == content,
    message: "Citation marker must be author-year, number, local, key, or custom content.")
  assert(inline == auto or type(inline) == bool, message: "Citation inline must be true, false, or auto.")
  // Explicit legacy numbering retains its meaning unless a marker mode is set.
  if numbering != auto and marker == auto { marker = "local" }
  let data = (
    kind: "ambrosia-citation", key: key, cite-style: cite-style,
    foot-style: foot-style, supplement: supplement, numbering: if numbering == auto { "1" } else { numbering },
    label: if type(label) == std.label { str(label) } else { label }, scope: scope,
    marker: marker, inline: inline, form: form,
  )
  // The real footnote must be visible to Touying's parser, outside any context.
  // This prevents its entry leaking before a pause reveals its marker.
  context {
    if data.inline == true or (data.inline == auto and _mode(data) == "local") {
      _scoped-cite(data, form: form, style: cite-style, supplement: supplement)
    }
  }
  let note = footnote(numbering: data.numbering, metadata(data))
  if data.label == auto { note } else { [#note#std.label(data.label)] }
}


/// Style only our citation footnotes; ordinary footnotes keep their own behavior.
#let apply-citation-links(body) = {
  show footnote: note => if _data(note) != none { _render-note(note) } else { note }
  show ref: it => context {
    let targets = query(it.target).filter(target => target.func() == footnote
      and _data(target) != none and not _is-covered(target))
    if targets.len() > 0 {
      let source = targets.last()
      let target = _canonical(source)
      let data = _data(source)
      _marker(if data.marker == auto { _data(target) } else { data }, target)
    } else { it }
  }
  body
}

#let apply-citation-entry-style(body) = {
  show footnote.entry: entry => if _is-covered(entry.note) { none } else if _data(entry.note) != none {
    context {
      if _is-primary(entry.note) {
        let data = _data(entry.note)
        [
          #_marker-content(data, entry.note, raised: _mode(data) == "local")#h(0.3em)
          #_scoped-cite(data, form: "full", style: data.foot-style, supplement: data.supplement)
        ]
      }
    }
  } else { entry }
  body
}

/// Construct a real Typst bibliography with optional explicit citation routing.
#let scoped-bibliography(scope: none, label: auto, hidden: false, title: none, target: auto,
  marker: "native", style: auto, ..args) = {
  let marker = if marker == auto { "native" } else { marker }
  assert(marker in ("author-year", "native"), message: "Bibliography marker must be author-year or native.")
  assert(marker != "author-year" or style == auto,
    message: "Author-year bibliography markers use Ambrosia's CSL style. Use marker: native with a custom style.")
  let style = if marker == "author-year" { _compact-style } else { style }
  if scope != none {
    assert(type(scope) == str, message: "Bibliography scope must be a string.")
    assert(target == auto, message: "Use either scope or target, not both.")
    target = selector(cite).and(std.label("ambrosia-citation-scope:" + scope))
  }
  // Forward the original arguments object to retain the caller's source span:
  // rebuilding its positional array would resolve string paths in this module.
  let element = if style == auto { bibliography(..args, title: title, target: target) }
    else { bibliography(..args, title: title, target: target, style: style) }
  let content = if label == auto { element } else {
    [#element#std.label(if type(label) == std.label { str(label) } else { label })]
  }
  if hidden {
    show bibliography: none
    content
  } else { content }
}
