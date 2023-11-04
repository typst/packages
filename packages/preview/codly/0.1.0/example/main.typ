#import "../codly.typ": *

#show: codly-init.with()

#let icon(codepoint) = {
  text(
      font: "tabler-icons", 
      fallback: false, 
      weight: "regular", 
      size: 8pt,
  )[#codepoint]
}

#set raw(syntaxes: (
  "./Phos.sublime-syntax"
))

#codly(languages: (
  rust: (name: "Rust", icon: icon("\u{fa53}"), color: rgb("#CE412B")),
  phos: (name: "PHÔS", icon: icon("\u{ed8a}"), color: rgb("#de8f6e")),
))

```rust
pub fn main() {
    println!("Hello, world!");
}
```

```phos
syn beam_forming(
    input: optical,
    phase_shifts: (electrical...),
) -> (optical...) {
    input
        |> split(splat(1.0, phase_shifts.len()))
        |> constrain(d_phase = 0)
        |> zip(phase_shifts)
        |> map(set modulate(type_: Modulation::Phase))
        |> constrain(d_delay = 0)
}
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

#codly-range(start: 5, end: 10)

```phos
syn beam_forming(
    input: optical,
    phase_shifts: (electrical...),
) -> (optical...) {
    input
        |> split(splat(1.0, phase_shifts.len()))
        |> constrain(d_phase = 0)
        |> zip(phase_shifts)
        |> map(set modulate(type_: Modulation::Phase))
        |> constrain(d_delay = 0)
}
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