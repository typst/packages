#set document(date: none)
#set text(
  font: ("Liberation Sans", "Noto Sans CJK JP")
) // Optional

#import "@preview/rubby:0.10.2": get-ruby
#let ruby = get-ruby()

```typst
#let ruby = get-ruby() // (1) Adds missing delimiter around every content/string
// or
#let ruby = get-ruby(auto-spacing: false) // (2) Logic from original project
```

#ruby[ふりがな][振り仮名]

#ruby[とう|きょう|こう|ぎょう|だい|がく][東|京|工|業|大|学]

#ruby[とうきょうこうぎょうだいがく][東京工業大学]

Next 2 lines look the same with (1) (default):

#let ruby = get-ruby()

#ruby[|きょうりょく|][|協力|]

#ruby[きょうりょく][協力]

But lines are being typeset differently if (2) is used:

#let ruby = get-ruby(auto-spacing: false)

#ruby[|きょうりょく|][|協力|]

#ruby[きょうりょく][協力] // Page boundaries are not honored

First 3 lines out of 4 look the same way with (1):

#let ruby = get-ruby()

#ruby[きゅう][九]#ruby[じゅう][十]

#ruby[きゅう|][九|]#ruby[|じゅう][|十]

#ruby[きゅう|じゅう][九|十]

#ruby[きゅうじゅう][九十]

Only 2nd and 3rd lines look the same way with (2):

#let ruby = get-ruby(auto-spacing: false)

#ruby[きゅう][九]#ruby[じゅう][十]

#ruby[きゅう|][九|]#ruby[|じゅう][|十]

#ruby[きゅう|じゅう][九|十]

#ruby[きゅうじゅう][九十]
