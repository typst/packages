#import "/src/lib.typ" as oak

#show: oak.set-config()

#let data = (
  oak.section(
    "Basic problems",
    descr: [
      Easy problems to get started. This text will only appear in the list.
    ],
    (
      oak.problem("Hello world!", [
        A text solution.

        This one's easy.
      ]),
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
      oak.problem("Turning off lights", "P63648"),
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

