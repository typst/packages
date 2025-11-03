/*
==========================================
1. Importy a pomocné funkce
2. Hlavní funkce `Template`
3. Pomocné funkce (styly, bibliografie)
4. Hlavní funkce `settings`
5. Funkce `Annex` pro přílohy
==========================================
*/

/* ==========================================
 * 1. Importy
 * ========================================== */
#import "genitiv.typ": *
#import "@preview/ez-today:1.1.0"
#import "@preview/vlna:0.1.1": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *


/* ==========================================
 * 2. Pomocné funkce (snake_case)
 * ========================================== */

// Definice barev dle fakulty – vrací barvu podle zkratky fakulty
#let get_faculty_color(faculty) = {
  if faculty == "fvl" { rgb("#808205") } else if faculty == "fvt" {
    rgb("#6188cd")
  } else if faculty == "vlf" { rgb("#ea0738") } else if faculty == "uo" {
    rgb("#fec820")
  } else { rgb("#000000") }
}

// Definice názvu fakulty – podle zkratky a varianty (1: nominativ, 2: genitiv)
#let get_faculty_name(faculty, variant: 1) = {
  context if variant == 1 {
    if faculty == "fvl" {
      if text.lang != "en" { [Fakulta vojenského leadershipu] } else {
        [Faculty of Military Leadership]
      }
    } else if faculty == "fvt" {
      if text.lang != "en" { [Fakulta vojenských technologií] } else {
        [Faculty of Military Technology]
      }
    } else if faculty == "vlf" {
      if text.lang != "en" { [Vojenská lékařská fakulta] } else {
        [Military Faculty of Medicine]
      }
    } else if faculty == "uo" { [] } else { "" }
  } else {
    if faculty == "fvl" {
      if text.lang != "en" { [Fakulty vojenského leadershipu] } else {
        [Faculty of Military Leadership]
      }
    } else if faculty == "fvt" {
      if text.lang != "en" { [Fakulty vojenských technologií] } else {
        [Faculty of Military Technology]
      }
    } else if faculty == "vlf" {
      if text.lang != "en" { [Vojenské lékařské fakulty] } else {
        [Military Faculty of Medicine]
      }
    } else if faculty == "uo" { [] } else {
      if text.lang != "en" {
        panic("Nepodporovaná fakulta! Zvolte: `fvl` | `fvt` | `vlf` | `uo`")
      } else {
        panic("Unsupported faculty! Try: `fvl` | `fvt` | `vlf` | `uo`")
      }
    }
  }
}


// Definice města fakulty – vrací název města podle fakulty a varianty (nominativ/6. pád)
#let get_city_name(faculty, variant: 1) = {
  if variant == 1 {
    if (faculty == "fvl") or (faculty == "fvt") or (faculty == "uo") {
      [BRNO]
    } else if faculty == "vlf" {
      [HRADEC KRÁLOVÉ]
    } else {
      if text.lang != "en" {
        panic("Nepodporovaná fakulta! Zvolte: `fvl` | `fvt` | `vlf` | `uo`")
      } else {
        panic("Unsupported faculty! Try: `fvl` | `fvt` | `vlf` | `uo`")
      }
    }
  } else {
    if (faculty == "fvl") or (faculty == "fvt") or (faculty == "uo") {
      [Brně]
    } else if faculty == "vlf" {
      [Hradci Králové]
    } else {
      if text.lang != "en" {
        panic("Nepodporovaná fakulta! Zvolte: `fvl` | `fvt` | `vlf` | `uo`")
      } else {
        panic("Unsupported faculty! Try: `fvl` | `fvt` | `vlf` | `uo`")
      }
    }
  }
}


// Definice cesty k logu fakulty – vrací cestu k souboru loga ve formátu SVG
#let get_logo_path(faculty) = {
  "../resources/logo" + upper(faculty) + ".svg"
}

// Definice typu závěrečné práce – název podle kódu (bc, ing, phd, teze) a varianty
#let get_thesis_type_name(thesis_type, variant: 1) = {
  context if variant == 1 {
    if thesis_type == "bc" {
      if text.lang != "en" { [Bakalářská práce] } else { [Bachelor Thesis] }
    } else if thesis_type == "ing" {
      if text.lang != "en" { [Diplomová práce] } else { [Master Thesis] }
    } else if thesis_type == "phd" {
      if text.lang != "en" { [Disertační práce] } else { [Dissertation] }
    } else if thesis_type == "teze" {
      if text.lang != "en" { [Teze disertační práce] } else {
        [Dissertation Proposal]
      }
    } else {
      if text.lang != "en" {
        panic("Nepodporovaný typ práce! Zvolte: `bc` | `ing` | `phd` | `teze`")
      } else {
        panic("Unsupported type of work! Try: `bc` | `ing` | `phd` | `teze`")
      }
    }
  } else if variant == 2 {
    if thesis_type == "bc" {
      if text.lang != "en" { [bakalářské práce] } else { [bachelor thesis] }
    } else if thesis_type == "ing" {
      if text.lang != "en" { [diplomové práce] } else { [master thesis] }
    } else if thesis_type == "phd" {
      if text.lang != "en" { [disertační práce] } else { [dissertation] }
    } else if thesis_type == "teze" {
      if text.lang != "en" { [tezi disertační práce] } else {
        [dissertation proposal]
      }
    } else {
      if text.lang != "en" {
        panic("Nepodporovaný typ práce! Zvolte: `bc` | `ing` | `phd` | `teze`")
      } else {
        panic("Unsupported type of work! Try: `bc` | `ing` | `phd` | `teze`")
      }
    }
  } else if variant == 3 {
    if thesis_type == "bc" {
      if text.lang != "en" { [bakalářskou práci] } else { [bachelor thesis] }
    } else if thesis_type == "ing" {
      if text.lang != "en" { [diplomovou práci] } else { [master thesis] }
    } else if thesis_type == "phd" {
      if text.lang != "en" { [disertační práci] } else { [dissertation] }
    } else if thesis_type == "teze" {
      if text.lang != "en" { [tezi disertační práce] } else {
        [dissertation proposal]
      }
    } else {
      if text.lang != "en" {
        panic("Nepodporovaný typ práce! Zvolte: `bc` | `ing` | `phd` | `teze`")
      } else {
        panic("Unsupported type of work! Try: `bc` | `ing` | `phd` | `teze`")
      }
    }
  } else {
    if text.lang != "en" {
      panic("Nepodporovaný typ práce! Zvolte: `bc` | `ing` | `phd` | `teze`")
    } else {
      panic("Unsupported type of work! Try: `bc` | `ing` | `phd` | `teze`")
    }
  }
}

