// -> number/complex/const.typ

#import "init.typ": make-complex

// The imaginary unit $upright(i) = 0 + 1 upright(i)$
#let /*pub*/ i = make-complex(0, 1)

// The negation of imaginary unit $-upright(i) = 0 - 1 upright(i)$.
#let /*pub*/ neg-i = make-complex(0, -1)

// The complex zero value $0 = 0 + 0 upright(i)$
#let /*pub*/ zero = make-complex(0, 0)

// The complex one value $1 = 1 + 0 upright(i)$
#let /*pub*/ one = make-complex(1, 0)

// The complex negative one value $-1 = -1 + 0 upright(i)$
#let /*pub*/ neg-one = make-complex(-1, 0)

// the 3#super[rd] unit root $omega = - 1/2 + sqrt(3)/2 upright(i)$
#let /*pub*/ omega = make-complex(-0.5, 0.5 * calc.sqrt(3))

// square (or conjugate) of the 3#super[rd] unit root $macron(omega) = - 1/2 - sqrt(3)/2 upright(i)$
#let /*pub*/ omega-2 = make-complex(-0.5, -0.5 * calc.sqrt(3))

#let /*pub*/ nan = make-complex(float.nan, float.nan)