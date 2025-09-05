// assigns a Roman character to a code point representing its Greek equivalent
// anything not in this list (and not handled elsewhere) will be rendered literally
#let letterDictionary = (
  // lower-case letters
  a: 0x03B1,
  b: 0x03B2,
  g: 0x03B3,
  d: 0x03B4,
  e: 0x03B5,
  z: 0x03B6,
  h: 0x03B7,
  q: 0x03B8,
  i: 0x03B9,
  k: 0x03BA,
  l: 0x03BB,
  m: 0x03BC,
  n: 0x03BD,
  // ksi is handled in the function
  o: 0x03BF,
  p: 0x03C0,
  r: 0x03C1,
  // sigma is handled in the function
  t: 0x03C4,
  u: 0x03C5,
  f: 0x03C6,
  x: 0x03C7,
  // psi is handled in the function
  w: 0x03C9,
  // upper-case letters.  Could do this programatically, but that'd actually be more work
  A: 0x0391,
  B: 0x0392,
  G: 0x0393,
  D: 0x0394,
  E: 0x0395,
  Z: 0x0396,
  H: 0x0397,
  Q: 0x0398,
  I: 0x0399,
  K: 0x039A,
  L: 0x039B,
  M: 0x039C,
  N: 0x039D,
  // ksi is handled in the function
  O: 0x039F,
  P: 0x03A0,
  R: 0x03A1,
  S: 0x03A3, // no capital final sigma, so can just render it normally
  T: 0x03A4,
  U: 0x03A5,
  F: 0x03A6,
  X: 0x03A7,
  // psi is handled in the function
  W: 0x03A9,
  // accent marks, return a combining diacritical (which typist handles properly)
  "/": 0x0301,
  "\\": 0x0300,
  "=": 0x0342,
  "|": 0x0345,
  ":": 0x0308,
  // rough breathing mark is handled directly in the function
  // punctuation
  ";": 0x0387,  // high dot
  "?": 0x037E,
)

#let vowelList = (
  "a", "e", "h", "i", "o", "u", "w",
  "A", "E", "H", "I", "O", "U", "W"
)

#let ptgk(txt) = {

  let i = 0
  while i < txt.len() {
    let ltr = txt.at(i)
    // rough breathing mark
    if ltr == "(" and vowelList.contains(txt.at(i + 1)) { 
      let code = letterDictionary.at(txt.at(i + 1))
      let brMark = 0x0314
      str.from-unicode(code)
      str.from-unicode(brMark)
      i = i + 2
    // apply smooth breathing mark if previous character is a space or this vowel is the first letter of the string, but not if next character is a vowel
    } else if vowelList.contains(ltr) {
      let prev
      if (i == 0) {
        prev = " "
      } else {
        prev = txt.at(i - 1)
      }
      let next = txt.at(i + 1, default: "")
      if prev == " " and next not in vowelList and next != "(" and next != ")" {
        let code = letterDictionary.at(ltr)
        let brMark = 0x0313
        str.from-unicode(code)
        str.from-unicode(brMark)
        i = i + 1
      } else {
        let code = letterDictionary.at(ltr)
        str.from-unicode(code)
        i = i + 1  
      }
    // allow manual addition of smooth breathing mark (e.g. for diphthongs)
    } else if ltr == ")" and vowelList.contains(txt.at(i + 1)) {
        let code = letterDictionary.at(txt.at(i + 1))
        let brMark = 0x0313
        str.from-unicode(code)
        str.from-unicode(brMark)
        i = i + 2
    // combining characters (ksi and psi), plus final vs. non-final sigma
    } else if ltr == "k" {
        let next = txt.at(i + 1, default: "")
        if next == "s" {
          str.from-unicode(0x03BE)
          i = i + 2
        } else {
          let code = letterDictionary.at(ltr)
          str.from-unicode(code)
          i = i + 1
        }
    } else if ltr == "K" {
      let next = txt.at(i + 1, default: "")
        if next == "s" or next == "S" {
          str.from-unicode(0x039E)
          i = i + 2
        } else {
          let code = letterDictionary.at(ltr)
          str.from-unicode(code)
          i = i + 1
        }
    } else if ltr == "p" {
        let next = txt.at(i + 1, default: "")
        if next == "s" {
          str.from-unicode(0x03C8)
          i = i + 2
        } else {
          let code = letterDictionary.at(ltr)
          str.from-unicode(code)
          i = i + 1
        }
   } else if ltr == "P" {
      let next = txt.at(i + 1, default: "")
      if next == "s" or next == "S" {
        str.from-unicode(0x03A8)
        i = i + 2
      } else {
        let code = letterDictionary.at(ltr)
        str.from-unicode(code)
        i = i + 1
      }
    } else if ltr == "s" { // see if we're at the end of a word, in which case render the final sigma
        let next = txt.at(i + 1, default: "")
        if next == "." or next == "," or next == " " or next == "?" or next == ";" or next == "" or next == "\n" {
          str.from-unicode(0x03C2) // final sigma
          i = i + 1
        } else {
          str.from-unicode(0x03C3)
          i = i + 1
        }
    } else {
      let code = letterDictionary.at(ltr, default: -2)
      if (code != -2 ) {
        str.from-unicode(code)
      } else {
        ltr
      }
      i = i + 1
    }
  }
}
