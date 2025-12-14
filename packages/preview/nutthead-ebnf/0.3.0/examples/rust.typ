#import "@preview/nutthead-ebnf:0.3.0": *

#set page(paper: "a6", flipped: true)

#context [
  #ebnf[
    #[
      #syntax-rule(
        meta-id: [Function],
        example: [`fn main() { }`],
        definition-list: (
          (indent: 1),
          [
            #single-definition(illumination: "dimmed")[FunctionQualifiers]
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
            #grouped-sequence[
              #single-definition[BlockExpression]
              #terminal(illumination: "dimmed")[;]
            ]
          ],
        ),
      )
    ]
  ]
]
