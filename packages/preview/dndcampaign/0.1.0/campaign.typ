// DnD 5e-Style campaign template
// By Yan Xin (Yanwenyuan) 2024
// Inspired from https://github.com/rpgtex/DND-5e-LaTeX-Template
// also uses a modified version of my statblock library
// // requires droplet for dropcaps

#import calc
#import "statblock.typ" as stat
#import "colours.typ" as colours
#import "dnditem.typ" as item
#import "@preview/droplet:0.3.1": dropcap

#let mainFonts = ("TeX Gyre Bonum", "KingHwa_OldSong")
#let sansFonts = ("Scaly Sans Remake", "KingHwa_OldSong")
#let sansSCFonts = ("Scaly Sans Caps", "KingHwa_OldSong")
#let dropcapFont = "Royal Initialen"
#let fontsize = 10pt

#let pageNumberMargin = (
  0cm,
  1.2cm,
  1.3cm,
  1.4cm,
  1.5cm,
  1.6cm,
  1.7cm,
  1.8cm,
  1.9cm
)

#let themeColour = state("theme_colour", colours.phbgreen)


#let conf(doc) = {
  set text(font: mainFonts, size: fontsize)
  set page(
    columns: 2, 
    margin: (x: 1.75cm, y: 1.75cm),
    background: context {
      if calc.odd(counter(page).get().at(0)) {
        place(
          bottom + center,
          image("footer-right.png")
        )
      } else {
        place(
          bottom + center,
          image("footer-left.png")
        )
      }
    },
    footer: context {

      set text(size: 0.9*fontsize, fill: colours.pagegold)

      let counterNum = counter(page).display("1")
      let numLen = counterNum.len()
      let xAdjust = 1.07cm + 0.1cm * numLen
      let yAdjust = -3em

      if calc.odd(counter(page).get().at(0)) {
        place(
          bottom + right,
          dx:xAdjust, dy: yAdjust,
          counterNum
        )
      } else {
        place(
          bottom + left,
          dx:-xAdjust, dy: yAdjust,
          counterNum
        )
      }

      let chapters = query(selector(heading.where(level: 1, outlined: true)).before(here()))
      let chapterYAdjust = -3.5em

      if (chapters.len() > 0) {
        let currentChapter = chapters.last()
        let ccText = currentChapter.body

        if calc.odd(counter(page).get().at(0)) {
          place(
            bottom + right,
            dy: chapterYAdjust,
            smallcaps(ccText)
          )
        } else {
          place(
            bottom + left,
            dy: chapterYAdjust,
            smallcaps(ccText)
          )
        }
      }
      
    }
  )

  // ========================
  show heading.where(level: 1) : hd => {
    place(
      top + left,
      float: true,
      scope: "parent",
      text(smallcaps(hd) ,fill: colours.dndred, size: 2.8*fontsize, weight: "regular")
    )
  }

  show heading.where(level: 2) : hd => {
    set text(fill: colours.dndred, weight: "regular", size: 2*fontsize)
    block(smallcaps(hd.body))
  }

  show heading.where(level: 3) : hd => {
    set text(fill: colours.dndred, weight: "regular", size: 1.6*fontsize)
    // [#hd.fields()]
    block(
      [
        #smallcaps(hd.body)
        #v(-1.2em)
        #line(start: (0%, 0%), length: 100%, stroke: 0.7pt + colours.rulegold)
        #v(-0.4em)
      ]
    )
  }

  show heading.where(level: 4) : hd => {
    set text(fill: colours.dndred, weight: "regular", size: 1.2*fontsize)
    block(smallcaps(hd.body))
    
  }

  // ========================
  show outline.entry.where(level: 1): entry => strong(entry)
  show outline: outl => {
    set page(columns: 1)
    set heading(level: 1)
    columns(2, outl)
  }

  set outline(depth: 3)

  // ========================
  show link: lk => {
    set text(fill: colours.dndred, style: "italic")
    lk
  }

  // ========================
  show table.where(fill: none): tb => {
    set text(font: sansFonts)
    
    context {
      let col = themeColour.get()

      table(
        align: tb.align, rows: tb.rows, columns: tb.columns,
        row-gutter: tb.row-gutter, column-gutter: tb.column-gutter,
        fill: (_, y) => if calc.odd(y) { col },
        stroke: none,
        inset: (left: 5pt, right: 5pt, top: 2.5pt, bottom: 2.5pt),
        ..tb.children
      )
    }
  }


  // ========================
  
  show figure.caption: smallcaps

  // ========================
  set par(first-line-indent: 1em, spacing: 0.75*fontsize, leading: 0.5*fontsize)

  // TODO: broken by internal headings in monster and item blocks.
  // set heading(numbering: (..nums) => 
  //   if nums.pos().len() == 1 { 
  //     return "Chapter " + numbering("1.", ..nums) 
  //   } else {
  //     return none
  //   }
  // )

  doc
}


