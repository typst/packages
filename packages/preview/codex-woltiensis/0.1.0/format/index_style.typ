#import "constant.typ" : *


// Index
#let _Index-letter-font = "Hammersmith One"
#let _Index-title-font =  "Noto Sans"

#let _Index-letter-fontsize = 10pt
#let _Index-title-fontsize =  7pt

// Style pour l'index

#let index_letter(body) = {
  text(font : _Index-letter-font, size: _Index-letter-fontsize)[#text("  ")#body \ ]
}

#let index_title(song) = {
  text(font: _Index-title-font, size: _Index-title-fontsize)[
    #song.title  #box(width: 1fr, repeat[.])  #song.page #v(0.2cm, weak : true)]
}