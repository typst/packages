#import "@preview/tudelft-prime-presentation:0.1.2": * 
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge
#import fletcher.shapes: diamond

#show math.equation: set text(font : "Lete Sans Math") 

#set math.mat(delim: "[")
#set math.vec(delim: "[")
#set enum(spacing: 2em)
#set list(spacing: 1.2em)

#set math.mat(column-gap: 1em)

#let students = false

#show: prime-slides.with(
    title: "Linear Algebra Lecture 5",
    subtitle: "Matrix operations",
    background : "background/background.png", // Courtesy of Nelson Chan
    logo : "Linear Algebra/Logos/intersection_planes.png"
)

== Programme
#programme_slide(book_sections : (2.1,) )[

- Matrix addition and scalar multiplication
- Matrix multiplication
- Transpose of a matrix

]

== Polling questions using Vevox
#slide(slide-type : "polling")[
  - Go to vevox.app and enter the session ID:
  - No personal informations is required
]

= Matrix addition and scalar multiplication

== Matrix addition
#slide(slide-type: "polling")[
  Let $A=mat(1,1; 3,5)$ and $B = mat(2&, -2&; 4, -1; -2, 3)$,
 
  compute $A+B$ if possible.

  #poll_answers( cols: 1, correct_answer: 3, students: students)[
    1. $mat(3&, -1&; 7, 4; -2,3)$
    2. $mat(2&, -2&;5, 0; 1, 8)$
    3. Not defined
  ]
]

== Matrix addition and scalar multiplication
#slide(slide-type: "polling")[
  Let $A = mat(1,1;3,5)$ and $B=mat(2, -2; 4, -1)$,

  compute $2A-B$ if possible.

    #poll_answers( cols : 1, row-gutter: 2em, correct_answer : 1, students: students)[
      1. $ mat(0&, 4&; 2, 11)$
      2. $ mat(-2&, -6&;-2, 12)$
      3. Not defined
    ]

]

== Some special types of matrics

#slide(slide-type: "definition")[
  #definitions(text-size: 23pt)[
    An $m times n$ matrix $A$ is called a:
    #list(indent: 1em, spacing: 1.1em,
      list.item()[#underline[zero matrix] if all entries are zeros.],
      list.item()[#underline[square matrix] if $m = n$.]
    )
    The #underline[main diagonal] of a square matrix consists of the entries $a_(i i)$.\
    A square matrix is called $a(n)$:
    #list(indent: 1em, spacing: 1.1em,
      list.item()[#underline[diagonal matrix] if all off-diagonal entries are zeros.],
      list.item()[#underline[identity matrix] if its a diagonal matrix with 1's on the main diagonal.],
      list.item()[#underline[lower/upper triangular matrix] if all entries above/below the main diagonal are zeros.]
    )
  ]
]


== #text(size: 30pt,"Properties of matrix addition and scalar multiplication")
#slide(slide-type: "definition")[
  #theorem()[
    Let $A$, $B$ and $C$ be matrices of the same size and let $r$ and $s$ be scalars, then:
    #enum(numbering: "a.", indent : 1em, spacing: .95em,
      enum.item()[$A+ B = B+A$],
      enum.item()[$(A+B)+C = A + (B+C)$],
      enum.item()[$A+0 = A$],
      enum.item()[$r(A+B) = r A + r B$],
      enum.item()[$(r+s)A = r A + s A$],
      enum.item()[$r(s A) = (r s)A$]
    )
  ]
]

= Matrix multiplication

