#import "../codly.typ": *

#show: codly-init.with()

#let icon(codepoint) = {
  box(
    height: 0.8em,
    baseline: 0.05em,
    image(codepoint)
  )
  h(0.1em)
}

#codly(languages: (
  rust: (name: "Rust", icon: icon("brand-rust.svg"), color: rgb("#CE412B")),
  python: (name: "Python", icon: icon("brand-python.svg"), color: rgb("#3572A5")),
))

```rust
pub fn main() {
    println!("Hello, world!");
}
```

```python
def fibonaci(n):
    if n <= 1:
        return n
    else:
        return(fibonaci(n-1) + fibonaci(n-2))
```

We can also set a line number offset with `codly-offset(int)`:

#codly-offset(offset: 1)
```rust
    println!("Hello, world!");
```

We are also able to control line numbers alignment:

`#codly(number-align: horizon)`
#codly(number-align: horizon)
```python
import numpy as np
print(np.array([np.random.randint(1, 100) for _ in range(1000)]), np.array([np.random.normal(0, 1) for _ in range(1000)]), np.array([np.random.uniform(0, 1) for _ in range(1000)]))
```
`#codly(number-align: top)`
#codly(number-align: top)
```python
import numpy as np
print(np.array([np.random.randint(1, 100) for _ in range(1000)]), np.array([np.random.normal(0, 1) for _ in range(1000)]), np.array([np.random.uniform(0, 1) for _ in range(1000)]))
```

And we can also disable line numbers:

#codly(number-format: none)

```rust
pub fn main() {
    println!("Hello, world!");
}
```

We can also select only a range of lines to show:

#codly-range(start: 5, end: 5)

```python
def fibonaci(n):
    if n <= 1:
        return n
    else:
        return(fibonaci(n-1) + fibonaci(n-2))
```

#codly(
  stroke: 1pt + red,
)

```rust
pub fn main() {
    println!("Hello, world!");
}
```


#codly(
  display-icon: false,
  stroke: 1pt + luma(240),
  zebra-fill: luma(240),
  number-format: none,
)

```rust
pub fn main() {
    println!("Hello, world!");
}
```

```rust
pub fn function<R, S, T>() -> R where T: From<S>, S: Into<R>, R: Send + Sync + 'static {
    println!("Hello, world!");
}
```

#v(25%)

#codly(
  breakable: true
)

```rust
pub fn main() {
    println!("This is in another page!")
}
```

#codly(number-format: (x) => strong(str(x)))

```rust
pub fn main() {
    println!("Strong line numbers go brrrrrrr.");
}
```

#codly(lang-format: (..) => [ No, I don't think I will. ], number-format: (s) => str(s))
```rust
pub fn main() {
    println!("Strong line numbers go brrrrrrr.");
}
```

= Empty line test with line number disabled.
#codly(lang-format: none, number-format: none)
```rust
pub fn main() {
    println!("Strong line numbers go brrrrrrr.");

}
```

= Test of smart indent
#codly(lang-format: none, number-format: none, smart-indent: true)
#box(width: 50%,
    ```rust
    pub fn main() {
        println!("Strong line numbers go brrrrrrr.");
    }
    ```
)
