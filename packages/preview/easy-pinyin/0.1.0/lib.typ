#let pinyin(doc) = {
  show "a": [ɑ];
  show "a1": [ɑ̄];
  show "a2": [ɑ́];
  show "a3": [ɑ̌];
  show "a4": [ɑ̀];

  show "e1": [ē];
  show "e2": [é];
  show "e3": [ě];
  show "e4": [è];

  show "i1": [ī];
  show "i2": [í];
  show "i3": [ǐ];
  show "i4": [ì];

  show "o1": [ō];
  show "o2": [ó];
  show "o3": [ǒ];
  show "o4": [ò];

  show "u1": [ū];
  show "u2": [ú];
  show "u3": [ǔ];
  show "u4": [ù];

  show "v": [ü];
  show "v1": [ǖ];
  show "v2": [ǘ];
  show "v3": [ǚ];
  show "v4": [ǜ];

  doc
}

#let zhuyin(doc, ruby, scale: 0.7, gutter: 0.3em, delimiter: none, spacing: none) = {
  if delimiter == none {
   return box(align(
      bottom,
      table(
        columns: (auto, ),
        align: (center, ),
        inset: 0pt,
        stroke: none,
        row-gutter: gutter,
        text(1em * scale, pinyin(ruby)), 
        doc,
      ),
    ));
  }

  let extract-text(thing) = if type(thing) == "string" { thing } else { thing.text };
  let chars = extract-text(doc).split(delimiter);
  let aboves = extract-text(ruby).split(delimiter);

  if chars.len() != aboves.len() {
    error("count of character and zhuyin is different")
  }

  chars.zip(aboves).map(((c, above)) => [#zhuyin(scale: scale)[#c][#above]]).join(if spacing != none [#h(spacing)])
}

/*

#set text(
   lang: "zh", region: "cn",
   font: ("LXGW WenKai", ),
   fallback: false,
)

汉（#pinyin[ha4n]）语（#pinyin[yu3]）拼（#pinyin[pi1n]）音（#pinyin[yi1n]）。

#let per-char(f) = [#f(delimiter: "|")[汉|语|拼|音][ha4n|yu3|pi1n|yi1n]]
#let per-word(f) = [#f(delimiter: "|")[汉语|拼音][ha4nyu3|pi1nyi1n]]
#let all-in-one(f) = [#f[汉语拼音][ha4nyu3pi1nyi1n]]
#let example(f) = (per-char(f), per-word(f), all-in-one(f))

// argument of scale and spacing
#let arguments = ((0.5, none), (0.7, none), (0.7, 0.1em), (1.0, none), (1.0, 0.2em))

#table(
  columns: (auto, auto, auto, auto),
  align: (center + horizon, center, center, center),
  [arguments], [per char], [per word], [all in one],
  ..arguments.map(((scale, spacing)) => (
    text(size: 0.7em)[#scale,#repr(spacing)], 
    ..example(zhuyin.with(scale: scale, spacing: spacing))
  )).flatten(),
)

// */
