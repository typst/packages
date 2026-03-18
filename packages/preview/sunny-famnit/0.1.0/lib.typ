// Made By Tilen Gimpelj
// questions and suggestions => https://github.com/Tiggax/famnit_typst_template
#let col = (
  gray: rgb(128,128,128),
)

#let todo = [
  #set text(fill: red)
  *TODO*
]

#let split_author(author) = {
  let a_list = author.split(" ")
  (name: a_list.at(0), surname: a_list.slice(1).join(" ") )
}

#let surname_i(author) = {
  let author = split_author(author)
  (author.surname, " ", author.name.at(0), ".").join()
}


#let project(
  naslov: "Naslov zaključne naloge",
  title: "Title of the final work",
  ključne_besede: ("typst", "je", "zakon!"),
  key_words: ("typst", "is", "awesome!"),
  izvleček: [],
  abstract: [],
  author: "Samo Primer",
  studij: "Ime študijskega programa",
  mentor: "dr. Oge So-Kul",
  somentor: none,
  kraj: "Koper",
  date: datetime(day: 1, month: 1, year: 2024),
  zahvala: none,
  kratice: (
    ("short": "long")
  ),
  priloge: (),
  bib_file: none,
  text_lang: "sl",
  body,
) = {
  let auth_dict = split_author(author)
  
  
  set document(author: (author), title: naslov, keywords: ključne_besede)

  let header(dsp) = [
    #set text(size: 10pt, fill: col.gray, top-edge: "cap-height")
    #set align(top)
    #v(1.5cm)
    
    #surname_i(author) #naslov.\
    Univerza na Primorskem, Fakulteta za matematiko, naravoslovje in informacijske tehnologije,#date.year()
    #h(1fr)
    #counter(page).display(dsp)
    #line(start: (0pt,-6pt), length: 100%, stroke: col.gray + 0.5pt)
  ]
  
  set page(
    numbering: "1", 
    number-align: center, 
    margin: (left: 3cm, top: 3cm),
    header: header("I"),
    footer-descent: 1.5cm,
    footer: []
  )
  set text(
    font: "Times New Roman", 
    lang: text_lang, 
    size: 12pt
  )

  show footnote: it => text(size: 10pt, it)
  
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => text(size: 14pt, weight: "bold",upper(it))
  show heading.where(level: 2): it => text(size: 14pt, weight: "bold", it)
  show heading.where(level: 3): it => text(size: 12pt, it)
  show heading.where(level: 4): it => text(size: 12pt, weight: "regular", it)
  
  show figure.caption: it => text(size: 10pt,it)

  show bibliography: set heading(numbering: "1.1")
  
  
  
  // --------- COVER PAGE --------------
  page(header: none, margin: (bottom: 5cm))[
    #set text(size: 14pt, spacing: 0.28em)
    #set align(center)

    
    UNIVERZA NA PRIMORSKEM\
    FAKULTETA ZA MATEMATIKO, NARAVOSLOVJE IN\
    INFORMACIJSKE TEHNOLOGIJE

    #align(center + horizon)[
      ZAKLJUČNA NALOGA

      #if text_lang == "en" {
        [(FINAL PROJECT PAPER)]
      }
    ]
    #align(center + horizon)[
      #set text(size: 18pt)
      #upper(naslov)

      #if text_lang == "en" {
        [(#upper(title))]
      }
    ]
    #set align(right + bottom)
    #upper(author)
  ]
  
  // --------- Header ---------------
  page(header:none)[
    #set text(size: 14pt)
    #set align(center)
    UNIVERZA NA PRIMORSKEM\
    FAKULTETA ZA MATEMATIKO, NARAVOSLOVJE IN\
    INFORMACIJSKE TEHNOLOGIJE

    #align(center + horizon)[
      #set text(size: 12pt)
      Zaključna naloga
      #if text_lang == "en" {
        [\ (Final project paper)]
      }

      #text(size: 14pt)[*#naslov*]
      
      (#title)
    ]
    #v(5em)
    #align(left)[
      Ime in priimek: #author\
      Študijski program: #studij\
      Mentor: #mentor\
      #if somentor != none [Somentor: #somentor\ ]
    ]
    #align(bottom + center)[
      #kraj, #date.year()
    ]
    
    #counter(page).update(1)
  ]

  // ----------- zahala -----------------
  if zahvala != none {
    page()[
      #text(weight: "bold", size: 18pt, if text_lang == "en" [Acknowledgement] else [Zahvala])

      #zahvala
    ]
  }
  let item_counter(target, prefix) = context {
    let cnt = counter(target).final().first()
    if cnt > 0 {
      let a = [#prefix: #cnt]
      style( s => {
        let m = measure(a, s)
        a + h(11em - m.width)
      })
    }
  }

  let number_of_content() = context {
    let p_cnt = counter(page)

    [#p_cnt.at(query(<body_end>).first().location()).first()]
  }
  
  // ---- Ključna dokumentacija ----
  page()[
    #h(1fr)*Ključna dokumentacijska informacija*
    
    #box(
      stroke: black + 0.5pt,
      inset: 0.5em,
      width: 100%,
    )[
      
      Ime in PRIIMEK: #auth_dict.name #upper(auth_dict.surname)

      Naslov zaključne naloge: #naslov

      #v(2em)
      
      Kraj: #kraj
      
      Leto: #date.year()
      #v(2em)


      #[Število strani: #number_of_content()]
      #h(4.7em)
      #item_counter(figure.where(kind: image), "Število slik")
      #item_counter(figure.where(kind: table), "Število tabel")
      
      #item_counter(figure.where(kind: "Priloga"), "Število prilog")
      #item_counter(page, "Št. strani prilog")
      
      #item_counter(bibliography, "Število referenc")

      Mentor: #mentor

      #if somentor != none [
        Somentor: #somentor
      ]
      #v(2em)
      Ključne besede: #ključne_besede.join(", ")

      Izvleček: 
      #v(1em)
      #izvleček
      
      
    ]
  ]

  // ---- Ključna dokumentacija (eng)----

  page()[
    #h(1fr)*Key document information*
    
    #box(
      stroke: black + 0.5pt,
      inset: 0.5em,
      width: 100%,
    )[
      
      Name and SURNAME: #auth_dict.name #upper(auth_dict.surname)

      Title of the final project paper: #title
      
      #v(2em)
      
      Place: #kraj
      
      Year: #date.year()
      #v(2em)
      
      Number of pages: #number_of_content()
      #h(3.1em)
      #item_counter(figure.where(kind: image), "Number of figures")
      #item_counter(figure.where(kind: table), "Number of tables")

      #item_counter(figure.where(kind: "Priloga"), "Number of appendix") 
      #item_counter(page, "Number of appendix pages")

      #item_counter(bibliography, "Number of references") 


      Mentor: #mentor

      #if somentor != none [
        Co-mentor: #somentor
      ]
      #v(2em)
      
      Keywords: #key_words.join(", ")

      Abstract: 
      #v(1em)
      #abstract
      
      
    ]
  ]

  // -------- TABLES ----------

  let tablepage(outlin) = context {
    let count = counter(outlin.target).final().first()
    
    if count != 0 {
      page(header: header("I"), outline(..outlin))
    } else {
      none
    }
  }
  
  
  set page(header: header("1"))
  
  tablepage((target: heading, title: if text_lang =="sl" {"Kazalo vsebine"} else {"Table of contents"}))
  

  tablepage((target: figure.where(kind: table), title: if text_lang == "sl" {"Kazalo preglednic"} else {"Index of tables"}))

  tablepage((target: figure.where(kind: image), title: if text_lang == "sl" {"Kazalo slik in grafikonov"} else {"Index of images and graphs"}))



  show outline.entry: it => {
    let f = it.body.children

    [\ ] + upper(f.at(0)) + [ ] + f.at(2) + h(2em) + f.at(4)
  }
  
  tablepage((
    target: figure.where(kind: "Priloga"), 
    title: if text_lang == "sl" {
      "Kazalo prilog"
    } else {
      "Index of Attachments"
    },
  ))
  
  // kratice
  if kratice != none {
    page(header: header("I"))[

      #upper(text(weight: "bold", size: 14pt, if text_lang == "en" [list of abbreviations] else [Seznam kratic]))
      
      #kratice.pairs().map( ((short,desc)) => {
        [/ #short: #desc #label(short)]
      }).join("")
      #counter(page).update(0)
    ]

  }

  show ref: it => {
    if it.element in kratice.values().map(p => [#p]) {
      let tar = str(it.target)
      if it.citation.supplement != none {
        let sup = it.citation.supplement
        link(it.target)[#tar\-#sup]
      } else {
        link(it.target)[#tar]
      }
    } else {
      it
    }
  }

  show figure.where(kind: "Priloga"): it => {
  }
  
  // Main body.
  set par(justify: true)
  set page(header: header("1"))

  [#metadata(none) <body_start>]
  
  body
  
  [#metadata(none) <body_end>]

  pagebreak()
  if bib_file != none {bib_file}

  counter(page).update(0)
  let priloga_counter = counter("priloga")
  priloga_counter.step()

  let priloga(content) = context {
      let a = priloga_counter.get().first()
    
      [
        #figure(
          supplement: if text_lang == "en" [Attachment] else [Priloga],
          kind: "Priloga",
          numbering: "A",
          caption: text( style: "italic", content.at(0)),
          [])
        #label("priloga_" + str(a))
        #content.at(1)
        #priloga_counter.step()
      ]
  }
  set page(
        header: align(right)[#if text_lang == "en" [Attachment] else [Priloga] #priloga_counter.display("A")],
        header-ascent: 1cm,
      )
  for name in priloge {
    priloga(name)
    pagebreak(weak: true)
  }
}
