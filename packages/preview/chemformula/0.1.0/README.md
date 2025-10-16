# chemformula
Typst Packages for easy and extensible chemical formula formatting.
This provide a `ch` function for writing chemical notations. 
Chemformula uses Typst's [math mode](https://typst.app/docs/reference/math/) to [evaluate](https://typst.app/docs/reference/foundations/eval/) the input string (or raw) in the `ch` function and render them into the document. 

## Examples 

### Chemical Formulae
The number preceding by other letters is subscripted by default.
```typ
#ch("H2O")

#ch("Sb2O3")
```
<img alt="example-01" src="https://github.com/user-attachments/assets/17373f66-373d-49ed-b497-16241df870c4" />

### Chemical Equations
You can use `->` to draw arrow. The length will changes according to the content being above or below the arrow. The arrow is rendered using Typst's [stretch function](https://typst.app/docs/reference/math/stretch/).
```typ
#ch("CO2 + C -> 2 CO")

// Multilines are allowed!
#ch("Hg^2+ ->[I^-] HgI2
           ->[I^-] [Hg^II I4]^2- ")
```
<img alt="example-02" src="https://github.com/user-attachments/assets/c986a131-9765-4118-9cc9-303ce88d0c16" />

### Charges
Plus and minus signs coming after the text are superscript positioned by default. However, you may use `^` operator to raise them upper. The `^` operator will superscript the content until a space or a semicolon (`;`) is typed.
```typ
#ch("H+")

#ch("CrO4^2-") // or 
#ch("CrO4 ^2-") // IUPAC recommended

#ch("[AgCl2]-")

#ch("Y^99+") // or
#ch("Y^(99+)") // Same
```
<img alt="example-03" src="https://github.com/user-attachments/assets/733f34c4-b12e-4c58-a569-897b6f37dd99" />

### Oxidation States 
Typing `^^` gives the ability to put things above the elements. This operator captures content in parenthesis/or until black space is met.
```typ
#ch("Fe^^II Fe^^III_2 O4") // or 
#ch("Fe^^(II)Fe^^(III)_(2)O4") // Same
```
<img alt="example-04" src="https://github.com/user-attachments/assets/998bb37f-5368-41f6-b847-676a946af992" />

### Stoichiometric Numbers 
Since the content is evaluated in math mode, the fractions are rendered by default. If one space is present between the compound and digits, then thin space is used. If more than one spaces are typed, then full one normal space will be used.
```typ
#ch("2H2O") // Tight 

#ch("2 H2O") // Spaced 

#ch("2  H2O") // Very Spaced 

#ch("1/2 H2O") // Automatic Fractions 

#ch("1\/2 H2O") // 
```
<img  alt="example-05" src="https://github.com/user-attachments/assets/9713350a-43db-416d-8bc7-52ca6a48ae6a" />

### Nuclides, Isotopes 
The syntax writing nuclides is *preceding* the `^` for mass number or `_` for atomic number with space/or begining of the string. Otherwise, the operator will attach to the preceding content.
```typ
#ch("^227_90 Th+")

#ch("^227_(90)Th+")

#ch("^0_-1 n-")

#ch("_-1^0 n-")
```
<img  alt="example-06" src="https://github.com/user-attachments/assets/f09940cb-58db-4a9d-a90c-f9d629f369d4" />

### Parenthesis, Braces, Brackets
In Typst, parentheses are automatically sized by default. If you finding this ugly, you can disrupt them by typing `\` before the parentheses group. To force a group of parenthesis between substances to big-size, wrap the whole reaction with [display](https://typst.app/docs/reference/introspection/counter/#definitions-display) function.
```typ
#ch("(NH4)2S") // Automatic sizing 

#ch("[{(X2)3}2]^3+") 

#ch("\[{(X2)3}2]^3+") // To disable this behavior, just type `\`

$display(ch("CH4 + 2(O2 + 7/2N2)"))$ // Hack with math mode
```
<img  alt="example-07" src="https://github.com/user-attachments/assets/37520c8e-d760-406a-9e95-9ac9e870a193" />

### States of Aggregation 
Normally, lower case letters are considered math variables, and multiple form of them will be symbol/variable call. This follows the Typst's naive math syntax. However, `(aq)` is preserved by the parser as math variable that evaluates to `$a q$`. 
```typ
#ch("H2(aq)")

