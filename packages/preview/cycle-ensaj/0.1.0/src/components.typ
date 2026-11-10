
//good looking code blocks like the ones you see in chatgpt code generation !!!

#let achraf-code-block = (code, langue) => (
  align(
    left,
    rect(
      width: 15cm,
      block[
        #align(left)[
          #text(
            size: 8pt,
            fill: rgb(90,90,90),
            "</ > " + lower(langue)
          )
          
          #v(6pt)
          
          #block[#raw(code, lang: langue)]
        ]
      ],
      stroke: white,
      fill: rgb(120, 120, 120).transparentize(95%),
      radius: (
        top-left: 10pt,
        top-right: 5pt,
        bottom-left: 15pt,
        bottom-right: 15pt,
      ),
    )
  )
)
