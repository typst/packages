#import "../codly.typ": *

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

#show: codly.with(languages: (
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

#show: codly.with(languages: (
  rust: (name: "Rust", icon: icon("\u{fa53}"), color: rgb("#CE412B")),
), width-numbers: none)

```rust
pub fn main() {
    println!("Hello, world!");
}
```