/*
 * This file mainly exports functionality needed when writing your own styling function.
 */
#import "../utils/text-queries.typ": real-text-direction, text-is-left-to-right

/// Whether a value counts as "nothing to show": `none`, empty strings, empty content and lone spaces.
#let _is-blank(value) = (
  value in (none, "", [])
    or (type(value) == content and value.func() == [ ].func())
)

/// Asserts that the argument behind the supplement has the expected type (for built-in styles: a color).
#let assert-arg-type(arg, arg-type, supplement) = assert(
  type(arg) == arg-type,
  message: "Please provide a "
    + repr(arg-type)
    + " as argument for the frame instance: "
    + repr(supplement)
    + " (was "
    + repr(type(arg))
    + ")",
)

/// The structure of a frame, derived from its title, tags and body. Blank values count as absent.
///
/// Returns `shows-header` (title is not `none`), `has-title-text`, `has-tags`, `has-header-items`
/// (title or tags are shown in the header), `has-body`, `header-joins-body` (header and body are both
/// shown, so they share an edge), and `header-items` (the title if shown, followed by the tags).
#let frame-structure(title, tags, body) = {
  let has-title-text = not _is-blank(title)
  let has-body = not _is-blank(body)
  (
    shows-header: title != none,
    has-title-text: has-title-text,
    has-tags: tags != (),
    has-header-items: has-title-text or tags != (),
    has-body: has-body,
    header-joins-body: title != none and has-body,
    header-items: if has-title-text { (title, ..tags) } else { tags },
  )
}

/// Text direction of the frame. Reads the styles, so it must be called inside `context`.
///
/// Returns `dir`, `is-ltr`, and `start-side`, `end-side` (the physical sides matching the text direction).
#let direction-info() = {
  let is-ltr = text-is-left-to-right()
  (
    dir: real-text-direction(),
    is-ltr: is-ltr,
    start-side: if is-ltr { "left" } else { "right" },
    end-side: if is-ltr { "right" } else { "left" },
  )
}

/// Deprecated: use the native `divider()` element instead.
/// Kept for backwards compatibility, it is equivalent to `divider()`.
#let divide() = divider()

/// Deprecated: add `show divider: ...` directly in your styling function instead.
/// Kept for backwards compatibility.
#let dividers-as(divider-element) = (
  document => {
    show divider: _ => divider-element
    document
  }
)
