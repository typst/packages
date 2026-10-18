// The package entrypoint. Typst re-exports every top-level binding, so this
// file imports only the names the package means to expose: the public API from
// `src/api.typ` and the theme presets. The modules `utils`, `layout`, `blocks`,
// `cards` and `toc` are implementation detail and stay out of the surface.
#import "src/api.typ": definition, warning, remark, hint, info, example, quote, success, failure
#import "src/api.typ": card, card-grid
#import "src/api.typ": resolve-theme, active-theme, theme-color, theme-text, theme-box, with-theme
#import "src/api.typ": theme-block-code-background, theme-card-code-background, theme-header-dim-color
#import "src/api.typ": section-slide, setup-presentation
#import "src/themes.typ" as themes
