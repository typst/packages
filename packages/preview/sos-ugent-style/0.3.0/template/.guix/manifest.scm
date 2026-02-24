; This file contains 'guile' code, the programming language used by Guix.
; Everything starting with a ; are comments.

(use-modules ; ↓ contains helper functions like create-typst-package-tar
             ;(typst package-helper)
             ; ↓ contains the typst-sos-ugent-style package
             (typst packages sos-ugent-style)
             ; ↓ Contains the functions to specify a package directly from git
             ;(guix packages)
             ;(guix git-download)
             )

(concatenate-manifests
 (list
  (specifications->manifest
   (list "typst"))
  (packages->manifest
   (list typst-sos-ugent-style
         ; Here, you can specify any additional Typst packages needed to exactly
         ; reproduce your document. These are e.g. imported like
         ; `#import "@preview/physica:0.9.5"`
         ; When using `guix shell --container`, Typst will automatically complain
         ; about which packages it could not download. You should specify them here.

         ; The reproducibility of you work depends on how long https://typst.app
         ; will serve these tarballs.
         ;(create-typst-package-tar
         ; '("physica" "0.9.5"
         ;   ; The sha256 hash of the physica package. The easiest approach
         ;   ; when specifying a new package is to specify the following hash
         ;   ; "0000000000000000000000000000000000000000000000000000"
         ;   ; and when `guix shell` complains about a mismatch, just copy
         ;   ; the correct hash in it's place.
         ;   "1swj0di0v0yx58a3vlcqmqqm7b8qffzhv6y0r63dqr931pz9iqjj"))

         ; A safer alternative (but more work) is to get the package
         ; directly from git. The intersection between Guix and Typst
         ; is still evolving, in the future, this will hopefully be more streamlined.
         ;(create-typst-package-source
         ; `("plotst" "0.2.0"
         ;   ,(origin (method git-fetch)
         ;     (uri (git-reference
         ;           (url "https://github.com/DArtagnant/typst-plotting")
         ;           (commit "13ba9d0f6bcb063cc6a288059db47ee08092ad01")))
         ;     (sha256
         ;      (base32
         ;       "1hzigf5141qgg0z1isx36mj50rqa2b358ndgvc6m86hm620f6sn1"))))
         ; #:namespace "preview")

         ; All dependencies of a package need to be specified for guix.
         ; Here, plotst needs an extra package on which it depends.
         ;(create-typst-package-tar
         ; '("oxifmt" "0.2.0"
         ;   "0qp8a8hxh4cmhc6i34kxh22rvf7c7idqi3pq4sgag1ij2ysls396"))
         ))))
