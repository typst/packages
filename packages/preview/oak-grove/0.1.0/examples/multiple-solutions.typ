#import "/src/lib.typ" as oak

#show: oak.set-config(
  // This font size will be applied to code solutions. It will not affect solution descriptions
  // nor solution bodies that have more content other than a raw text block.
  code-size: 8pt
)

#let data = (
  oak.section(
    "Basic problems",
    descr: [
      Easy problems to get started. This text will only appear in the list.
    ],
    (
      oak.problem(
        "Hello world!",
        descr: [
          You should do this problem first.
        ],
        [
          A text solution.

          This one's easy.
        ],
      ),
      oak.problem("Siracusa function", "P52109", ```cpp
      // A code solution.

      #include <iostream>
      using namespace std;

      int main() {
          int n;
          while (cin >> n) {
              n = 3 * n + 1;
              while (n % 2 == 0) {
                  n /= 2;
              }
              cout << n << '\n';
          }
      }
      ```),
    ),
  ),
  oak.section(
    "Advanced problems",
    descr-sol: [
      These were much harder than I expected. This text will only appear in the solutions section.
    ],
    (
      oak.problem(
        "Turning off lights",
        "P63648",
        descr-sol: [
          This problem has 3 solutions.
        ],
        (
          oak.solution(
            [
              Solution body is a positional parameter for `oak.solution`, that is, you do not need to put `body: ` in front of it.
            ]
          ),
          [
            Use your brain.

            Here's some code _not_ affected by `config.code-size`:

            ```js
            var add = require("add")
            console.log(add(2, 2))
            ```
          ],
          oak.solution(
            title: [This one even has a _title_.],
            descr: [Hmmm... A description before a code solution. This one _is_ a named parameter.],
            ```py
            from problemsolver import solve
            data = input()
            print(solve(data))
            ```
          ),
        ),
      ),
      oak.problem("Adding subrectangles", "P88567"),
      // this problem doesn't have a solution, so it will be ommitted in the solutions section.
    ),
  ),
)

= Problem list

#oak.problems-list(
  data,
)

#pagebreak()

= Solutions
#oak.problems-solutions(
  data,
)

