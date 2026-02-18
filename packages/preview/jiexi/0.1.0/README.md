# Jiexi

**Parser generator for Typst.** 

Jiexi (解析 in Chinese, meaning "to parse") is a generic and powerful parser generator tool for Typst, analogous to Yacc for C and Happy for Haskell. 

Internally, Jiexi calls Happy to convert a grammar specification to tables for a shift-reduce parser. 

## Syntax for Jiexi grammar files

The syntax of Jiexi's grammar files is similar to that of Happy's grammar files, which is in turn similar to that of Yacc. Thus, you should find some familiarity if you are familiar with either Happy or Yacc. 

A Jiexi file is split by a separator `%%` into two sections, the directive section and the grammar section: 
```text
<directives>
%%
<grammar>
```

The directive section consists of a list of directives, one for each line. The possible directives are: 
```text
%start <non-terminal>
%token <token-name> <token-tag>
%left <token-names>
%right <token-names>
%nonassoc <token-names>
```

The meaning of these directives are explained below: 
- `%start <non-terminal>` defines the non-terminal that we want as the parse result. 
  
  There should be exactly one `%start` directive for each Jiexi file. 

- `%token <token-name> <token-tag>`
  
  Defines a token with the given name and tag. 

  The name is used inside the Jiexi file to refer to the token. A valid token name is either a letter followed by an arbitrary amount of alphanumeric characters or underscores, or an arbitrary sequence of characters surround by a pair of single/double quotes `''` or `""`. If you want to use the same quote symbol inside a pair of quotes, escape it. 

  The tag is a non-negative integer used to externally refer to this token. As we will talk about later, the Typst interface of a generated parser would be `parser(tag-stream, value-stream)`. The two arrays must have equal length. `tag-stream` will contain tags for each token, which are Typst integers. Inside the parser, each token will have the token kind specified with a `%token` directive with this tag. 

- `%left <token-names>`, `%right <token-names>`, `%nonassoc <token-names>`
  Defines the associativity and precedence of a given list of tokens. 
  
  Any token involved in a directive of this type is assumed to have higher precedence than those in `%left`/`%right`/`%nonassoc` directives above it and lower than those `%left`/`%right`/`%nonassoc` directives in below it. 

  Associativity is used to resolve shift-reduce conflicts. More specifically: 

  - The induced precedence and associativity of a production is that of its last terminal symbol. 
  - In case of a shift-reduce conflict, we compare the precedence of the shifted token against that of the production rule to reduce with: 
    - token precedence > production precedence: SHIFT
    - token precedence < production precedence: REDUCE
    - token precedence = production precedence: 
      Since it is forced that terminals/rules with the same precedence have the same associativity, 
        we look at the associativity of either the rule or the terminal token: 
      - SHIFT if left associative; 
      - REDUCE if right associative; 
      - ERROR if non-associative. 

The grammar section consists of a list of productions. Each production is of the following form: 
```text
<nonterminal>
  : <rule1> { code1 #}
  | <rule2> { code2 #}
  ...
  | <ruleN> { codeN #}
```
A rule is a list of space-separated terminal or non-terminal tokens, specifying a way of obtaining the specified non-terminal token. 

A rule must be followed by a section of Typst code that computes the semantic value of a non-terminal token obtained this way. In this code segment, semantic values of the tokens in the production rules may be referred to as `t1`, `t2`, ... in order. This code segment is always terminated by the character sequence `#}`, even if you intended to use this sequence in a Typst string literal, content or math block. As such, if you have to use this sequence in the block of Typst code, you should use some sort of escape. 

A rule may be optionally followed by a directive: 
- `%prec <token-name>`: This makes the rule inherit the precedence and associativity of the specified token, instead of having the induced precedence and associativity of its last terminal token. 
- `%shift`: This gives the rule the lowest precedence. Any shift-reduce conflict involving this rule is always resolved as SHIFT. 

## Typst interface

The Typst interface of current version of Jiexi consists of one function `make-parser(grammar)`. It receives a string argument containing the content of a Jiexi grammar file, and returns a parser function. 

The parser function takes two array arguments `(tag-stream, value-stream)`. These two arrays must have the same length. `tag-stream.at(i)` is the tag of the `i`-th token, meaning that the `i`-th token has the kind of the terminal token specified in a `%token` directive with this tag. `value.stream.at(i)` is the semantic value of the `i`-th token. This is the value that will be passed as one of `t1`, `t2`, ... corresponding to this terminal token, in the code section associated with a rule that will be used to reduce this token with. 

## A study by example

Consider a grammar evaluating arithmetic expressions with integer literals, `+`, `-`, `*` operators and a unary minus. 

The Jiexi grammar file should then be: 
```text
%start Expr

%token int 0
%token '+' 1
%token '-' 2
%token '*' 3
%token '(' 4
%token ')' 5
%token NEG 6

%left '+' '-'
%left '*'
%left NEG

%%

Expr
  : int { t1 #}
  | Expr '+' Expr { t1 + t3 #}
  | Expr '-' Expr { t1 - t3 #}
  | Expr '*' Expr { t1 * t3 #}
  | '-' Expr %prec NEG { -t2 #}
  | '(' Expr ')' { t2 #}
```
Here, we specify all terminal tokens: integer literals, operators `+`, `-`, `*`, parentheses, and a dummy `NEG` token that should not appear in input. 

We want `*` to have higher precedence than binary `+` and `-`, but lower precedence than unary `-`. To implement this, we declared the dummy token `NEG` with higher priority than `*`, and used a `%prec` directive to modify the precedence of the unary minus rule from its induced value (the precedence of `-`, its last terminal) to that of `NEG`. 

The semantic value of a integer literal is a Typst integer with this value. Then, the code sections we included associated a semantic value with each `Expr` that is the same as this `Expr` evaluated usually as an arithmetic expression.  

Given a parse function `parse` obtained from this grammar, suppose that we are to evaluating `(1 + 2) * 3 - 4 * 5`. We would need to invoke `parse` with: 
```
parse(
  (4, 0, 1, 0, 5, 3, 0, 2, 0, 3, 0), 
  (none, 1, none, 2, none, none, 3, none, 4, none, 5)
)
```
Here, each integer token is associated with its value as an integer, and each symbol token is given a semantic value of `none`. This `none` is arbitrary, since we never used the semantic value of a symbol token in the code sections in the grammar specification above. We will then obtain the intended return value `-11`. 

To convert the string `"(1 + 2) * 3 - 4 * 5"` to the two arrays `(4, 0, 1, 0, 5, 3, 0, 2, 0, 3, 0)` and `(none, 1, none, 2, none, none, 3, none, 4, none, 5)`, you need to write a lexer yourself. 

I plan to implement a lexer generator in Jiexi in a future version, but for now you have to manually write lexers. 

More examples can be found in [examples](./examples). 