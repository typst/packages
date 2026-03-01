#import "../lib.typ": jyutcitzi, combine-parts, initials-dict, finals-dict

#set page(width: auto, height: auto, margin: 10pt)
#set text(font: "Noto Sans CJK TC")

= Jyutcitzi Smoke Test

// Test various split modes
- Syllabic nasal sound: #jyutcitzi("ng")
- Horizontal: #jyutcitzi("pin")
- Vertical: #jyutcitzi("di") 
- Null initial: #jyutcitzi("aa")
- Null final: #jyutcitzi("s")
- Compound initial:
  #combine-parts(
    combine-parts(initials-dict.s.at(0), initials-dict.k.at(0), "-"),
    "頁",
    "|"
  )
- Jyutcitzi with tone: #jyutcitzi("seng2")

// Test a multi-line space-delimited string containing jyutping
#jyutcitzi("混合 jyut\tping faat3\ncit zi 輸入， zung3 zi1 wun4 sing1 dyu6 。")
