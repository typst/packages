/// CSL言語の制限を超えたカスタマイズのための擬似的な参考文献リストを生成する
///
/// - yaml-data (dictionary): Hayagriva YAML形式のデータ
/// - show-unused (boolean): 文内未参照のエントリーを表示するかどうか
#let fake-bibliography(yaml-data, show-unused: false) = {
  if yaml-data == none {
    return none
  }
  // set text(fill: blue)
  // TODO:
  // locate(loc => {
  //   let all-refs = query(cite, loc)
  //   repr(all-refs)
  // })
  let format-entry(b) = {
    let language = if "language" in b {
      b.language
    } else {
      "en"
    }

    let colon = if language == "ja" {
      "："
    } else {
      ": "
    }
    let comma = if language == "ja" {
      "，"
    } else {
      ", "
    }
    let period = if language == "ja" {
      "．"
    } else {
      ". "
    }
    let parenthesize(text) = "(" + text + ")"

    // 著者
    if "author" in b {
      if type(b.author) == str {
        b.author = (b.author,)
      }
      let replaced = b.author.map(a => if language == "ja" {
        a.replace(", ", "")
      } else {
        a
      })

      if language == "ja" or replaced.len() == 1 {
        replaced.join(comma)
      } else {
        replaced.slice(0, -1).join(comma) + " and " + replaced.at(-1)
      }
    }

    if "editor" in b {
      if type(b.editor) == str {
        b.editor = (b.editor,)
      }
      let replaced = b.editor.map(a => if language == "ja" {
        a.replace(", ", "")
      } else {
        a
      })

      if language == "ja" or replaced.len() == 1 {
        replaced.join(comma)
      } else {
        replaced.slice(0, -1).join(comma) + " and " + replaced.at(-1)
      }
    }

    colon

    if language == "en" and b.type == "Book" {
      emph(b.title)
    } else {
      b.title
    }

    if "note" in b {
      " "
      parenthesize(b.note)
    }

    // Journal/Book of an article
    if "parent" in b {
      if "title" in b.parent {
        comma
        if language == "en" {
          emph(b.parent.title)
        } else {
          (b.parent.title)
        }
      }

      if "volume" in b.parent {
        comma
        "Vol. "
        str(b.parent.volume)
      }

      if "issue" in b.parent {
        comma
        "No. "
        str(b.parent.issue)
      }
    }

    if "series" in b {
      comma
      b.series
    }

    if "volume" in b {
      comma
      "Vol. "
      str(b.volume)
    }

    if "issue" in b {
      comma
      "No. "
      str(b.issue)
    }

    if "publisher" in b {
      comma
      b.publisher
    }

    if "address" in b {
      comma
      b.address
    }

    let format-date(date) = {
      "("
      let splitted = str(date).split("-")
      splitted.join(".")
      ")"
    }

    if "date" in b {
      [ ]
      format-date(b.date)
    }

    if "url" in b {
      let url = none
      let access = none
      if type(b.url) == str {
        url = b.url
      } else {
        url = b.url.value
        access = b.url.date
      }

      if url != none {
        comma
        [入手先 ]
        "⟨"
        url
        "⟩"
      }

      if access != none {
        [ ]
        format-date(access)
      }
    }

    if "page-range" in b {
      comma
      "pp. "
      b.page-range
    }

    if "doi" in b {
      comma
      "DOI: "
      link("https://doi.org/" + b.doi, b.doi)
    }

    if "serial-number" in b {
      if type(b.serial-number) == str {
        comma
        b.serial-number
      }

      for (key, number) in b.serial-number.pairs() {
        comma
        if key == "doi" {
          "DOI: "
          link("https://doi.org/" + number, number)
        } else {
          upper(key) + ": "
          number
        }
      }
    }

    period
  }

  context {
    let citations = query(ref.where(element: none))
      .map(r => str(r.target))
      .dedup()

    // If no citations are found, list all entries to prevent user confusion
    let formatted-entries = if citations.len() == 0 {
      yaml-data.values().map(value => format-entry(value))
    } else {
      citations.map(c => format-entry(yaml-data.at(c)))
    }

    /// Entries that are not cited
    let rest-entries = if show-unused {
      let used-entries = citations.map(c => yaml-data.at(c))
      yaml-data
        .values()
        .filter(e => not used-entries.contains(e))
        .map(format-entry)
    } else {
      ()
    }

    // repr(citations.len())
    set text(size: 8.5pt)
    enum(
      numbering: "[1]",
      indent: 0em,
      body-indent: 2em,
      ..formatted-entries,
      ..rest-entries,
    )
  }
}
