// Implementation of the Mode of Gondor

#import "tengwar_proto.typ": *

#let map-gondor = (
  th     : sule,                   Th     : sule,
  ph     : formen,                 Ph     : formen,
  kh     : hwesta,                 Kh     : hwesta,
  ch     : hwesta,                 Ch     : hwesta,
  dh     : anto,                   Dh     : anto,
  ng     : nwalme,                 Ng     : nwalme,
  gh     : unque,                  Gh     : unque,
  rh     : arda,                   Rh     : arda,
  lh     : alda,                   Lh     : alda,
  ss     : esse,                   Ss     : esse,
  hw     : hwesta-s,               Hw     : hwesta-s,
  mh     : malta-s,                Mh     : malta-s,
  t      : tinco,                  T      : tinco,
  p      : parma,                  P      : parma,
  c      : quesse,                 C      : quesse,
  q      : quesse,                 Q      : quesse,
  d      : ando,                   D      : ando,
  b      : umbar,                  B      : umbar,
  g      : ungwe,                  G      : ungwe,
  f      : formen,                 F      : formen,
  v      : ampa,                   V      : ampa,
  n      : numen,                  N      : numen,
  m      : malta,                  M      : malta,
  r      : ore,                    R      : ore,
  l      : lambe,                  L      : lambe,
  s      : silme,                  S      : silme,
  h      : hyarmen,                H      : hyarmen,
  w      : wilya,                  W      : wilya,
  ai     : tehta-a + anna,         Ai     : tehta-a + anna,
  ei     : tehta-e + anna,         Ei     : tehta-e + anna,
  ui     : tehta-u + anna,         Ui     : tehta-u + anna,
  ae     : tehta-a + iglide,       Ae     : tehta-a + iglide,
  oe     : tehta-o + iglide,       Oe     : tehta-o + iglide,
  au     : tehta-a + uglide,       Au     : tehta-a + uglide,
  aw     : tehta-a + uglide,       Aw     : tehta-a + uglide,
  a      : tehta-a,                A      : tehta-a, 
  e      : tehta-e,                E      : tehta-e, 
  i      : tehta-i,                I      : iglide, 
  o      : tehta-o,                O      : tehta-o, 
  u      : tehta-u,                U      : tehta-u, 
  y      : tehta-y-up,             Y      : tehta-y-up, 
  á      : tehta-a + carrier-j,    Á      : tehta-a + carrier-j,
  é      : tehta-e + carrier-j,    É      : tehta-e + carrier-j,
  í      : tehta-i + carrier-j,    Í      : tehta-i + carrier-j,
  ó      : tehta-o + carrier-j,    Ó      : tehta-o + carrier-j,
  ú      : tehta-u + carrier-j,    Ú      : tehta-u + carrier-j,
  ý      : tehta-y-up + carrier-j, Ý      : tehta-y-up + carrier-j,
  ä      : tehta-a,                Ä      : tehta-a,
  ë      : tehta-e,                Ë      : tehta-e,
  ï      : tehta-i,                Ï      : tehta-i,
  ö      : tehta-o,                Ö      : tehta-o,
  ü      : tehta-u,                Ü      : tehta-u,
  â      : tehta-a + carrier-j, 
  ê      : tehta-e + carrier-j, 
  î      : tehta-i + carrier-j, 
  ô      : tehta-o + carrier-j, 
  û      : tehta-u + carrier-j, 
  ŷ      : tehta-y-up + carrier-j, 
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
  "<"    : "\u{ffff}«\u{fffe}",
  "«"    : "\u{ffff}«\u{fffe}",
  ">"    : "\u{ffff}»\u{fffe}",
  "»"    : "\u{ffff}»\u{fffe}",
  ";"    : " " + comma,
  ":"    : " " + comma,
  "|"    : "\u{fffd}",
  "?"    : questionmark,
)


