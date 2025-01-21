/*
Formatage des chants. Il s'agit d'un ensemble fonctions qui utilisent les styles défini dans style.typ
*/
#import "constant.typ"
#import "../format/chant_style.typ" : *
#import "utils.typ"

#let iterate-over-body-list(
  body-list,
  body-list-format,
  general-body-style-info,
  max,
  min:0,
  step:1,
) = {
  for i in range(min,max,step:step){
    let body-chorus-spacing = general-body-style-info.at("Body-chorus-spacing")
    let body-chorus-spacing-ref = general-body-style-info.at("Body-chorus-spacing-ref")
    let body-chorus-fontinfo =  (
        fontname : general-body-style-info.at("Body-chorus-font"),
        fontsize :  general-body-style-info.at("Body-chorus-fontsize")
    )
  
    let body-lyrics-spacing = general-body-style-info.at("Body-lyrics-spacing")
    
    let body-lyrics-fontinfo =  (
        fontname : general-body-style-info.at("Body-lyrics-font"),
        fontsize :  general-body-style-info.at("Body-lyrics-fontsize")
      )
  
    
    // refrain francais
    if (body-list-format.at(i) == "rf"){
      body-chorus(
        lang: "fr",
        spacing : body-chorus-spacing,
        spacing-ref : body-chorus-spacing-ref,
        font-info : body-chorus-fontinfo,
      )[#body-list.at(i)]
    }
      
    // refrain néerlandais
    else if (body-list-format.at(i) == "rn"){
      body-chorus(
        lang: "nl",
        spacing : body-chorus-spacing,
        spacing-ref : body-chorus-spacing-ref,
        font-info : body-chorus-fontinfo
      )[#body-list.at(i)]
    }
      
    // dernier refain francais
    else if (body-list-format.at(i) == "rfl"){
      body-chorus(
        lang: "fr",
        last : true,
        spacing : body-chorus-spacing,
        spacing-ref : body-chorus-spacing-ref,
        font-info : body-chorus-fontinfo
      )[#body-list.at(i)]
    }
      
    // dernier refain nl
    else if (body-list-format.at(i) == "rnl"){
      body-chorus(
        lang: "nl",
        last : true,
        spacing : body-chorus-spacing,
        font-info : body-chorus-fontinfo
      )[#body-list.at(i)]
    }
      
    // refain simple fr
    else if (body-list-format.at(i) == "rfs"){
      body-chorus-simple(
        lang: "fr",
        spacing : body-chorus-spacing,
        font-info : body-chorus-fontinfo
      )
    }
    // refain simple fr
    else if (body-list-format.at(i) == "rns"){
      body-chorus-simple(
        lang: "nl",
        spacing : body-chorus-spacing,
        font-info : body-chorus-fontinfo
      )
    }
    // couplet
    else if (body-list-format.at(i) == "c") {
      body-lyrics(
        spacing : body-lyrics-spacing,
        font-info : body-lyrics-fontinfo
      )[#body-list.at(i)]
    }
  }
}

#let manage-header(header, general-header-style-info) = {
  let width1
  let width2
  
  if (header.tune != none){
    width1 = measure(
      header-tune(
        author : header.author,
        spacing : general-header-style-info.at("Header-tune-spacing"),
        font-info : (
          fontname : general-header-style-info.at("Header-tune-font"),
          fontsize : general-header-style-info.at("Header-tune-fontsize")
        )
      )[#header.tune]).width
  }
  
  if (header.lyrics != none){
    width2 = measure(
      header-lyrics(
        pseudonym : header.pseudo,
        spacing : general-header-style-info.at("Header-lyrics-spacing"),
        font-info : (
          fontname : general-header-style-info.at("Header-lyrics-font"),
          fontsize :  general-header-style-info.at("Header-lyrics-fontsize")
        )
      )[#header.lyrics]).width
  }

  // si les deux détails de header
  if header.lyrics != none and header.tune != none {
    // si la largeur est plus petite que la page -> mets les un a coté de l'autres
    if width1 + width2 < utils.get-page-measure-margin().width [
      #header-tune(
        author : header.author,
        spacing : 0pt,
        font-info : (
          fontname : general-header-style-info.at("Header-tune-font"),
          fontsize :  general-header-style-info.at("Header-tune-fontsize")
        )
      )[
        #header.tune #text(" "*3) #header-lyrics(
          pseudonym : header.pseudo,
          spacing : 0pt,
          font-info : (
            fontname : general-header-style-info.at("Header-lyrics-font"),
            fontsize :  general-header-style-info.at("Header-lyrics-fontsize")
          )
        )[#header.lyrics]
      ]
    ]else [
      #header-tune(
        author : header.author,
        spacing : general-header-style-info.at("Header-tune-spacing"),
        font-info : (
          fontname : general-header-style-info.at("Header-tune-font"),
          fontsize :  general-header-style-info.at("Header-tune-fontsize")
        )
      )[#header.tune]
      #header-lyrics(
        pseudonym : header.pseudo,
        spacing : general-header-style-info.at("Header-lyrics-spacing"),
        font-info : (
          fontname : general-header-style-info.at("Header-lyrics-font"),
          fontsize : general-header-style-info.at("Header-lyrics-fontsize")
        )
      )[#header.pseudo]
    ]
  } else if (header.tune != none){
    header-tune(
      author : header.author,
      spacing : general-header-style-info.at("Header-tune-spacing"),
      font-info : (
          fontname : general-header-style-info.at("Header-tune-font"),
          fontsize :  general-header-style-info.at("Header-tune-fontsize")
      )
    )[#header.tune]
  } else if (header.lyrics != none){
    header-lyrics(
      pseudonym : header.pseudo,
      spacing : general-header-style-info.at("Header-lyrics-spacing"),
      font-info : (
        fontname : general-header-style-info.at("Header-lyrics-font"),
        fontsize :  general-header-style-info.at("Header-lyrics-fontsize")
      )
    )[#header.lyrics]
  }
}

#let column-layout(body-list, body-list-format, layout-info,general-body-style-info) = {
  let mid = if (layout-info.col1 == none) {calc.ceil(body-list.len() / 2)} 
    else {layout-info.col1}
  let col1 = [
    #iterate-over-body-list(
      body-list, 
      body-list-format,
      general-body-style-info,
      mid)
    #colbreak()
  ]
  let col2 = [
    #iterate-over-body-list(
      body-list, 
      body-list-format,
      general-body-style-info,
      body-list.len(), min : mid)
  ]
  columns(2)[#col1 #col2]
}

#let defaut-layout(body-list, body-list-format, general-body-style-info) = {
  iterate-over-body-list(
    body-list,
    body-list-format,
    general-body-style-info,
    body-list.len(),
  )
}

#let manage-body(
  body-list,
  body-list-format,
  layout,
  layout-info,
  general-body-style-info
) = {
    
   if (layout == "default") {
    defaut-layout(body-list, body-list-format, general-body-style-info)
  } else if (layout == "column") {
    column-layout(
      body-list,
      body-list-format,
      layout-info,
      general-body-style-info)
  }
}

#let manage-content(
  title,
  body-list,
  body-list-format,
  layout,
  layout-info,
  header,
  img,
  sub-content,
  general-chant-style-info
) = return {
  
  if img.image != none and img.position == top [
    #align(img.alignment)[#img.image]
  ]

  let _General-Title-Style-Info = general-chant-style-info.at("_General-Title-Style-Info")
  song-title(
    spacing : _General-Title-Style-Info.at("Title-spacing"),
    font-info : (
      fontname : _General-Title-Style-Info.at("Title-font"),
      fontsize : _General-Title-Style-Info.at("Title-fontsize")
    )
  )[#title]

  let general-header-style-info = general-chant-style-info.at("_General-Header-Style-Info")
  manage-header(header, general-header-style-info)

  
  v(0.3cm, weak : true)// délimitation entre commentaire et 
  
  if (header.comments != none){
    header-comment(
      spacing : general-header-style-info.at("Header-comment-spacing"),
      font-info : (
        fontname : general-header-style-info.at("Header-comment-font"),
        fontsize :  general-header-style-info.at("Header-comment-fontsize")
      )
    )[#header.comments]
  } 
  
  v(0.2cm, weak : true)// délimitation entre header et body

  let general-body-style-info = general-chant-style-info.at("_General-Body-Style-Info")
  
  manage-body(
    body-list,
    body-list-format,
    layout,
    layout-info,
    general-body-style-info)
  
  if img.image != none and img.position == bottom [
    #align(img.alignment)[#img.image]
  ]
  
  if (sub-content != none) { sub-content }  
}



#let chant(
  title,                  // Titre du Chant
  body-list,              // Liste des refrains et couplet du chant
  body-list-format,       // Format des refrains et couplet du chant
  layout : "default",     // Layout simple ? En colonne ? autre ?
  layout-info : (:),      // Info additionnelle du layout
  header : (:),           // En tête : paroles, airs, commentaire
  img : (:),              // Image ajoutée dans le chant ?
  sub-content : none,     // Sous chant ? autre contenu ?
  new-page: true,         // Nouvelle page pour le chant ? utilisé  si sub-content = chant(...)
  type : "leekes",        // type de chant, utile pour les rectangle noirs
  general-chant-style-info : constant._General-Chant-Style-Info,
) = context {
  // replace non complete entry by none
  let header = constant.header-settings + header

  let img = constant.image-settings + img


  let layout-info = constant.layout-info + layout-info
  //let general-chant-style-info = constant._General-Chant-Style-Info + general-chant-style-info

  let page-alignment = utils.get-footer-alignemnt()
  let page-num = utils.get-page-number()
  
  // assert that length of both dictionnary are the same
  assert(                            
    body-list.len() == body-list-format.len(),
    message : "La taille entre body-list et body-list-format n'est pas la même"
  )

  set page(
      paper : "a6",
      margin : constant.margin,
      numbering: "1",
      number-align: utils.get-footer-alignemnt(),
      footer-descent: -1mm,
      background: context {
        let page = utils.get-page-number()
        let posit = utils.get-rectangle-position(type, page)
        place(utils.value-odd-even(page, right, left), constant.rectangle, dy: posit.dy)
      }
    ) if new-page

  
  manage-content(
    title,
    body-list,
    body-list-format,
    layout,layout-info,
    header,
    img,
    sub-content,
    general-chant-style-info,
  )


 
  
  utils._index-list.update(index-list=> {
      index-list.push((title : title, page : page-num))
      index-list

    }
  )
  counter(footnote).update(0) // reset le counter des notes en bas de pages
  //pagebreak(weak: true) 
}