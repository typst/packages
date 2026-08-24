///! `_brand.yml` theme preset.
///!
///! Maps a brand's semantic colour roles and font families onto a theme, and
///! derives a discrete palette from its data-ink roles.

#import "../utils/brand-yml.typ": brand-colours, brand-font, brand-palette-from
#import "defaults.typ": _tr-ink, _tr-paper, default-theme, minimal-surfaces
#import "elements.typ": element-rect
#import "theme.typ": _preset

// Set a font on an element record without rebuilding it: `merge-theme`
// replaces a record wholesale, so a bare `element-text(font: ...)` would drop
// the surface's own default size and weight.
#let _with-font(record, family) = {
  if family == none { record } else { (..record, font: family) }
}

/// Brand theme: a theme built from a parsed `_brand.yml`.
///
/// brand.yml is a tool-independent standard for a single brand definition, specified at <https://posit-dev.github.io/brand-yml/>. Quarto, Shiny for R, and Shiny for Python all read the same file, so one brand file can cover a document, an application, and the plots in either.
///
/// Takes the dictionary `yaml()` produces, not a path: Typst resolves a relative path against the file that calls `yaml`, so the package cannot resolve one on your behalf. Read the file yourself and pass the result.
///
/// The brand's `color.foreground`, `color.background` and `color.primary` become the theme's `ink`, `paper` and `accent`; every other surface is derived from that pair the way `theme-minimal` derives it, so gridlines and strips re-tint themselves and stay legible in either mode. The remaining data-ink roles (`secondary`, `tertiary`, `success`, `info`, `warning`, `danger`) are de-duplicated in that order into the discrete `palette` every colour and fill scale falls back to.
///
/// Semantic colours may be hex strings, names of `color.palette` entries, aliases of other entries, or `light` / `dark` variants; all of these resolve. A role the brand omits keeps the library default, but a role that is present and malformed fails. `color.light`, `color.dark`, `logo`, `meta` and `defaults` are ignored, as are all font properties other than the family name: Typst can only use a family already available to the compiler.
///
/// Nothing checks that the brand's foreground and background contrast, so a brand that pairs two dark colours yields a theme you cannot read.
///
/// - brand: Dictionary parsed from a `_brand.yml`, e.g. `yaml("_brand.yml")`. An empty dictionary yields the `theme-minimal` defaults.
/// - mode: Which side of the brand's `light` / `dark` colour variants to use: `"light"` or `"dark"`. A colour with no variants is used in both. Default: `"light"`.
/// - palette: Discrete palette override. `auto` derives one from the brand's data-ink roles; `none` keeps the library default (Okabe-Ito); an array of colours is used as-is.
/// - fields: Extra overrides forwarded to `theme`; see its docs for the full catalogue of structured and flat keys.
///   - text: Override for the `text` element.
///   - line: Override for the `line` element.
///   - rect: Override for the `rect` element.
///   - plot-title: Override for the `plot-title` element.
///   - plot-subtitle: Override for the `plot-subtitle` element.
///   - plot-caption: Override for the `plot-caption` element.
///   - plot-tag: Override for the `plot-tag` element.
///   - plot-background: Override for the `plot-background` element.
///   - axis-title: Override for the `axis-title` element.
///   - axis-text: Override for the `axis-text` element.
///   - axis-line: Override for the `axis-line` element.
///   - axis-ticks: Override for the `axis-ticks` element.
///   - panel-grid: Override for the `panel-grid` element.
///   - panel-background: Override for the `panel-background` element.
///   - legend-title: Override for the `legend-title` element.
///   - legend-text: Override for the `legend-text` element.
///   - legend-ticks: Override for the `legend-ticks` element.
///   - legend-background: Override for the `legend-background` element.
///   - legend-bar: Override for the `legend-bar` element.
///   - strip-text: Override for the `strip-text` element.
///   - strip-background: Override for the `strip-background` element.
///   - geom: Override for the `geom` element.
///
/// Returns: Theme dictionary consumed by `plot`.
///
/// See the package reference for the full theme key catalogue.
///
/// See also: `theme-minimal`, `theme`, `theme-set`.
///
/// Brand chrome and a palette derived from the brand's data-ink roles.
///
/// ```typst
/// #let brand = (
///   color: (
///     palette: (cream: "#FFFAF0", charcoal: "#1A1A1A"),
///     foreground: "charcoal",
///     background: "cream",
///     primary: "#E94C3D",
///     secondary: "#1F7A8C",
///     tertiary: "#F4B740",
///     success: "#7FC8A9",
///   ),
/// )
/// #let d = range(0, 12).map(i => (
///   x: i,
///   y: calc.rem(i * 5, 7),
///   g: ("a", "b", "c", "d").at(calc.rem(i, 4)),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   theme: theme-brand(brand),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Take the `dark` side of every colour variant the brand declares.
///
/// ```typst
/// #let brand = (
///   color: (
///     foreground: (light: "#1A1A1A", dark: "#F4EDDF"),
///     background: (light: "#FFFAF0", dark: "#161B1E"),
///     primary: (light: "#E94C3D", dark: "#FF6F60"),
///     secondary: (light: "#1F7A8C", dark: "#5BB5C7"),
///     tertiary: (light: "#F4B740", dark: "#FFD166"),
///   ),
/// )
/// #let d = range(0, 12).map(i => (
///   x: i,
///   y: calc.rem(i * 5, 7),
///   g: ("a", "b", "c").at(calc.rem(i, 3)),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   theme: theme-brand(brand, mode: "dark"),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Keep the brand's chrome but draw the data in the library's colour-vision-deficiency-safe default.
///
/// ```typst
/// #let brand = (
///   color: (
///     foreground: "#1A1A1A",
///     background: "#FFFAF0",
///     primary: "#E94C3D",
///     secondary: "#1F7A8C",
///   ),
/// )
/// #let d = range(0, 12).map(i => (
///   x: i,
///   y: calc.rem(i * 5, 7),
///   g: ("a", "b", "c").at(calc.rem(i, 3)),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   theme: theme-brand(brand, palette: none),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Read the brand file yourself and set the theme once for the whole document. The path resolves against the file calling `yaml`, so this only works where you write it, not inside the package.
///
/// ```typst
/// #theme-set(theme-brand(yaml("_brand.yml")))
/// ```
#let theme-brand(brand, mode: "light", palette: auto, ..fields) = {
  let colours = brand-colours(brand, mode)
  let ink = colours.at("foreground", default: _tr-ink)
  let paper = colours.at("background", default: _tr-paper)
  let accent = colours.at("primary", default: default-theme.accent)
  let derived = if palette == auto { brand-palette-from(colours) } else {
    palette
  }
  _preset(
    "brand",
    ink,
    paper,
    accent,
    (
      ..minimal-surfaces(ink, paper),
      // Paint the canvas: a dark brand on an unpainted background leaves
      // light ink on a white page.
      plot-background: element-rect(fill: paper),
      text: _with-font(default-theme.text, brand-font(brand, "base")),
      plot-title: _with-font(
        default-theme.plot-title,
        brand-font(brand, "headings"),
      ),
      palette: derived,
    ),
    fields,
  )
}
