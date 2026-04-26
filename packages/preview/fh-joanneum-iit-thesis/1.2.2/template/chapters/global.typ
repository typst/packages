//
// About the fh-joanneum-iit-thesis package used:
//

// Note 1:
//     following is an (indirect) import of the 'lib.typ' file
//     The file lib.typ (and others) will be downloaded and cached
//     by your system. The location of the @preview cache directory
//     is explained in
//     https://github.com/typst/packages?tab=readme-ov-file#downloads
//     e.g.  %APPDATA% on Windows on Windows
//           ~/.local/share or $XDG_DATA_HOME on Linux
//           ~/Library/Application Support on macOS
//
// Note 2:
//    If you like to modify "lib.typ", copy the file from the cache directory
//    or get it from the 'official' Typst Universe package git repo
//       (i.e. from proper 'version number subdir' of
//         https://github.com/typst/packages/tree/main/packages/preview/fh-joanneum-iit-thesis)
//    Copy the lib.typ to a (sub)folder of this project and
//    set the path accordingly.
#import "@preview/fh-joanneum-iit-thesis:1.2.2": *

// Anytime you might simply override custom macros, such as:
// #let quote(message, by) = {
//   block(
//         radius: 3em, width: 75%,
//         inset: (x: 2em, y: 0.5em),
//         [
//         #message,
//         #par(
//           first-line-indent: 15em,
//           text(font: "Inria Serif", size: 9pt, style: "italic", [
//           #by
//           ])
//         )
//         ]
//   )
// }

//
// Other packages used:
//

// See https://github.com/typst/packages/tree/main/packages/preview/glossarium
#import "@preview/glossarium:0.4.1": make-glossary, print-glossary, gls, glspl

