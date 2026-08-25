#import "/src/lib.typ" as oak

#show: oak.set-config(
  tags: (
    oak.tag("easy", green.darken(50%)),
    oak.tag("normal"),
    oak.tag("internalName", "display name", yellow.darken(40%))
  )

)

#let data = (
  oak.problem("Hello world!", [
    A text solution.

    This one's easy.
  ], tags: ("easy", "internalName")),
  oak.problem("Siracusa function", ```cpp
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
  ```, tags: ("normal")),
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

