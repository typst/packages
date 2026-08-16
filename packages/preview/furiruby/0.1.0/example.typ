#import "@preview/furiruby:0.1.0": (ruby, rb, rt)

#let sans = ("Noto Sans KR", "Noto Sans CJK KR", "Noto Sans JP", "Noto Sans CJK JP")
#let serif = ("Noto Serif KR", "Noto Serif CJK KR", "Noto Serif JP", "Noto Serif CJK JP")
#let mono = ("Noto Sans Mono", "D2Coding", "MonoplexKR")

#set text(font: serif, size: 10pt)

#counter(page).update(1)

#set page(
  margin: (
    top: 15mm,
    bottom: 15mm,
    left: 15mm,
    right: 15mm,
  ),
  numbering: "1",
  header: [
    #text(size: .7em, fill: gray)[#columns(2)[
      #align(left)[伊勢物語]
      #colbreak()
      #align(right)[二三段・筒井筒]
    ]
  ]],
  columns: 2
)

#show heading.where(
  level: 1
): it => block(width: 100%)[
  #set align(center)
  #text(weight: "regular", size: 2em)[
    #it.body
  ]
]
#show heading.where(level: 2): set text(size: 1.5em, weight: "semibold")
#show heading.where(level: 3): set text(size: 1.3em, weight: "regular")


#place(
  top,
  float: true,
  scope: "parent",
  clearance: 30pt,
)[
  = 筒井筒
  
  #align(center)[#text(size: 1.5em)[
    《伊勢物語》二三段
  ]]
]

#let ruby = ruby.with(layout: (
  inline-mode: "float",
))

== 【一】

昔、#rt[ゐなか][田舎]わたら#rb[イ][ひ]しける人の子ども、#rt[ゐ][井]のもとに出でて遊びけるを、#rt[おとな][大人]になりにければ、男も女も恥ぢか#rb[ワ][は]してありけれど、男は、この女をこそ#rt[え][得]めと思#rb[ウ][ふ]。女はこの男をと思#rb[イ][ひ]つつ、親のあ#rb[ワ][は]すれども聞かでな#rb[ン][む]ありける。さて、この#rt[となり][隣]の男のもとより、かくな#rb[ン][む]、

#quote(block: true)[#rt[つつゐづつ][筒井筒]井筒にかけしまろがたけ過ぎにけらしな#rt[いも][妹]見ざるまに]

女、返し、

#quote(block: true)[くらべ#rt[こ][来]しふり#rt[わ][分]け髪も肩すぎぬ君ならずして#rt[たれ][誰]かあぐべき]

など言#rb[イ][ひ]言#rb[イ][ひ]て、つ#rb[イ][ひ]に#rt[ほ][本]#rt[い][意]のごとくあ#rb[イ][ひ]にけり。

\

== 【二】

さて、年ごろ#rt[ふ][経]るほどに、女、親なく、#rt[たよ][頼]なりなくなるままに、もろともにい#rb[ウ][ふ]か#rb[イ][ひ]なくてあら#rb[ン][む]や#rb[ワ][は]とて、#ruby(t: [かふち], b: [カウチ])[河内]の国、#rt[たかやす][高安]の#ruby(t: [こほり], b: [コオリ])[郡]に#rt[い][行]きかよ#rb[ウ][ふ]所#rt[い][出]で#rt[き][来]にけり。さりけれど、このもとの女、#rt[あ][悪]しと思#rb[エ][へ]るけしきもなくて出だしやりければ、男、#rt[ことごころ][異心]ありてかかるにやあら#rb[ン][む]と思#rb[イ][ひ]疑#rb[イ][ひ]て、#rt[せんざい][前栽]の中に隠れて、河内へ#rt[い][往]ぬる#ruby(t: [かほ], b: [カオ])[顔]にて見れば、この女いとようけ#rb[ソ][さ]うじて、うちながめて、

#quote(block: true)[風吹けば#rt[おき][沖]つ白波たつた山#rt[よ][夜]#ruby(t: [は], b: [ワ])[半]にや君がひとり越ゆら#rb[ン][む]]

とよみけるを聞きて、限りなくかなしと思#rb[イ][ひ]て、河内へも#rt[い][行]かずなりにけり。

#colbreak()

== 【三】

まれまれの#rt[たかやす][高安]に来てみれば、はじめこそ心にくくもつくりけれ、今はうちとけて、手づから#ruby(t: [いひ], b: [イイ])[飯]が#rb[イ][ひ]取りて、#rt[け][筒]#rt[こ][子]のうつ#rb[ワ][は]ものに#rt[も][盛]りけるを見て、心#rt[う][憂]がりて#rt[い][行]かずなりにけり。さりければ、かの女、大和の#rt[かた][方]を見やりて、

#quote(block: true)[君があたり見つつを#rt[を][居]ら#rb[ン][む]#rt[い][生]#rt[こま][駒]山雲なかくしそ雨はふるとも]

と言#rb[イ][ひ]て見#rt[イ][出]すに、か#rb[ロ][ら]うじて#rt[やまとひと][大和人]、「#rt[こ][来]#rb[ン][む]」と言#rb[エ][へ]り。喜びて待つに、たびたび過ぎぬれば、

#quote(block: true)[君#rt[こ][来]#rb[ン][む]と言#rb[イ][ひ]し夜ごとに過ぎぬれば頼まぬものの恋#rb[イ][ひ]つつぞ#rt[ふ][経]る]

と言#rb[イ][ひ]けれど、男住まずなりにけり。
