#import "../ebnf.typ": *

#set page(width: auto, height: auto, margin: .5cm, fill: white)

// Rust grammar example with custom font (uses default colorful scheme)
#syntax(
  mono-font: "JetBrains Mono",
  syntax-rule(
    meta-identifier[Function],
    {
      definitions-list[#optional-sequence[#terminal-string[pub]] #terminal-string[fn] #meta-identifier[Ident] #optional-sequence[#meta-identifier[Generics]] #terminal-string[\(] #optional-sequence[#meta-identifier[Params]] #terminal-string[\)] #optional-sequence[#meta-identifier[ReturnType]] #meta-identifier[Block]][function definition]
    },
  ),
  syntax-rule(
    meta-identifier[Generics],
    {
      definitions-list[#terminal-string[\<] #meta-identifier[GenericParam] #repeated-sequence[#terminal-string[,] #meta-identifier[GenericParam]] #terminal-string[\>]][generic parameters]
    },
  ),
  syntax-rule(meta-identifier[GenericParam], {
    definitions-list[#meta-identifier[Ident] #optional-sequence[#terminal-string[:] #meta-identifier[Bounds]]][type parameter]
    definitions-list[#meta-identifier[Lifetime]][lifetime parameter]
  }),
  syntax-rule(meta-identifier[Bounds], {
    definitions-list[#meta-identifier[Bound] #repeated-sequence[#terminal-string[+] #meta-identifier[Bound]]][trait bounds]
  }),
  syntax-rule(meta-identifier[ReturnType], {
    definitions-list[#terminal-string[\-\>] #meta-identifier[Type]][return type]
  }),
  syntax-rule(meta-identifier[Type], {
    definitions-list[#meta-identifier[Ident] #optional-sequence[#meta-identifier[Generics]]][named type]
    definitions-list[#terminal-string[&] #optional-sequence[#meta-identifier[Lifetime]] #optional-sequence[#terminal-string[mut]] #meta-identifier[Type]][reference type]
    definitions-list[#terminal-string[\[] #meta-identifier[Type] #terminal-string[\]]][slice type]
    definitions-list[#grouped-sequence[#terminal-string[\(] #meta-identifier[Type] #repeated-sequence[#terminal-string[,] #meta-identifier[Type]] #terminal-string[\)]]][tuple type]
  }),
  syntax-rule(meta-identifier[Lifetime], {
    definitions-list[#terminal-string[\'] #meta-identifier[Ident]][lifetime]
  }),
  syntax-rule(
    meta-identifier[Struct],
    {
      definitions-list[#optional-sequence[#terminal-string[pub]] #terminal-string[struct] #meta-identifier[Ident] #optional-sequence[#meta-identifier[Generics]] #terminal-string[\{] #repeated-sequence[#meta-identifier[Field]] #terminal-string[\}]][struct definition]
    },
  ),
  syntax-rule(meta-identifier[Field], {
    definitions-list[#optional-sequence[#terminal-string[pub]] #meta-identifier[Ident] #terminal-string[:] #meta-identifier[Type] #optional-sequence[#terminal-string[,]]][field]
  }),
)
