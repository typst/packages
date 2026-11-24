// Supported building blocks for institution wrappers and custom slide renderers.
#import "theme/flavors.typ": flavor-defaults, flavor-names, get-flavor, current-flavor
#import "theme/render.typ": touying-slide as render-slide
#import "theme/title.typ": _modern-title-slide as render-title-slide
#import "theme/slides.typ": render-ending-slide
#import "theme/fitting.typ": fit-title
#import "components/watermark.typ": watermark-mark, watermark-layer
#import "utils/layout.typ": call-or-display, call-or-return
#import "components/branding.typ": primary-logos, title-logo-groups, grouped-logo-row, render-primary-logos, render-header-logo
#import "utils/people.typ": presentation-people, authors-grid, institutions-list, emails-grid, short-authors
#import "utils/headings.typ": *
#import "vendor/shadowed.typ": frame
#import "components/blocks.typ": block-style-names, block-kinds
#import "navigation.typ": navigation-defaults, navigation-names, get-navigation, resolve-navigation
#import "theme/chrome.typ": navigation-row as render-navigation-row
#import "title-layouts.typ": title-layout-defaults, title-layout-names, get-title-layout, resolve-title-layout
#import "ending-layouts.typ": ending-layout-defaults, ending-layout-names, get-ending-layout, resolve-ending-layout

#import "components/agenda.typ": agenda-styles
