#import "../ebnf.typ": *
#set page(width: auto, height: auto, margin: .5cm, fill: white)

// Rust grammar example with custom font (uses default colorful scheme)
#ebnf(
  mono-font: "JetBrains Mono",
  prod(
    n[Function],
    {
      alt[#opt[#t[pub]] #t[fn] #n[Ident] #opt[#n[Generics]] #t[\(] #opt[#n[Params]] #t[\)] #opt[#n[ReturnType]] #n[Block]][function definition]
    },
  ),
  prod(
    n[Generics],
    {
      alt[#t[\<] #n[GenericParam] #rep[#t[,] #n[GenericParam]] #t[\>]][generic parameters]
    },
  ),
  prod(n[GenericParam], {
    alt[#n[Ident] #opt[#t[:] #n[Bounds]]][type parameter]
    alt[#n[Lifetime]][lifetime parameter]
  }),
  prod(n[Bounds], {
    alt[#n[Bound] #rep[#t[+] #n[Bound]]][trait bounds]
  }),
  prod(n[ReturnType], {
    alt[#t[\-\>] #n[Type]][return type]
  }),
  prod(n[Type], {
    alt[#n[Ident] #opt[#n[Generics]]][named type]
    alt[#t[&] #opt[#n[Lifetime]] #opt[#t[mut]] #n[Type]][reference type]
    alt[#t[\[] #n[Type] #t[\]]][slice type]
    alt[#grp[#t[\(] #n[Type] #rep[#t[,] #n[Type]] #t[\)]]][tuple type]
  }),
  prod(n[Lifetime], {
    alt[#t[\'] #n[Ident]][lifetime]
  }),
  prod(
    n[Struct],
    {
      alt[#opt[#t[pub]] #t[struct] #n[Ident] #opt[#n[Generics]] #t[\{] #rep[#n[Field]] #t[\}]][struct definition]
    },
  ),
  prod(n[Field], {
    alt[#opt[#t[pub]] #n[Ident] #t[:] #n[Type] #opt[#t[,]]][field]
  }),
)
