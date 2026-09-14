#import "../lib.typ": *

#set text(lang: "es")

#let then = $arrow$
#let bithen = $arrow.l.r$
#let eqt = $eq.triple$
#let ex = $exists$

#let hi(content) = {
  text(content, weight: "bold", fill: gradient.linear(red, blue))
}

= Examples

Default usage of `ded-nat-boxed`:

#ded-nat-boxed(stcolor: black, arr:(
  ("1", 0, "first line", "PR"),
  ("1", 0, "second line", "PR"),
  ("1", 0, "third line" , "PR"),
  ("1", 0, text(weight: "bold", "fourth line") , "PR"),
))

Usage of `ded-nat-boxed` with overriden `style-dep`, `style-formula` and `style-rule` parameters:

#ded-nat-boxed(style-dep: a => text(weight: "extrabold", fill: red, a), style-formula: a => text(fill: fuchsia, a), style-rule: a => text(weight: "extralight", style: "italic", fill: olive, tracking: 6pt, a), arr:(
  ("1", 0, "first line", "PR"),
  ("1", 0, "second line", "PR"),
  ("1", 0,  "third line" , "PR"),
  ("1", 0,  text(fill: blue, weight: "bold", "fourth line") , "PR"),
))

== Deducción natural
Elegir 10 ejercicios del libro de Falguera y Vidal, de las páginas 318, 319, 320 y 321; y hacer su prueba con deducción natural. 

+ pg. 318, ejercicios VI, I. 1)

  This is written using `ded-nat-boxed`. The coloring of the text is done by wrapping that function with `text(content, weight: "bold", fill: gradient.linear(red, blue))`, and the color of the box stroke is done with `stcolor: gradient.linear(red, blue)`.

  #hi[
    #ded-nat-boxed(stcolor: gradient.linear(red, blue), arr:(
        ("1", 0, $forall x (P x) and forall x (Q x)$, "PR"),
        ("2", 0, $forall x (P x -> R x)$, "PR"),
        
        ("1", 0, $forall x (P x)$, "S 1"),
        ("1", 0, $P a$, "IU 3"),
        ("2", 0, $P a -> R a$, "IU 2"),
        ("1,2", 0, $R a$, "MP 4, 5"),
        
        ("1,2", 0, $forall x (R x)$, "GU 6"),
    ))
  ]

  This is using `ded-nat`, and it is a repetition of the last one but without the boxing and without dependencies (inputting an array of 3 items).

  #ded-nat(stcolor: black, arr: (
    (0, $forall x (P x) and forall x (Q x)$, "PR"),
    (0, $forall x (P x -> R x)$, "PR"),
  
    (0, $forall x (P x)$, "S 1"),
    (0, $P a$, "IU 3"),
    (0, $P a -> R a$, "IU 2"),
    (0, $R a$, "MP 4, 5"),
    (0, $forall x (R x)$, "GU 6"),
  ))

  This is using `ded-nat-boxed`, without dependencies (inputting an array of 3 items) and without the premises and conclusion of the deduction automatically put over the lines.

  #ded-nat-boxed(stcolor: black, premises-and-conclusion: false, arr: (
    (0, $forall x (P x) and forall x (Q x)$, "PR"),
    (0, $forall x (P x -> R x)$, "PR"),
  
    (0, $forall x (P x)$, "S 1"),
    (0, $P a$, "IU 3"),
    (0, $P a -> R a$, "IU 2"),
    (0, $R a$, "MP 4, 5"),
    (0, $forall x (R x)$, "GU 6"),
  ))

