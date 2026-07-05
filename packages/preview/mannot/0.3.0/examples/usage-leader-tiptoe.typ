#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (left: 1cm, top: 0.5cm, bottom: 1.2cm), fill: white)
#set text(16pt)

$
  markhl(x, tag: #<1>)

  #annot(
    <1>,
    pos: bottom + right, dy: 1em,
    leader-tip: tiptoe.circle,
    leader-toe: tiptoe.stealth.with(length: 1000%),
  )[annotaiton]
$
