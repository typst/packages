#let types = (
  EOF: "EOF",
  Name: "name",
  Literal: "literal",
  Lbrack: "[",
  Rbrack: "]",
  LParen: "(",
  RParen: ")",
  Comma: ",",
  Wildcard: "*",
  Colon: ":",
  DotDot: "..",
  Dot: ".",
  Operator: "operator",
  // keywords
  Root: "$",
  Current: "@",
  Filter: "?",
)

#let lit_kind = (
  Int: "int",
  FLoat: "float",
  String: "string",
)

#let token(
  start,
  end,
  type,
  lit, // valid if types: name, literal
  litkind, // valid if types: literal
  op, // valid if types: operator
) = {
  return (
    pos: (
      start: start,
      end: end,
    ),
    type: type,
    lit: lit,
    litkind: litkind,
    op: op,
  )
}

#let Eof(start, end) = {
  return token(start, end, types.EOF, none, none, none)
}

#let Name(start, end, name) = {
  return token(start, end, types.Name, name, none, none)
}

#let Literal(start, end, kind, literal) = {
  return token(start, end, types.Literal, literal, kind, none)
}

#let Lbrack(start, end) = {
  return token(start, end, types.Lbrack, none, none, none)
}

#let Rbrack(start, end) = {
  return token(start, end, types.Rbrack, none, none, none)
}

#let Comma(start, end) = {
  return token(start, end, types.Comma, none, none, none)
}

#let Wildcard(start, end) = {
  return token(start, end, types.Wildcard, none, none, none)
}

#let Colon(start, end) = {
  return token(start, end, types.Colon, none, none, none)
}

#let DotDot(start, end) = {
  return token(start, end, types.DotDot, none, none, none)
}

#let Dot(start, end) = {
  return token(start, end, types.Dot, none, none, none)
}

#let Operator(start, end, op) = {
  return token(start, end, types.Operator, none, none, op)
}

#let LParen(start, end) = {
  return token(start, end, types.LParen, none, none, none)
}

#let RParen(start, end) = {
  return token(start, end, types.RParen, none, none, none)
}

#let Root(start, end) = {
  return token(start, end, types.Root, none, none, none)
}

#let Current(start, end) = {
  return token(start, end, types.Current, none, none, none)
}

#let Filter(start, end) = {
  return token(start, end, types.Filter, none, none, none)
}

#let token_str(tok) = {
  let kind_content(kind, content) = {
    return kind + "(" + content + ")"
  }
  if tok.type == types.EOF {
    return "EOF"
  }
  if tok.type == types.Name {
    return kind_content("name", tok.lit)
  }
  if tok.type == types.Literal {
    return kind_content(tok.litkind, tok.lit)
  }
  if tok.type == types.Operator {
    return kind_content("operator", tok.op)
  }
  return tok.type
}
