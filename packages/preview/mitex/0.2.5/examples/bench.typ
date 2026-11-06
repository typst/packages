#import "../lib.typ": *

#set page(width: 500pt)

#assert.eq(mitex-convert("\alpha x"), "alpha  x ")

Write inline equations like #mi("x") or #mi[y].

Also block equations:

#mitex("\alpha x" * 8000)

/*
last^1
17000
Benchmark 1: typst compile --root . packages\mitex\examples\bench.typ
  Time (mean ± σ):     323.1 ms ±  18.0 ms    [User: 84.4 ms, System: 14.1 ms]
  Range (min … max):   302.1 ms … 353.9 ms    10 runs
8000
Benchmark 1: typst compile --root . packages\mitex\examples\bench.typ
  Time (mean ± σ):     198.3 ms ±   6.5 ms    [User: 50.2 ms, System: 24.6 ms]
  Range (min … max):   188.5 ms … 207.1 ms    14 runs

last^2
17000
Benchmark 1: typst compile --root . packages\mitex\examples\bench.typ
  Time (mean ± σ):     638.8 ms ±  10.4 ms    [User: 143.8 ms, System: 32.8 ms]
  Range (min … max):   616.5 ms … 652.5 ms    10 runs
8000
Benchmark 1: typst compile --root . packages\mitex\examples\bench.typ
  Time (mean ± σ):     503.2 ms ±  15.1 ms    [User: 109.4 ms, System: 28.1 ms]
  Range (min … max):   485.8 ms … 535.5 ms    10 runs

init
17000
Benchmark 1: typst compile --root . typst-package\examples\bench.typ
  Time (mean ± σ):     972.4 ms ±  28.3 ms    [User: 223.4 ms, System: 62.2 ms]
  Range (min … max):   938.4 ms … 1029.7 ms    10 runs
8000
Benchmark 1: typst compile --root . typst-package\examples\bench.typ
  Time (mean ± σ):     687.6 ms ±  20.6 ms    [User: 154.4 ms, System: 24.8 ms]
  Range (min … max):   668.2 ms … 731.7 ms    10 runs

*/
