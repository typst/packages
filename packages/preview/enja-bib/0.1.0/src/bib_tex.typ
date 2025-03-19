#import "bib_setting_fucntion.typ": *

//---------- 文字列から，最初の{までを取り除く関数 ---------- //
#let remove_brace_l(text, remove_str: "{") = {

  // 出力文字列
  let output_str = ""
  // {で分割
  output_str = text.split(remove_str)
  // 最初の要素を削除
  output_str.remove(0)
  // 最初の{以降を返す
  return output_str.sum()
}

//---------- 文字列から，最後の}までを取り入れる関数 ---------- //
#let remove_brace_r(text, remove_str: "}") = {

  // 出力文字列
  let output_str = ""
  // {で分割
  output_str = text.split(remove_str)
  // 最初の要素のみを返す
  return output_str.at(0)
}

//---------- 文字列の一部から，ラベル名を取得する関数 ---------- //
#let text_to_label(bib_text) = {

  // 出力文字列
  let output_str = ""
  // 出力bool
  let output_bool = true

  if bib_text.contains("{") {//文字列に{が含まれる場合
    // {を削除した文字列を取得
    output_str = remove_brace_l(bib_text)
  }
  else {
    // {が含まれない場合，そのまま代入
    output_str = bib_text
  }

  if output_str.contains(",") {//出力文字列に,が含まれる場合
    // ,で分割し，最初の要素を取得
    output_str = output_str.split(",").at(0)
    // ラベル名を全て取得完了
    output_bool = false
  }

  return (output_str, output_bool)

}

//---------- 文字列の一部から，辞書型に変換する関数 ---------- //

#let text_to_dict(bib_text, contents_num, brace_num) = {

  let name_list = ()//名前のリスト
  let contents = ()//内容のリスト
  let tmp_str = ""//一時保存用
  let num = contents_num//現在の位置
  let num_list = (num,)//位置のリスト

  for value in bib_text{//一文字ずつ取得

    if num == 1{//位置が1のとき
      if value == "=" {//=のとき，名前が全て取得完了
        name_list.push(tmp_str)
        tmp_str = ""
        num = 2//位置を2に変更
        num_list.push(num)
      }
      else{//それ以外のとき，名前を追加
        tmp_str += value
      }
    }
    else if num == 2{//位置が2のとき
      if value == "{"{//{のとき，位置を3に変更
        num = 3
        num_list.push(num)
      }
    }
    else if num == 3{//位置が3のとき
      if value == "}" and brace_num == 1{//}かつ外側の括弧であるとき
        contents.push(tmp_str)
        tmp_str = ""
        num = 4//位置を4に変更
        num_list.push(num)
      }
      else{//それ以外のとき
        if value == "{"{//{のとき，これ以降は括弧の内側となる
          brace_num += 1
        }
        else if value == "}"{//}のとき，これ以降は括弧の外側となる
          brace_num -= 1
        }
        tmp_str += value//文字列の追加
      }
    }
    else if num == 4{//位置が4のとき
      if value == ","{// ,のとき，位置を1に変更
        num = 1
        num_list.push(num)
      }
    }
  }

  if tmp_str != ""{//最後の文字列を追加
    if num == 3{//位置が3のとき，contentsに追加
      contents.push(tmp_str)
    }
    else if num == 1{//位置が1のとき，name_listに追加
      name_list.push(tmp_str)
    }
  }

  return (name_list, contents, num, num_list, brace_num)
}

//---------- 文字列に日本語が含まれるかを判定する関数 ---------- //

#let check_japanese_tex_str(str) = {
  return (regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]") in str)
}

//---------- 文献リストに日本語が含まれるかを判定する関数 ---------- //

#let check_japanese_tex(bibtex) = {

  let bib_arr = bibtex.pairs()

  for value in bib_arr{
    if value.at(0) != "label" {
      let tmp = value.at(1)

      if type(tmp) == array{
        tmp = tmp.sum()
      }

      if type(tmp) == content{
        tmp = contents-to-str(tmp)
      }

      if check_japanese_tex_str(tmp){
        return true
      }
    }
  }
  return false
}

//---------- 文献リストにlang要素を加える関数 ---------- //

#let add_dict_lang(biblist, lang) = {

  let output_list = biblist
  let check_exist_lang = biblist.at("lang", default: "")

  if check_exist_lang != ("en",) and check_exist_lang != ("ja",){

    if lang == auto or lang != "ja" or lang != "en"{
      if check_japanese_tex(biblist){
        output_list.insert("lang", "ja")
      }
      else{
        output_list.insert("lang", "en")
      }
    }
    else{
      output_list.insert("lang", lang)
    }

  }
  else{
    output_list.insert("lang", check_exist_lang.at(0))
  }

  return output_list
}

