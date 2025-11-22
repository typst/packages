// Constante pour le chant

#let _General-Chant-Style-Info = (
  _General-Title-Style-Info : (
    Title-font : "Noto Sans Display",
    Title-fontsize : 14pt,
    Title-spacing : 0.2cm,
  ),

  _General-Header-Style-Info : (
    Header-tune-font : "Noto Serif",
    Header-tune-fontsize : 6pt,
    Header-tune-spacing : 0.1cm,          // écart entre "air :" et la suite
    
    Header-lyrics-font : "Noto Serif",     // paroles :
    Header-lyrics-fontsize : 6pt,
    Header-lyrics-spacing : 0.1cm,        // écart entre "paroles : " et la suite 
    
    Header-comment-font : "Noto Serif",    // commentaire
    Header-comment-fontsize   : 6pt,
    Header-comment-spacing : 0.3cm,       // écart après le commentaire
  ),

  _General-Body-Style-Info : (
    Body-chorus-font : "Noto Serif",       // refrain
    Body-chorus-fontsize   : 8pt,
    Body-chorus-spacing : 0.4cm,
    Body-chorus-spacing-ref : 0.2cm,      // espace entre le mot Refrain et le refrain
    
    Body-lyrics-font : "Noto Serif",       // couplet
    Body-lyrics-fontsize   : 7.5pt,  // couplet
    Body-lyrics-spacing : 0.35cm,
  ),

  _General-Footer-Style-Info : (
    Footer-comment-font : "Noto Serif",    // note en bas de page
    Footer-comment-fontsize : 5pt ,  // note en bas de page
  ),
  
  Text-spacing : 0.2cm
)

#let _General-Chapter-Style-Info = (
  Book-title-font : "Noto Serif",  //"Hammersmith One",
  Book-title-fontsize : 25pt,
  
  Subtitle-font : "Noto Serif",
  Subtitle-fontsize : 12pt,
)



#let _General-Index-Style-Info = (
  Index-title-font :  "Noto Serif",
  Index-title-fontsize :  7pt,

  Index-letter-font : "Noto Sans Display",
  Index-letter-fontsize : 10pt,
)
// Index


#let a6-size = (width: 105mm, height : 148mm)

#let type = (
  "reglement" : 0,
  "officiel" : 2,
  "leekes" : 3,
  "groupe_folklorique" : 4,
  "andere_ziever" : 5,
  "index" : 0)

#let margin = (top:0.5cm, inside : 1cm, outside : 0.5cm, bottom : 0.6cm)

#let rectangle = rect(fill: black, width: 0.4cm, height: a6-size.height / type.len())
#let rectangle-line = rect(fill: black, width: 0.4cm, height: a6-size.height)

// Contenu des headers de chant 
#let header-settings = (tune : none,author : none,lyrics : none,pseudo : none, comments : none) 
#let image-settings = (image : none, position : bottom,alignment:center)
#let layout-info = (col1 : none,col2 : none,) 