+ pg. 321, ejercicios VI, I. 62)

  #ded-nat-boxed(stcolor: black, arr: (
    ("1", 0, $forall x (S x b) and not forall y (P y -> Q b y)$, "PR"),
    ("2", 0, $forall x forall y (Q x y -> not Q y x)$, "PR"),

      ("3", 1, $not forall x (not P x) -> forall y (S y b -> Q b y)$, "Sup. RAA"),
      ("1", 1, $not forall y (P y -> Q b y)$, "S 1"),
      ("1", 1, $exists y not (P y -> Q b y)$, "EMC 4"),
        ("6", 2, $not (P a -> Q b a)$, "Sup. IE 5"),
          ("7", 3, $not (P a and not Q b a)$, "Sup. RAA"),
          ("7", 3, $not P a or not not Q  b a$, "DM 7"),
            ("9", 4, $not P a$, "Sup. PC"),
            ("9", 4, $not P a or Q b a$, "Disy. 9"),
          ("", 3, $not P a -> (not P a or Q b a)$, "PC 9-10"),
            ("12", 4, $not  not Q b a$, "Sup. PC"),
            ("12", 4, $Q b a$, "DN 12"),
            ("12", 4, $not P a or Q b a$, "Disy. 13"),
          ("", 3, $not not Q b a -> (not P a or Q b a)$, "PC 12-14"),
          ("7", 3, $not P a or Q b a$, "Dil. 8,11,15"),
          ("7", 3, $P a -> Q b a$, "IM 16"),
          ("6,7", 3, $(P a -> Q b a) and not (P a -> Q b a)$, "Conj. 6, 17"),
        ("6", 2, $P a and not Q b a$, "RAA 7-18"),
        ("6", 2, $P a$, "S 19"),
        ("6", 2, $exists x (P x)$, "GE 20"),
        ("6", 2, $not forall x (not P x)$, "EMC 21"),
        ("3,6", 2, $forall y (S y b -> Q b y)$, "MP 3, 22"),
        ("3,6", 2, $S a b -> Q b a$, "IU 23"),
        ("1", 2, $forall x (S x b)$, "S 1"),
        ("1", 2, $S a b$, "IU 25"),
        ("1,3,6", 2, $Q b a$, "MP 24, 25"),
        ("6", 2, $not Q b a$, "S 19"),
        ("1,3,6", 2, $Q b a or not exists y not (P y -> Q b y)$, "Disy. 27"),
        ("1,3,6", 2, $not exists y not (P y -> Q b y)$, "MTP 28, 29"),
      ("1,3", 1, $not exists y not (P y -> Q b y)$, "IE 5, 6, 30"),
      ("1,3", 1, $not exists y not (P y -> Q b y) and exists y not (P y -> Q b y)$, "Conj. 5, 31"),

    ("1", 0, $not (not forall x (not P x) -> forall y ( S y b -> Q b y))$, "RAA 3-32"),
    ))


+ pg. 320, ejercicios VI, I. 51)

  #hi[
    #box(
      stroke: gradient.linear(red, blue), inset: 8pt, radius: 8pt,
    )[
      #align(center)[
        $
        not (M a b -> (S a and S b)), \
        not (not exists x Q x or forall x not R a b x) \
        tack forall x ((S a and S b) -> (R a b x -> not Q x))
        $
      
      #ded-nat(stcolor: gradient.linear(red,blue), arr: (
        ("1", 0, $not (M a b -> (S a and S b))$, "PR"),
        ("2", 0, $not (not exists x Q x or forall x not R a b x)$, "PR"),
        
          ("3", 1, $not (M a b and not (S a and S b))$, "Sup. RAA"),
          ("3", 1, $not M a b or not not (S a and S b)$, "DM 3"),
            ("5", 2, $not M a b$, "Sup. PC"),
            ("5", 2, $not M a b or (S a and S b)$, "Adj. 5"),
            ("5", 2, $M a b -> (S a and S b)$, "IM 6"),
          ("", 1, $not M a b -> (M a b -> (S a and S b))$, "PC 5-7"),
            ("9", 2, $not not (S a and S b)$, "Sup. PC"),
            ("9", 2, $S a and S b$, "DN 9"),
            ("9", 2, $not M a b or (S a and S b)$, "Adj. 10"),
            ("9", 2, $M a b -> (S a and S b)$, "IM 11"),
          ("", 1, $not not (S a and S b) -> (M a b -> (S a and S b))$, "PC 9-12"),
          ("3", 1, $M a b -> (S a and S b)$, "Dil. 4, 8, 13"),
          ("1,3", 1, $not(M a b -> (S a and S b)) and (M a b -> (S a and S b))$, "Conj. 1, 14"),
        ("1", 0, $M a b and not (S a and S b)$, "RAA 3-15"),
          ("17", 1, $S and S b$, "Sup. PC"),
          ("17", 1, $(S and S b) or (R a b c -> not Q c)$, "Adj. 17"),
          ("1", 1, $not (S and S b)$, "S 16"),
          ("1,17", 1, $R a b c -> not Q c$, "MTP 18, 19"),
        ("1", 0, $(S a and S b) -> (R a b c -> not Q c)$, "PC 17-20"),
        
        ("1", 0, $forall x ((S a and S b) -> (R a b x -> not Q x))$, "GU 21"),
      ))
      ]
    ]
  ]

