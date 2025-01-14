#import "constant.typ" : *
#import "utils.typ"



// Nom du Livre
#let title_book(
  body,
  color : black,
  font-info : (:)
) = {
  text(
    size: font-info.at("fontsize"),
    font : font-info.at("fontname"),
    weight: "extrabold",
    fill: color
  )[#body \ ]
}

#let subtitle_chapter(
  body,
  font-info : (:)
) = {
  text(size : font-info.at("fontsize"), font :font-info.at("fontname"), weight: "bold")[#body \ ]
}
