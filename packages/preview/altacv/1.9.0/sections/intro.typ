// The intro between the header and the first section:
// `basics.summary` mapped onto `_intro-block`. Like the header,
// `alta()` calls it directly.

#import "../internal/util/fields.typ": _field
#import "../internal/components/intro.typ": _intro-block

#let _intro(cv, _) = _intro-block(summary: _field(cv.basics, "summary"))
