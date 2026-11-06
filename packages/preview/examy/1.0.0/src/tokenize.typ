/// Phase B: turn a content stream containing division markers into a flat
/// array of tokens. Unwrapping is conservative: only `sequence` and `styled`
/// containers and elembic rules (`#show: e.set_(..)`) can be unwrapped
/// (their styles and rules are recorded on a stack and re-applied at render
/// time), and one that turns out to hold no marker is put back together as
/// one `chunk`. Everything else stays an opaque `chunk`.
///
/// Token kinds (plain dictionaries):
/// - (kind: "begin", fields: (..), styles: (..)), `fields` holding, as
///   `_scoped`, the options of the `config` rules around the division that
///   it is laid out with (see `scoped_options_set`), if there are any
/// - (kind: "end")
/// - (kind: "break", target: "page" | "col", weak: bool, styles: (..))
/// - (kind: "chunk", body: content, styles: (..), has_inner_break: bool,
///    fr: fraction | none)

#import "prelude.typ": e
#import "constants.typ": BATCH
#import "markers.typ": is_outside_check, marker_value
#import "config.typ": exam_wide_options_set, scoped_options_set
#import "scan.typ": STYLED_FUNC, elembic_rule, is_break, scan, unwrap

/// A token's style stack (see `apply_styles`), as tokens and items keep it:
/// in `metadata`, as content, whose hash Typst works out once and keeps.
/// Every function the exam calls with its items hashes them, as Typst
/// memoizes the call, and a stack is as deep as the rules around the token,
/// one level for each `#set` or `#show` rule in a document made the exam by
/// `#show: exam`: kept as an array, the items of a long exam with many rules
/// would take ever longer to hash, in every call.
#let _kept(styles) = metadata(styles)

/// The style stack of a token or item, out of the `metadata` it is kept in
/// (see `_kept`), or `styles` itself if it is a stack already.
#let stack_of(styles) = if type(styles) == content { styles.value } else { styles }

/// Re-apply a recorded style stack to content. Each entry is
/// `(id: int, apply: ..)`: `apply` the `styles` of a `styled` element, or a
/// function, the show rule of an elembic rule; `id` the container it was
/// recorded from, numbered by `tokenize`, the same for all it holds. (Two
/// `styles` never compare equal, even the same one: the ids tell whether
/// two pieces of content are in the same scope of a rule, see `render`.)
#let apply_styles(body, styles) = {
  let ret = body
  for s in stack_of(styles).rev() {
    ret = if type(s.apply) == function { (s.apply)(ret) } else { STYLED_FUNC(ret, s.apply) }
  }
  ret
}

/// The show rule applying an elembic rule again, from the rule's data as
/// its tag keeps it (see `elembic_rule`). `e.apply` takes rules as functions
/// and reads each one's data from the tag it leaves; this one leaves just
/// that.
#let _elembic_show(rule) = e.apply(_ => [#metadata(none)#metadata((rule: rule))])

#let _chunk(c, styles, info) = (
  kind: "chunk",
  body: c,
  styles: _kept(styles),
  has_inner_break: info.has_break,
  fr: info.fr,
)

/// The chunk that a container `c` (see `unwrap`) holding no marker is put
/// back together as, from `tokens`, what it was tokenized as: what they say
/// of breaks and `fr` heights is what `scan(c)` would.
#let _rejoin(c, styles, tokens) = {
  let has_break = false
  let fr = none
  for t in tokens {
    if t.kind == "break" or t.has_inner_break { has_break = true }
    if t.kind == "chunk" and t.fr != none { fr = if fr == none { t.fr } else { fr + t.fr } }
  }
  _chunk(c, styles, (has_break: has_break, fr: fr))
}

/// The error for an elembic rule (its data, see `elembic_rule`) around
/// divisions that sets options an exam reads once (see
/// `exam_wide_options_set`), or that revokes a rule before the exam that set
/// them (one of `wide_names`, see `exam_wide_names`), or `none`.
#let exam_wide_rule_error(rule, wide_names: ()) = {
  // A `revoke` among the rules, `apply`s opened up.
  let stack = (rule,)
  while stack.len() > 0 {
    let r = stack.pop()
    if type(r) != dictionary { continue }
    if r.at("kind", default: none) == "apply" { stack += r.at("rules", default: ()) }
    if r.at("kind", default: none) == "revoke" and r.at("revoking", default: none) in wide_names {
      return (
        "examy: an `e.revoke` inside an exam, around some of its questions, undoes `"
          + r.revoking
          + "`, a `config` rule before the exam that sets options read once for the whole exam "
          + "(such as `numbering` or `points-position`), so it would change nothing. Give the exam the "
          + "options it should have, e.g. with `#show: exam.with(..)`."
      )
    }
  }
  let names = exam_wide_options_set(rule)
  if names.len() == 0 { return none }
  let list = names.map(n => "`" + n + "`").join(", ", last: " and ")
  let one = names.len() == 1
  (
    "examy: a `config` rule inside an exam, around some of its questions, sets "
      + list
      + ", which "
      + (if one { "is" } else { "are" })
      + " read once for the whole exam, so "
      + (if one { "it" } else { "they" })
      + " would change nothing. Give "
      + (if one { "it" } else { "them" })
      + " to the exam, e.g. `#show: exam.with("
      + names.first()
      + ": ..)`, or set "
      + (if one { "it" } else { "them" })
      + " in a `config` rule above `#show: exam`."
  )
}

