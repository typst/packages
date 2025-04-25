#import "utils.typ"
#import "constant.typ" : *


// Titre
#let song-title(
  body,
  spacing : none,
  font-info : (:)
) = {
  text(size: font-info.at("fontsize"), font : font-info.at("fontname"), weight: "bold")[
    #body #v(spacing, weak : true)]
}
// Partie Header : 

/* 
  header_tune(body, author: none) : Partie du header qui décrit l'air
  -> "Air : Petit Papa Noël (Tino rossi)" 
*/
#let header-tune(
  body,
  author: none,
  spacing : none,
  font-info : (:)
) = {
  text(size:font-info.at("fontsize"), font : font-info.at("fontname"))[
    Air : #body #if (author != none) [(#author)] else [] #v(spacing, weak : true)]
}
  

/*
  header_lyrics(author, pseudonym : none) : Partie du header qui décrit les paroles
  -> "Paroles : Sam Moinil (Jean Du Jardin)"
*/
#let header-lyrics(
  author,
  pseudonym : none,
  spacing : none,
  font-info : (:)
) = {

  text(size: font-info.at("fontsize"), font : font-info.at("fontname"))[
    Paroles : #author #if (pseudonym != none) [(#pseudonym)] else [] 
    #v(spacing, weak: true)
  ]
}

/*
  header_comment(body) : Partie du header où l'on rajoute un commentaire
  -> "Chant officiel de la VUB"
*/
#let header-comment(
  body,
  spacing : none,
  font-info : (:)
) = {
  text(size: font-info.at("fontsize"), font : font-info.at("fontname"))[
    #body #v(spacing, weak : true)
  ]
}


// Partie Body : 

#let body-lyrics(
  body,
  spacing : none,
  font-info : (:)
) = {
  text(
    size: font-info.at("fontsize"),
    font : font-info.at("fontname"))[
      #body #v(spacing, weak : true)
    ]
}

//   body_chorus(body, lang : "fr") : Paroles du refrain, la langue peut etre définie en "nl"
#let body-chorus(
  body,
  lang : "fr",
  last: false,
  spacing : none,
  spacing-ref :none,
  font-info : (:)
) = {

  set text(size: font-info.at("fontsize"))

  
  let first = if (lang == "fr"){ "Dernier" } else if (lang == "nl"){ "Laaste" } 
  let second = if (lang == "fr"){ "Refrain :" } else if (lang == "nl"){ "Refrein :" }
  
  text(
    if (last){first + " " + second} else {second},
    font : font-info.at("fontname"), weight: "bold"
  )
  
  v(spacing-ref, weak: true)
  text(size: font-info.at("fontsize"), font : font-info.at("fontname"))[
    #body #v(spacing, weak : true)
  ]
  v(spacing, weak : true)
}

//   body_chorus(lang : "fr") : Refrain, la langue peut etre définie en "nl"
#let body-chorus-simple(
  lang : "fr",
  last : false,
  spacing : none,
  font-info : (:)
) = {

  set text(size: font-info.at("fontsize"))
  
  let first = if (lang == "fr"){ "Dernier" } else if (lang == "nl"){ "Laaste" } 
  let second = if (lang == "fr"){ "Refrain" } else if (lang == "nl"){ "Refrein" }
  
  text(
    if (last){first + " " + second} else {second},
     font : font-info.at("fontname"), weight: "bold"
  )
  
  v(spacing, weak : true)
}
 
//  Partie Footnote
#let footnote-lyrics(
  body,
  font-info : (
    fontname : _General-Chant-Style-Info.at("_General-Footer-Style-Info").at("Footer-comment-font"),
    fontsize :  _General-Chant-Style-Info.at("_General-Footer-Style-Info").at("Footer-comment-fontsize"),
  )
) = {
  footnote(
    text(size: font-info.at("fontsize"), font : font-info.at("fontname"))[#body],
    numbering: "1"
  ) 
}

// Partie modification de texte : (bis), (ter), (quarter), ...

#let bis(body, number: int) = [
  #body #utils.get-repeat(number)
]

// Il y a peut etre un meilleur moyen de faire. A vérifier
#let multiline-bis(
  body,
  number : int,
  spacing :_General-Chant-Style-Info.at("Text-spacing"),
  font-info : (
    fontname :none,
    fontsize :  _General-Chant-Style-Info.at("_General-Body-Style-Info").at("Body-chorus-fontsize")
  )
) =context {
  let text-width = measure(body).width
  let body-height = measure(body).height
  grid(
    columns: (text-width + 5pt, 0.1fr, 3fr),
    body,line(angle : 90deg,length: body-height, stroke : 0.2pt),
    move(text(utils.get-repeat(number)), dy : body-height - font-info.at("fontsize"))
  ) 
  v(spacing, weak: true)
}