// Formátování jména osoby – vrací řetězec se jménem, příjmením, tituly
#let format_name(person) = [
  #person.prefix
  #person.name
  #if person.suffix != none {
    [#person.surname, #person.suffix]
  } else {
    [#person.surname]
  }
]

// Formátování jména vedoucího práce pro čestné prohlášení
// - využívá externí python skript `genitiv_supervisor` pro skloňování do 2. pádu
// - vrací prefix, jméno a příjmení ve správném pádě, případně i suffix
#let format_supervisor_for_declaration(supervisor) = [
  #supervisor.prefix
  #py.call(genitiv_supervisor, "genitiv", supervisor.name)
  #py.call(genitiv_supervisor, "genitiv", supervisor.surname),
  #if supervisor.suffix != none {
    [#supervisor.suffix,]
  } else {
    []
  }
]


// Generování seznamu zkratek (akronymů)
// - vstup: slovník {"ISO": ("International Organization...", "Mezinárodní organizace...")}
// - výstup: tabulka se sloupci [akronym | vysvětlení]
// - podporuje 1 i více významů pro jednu zkratku
#let generate_acronyms_list(acronyms_dict) = {
  if acronyms_dict != none and acronyms_dict.len() > 0 {
    grid(
      columns: (auto, 1fr),
      inset: 3mm,
      ..acronyms_dict
        .pairs()
        .sorted(key: ((short, _)) => short.normalize(form: "nfd"))
        .map(((short, long)) => {
          let cell_content = []
          if type(long) == array {
            if long.len() > 1 {
              cell_content = [#long.at(0) #linebreak() #long.at(1)]
            } else if long.len() == 1 {
              cell_content = [#long.at(0)]
            }
          } else if type(long) == str {
            cell_content = [#long]
          }

          ([#strong(short)], cell_content)
        })
        .flatten()
    )
  }
}


// Vložení bibliografie do práce
// - volba typu zdroje: `yml` nebo `bib`
// - volba citačního stylu: `numeric` nebo `harvard`
// - kontroluje správnost vstupních hodnot (vyhazuje panic při chybě)
// - vrací naformátovanou bibliografii dle CSL
#let get_bibliography(type: "bib", style: "numeric") = {
  // vyber správný soubor se zdroji
  let get_file_path = if type == "yml" {
    "../template/references.yml"
  } else if type == "bib" {
    "../template/references.bib"
  } else {
    if text.lang != "en" {
      panic("Nepodporovaný typ souboru! Zvolte: `yml` | `bib`")
    } else {
      panic("Unsupported file type! Try: `yml` | `bib`")
    }
  }

  context {
    // vyber citační styl podle jazyka a parametru
    let citation_style = if text.lang != "en" {
      if style == "numeric" {
        "./csl/numeric.csl"
      } else if style == "harvard" {
        "./csl/harvard.csl"
      } else {
        none
      }
    } else {
      if style == "numeric" {
        "iso-690-numeric"
      } else if style == "harvard" {
        "iso-690-author-date"
      } else {
        none
      }
    }

    context bibliography(
      title: {
        if text.lang != "en" {
          [SEZNAM POUŽITÝCH ZDROJŮ]
        } else {
          [BIBLIOGRAPHY]
        }
      },
      style: citation_style,
      get_file_path,
    )
  }
}




/* ==========================================
 * 3. Hlavní funkce Template
 * ========================================== */

// Text následující za třemi lomítky (///) slouží pro automatickou tvorbu dokumentace.

/// Hlavní vstupní funkce šablony pro sazbu akademické práce. Nastaví globální typografii, stránkování, titulní stranu, volitelné oddíly (zadání, poděkování, abstrakty, čestné prohlášení) a vygeneruje obsah a seznamy (zkratek, obrázků, tabulek, rovnic, výpisů).
///
/// *Příklad použití:*
///  #block(width: 100%, breakable: true, stroke: 1pt, inset: 2pt,
/// ```typ
/// #set text(lang: "cs")
/// #show: template(
///   university: (
///     faculty: "fvl",
///     programme: "Řízení a použití ozbrojených sil",
///     specialisation: "Management informačních zdrojů",
///   ),
///   thesis: (
///     type: "ing",
///     title: "Eliminace závislosti na aplikacích společnosti Microsoft v ozbrojených silách",
///   ),
///   author: (
///     prefix: "rtm.",
///     name: "Jan",
///     surname: "Novák",
///     suffix: none,
///     sex: "M",
///   ),
///   supervisor: (
///     prefix: "pplk. Ing.",
///     name: "Jana",
///     surname: "Nováková",
///     suffix: "Ph.D.",
///     sex: "F",
///   ),
///   first_advisor: (
///     prefix: "Mgr.",
///     name: "Jan",
///     surname: "Novák",
///     suffix: none,
///     sex: "M",
///   ),
///   second_advisor: (
///     prefix: "",
///     name: "",
///     surname: "",
///     suffix: none,
///     sex: none,
///   ),
///   assignment: (
///     front: true,
///     back: true,
///   ),
///   acknowledgement: [Chci poděkovat...],
///   abstract: (
///     czech: [V práci...],
///     english: [In this thesis...],
///   ),
///   keywords: (
///     czech: "Alfa, Bravo, ...",
///     english: "Alpha, Bravo, ...",
///   ),
///   declaration: (
///     declaration: true,
///     ai_used: true,
///   ),
///   acronyms: (
///     "ISO": ("International Organization for Standardization", "Mezinárodní organizace pro standardizaci"),
///     "AČR": ("Armáda České republiky"),
///   ),
///   outlines: (
///     headings: true,
///     acronyms: true,
///     figures: true,
///     tables: true,
///     equations: true,
///     listings: true,
///   ),
///   introduction: [V současné vědecké komunitě se řeší...],
///   guide: true,
///   docs: false,
/// )
/// ```)
/// *Funkcionality:*
/// - Globální nastavení sazby, stránek a písem.
/// - Titulní strana s logem fakulty/univerzity a metadaty.
/// - Volitelné vložení zadání práce (obrázky PNG přes celou stranu).
/// - Oddíl poděkování (nepovinný).
/// - Abstrakty v češtině a angličtině + klíčová slova.
/// - Čestné prohlášení s volbou deklarace použití AI.
/// - Automatický obsah a seznamy (zkratky, obrázky, tabulky, rovnice, výpisy).
/// - Číslování rovnic a figur s prefixem kapitoly.
/// - Režim tisku s korektním stránkováním.
///
#let template(
  university: (
    ///   /// Význam:
    /// `faculty` — fakulta\
    /// Podporované možnosti:
    /// - `"fvl"` – Fakulta vojenského leadershipu / Faculty of Military Leadership
    /// - `"fvt"` – Fakulta vojenských technologií / Faculty of Military Technology
    /// - `"vlf"` – Vojenská lékařská fakulta / Military Faculty of Medicine
    /// - `"uo"`  – Univerzita obrany (bez uvedení konkrétní fakulty)
    faculty: "uo",
    /// `programme` – název studijního programu.\
    /// Podporované možnosti:
    /// - Vlastní text
    programme: "",
    /// `specialisation` – název studijní specializace.\
    /// Podporované možnosti:
    /// - Vlastní text
    specialisation: "",
    /// -> str
  ),
  thesis: (
    type: "",
    /// Význam:\
    /// `type` – druh práce
    /// - `"bc"` – Bakalářská práce / Bachelor Thesis
    /// - `"ing"` – Diplomová práce / Master Thesis
    /// - `"phd"` – Disertační práce / Dissertation
    /// - `"teze"` – Teze disertační práce / Dissertation Proposal
    /// `title` – název práce
    /// - Vlastní text
    title: "",
    /// -> str
  ),
  /// Informace o osobě.\
  ///  Význam:
  /// - `prefix` – hodnost a/nebo titul
  /// - `name` – křestní jméno
  /// - `surname` – příjmení
  /// - `suffix` – titul za jménem
  /// - `sex` – pohlaví ovlivňující skloňování v textu (`M`  – Male nebo `F` – Female)
  /// Stejný postup a logika platí i pro `supervisor`, `first_advisor`, `second_advisor`.
  author: (
    prefix: "",
    name: "",
    surname: "",
    suffix: "",
    sex: "",
    /// -> str | none
  ),
  supervisor: (
    /// Viz `author`.\
    prefix: "",
    name: "",
    surname: "",
    suffix: "",
    sex: "",
    /// -> str | none
  ),
  first_advisor: (
    /// Viz `author`.\
    prefix: "",
    name: "",
    surname: "",
    suffix: "",
    sex: "",
    /// -> str | none
  ),
  second_advisor: (
    /// Viz `author`.\
    prefix: "",
    name: "",
    surname: "",
    suffix: "",
    sex: "",
    /// -> str | none
  ),
  /// Nastavení čestného prohlášení.\
  // Podporované možnosti:
  /// - `true` – pravda/ano
  /// - `false`– nepravda/ne
  /// Význam:\
  /// - `declaration` — čestné prohlášení.
  /// - `ai_used` — použití nástrojů AI.
  declaration: (
    declaration: true,
    ai_used: false,
    /// -> bool
  ),
  /// Vložení naskenovaného zadání práce (PNG).\
  // Podporované možnosti:
  /// - `true` – pravda/ano
  /// - `false`– nepravda/ne
  /// Při `true` se očekává `/front.png` a `/back.png` v pracovní složce projektu.\
  /// Obrázky jsou osazeny na stránku s negativním insetem (2.5cm) pro přesah.\
  /// Význam:
  /// - `front` – přední strana
  /// - `back` – zadní strana
  ///->  bool
  assignment: (
    front: true,
    back: true,
  ),
  /// Poděkování (nepovinné).\
  /// Podporované možnosti:
  /// - `[...]` — Vlastní obsah poděkování\
  /// - `false` — oddíl se nevloží
  ///-> content | bool | none
  acknowledgement: false,
  outlines: (
    /// Řízení generování obsahu a seznamů. Každá položka je `bool`.
    // Podporované možnosti:
    /// - `true` – pravda/ano
    /// - `false`– nepravda/ne
    /// Význam:
    /// - `headings` — obsah
    /// - `acronyms` — seznam zkratek
    /// - `figures` — seznam obrázků
    /// - `tables` — seznam tabulek
    /// - `equations` — seznam rovnic
    /// - `listings` — seznam výpisů kódu
    headings: true,
    acronyms: false,
    figures: false,
    tables: false,
    equations: false,
    listings: false,
    /// -> bool
  ),
  /// Slovník zkratek (akronymy).\
  /// Zápis:
  /// - cizojazyčná zkratka:\ `"ISO": ("International Organization for Standardization", "Mezinárodní organizace pro standardizaci")`\
  /// - česká zkratka:\ `"AČR": ("Armáda České republiky")`\
  /// Při `false` se seznam negeneruje.
  /// -> dictionary | bool
  acronyms: false,
  abstract: (
    /// Abstrakt práce.\
    /// Podporované možnosti:
    /// - "" – vlastní text
    /// Význam:
    /// - `czech` — český abstrakt\
    /// - `english` — anglický abstrakt\
    /// - `[...]` — obsah abstraktu\
    czech: [],
    english: [],
    /// -> content | bool
  ),
  keywords: (
    /// Klíčová slova.\
    /// Podporované možnosti:
    /// - "" – vlastní text
    /// Význam:
    /// - `czech` — česká klíčová slova
    /// - `english` — anglická klíčová slova
    czech: "",
    english: "",
    /// -> str
  ),
  /// Úvod
  /// Podporované možnosti:\
  ///   [ ] – vlastní obsah
  /// -> content
  introduction: [],
  /// Stručná příručka pro seznámení s hlavními funkcemi.
  // Podporované možnosti:
  /// - `true` – pravda/ano
  /// - `false`– nepravda/ne
  /// -> bool
  guide: true,
  /// Rozšířená příručka včetně všech parametrů, hodnot a pomůcky.
  // Podporované možnosti:
  /// - `true` – pravda/ano
  /// - `false`– nepravda/ne
  /// -> bool
  docs: false,
  body,
  ///
) = {
  // ==========================================
  // 4.1. Základní nastavení
  // ==========================================

  // Barva odkazu url modrou barvou
  show link: set text(fill: rgb("#0000FF"))

  // Kódové prostředí
  show: codly-init.with()
  codly(languages: codly-languages)
  show: apply-vlna

  //Metadata
  set document(
    author: author.prefix
      + " "
      + author.name
      + " "
      + author.surname
      + " "
      + author.suffix,
    title: thesis.title,
    date: auto,
    description: abstract.czech,
    keywords: keywords.czech,
  )

  // Těsné vertikální lepení odstavců bez sirotků/vdov.
  show par: it => {
    let threshold = 10%
    block(breakable: false, height: threshold)
    v(-threshold, weak: true)
    it
  }

  set text(
    bottom-edge: "bounds",
    size: 12pt,
    overhang: true,
    font: "TeX Gyre Termes",
    fallback: true,
    hyphenate: false,
    costs: (runt: 1000%, hyphenation: 1000%, widow: 1000%, orphan: 1000%),
  )

  show math.equation: set text(font: "TeX Gyre Termes Math", fallback: true)
  show raw: set text(font: "TeX Gyre Cursor", fallback: true)

  set page(
    margin: (inside: 35mm, outside: 25mm, y: 25mm),
    numbering: "1",
    footer: context {
      set align(center)
      counter(page).display(page.numbering)
    },
    paper: "a4",
    binding: auto,
  )

  // ==========================================
  // 3.2. Stylování podle fakulty
  // ==========================================
  let faculty-color = get_faculty_color(university.faculty)

  set par(
    first-line-indent: (amount: 7mm, all: true),
    linebreaks: "optimized",
    leading: 1.05em,
    justify: true,
  )

  set enum(indent: 1em)
  set list(indent: 1em)

  set math.equation(numbering: (..nums) => {
    let section = counter(heading).get().first()
    numbering("(1.1)", section, ..nums)
  })

  // ==========================================
  //  MANUÁL
  // ==========================================

  if docs != false { include "docs.typ" } else {}

  // ==========================================
  // 3.3. Titulní strana
  // ==========================================
  {
    show heading: none
    context heading(
      numbering: none,
      bookmarked: true,
      level: 1,
      outlined: false,
    )[
      #if text.lang != "en" { [TITULNÍ LIST] } else { [TITLE PAGE] }
    ]
  }

  {
    set par(first-line-indent: 0mm)
    set page(footer: none)
    set align(center)

    text(size: 16pt)[
      #upper(
        context if text.lang != "en" { [Univerzita obrany] } else {
          [University of Defence]
        },
      )
    ]
    linebreak()

    text(size: 14pt, weight: "bold")[
      #if university.faculty != "uo" {
        upper(get_faculty_name(university.faculty))
        linebreak()
      } else {}
    ]

    if university.programme != none {
      text(size: 14pt, weight: "bold")[
        #context if text.lang != "en" { [Studijní program: ] } else {
          [Programme: ]
        }
        #university.programme
        #linebreak()
      ]
    } else {}

    if university.specialisation != none {
      text(size: 14pt)[
        #context if text.lang != "en" { [Studijní specializace: ] } else {
          [Specialisation: ]
        }
        #university.specialisation
        #linebreak()
      ]
    } else {}

    v(1cm)
    image(get_logo_path(university.faculty), height: 8cm)
    linebreak()
    v(.5cm)

    text(size: 24pt, weight: "bold")[
      #upper(get_thesis_type_name(thesis.type))
      #linebreak()
    ]
    v(1cm)

    text(size: 16pt, weight: "bold")[
      #thesis.title
      #linebreak()
    ]
    v(1fr)

    set align(left)

    text(size: 14pt)[
      // Autor
      #context if author.sex != "F" {
        if text.lang != "en" { [Zpracoval:] } else { [Author:] }
      } else {
        if text.lang != "en" { [Zpracovala:] } else { [Author:] }
      }
      #format_name(author)
      #linebreak()

      // Vedoucí / Školitel
      #if supervisor != none {
        context if thesis.type == "bc" or thesis.type == "ing" {
          if text.lang != "en" { [Vedoucí práce:] } else { [Supervisor:] }
        } else {
          if text.lang != "en" { [Školitel:] } else { [Supervisor:] }
        }
        format_name(supervisor)
        linebreak()
      }

      // Odborný konzultant, nebo první školitel specialista
      #if first_advisor != none {
        context if thesis.type == "bc" or thesis.type == "ing" {
          if text.lang != "en" { [Odborný konzultant:] } else { [Advisor:] }
        } else {
          if text.lang != "en" { [Školitel-specialista:] } else {
            [Co-Supervisor:]
          }
        }
        format_name(first_advisor)
        linebreak()
      }

      // Druhý školitel specialista
      #if (
        second_advisor != none and thesis.type == "phd" or thesis.type == "teze"
      ) {
        context if text.lang != "en" { [Školitel-specialista:] } else {
          [Co-Supervisor:]
        }
        format_name(second_advisor)
        linebreak()
      }
    ]

    // Město a datum
    v(1fr)
    set align(center)
    text(
      size: 16pt,
      upper(get_city_name(university.faculty)) + ez-today.today(format: " Y"),
    )
  }


  // ==========================================
  // 3.4. Nastavení nadpisů
  // ==========================================
  set page(footer: none)
  set heading(numbering: "1.1.1", supplement: [heading], depth: 3)

  show heading.where(level: 1): it => {
    pagebreak()
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(math.equation).update(0)

    block(width: 100%)[
      #set text(size: 14pt, weight: "bold")
      #set par(first-line-indent: 0mm)
      #upper(it)
      #v(1em)
    ]
  }

  show heading.where(level: 2): it => block(width: 100%)[
    #set text(size: 14pt, weight: "bold")
    #v(.5em)
    #it
    #v(.5em)
  ]

  show heading.where(level: 3): it => block(width: 100%)[
    #set text(size: 13pt, weight: "bold")
    #v(.5em)
    #it
    #v(.5em)
  ]

  show heading.where(level: 4): it => block(width: 100%)[
    #set text(size: 12pt, weight: "bold")
    #v(.5em)
    #it
    #v(.5em)
  ]
  show heading.where(level: 4): set heading(numbering: none)

  // ==========================================
  // 3.5. Zadání práce
  // ==========================================
  context if assignment.front != false or assignment.back != false {
    {
      show heading: none
      heading(numbering: none, bookmarked: true, outlined: false, level: 1)[
        #if text.lang != "en" { [ZADÁNÍ PRÁCE] } else { [ASSIGNMENT] }
      ]
      pagebreak(to: "odd")
    }
  } else {}

  if assignment.front != false {
    box(image("../template/front.png", width: 100%), inset: -2.5cm)
  } else {}
  if assignment.back != false {
    box(image("../template/back.png", width: 100%), inset: -2.5cm)
  } else {}

  // ==========================================
  // 3.6. Poděkování
  // ==========================================
  context if acknowledgement != [] {
    heading(
      if text.lang != "en" { [PODĚKOVÁNÍ] } else { [ACKNOWLEDGEMENT] },
      numbering: none,
      bookmarked: true,
      level: 1,
    )
    acknowledgement
  } else {
    heading(
      if text.lang != "en" { [PODĚKOVÁNÍ] } else { [ACKNOWLEDGEMENT] },
      numbering: none,
      bookmarked: true,
      level: 1,
    )
    [Text poděkování \ Poděkování není povinnou součástí závěrečné práce. Je vhodné vyjádřit poděkování rodičům, vedoucímu závěrečné práce, konzultantům či osobám, které Vám pomohly / byly nápomocny při zpracování závěrečné práce nebo v průběhu studia.]
  }

  // ==========================================
  // 3.7. Čestné prohlášení
  // ==========================================
  context if declaration.declaration != false {
    heading(
      if text.lang != "en" { [ČESTNÉ PROHLÁŠENÍ] } else { [DECLARATION] },
      numbering: none,
      bookmarked: true,
      level: 1,
    )

    [
      Prohlašuji, že jsem zadanou #get_thesis_type_name(thesis.type, variant: 3)
      na téma #emph[#thesis.title] #lower[vypracoval] samostatně, pod odborným vedením
      #if thesis.type == "bc" or thesis.type == "ing" {
        if supervisor.sex == "M" { [vedoucího práce] } else { [vedoucí práce] }
      } else {
        if supervisor.sex == "M" { [školitele] } else { [školitelky] }
      }
      #format_supervisor_for_declaration(supervisor) a
      #context if author.sex == "M" { [použil] } else { [použila] } jsem pouze literární zdroje uvedené v práci.

      #parbreak()

      Dále prohlašuji, že při vytváření této práce jsem
      #if declaration.ai_used != false {
        context if author.sex == "M" { [použil] } else { [použila] }
        [
          nástroje umělé inteligence. Tyto nástroje byly využity v souladu s platnými obecně závaznými právními předpisy, vnitřními předpisy
          Univerzity obrany a #get_faculty_name(university.faculty, variant: 2)
          a etickými normami. Veškeré výsledky, které byly generovány nebo
          ovlivněny nástroji umělé inteligence, jsou v této práci
          identifikovány, popsány a podloženy relevantními informacemi o
          použitých algoritmech, tréninkových datech a metodologii.
        ]
      } else {
        context if author.sex == "M" { [nepoužil] } else { [nepoužila] }
        [ nástroje umělé inteligence. ]
      }

      #parbreak()

      Dále prohlašuji, že jsem
      #context if author.sex == "M" { [seznámen] } else { [seznámena] }
      s tím, že se na moji #text(lang: "cs")[#get_thesis_type_name(thesis.type, variant: 3)]
      vztahují práva
      a povinnosti vyplývající ze zákona č. 121/2000 Sb., o právu autorském,
      o právech souvisejících s právem autorským a o změně některých zákonů
      (autorský zákon), ve znění pozdějších předpisů, zejména skutečnosti,
      že Univerzita obrany má právo na uzavření licenční smlouvy o užití
      této #text(lang: "cs")[#get_thesis_type_name(thesis.type, variant: 2)]
      jako školního díla
      podle §~60~odst.~1 výše uvedeného zákona, a s tím, že pokud dojde k
      užití této #text(lang: "cs")[#get_thesis_type_name(thesis.type, variant: 2)]
      mnou nebo
      bude poskytnuta licence o užití díla třetímu subjektu, je Univerzita
      obrany oprávněna ode mne požadovat přiměřený příspěvek na úhradu
      nákladů, které na vytvoření díla vynaložila, a to podle okolností až
      do jejich skutečné výše.

      #parbreak()

      Souhlasím se zpřístupněním své
      #text(lang: "cs")[#get_thesis_type_name(thesis.type, variant: 2)]
      pro prezenční studium v prostorách knihovny Univerzity obrany.

      #v(2cm)
      #align(center, grid(
        align: (left, center),
        columns: (50%, 50%),
        rows: 2,
        [
          V #get_city_name(university.faculty, variant: 2),
          dne #lower[#ez-today.today(lang: "cs", format: "d. m. Y")]
        ],
        [#box(width: 1fr, repeat[.])],

        v(.5cm), [],
        [], [#format_name(author)],
      ))
    ]
  }


  // ==========================================
  // 3.8. Abstrakty
  // ==========================================

  // Abstrakt česky
  if abstract.czech != [] {
    heading(
      numbering: none,
      bookmarked: true,
      level: 1,
    )[ABSTRAKT]
    abstract.czech
    parbreak()
    h(-7mm) + [*Klíčová slova*: ] + keywords.czech
  } else {
    heading(
      numbering: none,
      bookmarked: true,
      level: 1,
    )[ABSTRAKT]
    [Abstrakt představuje stručnou a přesnou charakteristiku obsahu závěrečné práce, poskytuje informace o problému, způsobu řešení a dosažených výsledcích práce. Rozsah abstraktu v českém jazyce do jedné #footnote[Jako pomocník pro vypracování možné využít: ČSN ISO 214 Dokumentace – abstrakty pro publikace a dokumentaci, případně: https://www.herout.net/blog/2013/12/jak-psat-abstrakt]strany.]
    parbreak()
    (
      h(-7mm)
        + [*Klíčová slova*: ]
        + [ uvádí se 5–10 klíčových slov (= hesla, sousloví a fráze) v abecedním
          pořadí, které charakterizují obsahovou podstatu závěrečné práce]
    )
  }

  // Abstrakt anglicky
  if abstract.english != [] {
    heading(
      numbering: none,
      bookmarked: true,
      level: 1,
    )[ABSTRACT]
    abstract.english
    parbreak()
    h(-7mm) + [*Keywords*: ] + keywords.english
  } else {
    heading(
      numbering: none,
      bookmarked: true,
      level: 1,
    )[ABSTRACT]
    [Text abstraktu v anglickém jazyce.]
    parbreak()
    h(-7mm) + [*Keywords*: ]
  }


  // ==========================================
  // 3.9. Seznamy (obsah, zkratky, obrázky, …)
  // ==========================================
  set page(footer: context {
    set align(center)
    counter(page).display(page.numbering)
  })

  // Obsah vzhled
  if outlines.headings != false {
    show outline.entry.where(level: 1): it => {
      set text(size: 14pt, weight: "bold")
      upper(it)
    }
    show outline.entry.where(level: 2): it => {
      set text(size: 13pt)
      it
    }
    show outline.entry.where(level: 3): it => {
      set text(size: 12pt, style: "italic")
      it
    }

    // Obsah
    outline(
      target: heading.where(supplement: [heading]),
      indent: 1em,
      depth: 3,
      title: context if text.lang != "en" { [OBSAH] } else {
        [TABLE OF CONTENTS]
      },
    )
  }

  // Seznam zkratek
  context if outlines.acronyms != false {
    heading(
      bookmarked: true,
      outlined: true,
      numbering: none,
      level: 1,
    )[#if text.lang != "en" { [SEZNAM ZKRATEK] } else { [LIST OF ACRONYMS] }]
    generate_acronyms_list(acronyms)
  }

  // Seznam obrázků
  context if outlines.figures != false {
    heading(
      bookmarked: false,
      outlined: true,
      numbering: none,
      level: 1,
    )[#if text.lang != "en" { [SEZNAM OBRÁZKŮ] } else { [LIST OF FIGURES] }]
    outline(title: none, target: figure.where(kind: image))
  }

  // Seznam tabulek
  context if outlines.tables != false {
    heading(
      bookmarked: true,
      outlined: true,
      numbering: none,
      level: 1,
    )[#if text.lang != "en" { [SEZNAM TABULEK] } else { [LIST OF TABLES] }]
    outline(title: none, target: figure.where(kind: table))
  }

  // Seznam rovnic
  context if outlines.equations != false {
    heading(
      bookmarked: true,
      outlined: true,
      numbering: none,
      level: 1,
    )[#if text.lang != "en" { [SEZNAM ROVNIC] } else { [LIST OF EQUATIONS] }]
    outline(title: none, target: math.equation)
  }

  // Seznam výpisů
  context if outlines.listings != false {
    heading(
      bookmarked: true,
      outlined: true,
      numbering: none,
      level: 1,
    )[#if text.lang != "en" { [SEZNAM VÝPISŮ] } else { [LIST OF LISTINGS] }]
    outline(title: none, target: figure.where(kind: raw))
  }

  // ==========================================
  // 3.10. Úvod
  // ==========================================

  context if introduction != [] {
    heading(level: 1, outlined: true, numbering: none)[#if text.lang != "en" {
      [ÚVOD]
    } else { [INTRODUCTION] }]
    introduction
  } else {
    [#heading(level: 1, outlined: true, numbering: none)[#if text.lang != "en" {
        [ÚVOD]
      } else { [INTRODUCTION] }]
      Úvod vyjadřuje aktuálnost, významnost a potřebnost řešeného problému z hlediska teorie či praxe.  V úvodu se nepíše cíl práce, použité metody ani obsah práce. K tomuto účelu slouží samostatné kapitoly závěrečné práce. Doporučený rozsah úvodu je 1–2 normostrany.]
  }

  // ==========================================
  // 3.11. Nastavení obrázků a tabulek
  // ==========================================

  // Popisky figur – číslo + text, vždy s mezerou nad
  set figure.caption(separator: " ")
  show figure.caption: it => [
    #v(1em)
    #it.supplement #context it.counter.display(it.numbering)~#it.body
    #v(1em)
  ]

  // Základní styl figure
  let figure_spacing = 1em
  show figure: it => {
    let content = block(width: 100%, inset: (y: figure_spacing), align(
      center,
      it,
    ))
    if it.placement == none {
      block(it, inset: (y: figure_spacing))
    } else {
      place(it.placement, float: true, content)
    }
  }
  show figure: set block(breakable: true, spacing: 1.2em)
  show figure: align.with(center)

  // Tabulky, kódy a rovnice – popisek nahoře
  show table.cell.where(y: 0): strong
  set table(stroke: 0.7pt)
  show figure.where(kind: table): set figure.caption(
    position: top,
    separator: [],
  )
  show figure.where(kind: raw): set figure.caption(position: top, separator: [])
  show figure.where(kind: math.equation): set figure.caption(
    position: top,
    separator: [],
  )

  // Rovnice – svislé mezery před a po
  show math.equation.where(block: true): it => {
    v(.5em)
    it
    v(.5em)
  }

  // Tabulky – menší font + zarovnání
  show table: set text(size: 10pt, hyphenate: true)
  show table: set par(justify: true)
  set table.hline(stroke: .5pt)

  // Číslování figur s prefixem kapitoly
  set figure(numbering: n => numbering(
    "1.1 ",
    counter(heading).get().first(),
    n,
  ))

  if guide != false [
    #set text(fill: red)
    = –ZÁKLADNÍ NÁVOD DLE OPATŘENÍ –
    Červený text lze vypnout přepnutím z `guide: true` na `guide: false` v nastavení.
    Základní rozdělení typů textu při formátování.
    ```typ
    Text (String) – "". Jednoduchý textový řetězec bez možnosti formátování.
    Obsah (Content) – []. Blok pro vkládání formátovaného obsahu (odstavce, seznamy atd.).
    Pole (Array) – (). Seznam nebo sada více položek (např. galerie, výčet vlastností).
    Přepínač (Boolean) – true | false. Logická hodnota pro stavy ano/ne nebo zapnuto/vypnuto.
    Číslo (Int) – 1. Číselná hodnota
    ```
    Příklad vyplnění základních parametrů šablony s vysvětlením.
    ```typ
    #show: template.with( // Zobrazí šablonu (`template`) s následujícími hodnotami:
      university:( // Pole `university`, které nese informaci o typu fakulty (`faculty`), studijního programu (`programme`) a studijní specializaci (`specialisation`).
        faculty: "fvl", // Studují na Fakultě vojenského leadershipu zvolím `fvl`. Možnosti: `fvl`, `fvt`, `vlf` a `uo`.
        programme: [Řízení a použití ozbrojených sil], // Vlastními slovy níázev studijního programu.
        specialisation: [Management informačních zdrojů], // Vlastními slovy název studijního oboru.
      ),
      thesis:( // Pole závěrečné práce (`thesis`), které nese informaci o typu závěrečné práce (`type`) a  její název (`title`).
        type: "ing", // Píši diplomovou práci zvolím `ing`. Možnosti `bc`, `ing`, `phd` a `teze`.
        title: [Eliminace závislosti na aplikacích Microsoftu v ozbrojených silách], // Vlastními slovy název práce.
      ),
      author: ( // Pole s autorem (`author`). Struktura: `prefix`, `name`, `surname`, `suffix` a `sex` jsou pro osoby stejné.
        prefix: "rtm.", // Před jménem ve formátu hodnost. titul.
        name: "Jan",  // Jméno
        surname: "Novák", // Příjmení
        suffix: none,  // Titul za jménem. Pokud není píšeme `none`.
        sex: "M",  // Pohlaví. Možnosti: `M` nebo `F`.
      ),
      supervisor: ( // Vedoucí práce (`bc`, `ing`), nebo Školitel (`phd`, `teze`)
        prefix: "pplk. Ing.",
        name: "Jana",
        surname: "Nováková",
        suffix: "Ph.D.",
        sex: "F",
      ),
      first_advisor: ( //  Odborný konzultant (`bc` a `ing`), nebo První školitel-specialista (`phd`, `teze`)
        prefix: "Mgr.",
        name: "Jan",
        surname: "Novák",
        suffix: none,
      ),
      second_advisor: ( // Druhý školitel-specialista (`phd`, `teze`)
        prefix: "",
        name: "",
        surname: "",
        suffix: none,
      ),
        assignment: ( // Pole zadáná (`assignment`), které nese informaci o přítomnosti přední (`front`) a zadní (`back`) strany zadání.
        front: true, // Přední strana
        back: true, // Zadní strana
      ),
      acknowledgement: [Chci poděkovat, .....], // Vlastní obsah poděkování.
      abstract:( // Pole s abstraktem (`abstract`), které obsahuje českou (`czech`) a anglickou (`english`) variantu.
        czech: [V práci .....], // Vlastní obsah abstraktu v češtině.
        english: [In this thesis ....], // Vlastní obsah abstraktu v angličtině.
      ),
      keywords:( // Pole s  klíčovými slovy (`keywords`), které obsahuje českou (`czech`) a anglickou (`english`) variantu.
        czech: "Alfa, Bravo, ...", // Vlastní text klíčových slov v češtině.
        english: "Alfa, Brava,...", // Vlastní text klíčových slov v angličtině.
      ),
      declaration:( // Pole s Čestným prohlášením (`declaration`), které obsahuje přítomnost čestného prohlášení (`declaration`) a použití umělé inteligence (`ai_used`).
        declaration: true, // Zobrazit čestné prohlášení. Možnosti: `true`nebo `false`.
        ai_used: true, // Byla v práci použita generativní umělá inteligence? Možnosti: `true`nebo `false`.
      ),
      acronyms: ( // Pole s automaticky seřazovanými zkratkami (`acronyms`)
        "CIZÍ ZKRATKA": ("CIZÍ VARIANTA", "ČESKÁ VARIANTA"),
        "ČESKÁ ZKRATKA": ("ČESKÁ VARIANTA"),
        "ISO": ("International Organization for Standardization","Mezinárodní organizace pro standardizaci"),  // Příklad anglické zkratky
        "AČR": ("Armáda České republiky"),  // Příklad české zkratky
      ),
      outlines:( // Pole se seznamy. Možnosti: `true` nebo `false`
        headings: true,  // Obsah
        acronyms: true,  // Seznam zkratek
        figures: true,  // Seznam obrázků
        tables: true,  // Seznam tabulek
        equations: true,  // Seznam rovnic
        listings: true,  // Seznam výpisů/kódů
      ),
      introduction: [V současné vědecké komunitě se řeší ...], // Vlastní obsah úvodu
      guide: true, // Stručný návod. Možnosti. `true` nebo `false`
      docs: false, // Manuál. Možnosti: `true` nebo `false`
    )
    ```

    *1. Kapitola – TEORETICKÁ ČÁST / ANALÝZA SOUČASNÉHO
    STAVU*

    Vyberte pouze jeden nadpis.

    Úvod ke kapitole v rozsahu 3–5 řádků, který představuje náplň kapitoly. Každá kapitola začíná na nové stránce.

    Text se člení na hlavní kapitoly, podkapitoly (např. 1.1) a oddíly (např. 1.1.1), další členění se nedoporučují.

    Název kapitoly volíte pouze jeden v závislosti na obsahu práce.

    Jednotlivé oddíly kapitoly by měly být z hlediska rozsahu vyvážené (přibližně stejně dlouhé).

    Podle Pravidel českého pravopisu se nepíší neslabičné předložky v, s, z, k na konec řádku, podle typografické normy jednopísmenná slova (předložky a spojky a, i, o, u) a jakékoli jednoslabičné výrazy (např. ve, ke, ku, že, na, do, od, pod). Nepoužívejte automatické dělení slov. Spojení slov lze provést pomocí tzv. vlny #"~" (Windows: alt + 126, GNU/Linux Pravý Alt + 126, MacOS: option + 5) příklad Text a~spojený text.

    V případě používání výčtu je možné položky výčtu označovat číslicemi, písmeny abecedy, pomlčkami, odrážkami nebo jinými grafickými prvky. Bližší úpravu a zásady psaní položek výčtu naleznete na http://prirucka.ujc.cas.cz/?id=870.

    Doporučuje se, aby na tabulky a obrázky byly zařazeny poblíž jejich první citace v textu. Při citaci v textu, musí číslům tabulek nebo obrázků předcházet nebo po nich následovat slova obrázek nebo tabulka. Za obrázky je považována kresba, graf, fotografie, mapa. Tabulky a obrázky musí být čitelné.

    U každého obrázku a tabulky musí být uveden krátký horizontální a neorámovaný popisný text. Popisný text tabulky musí být napsán nad tabulkou za arabskou číslicí přidělenou tabulce. Legenda k obrázku musí být umístěna pod obrázkem. Legenda
    k obrázku musí být umístěna za arabskou číslici přidělenou obrázku. U nepůvodních obrázků a tabulek se uvádí pramen. Obrázky a tabulky se číslují odděleně a posloupně.

    ==== Praktická ukázka nejčastějších zápisů:

    ==== 1 NÁZEV KAPITOLY
    ==== 1.1 Podkapitola
    ==== 1.1.1 Oddíl
    ==== Čtvrtý řád – pokud je potřeba, nemá číslování

    ==== Zápis
    ```typst
    = NÁZEV KAPITOLY
    == Podkapitola
    === Oddíl
    ==== Čtvrtý řád – pokud je potřeba, nemá číslování
    ```
    ==== Obrázek s titulkem
    Pozn. Pokud se nevleze společně se zdrojem na jednu stranu můžeme jej odsadit s pomocí `#colbreak()` (column break).
    #figure(
      caption: [Název obrázku],
      image(
        "../thumbnail.svg",
        width: 5cm,
        height: 5cm,
      ),
    )<obr:Můj_obrázek>
    Zdroj: @fvl[Rozsah stran]

    Reference na @obr:Můj_obrázek, nebo také na @obr:Můj_obrázek[cokoliv co napišu]

    ==== Zápis

    ```typ
    #figure(
      caption: [Název obrázku], // Titulek
      image(
        "obrazek.png", // Cesta k obrázku
        width: 5cm, // Šířka
        height: 5cm,  // Výška
      ),
    )<obr:Můj_obrázek> // Vytvoření štítku k odkazování
    Zdroj: @fvl[Rozsah stran] // Zdroj
    Reference na @obr:Můj_obrázek, nebo také na @obr:Můj_obrázek[cokoliv co napišu] // Odkázání na obrázek. Provázáno přes proklik. V hranatých závorkách lze upravit název.
    ```

    ==== *Tabulka s titulkem*
    #figure(
      caption: [Název tabulky],
      table(
        columns: 3,
        rows: 3,
        table.header([Záhlaví Jedna], [Záhlaví dva], [Záhlaví tři]),
        [První buňka], [Druhá buňka], [Třetí buňka],
        [Čtvrtá buňka], [Pátá buňka], [Šestá buňka],
        table.footer([Zápatí jedna], [Zápatí dva], [Zápatí tři]),
      ),
    )<tab:Moje_tabulka>
    @tab:Moje_tabulka
    ==== Zápis
    ```typ
    #figure(
      caption: [Název tabulky], // Titulek
        table(
          columns: 3, // Počet sloupců
          rows: 3, // Počet řádků
          table.header([Záhlaví Jedna], [Záhlaví dva], [Záhlaví tři]), // Záhlaví
          [První buňka], [Druhá buňka], [Třetí buňka], // Tělo tabulky
          [Čtvrtá buňka], [Pátá buňka], [Šestá buňka],
          table.footer([Zápatí jedna], [Zápatí dva], [Zápatí tři] // Zápatí
        )
      )
    )<tab:Moje_tabulka>
    @tab:Moje_tabulka
    ```

    ==== Matematika – inline
    Text $a+b=3$ Pokračování textu

    ==== Zápis
    ```typ
    $a+b=3$
    ```
    ==== Bloková

    Text
    $
      x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a)
    $
    Pokračování textu
    ==== Zápis
    ```typ
    $
    x = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a)
    $
    ```
    ==== Kód
    #figure(
      caption: [Název kódu/výpisu],
      ```python
      print("Hello, World!")
      ```,
    )
    ==== Zápis
    ````typ
      #figure(
        caption: [Název kódu/výpisu],
      ```python
        print("Hello, World!")
      ```
      )
    ````



  ]


  // ==========================================
  // 3.12. Hlavní obsah
  // ==========================================
  body
}
/* ==========================================
 * 4. Funkce annex pro přílohy
 * ========================================== */