== Composition of linear transformations
#slide(slide-type: "definition")[
  #theorem()[
    Given two linear transformations $T:bb(R)^p->bb(R)^n$ and $S:bb(R)^n -> bb(R)^m$, then the composition $S compose T :bb(R)^p -> bb(R)^m$, defined by
    $ (S compose T)(upright(bold(x))) = S(T(upright(bold(x)))), $
    is also a linear transformation.
  ]

  #place(dx : 9cm, dy: .8cm,
    diagram(
      //Diamonds
      node((0,0),shape: diamond,stroke: MOOCblue, fill : MOOCblue.lighten(20%), width: 2cm, height : .8cm, layer : -1),
      node((1,0),shape: diamond,stroke: MOOCblue, fill : MOOCblue.lighten(20%), width: 2cm, height : .8cm, layer : -1),
      node((2,0),shape: diamond,stroke: MOOCblue, fill : MOOCblue.lighten(20%), width: 2cm, height : .8cm, layer: -1),
      
      node((0,-.35),$bb(R)^p$, fill: none), // Upper label R^p
      node((0,0), "", shape: circle, radius: 1mm ,fill : MOOCred, name: <A>), // dot
      node((0,.35),$upright(bold(x))$, fill: none), // Lower label x
      edge(<A>,<B>,"->",bend: 45deg)[$T$], // Arrow
      node((1,-.35),$bb(R)^n$, fill: none), // Upper label
      node((1,0),"",shape: circle, radius: 1mm ,fill : MOOCred, name: <B>), // dot
      node((1,.35),$T(upright(bold(x)))$, fill: none), //Lower label
      edge(<B>,<C>,"->", bend: 45deg)[$S$], // Arrow
      node((2,-.35),$bb(R)^m$, fill: none), // Upper Label
      node((2,0),"",shape: circle, radius: 1mm ,fill : MOOCred, name: <C>), // dot
      node((2.4,.35),$S(T(upright(bold(x))))$, fill: none), // Lower Label
      edge(<A>,<C>, "->", bend: -45deg)[$S compose T$], // Arrow
    )
  )
]

== Matrix multiplication
#slide(slide-type: "definition")[
  #definition()[
      Let $A$ be an $m times n$ matrix and $B$ an $n times p$ matrix. The *product* $A B$ of $A$ and $B$ (in that order) is equal to the standard matrix of the composite mapping $S compose T$, where $S(upright(bold(x))) = A upright(bold(x))$ and $T(upright(bold(x)))=B upright(bold(x)).$\
      \
      (In particular, $A B$ is an $m times p$ matrix).
  ]
  #place(dx : 9cm, dy: .8cm,
    diagram(
      node((0,0),shape: diamond,stroke: MOOCblue, fill : MOOCblue.lighten(20%), width: 2cm, height : .8cm, layer : -1),
      node((1,0),shape: diamond,stroke: MOOCblue, fill : MOOCblue.lighten(20%), width: 2cm, height : .8cm, layer : -1),
      node((2,0),shape: diamond,stroke: MOOCblue, fill : MOOCblue.lighten(20%), width: 2cm, height : .8cm, layer: -1),
      
      node((0,-.35),$bb(R)^p$, fill: none), // Upper label
      node((0,0), "", shape: circle, radius: 1mm ,fill : MOOCred, name: <A>),
      node((0,.35),$upright(bold(x))$, fill: none), // Lower label
      edge(<A>,<B>,"->",bend: 45deg)[$T$], // Arrow
      node((1,-.35),$bb(R)^n$, fill: none), // Upper label
      node((1,0),"",shape: circle, radius: 1mm ,fill : MOOCred, name: <B>),
      node((1,.35),$B upright(bold(x))$, fill: none), //Lower label
      edge(<B>,<C>,"->", bend: 45deg)[$S$], // Arrow
      node((2,-.35),$bb(R)^m$, fill: none), // Upper Label
      node((2,0),"",shape: circle, radius: 1mm ,fill : MOOCred, name: <C>),
      node((2.4,.35),$A(B upright(bold(x)))$, fill: none), // Lower Label
      edge(<A>,<C>, "->", bend: -45deg)[$S compose T$], // Arrow
    )
  )
]

== Function composition
#slide(slide-type: "polling")[
  Given $T$ and $S$ as below. Does $(T compose S)$ exist?
  
  $ T(vec(x_1 ,x_2)) = vec(x_1+x_2, x_1-x_2, -x_1+x_2) $
  $ S(vec(y_1, y_2, y_3) ) = vec(y_1-y_2, y_2+y_3) $

  #poll_answers(cols: 1, correct_answer : 2, students: students)[
    1. No
    2. Yes
  ]
]

== Matrix Multiplication

