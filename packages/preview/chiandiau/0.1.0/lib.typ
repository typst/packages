/* Raw utils */

#import "util.typ": cd, to-pairs, to-sandhi-pairs, tone


/* Schemes */

#import "cmn.typ": cmn-cyuc-sicuan, cmn-pinyin, cmn-xghu-tongyong
#import "nan.typ": nan-tailo
#import "wuu/wuu.typ": wuu-wugniu
#import "yue.typ": yue-jyutping

#let easy-split(function, c, splitter: "|", splitter-regex: none, ..attrs) = {
  if splitter-regex == none {
    splitter-regex = splitter
  }
  show regex("(.+)" + splitter-regex + "(.+)"): it => yue-jyutping(
    ..it.text.split(splitter).map(t => t.trim()),
    width: 1.2em,
  )
  c
}
