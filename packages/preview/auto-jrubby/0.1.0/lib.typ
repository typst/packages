#let plugin = plugin("auto_jrubby.wasm")
#import "@preview/rubby:0.10.2": get-ruby

#let tokenize(input-text) = {
  let params = (text: input-text)
  let result-bytes = plugin.analyze(bytes(json.encode(params)))
  let result-str = str(result-bytes)
  if result-str.starts-with("Error:") { panic(result-str) }
  json(result-bytes)
}

#let show-analysis-table(input-text) = {
  let tokens = tokenize(input-text)
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

#let show-ruby(input-text, size: 0.5em, ruby-func: auto) = {
  let tokens = tokenize(input-text)
  
  let cmd = if ruby-func == auto {
    get-ruby(size: size)
  } else {
    ruby-func
  }

  par(leading: 1.5em)[
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