/// Tokenize `content` into a flat array of tokens. `wide_names` are the
/// names of the `config` rules before the exam that set options it reads
/// once (see `exam_wide_rule_error`). Walked with a stack of
/// its own, in order, not by recursing, as `scan` is, for a document nested
/// a level deeper with every set or show rule in it, and in batches, for one
/// longer than Typst lets a loop run (see `BATCH`). Each container is
/// unwrapped, and once what it holds is tokenized, put back together if
/// that holds no marker: so each piece of content is looked at once, not
/// scanned again for every container around it.
#let tokenize(c, wide_names: ()) = {
  let tokens = ()
  // How many begin and end tokens there are so far.
  let markers = 0
  // How many containers with styles or a rule were unwrapped (see
  // `apply_styles`).
  let scopes = 0
  // What is left to tokenize, last first, each with its styles and the
  // options the `config` rules around it set (`scoped`); or a container whose
  // content is tokenized, with where its tokens start and how many markers
  // there were before them.
  let stack = ((c: c, styles: (), scoped: (:)),)
  while stack.len() > 0 {
    // In batches (see `BATCH`).
    let round = 0
    while stack.len() > 0 and round < BATCH {
      round += 1
      let (c, styles, scoped, ..done) = stack.pop()
      if done.len() > 0 {
        if markers == done.markers {
          // Popped, not sliced off: a slice copies all of `tokens`, every
          // container. A `for` loop has no limit on its rounds.
          let mine = ()
          for _ in range(tokens.len() - done.start) { mine.push(tokens.pop()) }
          tokens.push(_rejoin(c, styles, mine))
        } else {
          // Around divisions, a rule may not set what the exam reads once.
          let rule = elembic_rule(c)
          let error = if rule != none { exam_wide_rule_error(rule.rule, wide_names: wide_names) }
          if error != none { panic(error) }
        }
        continue
      }
      if type(c) == array {
        for x in c.rev() { stack.push((c: x, styles: styles, scoped: scoped)) }
        continue
      }
      if type(c) != content {
        tokens.push(_chunk([#c], styles, scan(c)))
        continue
      }

      // A division's check that it is laid out by an exam: it is (see
      // `outside_check`).
      if is_outside_check(c) { continue }
      let m = marker_value(c)
      if m != none {
        tokens.push(if m.kind == "begin" {
          markers += 1
          (kind: "begin", fields: if scoped.len() > 0 { (..m.fields, _scoped: scoped) } else { m.fields }, styles: _kept(styles))
        } else if m.kind == "end" {
          markers += 1
          (kind: "end")
        } else {
          // Other marker kinds (e.g. height hints) travel as ordinary chunks.
          _chunk(c, styles, scan(c))
        })
        continue
      }
      if is_break(c) {
        tokens.push((
          kind: "break",
          target: if c.func() == pagebreak { "page" } else { "col" },
          weak: c.at("weak", default: false),
          styles: _kept(styles),
        ))
        continue
      }

      // A container: unwrapped, with its styles or rule for what it holds.
      let kids = unwrap(c)
      if kids != none {
        stack.push((c: c, styles: styles, scoped: scoped, start: tokens.len(), markers: markers))
        let rule = elembic_rule(c)
        let apply = if rule != none { _elembic_show(rule.rule) } else if c.func() == STYLED_FUNC { c.styles }
        let inner = if apply != none {
          scopes += 1
          styles + ((id: scopes, apply: apply),)
        } else { styles }
        // What a `config` rule sets for the divisions in its scope.
        let inner_scoped = if rule != none { scoped + scoped_options_set(rule.rule) } else { scoped }
        for x in kids.rev() { stack.push((c: x, styles: inner, scoped: inner_scoped)) }
        continue
      }

      let info = scan(c)
      if not info.has_marker {
        // No structure inside: keep as one opaque chunk. Never destructured.
        tokens.push(_chunk(c, styles, info))
        continue
      }

      // Contains markers but cannot be unwrapped without losing information.
      let names = info.marker_names.dedup()
      if names.len() == 0 { names = ("division",) }
      panic(
        "examy: a `"
          + names.join("`/`")
          + "` was found inside a `"
          + repr(c.func())
          + "` element. Questions, parts, and subparts may only appear at the "
          + "top level of their parent's body (not inside list items, blocks, "
          + "boxes, figures, tables, etc.). Move it out of the `"
          + repr(c.func())
          + "`.",
      )
    }
  }
  tokens
}
