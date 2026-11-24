
#import "src/elem-lib.typ": set-default, set-paragraph

#import "src/lib/ref-lib.typ": elabel

#import "src/foundation/item-config.typ": item

#import "src/core/feat-item-lib.typ": (
  auto-label-item, auto-resume-enum, isolated-resume-enum, resume, resume-label, resume-list,
)

#import "src/export-el.typ": (
  default-enum, default-enum-list, default-list, inline-enum, inline-enum-list, inline-list, paragraph-enum,
  paragraph-enum-list, paragraph-list,
)

#import "src/advance.typ" as adv

#import "src/config.typ" as config

#import "src/util/identifier.typ": LOOP

#import "src/util/identifier.typ": prevent-recursion-label as itemize-prevent-label

/// deprecated
///
/// Use `el.config.ref` instead!
#let ref-enum(doc) = {
  panic("Use `el.config.ref` instead!")
}

/// Display an enum or list as a new enum or list. Usage:
/// ```typst
/// + item 1
/// + item 2
/// #el.new-enum-list-flag
/// // The following content will be treated as a new enum or list
/// + item 3
/// + item 4
/// ```
#let new-enum-list-flag = {
  show enum: it => it
  show list: it => it
}
