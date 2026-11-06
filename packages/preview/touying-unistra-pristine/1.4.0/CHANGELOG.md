# v1.4.0 (2025-05-30)

## General

- Updated to Typst 0.13.1.
- Restyled the footer to make it more compact.

### Slides

- **Focus Slides**
  - Added support for icons (see below).
    - Use the `icon` parameter for an icon to be shown above the title.
  - Added the following parameters: `text-size`, `icon`, `icon-size`.
    - `text-size` (length): The size of the text. Default: 2em.
    - `icon` (function): The icon to show above the text. Should be `us-icon()` or `nv-icon()`.
    - `icon-size` (length): The size of the icon. Default: 1.7em.
  - Removed the `text-alignment` parameter.

### Icons

- Added support for icon fonts _Unistra Symbol_ and _Nova Icons_. The _Unistra Symbol_ font can only be downloaded by students and staff from the University of Strasbourg, while the _Nova Icons_ font is available publicly. The full list of icons for both fonts is available [here](https://di.pages.unistra.fr/pictogrammes/). More information is available in the README.
- Added `#us-icon(name)` and `#nv-icon(name)` functions to display _Unistra Symbol_ and _Nova Icons_ icons, respectively. Both functions take the icon string ID without the prefix as an argument (e.g., `#us-icon("plant")`). These functions can also be used as arguments of the new `icon` parameter for focus slides.

### Citations

- Added specific functions to better handle how citations appear in slides: `#pcite(label, ..args)` and `#mcite(..args)`.
  - `#pcite()` creates a citation with the format `[author] ([year])`. Supplement can be specified as an additional argument (str or int) to show as `[author] ([year]:[page])`. Example: `#pcite(<a>, 5)`.
  - `#mcite()` takes an array of (author, page) arrays to display multiple citations with the format `[author], [year]:[page] ; [author], [year]:[page]`, etc. Like `#pcite()`, supplement is optional. Example: `#mcite((<a>, 5), (<b>, "24-25"))`.
- It is recommended to use the corresponding `apa.csl` file (available in the `assets` folder) and specify it as the value of the `style` argument when invoking `#bibliography()` so that citations appear with the correct format.

### Admonitions

- Deprecated. Users should switch to [typst-theorion](https://github.com/OrangeX4/typst-theorion) instead.

### Settings

- Added setting `footer-hide` (str) to hide specific elements from the footer.
  - Currently, two values are accepted: "author" and "date".
- Renamed settings `footer-upper-sep` and `footer-lower-sep` to `footer-first-sep` and `footer-second-sep` to accomodate for footer changes.
- Removed setting `footer-show-subtitle`.

## Fixes

- Fixed outline entries not being linebroken properly.
- Fixed type/str comparison for future Typst 0.14 compatibility.

# v1.3.1 (2025-02-24)

## General

- Updated to Typst 0.13.0.
- Updated to Touying 0.6.1.

### Other

- Added support for PDF outline bookmarks (will use the value of the `outlined` parameter in the `focus-slide()` function).

## Fixes

- Fixed footer upper separator showing when either title or subtitle was empty.

# v1.3.0 (2025-01-06)

## General

- Updated to Touying 0.5.5.

### Slides

- **Outline Slides**:
  - New slide type.
    - Invoked using the `outline-slide()` function.
    - Automatically generates a table of contents that lists focus slides from the presentation.
      - Set the new `outline` parameter to `false` in the `focus-slide()` function to exclude a slide from the table of contents.
    - Takes the following parameters:
      - `title` (str): The title of the slide. Default: "Outline".
      - `title-size` (length): The size of the title. Default: 1.5em.
      - `content-size` (length): The size of the content. Default: 1.2em.
      - `fill` (color): The fill color of the outline block. Default: nblue.D.
      - `outset` (length): The outset of the outline block. Default: 30pt.
      - `height` (ratio): The height of the outline block. Default: 80%.
      - `radius` (ratio): The radius of the outline block. Default: 7%.
      - `..args`: Additional arguments to pass to the outline.
- **Appendix Slides**:
  - Added custom footer label support for appendix slides (slides that appear after `#show: appendix`, e.g. bibliography).
    - By default, an italic "A-" label will be shown in the footer right before the slide number. The content of the label can be changed using the settings (see below).

### Settings

- Added new settings to further customize the custom `quote` element:
  - `margin-top` (relative | fraction): The top margin of the quote. Default: 0em.
  - `outset` (relative | dictionary): The outset of the quote box. Default: 0.5em.
  - These settings should be specified in the `config-store()` object under the `quote` key, when initializing `unistra-theme`.
- Added `footer-appendix-label` (str) setting to customize the label shown in the footer for appendix slides. Default: "A-".

### Other

- Replaced the default [‣] first-child item list marker with [--] to fix alignment issues.

# v1.2.0 (2024-11-21)

## General

- Updated to Typst 0.12.0.

### Slides

- **Title Slides**:
  - Added multiple logo support.
    - Use the `logos` parameter to specify several logos to be shown side-by-side. `logos` takes an array of images as input. Both `logo` and `logos` cannot be set at the same time.

### Settings

- Reworked how settings are handled to allow full compatibility with Typst Universe.
  - Settings should now be specified by adding the `config-store()` object when initializing `unistra-theme`, as it is standard to do with Touying themes.
  - The following settings are available: `show-header` (bool), `show-footer` (bool), `footer-upper-sep` (str), `footer-lower-sep` (str), `font` (array[str]), `quotes` (dict[str]).

### Admonitions

- Admonitions now allow the following optional parameters:
  - `lang` (str, default: "fr"): the language to show the admonition title in. Accepts one of the langs in the `ADMONITION-TRANSLATIONS` dict.
  - `plural` (bool, default: false): whether the admonition title should be plural.
  - `show-numbering` (bool, default: false): whether the admonition number should be appended before the title. This replaces the old `ADMONITION-NUMBERING` setting in `settings.typ`, and allows for individual admonition customization.

### Other

- Added support for `short-title` and `short-subtitle` parameters in `config-info` object.
- Reduced list item spacing to `1em`.

## Fixes

- Minor fixes to positioning.

# v1.1.0 (2024-10-16)

## General

- Updated to Touying 0.5.3.

### Slides

- **Hero Slides**:
  - Added the following parameters: `fill`, `inset`, `footnote`.
    - `fill` (color): allows to fill the entire slide with a color. It can be used to achieve a better result if an image with a fixed background color different from the default one does not properly cover the entire slide, leaving some parts of the default background color visible.
    - `inset` (length): allows to specify the negative inset value for the image to take the most space possible on the slide.
    - `footnote` (bool): allows to specify whether there is a footnote. If true, gives some width to accommodate the footnote. Experimental feature. Default: false.
  - Removed the following parameters: `img-height`, `img-width`, `text-fill`, `text-alignment`, `enhanced-text`.
  - The `txt` parameter, used to show text next to the image, is now a dictionary accepting the following optional keys: `text`, `enhanced`, `fill`, `align`.
    - `text` (str): the text to display. Default: none.
    - `enhanced` (bool | function): whether to enhance the text. Can pass a custom function that will act as a callback to enhance the text. Default: true.
    - `fill` (color): the fill color of the text. Default: none.
    - `align` (alignment): the alignment of the text. Default: horizon + center.

### Colors

- Added all the colors from the [official color palette of the University of Strasbourg](https://langagevisuel.unistra.fr/index.php?id=396) to `colors.typ`.
  - Every color is defined as a dictionary with its different shades as keys (A: dark (_foncée_), B: vivid (_vive_), C: pale (_layette_), D: light (_claire_), E: Web colors (_Web_)).
    - The following colors and their shades are included: `grey`, `maroon`, `brown`, `orange`, `red`, `pink`, `purple`, `violet`, `nblue`, `cyan`, `ngreen`, `green`, `camo`, `yellow`.
      - Example use: `grey.A` for the dark shade of grey, `maroon.B` for the vivid shade of maroon, etc.
  - Standard colors `black`, `white`, and `link-color` remain available without dictionary use.
- Added the following colorthemes: `forest`, `berry`, `ocean`, `lavender`, `moss`, `clay`, `mint`, `lemon`, `wine`.

## Fixes

- The image on hero slides now takes double the space of the text box width on the main axis (LTR, RTL) when text is provided.
- Increased font size from 22pt to 25pt.
- Fixed template title slide missing logo.
- Fixed outdated `title-slide` function docstring.
- Fixed logo in footer not positioning correctly.
- Fixed other footer positioning issues.

# v1.0.0 (2024-09-18)

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
