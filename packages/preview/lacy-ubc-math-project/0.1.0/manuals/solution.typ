#import "../format.typ": solution

= Solution
The `solution()` function is to create a solution block.
#block(
  breakable: false,
  grid(
    columns: 2,
    gutter: 1em,
    align: horizon,
    ```typst
    #solution[
      The solution to the question.
      // Change color, remove supplement
      #solution(color: orange, supplement: none)[
        Sub-solution.
      ]
      // Change supplement
      #solution(supplement: [*My Answer*: ])[
        Another sub-solution.
      ]
    ],
    ```,
    solution[
      The solution to the question.
      // Change color, remove supplement
      #solution(color: orange, supplement: none)[
        Sub-solution.
      ]
      // Change supplement
      #solution(supplement: [*My Answer*: ])[
        Another sub-solution.
      ]
    ],
  ),
)

Solution is usually put in a question block as a response to it.
```typst
#question(1)[
  What is the answer to the universe, life, and everything?
  #solution[ The answer is 42. ]
]
```
