
// ---------- contentsをstringsに変換する関数 ---------- //
// !! この関数はbib_tex.typで使用されているため，関数名・および中身を変更しないように注意 !!
#let contents-to-str(content) = {
  let str = ""
  if content.has("text") {
    str = content.text
    str
  } else if content.has("children") {
    str = content.children.map(contents-to-str).join("")
    str
  } else if content.has("body") {
    contents-to-str(content.body)
  } else if content == [ ] {
    " "
  } else if content.has("child") {
    contents-to-str(content.child)
  }
}

// ---------- 文字列の左側のスペースを削除する関数 ---------- //
#let remove-space-l(text) = {
  return text.trim(regex("^\\s+"))
}

// ---------- 文字列の右側のスペースを削除する関数 ---------- //
#let remove-space-r(text) = {
  return text.trim(regex("\\s+$"))
}

// ---------- 文字列の両側のスペースを削除する関数 ---------- //
#let remove-space(text) = {
  return text.trim()
}

// ---------- 項目内をそのまま返す関数 ---------- //
#let all-return(biblist, name) = {
  return biblist.fields.at(name, default: "")
}

// ---------- 項目内を太文字にして返す関数 ---------- //
#let all-bold(biblist, name) = {
  return strong(biblist.fields.at(name, default: ""))
}

// ---------- 項目内を斜体にして返す関数 ---------- //
#let all-emph(biblist, name) = {
  return emph(biblist.fields.at(name, default: ""))
}

// ---------- 英語の著者名(例：Reynolds, Osborne)を型(例：Reynolds O.)に変換 ---------- //
#let author-en(author_arr) = {
  let given = author_arr.at("given")

  if given != "" {
    given = given.split(" ").map(x => upper(x.at(0)) + ".").join(" ")
  }

  return (author_arr.prefix, author_arr.family, given, author_arr.suffix).filter(x => x != "").join(" ")
}

// ---------- 英語の著者名(例：Reynolds, Osborne)を型(例：Reynolds)に変換 ---------- //
#let author-en2(author_arr) = {
  return (author_arr.prefix, author_arr.family).filter(x => x != "").join(" ")
}


// ---------- 英語の著者名(例：Reynolds, Osborne)を型(例：O Reynolds)に変換 ---------- //
#let author-en3(author_arr) = {
  let given = author_arr.at("given")
  let suffix = author_arr.at("suffix")

  if given != "" {
    given = upper(given.at(0))
  }

  if suffix != "" {
    suffix = upper(suffix.at(0))
  }

  return (author_arr.prefix, author_arr.family, given, suffix).filter(x => x != "").join(" ")
}

// ---------- 英語の著者名(例：Reynolds, Osborne)を型(例：Osborne Reynolds)に変換 ---------- //
#let author-en4(author_arr) = {
  return (author_arr.prefix, author_arr.given, author_arr.family, author_arr.suffix).filter(x => x != "").join(" ")
}

// ---------- 英語の著者名(例：Reynolds, Osborne)を型(例：O. Reynolds)に変換 ---------- //
#let author-en5(author_arr) = {
  let given = author_arr.at("given")
  let suffix = author_arr.at("suffix")

  if given != "" {
    given = given.split(" ").map(x => upper(x.at(0)) + ".").join(" ")
  }

  if suffix != "" {
    suffix = upper(suffix.at(0))
  }

  return (given, author_arr.prefix, author_arr.family, suffix).filter(x => x != "").join(" ")
}

// ---------- 英語の著者名(例：Reynolds, Osborne)を型(例：RAYNOLDS O)に変換 ---------- //
#let author-en6(author_arr) = {
  let given = author_arr.at("given")
  let suffix = author_arr.at("suffix")

  if given != "" {
    given = given.split(" ").map(x => upper(x.at(0)) + ".").join(" ")
  }

  if suffix != "" {
    suffix = upper(suffix.at(0))
  }

  return (smallcaps(author_arr.family), smallcaps(author_arr.prefix), given, suffix).filter(x => x != "").join(" ")
}

// ---------- 英語の著者名(例：Reynolds, Osborne)を型(例：Reynolds, O.)に変換 ---------- //
#let author-en7(author_arr) = {
  let family = author_arr.at("family")
  let given = author_arr.at("given")

  if family != "" {
    family = family + ", "
  }

  if given != "" {
    given = given.split(" ").map(x => upper(x.at(0)) + ".").join(" ")
  }

  return (author_arr.prefix, family, given, author_arr.suffix).filter(x => x != "").join(" ")
}