// sets a theme colours from the colours package of this module
// or any other colour you want, on you if it looks bad :)
// The colours recommended are:
// phbgreen, phbcyan, phbmauve, phbtan, dmglavender, dmgcoral, dmgslategrey (-ay), dmglilac
// 
// Parameters:
// - colour: the theme colour
#let setThemeColour(colour) = {
  context themeColour.update(colour)
}


// Makes a simple title page
// 
// Parameters:
// - title: main book title
// - subtitle: (optional) subtitle
// - author: (optional)
// - date: (optional) -- just acts as a separate line, can be used for anything else
// - anythingBefore: (optional) this is put before the title
// - anythingAfter: (optional) this is put after the date
#let makeTitle(title, subtitle: [], author: [], date: [], anythingBefore: [], anythingAfter: []) = {
  set page(columns: 1, background: none, footer: none)
  set align(center)
  set align(horizon)
  set par(leading: 1em)

  anythingBefore

  line(
    start: (0%, 0%), length: 60%, 
    stroke: (paint: gradient.linear(white, colours.dndred, white), thickness: 1.5pt)
  )
  {
    show: smallcaps.with()
    set text(fill: colours.dndred, size: fontsize*2.5)
    title
  }
  if subtitle != [] {
    linebreak()
    set text(fill: colours.dndred, size: fontsize*1.4)
    subtitle
  }
  line(
    start: (0%, 0%), length: 60%, 
    stroke: (paint: gradient.linear(white, colours.dndred, white), thickness: 1.5pt)
  )
  {
    set text(fill: colours.dndred, size: fontsize*1.4)
    v(2em)
    author
    v(1em)
    date
  }

  anythingAfter

  counter(page).update(0)
}


// Makes a paragraph with a drop captial
//
// Parameters:
// - smallCapitals: (optional) any text which you wish to be rendered in small caps, like how DnD Does it
// - body: anything else
#let dropParagraph(smallCapitals: "", body) = {
  if smallCapitals != "" {
    dropcap(
      [#smallcaps(smallCapitals) #body], 
      height: 4, gap: 0.3em, font: dropcapFont
    )
  } 
  else {
    dropcap(body, height: 4, gap: 0.3em, font: dropcapFont)
  }
}


// Manually does a 1em paragraph space
#let bump() = h(1em)


// A paragraph with a bold italic name at the start
// 
// Parameters;
// - title: the bold italic name, a full stop / period is put immediately after for you
// - content: everything else
#let namedPar(title, content) = [
  _*#title*__*.*_ #content
]


// See namedPar but this one is in a block environment
#let namedParBlock(title, content) = block[
  _*#title*__*.*_ #content
]


