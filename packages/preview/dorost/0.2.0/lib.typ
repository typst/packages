#import "src/config.typ": default-fonts, default-page, default-text, default-colors
#import "src/document.typ": document

#let document = document
#let default-fonts = default-fonts
#let default-page = default-page
#let default-text = default-text
#let default-colors = default-colors
#import "src/text/direction.typ": ltr, rtl
#import "src/text/digits.typ": persian-digits
#import "src/components/inline.typ": code-inline, math-inline, badge
#import "src/components/blocks.typ": note, quote-frame, prompt-example, checklist
#import "src/components/resources.typ": resource-link, resource-links
#import "src/layout/cover.typ": cover-page
#import "src/layout/page-chrome.typ": page-chrome
#import "src/components/forms.typ": labeled-field, choice-group
#import "src/components/tables.typ": data-table
#import "src/components/frames.typ": border-frame, section-title
#import "src/slides/setup.typ": slides
#import "src/slides/layouts.typ": slide-cover, slide-section, slide-content, slide-columns, slide-image, slide-image-text, slide-statement
