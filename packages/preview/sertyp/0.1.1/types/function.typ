#import "../utils.typ" as utils;
#import "generic.typ" as generic;

#let SUPER_TYPES = (
  table: (
    table.cell,
    table.footer,
    table.header,
    table.hline,
    table.vline,
  ),
  grid: (
    grid.cell,
    grid.footer,
    grid.header,
    grid.hline,
    grid.vline,
  ),
  math: (
    math.accent,
    math.attach,
    math.binom,
    math.cancel,
    math.cases,
    math.equation,
    math.frac,
    math.lr,
    math.mat,
    math.op,
    math.primes,
    math.root,
    math.sqrt,
    math.display,
    math.vec,
    math.mid,
    math.stretch,
    math.underline,
    math.overline,
    math.underbrace,
    math.overbrace,
    math.underbracket,
    math.overbracket,
    math.underparen,
    math.overparen,
    math.undershell,
    math.overshell,
  ),
  place: (
    place.flush,
  ),
  curve: (
    curve.line,
    curve.move,
    curve.cubic,
    curve.close,
    curve.quad,
  ),
  color: (
    color.hsl,
    color.hsv,
    color.rgb,
    color.linear-rgb,
    color.cmyk,
    color.luma,
    color.oklab,
    color.oklch,
  ),
  gradient: (
    gradient.linear,
    gradient.radial,
    gradient.conic,
  ),
)

#let serializer(f, ctx: none) = {
  utils.assert_type(f, function);

  for (group, values) in SUPER_TYPES.pairs() {
    if f in values {
      ctx = group;
      break;
    }
  }
  
  import "string.typ" as string_;
  return string_.serializer(if ctx != none { ctx + "." } else { "" } + repr(f));
};

#let deserializer(s) = {
  utils.assert_type(s, str);

  if s == "(..) => .." {
    panic(s, "Inline function deserialization is not supported");
  }
  return eval(s);
};

#let test(cycle) = {
  utils.assert(
      serializer((x: int) => { return "test"; }),
      "(..) => .."
  );
  utils.assert(
    serializer(table.cell),
    "table.cell"
  )
  utils.assert(
    deserializer("repr"),
    repr
  );

  let a = generic.serializer(color.hsl)

  let null = cycle(repr);
  let null = cycle(color.hsl)
};