// A tan coloured read-aloud box with some decorations
#let readAloud(content) = {
  let corner(alignment, dxMod: 1, dyMod: 1) = place(
      alignment,
      dx: dxMod * (1em + 2pt),
      dy: dyMod * (1em + 2pt),
      circle(fill: colours.dndred, radius: 2pt),
    )

  block(
    width: 100%,
    inset: 1em, 
    fill: colours.bgtan,
    above: 1em,
    below: 1em,
    stroke: (
      right: 1pt + colours.dndred,
      left: 1pt + colours.dndred,
    ),
    breakable: true
  )[
    #set text(font: sansFonts)
    #set par(leading: 0.5 * fontsize, first-line-indent: 0em, spacing: 0.8*fontsize)
    #content 
    #corner(top + left, dxMod: -1, dyMod: -1)
    #corner(top + right, dxMod: 1, dyMod: -1)
    #corner(bottom + left, dxMod: -1, dyMod: 1)
    #corner(bottom + right, dxMod: 1, dyMod: 1)
  ]
}


// A theme-coloured plain comment box
//
// Parameters:
// - title: (optional) a title in bold small caps
// - content:
#let commentBox(title: [], content) = context {
  let col = themeColour.get();

  block(
    width: 100%,
    inset: 1em, 
    fill: col,
    above: 1em,
    below: 1em,
    breakable: true,
  )[
    #set par(leading: 0.5 * fontsize, first-line-indent: 0em, spacing: 0.8*fontsize)
    #set text(font: sansSCFonts)
    #title
    // #v(-0.5em)

    #set text(font: sansFonts)
    #content
  ]
}


// A theme-coloured fancy comment box with decorations
//
// Parameters:
// - title: (optional) a title in bold small caps
// - content:
#let fancyCommentBox(title: [], content) = context {
  let col = themeColour.get();

  block(
    width: 100%,
    inset: 1em, 
    fill: col,
    above: 1em + 6pt,
    below: 1em + 6pt,
    breakable: true,
    stroke: (
      top: 1pt + black,
      bottom: 1pt + black
    )
  )[
    #set par(leading: 0.5 * fontsize, first-line-indent: 0em, spacing: 0.8*fontsize)
    #set text(font: sansSCFonts)
    #title

    #set text(font: sansFonts)
    #content

    #place(  // bottom box shadow
      bottom,
      dx: -1em + 3pt, dy: 1em + 4.4pt,
      rect(width: 100% + 2em - 6pt, height: 4pt, stroke: none, fill: gradient.linear(
        colours.shadow, white, angle: 90deg
      ))
    )
    // #place(
    //   top + left, 
    //   rect(width: 2pt, height: 1fr, stroke: none, fill: blue)
    // )

    #place(  // bottom left
      bottom,
      dx: -1em, dy: 1em + 4.4pt,
      polygon(fill: black, stroke: none, (0pt, 0pt), (6pt, 0pt), (6pt, 4pt))
    )
    #place(  // bottom right
      bottom + right,
      dx: 1em, dy: 1em + 4.4pt,
      polygon(fill: black, stroke: none, (0pt, 0pt), (6pt, 0pt), (0pt, 4pt))
    )
    #place(  // top left
      top,
      dx: -1em, dy: - 1em - 4.4pt,
      polygon(fill: black, stroke: none, (6pt, 0pt), (6pt, 4pt), (0pt, 4pt))
    )
    #place(  // top right
      top + right ,
      dx: 1em, dy: - 1em - 4.4pt,
      polygon(fill: black, stroke: none, (0pt, 0pt), (0pt, 4pt), (6pt, 4pt))
    )
  ]
}


#let sctitle(content) = block(
  above: 0.8em, below: 0.2em,
  {
    set text(font: sansSCFonts)
    smallcaps(content)
  }
)


// begins the monster statblock environment
#let beginStat(content) = block(
  above: 2em, below: 2em, fill: colours.bgtan, inset: 1em,
  stroke: (top: 2pt + colours.rulegold, bottom: 2pt + colours.rulegold)
)[
  #set table(inset: 0% + 5pt, stroke: none, fill: colours.bgtan)
  #stat.smallconf(content)
]


// begins the item environment
#let beginItem(content) = block(
  above: 1em, below: 1em,
  inset: (top: 0.8em, bottom: 0.8em),
  // stroke: (top: 1pt + colours.rulegold, bottom: 1pt + colours.rulegold)
)[
  #item.conf(content)
]

