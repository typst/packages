# Tinyset
Extremely simple [typst](https://github.com/typst/typst) package for writing
math problem sets quickly and consistently. Under the hood it is just typst fundamentals that could be defined by hand, however the aim of this package is to make you faster and the code easier to read.

## Usage
Import styles and create a new header. I like to copy this from the top of the
previous week's homework (don't forget to increment the number!).

Example using proof, question, and part environments. Indentation in source code is largely ignored and left to personal preference. By default questions are numbered and each part is lettered, you can change this based on course / instructor preference.

```typ
#import "@preview/tinyset:0.1.0": *
#header(number: 7, name: "Sylvan Franklin", class: "Math 3551 - Fall 2024")

+ #qs[
Let $G_1$ and $G_2$ be groups, $phi : G_1 -> G_2$ be a homomorphism, and $H$ be
any subgroup of $G_2$. Define

$ phi^(-1)(H) = {g in G_1 : phi(g) in H}. $

+ #pt[ 
    Prove that $phi^(-1)(H)$ is a subgroup of $G_1$.
    #prf[ Non empty: Since $H$ is a subgroup it contains the indentity, and
    since $phi$ is a homomorphism and ... ]
]

+ #pt[ 
    What about a question that you don't need a proof for?
    #ans[Use the ans environment]
]

]

```
## Custom shorthand

Sometimes when thinking about math I find it easier to phonetically write out these symbols instead of using the built in typst classes. For certain others I find the original symbols annoying to type quickly.  

| shorthand | expansion |
| --- | --- |
| implies / impl | ==> |
| iff | <==> |
| wlog | without loss of generality |
| inv(<expression>) | (<epression>)^(-1) |