#ch("CO3^2-_((aq))")

#ch("NaOH(aq, $oo$)")
```
<img alt="example-08" src="https://github.com/user-attachments/assets/a73906d3-2fec-47f7-8573-be5919a43c06" />

You can use `$..$` syntax for escaping the parser so that the content inside will be directly evaluated by math mode. 


### Radical Dots 
`*` or `.` in superscript and subscript mode will be used as radical notation. This uses `sym.bullet` to display.
```typ
#ch("OCO^*-")

#ch("NO^((2*)-)")
```
<img alt="example-09" src="https://github.com/user-attachments/assets/81bd6016-e607-44a0-80c9-c1d9dd58dafe" />

### Escaped Modes
Contents inside `$..$` will be escaped by the parser and evaluated in math mode directly bypassing other grammars.  So you can type greek letters or other variables in math in this mode, for example.
```typ
// Use Math Mode!
#ch("NO_x") is the same as #ch("NO_$x$")

#ch("Fe^n+") is the same as #ch("Fe^$n+$")

#ch("Fe(CN)_$6/2$") // Fractions!

#ch("$#[*CO*]$_2^3") // bold text 

// Or just type texts...
#ch("mu\"-\"Cl") // Hyphen Escaped
```
<img alt="example-10" src="https://github.com/user-attachments/assets/c8f04a9f-8969-431f-84b8-390a7323b192" />

## Reaction Arrows 
```typ
#ch("A -> B")

#ch("A <- B")

#ch("A <-> B")

#ch("A <=> B")
```
<img  alt="example-11" src="https://github.com/user-attachments/assets/b75faaf3-ca93-467e-b6c6-6303c29da129" />

### Above/Below Arrow Text 
```typ
#ch("A ->[Delta] B")

#ch("A <=>[Above][Below] B")

#ch("CH3COOH <=>[+ OH-][+ H+] CH3COO-")
```
<img alt="example-12" src="https://github.com/user-attachments/assets/34d651ce-e4c3-4933-833e-d3b36e33bcb8" />

### Precipitation and Gas 
This feature has *very* dedicate syntax: the `^` or `v` must precede -and- folows by white space.
```typ
#ch("SO4^2- + Ba^2+ -> BaSO4 v")

#ch("A v B v -> B ^ B ^")
```
<img  alt="example-13" src="https://github.com/user-attachments/assets/f52e47bb-ed98-487b-a525-ca3f567de329" />

### Alignments
```typ
$ ch("A &-> B") \
  ch("B &-> C + D")
$
```
<img  alt="example-14" src="https://github.com/user-attachments/assets/9bf7f6a3-92bf-40b8-a9fc-20a178b10bcd" />

### More Examples 
Integration seamlessly with Typst's math mode.
```typ
$  
  ch("Zn^2+ <=>[+ 2 OH-][+ 2 H+]")
  limits(ch("Zn(OH)2 v"))_"amphoteres Hydroxid"
  ch("<=>[+ 2 OH-][+ 2H+]")
  limits(ch("[Zn(OH)4]^2-"))_"Hydroxozikat"
$
```
<img alt="example-15" src="https://github.com/user-attachments/assets/4da96416-ec73-4100-af90-23610ac7b3b1" />

You can use user-defined functions in `ch`. Howeer, you must add the definition of this function into the `scope` parameter of `ch`.

```typ
#let tg = text.with(fill: olive)
#let ch = ch.with(scope: (tg: tg, ch: ch))
$ ch("Cu^^II Cl2 + K2CO3 -> tg(Cu^^II)CO3 v + 2 KCl") $

$ ch("Hg^2+ ->[I-] HgI2
            ->[I-] [Hg^II I4]^2-
") $
```
<img alt="example-16" src="https://github.com/user-attachments/assets/a870ad91-612e-471f-8bf6-ea8211311e08" />


# Acknowledgement 
This packages' examples and syntax are highly inspired by [mhchem](https://ctan.org/pkg/mhchem?lang=en) package. Please feel free to give any suggestions for improving the feature of this package!
