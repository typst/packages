#import "../ebnf.typ": *

#set page(width: auto, height: auto, margin: .5cm, fill: white)

// Java grammar example with custom font
#syntax(
  mono-font: "Fira Mono",
  syntax-rule(
    meta-identifier[ClassDecl],
    {
      definitions-list[#optional-sequence[#meta-identifier[Modifier]] #terminal-string[class] #meta-identifier[Ident] #optional-sequence[#terminal-string[extends] #meta-identifier[Type]] #meta-identifier[ClassBody]][class declaration]
    },
  ),
  syntax-rule(meta-identifier[Modifier], {
    definitions-list[#terminal-string[public]][access modifier]
    definitions-list[#terminal-string[private]][]
    definitions-list[#terminal-string[protected]][]
    definitions-list[#terminal-string[static]][other modifiers]
    definitions-list[#terminal-string[final]][]
    definitions-list[#terminal-string[abstract]][]
  }),
  syntax-rule(meta-identifier[ClassBody], {
    definitions-list[#terminal-string[\{] #repeated-sequence[#meta-identifier[Member]] #terminal-string[\}]][class body]
  }),
  syntax-rule(meta-identifier[Member], {
    definitions-list[#meta-identifier[FieldDecl]][member declaration]
    definitions-list[#meta-identifier[MethodDecl]][]
    definitions-list[#meta-identifier[ConstructorDecl]][]
  }),
  syntax-rule(
    meta-identifier[MethodDecl],
    {
      definitions-list[#repeated-sequence[#meta-identifier[Modifier]] #meta-identifier[Type] #meta-identifier[Ident] #terminal-string[\(] #optional-sequence[#meta-identifier[Params]] #terminal-string[\)] #meta-identifier[Block]][method]
    },
  ),
  syntax-rule(meta-identifier[Params], {
    definitions-list[#meta-identifier[Param] #repeated-sequence[#terminal-string[,] #meta-identifier[Param]]][parameter list]
  }),
  syntax-rule(meta-identifier[Type], {
    definitions-list[#meta-identifier[PrimitiveType]][type]
    definitions-list[#meta-identifier[ReferenceType]][]
  }),
  syntax-rule(meta-identifier[PrimitiveType], {
    definitions-list[#terminal-string[int]][primitive types]
    definitions-list[#terminal-string[boolean]][]
    definitions-list[#terminal-string[char]][]
    definitions-list[#terminal-string[void]][]
  }),
)
