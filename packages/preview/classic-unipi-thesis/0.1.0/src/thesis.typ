// Template Tesi di Laurea - Università di Pisa
// Conforme al template LaTeX ufficiale (report class, twoside, openright, 13pt, margini 3cm)

#import "frontespizio.typ": frontespizio

#let in-appendix = state("in-appendix", false)
#let suppress-header-pages = state("suppress-header-pages", ())

// Titolo breve di una figura per l'elenco delle figure: la prima frase della didascalia,
// troncata a `max` caratteri (al limite di parola) con "…". Il resto resta solo sotto la figura.
#let short-caption(el, max: 50) = {
  let kids = if el.caption.body.has("children") { el.caption.body.children } else { (el.caption.body,) }
  let out = ()
  let used = 0
  let cut = false
  for k in kids {
    if cut { break }
    if k.func() == text {
      let t = k.text
      // fine della prima frase: un punto seguito da spazio, ma non in "vs." / "e.g." / "i.e."
      let end = none
      for m in t.matches(regex("\\.(\\s|$)")) {
        let before = t.slice(0, m.start)
        if not (before.ends-with("vs") or before.ends-with("e.g") or before.ends-with("i.e")) {
          end = m.start
          break
        }
      }
      if end != none {
        t = t.slice(0, end)
        cut = true
      }
      if used + t.len() > max {
        t = t.slice(0, max - used)
        let sp = t.clusters().rev().position(c => c == " ")
        if sp != none and sp < t.len() - 1 { t = t.slice(0, t.len() - sp - 1) }
        t = t.trim() + "…"
        cut = true
      }
      used += t.len()
      out.push(t)
    } else {
      out.push(k)
    }
  }
  out.join()
}

// Pagina dei ringraziamenti: titolo localizzato in base alla lingua della tesi,
// non inserita nell'indice e senza testatina.
#let acknowledgements(body) = context {
  let title = if text.lang == "it" { "Ringraziamenti" } else { "Acknowledgements" }
  heading(level: 1, numbering: none, outlined: false, title)
  body
}

#let appendix(body) = {
  in-appendix.update(true)
  counter(heading).update(0)
  body
}

