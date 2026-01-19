#import "@preview/tasks:0.2.0": tasks

#set page(width: 12cm, height: auto, margin: 1cm)

= Label Formats

Lowercase letters:
#tasks(columns: 3, label: "a)")[+ One + Two + Three]

Uppercase letters:
#tasks(columns: 3, label: "A)")[+ One + Two + Three]

Numbers:
#tasks(columns: 3, label: "1)")[+ One + Two + Three]

Roman numerals:
#tasks(columns: 3, label: "i)")[+ One + Two + Three]

Bullets:
#tasks(columns: 3, label: "*")[+ One + Two + Three]

Custom:
#tasks(columns: 3, label: n => "Q" + str(n) + ":")[+ One + Two + Three]
