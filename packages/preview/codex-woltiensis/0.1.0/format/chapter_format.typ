#import "../format/chapter_style.typ" : *
#import "constant.typ"
#import "utils.typ"




#let chapter(
  title : "",                   // Titre de la page
  title-color : black,
  subtitle : none,              // Sous-titre de la page
  alignment : center+horizon,   // Alignement du texte et de l'image sur la page
  img : (:),
  margin : constant.margin,     // Marge 
  numbering : false,            // Numération automatique ? 
  defaut-page : true,           // Page classique ou couverture ?
) = context {

  // définition de la page
  set page(
      paper : "a6",
      margin : margin,
      numbering: if numbering {"1"} else {none},
      number-align: utils.get_footer_alignemnt(),
      footer-descent: -1mm,
  ) if defaut-page

  set page(
      paper : "a6",
      margin : margin,
  ) if not defaut-page

  let img = constant.image-settings + img
  if (img.path != none) {img.path = "../images/" + img.path}
  
  // alignement par défaut
  set align(alignment)

  if img.path != none and img.position == top [
    #align(img.alignment)[#image(img.path, width: img.width, height: img.height)]
  ]
  title_book(color : title-color)[#title]
  
  if (subtitle != none) {subtitle_chapter[#subtitle]}}
}