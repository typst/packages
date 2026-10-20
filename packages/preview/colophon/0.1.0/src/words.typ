/// True for the element types whose rendered form is a number or
/// bracket synthesized later, during layout -- never real prose, so
/// always safe to drop from a word count. Crucially, this only needs
/// to catch `ref` (a bare `@key`, *before* citation/cross-reference
/// resolution rewrites it into visible text) because `extract-text`
/// only ever runs on the pre-layout body `instrument()` captured, never
/// on laid-out, queried content -- see `instrument.typ`. `metadata` is
/// handled separately, just below -- some of it (see
/// `palimpsest-clean-text`) needs to be looked *into*, not skipped.
#let is-reference-like(func) = func == cite or func == ref or func == label

/// Content colophon should count in place of a metadata element whose
/// *visible* rendering it can never see, for one specific, known
/// reason: `@preview/palimpsest`'s `passage()`/`add()`/`del()`/`rep()`
/// all render their actual output through a `context` block --
/// structurally opaque to this pre-layout walk, the same way any
/// `context` value is -- *even in clean mode*. Found directly, testing
/// this package combined with palimpsest for the first time: a whole
/// `passage(...)[...]` call's text, marked or not, came back as zero
/// words.
///
/// The fix doesn't need to see through that `context` at all, because
/// each of those functions *also* emits an ordinary, non-context
/// `metadata` element first, holding exactly what clean mode shows --
/// `passage`'s own `contexture.anchor("palimpsest-passage", (...,
/// raw-body: body, ...))` holds the whole passage's real content
/// (however it decides to route through `add`/`del`/`rep`, or neither);
/// each of those, in turn, marks its own contribution with
/// `metadata((tag: "palimpsest-mark", kind: ..., old: ..., new:
/// ...))`, where `new` is, by construction, exactly what clean mode
/// renders for every kind palimpsest has (the added text for `add`,
/// the replacement for `rep`, and `none` for `del`/`suppress` -- clean
/// mode shows nothing for either, and `new` already reads `none` for
/// both without this needing to know that specifically).
///
/// This is real, narrow coupling to palimpsest's own, undocumented
/// metadata shape, not a generic mechanism -- accepted deliberately
/// (see CLAUDE.md, "Phase 4") because there is no other way to get a
/// correct clean-mode word count for a manuscript that also uses
/// palimpsest, and because both shapes are small, stable implementation
/// details this package already depends on being told about if they
/// ever change. Returns `none` for any other `metadata`, `contexture`'s
/// own (checkitoff's own anchors included) or a bare Typst one --
/// unaffected, since none of those hide anything behind `context` to
/// begin with.
#let palimpsest-clean-text(value) = {
  if type(value) != dictionary { return none }
  let tag = value.at("tag", default: none)
  if tag == "contexture-anchor" and value.at("kind", default: none) == "palimpsest-passage" {
    value.at("raw-body", default: none)
  } else if tag == "palimpsest-mark" {
    value.at("new", default: none)
  } else {
    none
  }
}

