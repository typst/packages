#import "../ebnf.typ": *
#set page(width: auto, height: auto, margin: .5cm, fill: white)

// Rust grammar example with custom fonts (uses default colorful scheme)
#ebnf(
  mono-font: "JetBrains Mono",
  body-font: "DejaVu Serif",
  Prod(
    N[Function],
    {
      Or[#Opt[#T[pub]] #T[fn] #N[Ident] #Opt[#N[Generics]] #T[\(] #Opt[#N[Params]] #T[\)] #Opt[#N[ReturnType]] #N[Block]][function definition]
    },
  ),
  Prod(
    N[Generics],
    {
      Or[#T[\<] #N[GenericParam] #Rep[#T[,] #N[GenericParam]] #T[\>]][generic parameters]
    },
  ),
  Prod(N[GenericParam], {
    Or[#N[Ident] #Opt[#T[:] #N[Bounds]]][type parameter]
    Or[#N[Lifetime]][lifetime parameter]
  }),
  Prod(N[Bounds], {
    Or[#N[Bound] #Rep[#T[+] #N[Bound]]][trait bounds]
  }),
  Prod(N[ReturnType], {
    Or[#T[\-\>] #N[Type]][return type]
  }),
  Prod(N[Type], {
    Or[#N[Ident] #Opt[#N[Generics]]][named type]
    Or[#T[&] #Opt[#N[Lifetime]] #Opt[#T[mut]] #N[Type]][reference type]
    Or[#T[\[] #N[Type] #T[\]]][slice type]
    Or[#Grp[#T[\(] #N[Type] #Rep[#T[,] #N[Type]] #T[\)]]][tuple type]
  }),
  Prod(N[Lifetime], {
    Or[#T[\'] #N[Ident]][lifetime]
  }),
  Prod(
    N[Struct],
    {
      Or[#Opt[#T[pub]] #T[struct] #N[Ident] #Opt[#N[Generics]] #T[\{] #Rep[#N[Field]] #T[\}]][struct definition]
    },
  ),
  Prod(N[Field], {
    Or[#Opt[#T[pub]] #N[Ident] #T[:] #N[Type] #Opt[#T[,]]][field]
  }),
)
