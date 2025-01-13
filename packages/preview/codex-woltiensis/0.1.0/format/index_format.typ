#import "constant.typ"
#import "index_style.typ" : *
#import "utils.typ"

#let fullindex() = context{
  
  let page-number = utils._page.get().first() 
  let page-alignment = utils.get_footer_alignemnt()
  
  set page(
      paper : "a6",
      margin : constant.margin,
      numbering: "1",
      number-align:page-alignment,
      footer-descent: -1mm,
      // retangle de la page
      background: context {
        let page = utils.get_page_number()
        place(utils.value_odd_even(page, right, left), constant.rectangle-line)
      }
  )

    let songs = utils._index-list.final()
    let songs = songs.sorted(key : it => (it.title, it.page)) // tri de la liste
    let last-letter = songs.at(0).title.at(0) // Dernière lettres utilisée
  
    index_letter[*#last-letter*] //#heading(last_letter, level : 2)]
    for song in songs [
      #let new-letter = song.title.at(0)
      #if new-letter != last-letter {
        index_letter[*#new-letter*]//heading(new_letter, level : 2)
        last-letter = new-letter
      }
      #index_title(song)
    ]
}