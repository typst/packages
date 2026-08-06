# iridis

Iridis is a package to colorize parenthesis in your typst document. Iridis is a latin word that means "rainbow". This package is inspired by the many rainbow parenthesis plugins available for code editors.


## Usage

The package provides a single show-rule `iridis-show` that can be used to colorize parenthesis in your document and a palette `iridis-palette` that can be used to define the colors used.

The rule takes 3 arguments:
- `opening-parenthesis`: The opening parenthesis character. Default is `("(", "[", "{")`.
- `closing-parenthesis`: The closing parenthesis character. Default is `(")", "]", "}")`.
- `palette`: The color palette to use. Default is `iridis-palette`.

If the symbols are single characters, they are interpreted as normal strings but if you use multi-character strings, then they are interpreted as regular expressions.

## Exemples

````typ
#show: iridis.iridis-show

```rs
fn main() {
    let n = false;
    if n {
        println!("Hello, world!");
    } else {
        println!("Goodbye, world!");
    }
}
```

```cpp
#include <iostream>

int main() {
    bool n = false;
    if (n) {
        std::cout << "Hello, world!" << std::endl;
    } else {
        std::cout << "Goodbye, world!" << std::endl;
    }
}
```

```py
if __name__ == "__main__":
    n = False
    if n:
        print("Hello, world!")
    else:
        print("Goodbye, world!")
```
````

![example of code coloration](https://raw.githubusercontent.com/Robotechnic/iridis/0.2.0/tests/code/ref/1.png)

```typ
#show: iridis.iridis-show

$
    "plus" equiv lambda m. f lambda n. lambda f. lambda x. m f (n f x) \
    "succ" equiv lambda n. lambda f. lambda x. f (n f x) \
    "mult" equiv lambda m. lambda n. lambda f. lambda x. m (n f) x \
    "pred" equiv lambda n. lambda f. lambda x. n (lambda g. lambda h. h (g f)) (lambda u. x) (lambda u. u) \
    "zero" equiv lambda f. lambda x. x \
    "one" equiv lambda f. lambda x. f x \
    "two" equiv lambda f. lambda x. f (f x) \
    "three" equiv lambda f. lambda x. f (f (f x)) \
    "four" equiv lambda f. lambda x. f (f (f (f x))) \
$

$
    (((1 + 5) times 7) / (5 - 8 times 7) + 3) times 2 approx 4.352941176
$

$ mat(
  1, 2, ..., (10 / 2);
  2, 2, ..., 10;
  dots.v, dots.v, dots.down, dots.v;
  10, (10 - (5 times 8)) / 2, ..., 10;
) $

$
[1;2]
$

$
{a, forall a in A | exists b in [5;10]. a times b > 10}
$
```

![example of math coloration](https://raw.githubusercontent.com/Robotechnic/iridis/0.2.0/tests/math/ref/1.png)

## Changelog

### 0.2.0

- Update the package to work with typst 0.15.0

### 0.1.0

- Initial release