#pagebreak()
4. pg. 320, ejercicios VI, I. 41)

  #ded-nat-boxed(stcolor: black, arr: (
    ("1", 0, $forall x forall y ((Q y x and R y x) -> not Q x y)$, "PR"),
    ("2", 0, $Q a b and P b$, "PR"),
  
      ("3", 1, $R b a$, "Sup. PC"),
      ("1", 1, $forall y ((Q y a and R y a) -> not Q a y)$, "IU 1"),
      ("1", 1, $(Q b a and R b a) -> not Q a b$, "IU 4"),
      ("2", 1, $Q a b$, "S 2"),
      ("2", 1, $not not Q a b$, "DN 6"),
      ("1,2", 1, $not (Q b a and R b a)$, "MT 5, 7"),
      ("1,2", 1, $not Q b a or not R b a$, "DM 8"),
      ("3", 1, $not not R b a$, "DN 3"),
      ("1,2,3", 1, $not Q b a$, "MTP 9, 10"),
      ("2", 1, $P b$, "S 2"),
      ("1,2,3", 1, $not Q b a and P b$, "Conj. 11, 12"),
      ("1,2,3", 1, $exists x (not Q b x and P b)$, "GE 13"),
  
    ("1,2", 0, $R b a -> exists x (not Q b x and P b)$, "PC 3-14"),
  ))

#pagebreak()
5. pg. 319, ejercicios VI, I. 30)

  #hi[
    #box(
      stroke: gradient.linear(red, blue), inset: 8pt, radius: 8pt,
    )[
      #align(center)[
        $
        not ex x ex y (not T x y and not T y x), \
        forall x (T x a -> (Q a and R a)), \
        not forall x (T a x) \
        tack exists x (Q x and R x)
        $
      
      #ded-nat(stcolor: gradient.linear(red,blue), arr: (
        ("1", 0, $not ex x ex y ( not T x y and not T y x)$, "PR"),
        ("2", 0, $forall x (T x a -> (Q a and R a))$, "PR"),
        ("3", 0, $not forall x (T a x)$, "PR"),
        
        ("3", 0, $ex x not(T a x)$, "EMC 3"),
        ("5", 1, $not T a b$, "Sup. IE 4"),
        ("1", 1, $forall x not ex y (not T x y and not T y x)$, "EMC 1"),
        ("1", 1, $not ex y (not T b y and not T y b)$, "IU 6"),
        ("1", 1, $forall y not (not T b y and not T y b)$, "EMC 7"),
        ("1", 1, $not (not T b a and not T a b)$, "IU 8"),
        ("1", 1, $not not T b a or not not T a b)$, "DM 9"),
        ("5", 1, $not not not T a b$, "DN 5"),
        ("1,5", 1, $not not T b a$, "MTP 10, 11"),
        ("1,5", 1, $T b a$, "DN 12"),
        ("2", 1, $T b a -> (Q a and R a)$, "IU 2"),
        ("1,2,5", 1, $Q a and R a$, "MP 13, 14"),
        ("1,2,5", 1, $ex x (Q x and R x)$, "GE 15"),
        
        ("1,2,3", 0, $ex x (Q x and R x)$, "IE 4, 5, 16"),
      ))
      ]
    ]
  ]


+ pg. 319, ejercicios VI, I. 20)

  #hi[
    #box(
      stroke: gradient.linear(red, blue), inset: 8pt, radius: 8pt,
    )[
      #align(center)[
        $
        not ex x (S x) or (Q a and T a), \
        ex x (Q x and T x) -> forall x (R x), \
        S a \
        tack R b
        $
      
      #ded-nat(stcolor: gradient.linear(red,blue), arr: (
        ("1", 0, $not ex x (S x) or (Q a and T a)$, "PR"),
        ("2", 0, $ex x (Q x and T x) -> forall x (R x)$, "PR"),
        ("3", 0, $S a$, "PR"),
        
        ("3", 0, $ex x (S x)$, "GE 3"),
        ("3", 0, $not not ex x (S x)$, "DN 4"),
        ("1,3", 0, $Q a and T a$, "MTP 1, 5"),
        ("1,3", 0, $ex x (Q x and T x)$, "GE 6"),
        ("1,2,3", 0, $forall x (R x)$, "MP 2, 7"),
        
        ("1,2,3", 0, $R b$, "IU 8"),
      ))
      ]
    ]
  ]

