// Bundle entrypoint: compiles main.typ into a PDF and writes the speaker-note
// sidecar next to it in a single command.
//
//   typst compile --features bundle --format bundle bundle.typ out/
//
// produces out/main.pdf and out/main.pdfpc. Compile main.typ directly for a
// plain PDF (and for the Typst web app).
#import "@preview/pepentation:0.4.0": pdfpc-bundle-assets

#pdfpc-bundle-assets()

#document("main.pdf", include "main.typ")
