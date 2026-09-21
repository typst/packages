// Namespaced re-exports for `#import "@preview/gibz-script:0.2.0": GIBZ`.
//
// This has to be a genuine module (imported with `as GIBZ`, not assembled as
// a plain dictionary): current Typst only lets you call a function stored in
// a dictionary via `(dict.field)(..)`, not `dict.field(..)` — but that direct
// call sugar does work on modules, which is what makes `GIBZ.script(..)` etc.
// below work as expected.
#import "layout.typ": _conf as script, _sheet-conf as sheet
#import "components/base_box.typ": base-box as base_box
#import "components/icon_box.typ": icon-box as icon_box
#import "components/boxes.typ": hint, question, supplementary, video, warning
#import "components/codebox.typ": black-code-box as black_code_box
#import "components/task.typ": task
#import "components/ipa-criterion.typ": ipa-criterion as ipa_criterion
#import "components/icons.typ": icon-moodle as icon_moodle, icon-script as icon_script, icon-exercise as icon_exercise
#import "i18n.typ": t
#import "colors.typ": gibz-blue

#let colors = (blue: gibz-blue)
