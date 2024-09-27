#import "tengwar_proto.typ": *


#let map-quenya = (
  th     : sule,                 Th     : sule,
  "£t"   : tinco-alt,            "£T"   : tinco-alt,
  t      : tinco,                T      : tinco,
  "£nd"  : ando-alt,             "£Nd"  : ando-alt,
  nd     : ando,                 Nd     : ando,
  "£ss"  : esse-alt,             "£Ss"  : esse-alt,
  "£s"   : silme-alt,            "£S"   : silme-alt,
  ss     : esse,                 Ss     : esse,
  s      : silme,                S      : silme,
  nt     : anto,                 Nt     : anto,
  "£ngw" : ungwe-alt,            "£Ngw" : ungwe-alt,
  nqu    : unque,                Nqu    : unque,
  ngw    : ungwe,                Ngw    : ungwe,
  nkw    : unque,                Nkw    : unque,
  ñw     : nwalme,               Ñw     : nwalme,
  "£ng"  : anga-alt,             "£Ng"  : anga-alt, 
  ng     : anga,                 Ng     : anga, 
  nc     : anca,                 Nc     : anca,
  nq     : anca,                 Nq     : anca,
  nk     : anca,                 Nk     : anca,
  "£n"   : noldo,                "£N"   : noldo,
  ñ      : noldo,                Ñ      : noldo,
  n      : numen,                N      : numen,
  rd     : arda,                 Rd     : arda,
  "£r"   : romen,                "£R"   : romen,
  r      : ore,                  R      : ore,
  "£p"   : parma-alt,            "£P"   : parma-alt,
  p      : parma,                P      : parma,
  "£mb"  : umbar-alt,            "£Mb"  : umbar-alt,
  mb     : umbar,                Mb     : umbar,
  f      : formen,               F      : formen,
  mp     : ampa,                 Mp     : ampa,
  m      : malta,                M      : malta,
  v      : vala,                 V      : vala,
  "£qu"  : quesse-alt,           "£Qu"  : quesse-alt,
  qu     : quesse,               Qu     : quesse,
  "£kw"  : quesse,               "£Kw"  : quesse,
  kw     : quesse-alt,           Kw     : quesse-alt,
  "£k"   : calma,                "£K"   : calma,
  k      : calma-alt,            K      : calma-alt,
  "£c"   : calma-alt,            "£C"   : calma-alt,
  c      : calma,                C      : calma,
  hw     : hwesta,               Hw     : hwesta,
  "£h"   : hyarmen,              "£H"   : hyarmen,
  h      : aha,                  H      : aha,
  y      : anna,                 Y      : anna,
  ld     : alda,                 Ld     : alda,
  "£l"   : lambe-alt,            "£L"   : lambe-alt,
  l      : lambe,                L      : lambe,
  w      : wilya,                W      : wilya,
  x      : calma + silme,        X      : calma + silme,
  ai     : iglide + tehta-a,     Ai     : iglide + tehta-a,
  ei     : iglide + tehta-e,     Ei     : iglide + tehta-e,
  oi     : iglide + tehta-o,     Oi     : iglide + tehta-o,
  ui     : iglide + tehta-u,     Ui     : iglide + tehta-u,
  au     : uglide + tehta-a,     Au     : uglide + tehta-a,
  eu     : uglide + tehta-e,     Eu     : uglide + tehta-e,
  iu     : uglide + tehta-i,     Iu     : uglide + tehta-i,
  ou     : uglide + tehta-o,     Ou     : uglide + tehta-o,
  a      : tehta-a,              A      : tehta-a,
  e      : tehta-e,              E      : tehta-e,
  i      : tehta-i,              I      : tehta-i,
  o      : tehta-o,              O      : tehta-o,
  u      : tehta-u,              U      : tehta-u,
  á      : carrier-j + tehta-a,  Á      : carrier-j + tehta-a,
  é      : carrier-j + tehta-e,  É      : carrier-j + tehta-e,
  í      : carrier-j + tehta-i,  Í      : carrier-j + tehta-i,
  ó      : carrier-j + tehta-o,  Ó      : carrier-j + tehta-o,
  ú      : carrier-j + tehta-u,  Ú      : carrier-j + tehta-u,
  ä      : tehta-a,              Ä      : tehta-a,
  ë      : tehta-e,              Ë      : tehta-e,
  ï      : tehta-i,              Ï      : tehta-i,
  ö      : tehta-o,              Ö      : tehta-o,
  ü      : tehta-u,              Ü      : tehta-u,
  ô      : tehta-oo,             Ô      : tehta-oo,
  ","    : comma,
  "."    : period,
  "--"   : em-dash,
  "—"    : em-dash,
  "-"    : en-dash,
  "!"    : exclamationmark,
  "("    : l-paren,
  ")"    : r-paren,
  "­"    : tilde,
  "/"    : slash,
  "«"    : "\u{ffff}«\u{fffe}",
  "»"    : "\u{ffff}»\u{fffe}",
  ":"    : "\u{fffd}",
  "?"    : questionmark,
)


