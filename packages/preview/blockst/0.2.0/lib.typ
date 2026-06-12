// =====================================================
// blockst — Render block-based programming languages
// =====================================================
//
// Primary API (no wrapper needed):
//   #scratch("when green flag clicked\nmove (10) steps")
//   #scratch("Wenn ⚑ angeklickt\ngehe (30)er-Schritt", language: "de")
//
// Optional grouping with theme override:
//   #blockst(theme: "print", scale: 80%)[
//     #scratch("...")
//   ]
//
// Global settings:
//   #set-blockst(theme: "high-contrast", scale: 70%)
//
// SB3 import:
//   #sb3.render-scripts(project, language: "de")
//
// Execution:
//   #scratch-run(..scratch-execute("pen down\nrepeat (4)\nmove (70) steps\nturn cw (90) degrees\nend"))

#import "libs/scratch/api.typ": blockst, set-blockst, scratch, scratch-parse, scratch-execute, raw-scratch
#import "libs/scratch/sb3.typ" as sb3
#import "libs/scratch/interpreter.typ": blockst-run-options, scratch-run, set-scratch-run
