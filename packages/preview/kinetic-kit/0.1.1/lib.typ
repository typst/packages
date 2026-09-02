#import "src/dissertation.typ": dissertation
#import "src/thesis.typ": thesis
#import "src/figures.typ": flex-caption

/// Style constants for custom figures and components that need to match the
/// template's visual identity: font families, sizes, line spacing, and KIT colors.
#let kit-style = {
    import "src/typography.typ": font-sizes-by-format, fonts, leading
    import "src/kit-colors.typ": kit-colors
    (
        fonts: fonts,
        font-sizes-by-format: font-sizes-by-format,
        leading: leading,
        colors: kit-colors,
    )
}

/// Building blocks for fully custom document composition. Use when the
/// high-level `dissertation` / `thesis` functions don't cover your layout.
///
/// Example:
/// ```typst
/// #import "@preview/kinetic-kit:0.1.1": components
/// #show: components.setup-page.with(margin-preset: "short", lang: "de")
/// #show: components.setup-front-matter
/// #components.print-toc(lang: "de")
/// ```
#import "src/components.typ"