#let quenya-str(txt, style: "normal") = { 
  // Set the font to Tengwar Annatar
  set text(font: tengwar-font, fallback: false)

  // Extract numbers, convert them to quenya, and shift the glyphs to avoid conflicts
  txt = txt.replace(regex("([0-9]+)"),
                    m => number-to-quenya(m.captures.first()))

  // Map symbols from the Latin alphabet to Tengwar glyphs
  txt = txt.replace(regex("(" + array-to-string-or(map-quenya.keys()) + ")"),
                    m => map-quenya.at(m.captures.first(), default: m.captures.first()))
  
  // Undo the number glyph shifts
  txt = txt.replace(regex("(" + array-to-string-or(numbers-unshift.keys()) + ")"),
                    m => numbers-unshift.at(m.captures.first()))
  
  // Replace aha by halla if followed by ore, romen, or lambe
  txt = txt.replace(regex(aha + "(" + ore + "|" + romen + "|" + lambe + "|" + lambe-alt + ")"), 
                    m => halla + m.captures.first())

  // Exchange aha and hyarmen and add two dots below anna at start of word
  txt = txt.replace(regex("(\ +)(" + aha + "|" + hyarmen + ")"), 
    m => m.captures.at(0) + if m.captures.at(1) == aha {hyarmen} else {aha})
  txt = txt.replace(regex("(\ +)" + anna), m => m.captures.first() + anna + tehta-y)
  txt = txt.replace(regex("(.)"), 
                    m => if m.captures.first() == aha { 
                      hyarmen 
                    } else if m.captures.first() == hyarmen {
                      aha
                    } else if m.captures.first() == anna {
                      anna + tehta-y
                    } else { 
                      m.captures.first() 
                    }, 
                    count: 1)

  // If anna follows a consonant, replace it by two dots under the tengwa
  txt = txt.replace(regex("(" + array-to-string-or(consonants) + ")" + "(\u{fffe}?)" + anna),
                    m => m.captures.at(0) + m.captures.at(1) + tehta-y)
  
  // If órë is followed by a voyel or by anna and a voyel, replace it with rómen, and conversely
  txt = txt.replace(regex("([" + ore + romen + "])" + "(" + array-to-string-or(voyels) + ")"),
                    m => {if m.captures.at(0) == ore { romen } else { ore }} + m.captures.at(1))
  txt = txt.replace(regex("([" + ore + romen + "])" + anna + "(" + array-to-string-or(voyels) + ")"),
                    m => {if m.captures.at(0) == ore { romen } else { ore }} + anna + m.captures.first())
   
  // Use S-hooks if possible, and move the following tehtar if needed
  txt = txt.replace(regex("(" + array-to-string-or(consonants) + ")" 
                          + "(\u{fffe}?)" + silme
                          + "([" + array-to-string-or(tehtar) + "]?)"),
    m => if s-hooks.keys().contains(m.captures.at(0)) {
      m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + s-hooks.at(m.captures.at(0))
    } else {
      m.captures.at(0) + m.captures.at(1) + sule + m.captures.at(2)
    }
  )

  // Use alternate versions of silme and esse if followed by a short voyel
  txt = txt.replace(regex(silme + "(" + array-to-string-or(tehtar) + ")"), 
                    m => silmenuquerna + m.captures.first())
  txt = txt.replace(regex(esse + "(" + array-to-string-or(tehtar) + ")"), 
                    m => essenuquerna + m.captures.first())
  txt = txt.replace(regex("\\" + silme-alt + "(" + array-to-string-or(tehtar) + ")"), 
                    m => silmenuquerna-alt + m.captures.first())
  txt = txt.replace(regex(esse-alt + "(" + array-to-string-or(tehtar) + ")"), 
                    m => essenuquerna-alt + m.captures.first())

  // If a tehta is not on a consonnant nor preceded by \u{ffff}, add a carrier (exclude theta-y)
  txt = txt.replace(regex("(.?)(\u{fffe}?)(\u{ffff}?)(" + array-to-string-or(tehtar.slice(0,-1)) + ")"),
    m => if (consonants + (carrier-i, carrier-j, tehta-y)).contains(m.captures.at(0)) {
      m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + m.captures.at(3)
    } else {
      m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + carrier-i + m.captures.at(3)
    })

  // Fix the tilde width
  txt = txt.replace(regex("(" + array-to-string-or(consonants) + ")([" + array-to-string-or(voyels) + "]?)" + tilde),
    m =>  m.captures.at(0) + m.captures.at(1) + overtilde.at(letter-shapes.at(m.captures.at(0))))

  // Adjust the positions of tehtars
  txt = txt.replace(
    regex("(" + array-to-string-or(consonants) 
           + ")(\u{fffe}?)"
           + "(\u{ffff}?)("
           + tehta-y + "?)("
           + array-to-string-or(voyels) + ")"),
    m => {
      let shifted-a = voyels-shifted.at(
        m.captures.at(3) + letter-shapes.at(m.captures.at(0)),
        default: m.captures.at(3)) 
      let shifted-b = voyels-shifted.at(
        m.captures.at(4) + letter-shapes.at(m.captures.at(0)),
        default: m.captures.at(4))
      m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + if (letter-shapes.keys().contains(m.captures.at(0))) {
        if style == "italic" {
          voyels-shifted-it.at(
            m.captures.at(3) + letter-shapes.at(m.captures.at(0)),
            default: shifted-a) + voyels-shifted-it.at(
            m.captures.at(4) + letter-shapes.at(m.captures.at(0)),
            default: shifted-b)
        } else {
          shifted-a + shifted-b
        }
      } else {
        m.captures.at(3) + m.captures.at(4)
      }
    })

  // Combine repeated consonants
  txt = txt.replace(regex("(" + array-to-string-or(consonants) + ")(" + array-to-string-or(consonants) + ")"),
    m => if (m.captures.at(0) == m.captures.at(1)) {
      m.captures.first() + undertilde.at(letter-shapes.at(m.captures.at(0)))
    } else {
      m.captures.at(0) + m.captures.at(1)
    })

  // Use alt font for text between \u{ffff} and \u{fffe}
  let re-alt-font = regex("\u{ffff}(.?)\u{fffe}")
  show re-alt-font : it => {
    let m = it.text.match(re-alt-font).captures.first()
    text(font: tengwar-font-alt, fallback: false, m)
  }

  // Remove \u{fffd}
  show "\u{fffd}": ""
  
  txt
}

#let quenya(it, style: "normal") = { 
  
  // Adjust the spacing between some letters in italic mode
  let re-esse-adjust = regex(esse + "(" + array-to-string-or(consonants) + ")")
  show re-esse-adjust: it => {
    let m = it.text.match(re-esse-adjust).captures.first()
    if (text.style == "italic") and ("n", "m", "o").contains(letter-shapes.at(m)) {
      esse + h(-0.15em) + m
    } else {
      esse + m
    }
  }

  if it.has("text") {
    text(quenya-str(it.text, style: style), style: style)
  } else if it.has("body") {
    if (repr(it.func()) == "emph") {
      set text(style: "italic")
      quenya(it.body, style: "italic")
    } else {
      it.func()(quenya(it.body, style: style))
    }
  } else if it.has("children") {
    it.children.map(it => quenya(it, style: style)).join()
  } else if it.has("child") {
    quenya(it.child, style: style)
  } else {
    it
  }
}
