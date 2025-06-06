//
// About modern-uit-thesis:
//

// NOTE:
//     following is an (indirect) import of the 'lib.typ' file
//     The file lib.typ (and others) will be downloaded and cached
//     by your system. The location of the @preview cache directory
//     is explained in
//     https://github.com/typst/packages?tab=readme-ov-file#downloads
//     e.g.  %APPDATA% on Windows on Windows
//           ~/.local/share or $XDG_DATA_HOME on Linux
//           ~/Library/Application Support on macOS
//
// NOTE:
//    If you like to modify "lib.typ", copy the file from the cache directory
//    or get it from the 'official' Typst Universe package git repo
//       (i.e. from proper 'version number subdir' of
//         https://github.com/typst/packages/tree/main/packages/preview/modern-uit-thesis)
//    Copy the lib.typ to a (sub)folder of this project and
//    set the path accordingly.
#import "@preview/modern-uit-thesis:0.1.6": *

//
// Other packages used:
//

#import "@preview/glossarium:0.5.6": gls, glspl, make-glossary, print-glossary
#import "@preview/codly:1.3.0": *
