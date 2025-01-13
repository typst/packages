#import "utils.typ"

// Titre du receuil
#let _Book-title = "Codex Woltiensis" // "CODEX WOLTIENSIS"

#let _Book-title-font = "Hammersmith One"
#let _Subtitle-font = "Noto Sans"

#let _Book-Title-fontsize = 25pt
#let _Subtitle-fontsize = 12pt



// Nom du Livre
#let title_book(body, color : black) = {
  text(
    size: _Book-Title-fontsize,
    font : _Book-title-font,
    weight: "extrabold",
    fill: color
  )[#body \ ]
}

#let subtitle_chapter(body) = {
  text(size : _Subtitle-fontsize, font : _Subtitle-font, weight: "bold")[#body \ ]
}
