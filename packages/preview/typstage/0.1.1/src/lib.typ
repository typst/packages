// typstage: animated HTML presentations from a single Typst file, and a PDF
// handout from the same source.
//
// This file is the package's whole public surface. Everything else lives in
// the sibling modules and stays there: Typst has no `private`, and a leading
// underscore is only a convention, so the boundary is drawn here instead, by
// naming exactly what leaves the package.

#import "config.typ": (
  // Geometry and palette, so a deck can build on them.
  slide-width, slide-height, slide-margin,
  dark, accent, paper, muted,
  // Runtime version and the two files, for `assets: "split"` and CDNs.
  runtime-version, runtime-files,
)

#import "themes.typ": theme, themes
#import "palettes.typ": (
  // Color as a thing of its own, and the instrument the bundled palettes are
  // measured with.
  palettes, contrast, palette-report,
)
#import "slides.typ": (
  slide, section, title-slide, transition, speaker-note, class-clock,
  // One slide in the palette turned around, for the heading notation.
  invert,
  // What the deck knows about itself, so a deck can build its own chrome
  // instead of forking the theme. `info` says where it stands,
  // `deck-outline` how the whole thing is cut.
  info, deck-outline, contents,
)
#import "elements.typ": (alternatives, anim, build, camera, cue, cue-layer,
                         morph, pause, pin, scene, scene-layer, stagger,
                         stagger-layer)
#import "layout.typ": card, callout, fit, side-by-side, statement, tiles
#import "media.typ": video, embed, flipbook
#import "bridge.typ": bridge-job, bridge-targets
// GeoGebra, once a companion package of its own. It goes over the same bridge
// as any other, and a deck that never calls `geogebra` carries nothing of it.
#import "geogebra.typ": (geogebra, ggb-animate, ggb-hide, ggb-run, ggb-set,
                         ggb-show, ggb-style, ggb-tween, ggb-view)
// Desmos geht denselben Weg über die Brücke. Ein Deck, das keines von beiden
// ruft, trägt von beidem nichts.
#import "desmos.typ": (desmos, demo-key, dsm-animate, dsm-expr, dsm-hide,
                       dsm-remove, dsm-set, dsm-show, dsm-style, dsm-tween,
                       dsm-view)
#import "present.typ": presentation, bundle
