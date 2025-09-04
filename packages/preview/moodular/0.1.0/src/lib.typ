#import "c4l.typ"

/// Moodular's main template function, to be called as a show rule:
///
/// ```typ
/// #show: setup(mode: "preview")  // or "export"
/// ```
///
/// If you don't need flexibility of the `mode`, you can use @@preview() or @@export() instead.
///
/// The function applies the following settings for PDF export:
///
/// - if `mode` is `"preview"`, sets the page height to `auto` so that all content appears on a single continuous page,
///   like on the web
/// - sets a sans serif font (Noto Sans is currently hardcoded and therefore needs to be present)
///   and displays links blue and underlined
/// - shows blockquotes with a gray left border
/// - show raw blocks with a light beige background
///
/// which is a best-effort recreation of Moodle's Boost theme's default style.
///
/// For HTML export, the following settings are applied:
///
/// // work around Tidy's treatment of @@
/// #show "PLUGINFILE": it => "@@" + it + "@@"
///
/// - raw blocks are wrapped in `<pre class="language-..."><code>` tags to apply Moodle's syntax
///   highlighting
/// - `image` elements are transformed into `<img src="PLUGINFILE/..." class="img-fluid">` tags.
///   The `PLUGINFILE` prefix is used internally by Moodle to indicate references to uploaded files.
///
/// -> function
#let setup(
  /// the mode to use for the document; either `preview` (simulate a non-paged run of HTML content)
  /// or `export` (don't change the page setup, as to produce a paged PDF document).
  /// -> string
  mode: none,
) = body => {
  assert(mode in ("preview", "export"), message: "mode must be set to either 'preview' or 'export'")

  import "libs.typ": bullseye, bullseye.html

  import "htmlx.typ"

  // paged: setup page, font, link styling
  show: bullseye.show-target(paged: rest => {
    set page(height: auto, margin: 1cm) if mode == "preview"
    set text(font: "Noto Sans")
    show link: underline
    show link: set text(blue.darken(40%))
    rest
  })

  show quote.where(block: true): bullseye.show-target(paged: it => {
    show: block.with(
      width: 100%,
      stroke: (left: 5pt+rgb("#adb5bd")),
      inset: (left: 1em, y: 4pt),
    )
    set text(rgb("#495057"))
    it
  })

  show raw.where(block: true): bullseye.show-target(
    paged: it => {
      show: block.with(
        width: 100%,
        fill: rgb("#f5f2f0"),
        inset: 1.5em,
      )
      it
    },
    html: it => {
      show: htmlx.elem.with("pre", class: "language-" + it.lang)
      show: htmlx.elem.with("code")
      it.text
    },
  )

  show image: bullseye.show-target(html: it => {
    htmlx.img(
      "@@PLUGINFILE@@/" + it.source,
      ..if it.alt != none { (alt: it.alt) },
      class: "img-fluid"
    )
  })

  body
}

/// Sets up the document for HTML preview, i.e. simulating a non-paged run of HTML content.
/// Call this as a show rule:
///
/// ```typ
/// #show: preview()
/// ```
///
/// This is a wrapper around @@setup(), see that function for details.
///
/// -> function
#let preview() = setup(mode: "preview")

/// Sets up the document for PDF export, i.e. producing a paged PDF document.
/// Call this as a show rule:
///
/// ```typ
/// #show: export()
/// ```
///
/// This is a wrapper around @@setup(), see that function for details.
///
/// -> function
#let export() = setup(mode: "export")

/// Conditionally puts content into an `html.frame`, i.e. rendering it as an `<svg>` tag. When
/// exporting to PDF, the content is simply displayed as-is.
///
/// -> content
#let frame(
  /// the content to put into a frame
  /// -> content
  body,
) = {
  import "libs.typ": bullseye, bullseye.html

  import "htmlx.typ"

  context bullseye.on-target(
    paged: body,
    html: html.frame(body),
  )
}