#slide(slide-type: "polling")[
  $S: bb(R)^2 -> bb(R)^3$ is linear with matrix $A$.\
  $T: bb(R)^4 -> bb(R)^2$ is linear with matrix $B$.\
  Which statement on $A B$ is correct?

  #poll_answers(cols: 1, row-gutter: .8em,correct_answer : 3, students: students)[
    1. $A B$ does not exist, because\ $S compose T$ does not exist.
    2. $A B$ does not exist, because\ $T compose S$ does not exist.
    3. $A B$ does exist, and it\ is a $3 times 4$ matrix.
    4. $A B$ does exist, and it\ is a $4 times 3$ matrix.
  ]

]

== Questions?
#slide(slide-type: "questions")[]

== Recall the matrix-vector product

#slide(slide-type: "definition")[
  #definition()[
    The product of a #underline[matrix] $A$ with $n$ columns and a vector $upright(bold(x))$ with $n$ entries is defined by
    
    $ mat( upright(bold(a))_1, upright(bold(a))_2, dots.c, upright(bold(a))_n ) vec(upright(bold(x))_1,upright(bold(x))_2, dots.v, upright(bold(x))_n) = x_1 upright(bold(a))_1 + x_2 upright(bold(a))_2 + dots.c + x_n upright(bold(a))_n. $
  ]
#pause
This can be extended to a matrix-matrix product.
]

== Computing $A B$:  column rule
#slide(slide-type : "definition")[
  #theorem()[
    If $A$ is an $m times n$ matrix, and $B$ is an $n times p$ matrix with columns $upright(bold(b))_1$, $dots$, $upright(bold(b))_p$, then the product $A B$ is the $m times p$ matrix whose columns are $A upright(bold(b))_1$, $dots$, $A upright(bold(b))_p$.\
    \
    That is,
    $ A B = A mat(upright(bold(b))_1, upright(bold(b))_2, dots, upright(bold(b))_p) = mat(A upright(bold(b))_1, A upright(bold(b))_2, dots, A upright(bold(b))_p) $
  ]
] 

== Matrix multiplication
#slide(slide-type: "polling")[
  Compute $A B$ if possible where \
  \
  $A = mat(-5, 3;-4 , 1)$ and $B = mat(1&, -1&, 2; 2, 6, 0)$.
  #v(3em)
  #poll_answers(correct_answer : 3, row-gutter: 2em, students: students)[
    1. $mat(-1&, 4; -34, 0)$
    3. $mat(1&, -6; 23, -2; -10, 8)$
    2. $mat(1& , 23&, -10&; -6,-2,-8)$
    4. Not defined
  ]
]

== Matrix Multiplication
#slide(slide-type: "polling")[
  If $A$ is a $6 times 5$ matrix and $B$ is a $5 times 2$ matrix, \
  what is the size of $A B$, if defined?
  #v(1em)
  #poll_answers(row-gutter: 2em, column-gutter: 6em,
                correct_answer: 2, students: students)[
    1. $6 times 5$
    5. $6 times 2$
    2. $5 times 6$
    6. $2 times 6$
    3. $5 times 2$
    7. $5 times 5$
    4. $2 times 5$
    8. Not defined
  ]
]

== Computing $A B$: row-column rule

