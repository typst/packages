import sat / satvars {.all.}
import std / random

proc containsInvalidB(x: uint64): bool =
  var x = x
  while x != 0'u64:
    if (x and 0b1111_1111) == 0b0000_0000: x = x shr 8
    if (x and 0b1111) == 0b0000: x = x shr 4

    if (x and Mask) == IsInvalid: return true
    x = x shr 2

var b = createSolution(900)
b.setVar VarId(899), SetToTrue
echo getVar(b, VarId(1))

var b2 = createSolution(900)
b2.setVar VarId(899), SetToFalse

combine(b, b2)

echo b.invalid

template test(val) =
  assert containsInvalid(val) == containsInvalidB(val), $val

test 0'u64
test high(uint64)

for i in 0 ..< 100_000:
  test i.uint64
  var r = rand[uint64](0'u64..high(uint64))
  test r