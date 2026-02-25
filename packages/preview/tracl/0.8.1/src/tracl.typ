

#import "@preview/bullseye:0.1.0": *
#import "@preview/oxifmt:1.0.0": strfmt

#import "tracl-pergamon.typ": acl-refsection
#import "tracl-titlebox.typ": print-title-footnotes, affiliations-state, TITLEBOX-END-MARKER

// #let compilation-target = dictionary(std).at("target", default: () => "paged") // "html" or "paged"

// "Times" in TeX Live is actually Nimbus Roman.
// TeX Gyre Termes is builtin in the Typst web app and accepted by aclpubcheck.
// Tracl <= 0.7.0 used "Nimbus Roman No9 L" as the font.
#let tracl-serif = ("TeX Gyre Termes", "Libertinus Serif")
#let tracl-sans = ("TeX Gyre Heros", "Helvetica")
#let tracl-mono = ("Inconsolata", "DejaVu Sans Mono")

#let linespacing = 0.55em

// In Typst 0.14.0 and later, use a #title element for the title
#let use-title = sys.version >= version(0, 14, 0)

#let email(address) = text(font: tracl-mono, 11pt)[#link("mailto:" + address, address)]

#let maketitle(papertitle:none, authors:none, anonymous:false, titlebox-height: 5cm) = {
  context match-target(
    // We generate PDF => place the titlebox in a two-column container.
    // Using `place` is a little bit clunky; it makes footnotes out of the titlebox
    // difficult. But the alternative would be to enclose the entire document in
    // a `columns` element, and that has a lot of followup consequences that are even worse.
    paged: place(top + center, scope: "parent", float: true)[
      #box(height: titlebox-height, width: 1fr)[
        #align(center)[
          #if use-title {
            title()
            v(2.2em)
          } else {
            text(15pt, font: tracl-serif)[#par(leading:0.5em)[
              *#papertitle*
            ]]
            v(2.5em)
          }
        
          #if anonymous {
            set text(12pt)
            [*Anonymous ACL submission*]
          } else {
            affiliations-state.update((numbered: (:), named: (:)))
            set text(12pt)
            authors
            metadata((kind: TITLEBOX-END-MARKER))
          }
          #v(1em)
        ]      
      ]
    ],

    // We generate HTML => just print the titlebox.
    html: [
      #if use-title {
        title()
      } else {
        text(15pt, font: tracl-serif)[#par(leading:0.5em)[
          *#papertitle*
        ]]
      }

      #if anonymous {
        set text(12pt)
        [*Anonymous ACL submission*]
      } else {
        affiliations-state.update((numbered: (:), named: (:)))
        set text(12pt)
        authors
        metadata((kind: TITLEBOX-END-MARKER))
      }    
    ]
  )
}


#let darkblue = rgb("000099")
#let sidenumgray = rgb("bfbfbf")

#show link: it => text(blue)[#it]


#let abstract(abs) = {
  set par(leading: linespacing, spacing: 1em, first-line-indent: 0em, justify: true)

  context match-target(
    paged: align(center, 
      box(width: 90%,[
        #text(12pt)[*Abstract*]
        #v(0.8em)
        #text(10pt, align(left, abs))
      ])
    ),

    html: [
      // TODO wrap these in CSS classes, instead of specifying font sizes directly
      #text(12pt)[*Abstract*]
      #v(0.8em)
      #text(10pt, abs)
    ]
  )
}
    

// typeset a line number
#let sidenum(i) = {
  let s = str(i)
  while s.len() < 3 {
    s = "0" + s
  }
  text(font: tracl-sans, 7pt, fill: sidenumgray)[#s]
}

// Switch to appendix. By default, the appendices start on a fresh page.
// If you don't want this, pass "clearpage: false".
#let appendix(content, clearpage: true) = {
  if( clearpage ) { pagebreak() }

  set heading(numbering: "A.1", supplement: "Appendix")
  counter(heading).update(0)

  content
}

#let style-title(doc) = {
  // This doesn't work - waiting for advice.
  if use-title {
    show std.title: set text(15pt, font: tracl-serif)
    show std.title: set par(leading:0.5em)
    doc
  } else {
    doc
  }
}