#let gondor-str(txt, style: "normal") = { 
  // Set the font to Tengwar Annatar
  set text(font: tengwar-font, fallback: false)

  // Extract numbers, convert them to quenya, and shift the glyphs to avoid conflicts
  // (Numbers are written similarly in the Quenya Mode and in the MOde of Gondor.)
  txt = txt.replace(regex("([0-9]+)"),
                    m => number-to-quenya(m.captures.first()))

  // Map symbols from the Latin alphabet to Tengwar glyphs
  txt = txt.replace(regex("(" + array-to-string-or(map-gondor.keys()) + ")"),
                    m => map-gondor.at(m.captures.first(), default: m.captures.first()))
  
  // Undo the number glyph shifts
  txt = txt.replace(regex("(" + array-to-string-or(numbers-unshift.keys()) + ")"),
                    m => numbers-unshift.at(m.captures.first()))
  
  // // Use S-hooks if possible, and move the following tehtar if needed
  // txt = txt.replace(regex("(" + array-to-string-or(consonants) + ")" 
  //                         + "(\u{fffe}?)" + silme
  //                         + "([" + array-to-string-or(tehtar) + "]?)"),
  //   m => if s-hooks.keys().contains(m.captures.at(0)) {
  //     m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + s-hooks.at(m.captures.at(0))
  //   } else {
  //     m.captures.at(0) + m.captures.at(1) + sule + m.captures.at(2)
  //   }
  // )
 
  // It nwalme is neither initial nor final, replace it by numen + ungwe
  txt = txt.replace(regex(
    "(" + array-to-string-or(all-letters) + ")" 
    + nwalme
    + "(" + array-to-string-or(all-letters) + ")"),
      m => m.captures.at(0) + numen + ungwe + m.captures.at(1)
    )

  // If numen or malta precedes a consonant, replace it by an overbar
  txt = txt.replace(regex("([" + numen  + "|"+ malta + "])(" + array-to-string-or(consonants) + ")"),
                    m => m.captures.at(1) + overbar.at(letter-shapes.at(m.captures.at(1))))

  // Combine repeated consonants
  txt = txt.replace(regex("(" + array-to-string-or(consonants) + ")(" + array-to-string-or(consonants) + ")"),
    m => if (m.captures.at(0) == m.captures.at(1)) {
      m.captures.first() + undertilde.at(letter-shapes.at(m.captures.at(0)))
    } else {
      m.captures.at(0) + m.captures.at(1)
    })
  
  // If a tehta is followed by a consonant, exchange them, else add a carrier
  txt = txt.replace(regex("(" + array-to-string-or(tehtar.slice(0,-1)) + ")(\u{fffe}?)(\u{ffff}?)(" 
    + array-to-string-or((carrier-i, carrier-j) + consonants) + "?)"),
    m => if (m.captures.at(3) != "") {
      m.captures.at(1) + m.captures.at(2) + m.captures.at(3) + m.captures.at(0)
    } else {
      carrier-i + m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + m.captures.at(3)
    })

  // If a tehta is still not on a consonnant nor preceded by \u{ffff}, add a carrier (exclude theta-y)
  txt = txt.replace(regex("(.?)(\u{fffe}?)(\u{ffff}?)(" + array-to-string-or(tehtar.slice(0,-1)) + ")"),
    m => if (consonants + (carrier-i, carrier-j, tehta-y)).contains(m.captures.at(0)) {
      m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + m.captures.at(3)
    } else {
      m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + carrier-i + m.captures.at(3)
    })

  // Use alternate versions of silme and esse if followed by a short vowel
  txt = txt.replace(regex(silme + "(" + array-to-string-or(tehtar) + ")"), 
                    m => silmenuquerna + m.captures.first())
  txt = txt.replace(regex(esse + "(" + array-to-string-or(tehtar) + ")"), 
                    m => essenuquerna + m.captures.first())
  txt = txt.replace(regex("\\" + silme-alt + "(" + array-to-string-or(tehtar) + ")"), 
                    m => silmenuquerna-alt + m.captures.first())
  txt = txt.replace(regex(esse-alt + "(" + array-to-string-or(tehtar) + ")"), 
                    m => essenuquerna-alt + m.captures.first())
  
  // If órë not final, replace it by rómen
  txt = txt.replace(regex(ore + "(" + array-to-string-or(vowels + ("\u{fffd}",)) + "*)" + "(" + array-to-string-or((carrier-i, carrier-j) + consonants) + ")"),
                    m => romen + m.captures.at(0) + m.captures.at(1))
  
  // A final formen is replaced by ampa
  txt = txt.replace(regex(formen + "(" + array-to-string-or(vowels) + "*)" + "(" + array-to-string-or((carrier-i, carrier-j) + consonants) + "?)"),
                    m => if (m.captures.at(1) == "") { ampa + m.captures.at(0)} else { formen + m.captures.at(0) + m.captures.at(1) })

  // If wilya directly follows a consonant, replace it with an overbar
  txt = txt.replace(regex("(" + array-to-string-or(consonants) + ")(" + array-to-string-or(vowels) + "?)" + wilya),
                    m => m.captures.at(0) + tehta-w + m.captures.at(1))

  // Fix the tilde width
  txt = txt.replace(regex("(" + array-to-string-or(consonants) + ")([" + array-to-string-or(vowels) + "]?)" + tilde),
    m =>  m.captures.at(0) + m.captures.at(1) + overtilde.at(letter-shapes.at(m.captures.at(0))))

  // Adjust the positions of tehtars
  txt = txt.replace(
    regex("(" + array-to-string-or(consonants) 
           + ")(\u{fffe}?)"
           + "(\u{ffff}?)("
           + tehta-y + "?)("
           + tehta-w + "?)("
           + array-to-string-or(vowels) + ")"),
    m => {
      let shifted-a = vowels-shifted.at(
        m.captures.at(3) + letter-shapes.at(m.captures.at(0)),
        default: m.captures.at(3)) 
      let shifted-b = vowels-shifted.at(
        m.captures.at(4) + letter-shapes.at(m.captures.at(0)),
        default: m.captures.at(4))
      let shifted-c = vowels-shifted.at(
        m.captures.at(5) + letter-shapes.at(m.captures.at(0)),
        default: m.captures.at(5))
      m.captures.at(0) + m.captures.at(1) + m.captures.at(2) + if (letter-shapes.keys().contains(m.captures.at(0))) {
        if style == "italic" {
          vowels-shifted-it.at(
            m.captures.at(3) + letter-shapes.at(m.captures.at(0)),
            default: shifted-a) + vowels-shifted-it.at(
            m.captures.at(4) + letter-shapes.at(m.captures.at(0)),
            default: shifted-b) + vowels-shifted-it.at(
            m.captures.at(5) + letter-shapes.at(m.captures.at(0)),
            default: shifted-c)
        } else {
          shifted-a + shifted-b + shifted-c
        }
      } else {
        m.captures.at(3) + m.captures.at(4) + m.captures.at(5)
      }
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

#let gondor(it, style: "normal") = { 

  show re-esse-adjust: adjust-esse
  show re-lambe-silmenuquerna-adjust: adjust-lambe-silmenuquerna
  show re-tehtar-adjust: adjust-tehtar
  show re-digits-adjust: adjust-digits

  if it.has("text") {
    text(gondor-str(it.text, style: style), style: style)
  } else if it.has("body") {
    if (repr(it.func()) == "emph") {
      set text(style: "italic")
      gondor(it.body, style: "italic")
    } else {
      it.func()(gondor(it.body, style: style))
    }
  } else if it.has("children") {
    it.children.map(it => gondor(it, style: style)).join()
  } else if it.has("child") {
    gondor(it.child, style: style)
  } else {
    it
  }
}
