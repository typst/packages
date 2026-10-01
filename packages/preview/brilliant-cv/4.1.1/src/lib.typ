/*
 * Entry point for the package
 */

/* Internal modules. Import them as modules so dependency symbols do not
 * become accidental exports of the package root. The aliases below are the
 * supported v4 root API. */
#import "./cv.typ" as _cv
#import "./letter.typ" as _letter
#import "./utils/styles.typ" as _styles

#let cv-section = _cv.cv-section
#let cv-entry = _cv.cv-entry
#let cv-entry-start = _cv.cv-entry-start
#let cv-entry-continued = _cv.cv-entry-continued
#let cv-skill = _cv.cv-skill
#let cv-skill-with-level = _cv.cv-skill-with-level
#let cv-skill-tag = _cv.cv-skill-tag
#let cv-honor = _cv.cv-honor
#let cv-publication = _cv.cv-publication
#let h-bar = _styles.h-bar
// Preserve this historically reachable helper throughout v4. New templates
// should configure [layout.fonts] and let cv()/letter() resolve it.
#let overwrite-fonts = _styles.overwrite-fonts

/// Schema migration guard: panic on v3 metadata fields that v4 removed.
///
/// Mirrors the pattern used for `inject_ai_prompt` / `inject_keywords`
/// (the v2 -> v3 inject schema migration): when an obsolete field is
/// detected we panic with a message pointing to the v4 replacement,
/// rather than silently ignoring or guessing the user's intent.
///
/// Fires for any of:
/// - `language`            (v3 typography shortcut, removed in v4)
/// - `non_latin_font`      (replaced by [layout.fonts] regular_fonts + header_font)
/// - `non_latin_name`      (replaced by [personal] display_name)
/// - `[lang.<code>]` table (replaced by top-level header_quote / cv_footer / letter_footer)
#let _check-v3-legacy(metadata) = {
  if metadata.at("language", default: none) != none {
    panic(
      "'language' is removed in v4. v3 used it as a typography shortcut "
        + "(non-Latin font fallback, section title style, date column width, "
        + "non_latin_name selection). v4 makes those decisions explicit: set "
        + "[layout.fonts] regular_fonts (font fallback chain), [layout.fonts] "
        + "header_font, [layout.section] title_highlight, [personal] display_name, "
        + "and [layout] date_width. See migration.md for the full mapping.",
    )
  }
  if metadata.at("non_latin_font", default: none) != none {
    panic(
      "'non_latin_font' is removed in v4. List your fonts in "
        + "[layout.fonts] regular_fonts (e.g. [\"Source Sans 3\", \"Heiti SC\"]) "
        + "and set [layout.fonts] header_font for the heading. typst's "
        + "codepoint-level fallback handles mixed scripts automatically.",
    )
  }
  if metadata.at("non_latin_name", default: none) != none {
    panic(
      "'non_latin_name' is removed in v4. Use [personal] display_name "
        + "instead — it overrides the Latin first/last split with a single "
        + "styled string.",
    )
  }
  if metadata.at("lang", default: none) != none {
    panic(
      "'[lang.<code>]' tables are removed in v4. Set 'header_quote', "
        + "'cv_footer', 'letter_footer' as top-level fields in "
        + "profile_<name>/metadata.toml (one profile = one complete config).",
    )
  }
}

/// Schema migration guard: panic on v2 inject keys removed in v3.
///
/// Mirrors `_check-v3-legacy`: an obsolete field triggers a panic with
/// the v3+ replacement, rather than a silent no-op. Both `cv()` and
/// `letter()` invoke this at the entry point so the check fires once
/// per render regardless of code path.
#let _check-v2-inject-legacy(metadata) = {
  let inject = metadata.at("inject", default: (:))
  if inject.at("inject_ai_prompt", default: none) != none {
    panic(
      "'inject_ai_prompt' has been removed since v3. Use 'custom_ai_prompt_text' in [inject] instead.",
    )
  }
  if inject.at("inject_keywords", default: none) != none {
    panic(
      "'inject_keywords' has been removed since v3. Use 'injected_keywords_list' directly — if the list is present, keywords are injected. To disable injection, remove 'injected_keywords_list'.",
    )
  }
}

/* Layout */

/// Resolve typography (font list, header font, font size) from metadata.
/// Pure helper — the actual `set text` rule is applied by the caller because
/// `set` rules don't propagate out of nested function bodies in typst.
///
/// -> dictionary  (regular-fonts, header-font, font-size)
#let _resolve-typography(metadata) = {
  let font-config = _styles.overwrite-fonts(
    metadata,
    _styles._latin-font-list,
    _styles._latin-header-font,
  )
  let font-size = eval(metadata.layout.at("font_size", default: "9pt"))
  (
    regular-fonts: font-config.regular-fonts,
    header-font: font-config.header-font,
    font-size: font-size,
  )
}