#slide(slide-type: "definition")[
  Entry $(i,j)$ of $A B$ equals $op("row")_i (A) upright(bold(b))_j$
  $ (A B)_(i j) = color(a_(i 1),MOOCblue) color(b_(1 j),#red) + color(a_(i 2),MOOCblue)color(b_(2 j),#red) + dots.c + color(a_(i n),MOOCblue)color(b_(n j),#red) $

  $ mat(
      a_(1 1),dots.c,  , a_(1 j), ,dots.c, ,a_(1 n);
      dots.v ,       , , dots.v,  ,      , ,  dots.v;
      color(a_(i 1),MOOCblue) , color(dots.c,MOOCblue), , color(a_(i j),MOOCblue) ,  , color(dots.c,MOOCblue), , color(a_(i n),MOOCblue);
      dots.v , , ,dots.v , , , ,dots.v;
      a_(m 1) , dots.c , , a_(m j) , , dots.c , , a_(m n)
    )
    mat(
      b_(1 1),dots.c,  , color(b_(1 j),#red), ,dots.c, ,b_(1 p);
      dots.v ,       , , color(dots.v,#red),  ,      , ,  dots.v;
      b_(i 1), dots.c, , color(b_(i j),#red) ,  , dots.c, , b_(i p);
      dots.v , , ,color(dots.v, #red) , , , ,dots.v;
      b_(n 1) , dots.c , , color(b_(n j),#red) , , dots.c , , b_(n p)
    )
  $
]

== Matrix Multiplication

#slide(slide-type: "polling")[
  Determine $(A B)_(3,2)$ if possible,\
  #v(.3em)
  where $A = mat( 1&, 2&, 3&, 4&; 4, 3, 2, 1; -1, -2, -3, -4)$\
  
  and $B = mat(1&, 0& ; 0, 1; 1, 0; 1, -1)$

  #poll_answers(row-gutter: 1.5em, column-gutter:4em, correct_answer : 4,
                students: students)[
    1. $-2$
    4. $1$
    2. $-1$
    5. $2$
    3. $0$
    6. Not defined
  ]
]

== Matrix multiplication
#slide(slide-type: "polling")[
  
  Given $A$ and $B$ as below. Does $A B$ exist?\
  If so, what is the third row of $A B$?
  $ A = mat(-1&,  7&;
              0,  4;
              3, -2) #h(2em) 
    B = mat( 0&, 1&; 
             -1, 2 ) $
  #poll_answers(correct_answer : 4, cols: 1, students : students)[
    1. No
    2. Yes, and the third row equals $mat(7, 13)$
    3. Yes, and the third row equals $mat(-4, 8)$
    4. Yes, and the third row equals $mat(2, -1)$
  ]
]

== Questions?
#slide(slide-type: "questions")[]

== Properties of matrix multiplication
#slide(slide-type: "definition")[
  #theorem()[
    Let $A$ be an $m times n$ matrix, and let $B$ and $C$ be matrices with
    sizes for which the indicated sums and products are defined. Then:
    #enum(numbering: "a.", indent: 1em, spacing: 1em,
      [$A(B C) = (A B)C$],
      [$A(B+C) = A B + A C$],
      [$(B+C)A = B A + C A$],
      [$r(A B) = (r A)B = A(r B)$ for any scalar $r$.],
      [$I_m A = A = A I_n$],
    )
  ]
]

== Matrix multiplication
#slide(slide-type: "polling")[
  Given $A$ and $B$ as below.\
  Which statement is correct?
  $ A=mat(0&, 1&;-1, 0) #h(1em) B =mat(0,1;1,0) $\

  #poll_answers(row-gutter: 1.4em, correct_answer : 2, cols: 1, students : students)[
    1. $A B = B A$
    2. $A B = -B A$
    3. None of the above.
  ]
]

== Warning
#slide(slide-type: "definition")[
  #enum(numbering: "a.", indent: 1em,
    [The identity $A B = B A$ is #underline[not true] in general.],
    [If $A B = A C$, then in general is #underline[not true] that $B = C$ !],
    [If $A B = 0$, then in general it is #underline[not true] that $A=0$ or $B=0$ !]
  )
]

== Practice
#practice_slide()[
  - Matrix addition and scalar multiplication
  - Matrix multiplication
  \
  $section$ 2.1: 5, 7, 8, 9

  You are now able to
  #list(indent: 1em, spacing: .8em,
    list.item()[add two matrices, if defined, and multiply a matrix by a scalar;],
    list.item()[calculate the product of two matrices, if defined, using three techniques;],
    list.item()[relate properties of a matrix product $A B$ to properties of the individual matrices $A$ and $B$.]
  )
]

== Powers of a matrix
#slide(slide-type: "definition")[
  #definition()[
    If $A$ is an $n times n$ matrix and if $k$ is a positive integer, then
    $ A^k = underbrace(A A dots.c A,k "factors"). $

    For k = 0 we define $A^0 = I$.
  ]
