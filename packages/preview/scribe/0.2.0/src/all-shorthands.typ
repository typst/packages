#import "utils.typ": *

#let operations = (
  ($***$, $star.op$),
  ($**$, $ast.basic$),
  ($*$, $dot.op$),
  ($\\$, $without$),
  ($-:$, $div$),
  ($|><|$, $join$),
  ($|><$, $times.l$),
  ($><|$, $times.r$),
  ($@$, $compose$),
  ($o+$, $plus.circle$),
  ($o.$, $dot.circle$),
)

#let miscellaneous = (
  ($+-$, $plus.minus$),
  ($:.$, $therefore$),
  ($:'$, $because$),
  ($|~$, $ceil.l$),
  ($~|$, $ceil.r$),
  ($..$, $quad$),
)

#let relations = (
  ($-<=$, $prec.eq$),
  ($-<$, $prec$),
  ($>-=$, $succ.eq$),
  ($>-$, $succ$),
  ($-=$, $equiv$),
  ($~=$, $tilde.equiv$),
  ($~~$, $approx$),
)

#let logicals = (
  ($|--$, $tack.r$),
  ($|==$, $tack.r.double$),
)

#let grouping-brackets = (
  ($(:$, $angle.l$),
  ($:)$, $angle.r$),
  ($<<$, $angle.l$),
  ($>>$, $angle.r$),
)

#let caligraphics = ()