/// Funkce `annex` nastavuje sazbu a číslování příloh. \
///— příloha začíná na liché straně; \
///— stránky příloh se číslují ve tvaru `A–1`, `A–2`, … (písmeno dle pořadí přílohy); \
///— samostatně se resetují čítače obrázků, tabulek a rovnic; \
///— hlavní nadpis kapitoly je „PŘÍLOHA“ / „ANNEX“ a je označen písmenem.
///
/// *Příklad použití:*
/// #block(width: 100%, breakable: true,
/// ```typ
/// #show: annex
/// = Název přílohy
/// Text přílohy
/// ```)
/// Pozn.: Pokud je v projektu povolen outline pro přílohy, vygeneruje se i „Seznam příloh“ s odkazy.
#let annex(body) = {
  // Pokud se má vytvářet outline
  if outline != false {
    show outline.entry: it => [
      #upper(strong(it.indented(it.prefix(), it.body())))
    ]
    outline(
      target: heading.where(supplement: context {}),
      title: context if text.lang != "en" { [SEZNAM PŘÍLOH] } else {
        [LIST OF ANNEXES]
      },
      depth: 1,
    )
  }
  // Nadpis pro seznam příloh
  show heading: none
  context heading(numbering: none, level: 1)[
    #if text.lang != "en" { [SEZNAM PŘÍLOH] } else { [LIST OF ANNEXES] }
  ]

  // Nadpisy 1. úrovně v přílohách
  show heading.where(level: 1): set heading(
    numbering: "A",
    supplement: context {
      if text.lang != "en" { [PŘÍLOHA] } else { [ANNEX] }
    },
  )

  show heading.where(level: 1): it => [
    #set text(size: 14pt, weight: "bold")
    #set par(first-line-indent: 0mm)
    #it.supplement
    #{
      if it.numbering != none {
        numbering(it.numbering, ..counter(heading).at(it.location()))
      }
    }
    #upper(it.body)
    // reset čítačů
    #counter(figure.where(kind: table)).update(0)
    #counter(figure.where(kind: image)).update(0)
    #counter(math.equation).update(0)
    #counter(page).update(1)
  ]

  // Nová příloha vždy na nové straně + reset čítačů
  show heading.where(level: 1): it => {
    pagebreak()
    counter(page).update(1)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    it
  }

  // Číslování stránek v přílohách
  set page(
    numbering: n => numbering(
      "A–1",
      counter(heading).get().first(), // A/B/C podle přílohy
      n, // číslo stránky
    ),
    footer: context {
      set align(center)
      counter(page).display(page.numbering)
    },
  )

  // Reset hlavních čítačů
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "A")

  // Nastavení číslování a popisků obrázků, tabulek, rovnic…
  set figure(numbering: n => numbering(
    "A–1",
    counter(heading).get().first(),
    n,
  ))

  show figure.where(kind: image): set figure(
    outlined: false,
  )

  show figure.where(kind: table): set figure(
    outlined: false,
  )

  show figure.where(kind: math.equation): set figure(
    outlined: false,
  )

  show figure.where(kind: raw): set figure(
    outlined: false,
  )

  // V přílohách zakážeme číslování hlubších nadpisů
  show heading.where(level: 2): set heading(numbering: none, outlined: false)
  show heading.where(level: 3): set heading(numbering: none, outlined: false)
  show heading.where(level: 4): set heading(numbering: none, outlined: false)

  // Obsah přílohy
  body
}
