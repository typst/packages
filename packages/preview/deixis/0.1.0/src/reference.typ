#import "core.typ": *

/// A styled, clickable cross-reference to a specific note.
///
/// - ..targets (arguments): The positional target label (e.g., `<my-note>`) to reference.
/// - supplement (auto, content, none): The prefix to display before the number (e.g., `[Note]`). Set to `none` for just the number.
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
  /// #deixis-margin-note(label: <note-a>)[Test note A.]
  /// #deixis-margin-note(label: <note-b>)[Test note B.]
  /// #deixis-margin-note(label: <note-c>)[Test note C.]
  ///
  /// Single reference: #deixis-ref(<note-a>)
  /// ```
  ///
  /// - Multiple consecutive references will be collapsed automatically.
  /// ```example
  /// Multiple reference: #deixis-ref(<note-a>, <note-b>, <note-c>)
  /// ```
  ///
  /// - The last positional argument, if of type `content` or `str`, will be interpreted as @deixis-ref.supplement.
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
  /// -> auto | content | none
  supplement: auto,
  /// A custom styling function `(string) => content` for the reference number. If `auto`, it inherits the note's original marker style.
  /// -> auto | function
  marker-style: auto,
  /// The marker displayed for celibate notes.
  /// -> str
  celibate-marker: "?",
) = {
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

  let meta-tags = targets
    .map(target => {
      [#metadata((target: str(target)))<deixis-ref-marker>]
    })
    .join()

  let content = context {
    let sys = deixis-system.final()
    let notes = sys.at("notes", default: (:))
    let id-idx = sys.at("id-index", default: (:))
    let lbl-idx = sys.at("label-index", default: (:))

    let resolve-payload(t) = {
      // check registry
      if t in lbl-idx { return notes.at(lbl-idx.at(t)) }
      if t in id-idx { return notes.at(id-idx.at(t)) }
      let raw-internal = t.replace("deixis-body-", "").replace("deixis-mark-", "")
      if raw-internal in notes { return notes.at(raw-internal) }

      // query metadata for celibate notes
      let queried = query(std.label(t))
      if queried.len() > 0 {
        let el = queried.first()
        if el.func() == metadata {
          if type(el.value) == dictionary {
            return el.value
          } else {
            // Failsafe in case the metadata payload was stripped
            return (marker-str: none, is-celibate: true)
          }
        }
      }

      return none
    }

    // Single-target resolution for the `show ref:` rule fallback
    if targets.len() == 1 {
      let t-str = str(targets.first())
      let is-deixis = false

      if resolve-payload(t-str) != none {
        is-deixis = true
      }

      if not is-deixis {
        return if fallback != auto { fallback } else { ref(targets.first()) }
      }
    }

    let results = ()

    for target in targets {
      let t-lbl = if type(target) == str { std.label(target) } else { target }
      let t-str = str(t-lbl)

      let data = resolve-payload(t-str)
      if data == none { data = (:) }

      let internal-id = data.at("internal-id", default: none)
      let marker-str = none

      if internal-id != none {
        let marks = query(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>).or(<deixis-region-mark>))

        let match = marks.find(m => (
          type(m.value) == dictionary
            and m.value.at("internal-id", default: none) != none
            and str(m.value.internal-id) == str(internal-id)
        ))

        if match != none {
          marker-str = match.value.at("marker-str", default: none)
        }
      }

      if marker-str == none {
        marker-str = _deixis-evaluate-marker-str(data)
      }

      if marker-str == none { marker-str = celibate-marker }

      let m-style = auto
      if marker-style != auto {
        m-style = marker-style
      } else {
        let mark-type = data.at("mark-type", default: "inline")
        let raw-m-style = data.at("marker-style", default: auto)
        m-style = _deixis-resolve-typed-param(
          sys,
          raw-m-style,
          "marker-style",
          mark-type,
          component: "mark",
        )
      }

      let int-val = none
      if type(marker-str) == str and marker-str.match(regex("^\d+$")) != none {
        int-val = int(marker-str)
      } else if type(marker-str) == int {
        int-val = marker-str
        marker-str = str(marker-str)
      }

      results.push((lbl: t-lbl, marker-str: marker-str, int-val: int-val, m-style: m-style))
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
      if is-first and supplement not in (auto, none) {
        [#supplement~#num]
      } else {
        num
      }
    }

    // collapsing
    let all-ints = results.all(r => r.int-val != none)
    let formatted-content = ()

    if not all-ints {
      for (i, res) in results.enumerate() {
        formatted-content.push(std.link(res.lbl, format-num(res, i == 0)))
        if i < results.len() - 1 { formatted-content.push(master-style([, ])) }
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
          formatted-content.push(std.link(r0.lbl, format-num(r0, is-first)))
        } else if run.len() == 2 {
          let r0 = run.first()
          let r1 = run.last()
          formatted-content.push(std.link(r0.lbl, format-num(r0, is-first)))
          formatted-content.push(master-style([, ]))
          formatted-content.push(std.link(r1.lbl, (r1.m-style)(r1.marker-str)))
        } else {
          let r0 = run.first()
          let r1 = run.last()
          formatted-content.push(std.link(r0.lbl, format-num(r0, is-first)))
          formatted-content.push(master-style([–]))
          formatted-content.push(std.link(r1.lbl, (r1.m-style)(r1.marker-str)))
        }
        if i < runs.len() - 1 { formatted-content.push(master-style([, ])) }
      }
    }

    formatted-content.join()
  }

  [#meta-tags#content]
}

/// A show rule to automatically convert `@note-label` to `#deixis-ref(<note-label>)`.
///
/// ```example
/// #show: deixis-show-refs
/// ```
///
/// - body (content): The content of the document.
///
/// -> content
#let deixis-show-refs(body) = {
  show ref: it => deixis-ref(it.target, supplement: it.supplement, _fallback: it)

  body
}
