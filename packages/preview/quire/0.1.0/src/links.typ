/// This module configures links and provides link and reference helpers.
#import "config.typ": _config

/// Applies the link settings: in digital output, external links are colored; in print output, they are not.
///
/// -> content
#let _links-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  show link: it => if cfg.output == "digital" and type(it.dest) == str {
    text(fill: cfg.colors.link, it)
  } else {
    it
  }

  body
}

/// An external link that survives printing. In digital output it is a plain link; in print output, the link text is
/// followed by a footnote with the address. Without a body, the address itself is shown and no footnote is added.
///
/// ```typ
/// Built with #href("https://typst.app")[Typst].
/// ```
///
/// -> content
#let href(
  /// The destination address.
  /// -> str
  dest,
  /// The link text, optional.
  /// -> content
  ..body,
) = context {
  let body = body.pos().at(0, default: none)
  if body == none {
    link(dest)
  } else if _config.get().output == "print" {
    link(dest, body) + footnote(link(dest))
  } else {
    link(dest, body)
  }
}

/// A reference followed by the title of the referenced heading in small caps, e.g. "Chapter 2 (Preliminaries)".
///
/// -> content
#let ref-titled(
  /// The label of a heading.
  /// -> label
  target,
) = context {
  let element = query(target).first()
  [#ref(target) (#smallcaps(element.body))]
}