// ---------- 日本語の著者名はそのまま繋げて出力 ---------- //
#let author-ja(author_arr) = {
  return author_arr.prefix + author_arr.family + author_arr.given + author_arr.suffix
}

// ---------- 項目を著者型にして返す関数の共通部分 ---------- //
#let make-author-set(biblist, name, author-ja-func, author-en-func) = {
  let author_arr = biblist
    .parsed_names
    .at(name, default: ())
    .map(author => {
      let authorsum = author.values().sum()
      let check = (regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]") in authorsum)

      if check {
        return author-ja-func(author)
      } else {
        return author-en-func(author)
      }
    })

  if biblist.fields.lang == "ja" {
    return author_arr.join(", ")
  } else {
    return author_arr.join(", ", last: " and ")
  }
}

// ---------- 項目を著者型にして返す関数(author-en型) ---------- //
#let author-set(biblist, name) = {
  return make-author-set(biblist, name, author-ja, author-en)
}

// ---------- 項目を著者型にして返す関数(author-en3型) ---------- //
#let author-set2(biblist, name) = {
  return make-author-set(biblist, name, author-ja, author-en3)
}

// ---------- 項目を著者型にして返す関数(author-en4型) ---------- //
#let author-set3(biblist, name) = {
  return make-author-set(biblist, name, author-ja, author-en4)
}

// ---------- 項目を著者型にして返す関数(author-en5型) ---------- //
#let author-set4(biblist, name) = {
  return make-author-set(biblist, name, author-ja, author-en5)
}

// ---------- 項目を著者型にして返す関数(author-en6型) ---------- //
#let author-set5(biblist, name) = {
  return make-author-set(biblist, name, author-ja, author-en6)
}

// ---------- 項目を著者型にして返す関数(author-en7型) ---------- //
#let author-set6(biblist, name) = {
  return make-author-set(biblist, name, author-ja, author-en7)
}

// ---------- 項目をciteの著者型にして返す関数 ---------- //
#let author-set-cite(biblist, name) = {
  let author_arr2 = ()
  if biblist.fields.at(name, default: "") != "" {
    author_arr2 = biblist.parsed_names.at(name, default: ())
  } else {
    author_arr2 = ((family: "", given: "", prefix: "", suffix: ""),)
  }

  let author_arr = author_arr2.map(author => {
    let authorsum = author.values().sum()
    let check = (regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]") in authorsum)

    if check {
      return author.prefix + author.family
    } else {
      return author-en2(author)
    }
  })

  let author-joint = (" and ", " et al.")
  if biblist.fields.lang == "ja" {
    author-joint = (", ", "他")
  }

  if author_arr.len() == 1 {
    // 著者が1人の場合
    return author_arr.sum()
  } else if author_arr.len() == 2 {
    // 著者が2人の場合
    return author_arr.join(author-joint.at(0))
  } else {
    // 著者が3人以上の場合
    return (author_arr.at(0), author-joint.at(1)).sum()
  }
}

// ---------- URLを付与して返す関数 ---------- //
#let set-url(biblist, name) = {
  if biblist.fields.at("url", default: none) != none {
    //urlがある場合
    let url = biblist.fields.at("url")
    return link(url, biblist.fields.at(name))
  } else if biblist.fields.at("doi", default: none) != none {
    //doiがある場合
    let url = biblist.fields.at("doi")
    return link(url, biblist.fields.at(name))
  } else {
    //urlがない場合
    return biblist.fields.at(name)
  }
}

// ---------- ページ形式にして返す関数 ---------- //
#let page-set(biblist, name, prefix: ("pp.~", "p.~")) = {
  let pagestr = biblist.fields.at(name)

  if pagestr.contains("--") or pagestr.contains("–") {
    return prefix.at(0) + pagestr
  } else if pagestr.contains("-") {
    pagestr = pagestr.replace("-", "--")
    return prefix.at(0) + pagestr
  } else {
    return prefix.at(1) + pagestr
  }
}

