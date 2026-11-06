
#import "bib-tex.typ": *


// --------------------------------------------------
//  CITE FUNCTION
// --------------------------------------------------

#let bib-cite-turn = state("bib-cite-turn", ())

#let update-bib-cite-turn(cite-arr) = bib-cite-turn.update(
  bib_info => {
    let output_arr = bib_info
    let add_num = cite-arr.at(2)
    if output_arr.contains(add_num) == false{
      output_arr.push(add_num)
    }
    output_arr
  }
)

#let bib-cite-func(
    bib-cite: (),
  ..label_argument
  ) = context{

    let label_arr = label_argument.pos()
    if label_arr.len() == 1{//ラベルが1つのとき

      let label = label_arr.at(0)
      let contents = query(label)
      let cite-arr = eval(contents.at(0).supplement.text)
      update-bib-cite-turn(cite-arr)

      cite-arr = (cite-arr.at(0), cite-arr.at(1), cite-arr.at(3), contents.at(0).body)

      //出力
      bib-cite.at(0) + link(label,bib-cite.at(1)(cite-arr)) + bib-cite.at(3)

    }else{//ラベルが2つ以上のとき

      let label = label_arr.remove(0)
      let contents = query(label)
      let cite-arr = eval(contents.at(0).supplement.text)
      update-bib-cite-turn(cite-arr)
      cite-arr = (cite-arr.at(0), cite-arr.at(1), cite-arr.at(3), contents.at(0).body)
      let output1 = bib-cite.at(0) + link(label,bib-cite.at(1)(cite-arr)) + bib-cite.at(2)

      label = label_arr.remove(-1)
      contents = query(label)
      cite-arr = eval(contents.at(0).supplement.text)
      update-bib-cite-turn(cite-arr)
      cite-arr = (cite-arr.at(0), cite-arr.at(1), cite-arr.at(3), contents.at(0).body)
      let output2 = link(label,bib-cite.at(1)(cite-arr)) + bib-cite.at(3)

      let output = ""
      for label in label_arr{
        contents = query(label)
        cite-arr = eval(contents.at(0).supplement.text)
        update-bib-cite-turn(cite-arr)
        cite-arr = (cite-arr.at(0), cite-arr.at(1), cite-arr.at(3), contents.at(0).body)
        output += link(label,bib-cite.at(1)(cite-arr)) + bib-cite.at(2)
      }

      //出力
      output1 + output + output2
    }
}

// --------------------------------------------------
//  INITIALIZATION
// --------------------------------------------------

