/// Dictionary mapping Jyutping initials to Jyutcitzi part 1 and combine mode
#let initials-dict = (
  a: ("⺍", "-"),
  b: ("比", "-"),
  p: ("并", "|"),
  m: ("文", "-"),
  f: ("夫", "|"),
  d: ("大", "-"),
  t: ("天", "-"),
  n: ("乃", "|"),
  l: ("力", "|"),
  g: ("丩", "|"),
  k: ("臼", "-"),
  h: ("亾", "|"),
  z: ("止", "|"),
  c: ("此", "-"),
  s: ("厶", "-"),
  j: ("央", "-"),
  w: ("禾", "-"),
  gw: ("古", "|"),
  kw: ("夸", "|"),
  ng: (scale([乂乂], x: 50%, reflow: true), "-"),
)

/// Return the Jyutcitzi for syllabic nasal sounds
#let syllabic-nasal-char(jp-initial) = {
  set text(bottom-edge: "descender", top-edge: "ascender")
  let part13 = scale([一], 90%)
  let part22 = scale([乂], 75%)
  let dot-box = box(text(bottom-edge: "descender", top-edge: "bounds")[ˎ])
  let dot-dy = if jp-initial == "m" { -0.2em } else if jp-initial == "ng" { 0.2em }
  let dot-pos = if jp-initial == "m" { bottom + right } else if jp-initial == "ng" { top + right }
  box(baseline: 0.12em)[
    #place(part13, dy: 0.4em)
    #part22
    #place(bottom, part13, dy: -0.3em)
    #place(dot-pos, dy: dot-dy, dot-box)
  ]
}

/// Dictioary mapping Jyutping finals to Jyutcitzi part 2
#let finals-dict = (
  aa: "乍",
  aai: "介",
  aau: "丂",
  aam: "彡",
  aan: "万",
  aang: "生",
  aap: "甲",
  aat: "压",
  aak: "百",
  ai: "兮",
  au: "久",
  am: "令",
  an: "云",
  ang: "亙",
  ap: "十",
  at: "七",
  ak: "仄",
  e: "无",
  ei: "丌",
  eu: "了",
  em: "壬",
  en: "円",
  eng: "正",
  ep: "夹",
  et: "犮",
  ek: "尺",
  i: "子",
  iu: "么",
  im: "欠",
  "in": "千",
  ing: "丁",
  ip: "頁",
  it: "必",
  ik: "夕",
  o: "个",
  oi: "丐",
  ou: "冇",
  on: "干",
  ong: "王",
  ot: "匃",
  ok: "乇",
  u: "乎",
  ui: "会",
  un: "本",
  ung: "工",
  ut: "末",
  uk: "玉",
  oe: "居",
  oeng: "丈",
  oek: "勺",
  eoi: "句",
  eon: "卂",
  eot: "朮",
  yu: "仒",
  yun: "元",
  yut: "乙",
  m: syllabic-nasal-char("m"),
  ng: syllabic-nasal-char("ng"),
)

// Tone map for Jyutcitzi
#let tone-map = (
  "1": "'",
  "2": "ˊ",
  "3": "`",
  "4": "\"",
  "5": "˝",
  "6": "ﾞ",
)
