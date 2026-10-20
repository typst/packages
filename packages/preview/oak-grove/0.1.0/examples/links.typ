#import "/src/lib.typ" as oak

#show: oak.set-config(
  link: "https://jutge.org/problems/"
  // or specify a function for more advanced behaviour
  // link: (problem) => {
  //   return "https://jutge.org/problems/" + problem.id
  // }
)

#show link: text.with(blue.darken(50%))
#show link: underline


#let data = (
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

