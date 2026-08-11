/// Usage:
/// `#import "@preview/sos-ugent-style:0.1.0" as ugent`
/// `#show ugent.dissertation-template.with(...)`
#import "src/ugent-doc.typ": ugent-doc-template as doc-template
#import "src/ugent-dissertation.typ": (
  ugent-dissertation-template as dissertation-template,
  // Use: `show: ugent.section.with("preface")`
  ugent-section as section,
  ugent-abstract-info as dissertation-abstract-info,
  ugent-dissertation-info as info,
  ugent-dissertation-info-full as info-full,
)

#import "src/styling/elements.typ": ugent-glossary as glossary
/// Proprietary UGent font, only use as UGent staff for UGent purposes. See fonts/README.md
#let font-panno = "UGent Panno Text"
#import "src/ugent-doc.typ": font-default


// Some submodules are lazy loaded
/// Usage (different ways, according to preference):
/// #import "@preview/sos-ugent-style:0.1.0" as ugent: utils.todo
/// #import ugent.utils.glossy(): *
/// #import todo(): *
/// The brackets are to execute the function, it returns the module
#import "utils/lib.typ" as utils
#import "src/i18n.typ"


/// There should be no need to access anything except the exported functions.
/// If you still have some advanced use-case, use `ugent.modules.ugent-doc.special-function`
#let modules = (
  ugent-dissertation: { import "src/ugent-dissertation.typ"; ugent-dissertation },
  ugent-doc: { import "src/ugent-doc.typ";  ugent-doc },
  // Everything related to covers, should you feel a need to customize
  //cover: ,
  styling: (
    elements: { import "src/styling/elements.typ"; elements },
  ),
)
