// lib.typ — public entrypoint with flat gibz_ API + optional GIBZ namespace.

// Import only what we want to expose
#import "src/colors.typ": gibz-blue
#import "src/state.typ": gibz-lang            // kept internal; not re-exported
#import "src/layout.typ": _conf
#import "src/components/base_box.typ": base-box
#import "src/components/icon_box.typ": icon-box
#import "src/components/boxes.typ": hint, question, supplementary, video
#import "src/components/codebox.typ": black-code-box
#import "src/components/task.typ": task
#import "src/i18n.typ": t

#import "src/code.typ": code as gibz-code, code_wrap as _gibz-codly, set_code_style as gibz-set-code-style


// ── Flat API (prefixed) ──────────────────────────────────────────────────────
#let gibz-script = _conf
#let gibz-task = task
#let gibz-hint = hint
#let gibz-question = question
#let gibz-video = video
#let gibz-supplementary = supplementary
#let gibz-black-code-box = black-code-box
#let gibz-icon-box = icon-box
#let gibz-base-box = base-box
#let gibz-t = t

// Colors (both single and grouped)
#let gibz-blue = gibz-blue
#let gibz-colors = (blue: gibz-blue)

// ── Optional convenience namespace (no duplication; just references) ────────
#let GIBZ = (
  script: gibz-script,
  task: gibz-task,
  hint: gibz-hint,
  question: gibz-question,
  video: gibz-video,
  supplementary: gibz-supplementary,
  black_code_box: gibz-black-code-box,
  icon_box: gibz-icon-box,
  base_box: gibz-base-box,
  colors: gibz-colors,
  t: gibz-t,
)
