//        ___ ____   ____      _   _ _____ ___
//       |_ _/ ___| / ___|    | | | | ____|_ _|     Informatique et
//        | |\___ \| |   ___  | |_| |  _|  | |       systèmes de communication
//        | | ___) | |__|___| |  _  | |___ | |       HEI Sion · HES-SO Valais
//       |___|____/ \____|    |_| |_|_____|___|
//
//   52 65 61 64 69 6e 67 20 68 65 78 20 66 6f 72 20 66 75 6e 3f 20 49 53 43 20 66 6f 72 65 76 65 72
//
// Templates for ISC bachelor degree programme at the School of engineering in Sion
// 
// Since 2024, @pmudry with contributions from @LordBaryhobal, @MadeInShineA
// Bachelor thesis template first page inspired from Lasse Rosenow work on https://typst.app/universe/package/haw-hamburg-master-thesis
//
// This file is the sole public API (the package entrypoint). It is intentionally
// thin: every user-callable function lives in a focused module under lib/ and is
// re-exported here so that `#import "@preview/isc-hei-*": *` keeps working.
//
//   lib/settings.typ     — shared metrics, version, keywords
//   lib/fonts.typ        — font stacks + the "fonts not installed" fallback page
//   lib/i18n.typ         — i18n() string resolution
//   lib/decorations.typ  — chapter-rule reading-position hairline + hashed bit-rule
//   lib/content.typ      — titles, TOC/figures, bibliography, appendix, utilities
//   lib/code.typ         — code() source-listing block
//   lib/covers.typ       — per-document-type front matter (used by project)
//   lib/project.typ      — project(): the multi-type document template
//   lib/poster.typ       — isc-poster()/isc-card()/isc-colbreak()

#import "lib/settings.typ": *
#import "lib/fonts.typ": *
#import "lib/i18n.typ": *
#import "lib/decorations.typ": *
#import "lib/content.typ": *
#import "lib/code.typ": *
#import "lib/project.typ": *
#import "lib/poster.typ": *

// tb-assignment public helpers (used directly in user documents).
#import "lib/pages/cover_assignment.typ": tb-assignment-page, hes, industry, school, project-types, get-document-title
