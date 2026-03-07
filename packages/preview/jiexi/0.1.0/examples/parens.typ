// test the language of matching parentheses
#import "@preview/jiexi:0.1.0" as jiexi

#let parens-lex(input) = {
  let tag-stream = ()
  for ch in input {
    let pos = "()[]{}".position(ch)
    if (pos != none) { tag-stream.push(pos) }
  }
  return (tag-stream, (none,) * tag-stream.len())
}

#let grammar = "
%start Exp

%token '(' 0
%token ')' 1
%token '[' 2
%token ']' 3
%token '{' 4
%token '}' 5

%%

Exp
  : { #}
  | '(' Exp ')' Exp { #}
  | '[' Exp ']' Exp { #}
  | '{' Exp '}' Exp { #}
"

#let parens-parse = jiexi.make-parser(grammar)

#parens-parse(..parens-lex("()[]{}([{()[]{}}])"))

#parens-parse(..parens-lex("([{([{}])}])"))

// #parens-parse(..parens-lex("([{([{}])}]")) // should panick