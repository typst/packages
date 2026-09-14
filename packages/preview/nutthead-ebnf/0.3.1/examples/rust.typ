#import "@preview/nutthead-ebnf:0.3.1": *

#set page(paper: "a6", flipped: true)

#context [
  #ebnf[
    #[
      #syntax-rule(
        meta-id: [Function],
        rule-example: [```rust fn main() { }```],
        definition-list: (
          (indent: 1),
          [
            #single-definition[FunctionQualifiers]
            #terminal[fn]
            #single-definition[IDENTIFIER]
            #single-definition(illumination: "dimmed", qualifier: "opt")[GenericParams]
          ],
          (indent: 2),
          [
            #terminal[(]
            #single-definition(qualifier: "opt")[FunctionParameters]
            #terminal[)]
          ],
          [
            #single-definition(illumination: "dimmed", qualifier: "opt")[FunctionReturnType]
            #single-definition(illumination: "dimmed", qualifier: "opt")[WhereClause]
          ],
          [
            #grouped-sequence(
              single-definition[BlockExpression],
              terminal(illumination: "dimmed")[;],
            )
          ],
        ),
      )

      #syntax-rule(
        meta-id: [FunctionQualifiers],
        rule-example: [```rust const```],
        definition-list: (
          (indent: 1),
          [
            #terminal(qualifier: "opt")[const]
            #terminal(qualifier: "opt")[async]
            #single-definition(qualifier: "opt")[ItemSafety]
            #grouped-sequence(
              qualifier: "opt",
              [
                #terminal[extern]
                #single-definition(qualifier: "opt")[Abi]
              ],
            )
          ],
        ),
      )
    ]
  ]
]