/// Recursively extracts the literal prose text of `node` -- the same
/// structural-walk shape as `contexture.is-blank`/`collect-metadata`,
/// specialized for word counting rather than presence-testing:
///
/// - a reference/citation contributes nothing (`is-reference-like`);
/// - Typst's own inter-word `space` element (an internal, unexported
///   function -- matched by `repr()` since it can't be named directly,
///   the same workaround `contexture.strip-labels` already uses for
///   `sequence`) and `parbreak`/`linebreak` all contribute a single
///   space, so two text fragments that were only adjacent because
///   something between them got dropped never silently fuse into one
///   word (found directly: without this, "it <citation> World" became
///   "itWorld");
/// - a `table`'s cells are always skipped, `count-captions:` or not --
///   tabular data isn't prose, and (found directly) cells sit with no
///   space/parbreak between them, so concatenating their text the same
///   way as running prose fuses adjacent cells into one nonsense token;
/// - a `figure`'s own `caption` is additionally skipped by default
///   (`count-captions: false`) -- real prose everywhere else in the
///   same node still counts.
#let extract-text(node, count-captions: false) = {
  let t = type(node)
  if t == str {
    // A field (or an argument passed straight through, like an
    // abstract's `body`) is just as often a plain string as content --
    // `lorem(...)`, notably, returns one (verified directly: `type(lorem(5))
    // == str`, not `content`, in this Typst version) -- so this needs
    // handling at every point `content` is, not only at the top level.
    return node
  }
  if t == content {
    let f = node.func()
    if f == metadata {
      let clean = palimpsest-clean-text(node.value)
      return if clean != none { extract-text(clean, count-captions: count-captions) } else { "" }
    }
    if is-reference-like(f) {
      return ""
    }
    if repr(f) == "space" or f == parbreak or f == linebreak {
      return " "
    }
    if f == table {
      // Always excluded, regardless of `count-captions:` -- a table's
      // cells sit right next to each other with no space/parbreak
      // element between them (unlike running prose), so concatenating
      // their text the same way paragraphs are concatenated silently
      // fuses adjacent cells into one nonsense token (found directly: a
      // 2-cell row "A" / "B" extracted as "AB", one word instead of the
      // two -- or worse, unrelated multi-word cells glued together).
      // Tabular data isn't prose either way, so it's simplest to leave
      // it out entirely rather than try to reconstruct cell boundaries.
      return ""
    }
    if node.has("text") {
      return node.text
    }
    let fields = node.fields()
    if not count-captions and f == figure {
      // `let _ = ...`, not a bare statement: `.remove()` returns the
      // removed *content* itself, which would otherwise become a
      // dangling value this `if` (no `else`) leaves in the block,
      // auto-joined against whatever follows -- found directly, as
      // "cannot join content with dictionary" a few lines down, from
      // joining a stray caption against `word-counts-by-section`'s own
      // dict accumulator, which does the identical removal.
      let _ = fields.remove("caption", default: none)
    }
    // `t2 == content` only here -- *not* also `str`, on purpose, even
    // though `extract-text` itself accepts a bare string at its own
    // entry point (see above). Tried including `str` fields found this
    // way too, and it immediately picked up things that have nothing
    // to do with prose: `bibliography(...)`'s own `sources` field (an
    // array holding the raw `.bib` *path* string) and, worse, an
    // internal state-machinery field (a literal state key string like
    // `"palimpsest-current-anchors"`) buried inside a `state.update(...)`
    // content node -- both found directly, both counted as words.
    // Blindly descending into *every* string-typed field of *any*
    // element is fundamentally different from being *handed* a string
    // deliberately by a caller who already knows it's meant as prose
    // (an abstract's `raw-body`, `lorem(...)`'s own return value) --
    // only the latter is safe.
    return fields.values().map(v => {
      let t2 = type(v)
      if t2 == content {
        extract-text(v, count-captions: count-captions)
      } else if t2 == array {
        v.map(x => if type(x) == content {
          extract-text(x, count-captions: count-captions)
        } else {
          ""
        }).join("")
      } else {
        ""
      }
    }).join("")
  }
  ""
}

/// A "word" is any whitespace-delimited token containing at least one
/// letter or digit -- drops the stray, meaning-free tokens that
/// stripping a reference sometimes leaves behind (a comma immediately
/// after a dropped citation becomes its own, orphaned token once the
/// citation itself contributes no text: "...it #cite(<x>), see..." ->
/// "...it , see..."). Deliberately not "alphabetic only": a manuscript
/// is full of real numeral words (sample sizes, p-values) that must
/// still count.
#let count-words(s) = {
  let word-re = regex("[\p{L}\p{N}]")
  s.split(regex("\s+")).map(w => w.trim()).filter(w => w != "" and w.match(word-re) != none).len()
}

