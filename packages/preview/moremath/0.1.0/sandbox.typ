#import "./moremath.typ": *

#let AUC = math.op("AUC")

$
  AUC(h, y)
  &<= hat(AUC)_theta (h, y) + 4/theta zeta(hh) + sqrt((log 1\/delta)/(min {n_0, n_1})) \
  &= hat(AUC) (h - theta y, y) + 4/theta zeta(hh) + sqrt((log 1\/delta)/(min {n_0, n_1})), \
$

Where

$ zeta(hh) = rr_(0,min {n_0,n_1}) (hh) + rr_(1,min {n_0,n_1}) (hh) $

#repeat[.]

$
  ((x - y) - (y - z)) \
  bigp((x - y) - (y - z)) \
  big(((x - y) - (y - z))) \
$

#repeat[.]

$ x^2 argmin $

$ f : xx -> yy $

$
  X &indep Y \
  X &nindep Y \
$
