#import "../funarray.typ": *

#let arrs = range(7).map(i => range(i))

#range(1, 4).map(i => arrs.map(a => chunks(a, i)))

#unzip(())

#cycle(("A",), 4)

#range(1, 4).map(i => arrs.map(a => windows(a, i)))

#funarray-unsafe.windows(arrs.at(6), 2)

#range(1, 4).map(i => arrs.map(a => partition(a, n => calc.rem(n, i) == 0)))

#range(1, 4).map(i => arrs.map(a => group-by(a, n => calc.rem(n, i) == 0)))

#arrs.map(a => take-while(a, x => x < 3))

#arrs.map(a => skip-while(a, x => x < 3))

#arrs.map(a => accumulate(a, 0, (acc, x) => acc / 2 + x))

#arrs.map(a => scan(a, 1, (acc, x) => (acc / 2, acc + x)))

#range(7).map(a => unfold(1, acc => (1 + 0.1*acc, acc), a))

#range(7).map(a => iterated(0, x => 2*x + 1, a))