; Lines starting with a ; are comments in guile (the language used in guix)

; This file will enable your bit-reproducible document when using
; `guix time-machine`.
; This list pins the software you'll be using to their *exact* versions.
; At the moment, you still need to manually pin the 'sos-ugent-style channel
; to the version you are using.

(list (channel
        (name 'guix)
        (url "https://git.guix.gnu.org/guix.git")
        (branch "master")
        ; This pins the exact guix version for reproducibility.
        ; Remove (commit "") to use the latest guix (non-reproducible,
        ; since things might break in the future - but you can do this
        ; to get the latest version and then pin it again if everything works)
        (commit
          "669a6c8e992d4d4beb5b47a053f0a29f09ac5bf4")
        ; The channel 'introduction' is for security
        (introduction
          (make-channel-introduction
            "9edb3f66fd807b096b48283debdcddccfea34bad"
            (openpgp-fingerprint
              "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
      (channel
        (name 'sos-ugent-style)
        (url "https://codeberg.org/th1j5/typst-sos-ugent-style")
        (branch "main")
        ; At the moment, you need to manually pin this to the latest commit.
        ; Use `guix time-machine -C .guix/channels-lock.scm -- describe` and
        ; copy the hash into the next field. Just like above ↑. At the moment
        ; this field is commented, thus you are following the latest commits.
        ;(commit "") ; EDIT
        (introduction
          (make-channel-introduction
            "6d2497f423c99ab9de5d0e21b4f28b077cc93331"
            (openpgp-fingerprint
              "2B37 2BF1 7F9B 9213 FDDC  C4AF 6FE6 2826 909A 796F")))))
