// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The entrypoint of the package, and the only module a user imports.
//
// A star import brings in the body-level names and the `anim` module as a name,
// so that the animation argument of a slide can open the timeline vocabulary
// with `import anim: *` without shadowing the typst built-ins
// `hide`, `move` and `scale` in the slide body.

#import "anim.typ"
#import "deck.typ": animo
#import "number.typ": per-subslide, slide-count, slide-number
#import "slide.typ": slide
#import "region.typ": region
#import "tag.typ": tag
