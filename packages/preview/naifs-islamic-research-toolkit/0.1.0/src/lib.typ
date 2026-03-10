/// Renders Quranic text.
///
/// - sura (int): The Sura number (1-114).
/// - verse (int, array, none): The verse number (int) or range (array of two ints, e.g., (1, 3)). If none, the whole Sura is returned.
/// - word (int, array, none): The word number (int) or range (array of two ints, e.g., (1, 3)). If none, the whole verse is returned.
/// - qiraa (str, auto): The Qiraa to use ("hafs", "warsh", "حفص", "ورش"). If auto, uses the globally set qiraa.
/// - bracket (bool, auto): Whether to wrap the text in Quranic brackets. If auto, uses the globally set preference (default: true).
#let (quran, قرآن, set-qiraa, ضبط-القراءة, set-bracket, تفعيل-الأقواس) = {
  let qiraa-state = state("quran-qiraa", "hafs")
  let bracket-state = state("quran-bracket", true)

  let rlo = str.from-unicode(0x202E)
  let pdf = str.from-unicode(0x202C)
  let force-rtl(content) = rlo + content + pdf

  let quran-impl(sura, verse, word, qiraa, bracket) = {
    let wrap-word(w) = {
      let variant = if qiraa == "hafs" or qiraa == "حفص" { "Hafs" } else { "Warsh" }
      let page = str(w.p)
      if page.len() == 1 { page = "0" + page }
      let font = "QCF4_" + variant + "_" + page + "_W"
      text(font: font, fallback: false)[#str.from-unicode(w.c)]
    }

    assert(
      qiraa == "hafs" or qiraa == "warsh" or qiraa == "حفص" or qiraa == "ورش",
      message: "Invalid qiraa. Must be one of: 'hafs', 'warsh', 'حفص', 'ورش'.",
    )
    assert(type(bracket) == bool, message: "Bracket parameter must be a boolean.") 

    let mushaf = if qiraa == "hafs" or qiraa == "حفص" { json("hafs.json") } else { json("warsh.json") }

    let format-output(content) = {
      if bracket {
        let font = if qiraa == "hafs" or qiraa == "حفص" { "QCF4_Hafs_01_W" } else { "QCF4_Warsh_01_W" }
        let open = text(font: font, fallback: false)[#str.from-unicode(0xF8E0)]
        let close = text(font: font, fallback: false)[#str.from-unicode(0xF8E1)]
        force-rtl(open + content + close)
      } else {
        force-rtl(content)
      }
    }

    assert(type(sura) == int, message: "Sura number is required. Must specify a sura integer between 1 and " + str(mushaf.len()) + ".")
    assert(
      sura >= 1 and sura <= mushaf.len(),
      message: "Invalid sura number: " + str(sura) + ". Must be between 1 and " + str(mushaf.len()) + "."
    )

    let selected-sura = mushaf.at(sura - 1)

    if verse == none {
      assert(word == none, message: "Cannot specify a word without specifying a verse.")
      return format-output(
        selected-sura.flatten().map(wrap-word).join(" "),
      )
    }

    if type(verse) == int {
      assert(
        verse >= 1 and verse <= selected-sura.len(),
        message: "Invalid verse number: " + str(verse) + ". Sura " + str(sura) + " has " + str(selected-sura.len()) + " verses."
      )

      let words = selected-sura.at(verse - 1)

      if word == none {
        return format-output(words.map(wrap-word).join(" "))
      }

      let assert-word(word-idx) = assert(
        word-idx >= 1 and word-idx <= words.len(),
        message: "Invalid word number: " + str(word-idx) + ". Verse " + str(verse) + " has " + str(words.len()) + " words.",
      )

      if type(word) == int {
        assert-word(word)
        return format-output(wrap-word(words.at(word - 1)))
      }

      if type(word) == array {
        if word.len() == 1 {
          let (start-idx) = word
          assert(type(start-idx) == int, message: "Word range value must be an integer.")
          assert-word(start-idx)
          return format-output(
            words.slice(start-idx - 1).map(wrap-word).join(" "),
          )
        }

        if word.len() == 2 {
          let (left-idx, right-idx) = word

          assert(type(left-idx) == int and type(right-idx) == int, message: "Word range values must be integers.")
          assert(left-idx != right-idx, message: "Word range start and end cannot be equal.")

          let start-idx = calc.min(left-idx, right-idx)
          let end-idx = calc.max(left-idx, right-idx)

          assert-word(start-idx)
          assert-word(end-idx)

          return format-output(
            words.slice(start-idx - 1, end-idx).map(wrap-word).join(" "),
          )
        }

        panic(
          "Invalid word range length: " + str(word.len()) + ". Must be 1 or 2.",
        )
      }

      panic("Invalid word type: " + str(type(word)) + ". Must be int, array, or none.")
    }

    if type(verse) == array {
      assert(word == none, message: "Cannot specify words when a verse range is provided.")

      let assert-verse(verse-idx) = assert(
        verse-idx >= 1 and verse-idx <= selected-sura.len(),
        message: "Invalid verse number: " + str(verse-idx) + ". Sura " + str(sura) + " has " + str(selected-sura.len()) + " verses.",
      )

      if verse.len() == 1 {
        let (start-idx) = verse
        assert(type(start-idx) == int, message: "Verse range value must be an integer.")
        assert-verse(start-idx)
        return format-output(
          selected-sura.slice(start-idx - 1).flatten().map(wrap-word).join(" "),
        )
      }

      if verse.len() == 2 {
        let (left-idx, right-idx) = verse

        assert(type(left-idx) == int and type(right-idx) == int, message: "Verse range values must be integers.")
        assert(left-idx != right-idx, message: "Verse range start and end cannot be equal.")

        let start-idx = calc.min(left-idx, right-idx)
        let end-idx = calc.max(left-idx, right-idx)

        assert-verse(start-idx)
        assert-verse(end-idx)

        return format-output(
          selected-sura.slice(start-idx - 1, end-idx).flatten().map(wrap-word).join(" "),
        )
      }

      panic(
        "Invalid verse range length: " + str(verse.len()) + ". Must be 1 or 2.",
      )
    }

    panic("Invalid verse type: " + str(type(verse)) + ". Must be int, array, or none.")
  }

  let quran(sura: none, verse: none, word: none, qiraa: auto, bracket: auto) = context {
    let q = if qiraa == auto { qiraa-state.get() } else { qiraa }
    let b = if bracket == auto { bracket-state.get() } else { bracket }
    quran-impl(sura, verse, word, q, b)
  }

  let قرآن(سورة: none, آية: none, كلمة: none, قراءة: auto, أقواس: auto) = quran(sura: سورة, verse: آية, word: كلمة, qiraa: قراءة, bracket: أقواس)

  let set-qiraa(qiraa) = qiraa-state.update(qiraa)
  let set-bracket(enabled) = bracket-state.update(enabled)

  let ضبط-القراءة(قراءة) = set-qiraa(قراءة)
  let تفعيل-الأقواس(تفعيل) = set-bracket(تفعيل)

  (quran, قرآن, set-qiraa, ضبط-القراءة, set-bracket, تفعيل-الأقواس)
}
