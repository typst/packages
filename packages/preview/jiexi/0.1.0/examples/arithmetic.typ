/*
 * Tests an example grammar of arithmetics, containing integer literals, +, -, *, parentheses, 
 *   a unary minus and a Haskell-style `let x = RHS in ...` binding. 
 */
#import "@preview/jiexi:0.1.0" as jiexi

#let (
  tag-int, tag-plus, tag-minus, tag-mul, 
  tag-lparen, tag-rparen, tag-let, tag-id, 
  tag-assign, tag-in
) = range(10)

// Hand written lexer
// We will implement lexer generation one day
#let lex-arith(input) = {
  let input = input.replace(regex("[\+\-\*\(\)\=]"), match => " " + match.text + " ")
  let lexers = (
    (regex("let"), tag-let, _ => none),
    (regex("in"), tag-in, _ => none),
    (regex("\+"), tag-plus, _ => none),
    (regex("\-"), tag-minus, _ => none),
    (regex("\*"), tag-mul, _ => none),
    (regex("\("), tag-lparen, _ => none),
    (regex("\)"), tag-rparen, _ => none),
    (regex("="), tag-assign, _ => none),
    (regex("\d+"), tag-int, m => int(m.text)),
    (regex("[a-zA-Z][a-zA-Z0-9_]*"), tag-id, m => m.text),
  )
  let tag-stream = ()
  let value-stream = ()
  for token in input.split() {
    let matched = false
    if token.len() == 0 { continue }
    for (reg, tag, value-maker) in lexers {
      let m = token.match(reg)
      if (m != none and m.start == 0) {
        tag-stream.push(tag)
        value-stream.push(value-maker(m))
        matched = true
        break
      }
    }
    if (not matched) { panic("Unknown token: " + token) }
  }
  return (tag-stream, value-stream)
}

#let grammar = "
%start Exp
%token int 0
%token '+' 1
%token '-' 2
%token '*' 3
%token '(' 4
%token ')' 5
%token let 6
%token id 7
%token '=' 8
%token in 9
%token NEG 10

%right in
%left '+' '-'
%left '*'
%nonassoc NEG

%%

Exp
  : int { env => t1 #}
  | id { env => env.at(t1) #}
  | Exp '+' Exp { env => t1(env) + t3(env) #}
  | Exp '-' Exp { env => t1(env) - t3(env) #}
  | Exp '*' Exp { env => t1(env) * t3(env) #}
  | '-' Exp %prec NEG { env => -t2(env) #}
  | '(' Exp ')' { t2 #}
  | let id '=' Exp in Exp { env => {
    let new-env = env
    new-env.insert(t2, t4(env))
    t6(new-env)
  } #}
"

#let parse-arith = jiexi.make-parser(grammar)

#assert.eq(
  parse-arith(..lex-arith("let x = 10 in x * (x + 1) * (x - 1) * -2 + x * x"))((:)), 
  {let x = 10 ; x * (x + 1) * (x - 1) * -2 + x * x}
)