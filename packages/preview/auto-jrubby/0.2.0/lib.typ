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
  table(
    columns: (auto, auto, auto, auto, auto),
    inset: 8pt,
    align: (left, center, center, center, left),
    fill: (_, row) => if calc.odd(row) { luma(240) } else { white },
    table.header([*表層形*], [*品詞*], [*詳細*], [*読み*], [*基本形*]),
    ..tokens.map(t => (
      t.surface, t.pos, t.sub_pos, text(size: 0.8em, t.reading), t.base
    )).flatten()
  )
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