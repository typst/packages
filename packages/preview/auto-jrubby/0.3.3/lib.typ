#import "@preview/rubby:0.10.2": get-ruby

#let csv-array-to-string(data, delimiter: ",") = {
  data.map(row => row.join(delimiter)).join("\n")
}

#let tokenize(input-text, user-dict: none, dict: "ipadic") = {
  if dict not in ("ipadic", "unidic") {
    panic("dict must be one of: ipadic, unidic")
  }

  let plugin = plugin(dict.replace("-", "_") + ".wasm")

  let user-dict-csv = if user-dict != none {
    if type(user-dict) == str {
      user-dict
    } else if type(user-dict) == array {
      csv-array-to-string(user-dict)
    } else {
      panic("user-dict must be a string or array")
    }
  } else {
    none
  }
  
  let params = if user-dict-csv != none {
    (text: input-text, user_dict_csv: user-dict-csv)
  } else {
    (text: input-text)
  }
  
  let result-bytes = plugin.analyze(bytes(json.encode(params)))
  let result-str = str(result-bytes)
  if result-str.starts-with("Error:") { panic(result-str) }
  json(result-bytes)
}

#let show-analysis-table(input-text, user-dict: none, dict: "ipadic") = {
  let tokens = tokenize(input-text, user-dict: user-dict, dict: dict)
  let get-safe(arr, idx) = {
    if idx < arr.len() { arr.at(idx) } else { "*" }
  }

  if dict == "ipadic" {
    table(
      columns: (auto,) * 10,
      inset: 5pt,
      align: (left,) + (center,) * 9,
      fill: (_, row) => if calc.odd(row) { luma(240) } else { white },
      table.header(
        text(size: 1em)[*表層形*], 
        text(size: 1em)[*品詞*], 
        text(size: 1em)[*品詞細1*], 
        text(size: 1em)[*品詞細2*], 
        text(size: 1em)[*品詞細3*], 
        text(size: 1em)[*活用形*], 
        text(size: 1em)[*活用型*], 
        text(size: 1em)[*原形*], 
        text(size: 1em)[*読み*], 
        text(size: 1em)[*発音*]
      ),
      ..tokens.map(t => (
        t.surface,
        text(size: 0.9em, get-safe(t.details, 0)),
        text(size: 0.9em, get-safe(t.details, 1)),
        text(size: 0.9em, get-safe(t.details, 2)),
        text(size: 0.9em, get-safe(t.details, 3)),
        text(size: 0.9em, get-safe(t.details, 4)),
        text(size: 0.9em, get-safe(t.details, 5)),
        text(size: 0.9em, get-safe(t.details, 6)),
        text(size: 0.9em, get-safe(t.details, 7)),
        text(size: 0.9em, get-safe(t.details, 8))
      )).flatten()
    )
  } else if dict == "unidic" {
    // UniDic: Surface + 17 Details = 18 Columns
    table(
      columns: (auto,) * 18,
      inset: 3pt,
      align: (left,) + (center,) * 17,
      fill: (_, row) => if calc.odd(row) { luma(240) } else { white },
      table.header(
        text(size: 0.7em)[*表層形*], 
        text(size: 0.7em)[*品詞大*], text(size: 0.7em)[*品詞中*], text(size: 0.7em)[*品詞小*], text(size: 0.7em)[*品詞細*], 
        text(size: 0.7em)[*活用型*], text(size: 0.7em)[*活用形*], 
        text(size: 0.7em)[*読み*], text(size: 0.7em)[*語彙素*], 
        text(size: 0.7em)[*書字出*], text(size: 0.7em)[*発音出*], text(size: 0.7em)[*書字基*], text(size: 0.7em)[*発音基*], 
        text(size: 0.7em)[*語種*], 
        text(size: 0.7em)[*頭変型*], text(size: 0.7em)[*頭変形*], text(size: 0.7em)[*末変型*], text(size: 0.7em)[*末変形*]
      ),
      ..tokens.map(t => (
        text(size: 0.6em, t.surface),
        // UniDic Details (0-16 in array, corresponding to 4-20 in CSV)
        text(size: 0.6em, get-safe(t.details, 0)), // 品詞大分類
        text(size: 0.6em, get-safe(t.details, 1)), // 品詞中分類
        text(size: 0.6em, get-safe(t.details, 2)), // 品詞小分類
        text(size: 0.6em, get-safe(t.details, 3)), // 品詞細分類
        text(size: 0.6em, get-safe(t.details, 4)), // 活用型
        text(size: 0.6em, get-safe(t.details, 5)), // 活用形
        text(size: 0.6em, get-safe(t.details, 6)), // 語彙素読み
        text(size: 0.6em, get-safe(t.details, 7)), // 語彙素
        text(size: 0.6em, get-safe(t.details, 8)), // 書字形出現形
        text(size: 0.6em, get-safe(t.details, 9)), // 発音形出現形
        text(size: 0.6em, get-safe(t.details, 10)), // 書字形基本形
        text(size: 0.6em, get-safe(t.details, 11)), // 発音形基本形
        text(size: 0.6em, get-safe(t.details, 12)), // 語種
        text(size: 0.6em, get-safe(t.details, 13)), // 語頭変化型
        text(size: 0.6em, get-safe(t.details, 14)), // 語頭変化形
        text(size: 0.6em, get-safe(t.details, 15)), // 語末変化型
        text(size: 0.6em, get-safe(t.details, 16))  // 語末変化形
      )).flatten()
    )
  }
}

#let show-ruby(input-text, size: 0.5em, leading: 1.5em, ruby-func: auto, user-dict: none, dict: "ipadic") = {
  let tokens = tokenize(input-text, user-dict: user-dict, dict: dict)
  
  let cmd = if ruby-func == auto {
    get-ruby(size: size)
  } else {
    ruby-func
  }

  par(leading: leading)[
    #for t in tokens {
      for seg in t.ruby_segments {
        if seg.ruby == "" {
          seg.text
        } else {
          cmd(seg.ruby, seg.text)
        }
      }
    }
  ]
}