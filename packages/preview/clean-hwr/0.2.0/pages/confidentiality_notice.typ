/// Renders a standalone confidentiality notice page.
///
/// This function prints an unnumbered, non-outlined heading using the
/// provided `title`, followed by the `content`. After rendering the
/// content, a page break is inserted.
///
/// Parameters
/// - confidentiality-notice (dictionary):
///   - title (content): The heading displayed at the top of the page.
///   - content (content): The body text of the confidentiality notice.
///
/// Returns
/// - content: Formatted content consisting of:
///   - An unnumbered heading
///   - The notice content
///   - A trailing page break
///
/// Example
/// ```typst
/// #render-confidentiality-notice((
///   title: [Confidentiality Notice],
///   content: [This thesis contains confidential information.]
/// ))
/// ```
#let render-confidentiality-notice(confidentiality-notice: (
  title: [],
  content: [],
)) = {
    heading(
      outlined: false,
      numbering: none,
      confidentiality-notice.title,
    )

    confidentiality-notice.content
    pagebreak()
}

/// Conditionally renders the confidentiality notice on a specific page.
///
/// This function checks whether the current page number matches
/// `confidentiality-notice.page-idx`. If both conditions are met:
/// - the current page equals `page-idx`, and
/// - `confidentiality-notice.title` is not empty,
/// then `render-confidentiality-notice` is invoked.
///
/// The page check is performed inside a `context` block using
/// `counter(page).get()` to determine the current page number.
///
/// If the page does not match or no title is provided,
/// nothing is rendered.
///
/// Parameters:
/// - confidentiality-notice (dictionary):
///     (
///       title: [],
///       content: [],
///       page-idx: none,
///     )
///     - title (content):
///         The heading of the confidentiality notice.
///         Rendering only occurs if this is not empty.
///     - content (content):
///         The body text of the notice.
///     - page-idx (int or none):
///         The page number on which the notice should be rendered.
///         Must match the current page number.
///
/// Returns:
/// - content:
///     The rendered confidentiality notice (via
///     `render-confidentiality-notice`) if conditions are met,
///     otherwise empty content.
///
/// Example:
/// ```typst
/// #_render-confidentiality-notice-if-right-place((
///   title: [Confidentiality Notice],
///   content: [Restricted distribution.],
///   page-idx: 2,
/// ))
/// ```
#let _render-confidentiality-notice-if-right-place(confidentiality-notice: (
  title: [],
  content: [],
  page-idx: none,
)) = {
  context {
    let current-page = counter(page).get().at(0)
    if confidentiality-notice.page-idx == current-page and confidentiality-notice.title != [] {
      render-confidentiality-notice(confidentiality-notice: confidentiality-notice)
    }
  }
}