+ pg. 318, ejercicios VI, I. 10)

  #hi[
    #box(
      stroke: gradient.linear(red, blue), inset: 8pt, radius: 8pt,
    )[
      #align(center)[
        $
        forall x (T x -> Q x), \
        forall x not (P x or not T x) \
        tack
        ex x ( not P x and Q x)
        $
      
      #ded-nat(stcolor: gradient.linear(red,blue), arr: (
        ("1", 0, $forall x (T x -> Q x)$, "PR"),
        ("2", 0, $forall x not (P x or not T x)$, "PR"),
        
        ("2", 0, $not (P a or not T a)$, "IU 2"),
        ("2", 0, $not P a and not not T a$, "DM 3"),
        ("2", 0, $not not T a$, "S 4"),
        ("2", 0, $T a$, "DN 5"),
        ("1", 0, $T a -> Q a$, "IU 1"),
        ("1,2", 0, $Q a$, "MP 6, 7"),
        ("2", 0, $not P a$, "S 4"),
        ("1,2", 0, $not P a and Q a$, "Conj. 8, 9"),
        
        ("1,2", 0, $ex x ( not P x and Q x)$, "GE 10"),
      ))
      ]
    ]
  ]

#pagebreak()
8. pg. 318, ejercicios VI, I. 5)

  #hi[
    #ded-nat-boxed(stcolor: gradient.linear(red, blue), arr: (
        ("1", 0, $forall x (P x) -> forall x (Q x)$, "PR"),
        ("2", 0, $not Q a$, "PR"),
        
        ("2", 0, $ex x not (Q x)$, "GE 2"),
        ("2", 0, $not forall x  (Q x)$, "EMC 3"),
        
        ("1,2", 0, $not forall x (P x)$, "MT 1, 4"),
    ))
  ]

+ pg. 318, ejercicios VI, I. 6)

  #hi[
    #ded-nat-boxed(stcolor: gradient.linear(red, blue), arr: (
        ("1", 0, $forall x (P x -> Q x)$, "PR"),
        ("2", 0, $forall x ( not S x -> not Q x)$, "PR"),
        ("3", 0, $not forall x (S x)$, "PR"),
        
        ("3", 0, $ex x not (S x)$, "EMC 3"),
        ("5", 1, $not S a$, "Sup. IE 4"),
        ("2", 1, $not S a -> not Q a$, "IU 2"),
        ("2,5", 1, $not Q a$, "MP 5, 6"),
        ("1", 1, $P a -> Q a$, "IU 1"),
        ("1,2,5", 1, $not P a$, "MT 7, 8"),
        ("1,2,5", 1, $ex x (not P x)$, "GE 9"),
        
        ("1,2,3", 0, $ex x (not P x)$, "IE 4, 5, 10"),
    ))
  ]

#pagebreak()
10. pg. 318, ejercicios VI, I. 7)

  #ded-nat-boxed(stcolor: black, arr: (
      ("1", 0, $forall x (T x -> M x)$, "PR"),
      ("2", 0, $forall x not (M x and R x)$, "PR"),
      ("3", 0, $forall x ( T x -> (P x -> R x))$, "PR"),
    
      ("4", 1, $T a$, "Sup. PC"),
      ("1", 1, $T a -> M a$, "IU 1"),
      ("1,4", 1, $M a$, "MP 4,5"),
      ("2", 1, $not (M a and R a)$, "IU 2"),
      ("2", 1, $not M a or not R a$, "DM 7"),
      ("1,4", 1, $not not M a$, "DN 6"),
      ("1,2,4", 1, $not R a$, "MTP 8, 9"),
      ("3", 1, $T a -> (P a -> R a)$, "IU 3"),
      ("3,4", 1, $P a -> R a$, "MP 4, 11"),
      ("1,2,3,4", 1, $not P a$, "MT 10, 12"),
      ("14", 2, $M a -> P a$, "Sup. RAA"),
      ("1,4,14", 2, $P a$, "MP 6, 14"),
      ("1,2,3,4,14", 2, $P a and not  P a$, "Conj. 13, 15"),
      ("1,2,3,4", 1, $not (M a -> P a)$, "RAA 14-16"),
      ("1,2,3", 0, $T a -> not ( M a -> P a)$, "PC 4-17"),
    
      ("1,2,3", 0, $forall x ( T x -> not (M x -> P x))$, "GU 18"),
  ))
