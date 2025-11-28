#import "../ebnf.typ": *
#set page(width: auto, height: auto, margin: .5cm, fill: white)

// Java grammar example with custom fonts
#ebnf(
  mono-font: "Fira Mono",
  body-font: "IBM Plex Serif",
  Prod(
    N[ClassDecl],
    {
      Or[#Opt[#N[Modifier]] #T[class] #N[Ident] #Opt[#T[extends] #N[Type]] #N[ClassBody]][class declaration]
    },
  ),
  Prod(N[Modifier], {
    Or[#T[public]][access modifier]
    Or[#T[private]][]
    Or[#T[protected]][]
    Or[#T[static]][other modifiers]
    Or[#T[final]][]
    Or[#T[abstract]][]
  }),
  Prod(N[ClassBody], {
    Or[#T[\{] #Rep[#N[Member]] #T[\}]][class body]
  }),
  Prod(N[Member], {
    Or[#N[FieldDecl]][member declaration]
    Or[#N[MethodDecl]][]
    Or[#N[ConstructorDecl]][]
  }),
  Prod(
    N[MethodDecl],
    {
      Or[#Rep[#N[Modifier]] #N[Type] #N[Ident] #T[\(] #Opt[#N[Params]] #T[\)] #N[Block]][method]
    },
  ),
  Prod(N[Params], {
    Or[#N[Param] #Rep[#T[,] #N[Param]]][parameter list]
  }),
  Prod(N[Type], {
    Or[#N[PrimitiveType]][type]
    Or[#N[ReferenceType]][]
  }),
  Prod(N[PrimitiveType], {
    Or[#T[int]][primitive types]
    Or[#T[boolean]][]
    Or[#T[char]][]
    Or[#T[void]][]
  }),
)
