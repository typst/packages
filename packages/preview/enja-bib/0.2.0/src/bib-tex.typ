#import "bib-setting-function.typ": *
#import "bib-yomi.typ": *
#import "@preview/citegeist:0.3.1": load-bibliography

//---------- 文字列に日本語が含まれるかを判定する関数 ---------- //

#let check-japanese-tex-str(str) = {
  return (regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]") in str)
}

//---------- 文献リストに日本語が含まれるかを判定する関数 ---------- //

#let check-japanese-tex(bibtex) = {
  return bibtex.values().any(val => check-japanese-tex-str(val))
}

//---------- 文献リストにlang要素を加える関数 ---------- //

#let add-dict-lang(biblist, lang) = {
  let output_list = biblist.fields
  let current_lang = output_list.at("lang", default: "")

  if current_lang != "en" and current_lang != "ja" {
    if lang == auto or (lang != "ja" and lang != "en") {
      if check-japanese-tex(biblist.fields) {
        output_list.insert("lang", "ja")
      } else {
        output_list.insert("lang", "en")
      }
    } else {
      output_list.insert("lang", lang)
    }
  }

  biblist.insert("fields", output_list)
  return biblist
}

//---------- 要素の関数を取得 ---------- //
#let get-element-function(style, biblist) = {
  return style.entry.at(biblist.entry_type, default: none).at(biblist.fields.lang, default: none)
}

//---------- 文献リストを文献に変換 ---------- //
#let bibtex-to-bib(year-doubling, biblist, element_function) = {
  let output_list_bef = () //出力リスト(仮)
  let interval_str = "" //要素間の文字列
  let bef_element = "" //前の要素
  let element_num = 0 //要素の数
  let element_total_num = 0 //全要素数

  for bibitem in element_function {
    let tmp = biblist.fields.at(bibitem.at(0), default: "")
    if tmp != "" {
      //要素が存在する場合
      element_total_num += 1
    }
  }

  for bibitem in element_function {
    // 各要素に対して処理
    let tmp = biblist.fields.at(bibitem.at(0), default: none)
    if tmp != none and tmp != "" {
      // 要素が存在する場合
      element_num += 1

      //条件を満たすとき，前の要素間文字列を新しい文字列に置き換える
      if bibitem.at(1).at(5).contains(bef_element) and bibitem.at(1).at(0) != none {
        interval_str = bibitem.at(1).at(0)
      }
      //先頭に文字列を追加
      interval_str += bibitem.at(1).at(1)
      output_list_bef.push(interval_str)

      //要素を追加
      output_list_bef.push(bibitem.at(1).at(2)(biblist, bibitem.at(0)))

      //要素後に文字列を追加
      if element_num != element_total_num {
        //最後の要素でないとき
        output_list_bef.push(bibitem.at(1).at(3))
        interval_str = bibitem.at(1).at(4)
      } else {
        //最後の要素のとき
        output_list_bef.push(bibitem.at(1).at(6))
      }

      //前の要素を更新
      bef_element = bibitem.at(0)
    }
  }

  element_num = 0
  let bef_str = false //直前の要素が文字列かどうか
  let contain_str = ""
  let output_list = ()

  for value in output_list_bef {
    if value != "" {
      let outputvalue = value

      if bef_str or type(outputvalue) == str {
        if type(outputvalue) == str {
          contain_str += outputvalue
        } else {
          output_list.push(contain_str)
          output_list.push(outputvalue)
          contain_str = ""
        }
      } else {
        output_list.push(outputvalue)
      }

      if type(outputvalue) == str {
        bef_str = true
      } else {
        bef_str = false
      }
    }

    element_num += 1
  }

  if bef_str {
    output_list.push(contain_str)
    contain_str = ""
  }

  let outputlist = ()
  output_list_bef = ()
  for value in output_list {
    if type(value) == str {
      let tmp = value.split(year-doubling)
      if tmp.len() == 1 {
        output_list_bef.push(eval(value, mode: "markup"))
      } else {
        output_list_bef.push(eval(tmp.at(0), mode: "markup"))
        outputlist.push(output_list_bef)
        output_list_bef = ()
        output_list_bef.push(eval(tmp.at(1), mode: "markup"))
      }
    } else {
      output_list_bef.push(value)
    }
  }
  outputlist.push(output_list_bef)

  return outputlist
}

//---------- citeを作成する関数 ---------- //
#let bibtex-to-cite(
  bib-cite-author,
  bib-cite-year,
  biblist,
) = {
  let cite_list = ()

  //citet
  cite_list.push(bib-cite-author(biblist, "author"))
  //citep
  cite_list.push(bib-cite-year(biblist, "year"))

  return cite_list
}

//---------- 並び替えのための読み仮名 ---------- //
#let bibtex-yomi(biblist, bib_arr) = {
  let bib_str = contents-to-str(bib_arr.sum().sum())
  let yomi = biblist.fields.at("yomi", default: "")
  if yomi == "" {
    yomi = auto-make-yomi(biblist, bib_str)
  }

  if type(yomi) == content {
    yomi = contents-to-str(yomi)
  }

  if check-japanese-tex-str(yomi){
    yomi = romaji(yomi)
  }

  yomi = yomi.replace("{", "")
  yomi = yomi.replace("}", "")
  yomi = lower(yomi)

  return yomi
}
