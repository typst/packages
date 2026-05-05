
when defined(nimAtlasBootstrap):
  import ../../dist/sat/src/sat/[sat, satvars]
else:
  import sat/[sat, satvars]

proc `$`*(v: VarId): string =
  "v" & $v.int

export sat, satvars