#let thesis(
  title: "Un fantastico titolo per la mia tesi di laurea!",
  author: "Nome Cognome",
  department: "Dipartimento di Ingegneria dell'Informazione",
  degree: "Corso di Laurea Magistrale in Ingegneria Informatica",
  supervisors: (
    "Prof. Nome Cognome",
    "Prof. Nome Cognome",
  ),
  academic-year: "202X/202Y",
  // Alias opzionali
  titolo: none,
  autore: none,
  candidato: none,
  dipartimento: none,
  tipo-laurea: none,
  corso-di-laurea: none,
  relatori: none,
  anno-accademico: none,
  lang: "it",
  // Logo nel frontespizio: `auto` per il Cherubino (incluso nel pacchetto), un contenuto
  // (es. `image("logo.svg")`) per un altro logo, `none` per ometterlo
  logo: auto,
  // Margini del frontespizio (indipendenti da quelli del resto della tesi)
  frontespizio-margin: (top: 3cm, bottom: 3cm, left: 3.5cm, right: 3.5cm),
  // Dedica (contenuto): pagina a destra in corsivo dopo il frontespizio; `none` per ometterla
  dedication: none,
  // Indice generale ed elenco delle figure (titoli localizzati in base a `lang`)
  tableofcontents: false,
  lof: false,
  toc-depth: 3,
  body,
) = {
  import "@preview/i-figured:0.2.4"
  
  show figure.caption: set align(center)
  show raw.where(block: true): set align(left)

  // Numeri nel testo scritti come formula inline con la virgola delle migliaia (es. $100,000$):
  // in modalità matematica Typst aggiunge uno spazio dopo la virgola ("100, 000"), che qui
  // viene tolto. Vale solo per formule inline composte da sole cifre, virgole, spazi e "≈".
  show math.equation.where(block: false): it => {
    let kids = if it.body.has("children") { it.body.children } else { (it.body,) }
    let ok = kids.all(k => repr(k.func()) in ("text", "symbol", "space"))
    if ok {
      let str-body = kids.map(k => if repr(k.func()) == "space" { " " } else { k.text }).join()
      if str-body.match(regex("^[0-9,≈ ]*[0-9],[0-9]{3}[0-9,≈ ]*$")) != none {
        return math.equation(block: false, eval("\"" + str-body + "\"", mode: "math"))
      }
    }
    it
  }

  let title = if titolo != none { titolo } else { title }
  let author = if candidato != none { candidato } else if autore != none { autore } else { author }
  let department = if dipartimento != none { dipartimento } else { department }
  let degree = if tipo-laurea != none { tipo-laurea } else if corso-di-laurea != none { corso-di-laurea } else { degree }
  let supervisors = if relatori != none { relatori } else { supervisors }
  let academic-year = if anno-accademico != none { anno-accademico } else { academic-year }


  // Impostazioni della pagina base
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 3cm, left: 3cm, right: 3cm),
    header-ascent: 1.5em,
    header: context {
      let page-num = here().page()
      let supp = suppress-header-pages.final()
      
      // La testatina inizia solo con il primo capitolo numerato: nessuna testatina
      // su indice, elenco figure, ringraziamenti (e frontespizio, che ha la sua pagina)
      let chapters = query(heading.where(level: 1)).filter(h => h.numbering != none)
      if chapters.len() == 0 or page-num < chapters.first().location().page() {
        return none
      }

      // Nessuna testatina sulle pagine d'inizio capitolo
      if page-num in supp {
        return none
      }

      // Trova la sezione di livello 2 attiva su questa pagina o prima
      let headings-before = query(
        heading.where(level: 1).or(heading.where(level: 2)).before(here())
      )
      let header-content = if headings-before.len() > 0 {
        let h = headings-before.last()
        let h-loc = h.location()
        let ch-num = counter(heading).at(h-loc).at(0, default: 1)
        let sec-num = counter(heading).at(h-loc).at(1, default: 1)
        let prefix = if h.numbering != none {
          if in-appendix.at(h-loc) {
            numbering("A", ch-num) + "." + str(sec-num) + ". "
          } else {
            str(ch-num) + "." + str(sec-num) + ". "
          }
        } else {
          ""
        }
        upper[#prefix #h.body]
      } else {
        let ch-before = query(heading.where(level: 1).before(here()))
        if ch-before.len() > 0 {
          upper(ch-before.last().body)
        } else {
          []
        }
      }

      if not in-appendix.get() {
        block(width: 100%)[
          #grid(
            columns: (1fr, auto),
            align: (left + bottom, right + bottom),
            text(size: 13pt, header-content),
            text(size: 13pt, weight: "bold", str(page-num)),
            
            grid.cell(
              colspan: 2,
              inset: (top: 6pt),
              line(length: 100%, stroke: 0.5pt)
            )
          )
        ]
      }
    },
    footer: none,
  )

  // Tipografia e Lingua (Computer Modern a 13pt)
  set text(
    font: "New Computer Modern",
    size: 13pt,
    lang: lang,
  )

  // Giustificazione e interlinea (indentazione stile LaTeX: nessun rientro al primo paragrafo dopo il titolo)
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: (amount: 1.5em, all: false),
  )

  // Formattazione caption figure e tabelle
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: table): set figure.caption(position: bottom)
  set figure.caption(separator: [: ])

  // Numerazione figure e tabelle per capitolo (es. Figura 1.1, Tabella 1.1)
  set figure(numbering: (..nums) => {
    let n = nums.pos()
    context {
      let ch = counter(heading).get().at(0, default: 1)
      let prefix = if in-appendix.get() { numbering("A", ch) } else { str(ch) }
      prefix + "." + str(n.at(0))
    }
  })

  // Numerazione dei titoli
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if in-appendix.get() {
      if n.len() == 1 {
        numbering("A", n.at(0))
      } else if n.len() == 2 {
        numbering("A.1", n.at(0), n.at(1))
      } else if n.len() == 3 {
        numbering("A.1.1", n.at(0), n.at(1), n.at(2))
      }
    } else {
      if n.len() == 1 {
        str(n.at(0))
      } else if n.len() == 2 {
        str(n.at(0)) + "." + str(n.at(1))
      } else if n.len() == 3 {
        str(n.at(0)) + "." + str(n.at(1)) + "." + str(n.at(2))
      }
    }
  })
  
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    context {
      let p = here().page()
      suppress-header-pages.update(pages => {
        if not (p in pages) { pages.push(p) }
        pages
      })
    }

    if it.numbering != none {
      v(3cm)
      block(width: 100%)[
        #set par(first-line-indent: 0pt)
        #context {
          let is-app = in-appendix.get()
          let num-str = counter(heading).display()
          let prefix = if text.lang == "it" {
            if is-app { "Appendice" } else { "Capitolo" }
          } else {
            if is-app { "Appendix" } else { "Chapter" }
          }
          text(size: 25pt, weight: "regular")[#prefix #num-str]
        }
        #v(8pt)
        // Stile titolo capitolo
        #text(size: 27pt, weight: "regular")[#it.body]
      ]
      v(38pt)
    } else {
      v(45pt)
      block(width: 100%)[
        #set par(first-line-indent: 0pt)
        #text(size: 25pt, weight: "medium")[#it.body]
      ]
      v(30pt)
    }
  }

  // Stile sezioni (Livello 2)
  show heading.where(level: 2): it => {
    v(22pt)
    block(width: 100%)[
      #set par(first-line-indent: 0pt)
      #if it.numbering != none {
        text(size: 16pt, weight: "bold")[#counter(heading).display()]
        h(1.2em)
        text(size: 16pt, weight: "bold")[#it.body]
      } else {
        text(size: 16pt, weight: "bold")[#it.body]
      }
    ]
    v(12pt)
  }

  // Stile sottosezioni (Livello 3)
  show heading.where(level: 3): it => {
    v(18pt)
    block(width: 100%)[
      #set par(first-line-indent: 0pt)
      #if it.numbering != none {
        text(size: 14pt, weight: "bold")[#counter(heading).display()]
        h(1em)
        text(size: 14pt, weight: "bold")[#it.body]
      } else {
        text(size: 14pt, weight: "bold")[#it.body]
      }
    ]
    v(10pt)
  }

  // Sotto-sottosezioni (Livello 4): stile run-in/bold senza numero
  show heading.where(level: 4): it => {
    v(14pt)
    block(width: 100%)[
      #set par(first-line-indent: 0pt)
      #text(size: 13pt, weight: "bold")[#it.body]
    ]
    v(8pt)
  }

  // Indice con collegamenti e formattazione LaTeX (Capitoli in grassetto)
  show outline: set heading(numbering: none)

  show outline.entry: it => {
    if it.element.func() == figure {
      // Elenco delle figure: "numero  titolo breve ....... pagina", una voce per riga
      let el = it.element
      let loc = el.location()
      let num = numbering(el.numbering, ..el.counter.at(loc))
      block(width: 100%, above: 0.9em, below: 0.9em)[
        #set par(first-line-indent: 0pt, hanging-indent: 3em, justify: false)
        #link(loc)[#box(width: 3em)[#num]#short-caption(el)#box(width: 1fr, it.fill)#it.page()]
      ]
    } else if it.level == 1 {
      v(12pt)
      text(weight: "bold", it)
    } else {
      it
    }
  }

  // Generazione automatica del frontespizio, in una pagina a sé con margini propri
  page(margin: frontespizio-margin, header: none, footer: none)[
    #frontespizio(
      title: title,
      author: author,
      department: department,
      degree: degree,
      supervisors: supervisors,
      academic-year: academic-year,
      logo: logo,
      titolo: titolo,
      autore: autore,
      candidato: candidato,
      dipartimento: dipartimento,
      tipo-laurea: tipo-laurea,
      corso-di-laurea: corso-di-laurea,
      relatori: relatori,
      anno-accademico: anno-accademico,
    )
  ]
  show heading: i-figured.reset-counters
  // Numerazione per capitolo (1.1) e, in appendice, con la lettera dell'appendice (A.1)
  show figure: it => i-figured.show-figure(it, numbering: if in-appendix.get() { "A.1" } else { "1.1" })

  // Pagina di dedica: testo allineato a destra, in corsivo, nella parte alta della pagina
  if dedication != none {
    page(header: none, footer: none)[
      #v(28%)
      #align(right)[
        #block(width: 60%)[
          #set text( style: "italic", size: 15pt)
          #set par(justify: false, first-line-indent: 0pt, leading: 0.9em)
          #set align(right)
          #dedication
        ]
      ]
    ]
  }

  // Indice generale ed elenco delle figure (opzionali, titolo secondo `lang`)
  if tableofcontents {
    outline(title: if lang == "it" [Indice] else [Table of Contents], depth: toc-depth)
  }
  if lof {
    outline(
      title: if lang == "it" [Elenco delle figure] else [List of Figures],
      target: figure.where(kind: "i-figured-image"),
    )
  }

  body
}

// Funzione helper per forzare una nuova pagina
#let openright-break() = pagebreak(weak: true)
