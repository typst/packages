# sat
A SAT solver written in Nim.

```nim
import sat/[sat, satvars]
```

Note:
  Remember that even though SAT claims to support the OR operator, it actually doesn't and only supports it if you use it to build up an implication (A -> B == ~ A | B)