#pause
  #remark()[
    $ (A B)^k = underbrace((A B)dot.c(A B)dot.c dots.c dot.c (A B),k "times") $
  ]
]

== Rotation
#slide(slide-type : "polling")[
  Let $A$ be the standard matrix of the\
  counterclockwise rotation over an angle $phi$.\
  Then $A^2$ is given by:\
  \

  #poll_answers(column-gutter: 2em,row-gutter: 2em,correct_answer: 2, students: students)[
    1. $ mat(2cos phi, -2sin phi; 2sin phi, 2cos phi) $
    3. $ mat(cos 2phi, -sin 2phi; sin 2phi, cos 2phi) $
    2. $ mat(cos phi^2, -sin phi^2; sin phi^2, cos phi^2) $
    4. $ mat(cos^2phi , sin^2 phi; sin^2 phi, cos^2 phi) $
  ]
]

== Rotation
#slide(slide-type: "academic reasoning")[
  Is the following statement true or false?\

  Let $A$ be the standard matrix of the transformation that rotates clockwise over $180 / n$ degrees in $bb(R)^2$, where $n gt.eq 2$ is a positive integer.\
  Then $A^n = - I_2.$\
\

  #poll_answers(cols: 1,correct_answer : 1, row-gutter: 1.7em, students : students)[
    1. True
    2. False
  ]
]

#let cypher_square = [
  
#grid( stroke: (thickness: 1.5pt, paint: MOOCorange), columns : (1.5em,)*7, rows: (1em,1em,.4em)*4, column-gutter: 0em, row-gutter: 0em, align: center + horizon, 
    [A],[B],[C],[D],[E],[F], [G],
    [1],[2],[3], [4], [5], [6], [7],
    grid.cell(colspan: 7,[]),
    [H], [I], [J], [K], [L], [M], [N],
    [8],[9],[10],[11],[12], [13],[14],
    grid.cell(colspan: 7,[]),
    [O], [P], [Q], [R], [S], [T], [U],
    [15], [16], [17], [18], [19], [20], [21],
    grid.cell(colspan: 7,[]),
    [V], [W], [X], [Y], [Z], [],[],
    [22], [23], [24], [25], [26], [], [],
    grid.cell(colspan: 7,[])
  )
  #v(-.5em)
  #align(center, text(size: 18pt, [*Table.* Character encoding]))
]


== Encryption
#slide(slide-type: "example")[
  #set text(size : 24pt)
  - Suppose you want to send an important \ message to one specific person so that if\ the message is intercepted, it can not \ easily be decrypted.
  - Then you should make it impossible to \ read for others, thus encrypt the message.
  \

  #grid( stroke: (thickness: 2pt, paint: tudelft-colors.primary), columns : (1.7em,)*16, rows: (1em,)*2, column-gutter: 0em, row-gutter: 0em, align: center + horizon, 
    [C],[O],[M],[P],[U],[T],[E],[R], [], [S], [C], [I], [E], [N], [C], [E],
    [3], [15], [13], [16], [21], [20], [5], [18], [0], [19], [3], [9], [5], [14], [3], [5],
  )
  #place(dx : 18cm, dy: -12cm, scale(x: 8.79cm, y: 8.79cm, cypher_square ))
]

== Encryption

  #grid( stroke: (thickness: 2pt, paint: tudelft-colors.primary), columns : (1.7em,)*16, rows: (1em,)*2, column-gutter: 0em, row-gutter: 0em, align: center + horizon, 
    [C],[O],[M],[P],[U],[T],[E],[R], [], [S], [C], [I], [E], [N], [C], [E],
    [#color("3", red)], [#color("15",red)], [#color("13",red)], [#color("16",red)], [21], [20], [5], [18], [0], [19], [3], [9], [5], [14], [3], [5],
  )

  $ M = text("Message") = 
        mat(#color("3",red), 21, 0, 5;
            #color("15", red),20, 19, 14;
            #color("13",red), 5, 3, 3;
            #color("16", red), 18, 9, 5 ) 
            #h(5em) K = text("Key") = 
            mat( 1, 1, 1, 1;
                 0 ,1, 1, 1;
                 0, 0, 1, 1;
                 0, 0, 0, 1)
            $

    $ text("Encrypted message") = K M = 
          mat(        
            47, 64, 31, 27;
            44, 43, 31, 22;
            29, 23, 12, 8;
            16, 8, 9, 5
          )
    $


== Encryption

$ text("Key") = 
            mat( 1, 1, 1, 1;
                 0 ,1, 1, 1;
                 0, 0, 1, 1;
                 0, 0, 0, 1)
           #h(24em) $

 $ #text("Encrypted message:" ) mat(
  16,30,43,50,15,22,29,46; 
15,14,30,30,15,21,20,30,;
1,9,21,21,14,5,1,21;
1, 9 , 1, 7 , 0 , 0 , 1, 7
) #h(6em) $
#v(1em)
*What was the original message?*
#place(dx : 12.33cm, dy: -16.5cm, scale(x: 7cm, y: 7cm, cypher_square))

