
#import "bib-tex.typ": *


// --------------------------------------------------
//  CITE FUNCTION
// --------------------------------------------------

#let bib-cite-turn = state("bib-cite-turn", ())

#let update-bib-cite-turn(cite-arr) = bib-cite-turn.update(
  bib_info => {
    let output_arr = bib_info
    let add_num = cite-arr.at(2)
    if output_arr.contains(add_num) == false {
      output_arr.push(add_num)
    }
    output_arr
  },
)

#let format-bib-cite(label, bib-cite) = {
  let entry = query(label).at(0)
  let cite-arr = eval(entry.supplement.text)
  update-bib-cite-turn(cite-arr)
  cite-arr = (cite-arr.at(0), cite-arr.at(1), cite-arr.at(3), entry.body)
  link(label, bib-cite.at(1)(cite-arr))
}

#let bib-cite-func(
  bib-cite: (),
  ..label_argument,
) = context {
  let labels = label_argument.pos()

  if labels.len() == 1 {
    bib-cite.at(0) + format-bib-cite(labels.at(0), bib-cite) + bib-cite.at(3)
  } else {
    let output = ""
    for (index, label) in labels.enumerate() {
      output += format-bib-cite(label, bib-cite)
      output += if index == labels.len() - 1 { bib-cite.at(3) } else { bib-cite.at(2) }
    }
    bib-cite.at(0) + output
  }
}

// --------------------------------------------------
//  INITIALIZATION
// --------------------------------------------------

#let bib-init(
  bib-cite: (),
  body,
) = {
  show ref: it => {
    if it.has("element") and it.element != none {
      if it.element.has("kind") and it.element.kind == "bib" {
        let cite-arr = eval(it.element.supplement.text)

        update-bib-cite-turn(cite-arr)

        cite-arr = (cite-arr.at(0), cite-arr.at(1), cite-arr.at(3), it.element.body)

        if it.supplement == ref.supplement {
          //その他
          bib-cite.at(0) + link(it.target, bib-cite.at(1)(cite-arr)) + bib-cite.at(3)
        } else {
          link(it.target, it.supplement)
        }
      } else {
        it
      }
    } else {
      it
    }
  }
  body
}



