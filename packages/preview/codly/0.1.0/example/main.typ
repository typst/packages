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
  rust: (name: "Rust", icon: icon("brand-python.svg"), color: rgb("#CE412B")),
  python: (name: "Python", icon: icon("brand-rust.svg"), color: rgb("#3572A5")),
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

And we can also disable line numbers:

#codly(width-numbers: none)

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
  stroke-width: 1pt,
  stroke-color: red,
)

```rust
pub fn main() {
    println!("Hello, world!");
}
```


#codly(
  display-icon: false,
)

```rust
pub fn main() {
    println!("Hello, world!");
}
```