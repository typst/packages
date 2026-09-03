#import "utils.typ": parse-anchor, is-blank
#import "style.typ": reviewer-color, editor-color, author-color, author-display-name, style-state
#import "diagnostics.typ": diagnose

/// State holding which reviewer/editor/author section an `exchange`/
/// `note` is currently under — set by `reviewer`/`editor`/`author` before
/// rendering their body, read as a fallback header when the anchor
/// itself doesn't parse with a number to key off of. Same "resolves by
/// document position, not call order" trick as `current-passage-anchors`
/// in `marks.typ`.
#let current-exchange-context = state("palimpsest-exchange-context", none)

/// Groups a reviewer's comments under a heading; also supplies the
/// reviewer number and color to any `exchange` inside, and to
/// `exchange`'s duplicate/orphan diagnostics.
#let reviewer(n, body) = {
  current-exchange-context.update((kind: "reviewer", n: n))
  context [
    #block(above: 1.2em, below: 0.8em)[
      #text(size: 1.15em, weight: "bold", fill: reviewer-color(n))[Reviewer #n]
    ]
  ]
  body
  current-exchange-context.update(none)
}

/// Groups the editor's comments under a heading, like `reviewer` but
/// without a reviewer number.
#let editor(body) = {
  current-exchange-context.update((kind: "editor"))
  context [
    #block(above: 1.2em, below: 0.8em)[
      #text(size: 1.15em, weight: "bold", fill: editor-color)[Editor]
    ]
  ]
  body
  current-exchange-context.update(none)
}

/// Groups one co-author's own notes under a heading, like `reviewer`/
/// `editor` but for the "author explaining their own change" workflow
/// (see `note`). `id` is the raw author id (`"bob"`, matching `<bob-3>`
/// anchors) — the heading and color come from `author-display-name`/
/// `author-color` (`style.typ`), which resolve the `set-revisions(authors:
/// ...)` registry the same way any `note`/`exchange` on a `bob-*` anchor
/// already would.
#let author(id, body) = {
  current-exchange-context.update((kind: "author", id: id))
  context [
    #block(above: 1.2em, below: 0.8em)[
      #text(size: 1.15em, weight: "bold", fill: author-color(id))[#author-display-name(id)]
    ]
  ]
  body
  current-exchange-context.update(none)
}

