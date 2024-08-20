#import "lib.typ": *

#set page(height: auto, width: auto, fill: white)

= Natural and consistent matrix --- #smallcaps[Natrix]

Switch your *#underline(`mat`)* to *#underline(`nat`)* and you will get a natural and consistent matrix.

```typ
#import "@preview/natrix:0.1.0": *

$
bnat(a,b;c,d) bnat(x;y)
= x bnat(a;c) + y bnat(b;d)
= bnat(a x + b y; c x + d y)
$
```

== With #smallcaps[Natrix]'s *#underline(`nat`)*
$
bnat(a,b;c,d) bnat(x;y)
= x bnat(a;c) + y bnat(b;d)
= bnat(a x+b y;c x+d y)
$

== With original *#underline(`mat`)*

#[
#set math.mat(delim: "[")
$
mat(a,b;c,d) mat(x;y)
= x mat(a;c) + y mat(b;d)
= mat(a x+b y;c x+d y)
$
]
