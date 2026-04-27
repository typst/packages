#import "colors/colors.typ": style, palette, page-palette, set-palette, set-style
#import "i18n/i18n.typ": update-translation, translate, set-language
#import "i18n/translations.typ": i18n-words
#import "assets/fonts.typ": fonts
#import "content/back-cover.typ": back-cover
#import "content/cover.typ": cover
#import "content/toc.typ": toc
#import "content/appendices.typ": appendices


#let cookbook(
  title: "My Cookbook",
  book-author: "Myself",
  subtitle: "So good !",
  date: datetime.today(),
  paper: "a4",
  cover-image: none,
  custom-i18n: none,
  style: style.flat,
  chapter-on-right: false,
  palette: palette.slate,
  back-cover-content: none,
  back-cover-image: none,
  custom-indexes: none,
  custom-appendices: none,
  custom-cover: none,
  custom-back-cover:none,
  only-recipes: false,
  lang: none,
  margin: (x: 2cm, top: 2.5cm, bottom: 2.5cm),
  front-matter : none,
  back-matter: none,
  body
) = {

  set-language(lang)
  
  set-style(style)
    
  // Add custom translation if exists
  if custom-i18n != none {
    update-translation(custom-i18n)
  }

  // -------------- General Settings of the document --------------------  
  set document(title: title, author: book-author)

  set text(
    font: fonts.body,
    size: 11pt,
    features: (onum: 1)
  )
  
  
  set text(
    font: fonts.body,
    size: 11pt,
    features: (onum: 1)
  )
    
  set page(
    paper: paper,
    margin: margin,
    header: context {
      let palette = page-palette(here().page())

      set par(spacing: 1.2em) // to protect from changes for the content
      let p = counter(page).get().first()
      
      let page-cover = if only-recipes {0} else {1}
      
      if p > page-cover {
        set text(font: fonts.header, size: 9pt, fill: palette.dark)
        
        // get the previous chapter for the header
        let headings = query(selector(heading.where(level: 1)).before(here()))
        let chapter = if headings.len() > 0 {
          headings.last().body
        } else {
          book-author
        }
        
        grid(
          columns: (1fr, 1fr),
          align(left, title),
          align(right, chapter)
        )
        v(-0.8em)
        line(length: 100%, stroke: 0.5pt + palette.medium)
      }
    },
    footer: context {
      let palette = page-palette(here().page())
      set par(spacing: 0.5em)
      set text(font: fonts.header, size: 9pt, fill: palette.dark)
      let p = counter(page).get().first()
      line(length: 100%, stroke: 0.5pt + palette.medium)
      align(center)[— #p —]
    }
  )
    
    
  // Headings
  show heading.where(level: 1): it => {

    if chapter-on-right {
      pagebreak(to: "odd", weak: true)
    } else {
      pagebreak(weak: true)
    }
  
    counter(heading).step(level: 1)
    context {
      let palette = page-palette(here().page())
    
      set align(center + horizon)
      block(width: 100%)[
        #text(font: fonts.header, weight: "black", size: 3.5em, fill: palette.dark, it.body)
      ]
    }
  }
    
  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    block(below: 1.5em,
      text(font: fonts.header, weight: "bold", size: 2.2em, it.body)
    )
  }

  // reference on recipe
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 2 {
      context {
        let p = el.location().position().page
        link(el.location())[#el.body (#translate(i18n-words.page-short) #p)] 
      }
    } else {
      it
    }
  }
  
  // -------------- Cover Page --------------------
  if only-recipes == false {
   set-palette(palette)
    if custom-cover != none {
      custom-cover
    } else {
      cover(title, subtitle, date, palette, cover-image) 
    }

    if front-matter != none {
      if (chapter-on-right) {
        pagebreak(to: "odd", weak: true)
      }
      page[
        #front-matter
      ]
    }
     
    
    // -------------- TOC --------------------
    if (chapter-on-right) { // Only exception the TOC will start on the left side
      pagebreak(to: "even", weak: true)
    }
    toc(palette) 
  }
  
  
  // ----------------- Body --------------
  body

  // ---------------- Annexes ------------------
  if only-recipes == false {
    appendices(palette, custom-indexes, custom-appendices)

    if back-matter != none {
      if (chapter-on-right) {
        pagebreak(to: "even", weak: true)
      }
      page[
        #back-matter
      ]
    }

    // --------------- Back Cover -------------
    if custom-back-cover != none {
      custom-back-cover
    } else {
      if back-cover-content != none or back-cover-image != none {
        back-cover(title, book-author, back-cover-content,back-cover-image,palette)
      }  
    }  
  }
  
  
}




