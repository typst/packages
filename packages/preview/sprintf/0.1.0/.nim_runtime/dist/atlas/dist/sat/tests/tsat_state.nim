import std/unittest
import sat/[sat, satvars]

const StateLeakFormulaText = "(&(1>=v0) (1==v1) (|(~v1) v0))"

proc buildStateLeakFormula(): Formular =
  ## This formula is satisfiable with v0=true, v1=true.
  ## It previously triggered a false UNSAT in the fast solver due to
  ## branch-state leakage between false/true guesses.

  var b: Builder
  b.openOpr(AndForm)

  b.openOpr(ZeroOrOneOfForm)
  b.add(VarId(0))
  b.closeOpr()

  b.openOpr(ExactlyOneOfForm)
  b.add(VarId(1))
  b.closeOpr()

  b.openOpr(OrForm)
  b.addNegated(VarId(1))
  b.add(VarId(0))
  b.closeOpr()

  b.closeOpr()
  result = toForm(b)

suite "sat solver state isolation":
  test "fast solver keeps guess branches isolated":
    let f = buildStateLeakFormula()
    check $f == StateLeakFormulaText

    var fast = createSolution(maxVariable(f))
    let fastSat = satisfiable(f, fast)

    var slow = createSolution(maxVariable(f))
    let slowSat = satisfiableSlow(f, slow)

    check slowSat
    check fastSat
    check slowSat == fastSat
    check eval(f, fast)