#let from-content-to-output(
  year-doubling,
  bib-sort,
  bib-sort-ref,
  bib-full,
  bib-vancouver,
  vancouver-style,
  bib-year-doubling,
  bib-vancouver-manual,
  hanging-indent,
  content_raw,
) = {
  let contents = content_raw.pos()

  // ----- ソートする場合 ----- //
  if bib-sort {
    let yomi_arr = () //yomiの配列
    let num = 0 //番号
    for value in contents {
      //各文献ごとにyomi_arrに追加
      yomi_arr.push((value.at(2), num))
      num += 1
    }
    yomi_arr = yomi_arr.sorted() //yomi_arrをソート
    let sorted_contents = () //ソートされた文献の配列
    for value in yomi_arr {
      //yomi_arrの順番にcontentsをソート
      sorted_contents.push(contents.at(value.at(1)))
    }
    contents = sorted_contents //contentsをソートされたものに変更
  }

  for value in range(contents.len()) {
    contents.at(value).push(value)
  }

  // ----- 出力 ----- //

  context {
    let bib-cite-turn-arr = bib-cite-turn.final()
    if bib-cite-turn-arr == () {
      //もし何も引用されてなければ，全ての文献を表示する
      bib-cite-turn-arr = range(contents.len())
    }

    // ----- 文献番号をリストに変換 ----- //

    let output_contents = ()
    if bib-sort-ref {
      //引用された順番に文献を出力
      for value in bib-cite-turn-arr {
        output_contents.push(contents.at(value))
      }
    } else {
      if bib-full {
        for value in range(contents.len()) {
          output_contents.push(contents.at(value))
        }
      } else {
        bib-cite-turn-arr = bib-cite-turn-arr.sorted()
        for value in bib-cite-turn-arr {
          output_contents.push(contents.at(value))
        }
      }
    }

    if bib-full and bib-sort-ref {
      //全文献を出力
      let num = 0
      for value in contents {
        if bib-cite-turn-arr.contains(num) == false {
          output_contents.push(value)
        }
        num += 1
      }
    }

    if vancouver-style == false {
      //ハーバード方式のとき
      let duplicate_indices = (:)
      for (index, value) in output_contents.enumerate() {
        let cite = value.at(1).join(", ")
        let indices = duplicate_indices.at(cite, default: ())
        indices.push(index)
        duplicate_indices.insert(cite, indices)
      }

      for indices in duplicate_indices.values() {
        if indices.len() > 1 {
          for (number, index) in indices.enumerate() {
            let suffix = numbering(bib-year-doubling, number + 1)
            output_contents.at(index).at(0).insert(1, (suffix,))
            output_contents.at(index).at(1).at(1) += suffix
          }
        }
      }
    }

    // ----- リストを出力形式に変換 ----- //

    let num = 1
    let output_bib = ()

    if vancouver-style and bib-vancouver != "manual" {
      for value in output_contents {
        let cite-arr = value.at(1)
        cite-arr.push(value.at(4))
        cite-arr.push(num)
        output_bib.push([+ #figure(value.at(0).sum().sum(), kind: "bib", supplement: [#cite-arr])#label(value.at(3))])

        num += 1
      }
    } else {
      for value in output_contents {
        let cite-arr = value.at(1)
        cite-arr.push(value.at(4))
        cite-arr.push(num)
        output_bib.push([#figure(value.at(0).sum().sum(), kind: "bib", supplement: [#cite-arr])#label(value.at(3))])

        num += 1
      }
    }

    // ----- 出力 ----- //

    if vancouver-style {
      if bib-vancouver == "manual" {
        let output_bib2 = ()
        let cite-arr = ()
        for index in range(num - 1) {
          cite-arr = (output_contents.at(index).at(1))
          cite-arr.push(index)
          output_bib2.push(bib-vancouver-manual(cite-arr))
          output_bib2.push(output_bib.at(index))
        }

        table(
          columns: (auto, auto),
          rows: auto,
          gutter: (),
          column-gutter: (),
          row-gutter: (),
          align: (left, left),
          stroke: none,
          fill: none,
          inset: 0% + 5pt,
          ..output_bib2
        )
      } else {
        set enum(numbering: bib-vancouver)
        output_bib.sum()
      }
    } else {
      set par(hanging-indent: hanging-indent)
      output_bib.sum()
    }
  }
}

// --------------------------------------------------
//  MAIN FUNCTION
// --------------------------------------------------

//メイン関数
#let bibliography-list(
  year-doubling: "",
  bib-sort: false,
  bib-sort-ref: false,
  bib-full: false,
  bib-vancouver: "(1)",
  vancouver-style: false,
  bib-year-doubling: "a",
  bib-vancouver-manual: "",
  hanging-indent: 2em,
  title: context if (text.lang == "ja") { [参考文献] } else { [Bibliography] },
  ..body,
) = {
  if title != none {
    heading(title, numbering: none)
  }

  set par(first-line-indent: 0em)
  set par(leading: 1em)

  show figure.where(kind: "bib"): it => {
    align(left, it)
  }

  from-content-to-output(
    year-doubling,
    bib-sort,
    bib-sort-ref,
    bib-full,
    bib-vancouver,
    vancouver-style,
    bib-year-doubling,
    bib-vancouver-manual,
    hanging-indent,
    body,
  )
}

// ---------- 文献形式に出力する関数 ---------- //
#let bib-tex(
  lang: auto,
  style: (:),
  it,
) = {
  let dict = load-bibliography(it, sentence-case-titles: style.sentence-case-titles).values().at(0)
  let dict = add-dict-lang(dict, lang)

  let output_arr = ()
  let bib_element_function = get-element-function(style, dict)
  output_arr.push(bibtex-to-bib(style.year-doubling, dict, bib_element_function))

  let element_cite_list = bibtex-to-cite(
    style.bib-cite-author,
    style.bib-cite-year,
    dict,
  )
  output_arr.push(element_cite_list)
  output_arr.push(bibtex-yomi(dict, output_arr.at(0)))
  output_arr.push(dict.entry_key)

  return output_arr
}

#let bib-item(it, author: "", year: "", yomi: none, label: "") = {
  let output_arr = ()
  let bib_str = ""
  if type(it) == content or type(it) == str {
    output_arr.push(((it,),))
    bib_str = if type(it) == content { contents-to-str(it) } else { it }
  } else {
    let output_bib = ()
    for v in it {
      output_bib.push((v,))
    }
    output_arr.push(output_bib)
    bib_str = it.sum()
    if type(bib_str) == content {
      bib_str = contents-to-str(bib_str)
    }
  }

  output_arr.push((author, year))
  output_arr.push(if yomi == none { bib_str } else { yomi })
  output_arr.push(str(label))

  return output_arr
}

#let bib-file(
  style: (:),
  file_contents,
) = {
  let file_arr = file_contents.split(regex("(^|[^\\\\])@"))
  let output-arr = ()
  for value in file_arr {
    if not value.starts-with("comment") and value != "" {
      output-arr.push("@" + value)
    }
  }

  let output-bib = ()

  for value in output-arr {
    output-bib.push(bib-tex(
      style: style,
      value,
    ))
  }

  return output-bib
}