/// Typesets a document in the ACL style.
#let acl(
  /// The body of the document.
  /// -> content
  doc, 

  /// The title of the document.
  /// -> str | content
  title: none, 

  /// The authors as they should be displayed in the titlebox.
  /// You can use `make-authors` to typeset authors in a systematic way,
  /// or you can use free-form text.
  /// -> content
  authors: none, 

  /// The authors as they should be included in the PDF metadata.
  /// If `anonymous` is true, the authors field in the metadata will
  /// always say "Anonymous". Otherwise, if you leave `meta-authors`
  /// at `none`, the authors field will be left blank.
  /// -> str
  meta-authors: none, 

  /// Determines whether the paper should be anonymized. This will
  /// suppress author information and add page and line numbers.
  /// -> bool
  anonymous: false, 

  /// The height of the titlebox, i.e. the box at the top of the paper
  /// that contains the title and authors. Tracl won't let you reduce
  /// the height of the titlebox to be less than 5cm, in accordance
  /// with the ACL style rules.
  /// -> length
  titlebox-height: 5cm,

  /// Creates a document in the ACL style without a Pergamon
  /// `refsection`. Normally, each paper needs to be enclosed in a
  /// `refsection` so that you can cite papers and print a bibliography.
  /// However, in the specific context of the example `main.typ` file,
  /// where we nest an `acl` call within another `acl` call, this
  /// breaks the bibliography of the main document. Leave this
  /// parameter at `false` unless you know what you're doing.
  /// -> bool
  suppress-refsection: false
) = {
  // accessibility
  set document(title: title)
  
  if anonymous {
    set document(author: "Anonymous")
  } else if meta-authors != none {
    set document(author: meta-authors)
  }

  // overall page setup - this only makes sense if we generate PDF
  let page-numbering = if anonymous { "1" } else { none } // number pages only if anonymous
  show: show-target(paged: doc => {
    set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm), columns: 2, numbering: page-numbering)
    set columns(gutter: 6mm)

    doc
  })

  assert(titlebox-height >= 5cm)
  
  // some colors
  show link: it => text(darkblue)[#it]
  show ref: it => text(darkblue)[#it] // TODO - this makes all of "Section 6" blue; instead, make only the 6 blue

  // font sizes
  set text(11pt, font: tracl-serif)
  set par(leading: linespacing, first-line-indent: 4mm, justify: true, spacing: linespacing)

  show figure.caption: set text(10pt, font: tracl-serif)
  show figure.caption: set align(left)
  show figure.caption: it => [#v(0.5em) #it]

  show footnote.entry: set text(9pt, font: tracl-serif)

  show raw: set text(10pt, font: tracl-mono)

  // headings
  set heading(numbering: "1.1   ")

  show heading: it => {
    set block(above: if it.level == 1 { 1.3em } else { 1.5em })
    set text(if it.level == 1 { 12pt } else { 11pt })
    it
    v(if it.level == 1 { 1.2em } else { 1em }, weak: true)
  }

  // lists and enums
  set list(indent: 1em)
  show list: set par(spacing: 1em)

  set enum(indent: 1em)
  show enum: set par(spacing: 1em)

  // spacing around figures
  // show figure: set block(inset: (top: 0pt, bottom: 1cm))

  // if anonymous, add line numbering to every page
  show: it => {
    if anonymous {
      set par.line(numbering: "001", number-clearance: 4em)
      set par.line(
        numbering: n => text(sidenumgray, font: tracl-sans, size: 8pt)[
          *#strfmt("{:03}", n)*
        ]
      )
      show figure: set par.line(numbering: none) // Disable numbers inside figures.
      it
    } else {
      it
    }
  }

  // typeset the titlebox and document
  style-title(maketitle(papertitle:title, authors:authors, anonymous:anonymous, titlebox-height: titlebox-height))
  print-title-footnotes()

  if suppress-refsection {
    doc
  } else {
    acl-refsection(doc)
  }




  // TODO: play around with these costs to optimize the layout in the end
  // set text(costs: (orphan: 0%, widow: 0%))
}