//---------- bibtexの文字列から辞書型を返す関数 ---------- //

#let bibtex_to_dict(bibtex_raw) = {

  let contents_num = 0
  let remove_bite = 0
  let target_name = ""
  let label_name = ""
  let bibtex_str = bibtex_raw

  if type(bibtex_str) != str{
    bibtex_str = bibtex_str.text
  }

  for value in bibtex_str{

    if contents_num == 0{
      if value == "@"{ contents_num = 1 }
    }
    else if contents_num == 1{
      if value == "{"{
        contents_num = 2
      }
      else{
        target_name += value
      }
    }
    else if contents_num == 2{
      if value == ","{
        remove_bite += value.len()
        break
      }
      else{
        label_name += value
      }
    }
    remove_bite += value.len()
  }

  let bibtex = bibtex_str.slice(remove_bite)

  bibtex = bibtex.replace("\\{", "#text(weight:\"regular\")[{]")
  bibtex = bibtex.replace("\\}", "#text(weight:\"regular\")[}]")

  bibtex = eval(bibtex, mode: "markup")

  // dictionaryの作成
  let biblist = (target : target_name, label : label(label_name))
  let contents_num = 1 //現在の位置
                       // hoge = { hoge } ,
                       //1      2 3      4
  let label_name = "" // ラベル名
  let contents = () // 項目の一時保存
  let contents_list = () // 項目のリスト
  let contents_name = ""
  let brace_num = 1//括弧の数

  for value in bibtex.children{

    if value.has("text"){//テキストの場合

      contents = text_to_dict(value.text, contents_num, brace_num)//辞書型に変換

      for value_num in contents.at(3){//辞書へ順番に代入

        if value_num == 1 and contents.at(0) != (){//1のとき，名前を代入
          contents_name += contents.at(0).remove(0)
        }
        else if value_num == 2{//2のとき，括弧をリセットする
          brace_num = 1
        }
        else if value_num == 3 and contents.at(1) != (){//3のとき，内容を代入
          contents_list.push(contents.at(1).remove(0))
        }
        else if value_num == 4 and contents_name != "" and contents_list != (){//4のとき，項目を辞書に追加
          biblist.insert(lower(contents_name), contents_list)
          contents_name = ""
          contents_list = ()
        }
      }
      // 次の位置へ
      contents_num = contents.at(2)
      brace_num = contents.at(4)
    }
    else if value == smartquote(double: true){//ダブルクォートの場合，{や}と同様にcontents_numを変更
        if contents_num == 2{
          contents_num = 3
        }
        else if contents_num == 3{
          contents_num = 4
        }
    }
    else if contents_num == 3{//括弧の内側の場合，contents_listに追加
      if value.has("dest"){//URLなどは，その中身の文字列を取得
        contents_list.push(value.dest)
      }
      else{//それ以外の場合，そのまま追加
        contents_list.push(value)
      }
    }
  }

  return biblist
}

//---------- 要素の関数を取得 ---------- //
#let get_element_function(
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
  biblist
) = {

  let element_function = none

  if biblist.target == "article"{//articleの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-article-en
    }
    else{//日本語の場合
      element_function = bibtex-article-ja
    }
  }
  else if biblist.target == "book"{//bookの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-book-en
    }
    else{//日本語の場合
      element_function = bibtex-book-ja
    }
  }
  else if biblist.target == "booklet"{//bookletの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-booklet-en
    }
    else{//日本語の場合
      element_function = bibtex-booklet-ja
    }
  }
  else if biblist.target == "inbook"{//inbookの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-inbook-en
    }
    else{//日本語の場合
      element_function = bibtex-inbook-ja
    }
  }
  else if biblist.target == "incollection"{//incollectionの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-incollection-en
    }
    else{//日本語の場合
      element_function = bibtex-incollection-ja
    }
  }
  else if biblist.target == "inproceedings"{//inproceedingsの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-inproceedings-en
    }
    else{//日本語の場合
      element_function = bibtex-inproceedings-ja
    }
  }
  else if biblist.target == "conference"{//inproceedingsの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-conference-en
    }
    else{//日本語の場合
      element_function = bibtex-conference-ja
    }
  }
  else if biblist.target == "manual"{//manualの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-manual-en
    }
    else{//日本語の場合
      element_function = bibtex-manual-ja
    }
  }
  else if biblist.target == "mastersthesis"{//mastersthesisの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-mastersthesis-en
    }
    else{//日本語の場合
      element_function = bibtex-mastersthesis-ja
    }
  }
  else if biblist.target == "misc"{//miscの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-misc-en
    }
    else{//日本語の場合
      element_function = bibtex-misc-ja
    }
  }
  else if biblist.target == "online"{//onlineの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-online-en
    }
    else{//日本語の場合
      element_function = bibtex-online-ja
    }
  }
  else if biblist.target == "phdthesis"{//phdthesisの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-phdthesis-en
    }
    else{//日本語の場合
      element_function = bibtex-phdthesis-ja
    }
  }
  else if biblist.target == "proceedings"{//proceedingsの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-proceedings-en
    }
    else{//日本語の場合
      element_function = bibtex-proceedings-ja
    }
  }
  else if biblist.target == "techreport"{//techreportの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-techreport-en
    }
    else{//日本語の場合
      element_function = bibtex-techreport-ja
    }
  }
  else if biblist.target == "unpublished"{//unpublishedの場合
    if biblist.lang == "en"{//英語の場合
      element_function = bibtex-unpublished-en
    }
    else{//日本語の場合
      element_function = bibtex-unpublished-ja
    }
  }

  return element_function
}