== Questions?
#slide(slide-type: "questions")[]

= Transpose of  matrix

== The transpose of a matrix
#slide(slide-type : "definition")[
  #definition()[
    For any $m times n$ matrix $A$ the #underline[transpose] of $A$, denoted by $A^T$, is the matrix of size $n times m$ whose columns are formed from the corresponding rows of $A$.
  ]
  Example:
  
  $ mat(2&, -1&; 3, -2; 4, 5)^T  = mat( 2&, 3&, 4; -1, -2, 5) $
]

== Matrix transpose properties
#slide(slide-type : "polling")[
  Given two $m times n$ matrices $A$ and $B$.\
  Which of the statements are correct?
  #enum(numbering: "(i)", spacing: 1.3cm,
    [$(A^T)^T = A$;],
    [$(A+B)^T = A^T + B^T$]
  )
  #v(.5em)
  #poll_answers( cols: 1,row-gutter : 1.4em, correct_answer : 1, students: students)[    
    1. (i) is true, (ii) is true,
    2. (i) is true, (ii) is false,
    3. (i) is false, (ii) is true,
    4. (i) is false, (ii) is false
  ]
]

== Matrix product and transpose
#slide(slide-type : "polling")[
  For matrices \
  
  $A= mat(1, 2;3,4)$ and $B=mat(1&,2&;-1,1)$\
  
  which statement is correct?
  
  (i) $(A^2)^T = (A^T)^2$; (ii) $(A B)^T = A^T B^T$
  
  #poll_answers( cols: 1,row-gutter : 1.2em, correct_answer : 2, students: students)[
    1. (i) is true, (ii) is true,
    2. (i) is true, (ii) is false,
    3. (i) is false, (ii) is true,
    4. (i) is false, (ii) is false
  ]
]

== Properties of the transpose of a matrix
#slide(slide-type : "definition")[
  #theorem()[
    Let $A$ and $B$ be matrices such that the operations are defined.\
    
    #enum(numbering: "a.", spacing : 1em,
      [$(A^T)^T=A$],
      [$(A+B)^T=A^T + B^T$],
      [$(r A)^T = r A^T$ for any scalar $r$],
      [$(A B)^T = B^T A^T$]
    )
  ]
]

== Questions?
#slide(slide-type : "questions")[]

== Practice
#practice_slide()[
  - Transpose of a matrix
  #v(3em)
  $section$2.1: 15, 17, 19, 20, 23, 27, 29
  #v(4em)
  You are now able to
  #list( indent: 1.5em,
    [transpose a matrix]
  )
]


== Wrap up and next lecture
#wrapup_slide(topic: "Invertibility of matrices", book_sections: (2.2, 2.3 ))[
  Practice the topics of this lecture to:
  #set list(spacing: .6cm, indent: 1em)
  #set text(size: 23pt)
  #v(-.2cm)
  - add two matrices, if defined, and multiply a matrix by a scalar;
  - calculate the product of two matrices, if defined, using three techniques;
  - relate properties of a matrix product $A B$ to properties of the individual matrices $A$ and $B$;
  - transpose a matrix;
  - apply the calculation rules related to the aforementioned learning goals.
]


#title-slide(title: "See you next lecture", subtitle: "")[]