/// Page margin defaults — cv (snug right) vs letter (symmetric for formality).
/// On a4 both share the same compact defaults.
///
/// -> dictionary  (typst margin spec)
#let _page-margin(paper-size, letter-style: false) = {
  if paper-size == "us-letter" {
    if letter-style {
      (left: 2cm, right: 2cm, top: 1.2cm, bottom: 1.2cm)
    } else {
      (left: 2cm, right: 1.4cm, top: 1.2cm, bottom: 1.2cm)
    }
  } else {
    (left: 1.4cm, right: 1.4cm, top: 1cm, bottom: 1cm)
  }
}

/// Render a CV document with header, footer, and page layout applied.
///
/// - metadata (dictionary): The metadata dictionary read from `metadata.toml`.
/// - doc (content): The body content of the CV (typically the imported modules).
/// - profile-photo (image | none): The profile photo to display in the header. Defaults to `none`; pass an `image(...)` to render. When `none`, the photo column is hidden regardless of `display_profile_photo`.
/// - custom-icons (dictionary): Custom icons to override or extend the default icon set.
/// - header-info (auto | none | str | content): (optional) customize the contact-information row. `auto` (default) renders `metadata.personal.info`; `none` removes the row; a string or content value replaces it while inheriting the default info typography. Use explicit `text(fill: ...)`, `h-bar()`, and `linebreak()` calls inside custom content for granular styling and layout.
/// -> content
#let cv(
  metadata,
  doc,
  profile-photo: none,
  custom-icons: (:),
  header-info: auto,
) = {
  _check-v3-legacy(metadata)
  _check-v2-inject-legacy(metadata)

  if (
    header-info != auto
      and header-info != none
      and type(header-info) != str
      and type(header-info) != content
  ) {
    panic("header-info must be auto, none, a string, or content")
  }

  // Update metadata state so component functions can read it without
  // having metadata threaded through every call site.
  _cv.cv-metadata.update(metadata)

  let typography = _resolve-typography(metadata)
  set text(
    font: typography.regular-fonts,
    weight: "regular",
    size: typography.font-size,
    fill: _styles._regular-colors.lightgray,
  )
  set align(left)
  let paper-size = metadata.layout.at("paper_size", default: "a4")
  set page(
    paper: paper-size,
    margin: _page-margin(paper-size),
    footer: context _cv._cv-footer(metadata),
  )

  _cv._cv-header(
    metadata,
    profile-photo,
    typography.header-font,
    _styles._regular-colors,
    _styles._awesome-colors,
    custom-icons,
    header-info,
  )
  doc
}

/// Render a cover letter document with header, footer, and page layout applied.
///
/// - metadata (dictionary): The metadata dictionary read from `metadata.toml`.
/// - doc (content): The body content of the letter.
/// - sender-address (str | content | auto): The sender's mailing address. Defaults to `auto`, which reads from `metadata.personal.address` (falls back to `"Your Address Here"` if unset). Pass a string or content to override.
/// - recipient-name (str): The recipient's name or company displayed in the header.
/// - recipient-address (str): The recipient's mailing address displayed in the header. Supports multiline content.
/// - date (str): The date displayed in the letter header. Defaults to today's date.
/// - subject (str): The subject line of the letter.
/// - signature (str | content): (optional) content to display as the signature. Pass `image("signature.png")` for an image; a string is rendered as text.
/// - address-style (str): Address rendering style. `"smallcaps"` (default) or `"normal"`.
/// -> content
#let letter(
  metadata,
  doc,
  sender-address: auto,
  recipient-name: "Company Name Here",
  recipient-address: "Company Address Here",
  date: datetime.today().display(),
  subject: "Subject: Hey!",
  signature: "",
  address-style: "smallcaps",
) = {
  _check-v3-legacy(metadata)
  _check-v2-inject-legacy(metadata)

  // Resolve sender-address: auto reads from metadata, explicit value overrides
  let sender-address = if sender-address == auto {
    metadata.personal.at("address", default: "Your Address Here")
  } else {
    sender-address
  }

  let typography = _resolve-typography(metadata)
  set text(
    font: typography.regular-fonts,
    weight: "regular",
    size: typography.font-size,
    fill: _styles._regular-colors.lightgray,
  )
  set align(left)
  let paper-size = metadata.layout.at("paper_size", default: "a4")
  set page(
    paper: paper-size,
    margin: _page-margin(paper-size, letter-style: true),
    footer: _letter._letter-footer(metadata),
  )
  set text(size: 12pt)

  _letter._letter-header(
    sender-address: sender-address,
    recipient-name: recipient-name,
    recipient-address: recipient-address,
    date: date,
    subject: subject,
    metadata: metadata,
    awesome-colors: _styles._awesome-colors,
    address-style: address-style,
  )
  doc

  if signature != "" {
    _letter._letter-signature(signature)
  }
}
