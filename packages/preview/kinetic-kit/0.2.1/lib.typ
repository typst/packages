#import "src/thesis.typ": thesis
#import "src/title-page.typ": doctoral-title-page
#import "src/outlines.typ": flex-caption

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
