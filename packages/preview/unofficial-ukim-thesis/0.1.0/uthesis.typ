// Unofficial UKIM Thesis / Образец за труд на УКИМ
// Врз основа на образец од Институтот за Хемија @ Природно-математички факултет, УКИМ Скопје. Изворот е во документацијата @ Github. 
// Based on a template provided by the Department of Chemistry @ Faculty of Natural Sciences, University of Cyril and Methodius Skopje. Source is provided in the documenttion @ Github

#let uthesis(
  // Општи податоци 
  title-mk: "НАСЛОВ",
  title-en: "TITLE", 
  logo: image("logo.png"), // По default, оваа слика е логото на УКИМ. За да ја смените, прикачете го логото на вашиот институт и сменете го името овде. 
  institution: "Институт/Катедра, Факултет, УКИМ",
  author: "Име и презиме",
  year: "2025",
  location: "Скопје",
  
  // Детали за комисијата и самата одбрана на трудот. 
  mentor: "Ментор: ",
  committee: (
    "Членови на комисијата:       Член 1",
    "                                                               Член 2", 
    "                                                               Член 3"
  ),
  defense-date: "Датум на одбраната:                  ",
  promotion-date: "Датум на промоција:                ",
  
  // Абстракт на два јазици, како и клучните зборови
  abstract-mk: [],
  keywords-mk: (),
  abstract-en: [],
  keywords-en: (),
  
  // Посвета доколку студентот сака да ја додаде. 
  dedication: none,
  
  // Технички податоци за документот
  font-size: 12pt,
  line-spacing: 1.5,
  margin: (x: 2.5cm, y: 2.5cm),
  
  // Содржина
  body
) = {

  // Податоци за секоја страна
  set page(
    paper: "a4",
    margin: margin,
    numbering: "1",
    number-align: center
  )
  
  // Податоци за самиот текст
  set text(
    font: "Libertinus Serif",
    size: font-size,
    lang: "mk"
  )
  
  set par(
    justify: true,
    leading: line-spacing * 0.65em,
    first-line-indent: 1.25cm
  )
  
  // Поднаслови
  show heading.where(level: 1): it => {
    set text(size: 14pt, weight: "bold")
    set block(above: 2em, below: 1.5em)
    align(center)[
      #if it.numbering != none [
        #counter(heading).display(it.numbering)
        #h(0.5em)
      ]
      #upper(it.body)
    ]
  }
  
  show heading.where(level: 2): it => {
    set text(size: 13pt, weight: "bold") 
    set block(above: 1.5em, below: 1em)
    [
      #if it.numbering != none [
        #counter(heading).display(it.numbering)
        #h(0.5em)
      ]
      #it.body
    ]
  }
  
  show heading.where(level: 3): it => {
    set text(size: 12pt, weight: "bold")
    set block(above: 1em, below: 0.5em)
    [
      #if it.numbering != none [
        #counter(heading).display(it.numbering)
        #h(0.5em)
      ]
      #it.body
    ]
  }

  // Насловна страна
  page(
    margin: (x: 3cm, y: 4cm),
    numbering: none,
    [
      #align(center)[
        #set text(size: 16pt, weight: "bold")
        #set par(leading: 1em)

        #institution

        #v(1cm)
        
        #logo
        
        #v(3cm)

        #author

        #upper(title-mk)
        
        #v(0.5cm)
        
        #text(size: 14pt)[
          – дипломска работа –
        ]

        #v(5cm)
        
        #text(size: 14pt)[
          #location, #year
        #pagebreak()
        ]

        // Од овде надолу се однесува на менторот, комисијата и 
        #align(left)[
          #set text(size: 12pt, weight: "medium")
          
          #mentor
          
          #v(0.5cm)
          
          #for line in committee [
            #line \
          ]
          
          #v(1cm)
          
          #defense-date
          
          #v(0.5cm)
          
          #promotion-date
        ]
      ]
    ]
  )

  // Посвета (доколку постои)
  if dedication != none {
    page(
      numbering: none,
      [
        #v(1fr)
        #align(center)[
          #heading(level: 1, numbering: none)[Посвета/благодарност]
          #set par(first-line-indent: 0em)
          #dedication
        ]
        #v(2fr)
      ]
    )
  }

  // Тргнува број на страни за првите неколку страни
  set page(numbering: none)
  counter(page).update(1)

  // Содржина 
  page[
    #heading(level: 1, numbering: none, outlined: false)[СОДРЖИНА]
    #set par(first-line-indent: 0em)
    #outline(
      title: none,
      indent: 0.5cm,
      depth: 3
    )
  ]

  // Апстракти на македонски и англиски
  page[
    #heading(level: 1, numbering: none, outlined: false)[Апстракт]
    #set par(first-line-indent: 0em, justify: true)
    
    #abstract-mk
    
    #v(1em)
    
    #if keywords-mk.len() > 0 [
      *Клучни зборови:* #keywords-mk.join(", ")
    ]

    #v(5cm)
    
    #heading(level: 1, numbering: none, outlined: false)[#upper(title-en)]
    #v(1em)
    #heading(level: 1, numbering: none, outlined: false)[Abstract]
    #set par(first-line-indent: 0em, justify: true)
    
    #abstract-en
    
    #v(1em)
    
    #if keywords-en.len() > 0 [
      *Keywords:* #keywords-en.join(", ")
    ]
  ]

  // Го враќа бројот на страни
  set page(numbering: "1")
  counter(page).update(1)
  
  // Нумерирање на главните делови 
  set heading(numbering: "1.1.1")
  
  // Главен текст
  body
}
 
}

#let intro() = {
  heading(level: 1)[ВОВЕД]
}

#let theory() = {
  heading(level: 1)[ТЕОРЕТСКИ ДЕЛ]
}

#let experimental() = {
  heading(level: 1)[ЕКСПЕРИМЕНТАЛЕН ДЕЛ]
}

#let results() = {
  heading(level: 1)[РЕЗУЛТАТИ И ДИСКУСИЈА]
}

#let conclusion() = {
  heading(level: 1)[ЗАКЛУЧОК]
}
