#import "@preview/kip:0.1.0": kip

#set page(width: auto, height: auto, margin: 1cm)

#kip(```
filewid *= 1.2
Src:      file "pikchr.y"; move
LemonSrc: file "lemon.c"; move
Lempar:   file "lempar.c"; move
          arrow down from LemonSrc.s
CC1:      oval "C-Compiler" ht 50%
          arrow " generates" ljust above
Lemon:    oval "lemon" ht 50%
          arrow from Src chop down until even with CC1 \
            then to Lemon.nw rad 20px
          "Pikchr source " rjust "code input " rjust \
            at 2nd vertex of previous
          arrow from Lempar chop down until even with CC1 \
            then to Lemon.ne rad 20px
          " parser template" ljust " resource file" ljust \
            at 2nd vertex of previous
PikSrc:   file "pikchr.c" with .n at lineht below Lemon.s
          arrow from Lemon to PikSrc chop
          arrow down from PikSrc.s
CC2:      oval "C-Compiler" ht 50%
          arrow
Out:      file "pikchr.o" "or" "pikchr.exe" wid 110%
```)
