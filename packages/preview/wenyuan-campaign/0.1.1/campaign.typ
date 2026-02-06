// DnD 5e-Style campaign template
// By Yan Xin (Yanwenyuan) 2024
// Inspired from https://github.com/rpgtex/DND-5e-LaTeX-Template
// also uses a modified version of my statblock library
// // requires droplet for dropcaps

#import "statblock.typ" as stat
#import "colours.typ" as colours
#import "dnditem.typ" as item
#import "@preview/droplet:0.3.1": dropcap

#let default-main-fonts = ("TeX Gyre Bonum", "KingHwa_OldSong")
#let default-title-fonts = ("TeX Gyre Bonum", "KingHwa_OldSong")
#let default-sans-fonts = ("Scaly Sans Remake", "KingHwa_OldSong")
#let default-sans-sc-fonts = ("Scaly Sans Caps", "KingHwa_OldSong")
#let default-dropcap-font = "Royal Initialen"
#let default-fontsize = 10pt

#let page-number-margin = (
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

#let theme-colour = state("theme_colour", colours.phbgreen)
#let theme-main-font = state("main_font", default-main-fonts)
#let theme-title-font = state("title_font", default-title-fonts)
#let theme-sans-font = state("sans_font", default-sans-fonts)
#let theme-sans-sc-font = state("sans_sc_font", default-sans-sc-fonts)
#let theme-dropcap-font = state("dropcap_font", default-dropcap-font)
#let theme-fontsize = state("font_size", default-fontsize)


/// Main configuration function. Use `#show conf.with()`.
#let conf(
  doc, 
  /// Main body font size (default 10pt) -> length
  fontsize: default-fontsize,
  /// Body text (default tex gyre and kinghwa) -> array
  main-font: default-main-fonts,
  /// Title text (default tex gyre and kinghwa) -> array
  title-font: default-title-fonts,
  /// Font used in readalouds and comment boxes (default scaly sans) -> array
  sans-font: default-sans-fonts,
  /// The default sans-font doesn't have smallcaps built in in a way typst knows so scaly sans smallcaps is separate -> array
  sans-smallcaps-font: default-sans-sc-fonts,
  /// For the main chapter drop capitals (default Royal Initialen) -> array
  dropcap-font: default-dropcap-font,
) = {
  
  theme-fontsize.update(fontsize)
  theme-main-font.update(main-font)
  theme-title-font.update(title-font)
  theme-sans-font.update(sans-font)
  theme-sans-sc-font.update(sans-smallcaps-font)
  theme-dropcap-font.update(dropcap-font)

  set text(font: main-font, size: fontsize)

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
      // the footer deliberately will not use theme font size, as it would disrupt placement
      set text(size: 0.9*default-fontsize, fill: colours.pagegold)

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
      text(smallcaps(hd) ,fill: colours.dndred, size: 2.8*fontsize, weight: "regular", font: title-font)
    )
  }

  show heading.where(level: 2) : hd => {
    set text(fill: colours.dndred, weight: "regular", size: 2*fontsize, font: title-font)
    block(smallcaps(hd.body))
  }

  show heading.where(level: 3) : hd => {
    set text(fill: colours.dndred, weight: "regular", size: 1.6*fontsize, font: title-font)
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
    set text(fill: colours.dndred, weight: "regular", size: 1.2*fontsize, font: title-font)
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
  set table(stroke: none)

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


/// sets a theme colours from the `colours` package of this module
/// or any other colour you want, on you if it looks bad :)
/// The colours recommended are:
/// `phbgreen`, `phbcyan`, `phbmauve`, `phbtan`, `dmglavender`, `dmgcoral`, `dmgslategrey` (-ay), `dmglilac`
#let set-theme-colour(
  /// -> color
  colour
) = {
  context theme-colour.update(colour)
}


/// Makes a simple title page
/// 
/// Parameters:
/// - title: main book title
/// - subtitle: (optional) subtitle
/// - author: (optional)
/// - date: (optional) -- just acts as a separate line, can be used for anything else
/// - anything-before: (optional) this is put before the title
/// - anything-after: (optional) this is put after the date
/// - page-background: (optiona)
/// - text-colour: (optional) the colour the title and bars will be rendered in
#let make-title(
  /// -> content
  title, 
  /// Appears in smaller font within the bars under the title -> content
  subtitle: [], 
  /// Appears beneath the main title -> content
  author: [], 
  /// Appears beneath the author -> content
  date: [], 
  /// Appears before the main title -> content
  anything-before: [], 
  /// Appears after everything else -> content
  anything-after: [], 
  /// -> content
  page-background: none, 
  /// The primary title colour -> color
  text-colour: colours.dndred
) = {
  set page(columns: 1, background: page-background, footer: none)
  set align(center)
  set align(horizon)
  set par(leading: 1em)

  let transparent = text-colour.transparentize(100%)

  anything-before

  context {

    line(
      start: (0%, 0%), length: 60%, 
      stroke: (paint: gradient.linear(transparent, text-colour, transparent), thickness: 1.5pt)
    )
    {
      show: smallcaps.with()
      set text(fill: text-colour, size: theme-fontsize.get()*2.5, font: theme-title-font.get())
      title
    }
    if subtitle != [] {
      linebreak()
      set text(fill: text-colour, size: theme-fontsize.get()*1.4)
      subtitle
    }
    line(
      start: (0%, 0%), length: 60%, 
      stroke: (paint: gradient.linear(transparent, text-colour, transparent), thickness: 1.5pt)
    )
    {
      set text(fill: text-colour, size: theme-fontsize.get()*1.4)
      v(2em)
      author
      v(1em)
      date
    }

  }
  linebreak()
  anything-after

  counter(page).update(0)
}


