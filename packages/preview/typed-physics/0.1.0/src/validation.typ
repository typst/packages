// Internal validation façade.
//
// Public constructors and views import this stable boundary so validation
// remains synchronous at their callsites. Focused modules behind it own
// primitive values, styles, declarations, references, compatibility, and
// complete-situation orchestration.

#import "validation-core.typ" as core
#import "validation-styles.typ" as styles
#import "validation-references.typ" as references
#import "validation-schema.typ" as schema
#import "validation-situation.typ" as situation

#let fail = core.fail
#let validate-name = core.validate-name
#let validate-enum = core.validate-enum
#let validate-boolean = core.validate-boolean
#let validate-angle = core.validate-angle
#let validate-positive-number = core.validate-positive-number
#let validate-nonnegative-number = core.validate-nonnegative-number
#let validate-positive-integer = core.validate-positive-integer
#let validate-ratio = core.validate-ratio
#let validate-physical-scalar = core.validate-physical-scalar

#let validate-simple-reference = references.validate-simple-reference
#let validate-attachment = references.validate-attachment
#let attachment-element-name = references.attachment-element-name
#let attachment-anchor-name = references.attachment-anchor-name

#let validate-style-dictionary = styles.validate-style-dictionary
#let validate-paint = styles.validate-paint
#let validate-stroke = styles.validate-stroke
#let validate-element-style = styles.validate-element-style

#let known-declaration-kinds = schema.known-declaration-kinds
#let validate-situation-declarations = situation.validate-situation-declarations
#let validate-body-name = situation.validate-body-name