#let bib-init(
  bib-cite: (),
  body,
) = {
  show ref: it =>{

      if it.has("element") and it.element != none{
        if it.element.has("kind") and it.element.kind == "bib"{

          let cite-arr = eval(it.element.supplement.text)

          update-bib-cite-turn(cite-arr)

          cite-arr = (cite-arr.at(0), cite-arr.at(1), cite-arr.at(3), it.element.body)

          if it.supplement == ref.supplement{//その他
            bib-cite.at(0) + link(it.target, bib-cite.at(1)(cite-arr)) + bib-cite.at(3)
          }
          else{
            link(it.target, it.supplement)
          }

        }
        else{
          it
        }
      }
      else{
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
  content_raw
) = {

  let contents = content_raw.pos()

  // ----- ソートする場合 ----- //
  if bib-sort{
    let yomi_arr = ()//yomiの配列
    let num = 0//番号
    for value in contents{//各文献ごとにyomi_arrに追加
      yomi_arr.push((value.at(2), num))
      num += 1
    }
    yomi_arr = yomi_arr.sorted()//yomi_arrをソート
    let sorted_contents = ()//ソートされた文献の配列
    for value in yomi_arr{//yomi_arrの順番にcontentsをソート
      sorted_contents.push(contents.at(value.at(1)))
    }
    contents = sorted_contents//contentsをソートされたものに変更
  }


  for value in range(contents.len()){
    contents.at(value).push(value)
  }

  // ----- 出力 ----- //

  context {
    let bib-cite-turn-arr = bib-cite-turn.final()
    if bib-cite-turn-arr == (){//もし何も引用されてなければ，全ての文献を表示する
      bib-cite-turn-arr = range(contents.len())
    }

    // ----- 文献番号をリストに変換 ----- //

    let output_contents = ()
    if bib-sort-ref{//引用された順番に文献を出力
      for value in bib-cite-turn-arr{
        output_contents.push(contents.at(value))
      }
    }
    else{
      if bib-full{
        for value in range(contents.len()){
          output_contents.push(contents.at(value))
        }
      }
      else{
        bib-cite-turn-arr = bib-cite-turn-arr.sorted()
        for value in bib-cite-turn-arr{
          output_contents.push(contents.at(value))
        }
      }
    }

    if bib-full and bib-sort-ref{//全文献を出力
      let num = 0
      for value in contents{
        if bib-cite-turn-arr.contains(num) == false{
          output_contents.push(value)
        }
        num += 1
      }
    }

    // ----- 重複文献に記号を挿入 ----- //

    if vancouver-style == false{//ハーバード方式のとき
      let cite-arr = ()
      for value in output_contents{
        cite-arr.push(value.at(1).join(", "))
      }
      let num = 0
      let remove-num = ()
      for value in cite-arr{
        let num2 = num + 1
        let double_arr = ()
        for value2 in cite-arr.slice(num2){
          if value == value2 and remove-num.contains(num2) == false{
            remove-num.push(num2)
            double_arr.push(num2)
          }
          num2 += 1
        }

        if double_arr != (){//重複があるとき

          double_arr.insert(0, num)
          let num2 = 1

          for value2 in double_arr{
            let add_character = numbering(bib-year-doubling, num2)
            output_contents.at(value2).at(0).insert(1, (add_character, ))
            output_contents.at(value2).at(1).at(1) = output_contents.at(value2).at(1).at(1) + add_character
            num2 += 1
          }
        }

        num += 1
      }
    }

    // ----- リストを出力形式に変換 ----- //

    let num = 1
    let output_bib = ()

    if vancouver-style and bib-vancouver != "manual"{
      for value in output_contents{
        let cite-arr = value.at(1)
        cite-arr.push(value.at(4))
        cite-arr.push(num)
        output_bib.push([+ #figure(value.at(0).sum().sum(), kind: "bib", supplement: [#cite-arr])#value.at(3)])

        num += 1
      }
    }
    else{
      let bibnum = output_contents.len()
      for value in output_contents{
        let cite-arr = value.at(1)
        cite-arr.push(value.at(4))
        cite-arr.push(num)
        output_bib.push([#figure(value.at(0).sum().sum(), kind: "bib", supplement: [#cite-arr])#value.at(3)])

        num += 1
      }
    }

    // ----- 出力 ----- //

    if vancouver-style{
      if bib-vancouver == "manual"{
        let output_bib2 = ()
        let cite-arr = ()
        for index in range(num - 1){
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
      }
      else{
        set enum(numbering: bib-vancouver)
        output_bib.sum()
      }
    }
    else{
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
  title: [文　　　献],
   ..body
  ) = {

  if title != none{
    heading(title, numbering: none)
  }

  set par(first-line-indent: 0em)
  set par(leading: 1em)

  show figure.where(kind: "bib"): it =>{
    align(left, it)
  }

  let bib_content = body
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
    bib_content
  )
}

// ---------- 文献形式に出力する関数 ---------- //
#let bib-tex(
    year-doubling: "",
    bibtex-article-en: (),
    bibtex-article-ja: (),
    bibtex-book-en: (),
    bibtex-book-ja: (),
    bibtex-booklet-en: (),
    bibtex-booklet-ja: (),
    bibtex-inbook-en: (),
    bibtex-inbook-ja: (),
    bibtex-incollection-en: (),
    bibtex-incollection-ja: (),
    bibtex-inproceedings-en: (),
    bibtex-inproceedings-ja: (),
    bibtex-conference-en: (),
    bibtex-conference-ja: (),
    bibtex-manual-en: (),
    bibtex-manual-ja: (),
    bibtex-mastersthesis-en: (),
    bibtex-mastersthesis-ja: (),
    bibtex-misc-en: (),
    bibtex-misc-ja: (),
    bibtex-online-en: (),
    bibtex-online-ja: (),
    bibtex-phdthesis-en: (),
    bibtex-phdthesis-ja: (),
    bibtex-proceedings-en: (),
    bibtex-proceedings-ja: (),
    bibtex-techreport-en: (),
    bibtex-techreport-ja: (),
    bibtex-unpublished-en: (),
    bibtex-unpublished-ja: (),
    bib-cite-author: (),
    bib-cite-year: (),
    lang: auto,
    it
  ) = {
  let dict = bibtex-to-dict(it)
  let dict = add-dict-lang(dict, lang)

  let output_arr = ()
  let bib_element_function = get-element-function(
    bibtex-article-en,
    bibtex-article-ja,
    bibtex-book-en,
    bibtex-book-ja,
    bibtex-booklet-en,
    bibtex-booklet-ja,
    bibtex-inbook-en,
    bibtex-inbook-ja,
    bibtex-incollection-en,
    bibtex-incollection-ja,
    bibtex-inproceedings-en,
    bibtex-inproceedings-ja,
    bibtex-conference-en,
    bibtex-conference-ja,
    bibtex-manual-en,
    bibtex-manual-ja,
    bibtex-mastersthesis-en,
    bibtex-mastersthesis-ja,
    bibtex-misc-en,
    bibtex-misc-ja,
    bibtex-online-en,
    bibtex-online-ja,
    bibtex-phdthesis-en,
    bibtex-phdthesis-ja,
    bibtex-proceedings-en,
    bibtex-proceedings-ja,
    bibtex-techreport-en,
    bibtex-techreport-ja,
    bibtex-unpublished-en,
    bibtex-unpublished-ja,
    dict
  )
  output_arr.push(bibtex-to-bib(year-doubling, dict, bib_element_function))

  let element_cite_list = bibtex-to-cite(
    bib-cite-author,
    bib-cite-year,
    dict
  )
  output_arr.push(element_cite_list)
  output_arr.push(bibtex-yomi(dict, output_arr.at(0)))
  output_arr.push(dict.label)

  return output_arr
}

#let bib-item(it, author: "", year: "", yomi: none, label: none) = {

  let output_arr = ()
  let bib_str = ""
  if type(it) == content or type(it) == str{
    output_arr.push(((it, ),))
    if type(it) == content{
      bib_str = contents-to-str(it)
    }
    else{
      bib_str = it
    }
  }
  else{
    let output_bib = ()
    for v in it{
      output_bib.push((v, ))
    }
    output_arr.push(output_bib)
    bib_str = it.sum()
    if type(bib_str) == content{
      bib_str = contents-to-str(bib_str)
    }
  }

  output_arr.push((author, year))
  if yomi == none{
    output_arr.push(bib_str)
  }
  else{
    output_arr.push(yomi)
  }
  output_arr.push(label)

  return output_arr
}

#let bib-file(
  year-doubling: "",
  bibtex-article-en: (),
  bibtex-article-ja: (),
  bibtex-book-en: (),
  bibtex-book-ja: (),
  bibtex-booklet-en: (),
  bibtex-booklet-ja: (),
  bibtex-inbook-en: (),
  bibtex-inbook-ja: (),
  bibtex-incollection-en: (),
  bibtex-incollection-ja: (),
  bibtex-inproceedings-en: (),
  bibtex-inproceedings-ja: (),
  bibtex-conference-en: (),
  bibtex-conference-ja: (),
  bibtex-manual-en: (),
  bibtex-manual-ja: (),
  bibtex-mastersthesis-en: (),
  bibtex-mastersthesis-ja: (),
  bibtex-misc-en: (),
  bibtex-misc-ja: (),
  bibtex-online-en: (),
  bibtex-online-ja: (),
  bibtex-phdthesis-en: (),
  bibtex-phdthesis-ja: (),
  bibtex-proceedings-en: (),
  bibtex-proceedings-ja: (),
  bibtex-techreport-en: (),
  bibtex-techreport-ja: (),
  bibtex-unpublished-en: (),
  bibtex-unpublished-ja: (),
  bib-cite-author: (),
  bib-cite-year: (),
  file_contents
) = {

  let file_arr = file_contents.split(regex("(^|[^\\\\])@"))
  let output-arr = ()
  for value in file_arr{
    let tmp = value.starts-with("comment")
    if value.starts-with(regex("article|book|booklet|inbook|incollection|inproceedings|conference|manual|mastersthesis|misc|online|phdthesis|proceedings|techreport|unpublished")){
      output-arr.push("@" + value)
    }
  }

  let output-bib = ()

  for value in output-arr{
    output-bib.push(bib-tex(
      year-doubling: year-doubling,
      bibtex-article-en: bibtex-article-en,
      bibtex-article-ja: bibtex-article-ja,
      bibtex-book-en: bibtex-book-en,
      bibtex-book-ja: bibtex-book-ja,
      bibtex-booklet-en: bibtex-booklet-en,
      bibtex-booklet-ja: bibtex-booklet-ja,
      bibtex-inbook-en: bibtex-inbook-en,
      bibtex-inbook-ja: bibtex-inbook-ja,
      bibtex-incollection-en: bibtex-incollection-en,
      bibtex-incollection-ja: bibtex-incollection-ja,
      bibtex-inproceedings-en: bibtex-inproceedings-en,
      bibtex-inproceedings-ja: bibtex-inproceedings-ja,
      bibtex-conference-en: bibtex-conference-en,
      bibtex-conference-ja: bibtex-conference-ja,
      bibtex-manual-en: bibtex-manual-en,
      bibtex-manual-ja: bibtex-manual-ja,
      bibtex-mastersthesis-en: bibtex-mastersthesis-en,
      bibtex-mastersthesis-ja: bibtex-mastersthesis-ja,
      bibtex-misc-en: bibtex-misc-en,
      bibtex-misc-ja: bibtex-misc-ja,
      bibtex-online-en: bibtex-online-en,
      bibtex-online-ja: bibtex-online-ja,
      bibtex-phdthesis-en: bibtex-phdthesis-en,
      bibtex-phdthesis-ja: bibtex-phdthesis-ja,
      bibtex-proceedings-en: bibtex-proceedings-en,
      bibtex-proceedings-ja: bibtex-proceedings-ja,
      bibtex-techreport-en: bibtex-techreport-en,
      bibtex-techreport-ja: bibtex-techreport-ja,
      bibtex-unpublished-en: bibtex-unpublished-en,
      bibtex-unpublished-ja: bibtex-unpublished-ja,
      bib-cite-author: bib-cite-author,
      bib-cite-year: bib-cite-year,
      value)
    )
  }

  return output-bib
}
