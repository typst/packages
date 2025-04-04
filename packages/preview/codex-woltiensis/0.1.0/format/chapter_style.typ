#import "constant.typ" : *
#import "utils.typ"



// Nom du Livre
#let title-book(
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

#let subtitle-chapter(
  body,
  subtitle-color : black,
  font-info : (:)
) = {
  text(
    size : font-info.at("fontsize"),
    font :font-info.at("fontname"),
    fill : subtitle-color ,
    weight: "bold")[#body \ ]
}
