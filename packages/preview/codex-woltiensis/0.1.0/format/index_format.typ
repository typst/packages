#import "constant.typ"
#import "index_style.typ" : *
#import "utils.typ"

#let codex-index(general-index-style-info : _General-Index-Style-Info) = context{
  
  let page-number = utils._page.get().first() 
  let page-alignment = utils.get-footer-alignemnt()
  
  set page(
      paper : "a6",
      margin : constant.margin,
      numbering: "1",
      number-align:page-alignment,
      footer-descent: -1mm,
      // retangle de la page
      background: context {
        let page = utils.get-page-number()
        place(utils.value-odd-even(page, right, left), constant.rectangle-line)
      }
  )

    let songs = utils._index-list.final()
    let songs = songs.sorted(key : it => (it.title, it.page)) // tri de la liste
    let last-letter = songs.at(0).title.at(0) // Dernière lettres utilisée

    let font-info = (
      fontname : general-index-style-info.at("Index-letter-font"),
      fontsize : general-index-style-info.at("Index-letter-fontsize")
    )
    index-letter(font-info : font-info)[*#last-letter*] //#heading(last_letter, level : 2)]
    for song in songs [
      #let new-letter = song.title.at(0)
      #if new-letter != last-letter {
        index-letter(font-info : font-info)[*#new-letter*]//heading(new_letter, level : 2)
        last-letter = new-letter
      }
      #let font-info = (
        fontname : general-index-style-info.at("Index-title-font"),
        fontsize : general-index-style-info.at("Index-title-fontsize")
      )
      #index-title(song, font-info : font-info)
    ]
}