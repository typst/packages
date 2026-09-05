// Which way the deck reads.
//
// Typst turns a paragraph around by itself once `text.dir` is `rtl`, or once
// the language is one it reads from the right: `start` becomes the right
// edge, a grid lays its columns out from the right, a list puts its marks
// there. What it cannot turn around is what this package places by hand --
// the title in its band, the bar beside a callout, the number in the footer,
// the lines of a title slide. And one thing it turned the wrong way:
// `place(top + left, …)` sets more than a position. The alignment it is given
// becomes the alignment of everything inside it, and a fixed `left` there
// beats the `start` a paragraph would have resolved for itself. That is how
// every line of a Persian deck came to sit on the left while its lists and
// columns were already mirrored. Reported from the forum, with a picture.
//
// Both answers live here. `von-rechts()` says which way the text being laid
// out runs; `am-anfang` and `am-ende` place against the edge the writing
// starts or ends at, and hand `start` and `end` inward instead of a side.

/// The languages Typst itself reads from the right. Its own list, so that
/// `set text(lang: "fa")` alone turns a deck around exactly where it turns
/// the paragraphs around.
#let rtl-sprachen = ("ar", "dv", "fa", "he", "ks", "pa", "ps", "sd", "ug", "ur", "yi")

/// Does the text being laid out here run from the right? Only in context.
///
/// `text.dir` is `auto` unless a deck set it, and `auto` means "as the
/// language does" -- the same rule Typst applies when it resolves `start`.
#let von-rechts() = text.dir == rtl or (text.dir == auto and text.lang in rtl-sprachen)

/// `place` against the edge the writing starts at.
///
/// `y` is the vertical anchor, `m` the deck's margins or `none` for the bare
/// edge, `dx` is measured from the margin inwards. In a deck that reads from
/// the left this is `place(y + left, dx: m.left + dx, …)`, the frame it
/// always was; in one that reads from the right it is the mirror image,
/// anchored at `m.right`.
///
/// The anchor is `start`, not the side it resolves to, and that is the point:
/// `start` is what travels into the body, and there it is resolved wherever
/// the direction is set -- also by a `#set text(dir: rtl)` that sits *inside*
/// the body, after the show rule, where this `context` cannot see it.
#let am-anfang(y, m, body, dx: 0pt, dy: 0pt) = context {
  let r = von-rechts()
  let rand = if m == none { 0pt } else if r { m.right } else { m.left }
  place(y + start, dx: if r { -(rand + dx) } else { rand + dx }, dy: dy, body)
}

/// The same against the edge the writing ends at: the number in the footer.
#let am-ende(y, m, body, dx: 0pt, dy: 0pt) = context {
  let r = von-rechts()
  let rand = if m == none { 0pt } else if r { m.left } else { m.right }
  place(y + end, dx: if r { rand + dx } else { -(rand + dx) }, dy: dy, body)
}
