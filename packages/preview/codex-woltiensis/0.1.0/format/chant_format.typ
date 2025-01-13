/*
Formatage des chants. Il s'agit d'un ensemble fonctions qui utilisent les styles défini dans style.typ
*/

#import "constant.typ"
#import "../format/chant_style.typ" : *
#import "utils.typ"

#let iterate-over-body-list(body-list, body-list-format, max, min:0, step:1) = {
 for i in range(min,max,step:step){
      // refrain francais
      if (body-list-format.at(i) == "rf"){body_chorus(lang: "fr")[#body-list.at(i)]}
      // refrain néerlandais
      else if (body-list-format.at(i) == "rn"){body_chorus(lang: "nl")[#body-list.at(i)]}
      // dernier refain francais
      else if (body-list-format.at(i) == "rfl"){body_chorus(lang: "fr", last : true)[#body-list.at(i)]}
      // dernier refain nl
      else if (body-list-format.at(i) == "rnl"){body_chorus(lang: "nl", last : true)[#body-list.at(i)]}
      // refain simple fr
      else if (body-list-format.at(i) == "rfs"){body_chorus_simple(lang: "fr")}
      // refain simple fr
      else if (body-list-format.at(i) == "rns"){body_chorus_simple(lang: "nl")}
      // couplet
      else if (body-list-format.at(i) == "c") {body_lyrics()[#body-list.at(i)]
      }
  }
}

#let manage-header(header) = {
  let width1
  let width2
  if (header.tune != none){
    width1 = measure(header_tune(author : header.author)[#header.tune]).width
  }
  
  if (header.lyrics != none){
    width2 = measure(header_lyrics(pseudonym : header.pseudo)[#header.lyrics]).width
  }

  // si les deux détails de header
  if header.lyrics != none and header.tune != none {
    // si la largeur est plus petite que la page -> mets les un a coté de l'autres
    if width1 + width2 < utils.get_page_measure_margin().width [
      #header_tune(author : header.author, spacing : 0pt)[
        #header.tune #text(" "*3) #header_lyrics(pseudonym : header.pseudo)[#header.lyrics]
      ]
    ]else [
      #header_tune(author : header.author)[#header.tune]
      #header_lyrics(pseudonym : header.pseudo)[#header.pseudo]
    ]
  } else if (header.tune != none){
    header_tune(author : header.author)[#header.tune]
  } else if (header.lyrics != none){
    header_lyrics(pseudonym : header.pseudo)[#header.lyrics]
  }
}

#let column-layout(body-list, body-list-format, layout-info) = {
  let mid = if (layout-info.col1 == none) {calc.ceil(body-list.len() / 2)} 
    else {layout-info.col1}
  let col1 = [
    #iterate-over-body-list(body-list, body-list-format, mid)
    #colbreak()
  ]
  let col2 = [
    #iterate-over-body-list(body-list, body-list-format, body-list.len(), min : mid)
  ]
  columns(2)[#col1 #col2]
}

#let defaut-layout(body-list, body-list-format) = {
  iterate-over-body-list(body-list,body-list-format, body-list.len())
}

#let manage-body(body-list, body-list-format, layout, layout-info) = {
   if (layout == "default") {
    defaut-layout(body-list, body-list-format)
  } else if (layout == "column") {
    column-layout(body-list, body-list-format, layout-info)
  }
}

#let manage-content(title,body-list,body-list-format,layout,layout-info,header,img,sub-content) = return {
  if img.path != none and img.position == top [
    #align(img.alignment)[#image(img.path, width: img.width, height: img.height)]
  ]
  
  song_title[#title]
  
  manage-header(header)
  
  v(0.3cm, weak : true)// délimitation entre commentaire et 
  
  if (header.comments != none){
    header_comment[#header.comments]
  } 
  
  v(0.2cm, weak : true)// délimitation entre header et body
  
  manage-body(body-list, body-list-format, layout, layout-info)
  
  if img.path != none and img.position == bottom [
    #align(img.alignment)[#image(img.path, width: img.width, height: img.height)]
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
) = context {
  // replace non complete entry by none
  let header = constant.header-settings + header

  let img = constant.image-settings + img
  if (img.path != none) {img.path = "../images/" + img.path}


  let layout-info = constant.layout-info + layout-info

  let page-alignment = utils.get_footer_alignemnt()
  let page-num = utils.get_page_number()
  
  // assert that length of both dictionnary are the same
  assert(                            
    body-list.len() == body-list-format.len(),
    message : "La taille entre body-list et body-list-format n'est pas la même"
  )

  set page(
      paper : "a6",
      margin : constant.margin,
      numbering: "1",
      number-align: utils.get_footer_alignemnt(),
      footer-descent: -1mm,
      background:{
        let page = utils.get_page_number()
        let posit = utils.get_rectangle_position(type, page-alignment)
        place(constant.rectangle, dy : posit.dy, utils.value_odd_even(page,right,left))
      }
    ) if new-page

  
  manage-content(
    title,
    body-list,
    body-list-format,
    layout,layout-info,
    header,
    img,
    sub-content)

 
  
  utils._index-list.update(index_list=> {
      index_list.push((title : title, page : page-num))
      index_list
    }
  )
  counter(footnote).update(0) // reset le counter des notes en bas de pages
  //pagebreak(weak: true) 
}