//---------- 文献リストを文献に変換 ---------- //
#let bibtex-to-bib(year-doubling, biblist, element_function) = {

  let output_list_bef = ()//出力リスト(仮)
  let interval_str = ""//要素間の文字列
  let bef_element = ""//前の要素
  let element_num = 0//要素の数
  let element_total_num = 0//全要素数

  for bibitem in element_function{
    let tmp = biblist.at(bibitem.at(0), default: "")
    if tmp != "" and tmp != ("",){//要素が存在する場合
      element_total_num += 1
    }
  }

  for bibitem in element_function{// 各要素に対して処理
    let tmp = biblist.at(bibitem.at(0), default: none)
    if tmp != none and tmp != ("",){// 要素が存在する場合
    element_num += 1

      //条件を満たすとき，前の要素間文字列を新しい文字列に置き換える
      if bibitem.at(1).at(5).contains(bef_element) and bibitem.at(1).at(0) != none{
        interval_str = bibitem.at(1).at(0)
      }
      //先頭に文字列を追加
      interval_str += bibitem.at(1).at(1)
      output_list_bef.push(interval_str)

      //要素を追加
      output_list_bef.push(bibitem.at(1).at(2)(biblist, bibitem.at(0)))

      //要素後に文字列を追加
      if element_num != element_total_num{//最後の要素でないとき
        output_list_bef.push(bibitem.at(1).at(3))
        interval_str = bibitem.at(1).at(4)
      }
      else{//最後の要素のとき
        output_list_bef.push(bibitem.at(1).at(6))
      }

      //前の要素を更新
      bef_element = bibitem.at(0)
    }
  }

  element_num = 0
  let bef_str = false//直前の要素が文字列かどうか
  let contain_str = ""
  let output_list = ()

  for value in output_list_bef{
    if value != ""{
      let outputvalue = value

      if bef_str or type(outputvalue) == str{
        if type(outputvalue) == str{
          contain_str += outputvalue
        }
        else {
          output_list.push(contain_str)
          output_list.push(outputvalue)
          contain_str = ""
        }
      }
      else{
        output_list.push(outputvalue)
      }

      if type(outputvalue) == str{
        bef_str = true
      }
      else{
        bef_str = false
      }
    }

    element_num += 1
  }

  if bef_str{
      output_list.push(contain_str)
      contain_str = ""
  }

  let outputlist = ()
  output_list_bef = ()
  for value in output_list{
    if type(value) == str{
      let tmp = value.split(year-doubling)
      if tmp.len() == 1{
        output_list_bef.push(eval(value, mode: "markup"))
      }
      else{
        output_list_bef.push(eval(tmp.at(0), mode: "markup"))
        outputlist.push(output_list_bef)
        output_list_bef = ()
        output_list_bef.push(eval(tmp.at(1), mode: "markup"))
      }
    }
    else{
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
  biblist
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

  let yomi = ""
  let bib_str = contents-to-str(bib_arr.sum().sum())

  if biblist.at("yomi", default: "") != ""{
    yomi = biblist.at("yomi").sum()
  }
  else{
    yomi = bib_str
  }

  if type(yomi) == content{
    yomi = contents-to-str(yomi)
  }

  yomi = yomi.replace("{", "")
  yomi = yomi.replace("}", "")
  yomi = lower(yomi)

  return yomi
}
