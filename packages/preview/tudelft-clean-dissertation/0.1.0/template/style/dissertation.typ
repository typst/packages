#import "sidebar.typ": active_chapter_box, active_chapter_backside_box, inactive_chapter_box

#let tudelftbook(doc) = {
  // check if the user added the commit SHA along with compile command
  // e.g. typst compile thesis.typ --commit="ae55edf"
  let commit = sys.inputs.at("commit", default: "unknown")

  set page(
    width: 170mm,  // standard dissertation size is a modified B5
    height: 240mm,  // standard dissertation size is a modified B5
    margin: (inside: 2.55cm, outside: 1.6cm, y: 1.75cm),  // differential margins for even/odd pages
    header: context {
      counter(footnote).update(0)
      let needs-header = (query(selector(<start-headers>).before(here()))).len() > 0
      if needs-header {
        if calc.even(counter(page).get().first()) {  // even pages
            // add page number
            counter(page).display( 
              "1",
              both: false,
            )  
            h(1fr)
            text(7pt, rgb(0,0,0,0))[~~#commit~~]  // add commit SHA (hidden)
            // add current chapter title
            let headings = query(selector(heading.where(level: 1)).before(here()))
            if headings.len() > 0 {
              strong[Chapter #counter(heading).get().first() ]
              headings.last().body
            }
        } else {  // odd pages
          let headings = query(selector(heading.where(level: 2)).before(here()))
            if headings.len() > 0 {
              strong[Section: ]
              headings.last().body
            }
            text(7pt, rgb(0,0,0,0))[~~#commit~~]  // add commit SHA (hidden)
            h(1fr)
            counter(page).display(
              "1",
              both: false,
            )  
        }
      }
    },
    // foreground is rendered on top of everything on page
    foreground: context {

      // add sidebar boxes that allow quick navigation to chapter from side of printed book
      // we first define these functions below, and then draw them.

      let base_y_offset = 50pt // what height from top of page should boxes start
      let box_height = 70pt  // how far down should each box move per chapter 

      // find our chapter openers (created with #chapter-cover in /style/chapter.typ)
      let all-chapters = query(heading.where(level: 10))  // these hidden headings are level 10
      let chapter_index = counter(heading).get().at(0)  // keep track of which chapter we are currently in

      // make sure we only place the sidebar in the region between these selectors
      let past_start = (query(selector(<start-headers>).before(here()))).len() > 0
      let before_end = (query(selector(<end-chapter-markers>).after(here()))).len() > 0
      
      // place the sidebar boxes
      if (past_start and before_end) {
        if calc.even(counter(page).get().first()) {  // even pages
          active_chapter_backside_box(chapter_index, base_y_offset, box_height)
        } else {  // odd pages
          // place non-active chapter boxes
          for (index, chapter-header) in all-chapters.enumerate() { inactive_chapter_box(right, chapter-header, index, base_y_offset, box_height) }
          // place active chapter box
          active_chapter_box(chapter_index, base_y_offset, box_height)
        }
      }
    }
  )

  // override caption show styling
  show figure.caption: it => [
    #set text(size: 7pt) // smaller font size for captions
    #set par(justify: true) // justify text
    #set align(left) // we want left-aligned text as center align is for sociopaths
    #strong(it.supplement)  // bold "Figure"
    #strong(context it.counter.display(it.numbering)) // bold "1" 
    #it.body  // actual caption e.g. "Cool picture of a frog"
  ]


  // style figures

  // reset figure numbering when a new chapter is encountered. To be more
  // specific, when a new level 1 heading is encountered
  show heading.where(level: 1): it => {
     
    it
  }

  set figure(numbering: num => {
    let chap_num = counter(heading).at(here()).first()
    if chap_num != none {
      numbering("1.1", chap_num, num)
    } else {
      numbering("1", num)
    }
  })


  // style links to add a subtle underline
  show link: it => {
    underline(stroke: luma(180), offset:1.5pt, it)
  }


  set par(
    justify: true,
    justification-limits: (tracking: (min: -0.01em, max: 0.02em))
  )

  set text(font: "Atkinson Hyperlegible",  size: 9pt)

  set heading(numbering: "1.1.", supplement: [Chapter])

  // hide level 3 heading numbering. So no 3.2.1, only 3.1, 3.2 and no 
  // heading text for 3rd level. "3.2.4 MySection" -> "MySection"
  show heading.where(level: 3): set heading(numbering: none)

  // make citations show up in superscript rather than normal text
  show cite: it => {
    super[#it]
  }

  // enable equation numbering
  set math.equation(numbering: "1.")

  // make the footnotes distinct from citations
  set footnote(numbering: n => text(fill: luma(125))[*#sym.lozenge.filled#n*])  
  //show footnote.entry: it => {} //uncomment to hide footnotes

  doc // actual document content
}

// style commands




// custom commands for your own use

#let citneeded() = box[#super(text(red)[🧾Citation Needed])]

#let revisit(term) = box[#super(text(red)[⚠Revisit This #term])]


// a footnote that doesn't reference anything. For footnotes not referencing anything in main text.
#let footnote-orphan(body) = {
  footnote(numbering: _ => [])[#body]
  counter(footnote).update(n => n - 1)
}


#let definition(body) = {
  text(fill: red)[body]
}

// Style Guide Other ////////////////////////////////////////////////////////////////////////////////

// # chapter status colours (for highlighting)
// e.g. " == #highlight(fill: rgb("#f97c7c"))[section that is mostly incomplete] "
// mostly unfinished:  #f97c7c
// good progress, but needs more work: #FAC898
// mostly complete, maybe one more small exp neded #d2e7d6