/// Shared renderer behind both `exchange` (3-arg form) and `note`/
/// `exchange` (2-arg form): `comment: none` means "single block" (an
/// author's own note, nothing to quote), anything else means "quoted
/// comment + response". Kept as one function, not two independent code
/// paths, so the two call shapes can never drift apart in rendering.
///
/// `term: auto` picks the header noun ("comment" for reviewer/editor,
/// "change" for author) from `set-revisions(comment-word:, change-word:)`
/// unless overridden for this one call. The *raw* `term` (possibly
/// `auto`) is stored in the `<palimpsest-exchange>` metadata rather than
/// the resolved word, so `xcomment` — which reads this metadata back
/// later, from a different position in the document — reproduces the
/// same override without needing its own copy of this resolution logic.
///
/// Bare, number-less anchors (`p.num == none` — the "pure change-tracking,
/// no particular exchange to key into" case, e.g. `<bob>` reused across
/// many notes) are exempt from the "duplicate exchange" check below:
/// reuse is the expected shape for those, not a mistake. Numbered
/// anchors keep the check unconditionally — it doesn't depend on
/// `require-exchange` (`style.typ`), which only gates the *other*
/// direction, `passage`'s "no matching exchange" (`marks.typ`).
#let exchange-core(anchor, comment, response, term: auto) = {
  [#metadata((tag: "palimpsest-exchange", anchor: anchor, comment: comment, response: response, term: term)) <palimpsest-exchange>]

  context {
    let p = parse-anchor(anchor)
    let ctx = current-exchange-context.get()
    let sty = style-state.get()
    let kind = if p != none { p.kind } else if ctx != none { ctx.kind }
    let word = if term != auto {
      term
    } else if kind == "author" {
      sty.change-word
    } else {
      sty.comment-word
    }

    let header = if p != none and p.kind == "reviewer" {
      [Reviewer #p.reviewer — #word #p.num]
    } else if p != none and p.kind == "editor" {
      [Editor — #word #p.num]
    } else if p != none and p.kind == "author" {
      let name = author-display-name(p.author)
      if p.num != none { [#name — #word #p.num] } else { [#name] }
    } else if ctx != none and ctx.kind == "reviewer" {
      [Reviewer #ctx.n]
    } else if ctx != none and ctx.kind == "editor" {
      [Editor]
    } else if ctx != none and ctx.kind == "author" {
      [#author-display-name(ctx.id)]
    } else {
      [Comment]
    }

    let bare = p != none and p.num == none
    let siblings = query(<palimpsest-exchange>).filter(el => el.value.anchor == anchor)
    let dup = if not bare and siblings.len() > 1 {
      diagnose("duplicate exchange " + str(anchor), always: true)
    }

    let orphan = if not query(<palimpsest-passage>).any(el => el.value.anchors.contains(anchor)) {
      diagnose("comment " + str(anchor) + " has no matching revision in the manuscript", always: true)
    }

    let empty-noun = if comment == none { "note" } else { "response" }
    let empty = if is-blank(response) {
      diagnose("exchange " + str(anchor) + ": empty " + empty-noun, always: true)
    }

    block(above: 1em, below: 1em)[
      #dup #orphan #empty
      #strong(header) \
      #if comment != none [
        #emph(comment)
        #v(0.4em)
      ]
      #response
    ]
  }
}

/// Renders one reviewer/editor comment and the author's response (3
/// positional args), *or* — for the co-author workflow, where there's no
/// separate reviewer comment to quote — a single self-authored note (2
/// positional args, `exchange(anchor, text)`), identical in every way to
/// calling `note(anchor, text)` directly. Stores the exchange in a
/// `<palimpsest-exchange>` metadata for `pinpoint`/`xcomment` and for the
/// diagnostics in `exchange-core` above. Emits nothing in the manuscript
/// — only ever called from the exchanges document (`responses.typ`).
///
/// `anchor` is required in both forms: an exchange with nothing to
/// answer isn't an exchange. Use `parse-anchor`'s convention (`<r1-2>`,
/// `<e1>`, `<bob-3>`, with an optional round-number prefix) to get
/// automatic headers; other label shapes fall back to the enclosing
/// `reviewer`/`editor`/`author` context, or a bare "Comment" header.
#let exchange(..args) = {
  let pos = args.pos()
  let term = args.named().at("term", default: auto)
  if pos.len() >= 3 {
    exchange-core(pos.at(0), pos.at(1), pos.at(2), term: term)
  } else {
    exchange-core(pos.at(0), none, pos.at(1), term: term)
  }
}

/// The single-block form: an author explaining their own change, with
/// nothing separate to quote — the co-author counterpart to `exchange`'s
/// reviewer-comment-plus-response shape. `exchange(anchor, text)` (2
/// positional args) produces the exact same output; `note` exists
/// alongside it for callers who find the dedicated name clearer.
#let note(anchor, text, term: auto) = exchange-core(anchor, none, text, term: term)

/// Cross-references *another* exchange in the letter — "as already
/// answered in comment R1-2" — the counterpart to `xref` (which points
/// into the manuscript instead). A clickable link to where that
/// exchange is rendered, plus its page, since the letter can span
/// several pages same as the manuscript does.
///
/// Rebuilds the description from `parse-anchor(anchor)` directly rather
/// than reading the original exchange's own rendered header: that
/// header can fall back to the enclosing `reviewer`/`editor`/`author`
/// context for an anchor that doesn't follow a recognized convention
/// (see `exchange-core` above), and that context only exists at the
/// position where the *original* `exchange`/`note` call renders — not at
/// whatever unrelated position calls `xcomment`. The word ("comment" vs
/// "change", and any per-call `term:` override) comes from the target
/// exchange's own stored metadata, so `xcomment` always echoes back
/// whatever the original call actually said, never recomputing it
/// independently. Anchors that don't parse fall back to citing the raw
/// label instead.
#let xcomment(anchor) = context {
  let hits = query(<palimpsest-exchange>).filter(el => el.value.anchor == anchor)
  if hits.len() == 0 {
    diagnose("xcomment(" + repr(anchor) + "): no exchange found for this anchor", always: true)
  } else {
    let el = hits.first()
    let p = parse-anchor(anchor)
    let sty = style-state.get()
    let kind = if p != none { p.kind }
    let term = el.value.at("term", default: auto)
    let word = if term != auto {
      term
    } else if kind == "author" {
      sty.change-word
    } else {
      sty.comment-word
    }
    let desc = if p != none and p.kind == "reviewer" {
      [reviewer #p.reviewer, #word #p.num]
    } else if p != none and p.kind == "editor" {
      [editor's #word #p.num]
    } else if p != none and p.kind == "author" {
      let name = author-display-name(p.author)
      if p.num != none { [#name's #word #p.num] } else { [#name's #word] }
    } else {
      [comment #upper(str(anchor))]
    }
    [#link(el.location())[#desc], p. #el.location().page()]
  }
}
