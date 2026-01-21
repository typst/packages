#import "../format/chapter_style.typ" : *
#import "constant.typ"
#import "utils.typ"

#let chapter(
  title : "",                   // Titre de la page
  title-color : black,
  subtitle : none,              // Sous-titre de la page
  subtitle-color : black,
  alignment : center+horizon,   // Alignement du texte et de l'image sur la page
  img : (:),
  margin : constant.margin,     // Marge 
  numbering : false,            // Numération automatique ? 
  defaut-page : true,           // Page classique ou couverture ?
  general-chapter-style-info : _General-Chapter-Style-Info
) = context {

  // définition de la page
  set page(
      paper : "a6",
      margin : margin,
      numbering: if numbering {"1"} else {none},
      number-align: utils.get-footer-alignemnt(),
      footer-descent: -1mm,
  ) if defaut-page

  set page(
      paper : "a6",
      margin : margin,
  ) if not defaut-page

  let img = constant.image-settings + img
  // alignement par défaut
  set align(alignment)

  if img.image != none and img.position == top [
    #align(img.alignment)[#img.image]
  ]


  let font-info = (
    fontname : general-chapter-style-info.at("Book-title-font"),
    fontsize : general-chapter-style-info.at("Book-title-fontsize")
  )
    
  title-book(color : title-color,font-info : font-info)[#title]
  
  if (subtitle != none) {
    let font-info = (
      fontname : general-chapter-style-info.at("Subtitle-font"),
      fontsize : general-chapter-style-info.at("Subtitle-fontsize")
    )
    subtitle-chapter(subtitle-color : subtitle-color,font-info : font-info)[#subtitle]
  }

  if img.image != none and img.position == bottom [
    #align(img.alignment)[#img.image]
  ]

}