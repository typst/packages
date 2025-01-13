#import "utils.typ"

// Constante pour le chant
#let _Title-font = "Source Sans Pro"       // titre

#let _Header-tune-font = "Noto Sans"       // air :
#let _Header-lyrics-font = "Noto Sans"     // paroles :
#let _Header-comment-font = "Noto Sans"    // commentaire

#let _Body-chorus-font = "Noto Sans"       // refrain
#let _Body-lyrics-font = "Noto Sans"       // couplet

#let _Footer-comment-font = "Noto Sans"    // note en bas de page

// Taile de saut de ligne
#let _Title-spacing = 0.2cm // écart entre titre et header

#let _Header-tune-spacing = 0.1cm // écart entre "air :" et la suite
#let _Header-lyrics-spacing = 0.1cm // écart entre "paroles : " et la suite 
#let _Header-comment-spacing = 0.3cm // écart après le commentaire

#let _Body-chorus-spacing = 0.4cm
#let _Body-chorus-spacing-ref = 0.2cm  // espace entre le mot Refrain et le refrain
#let _Body-lyrics-spacing = 0.35cm

#let _Text-spacing = 0.2cm

#let _Title-fontsize = 14pt          // titre

#let _Header-tune-fontsize = 7pt     // air :
#let _Header-lyrics-fontsize = 7pt   // paroles :
#let _Header-comment-fontsize = 7pt  // commentaire

#let _Body-chorus-fontsize = 7.5pt  // refrain
#let _Body-lyrics-fontsize = 7.5pt  // couplet

#let _Footer-comment-fontsize = 5pt  // note en bas de page




// Titre
#let song_title(body) = {
  text(size: _Title-fontsize, font : _Title-font, weight: "bold")[
    #body #v(_Title-spacing, weak : true)]
}
// Partie Header : 

/* 
  header_tune(body, author: none) : Partie du header qui décrit l'air
  -> "Air : Petit Papa Noël (Tino rossi)" 
*/
#let header_tune(body, author: none, spacing : _Header-tune-spacing) = {
  text(size: _Header-tune-fontsize, font : _Header-tune-font)[
    Air : #body #if (author != none) [(#author)] else [] #v(spacing, weak : true)]
}
  

/*
  header_lyrics(author, pseudonym : none) : Partie du header qui décrit les paroles
  -> "Paroles : Sam Moinil (Jean Du Jardin)"
*/
#let header_lyrics(author, pseudonym : none, spacing : _Header-lyrics-spacing) = {
  text(size: _Header-lyrics-fontsize, font : _Header-lyrics-font)[
    Paroles : #author #if (pseudonym != none) [(#pseudonym)] else [] 
    #v(spacing, weak: true)
  ]
}

/*
  header_comment(body) : Partie du header où l'on rajoute un commentaire
  -> "Chant officiel de la VUB"
*/
#let header_comment(body) = {
  text(size: _Header-comment-fontsize, font : _Header-comment-font)[
    #body #v(_Header-comment-spacing, weak : true) // weak : false -> laisse un espace automatique du #par()
  ]
}


// Partie Body : 

//   body_lyrics(body) : Parole du chant, utilisé pour les couplets
#let body_lyrics(body) = {
  text(size: _Body-lyrics-fontsize, font : _Body-lyrics-font)[#body #v(_Body-lyrics-spacing, weak : true)]
}

//   body_chorus(body, lang : "fr") : Paroles du refrain, la langue peut etre définie en "nl"
#let body_chorus(body, lang : "fr", last: false) = {
  set text(size: _Body-chorus-fontsize)
  let first = if (lang == "fr"){ "Dernier" } else if (lang == "nl"){ "Laaste" } 
  let second = if (lang == "fr"){ "Refrain :" } else if (lang == "nl"){ "Refrein :" }
  text(if (last){first + " " + second} else {second}, font : _Body-chorus-font, weight: "bold")
  v(_Body-chorus-spacing-ref, weak: true)
  text(size: _Body-chorus-fontsize, font : _Body-chorus-font)[
    #body #v(_Body-chorus-spacing, weak : true)]
  v(_Body-chorus-spacing, weak : true)
}

//   body_chorus(lang : "fr") : Refrain, la langue peut etre définie en "nl"
#let body_chorus_simple(lang : "fr", last : false) = {
  set text(size: _Body-chorus-fontsize)
  let first = if (lang == "fr"){ "Dernier" } else if (lang == "nl"){ "Laaste" } 
  let second = if (lang == "fr"){ "Refrain" } else if (lang == "nl"){ "Refrein" } 
  text(if (last){first + " " + second} else {second}, font : _Body-chorus-font, weight: "bold")
  v(_Body-chorus-spacing, weak : true)
}
 
//  Partie Footnote
#let footnote_lyrics(body) = {
  footnote(text(size: _Footer-comment-fontsize, font : _Footer-comment-font)[#body], numbering: "1") 
}

// Partie modification de texte : (bis), (ter), (quarter), ...

#let bis(body, number: int) = [
  #body #utils.get_repeat(number)
]

// Il y a peut etre un meilleur moyen de faire. A vérifier
#let multiline_repeat(body, number : int) =context {
  let text-width = measure(body).width
  let body-height = measure(body).height
  grid(
    columns: (text-width + 5pt, 0.1fr, 3fr),
    body,line(angle : 90deg,length: body-height, stroke : 0.2pt),
    move(text(utils.get_repeat(number)), dy : body-height - _Body-chorus-fontsize)
  ) 
  v(_Text-spacing, weak: true)
}