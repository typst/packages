#import "@preview/zebraw:0.6.1": *

// --------------------------------
// Figureラッパー
// --------------------------------

// 画像用
#let fimg(
  path,
  caption: none,
  label: none,
  width: 100%,
  placement: bottom,
) = {
  [
    #figure(
      image(path, width: width),
      caption: caption,
      placement: placement,
    ) #label
  ]
}

// コードブロック
#let fcode(
  code,
  caption: none,
  label: none,
  placement: bottom,
) = {
  [
    #figure(
      block(
        align(left, code),
        breakable: true,
        stroke: 0.7pt,
        inset: 0.3em,
        width: 99%,
      ),
      caption: caption,
      kind: "src",
      placement: placement,
      supplement: "ソースコード",
    ) #label
  ]
}

// txtブロック
#let ftext(
  txt,
  caption: none,
  label: none,
  placement: bottom,
) = {
  show: zebraw.with(background-color: white, lang: false, numbering: false)
  [
    #figure(
      block(
        align(left, txt),
        breakable: true,
        stroke: 0.7pt,
        inset: 0.5em,
        width: 99%,
        radius: 0.5em,
      ),
      caption: caption,
      kind: "txt",
      placement: placement,
      supplement: "テキスト",
    ) #label
  ]
}
