// Single import site for third-party Typst packages.
// tools/typstdoc/main.lua reads the `@preview/<name>:<version>` lines below
// to emit docs/_variables.yml and rejects any direct `@preview/*` import
// elsewhere under src/.

#import "@preview/cetz:0.5.2"
