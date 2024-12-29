# v1.0.0 (2024-08-31)

Initial release for publication as a Typst template package.

# v0.2.0 (2024-08-30)

## General

### Slides

- **Focus Slides**:
  - Added counter support.
  - Added the following parameters: `text_alignment`, `show_counter`.
  - Added the following parameters to `grandientize(): `lighten-pct`, `angle`.
- **Title Slides**:
  - Added the following parameters: `title`, `subtitle`.
- **Hero Slides**:
  - Added support for the following directions: left-to-right (default), right-to-left, up-to-down, down-to-up.
  - Added caption support.
    - - Captions can be bolded using `bold_caption: true`.
  - Added enhanced text option.
    - Enhanced text appears bigger than normal text, in bold, and close to the image for better visibility.
    - Enhanced text can have a background using the `text_fill` parameter and specifying a fill color.
  - Added option to hide footer on individual slides.
  - Added the following parameters: `bold_caption`, `caption`, `direction`, `enhanced_text`, `gap`, `heading_level`, `hide_footer`, `img_height`, `img_width`, `numbering`, `rows`, `text_alignment`, `text_fill`, `txt`.
- **Gallery Slides**:
  - Added caption support for individual images.
    - Captions can be bolded using `bold_caption: true`.
  - Added the following parameters: `captions`, `height`, `gutter`, `subtitle`, `bold_caption`, `heading_level`, `width`, `gap`.

### Admonitions

- Added "Brainstorming" admonition type.
- Added "Question" admonition type.
- Added option to enable or disable admonition numbering (default: false).
- Added localization support.

### Settings

- Added the following settings:
  - ADMONITION_NUMBERING (default: false),
  - DEBUG (default: false),
  - FOOTER_LOWER_SEP (footer lower separator) (default: " | "),
  - FOOTER_SHOW_SUBTITLE
  - FOOTER_UPPER_SEP (footer upper separator) (default: " | "),
  - LANGUAGE (used for [Typst's `text()` lang parameter](https://typst.app/docs/reference/text/text/#parameters-lang)) (default: "fr"),
  - QUOTES (used to specify left and right quotation mark characters for the "Quote" element) (default: "« ,  »).
- Added [wiki page listing settings](https://github.com/spidersouris/typst-unistra-slides/wiki/Settings).

### Other

- Updated example with newest changes.
- Added a customized version of [`quote`](https://typst.app/docs/reference/model/quote/).
- Added the following exportable methods: `smaller`, `smallest`.
  - `smaller` sets text to 25pt.
  - `smallest` sets text to 20pt.
- Added `link-color` to `colors.typ`.

## Fixes

- Fixed aligment issue with `cell()`.
- Fixed alignment issue with `focus-slide()`.
- Improved `focus-slide()` theme-related error messages.

## Miscellaneous

- Added licence.

# v0.1.0 (2024-08-05)

Initial pre-release.