#let set-style(
  style,
  add-utils: (:),
) = {
  // tomlファイル内の関数文字列を関数に変換
  let utils = utils
  for value in add-utils.pairs() {
    utils.insert(value.at(0), value.at(1))
  }

  style.insert("bib-cite-author", utils.at(style.bib-cite-author))
  style.insert("bib-cite-year", utils.at(style.bib-cite-year))
  style.insert("bib-vancouver-manual", utils.at(style.bib-vancouver-manual))

  for value in style.cite.pairs() {
    let tmp = value.at(1)
    tmp.at(1) = utils.at(tmp.at(1))
    style.cite.insert(value.at(0), tmp)
  }

  for entry in style.entry.pairs() {
    for value in entry.at(1).en.pairs() {
      let tmp = value.at(1)
      tmp.at(2) = utils.at(tmp.at(2))
      entry.at(1).en.insert(value.at(0), tmp)
    }
    for value in entry.at(1).ja.pairs() {
      let tmp = value.at(1)
      tmp.at(2) = utils.at(tmp.at(2))
      entry.at(1).ja.insert(value.at(0), tmp)
    }
    style.entry.insert(entry.at(0), entry.at(1))
  }

  //各関数にスタイルを適用
  let bib-init = bib-init.with(bib-cite: style.cite.bib-cite)
  let bibliography-list = bibliography-list.with(
    year-doubling: style.year-doubling,
    bib-sort: style.bib-sort,
    bib-sort-ref: style.bib-sort-ref,
    bib-full: style.bib-full,
    bib-vancouver: style.bib-vancouver,
    vancouver-style: style.vancouver-style,
    bib-year-doubling: style.bib-year-doubling,
    bib-vancouver-manual: style.bib-vancouver-manual,
  )
  let bib-tex = bib-tex.with(style: style)
  let bib-file = bib-file.with(style: style)
  let bib-item = bib-item
  let citet = bib-cite-func.with(bib-cite: style.cite.bib-citet)
  let citep = bib-cite-func.with(bib-cite: style.cite.bib-citep)
  let citen = bib-cite-func.with(bib-cite: style.cite.bib-citen)
  let citefull = bib-cite-func.with(bib-cite: style.cite.bib-citefull)

  return (
    bib-init: bib-init,
    bibliography-list: bibliography-list,
    bib-tex: bib-tex,
    bib-file: bib-file,
    bib-item: bib-item,
    citet: citet,
    citep: citep,
    citen: citen,
    citefull: citefull,
  )
}
