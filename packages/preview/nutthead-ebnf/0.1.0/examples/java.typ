#import "@preview/nutthead-ebnf:0.1.0": *

#set page(width: auto, height: auto, margin: .5cm, fill: white)

// Java grammar example with custom font
#ebnf(
  mono-font: "Fira Mono",
  prod(
    n[ClassDecl],
    {
      alt[#opt[#n[Modifier]] #t[class] #n[Ident] #opt[#t[extends] #n[Type]] #n[ClassBody]][class declaration]
    },
  ),
  prod(n[Modifier], {
    alt[#t[public]][access modifier]
    alt[#t[private]][]
    alt[#t[protected]][]
    alt[#t[static]][other modifiers]
    alt[#t[final]][]
    alt[#t[abstract]][]
  }),
  prod(n[ClassBody], {
    alt[#t[\{] #rep[#n[Member]] #t[\}]][class body]
  }),
  prod(n[Member], {
    alt[#n[FieldDecl]][member declaration]
    alt[#n[MethodDecl]][]
    alt[#n[ConstructorDecl]][]
  }),
  prod(
    n[MethodDecl],
    {
      alt[#rep[#n[Modifier]] #n[Type] #n[Ident] #t[\(] #opt[#n[Params]] #t[\)] #n[Block]][method]
    },
  ),
  prod(n[Params], {
    alt[#n[Param] #rep[#t[,] #n[Param]]][parameter list]
  }),
  prod(n[Type], {
    alt[#n[PrimitiveType]][type]
    alt[#n[ReferenceType]][]
  }),
  prod(n[PrimitiveType], {
    alt[#t[int]][primitive types]
    alt[#t[boolean]][]
    alt[#t[char]][]
    alt[#t[void]][]
  }),
)