// ---------- ページ形式にして返す関数(ppを表示しない) ---------- //
#let page-set-without-p(biblist, name) = {
  return page-set(biblist, name, prefix: ("", ""))
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// bib-vancouver = "manual"のときの設定関数
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#let bib-vancouver-manual-default(bib_cite_contents) = {
  if bib_cite_contents.at(0) == none {
    bib_cite_contents.at(0) = ""
  }

  let tmp = bib_cite_contents.at(0).split(regex("and|, ")).map(x => remove-space(x))
  let bib_cite_name_arr = ()
  let is_japanese = false
  for value in tmp {
    bib_cite_name_arr.push(value)
    if (regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]") in value) {
      is_japanese = true
    }
  }

  let bib_cite_name = ""

  if is_japanese {
    if (regex(".*他") in bib_cite_name_arr.at(-1)) {
      //3人以上の場合
      bib_cite_name = bib_cite_name_arr.at(0).at(0) + "+"
    } else {
      bib_cite_name = bib_cite_name_arr.map(x => x.at(0)).join()
    }
  } else {
    if (regex(" et al\.") in bib_cite_name_arr.at(-1)) {
      //3人以上の場合
      bib_cite_name = bib_cite_name_arr.at(0)
      bib_cite_name = bib_cite_name.slice(0, bib_cite_name.len() - " et al.".len())

      if bib_cite_name.len() > 3 {
        bib_cite_name = bib_cite_name.slice(0, 3)
      }
      bib_cite_name += "+"
    } else if bib_cite_name_arr.len() == 1 {
      bib_cite_name = bib_cite_name_arr.sum()
      if bib_cite_name.len() > 3 {
        bib_cite_name = bib_cite_name.slice(0, 3)
      }
    } else {
      for index in range(bib_cite_name_arr.len()) {
        bib_cite_name += bib_cite_name_arr.at(index).at(0)
      }
    }
  }

  let year = bib_cite_contents.at(1)
  if year == "" {
    year = ""
  } else {
    year = year.slice(2, 4)
  }

  return "[" + bib_cite_name + year + "]"
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 各引用の表示形式設定関数
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#let bib-citet-default(bib_cite_contents) = {
  return bib_cite_contents.at(0) + [~(] + bib_cite_contents.at(1) + [)]
}

#let bib-citep-default(bib_cite_contents) = {
  return bib_cite_contents.at(0) + [,~] + bib_cite_contents.at(1)
}

#let bib-citen-default(bib_cite_contents) = {
  return str(bib_cite_contents.at(2))
}

// The author/year label used by the standard jalpha and jname styles.
#let bib-cite-alpha(bib_cite_contents) = {
  let names = bib_cite_contents.at(0).split(regex("and|, ")).map(x => remove-space(x))
  let japanese = names.any(name => regex("[\\p{scx:Han}\\p{scx:Hira}\\p{scx:Kana}]") in name)
  let label = ""

  if japanese {
    if regex(".*他") in names.at(-1) {
      label = names.at(0).at(0) + "+"
    } else {
      label = names.map(name => name.at(0)).join()
    }
  } else if regex(" et al\\.") in names.at(-1) {
    label = names.at(0).replace(" et al.", "")
    if label.len() > 3 { label = label.slice(0, 3) }
    label += "+"
  } else if names.len() == 1 {
    label = names.at(0)
    if label.len() > 3 { label = label.slice(0, 3) }
  } else {
    label = names.map(name => name.at(0)).join()
  }

  let year = bib_cite_contents.at(1)
  if year == "" { year = "" } else { year = year.slice(2, 4) }
  label + year
}

#let bib-citefull-default(bib_cite_contents) = {
  return bib_cite_contents.at(3)
}

#let bib-cite-authoronly(bib_cite_contents) = {
  return bib_cite_contents.at(0)
}

#let bib-cite-yearonly(bib_cite_contents) = {
  return bib_cite_contents.at(1)
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// 前関数辞書
// % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#let utils = (
  contents-to-str: contents-to-str,
  remove-space-l: remove-space-l,
  remove-space-r: remove-space-r,
  remove-space: remove-space,
  all-return: all-return,
  all-bold: all-bold,
  all-emph: all-emph,
  author-en: author-en,
  author-en2: author-en2,
  author-en3: author-en3,
  author-en4: author-en4,
  author-en5: author-en5,
  author-en6: author-en6,
  author-en7: author-en7,
  author-ja: author-ja,
  author-set: author-set,
  author-set2: author-set2,
  author-set3: author-set3,
  author-set4: author-set4,
  author-set5: author-set5,
  author-set6: author-set6,
  author-set-cite: author-set-cite,
  set-url: set-url,
  page-set: page-set,
  page-set-without-p: page-set-without-p,
  bib-vancouver-manual-default: bib-vancouver-manual-default,
  bib-citet-default: bib-citet-default,
  bib-citep-default: bib-citep-default,
  bib-citen-default: bib-citen-default,
  bib-cite-alpha: bib-cite-alpha,
  bib-citefull-default: bib-citefull-default,
  bib-cite-authoronly: bib-cite-authoronly,
  bib-cite-yearonly: bib-cite-yearonly,
)