/// Makes a paragraph with a drop capital. _N.B._  Since this is rendered in a block unless you have the new typst feature where every paragraph shall be indented you'll need to `#bump()` the next paragraph.
#let drop-paragraph(
  /// any text which you wish to be rendered in small caps, like how DnD Does it -> string | content
  small-caps: "", 
  /// -> content
  body
) = context {
  if small-caps != "" {
    dropcap(
      [#smallcaps(small-caps) #body], 
      height: 4, gap: 0.3em, font: theme-dropcap-font.get()
    )
  } 
  else {
    dropcap(body, height: 4, gap: 0.3em, font: theme-dropcap-font.get())
  }
}


/// Manually does a 1em paragraph space
#let bump() = h(1em)


/// A paragraph with a bold italic name at the start
#let namedpar(
  /// the bold italic name, a full stop / period is put immediately after for you -> str | content
  title, 
  /// -> content
  content
) = [
  _*#title*__*.*_ #content
]


/// See `namedpar` but this one is in a block environment
#let namedpar-block(
  /// -> str|content
  title, 
  /// content
  content
) = block[
  _*#title*__*.*_ #content
]



/// A tan coloured read-aloud box with some decorations
#let readaloud(
  /// -> content
  content
) = {
  let corner(alignment, dxMod: 1, dyMod: 1) = place(
    alignment,
    dx: dxMod * (1em + 2pt),
    dy: dyMod * (1em + 2pt),
    circle(fill: colours.dndred, radius: 2pt),
  )

  context {

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
      #corner(top + left, dxMod: -1, dyMod: -1)
      #corner(top + right, dxMod: 1, dyMod: -1)

      #set text(font: theme-sans-font.get())
      #set par(leading: 0.5 * theme-fontsize.get(), first-line-indent: 0em, spacing: 0.8*theme-fontsize.get())
      #content 
      
      #corner(bottom + left, dxMod: -1, dyMod: 1)
      #corner(bottom + right, dxMod: 1, dyMod: 1)
    ]

  }
}


#let _common-comment-box(title, content) = [
  #set par(leading: 0.5 * theme-fontsize.get(), first-line-indent: 0em, spacing: 0.8*theme-fontsize.get())
  #set text(font: theme-sans-sc-font.get())
  #smallcaps(title)

  #set text(font: theme-sans-font.get())
  #content
]


/// A theme-coloured plain comment box
#let comment-box(
  /// Will be shown in bold small caps -> content
  title: [], 
  /// -> content
  content
) = context {
  let col = theme-colour.get();

  block(
    width: 100%,
    inset: 1em, 
    fill: col,
    above: 1em,
    below: 1em,
    breakable: true,
    _common-comment-box(title, content)
  )
}


/// A theme-coloured fancy comment box with decorations
#let fancy-comment-box(
  /// Will be shown in bold small caps -> content
  title: [], 
  /// -> content
  content
) = context {
  let col = theme-colour.get();

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

    #_common-comment-box(title, content)

    #place(  // bottom box shadow
      bottom,
      dx: -1em + 3pt, dy: 1em + 4.4pt,
      rect(width: 100% + 2em - 6pt, height: 4pt, stroke: none, fill: gradient.linear(
        colours.shadow, colours.shadow.transparentize(100%), angle: 90deg
      ))
    )

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
  ]
}


/// makes a small caps title block (e.g. for table titles)
#let sctitle(
  /// -> content
  content
) = context {
  block(
    above: 0.8em, below: 0.2em,
    {
      set text(font: theme-sans-sc-font.get())
      smallcaps(content)
    }
  )
}


/// Creates a dnd-formatted table.
/// 
/// The use of this table is identical to the default table() interface, EXCEPT
/// you do not have access to stroke, fill, or inset
#let dndtable(
  /// ->auto|int|relative|fraction|array
  columns: (), 
  /// ->auto|int|relative|fraction|array
  rows: (), 
  /// ->auto|int|relative|fraction|array
  gutter: (), 
  /// ->auto|int|relative|fraction|array
  column-gutter: (), 
  /// ->auto|int|relative|fraction|array
  row-gutter: (), 
  /// -> auto|array|alignment|function
  align: auto, 
  /// -> content
  ..children
) = context {
  let col = theme-colour.get()
  set text(font: theme-sans-font.get())

  table(
    columns: columns, rows: rows, 
    gutter: gutter, column-gutter: column-gutter, row-gutter: row-gutter,
    align: align,
    fill: (_, y) => if calc.odd(y) { col },
    stroke: none,
    inset: (left: 5pt, right: 5pt, top: 2.5pt, bottom: 2.5pt),
    ..children
  )
}


/// Begins the monster statblock environment. See *Statblock module* documentation.
#let begin-stat(content) = context {
  
  block(
    above: 2em, below: 2em, fill: colours.bgtan, inset: 1em,
    stroke: (top: 2pt + colours.rulegold, bottom: 2pt + colours.rulegold)
  )[
    #stat.smallconf(
      content,
      fontsize: theme-fontsize.get(),
      title-font: theme-main-font.get(),
      body-font: theme-sans-font.get(),
      smallcap-font: theme-sans-sc-font.get()
    )
  ]

}


/// Begins the item environment. See *Item module* documentation.
#let begin-item(content) = context {

  block(
    above: 1em, below: 1em,
    inset: (top: 0.8em, bottom: 0.8em),
    // stroke: (top: 1pt + colours.rulegold, bottom: 1pt + colours.rulegold)
  )[
    #item.conf(content, fonts: theme-main-font.get(), fontsize: theme-fontsize.get())
  ]

}


