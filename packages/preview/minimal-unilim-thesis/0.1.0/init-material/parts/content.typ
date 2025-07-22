// install from typst univers
#import "@preview/minimal-unilim-thesis:0.1.0":*

// install in local version
// #import "@local/minimal-unilim-thesis:0.1.0":*


// local development 
// #import "../../lib.typ":*


= chapter 1:
== subtitle  

#lorem(30)
#figure(
  image("../resources/my-ressource.png", width: 50%),
  caption: [example]
)

#lorem(30)
== subtitle 
#lorem(30)
== subtitle 
#pseudocode(
  ```c
  #Define MAX_SIZE 45

  int i = 0;

  for (i=0; i<MAX_SIZE; i++)
    printf("Hello, world!");
  ```,
  size: 50% //optional
)
= chapter 2: 
== subtitle
#lorem(30)
== subtitle


*HQC*@aragon-hamming-nodate

Encryption:
$bold(c) = bold(m) * bold(G) + bold(e)$

Syndrome:
$bold(s) = bold(c) * bold(H)^T$

Hamming weight of a error vector:
$"wt"_H(bold(e)) = w$

Quasi-cyclic structure (rotation) :
$bold(m) * bold(G) = sum_{i=0}^{n-1} m_i * "rot"_i(bold(g))$

Fundamental problem (syndrome decoding) :
$bold(H) * bold(e)^T = bold(s)$

Decryption: $hat(bold(m)) = bold(c) - hat(bold(e)) * bold(G)$

== subtitle

= chapter 3: 
== subtitle
#figure(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3], [0.7], [0.5],
  ),
  caption: [Example],
)
#lorem(30)#footnote()[This a foonote]
== subtitle
== subtitle