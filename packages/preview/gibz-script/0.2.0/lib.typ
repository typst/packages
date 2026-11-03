// lib.typ — public entrypoint with flat gibz_ API + optional GIBZ namespace.

// Import only what we want to expose
#import "src/colors.typ": gibz-blue
#import "src/state.typ": gibz-lang            // kept internal; not re-exported
#import "src/layout.typ": _conf, _sheet-conf
#import "src/components/base_box.typ": base-box
#import "src/components/icon_box.typ": icon-box
#import "src/components/boxes.typ": hint, question, supplementary, video, warning
#import "src/components/codebox.typ": black-code-box
#import "src/components/task.typ": task
#import "src/components/ipa-criterion.typ": ipa-criterion
#import "src/components/icons.typ": icon-moodle, icon-script, icon-exercise
#import "src/i18n.typ": t

#import "src/code.typ": code as gibz-code, code_wrap as _gibz-codly, set_code_style as gibz-set-code-style


// ── Flat API (prefixed) ──────────────────────────────────────────────────────
#let gibz-script = _conf
#let gibz-sheet = _sheet-conf
#let gibz-task = task
#let gibz-hint = hint
#let gibz-question = question
#let gibz-video = video
#let gibz-supplementary = supplementary
#let gibz-warning = warning
#let gibz-black-code-box = black-code-box
#let gibz-icon-box = icon-box
#let gibz-base-box = base-box
#let gibz-ipa-criterion = ipa-criterion
#let gibz-icon-moodle = icon-moodle
#let gibz-icon-script = icon-script
#let gibz-icon-exercise = icon-exercise
#let gibz-t = t

// Colors (both single and grouped)
#let gibz-blue = gibz-blue
#let gibz-colors = (blue: gibz-blue)

// ── Optional convenience namespace (re-exported module; see namespace.typ
// for why this can't be a plain dictionary) ─────────────────────────────────
#import "src/namespace.typ" as GIBZ
