// -> number/rational/const.typ

#import "init.typ": make-rational

#let /*pub*/ inf = make-rational(true, 1, 0)
#let /*pub*/ neg-inf = make-rational(false, 1, 0)
#let /*pub*/ nan = make-rational(true, 0, 0)
#let /*pub*/ zero = make-rational(true, 0, 1)
#let /*pub*/ neg-zero = make-rational(false, 0, 1)
#let /*pub*/ one = make-rational(true, 1, 1)
#let /*pub*/ neg-one = make-rational(false, 1, 1)