/// Walks `body` once, bucketing its prose text by the nearest enclosing
/// heading whose own `depth` is `<= level` (so `level: 1` starts a new
/// bucket at every top-level `=` section, leaving any `==`/`===`
/// subheading's own title counted as ordinary body text of whichever
/// top-level bucket it falls under -- only a bucket-starting heading's
/// own title is excluded from the count, as a purely structural label).
/// Content before the first such heading, if any and non-empty, is
/// returned under `"(before any heading)"`.
///
/// Bucketing by *string concatenation first, word count second* --
/// exactly like `extract-text`/`count-words` above, and for the same
/// reason: splitting and counting each fragment independently would
/// double-count a token stray-split across a dropped reference.
// Threaded explicitly through `walk` below as an ordinary return value,
// never captured and mutated by a nested closure -- Typst only allows
// mutating a variable captured from an *enclosing* scope, not one two
// or more closure calls removed (`ensure`/`append`/`walk` each calling
// the next, all sharing one mutable outer binding, hit exactly this and
// failed to compile with "variables from outside the function are
// read-only"; found directly, not anticipated). `order` is the section
// names in first-seen order; `text` maps each to its accumulated
// string; `current` is the section new text is appended to right now.
#let append-text(state, s) = {
  let order = state.order
  let text = state.text
  if state.current not in text {
    order = order + (state.current,)
    text.insert(state.current, "")
  }
  text.insert(state.current, text.at(state.current) + s)
  (order: order, text: text, current: state.current)
}

/// Walks `body` once, bucketing its prose text by the nearest enclosing
/// heading whose own `depth` is `<= level` (so `level: 1` starts a new
/// bucket at every top-level `=` section, leaving any `==`/`===`
/// subheading's own title counted as ordinary body text of whichever
/// top-level bucket it falls under -- only a bucket-starting heading's
/// own title is excluded from the count, as a purely structural label).
/// Content before the first such heading, if any and non-empty, is
/// returned under `"(before any heading)"`.
///
/// Bucketing by *string concatenation first, word count second* --
/// exactly like `extract-text`/`count-words` above, and for the same
/// reason: splitting and counting each fragment independently would
/// double-count a token stray-split across a dropped reference.
#let word-counts-by-section(body, level: 1, count-captions: false) = {
  let walk(node, state) = {
    let t = type(node)
    if t == str {
      // See `extract-text`'s identical case for why -- `lorem(...)` and
      // some fields are plain strings, not content.
      append-text(state, node)
    } else if t == content {
      let f = node.func()
      if f == heading and node.at("depth", default: 1) <= level {
        let name = extract-text(node.body, count-captions: count-captions)
        (order: state.order, text: state.text, current: name)
      } else if f == metadata {
        // See `extract-text`'s identical rule (`palimpsest-clean-text`)
        // above for why this isn't simply `is-reference-like`.
        let clean = palimpsest-clean-text(node.value)
        if clean != none { walk(clean, state) } else { state }
      } else if is-reference-like(f) {
        state
      } else if repr(f) == "space" or f == parbreak or f == linebreak {
        append-text(state, " ")
      } else if f == table {
        // Always excluded -- see `extract-text`'s identical rule above.
        state
      } else if node.has("text") {
        append-text(state, node.text)
      } else {
        let fields = node.fields()
        if not count-captions and f == figure {
          // `let _ = ...`: see `extract-text`'s identical removal above.
          let _ = fields.remove("caption", default: none)
        }
        // `.fold()`, not a `for` loop reassigning `state` -- a `for`
        // loop is itself a value-producing expression in Typst (its
        // per-iteration bodies auto-join, the same way markup content
        // does), and mixing that with a `state` dictionary threaded
        // through by reassignment failed to compile ("cannot join
        // content with dictionary"), found directly. `.fold()` has no
        // such ambiguity: it's a plain function call.
        //
        // `t2 == content` only -- not also `str` -- for the identical
        // reason `extract-text`'s own field recursion doesn't either:
        // see its comment for the two concrete false positives found
        // (a bibliography's own `.bib` path, an internal state key)
        // recursing into *every* string field picked up.
        fields.values().fold(state, (st, v) => {
          let t2 = type(v)
          if t2 == content {
            walk(v, st)
          } else if t2 == array {
            v.fold(st, (st2, x) => if type(x) == content { walk(x, st2) } else { st2 })
          } else {
            st
          }
        })
      }
    } else if t == array {
      node.fold(state, (st, x) => walk(x, st))
    } else {
      state
    }
  }

  let init = (order: (), text: (:), current: "(before any heading)")
  let final = walk(body, init)

  final.order
    .map(name => (section: name, words: count-words(final.text.at(name))))
    .filter(row => row.words > 0)
}
