#import "core/internal.typ": *
#import "core/html.typ": _deixis-html-link
#import "core/references.typ": *
#import "core/native.typ": *

/// A styled, clickable cross-reference to a specific note.
///
/// - ..targets (arguments): The positional target label (e.g., `<my-note>`) to reference.
/// - supplement (auto, content, function, none): The prefix, or a function receiving the selected note's metadata element. Set to `none` for just the number.
/// - form (str): `"normal"` for note markers or `"page"` for native page references to the selected destination.
/// - marker-style (auto, function): A custom styling function `(string) => content` for the reference number. If `auto`, it inherits the note's original marker style.
/// - celibate-marker (str): The marker displayed for celibate notes.
///
/// -> content
#let deixis-ref(
  /// The positional target `label` (e.g., `<my-note>`) to reference.
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// Let's create some test notes
  /// #deixis-margin-note(id: <note-a>)[Test note A.]
  /// #deixis-margin-note(id: <note-b>)[Test note B.]
  /// #deixis-margin-note(id: <note-c>)[Test note C.]
  ///
  /// Single reference: #deixis-ref(<note-a>)
  /// ```
  ///
  /// - Compatible automatic decimal markers are sorted; consecutive runs of three or more become ranges.
  ///   Mixed counters, series, numbering rules, or styles retain the input order.
  /// ```example
  /// Multiple reference: #deixis-ref(<note-a>, <note-b>, <note-c>)
  /// ```
  ///
  /// - The last positional argument, if of type `content` or `str`, will be interpreted as `deixis-ref.supplement`.
  /// ```example
  /// #deixis-ref(<note-b>)[Comment]
  /// ```
  ///
  /// -> arguments
  ..targets,
  /// The prefix to display before the number (e.g., `[Note]`). Set to `none` for just the number.
  ///
  /// ```example
  /// #deixis-ref(<note-c>, supplement: [Todo])
  /// ```
  ///
  /// A function receives the selected mark/body metadata element, as with native
  /// references. An unprinted standalone body supplies unlocated metadata.
  /// -> auto | content | function | none
  supplement: auto,
  /// `"normal"` displays note markers; `"page"` uses Typst's page reference
  /// formatting at the selected body/mark destination. An unprinted standalone
  /// body has no destination and displays the celibate marker.
  /// -> str
  form: "normal",
  /// A custom styling function `(string) => content` for the reference number. If `auto`, it inherits the note's original marker style.
  /// -> auto | function
  marker-style: auto,
  /// The marker displayed for celibate notes.
  /// -> str
  celibate-marker: "?",
) = {
  assert(form in ("normal", "page"), message: "deixis: Reference form must be normal or page.")
  let named = targets.named()
  let fallback = named.remove("_fallback", default: auto)
  if named.len() > 0 {
    panic("deixis: Unknown named argument(s) " + repr(targets.named().keys()) + " passed to #deixis-ref.")
  }
  let targets = targets.pos()
  if targets.len() == 0 { return none }

  let supplement = supplement
  if type(targets.last()) in (content, str) {
    if supplement != auto {
      panic("deixis: #deixis-ref only accepts supplement as named or the last positional argument.")
    }
    supplement = targets.remove(-1)
  }
  if targets.any(it => type(it) != label) {
    panic("deixis: #deixis-ref only accepts one last positional content argument as supplement.")
  }

  if targets.len() == 0 { return none }

  let meta-tags = [#metadata((targets: targets.map(str)))<deixis-ref-marker>]

  let content = context {
    for target in targets { _deixis-check-omitted(target) }
    let sys = deixis-system.final()
    // Native references through the setup bridge (citations, headings, figures)
    // cannot name an annotation unless the key is a registered ID or one of the
    // private destination labels; return them without building the index.
    let key = str(targets.first())
    if (targets.len() == 1 and fallback != auto and key not in _deixis-registry(sys).id-index
      and not key.starts-with("deixis-body-") and not key.starts-with("deixis-mark-")) {
      return fallback
    }
    let index = _deixis-reference-index(details: form == "page" or type(supplement) == function)
    let results = ()
    let seen = (:)

    for target in targets {
      let resolved = _deixis-reference-target(index, target)
      if resolved == none {
        // Preserve native references, including user show rules and supplements.
        let native = if targets.len() == 1 and fallback != auto { fallback } else {
          ref(target, supplement: supplement, form: form)
        }
        results.push((native: native, int-val: none, m-style: auto))
        continue
      }
      if resolved.uid in seen { continue }
      seen.insert(resolved.uid, true)
      let data = resolved.data
      if form == "page" {
        let native = if resolved.dest-label == none { celibate-marker } else {
          // Keep native localization, destination-page numbering, and functional
          // supplements. The private label prevents the bridge from intercepting
          // this generated reference again after its deferred context is realized.
          [#ref(resolved.dest-label, form: "page",
            supplement: if results.len() == 0 { supplement } else { none })<deixis-native-page-ref>]
        }
        results.push((native: native, int-val: none, m-style: auto))
        continue
      }
      let marker-str = _deixis-evaluate-marker-str(data)
      if marker-str == none { marker-str = celibate-marker }
      let m-style = if marker-style != auto { marker-style } else {
        data.at("marker-style", default: data.at("mark-marker-style", default: auto))
      }
      let int-val = none
      // Only automatically numbered decimal markers can form a range.
      if data.at("marker", default: auto) == auto and data.at("count", default: none) != none {
        if type(marker-str) == str and marker-str.match(regex("^[0-9]+$")) != none {
          int-val = int(marker-str)
        } else if type(marker-str) == int {
          int-val = marker-str
          marker-str = str(marker-str)
        }
      }
      results.push((dest: resolved.dest, html-dest: resolved.html-dest, marker-str: marker-str, int-val: int-val,
        m-style: m-style, element: resolved.at("element", default: none), count-id: data.at("count-id", default: none),
        series: data.at("series", default: none), numbering: data.at("numbering", default: none)))
    }

    let valid-styles = results.filter(r => r.m-style != auto)
    let master-style = if valid-styles.len() > 0 { valid-styles.first().m-style } else {
      let raw-m-style = _deixis-resolve-typed-param(sys, auto, "marker-style", "rest", component: "mark")
      if raw-m-style != auto { raw-m-style } else { it => super(it) }
    }

    results = results.map(r => {
      if r.m-style == auto { r.insert("m-style", master-style) }
      r
    })

    let format-num(res, is-first) = {
      let num = (res.m-style)(res.marker-str)
      let prefix = if is-first and type(supplement) == function { supplement(res.element) } else { supplement }
      if is-first and prefix not in (auto, none, [], "") {
        [#prefix~#num]
      } else {
        num
      }
    }

    let linked(res, body) = if res.dest == none { body }
      else if _std-target() == "html" and res.html-dest != none { _deixis-html-link(res.html-dest, body) }
      else { _std-link(res.dest, body) }

    // Sorting/ranges apply only to a single compatible counter and style. Mixed
    // streams retain the caller's order and each note's own marker formatting.
    let first = results.first()
    let separator-style = if form != "page" and results.all(r => r.m-style == first.m-style) { master-style } else { it => it }
    let all-ints = results.all(r => r.int-val != none and r.count-id != none
      and r.count-id == first.count-id and r.series == first.series
      and r.numbering == first.numbering and r.m-style == first.m-style)
    let formatted-content = ()

    if not all-ints {
      for (i, res) in results.enumerate() {
        formatted-content.push(if "native" in res { res.native } else { linked(res, format-num(res, i == 0)) })
        if i < results.len() - 1 { formatted-content.push(separator-style([, ])) }
      }
    } else {
      let sorted = results.sorted(key: r => r.int-val)
      let runs = ()
      let current-run = (sorted.first(),)

      for i in range(1, sorted.len()) {
        let prev = sorted.at(i - 1)
        let curr = sorted.at(i)
        if curr.int-val == prev.int-val + 1 {
          current-run.push(curr)
        } else {
          runs.push(current-run)
          current-run = (curr,)
        }
      }
      runs.push(current-run)

      for (i, run) in runs.enumerate() {
        let is-first = (i == 0) // Only prepend supplement to the very first item

        if run.len() == 1 {
          let r0 = run.first()
          formatted-content.push(linked(r0, format-num(r0, is-first)))
        } else if run.len() == 2 {
          let r0 = run.first()
          let r1 = run.last()
          formatted-content.push(linked(r0, format-num(r0, is-first)))
          formatted-content.push(separator-style([, ]))
          formatted-content.push(linked(r1, (r1.m-style)(r1.marker-str)))
        } else {
          let r0 = run.first()
          let r1 = run.last()
          formatted-content.push(linked(r0, format-num(r0, is-first)))
          formatted-content.push(separator-style([–]))
          formatted-content.push(linked(r1, (r1.m-style)(r1.marker-str)))
        }
        if i < runs.len() - 1 { formatted-content.push(separator-style([, ])) }
      }
    }

    formatted-content.join()
  }

  [#meta-tags#content]
}

/// A show rule to automatically convert `@note-label` to `#deixis-ref(<note-label>)`.
///
/// Installed by `deixis-setup-notes`.
///
/// - body (content): The content of the document.
///
/// -> content
#let _deixis-show-refs(body) = {
  show ref: it => if it.has("label") and it.label == <deixis-native-page-ref> { it } else {
    deixis-ref(it.target, supplement: it.supplement, form: it.form, _fallback: it)
  }

  body
}
